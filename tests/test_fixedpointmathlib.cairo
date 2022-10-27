%lang starknet

from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq

from yagi.utils.fixedpointmathlib import mul_div_down, mul_div_up


const BASE = 1000000000000000000; // 10^18

func t_mul_div_down{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(a: felt, b: felt, c: felt, res: felt) {
    alloc_locals;
    let (r) = mul_div_down(Uint256(a, 0), Uint256(b, 0), Uint256(c, 0));
    let (eq) = uint256_eq(r, Uint256(res, 0));
    assert eq = TRUE;
    return ();
}

func t_mul_div_up{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(a: felt, b: felt, c: felt, res: felt) {
    alloc_locals;
    let (r) = mul_div_up(Uint256(a, 0), Uint256(b, 0), Uint256(c, 0));
    let (eq) = uint256_eq(r, Uint256(res, 0));
    assert eq = TRUE;
    return ();
}

@external
func test_mul_div_down{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    t_mul_div_down(13, 7, 5, 18);
    t_mul_div_down(7, 13, 5, 18);
    t_mul_div_down(13, BASE, 7, 1857142857142857142);
    t_mul_div_down(BASE, 13, 7, 1857142857142857142);
    t_mul_div_down(0, 7, BASE, 0);
    return ();
}

@external
func test_mul_div_up{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    t_mul_div_up(13, 7, 5, 19);
    t_mul_div_up(7, 13, 5, 19);
    t_mul_div_up(13, BASE, 7, 1857142857142857143);
    t_mul_div_up(BASE, 13, 7, 1857142857142857143);
    t_mul_div_up(0, 7, BASE, 0);
    return ();
}
