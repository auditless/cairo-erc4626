import pytest

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.testing.contract import StarknetContract

from ..util import str_to_felt, uint


@pytest.mark.asyncio
async def test_erc4626_asset(ctx_factory):
    ctx = ctx_factory()
    assert (await ctx.vault.asset().call()).result == (ctx.asset.contract_address,)


@pytest.mark.asyncio
async def test_erc4626_deposit(ctx_factory):
    ctx = ctx_factory()
    amount = 10 ** 3

    # Approve deposit amount
    await ctx.execute(
        "owner",
        ctx.asset.contract_address,
        "approve",
        [ctx.vault.contract_address, *uint(amount)],
    )

    # Deposit amount
    await ctx.execute(
        "owner",
        ctx.vault.contract_address,
        "deposit",
        [*uint(amount), ctx.owner.contract_address],
    )

    # Check deposit
    assert (await ctx.vault.balanceOf(ctx.owner.contract_address).call()).result == (
        uint(amount),
    )
    assert (await ctx.vault.afterDepositHookCalledCounter().call()).result == (1,)
