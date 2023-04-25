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
    fn remove_liquidity(
        tokenA: ContractAddress,
        tokenB: ContractAddress,
        liquidity: u128,
        amountAMin: u128,
        amountBMin: u128,
        to: ContractAddress,
        deadline: u64,
    ) -> (u128, u128);
    fn swap_exact_tokens_for_tokens(
        amountIn: u128,
        amountOutMin: u128,
        path: Array::<ContractAddress>,
        to: ContractAddress,
        deadline: u64,
    ) -> Array::<u128>;
}


#[contract]
mod jedi_removeLiquidity {
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
    fn remove_liquidity_event(
        sender: ContractAddress,
        pool_address: ContractAddress,
        to_token: ContractAddress,
        tokens_rec: u128,
    ) {}

    #[external]
    fn remove_liquidity(
        to_token_address: ContractAddress,
        from_pair_address: ContractAddress,
        incoming_lp: u128,
        min_tokens_rec: u128,
        path0: Array::<ContractAddress>,
        path1: Array::<ContractAddress>,
    ) -> u128 {
        assert(!from_pair_address.is_zero(), 'zero address');
        assert(!to_token_address.is_zero(), 'from zero address');
        let sender = get_caller_address();

        let (amount0, amount1) = _remove_liquidity(from_pair_address, incoming_lp);

        let tokens_rec = _swap_tokens(
            from_pair_address, amount0, amount1, to_token_address, path0, path1
        );
        assert(tokens_rec >= min_tokens_rec, 'High');

        IERC20Dispatcher { contract_address: to_token_address }.transfer(sender, tokens_rec);
        remove_liquidity_event(sender, from_pair_address, to_token_address, tokens_rec);

        tokens_rec
    }

    fn _remove_liquidity(from_pair_address: ContractAddress, incoming_lp: u128) -> (u128, u128) {
        let (token0, token1) = _get_pair_tokens(from_pair_address);
        let router = _router::read();
        let contract_address = get_contract_address();
        let sender = get_caller_address();
        let deadline = _deadline::read();

        let erc20 = IERC20Dispatcher { contract_address: from_pair_address };

        erc20.transfer_from(sender, contract_address, incoming_lp);
        erc20.approve(router, 0_u128);
        erc20.approve(router, incoming_lp);

        let (amount0, amount1) = IRouterDispatcher {
            contract_address: router
        }.remove_liquidity(
            token0, token1, incoming_lp, 1_u128, 1_u128, contract_address, deadline, 
        );

        assert(amount0 != 0_u128, 'token0 insufficient');
        assert(amount1 != 0_u128, 'token1 insufficient');
        (amount0, amount1)
    }

    fn _swap_tokens(
        from_pair_address: ContractAddress,
        amount0: u128,
        amount1: u128,
        to_token: ContractAddress,
        path0: Array::<ContractAddress>,
        path1: Array::<ContractAddress>,
    ) -> u128 {
        let (token0, token1) = _get_pair_tokens(from_pair_address);
        let mut tokens_bought0 = 0_u128;
        let mut tokens_bought1 = 0_u128;

        tokens_bought0 =
            if token0 == to_token {
                amount0
            } else {
                _fill_quote(token0, to_token, amount0, path0)
            };

        tokens_bought1 =
            if token1 == to_token {
                amount1
            } else {
                _fill_quote(token1, to_token, amount1, path1)
            };

        tokens_bought0 + tokens_bought1
    }

    fn _get_pair_tokens(pair_address: ContractAddress) -> (ContractAddress, ContractAddress) {
        let token0 = IPairDispatcher { contract_address: pair_address }.token0();
        let token1 = IPairDispatcher { contract_address: pair_address }.token1();

        (token0, token1)
    }

    fn _fill_quote(
        from_token_address: ContractAddress,
        to_token_address: ContractAddress,
        amount: u128,
        path: Array::<ContractAddress>
    ) -> u128 {
        let contract_address = get_contract_address();
        let ierc20 = IERC20Dispatcher { contract_address: to_token_address };

        let initial_balance = ierc20.balance_of(contract_address);

        let router = _router::read();
        let deadline = _deadline::read();

        IERC20Dispatcher { contract_address: from_token_address }.approve(router, amount);
        let amounts = IRouterDispatcher {
            contract_address: router
        }.swap_exact_tokens_for_tokens(amount, 0_u128, path, contract_address, deadline, );

        let token_bought: u128 = *amounts[amounts.len() - 2];
        assert(token_bought > 0_u128, 'Tokens bought less than 0');

        let new_balance = ierc20.balance_of(contract_address);
        let final_balance = new_balance - initial_balance;
        assert(final_balance == 0_u128, 'Final balance should be 0');

        final_balance
    }
}
