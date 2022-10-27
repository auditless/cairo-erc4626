%lang starknet

from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.starknet.common.syscalls import get_caller_address

from yagi.erc4626.interfaces.IERC4626 import IERC4626


const BASE = 1000000000000000000;

@external
func __setup__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    // Deploy an ERC20 token and an ERC4626 mock vault

    %{ stop_prank_callable = start_prank(123) %}

    let (admin) = get_caller_address();

    let erc20_name = 'Test Token';
    let erc20_symbol = 'TEST';
    let erc20_decimals = 18;
    let erc20_supply = BASE;

    let erc4626_name = 'Test Yield Vault';
    let erc4626_symbol = 'yTEST';

    %{ context.erc20 = deploy_contract("./openzeppelin/token/erc20/presets/ERC20.cairo", [ids.erc20_name, ids.erc20_symbol, ids.erc20_decimals, ids.erc20_supply, 1, ids.admin]).contract_address %}
    %{ context.erc4626 = deploy_contract("./tests/mocks/ERC4626_mock.cairo", [context.erc20, ids.erc4626_name, ids.erc4626_symbol]).contract_address %}

    %{ stop_prank_callable() %}

    return ();
}


@external
func test_asset{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    // Check if the vault's underlying asset is correctly set

    alloc_locals;

    tempvar erc20;
    tempvar erc4626;
    %{ ids.erc20 = context.erc20 %}
    %{ ids.erc4626 = context.erc4626 %}

    let (asset) = IERC4626.asset(contract_address=erc4626);
    assert asset = erc20;

    return ();
}
