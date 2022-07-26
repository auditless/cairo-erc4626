%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from yagi.utils.fixedpointmathlib import mul_div_down, mul_div_up

@external
func mul_div_down_ext{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(x: Uint256, y: Uint256, denominator: Uint256) -> (z: Uint256):
    return mul_div_down(x, y, denominator)
end

@external
func mul_div_up_ext{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(x: Uint256, y: Uint256, denominator: Uint256) -> (z: Uint256):
    return mul_div_up(x, y, denominator)
end
