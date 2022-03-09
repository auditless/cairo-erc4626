import asyncio
from pathlib import Path
import pytest
import pytest_asyncio

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.testing.contract import StarknetContract


FIXED_POINT_MATH_LIB_FILE = str(Path("tests", "mocks", "fixedpointmathlib_mock.cairo"))


@pytest.fixture(scope="module")
def event_loop():
    return asyncio.new_event_loop()


@pytest_asyncio.fixture(scope="module")
async def starknet() -> Starknet:
    return await Starknet.empty()


@pytest_asyncio.fixture(scope="module")
async def fxpm(starknet: Starknet) -> StarknetContract:
    return await starknet.deploy(source=FIXED_POINT_MATH_LIB_FILE)
