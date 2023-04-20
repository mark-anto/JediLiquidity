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
        liquidity:u128,
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
    fn zapped_out(
        sender: ContractAddress,
        pool_address: ContractAddress,
        to_token: ContractAddress,
        tokens_rec: u128,
    ) {}

#[external]
fn zap_out(
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
        from_pair_address, amount0, amount1, to_token_address,path0,path1
    );

    if(tokens_rec >= min_tokens_rec){

    }

    let (is_tokens_rec_less_than_min_tokens_rec) = uint256_lt(tokens_rec, min_tokens_rec);
    with_attr error_message('ZapperOut::zap_out:: High Slippage') {
        assert is_tokens_rec_less_than_min_tokens_rec = 0;
    }

 
    let tokens_rec_after_fees: u128 = uint256_checked_sub_lt(tokens_rec, goodwill_portion);

    IERC20.transfer(
        contract_address=to_token_address, recipient=sender, amount=tokens_rec_after_fees
    );

    Zapped_out.emit(
        sender=sender,
        pool_address=from_pair_address,
        to_token=to_token_address,
        tokens_rec=tokens_rec_after_fees,
    );
    return (tokens_rec_after_fees,);
}

}