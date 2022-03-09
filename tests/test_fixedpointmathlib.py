import pytest

from .util import uint

from starkware.starknet.testing.contract import StarknetContract

BASE = 10 ** 18
args = [(13, 7, BASE), (0, 7, BASE), (10 ** 27, 8, 8), (10 ** 27, 8, 10 ** 27)]


@pytest.mark.asyncio
async def test_mulDivDown_works(fxpm: StarknetContract):
    for x, y, d in args:
        assert (await fxpm.mulDivDown_ext(uint(x), uint(y), uint(d)).call()).result == (
            uint(x * y // d),
        )


@pytest.mark.asyncio
async def test_mulDivUp_works(fxpm: StarknetContract):
    for x, y, d in args:
        assert (await fxpm.mulDivUp_ext(uint(x), uint(y), uint(d)).call()).result == (
            uint((x * y - 1) // d + 1),
        )
