use jediSwapLiquidity::fib::fibbo;

#[test]
#[available_gas(2000000000000)]
fn test() {
    debug::print_felt252('Hello');
    debug::print_felt252(fibbo::fib(1, 2, 13));
}
