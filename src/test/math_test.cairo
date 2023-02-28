use option::OptionTrait;
use traits::TryInto;
use traits::PartialEq;

use cairo_erc4626::math::mul_div;
use cairo_erc4626::math::Rounding;

fn t_mul_div_down(x: felt, y: felt, denominator: felt, expected: felt) {
    let result = mul_div(x.try_into().unwrap(), y.try_into().unwrap(), denominator.try_into().unwrap(), Rounding::Down(()));
    assert(result == expected.try_into().unwrap(), 'mul_div invalid');
}

fn t_mul_div_up(x: felt, y: felt, denominator: felt, expected: felt) {
    let result = mul_div(x.try_into().unwrap(), y.try_into().unwrap(), denominator.try_into().unwrap(), Rounding::Up(()));
    assert(result == expected.try_into().unwrap(), 'mul_div invalid');
}

#[test]
fn test_mul_div_down() {
    let base = 1000000000000000000;
    t_mul_div_down(13, 7, 5, 18);
    t_mul_div_down(7, 13, 5, 18);
    t_mul_div_down(13, base, 7, 1857142857142857142);
    t_mul_div_down(base, 13, 7, 1857142857142857142);
    t_mul_div_down(0, 7, base, 0);
}

#[test]
fn test_mul_div_up() {
    let base = 1000000000000000000;
    t_mul_div_up(13, 7, 5, 19);
    t_mul_div_up(7, 13, 5, 19);
    t_mul_div_up(13, base, 7, 1857142857142857143);
    t_mul_div_up(base, 13, 7, 1857142857142857143);
    t_mul_div_up(0, 7, base, 0);
}

#[test]
#[should_panic(expected = ('division underflow',))]
fn test_mul_div_down_failed() {
    mul_div(1_u128, 1_u128, 0_u128, Rounding::Down(()));
}

#[test]
#[should_panic(expected = ('division underflow',))]
fn test_mul_div_up_failed() {
    mul_div(1_u128, 1_u128, 0_u128, Rounding::Up(()));
}
