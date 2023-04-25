use starknet::ContractAddress;
use array::ArrayTrait;

#[abi]
trait IERC20 {
    fn balance_of(account: ContractAddress) -> u128;
    fn transfer(recipient: ContractAddress, amount: u128) -> bool;
    fn transfer_from(sender: ContractAddress, recipient: ContractAddress, amount: u128) -> bool;
    fn approve(spender: ContractAddress, amount: u128) -> bool;
}

#[abi]
trait IPair {
    fn get_reserves() -> (u128, u128, u64);
    fn token0() -> ContractAddress;
    fn token1() -> ContractAddress;
}

#[abi]
trait IFactory {
    fn get_pair(token0: ContractAddress, token1: ContractAddress) -> ContractAddress;
}

#[abi]
trait IRouter {
    fn factory() -> ContractAddress;
    fn add_liquidity(
        tokenA: ContractAddress,
        tokenB: ContractAddress,
        amountADesired: u128,
        amountBDesired: u128,
        amountAMin: u128,
        amountBMin: u128,
        to: ContractAddress,
        deadline: u64,
    ) -> (u128, u128, u128);
    fn swap_exact_tokens_for_tokens(
        amountIn: u128,
        amountOutMin: u128,
        path: Array::<ContractAddress>,
        to: ContractAddress,
        deadline: u64,
    ) -> Array::<u128>;
}

#[contract]
mod jedi_liquidity {
    use starknet::ContractAddress;
    use array::ArrayTrait;
    use array::SpanTrait;
    use zeroable::Zeroable;
    use starknet::ContractAddressZeroable;
    use starknet::get_caller_address;
    use starknet::get_contract_address;
    use starknet::contract_address_const;


    use super::IPair;
    use super::IPairDispatcherTrait;
    use super::IPairDispatcher;

    use super::IERC20;
    use super::IERC20DispatcherTrait;
    use super::IERC20Dispatcher;

    use super::IRouter;
    use super::IRouterDispatcherTrait;
    use super::IRouterDispatcher;

    use super::IFactory;
    use super::IFactoryDispatcherTrait;
    use super::IFactoryDispatcher;

    struct Storage {
        _factory: ContractAddress,
        _router: ContractAddress,
        _deadline: u64,
    }

    #[view]
    fn get_router() -> ContractAddress {
        _router::read()
    }

    fn set_router(router_address: ContractAddress) {
        _router::write(router_address);
    }

    #[event]
    fn add_liquidity_event(
        sender: ContractAddress,
        from_token: ContractAddress,
        pool_address: ContractAddress,
        lp_amount: u128
    ) {}


    // External point of interaction
    #[external]
    fn add_liquidity(
        from_token_address: ContractAddress,
        pair_address: ContractAddress,
        amount: u128,
        min_pool_token: u128,
        path: Array::<ContractAddress>,
    ) -> u128 {
        assert(!pair_address.is_zero(), 'zero address');
        assert(!from_token_address.is_zero(), 'from zero address');
        assert(amount != 0_u128, 'zero amount');

        let sender = get_caller_address();
        let contract_address = get_contract_address();

        IERC20Dispatcher {
            contract_address: from_token_address
        }.transfer_from(sender, contract_address, amount);

        let lp_bought: u128 = _perform_add_liquidity(
            from_token_address, pair_address, amount, path
        );

        assert(lp_bought >= min_pool_token, 'less than minimum');

        IERC20Dispatcher { contract_address: pair_address }.transfer(sender, lp_bought);

        add_liquidity_event(sender, from_token_address, pair_address, lp_bought);

        lp_bought
    }


    // perform add_liquidity functionality. 
    fn _perform_add_liquidity(
        from_token_address: ContractAddress,
        pair_address: ContractAddress,
        amount: u128,
        path: Array::<ContractAddress>,
    ) -> u128 {
        let mut intermediate_amt: u128 = 0_u128;
        let mut intermediate_token: ContractAddress = contract_address_const::<0>();
        let (token0, token1) = _get_pair_tokens(pair_address);

        if (from_token_address == token0) {
            intermediate_amt = amount;
            intermediate_token = from_token_address;
        } else {
            if (from_token_address == token1) {
                intermediate_amt = amount;
                intermediate_token = from_token_address;
            } else {
                let (temp_amt, temp_token) = _fill_quote(
                    from_token_address, pair_address, amount, path
                );
                intermediate_amt = temp_amt;
                intermediate_token = temp_token;
            }
        }

        let (token0_bought, token1_bought) = _swap_intermediate(
            intermediate_token, token0, token1, intermediate_amt
        );
        _jedi_deposit(token0, token1, token0_bought, token1_bought)
    }

    // Actual liquidity call when both tokens are swapping into respective markets and amounts are satisfied
    fn _jedi_deposit(
        token0: ContractAddress, token1: ContractAddress, token0_bought: u128, token1_bought: u128, 
    ) -> u128 {
        let router: ContractAddress = _router::read();

        IERC20Dispatcher { contract_address: token0 }.approve(router, token0_bought);
        IERC20Dispatcher { contract_address: token1 }.approve(router, token1_bought);

        let contract_address = get_contract_address();
        let deadline: u64 = _deadline::read();
        let (amountA, amountB, liquidity) = IRouterDispatcher {
            contract_address: router
        }.add_liquidity(
            token0,
            token1,
            token0_bought,
            token1_bought,
            1_u128,
            1_u128,
            contract_address,
            deadline,
        );

        let sender = get_caller_address();

        if (amountA < token0_bought) { // Swap residual amount to loan_amt and transfer back to borrow contract
        }
        if (amountB < token1_bought) { //Swap residual amount here to loan_amt as well
        }

        liquidity
    }

    // get pair token addresses
    fn _get_pair_tokens(pair_address: ContractAddress) -> (ContractAddress, ContractAddress) {
        let token0 = IPairDispatcher { contract_address: pair_address }.token0();
        let token1 = IPairDispatcher { contract_address: pair_address }.token1();

        (token0, token1)
    }


    // fill quote for when token does not belong to A or B
    fn _fill_quote(
        from_token_address: ContractAddress,
        pair_address: ContractAddress,
        amount: u128,
        path: Array::<ContractAddress>
    ) -> (u128, ContractAddress) {
        let (token0, token1) = _get_pair_tokens(pair_address);
        let contract_address = get_contract_address();

        let initial_balance0: u128 = IERC20Dispatcher {
            contract_address: token0
        }.balance_of(contract_address);
        let initial_balance1: u128 = IERC20Dispatcher {
            contract_address: token1
        }.balance_of(contract_address);

        let router = _router::read();
        let deadline = _deadline::read();

        IERC20Dispatcher { contract_address: from_token_address }.approve(router, amount);

        let amounts = IRouterDispatcher {
            contract_address: router
        }.swap_exact_tokens_for_tokens(amount, 0_u128, path, contract_address, deadline);

        let token_bought: u128 = *amounts[1_u32];
        assert(token_bought > 0, 'token bought less than 0');

        let contract_token0_balance: u128 = IERC20Dispatcher {
            contract_address: token0
        }.balance_of(contract_address);

        let final_balance0: u128 = contract_token0_balance - initial_balance0;

        let contract_token1_balance: u128 = IERC20Dispatcher {
            contract_address: token1
        }.balance_of(contract_address);

        let final_balance1: u128 = contract_token1_balance - initial_balance1;

        let (amount_bought, intermediate_token) = if final_balance1 < final_balance0 {
            (final_balance0, token0)
        } else {
            (final_balance1, token1)
        };

        assert(amount_bought != 0_u128, 'Amount 0, revert');

        (amount_bought, intermediate_token)
    }


    // swap intermediate token to A or B market
    fn _swap_intermediate(
        intermediate_token: ContractAddress,
        token0: ContractAddress,
        token1: ContractAddress,
        amount: u128
    ) -> (u128, u128) {
        let factory: ContractAddress = _factory::read();
        let pair_address = IFactoryDispatcher {
            contract_address: factory
        }.get_pair(token0, token1);

        let (res0, res1, _) = IPairDispatcher { contract_address: pair_address }.get_reserves();
        let mut token1_bought = 0_u128;
        let mut token0_bought = 0_u128;
        let mut amount_to_swap = 0_u128;

        let amount_div_2 = amount / 2_u128;

        if (intermediate_token == token0) {
            let swap_amount: u128 = _calculate_swap_in_amount(res0, amount);

            amount_to_swap = if swap_amount <= 0 {
                amount_div_2
            } else {
                swap_amount
            };

            token1_bought = _token_to_token(intermediate_token, token1, amount_to_swap);
            token0_bought = amount - amount_to_swap;
        } else {
            let swap_amount: u128 = _calculate_swap_in_amount(res1, amount);

            amount_to_swap = if swap_amount <= 0 {
                amount_div_2
            } else {
                swap_amount
            };
            token0_bought = _token_to_token(intermediate_token, token0, amount_to_swap);
            token1_bought = amount - amount_to_swap;
        }

        (token0_bought, token1_bought)
    }

    // swap tokens for tokens
    fn _token_to_token(
        from_token: ContractAddress, to_token: ContractAddress, token_to_trade: u128
    ) -> u128 {
        if (from_token == to_token) {
            token_to_trade
        } else {
            let factory: ContractAddress = _factory::read();
            let router: ContractAddress = _router::read();
            IERC20Dispatcher { contract_address: from_token }.approve(router, token_to_trade);

            let pair_address = IFactoryDispatcher {
                contract_address: factory
            }.get_pair(from_token, to_token);
            assert(!pair_address.is_zero(), 'pair address 0');

            let mut path = ArrayTrait::new();
            path.append(from_token);
            path.append(to_token);

            let contract_address = get_contract_address();
            let deadline: u64 = _deadline::read();
            let amounts = IRouterDispatcher {
                contract_address: router
            }.swap_exact_tokens_for_tokens(
                token_to_trade, 0_u128, path, contract_address, deadline, 
            ); // using a large deadline

            let token_bought: u128 = *amounts[1_u32];
            assert(token_bought > 0_u128, 'Token bought less than 0');
            token_bought
        }
    }

    // Calculate amount which is equaivalent to root computation
    // (-b +- sqrRoot(4ac)) / 2a
    fn _calculate_swap_in_amount(reserve_in: u128, user_in: u128) -> u128 {
        let user_in_mul_3988000_add_reserve_in_mul_3988009 = user_in * 3988000_u128
            + reserve_in * 3988009_u128;
        let reserve_in_mul_user_in_mul_3988000_add_reserve_in_mul_3988009 = reserve_in
            * user_in_mul_3988000_add_reserve_in_mul_3988009;
        let sqrt = u128_sqrt(reserve_in_mul_user_in_mul_3988000_add_reserve_in_mul_3988009);

        let reserve_in_mul_1997 = reserve_in * 1997_u128;
        let sqrt_sub_reserve_in_mul_1997 = sqrt - reserve_in_mul_1997;

        let amount_to_swap = sqrt_sub_reserve_in_mul_1997 / 1994_u128;

        amount_to_swap
    }
// 1000 -> A + B
// // get_amount_out(x) = quote(1000 - x)
// amountIn * 997 / ((reserveIn * 1000) + amountIn * 997) = ((loan_amt - amountIn)) / reserveIn;
// amountIn * 997 * reserveIn = 

// 997*x**2 + 1997*x + 1000 = 0

// b = 1997 * reserve_in - 997 * 1000
// a = 997
// c = - 1000 * 1000 * reserve_in

// expand b according to (a + b)**2

// b**2 - 4ac
}

