use cairo_erc4626::fib;

#[test]
#[available_gas(200000)]
fn fib_test() {
    assert(fib::fib(0, 1, 10) == 55, 'invalid');
}
