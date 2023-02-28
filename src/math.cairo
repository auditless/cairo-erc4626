#[derive(Copy, Drop)]
enum Rounding {
    Down: (), // Toward negative infinity
    Up: (), // Toward infinity
    Zero: (), // Toward zero
}

// Return x * y / denominator rounded down
fn mul_div_down(x: u128, y: u128, denominator: u128) -> u128 {
    let max_u128 = 0xffffffffffffffffffffffffffffffff_u128;
    let cond = denominator != 0_u128 & (y == 0_u128 | x <= max_u128 / y);
    assert(cond, 'division underflow');
    x * y / denominator
}

// Return x * y % denominator
fn mul_mod(x: u128, y: u128, denominator: u128) -> u128 {
    x * y % denominator
}

// Return x * y / denominator with specified rounding
fn mul_div(x: u128, y: u128, denominator: u128, rounding: Rounding) -> u128 {
    let result = mul_div_down(x, y, denominator);
    match rounding {
        Rounding::Down(_) => result,
        Rounding::Up(_) => if mul_mod(x, y, denominator) > 0_u128 {
            result + 1_u128
        } else {
            result
        },
        Rounding::Zero(_) => result,
    }
}
