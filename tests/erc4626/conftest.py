import asyncio
import pytest
import pytest_asyncio
from pathlib import Path
import sys
from types import SimpleNamespace

import dill

from starkware.starknet.compiler.compile import compile_starknet_files
from starkware.starknet.testing.starknet import Starknet, StarknetContract

from ..util import str_to_felt, uint, TestSigner

# pytest-xdest only shows stderr
sys.stdout = sys.stderr


CONTRACT_SRC = [str(Path(__file__).parent.parent.parent)]


@pytest.fixture(scope="session")
def event_loop():
    return asyncio.new_event_loop()


def compile(path):
    return compile_starknet_files(
        files=[
            CONTRACT_SRC[0] + "/" + path
        ],  # TODO: Fix so that cairo path is used automatically
        debug_info=True,
        cairo_path=CONTRACT_SRC,
    )


async def deploy_account(starknet, signer, account_def):
    return await starknet.deploy(
        contract_def=account_def,
        constructor_calldata=[signer.public_key],
    )


# StarknetContracts contain an immutable reference to StarknetState, which
# means if we want to be able to use StarknetState's `copy` method, we cannot
# rely on StarknetContracts that were created prior to the copy.
# For this reason, we specifically inject a new StarknetState when
# deserializing a contract.
def serialize_contract(contract, abi):
    return dict(
        abi=abi,
        contract_address=contract.contract_address,
        deploy_execution_info=contract.deploy_execution_info,
    )


async def build_copyable_deployment():
    # Adapted from zorro.xyz
    starknet = await Starknet.empty()

    defs = SimpleNamespace(
        account=compile("openzeppelin/account/Account.cairo"),
        erc20_mintable=compile("openzeppelin/token/erc20/ERC20_Mintable.cairo"),
        erc4626_mock=compile("tests/mocks/ERC4626_mock.cairo"),
    )

    signers = dict(
        owner=TestSigner(8249684680), admin=TestSigner(2849643986), user=TestSigner(89238549868)
    )

    # Maps from name -> account contract
    accounts = SimpleNamespace(
        **{
            name: (await deploy_account(starknet, signer, defs.account))
            for name, signer in signers.items()
        }
    )

    # Underlying asset
    initial_supply = uint(100 * 10 ** 18)
    asset = await starknet.deploy(
        contract_def=defs.erc20_mintable,
        constructor_calldata=[
            str_to_felt("Ether"),
            str_to_felt("ETH"),
            18,
            *initial_supply,
            accounts.owner.contract_address,
            accounts.owner.contract_address,
        ],
    )

    vault = await starknet.deploy(
        contract_def=defs.erc4626_mock,
        constructor_calldata=[
            asset.contract_address,
            str_to_felt("vaultEther"),
            str_to_felt("vETH"),
        ],
    )

    consts = SimpleNamespace()

    return SimpleNamespace(
        starknet=starknet,
        consts=consts,
        signers=signers,
        serialized_contracts=dict(
            owner=serialize_contract(accounts.owner, defs.account.abi),
            admin=serialize_contract(accounts.admin, defs.account.abi),
            user=serialize_contract(accounts.user, defs.account.abi),
            asset=serialize_contract(asset, defs.erc20_mintable.abi),
            vault=serialize_contract(vault, defs.erc4626_mock.abi),
        ),
    )


@pytest_asyncio.fixture(scope="session")
async def copyable_deployment(request):
    CACHE_KEY = "deployment"
    val = request.config.cache.get(CACHE_KEY, None)
    if val is None:
        val = await build_copyable_deployment()
        res = dill.dumps(val).decode("cp437")
        request.config.cache.set(CACHE_KEY, res)
    else:
        val = dill.loads(val.encode("cp437"))
    return val


def unserialize_contract(starknet_state, serialized_contract):
    return StarknetContract(state=starknet_state, **serialized_contract)


@pytest_asyncio.fixture(scope="session")
async def ctx_factory(copyable_deployment):
    serialized_contracts = copyable_deployment.serialized_contracts
    signers = copyable_deployment.signers
    consts = copyable_deployment.consts

    def make():
        starknet_state = copyable_deployment.starknet.state.copy()
        contracts = {
            name: unserialize_contract(starknet_state, serialized_contract)
            for name, serialized_contract in serialized_contracts.items()
        }

        async def execute(account_name, contract_address, selector_name, calldata):
            return await signers[account_name].send_transaction(
                contracts[account_name],
                contract_address,
                selector_name,
                calldata,
            )

        return SimpleNamespace(
            starknet=Starknet(starknet_state),
            consts=consts,
            execute=execute,
            **contracts,
        )

    return make
