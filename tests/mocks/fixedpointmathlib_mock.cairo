%lang starknet

from starkware.cairo.common.uint256 import Uint256

from dependencies.erc4626.utils.fixedpointmathlib import mulDivDown, mulDivUp

@external
func mulDivDown_ext{
    range_check_ptr
}(
    x: Uint256,
    y: Uint256,
    denominator: Uint256
) -> (z: Uint256):
    return mulDivDown(x, y, denominator)
end

@external
func mulDivUp_ext{
    range_check_ptr
}(
    x: Uint256,
    y: Uint256,
    denominator: Uint256
) -> (z: Uint256):
    return mulDivUp(x, y, denominator)
end
