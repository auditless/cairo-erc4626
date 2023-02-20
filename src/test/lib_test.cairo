use cairo_erc4626::fib;

#[test]
fn fib_test() {
    assert(fib::fib(0, 1, 10) == 5, 'invalid');
}
