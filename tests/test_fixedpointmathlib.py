import pytest

from .util import uint

from starkware.starknet.testing.contract import StarknetContract

BASE = 10 ** 18
args = [(13, 7, BASE), (0, 7, BASE), (10 ** 27, 8, 8), (10 ** 27, 8, 10 ** 27)]


@pytest.mark.asyncio
async def test_mul_div_down_works(fxpm: StarknetContract):
    for x, y, d in args:
        assert (await fxpm.mul_div_down_ext(uint(x), uint(y), uint(d)).call()).result == (
            uint(x * y // d),
        )


@pytest.mark.asyncio
async def test_mul_div_up_works(fxpm: StarknetContract):
    for x, y, d in args:
        assert (await fxpm.mul_div_up_ext(uint(x), uint(y), uint(d)).call()).result == (
            uint((x * y - 1) // d + 1),
        )
