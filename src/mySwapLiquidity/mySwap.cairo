use zeroable::Zeroable;
use starknet::get_caller_address;
use starknet::contract_address_const;
use starknet::ContractAddress;

use starknet::StorageAccess;
use starknet::StorageBaseAddress;
use starknet::SyscallResult;
use starknet::storage_read_syscall;
use starknet::storage_write_syscall;
use starknet::storage_address_from_base_and_offset;
use traits::Into;
use traits::TryInto;
use option::OptionTrait;
use starknet::contract_address;
#[derive(Copy, Drop)]
struct MySwapPool {
    name: u128,
    token_a_address: ContractAddress,
    token_a_reserves: u128,
    token_b_address: ContractAddress,
    token_b_reserves: u128,
    fee_percentage: u128,
    cfmm_type: u128,
    liq_token: u128,
}

impl MySwapPoolSerde of serde::Serde::<MySwapPool> {
        fn serialize(ref serialized: Array::<felt252>, input: MySwapPool) {
            serde::Serde::<u128>::serialize(ref serialized, input.name);
            serde::Serde::<ContractAddress>::serialize(ref serialized, input.token_a_address);
            serde::Serde::<u128>::serialize(ref serialized, input.token_a_reserves);
            serde::Serde::<ContractAddress>::serialize(ref serialized, input.token_b_address);
            serde::Serde::<u128>::serialize(ref serialized, input.token_b_reserves);
            serde::Serde::<u128>::serialize(ref serialized, input.fee_percentage);
            serde::Serde::<u128>::serialize(ref serialized, input.cfmm_type);
            serde::Serde::<u128>::serialize(ref serialized, input.liq_token);
        }
        fn deserialize(ref serialized: Span::<felt252>) -> Option::<MySwapPool> {
            Option::Some(
                MySwapPool {
                    name: serde::Serde::<u128>::deserialize(ref serialized)?,
                    token_a_address: serde::Serde::<ContractAddress>::deserialize(ref serialized)?,
                    token_a_reserves: serde::Serde::<u128>::deserialize(ref serialized)?,
                    token_b_address: serde::Serde::<ContractAddress>::deserialize(ref serialized)?,
                    token_b_reserves: serde::Serde::<u128>::deserialize(ref serialized)?,
                    fee_percentage: serde::Serde::<u128>::deserialize(ref serialized)?,
                    cfmm_type: serde::Serde::<u128>::deserialize(ref serialized)?,
                    liq_token: serde::Serde::<u128>::deserialize(ref serialized)?,
                }
            )
        }
    }

impl MySwapPool_StorageAccess of StorageAccess::<MySwapPool> {
    fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult::<MySwapPool> {
        Result::Ok(
            MySwapPool {
                name: storage_read_syscall(
                    address_domain, storage_address_from_base_and_offset(base, 0_u8)
                )?.try_into().unwrap(),
                token_a_address: storage_read_syscall(
                    address_domain, storage_address_from_base_and_offset(base, 1_u8)
                )?.try_into().unwrap(),
                token_a_reserves: storage_read_syscall(
                    address_domain, storage_address_from_base_and_offset(base, 2_u8)
                )?.try_into().unwrap(),
                token_b_address: storage_read_syscall(
                    address_domain, storage_address_from_base_and_offset(base, 3_u8)
                )?.try_into().unwrap(),
                token_b_reserves: storage_read_syscall(
                    address_domain, storage_address_from_base_and_offset(base, 4_u8)
                )?.try_into().unwrap(),
                fee_percentage: storage_read_syscall(
                    address_domain, storage_address_from_base_and_offset(base, 3_u8)
                )?.try_into().unwrap(),
                cfmm_type: storage_read_syscall(
                    address_domain, storage_address_from_base_and_offset(base, 4_u8)
                )?.try_into().unwrap(),
                liq_token: storage_read_syscall(
                    address_domain, storage_address_from_base_and_offset(base, 4_u8)
                )?.try_into().unwrap(),
            }
        )
    }

    fn write(
        address_domain: u32, base: StorageBaseAddress, value: MySwapPool
    ) -> SyscallResult::<()> {
        storage_write_syscall(
            address_domain, storage_address_from_base_and_offset(base, 0_u8), value.name.into()
        )?;
        storage_write_syscall(
            address_domain,
            storage_address_from_base_and_offset(base, 1_u8),
            value.token_a_address.into()
        )?;
        storage_write_syscall(
            address_domain,
            storage_address_from_base_and_offset(base, 2_u8),
            value.token_a_reserves.into()
        )?;
        storage_write_syscall(
            address_domain,
            storage_address_from_base_and_offset(base, 3_u8),
            value.token_b_address.into()
        )?;
        storage_write_syscall(
            address_domain,
            storage_address_from_base_and_offset(base, 4_u8),
            value.token_b_reserves.into()
        )?;
        storage_write_syscall(
            address_domain,
            storage_address_from_base_and_offset(base, 2_u8),
            value.fee_percentage.into()
        )?;
        storage_write_syscall(
            address_domain, storage_address_from_base_and_offset(base, 3_u8), value.cfmm_type.into()
        )?;
        storage_write_syscall(
            address_domain, storage_address_from_base_and_offset(base, 4_u8), value.liq_token.into()
        )
    }
}



#[abi]
trait IERC20 {
    fn balance_of(account: ContractAddress) -> u128;
    fn transfer(recipient: ContractAddress, amount: u128) -> bool;
    fn transfer_from(sender: ContractAddress, recipient: ContractAddress, amount: u128) -> bool;
    fn approve(spender: ContractAddress, amount: u128) -> bool;
}


#[abi]
trait IFactory {
    // fn get_pair(token0: ContractAddress, token1: ContractAddress) -> ContractAddress;
    // fn get_pool(pool_id: u128) -> MySwapPool;
    fn _myswap_pool_id(token0: ContractAddress, token1: ContractAddress) -> u128;
}


#[abi]
trait IRouter {
    // fn factory() -> ContractAddress;
    fn withdraw_liquidity(
        pool_id:u128,
        shares_amount: u128,
        amount_min_a: u128,
        amount_min_b: u128,
    ) -> (u128, u128,u128,u128);
    fn swap(
        pool_id: u128, token_from_addr: ContractAddress, amount_from: u128, amount_to_min: u128
    ) -> u128;
}
#[contract]
mod jedi_withdraw_liquidity {
    use starknet::ContractAddress;
    use array::ArrayTrait;
    use array::SpanTrait;
    use zeroable::Zeroable;
    use starknet::ContractAddressZeroable;
    use starknet::get_caller_address;
    use starknet::get_contract_address;
    use starknet::contract_address_const;
    use starknet::contract_address;

    use super::IERC20;
    use super::IERC20DispatcherTrait;
    use super::IERC20Dispatcher;

    use super::IRouter;
    use super::IRouterDispatcherTrait;
    use super::IRouterDispatcher;

    use super::IFactory;
    use super::IFactoryDispatcherTrait;
    use super::IFactoryDispatcher;
    use super::MySwapPool;

    struct Storage {
        _factory: ContractAddress,
        _router: ContractAddress,
        _deadline: u64,
        my_swap_poolinfo: LegacyMap::<(ContractAddress, ContractAddress), u128>,
        pool_asset: LegacyMap::<u128, MySwapPool>,
        _mySwap_router: ContractAddress,
    }

     #[event]
    fn Zapped_out(sender:ContractAddress,pool_id:u128,to_token:ContractAddress,tokens_rec:u128){}

    #[external]
    fn zap_out(pool_id:u128,to_token_address: ContractAddress,
    from_pair_address: ContractAddress,
    incoming_lp: u128,
    min_tokens_rec: u128,
    path0: Array::<ContractAddress>,
    path1: Array::<ContractAddress>) -> u128 {
        assert(!from_pair_address.is_zero(), 'zero address');
        assert(!to_token_address.is_zero(), 'from zero address');
        let sender = get_caller_address();
        let (amount0,amount1) = _remove_liquidity(pool_id,from_pair_address,incoming_lp);
        let tokens_rec = swap(
        from_pair_address, amount0, amount1, to_token_address,path0,path1
    );

        let check = min_tokens_rec - tokens_rec;
        assert(check > 0_u128 == 1,'High slippage');


        IERC20Dispatcher{to_token_address}.transfer(sender,tokens_rec);

        Zapped_out(sender,from_pair_address,to_token_address,tokens_rec);

        return tokens_rec;
    }

    #[external]
    fn withdraw_tokens(tokens:Array::<ContractAddress>){
        if(tokens.len() == 0_u32){
            return ();
        }

        let contract_address = get_contract_address();
        let ierc20_address =  *tokens.at(0);
        let amount = IERC20Dispatcher{contract_address:ierc20_address}.balance_of(contract_address);
        // IERC20Dispatcher{ierc20_address}.transfer(owner,amount);
        // return withdraw_tokens
    }


    fn _remove_liquidity(pool_id:u128,from_pair_address:ContractAddress ,incoming_lp: u128) -> (u128,u128){
        let (token0,token1) = get_pair_address();
        let router = _mySwap_router::read();
        let contract_address = get_contract_address();
        let sender = get_caller_address();
        IERC20Dispatcher{from_pair_address}.transferFrom(sender,contract_address,incoming_lp);
        IERC20Dispatcher{from_pair_address}.approve(router,0_u128);
        IERC20Dispatcher{from_pair_address}.approve(router,incoming_lp);

        let (amount0,amount1) = IRouterDispatcher{contract_address:router}.withdraw_liquidity{
            pool_id:pool_id,shares_amount:incoming_lp,amount_min_a:1_u128,amount_min_b:1_u128    
            };
            assert(amount0 == 0_u128,'Remove liquidity');
            assert(amount1 == 0_u128,'Remove liquidity');
            
            return (amount0,amount1);

    }

    fn _swap_tokens(pool_id: u128,from_pair_address:ContractAddress,amount0:u128, amount1:u128, to_token:ContractAddress,path0: Array::<ContractAddress>,path1: Array::<ContractAddress>) -> u128 {
        let (token0,token1) = get_pair_address();
        if(token0 == to_token){
            let tokens_bought0 = amount0;
        } else {
            let amount_rec = _fill_quote(token0,to_token,amount0,path0);
        }

        if(token1==to_token){
            let tokens_bought1 = amount1;
        } else {
            let amount_rec = _fill_quote(token1,to_token,amount1,path1);
        }

        let tokens_bought = tokens_bought0 + tokens_bought1;
        return tokens_bought;
    }

    fn _fill_quote(
        pool_id: u128,
        token_from_addr: ContractAddress,
        amount_from: u128,
        amount_to_min: u128,
        amount: u128,
    ) -> (u128, ContractAddress) {
        let (token0, token1) = get_pair_address(pool_id);
        let contract_address = get_contract_address();

        let initial_balance0: u128 = IERC20Dispatcher {
            contract_address: token0
        }.balance_of(contract_address);
        let initial_balance1: u128 = IERC20Dispatcher {
            contract_address: token1
        }.balance_of(contract_address);

        let router = _router::read();
        let deadline = _deadline::read();

        IERC20Dispatcher { contract_address: token_from_addr }.approve(router, amount);

        let amounts = IRouterDispatcher {
            contract_address: router
        }.swap(pool_id, token_from_addr, amount_from, amount_to_min, deadline);

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

    fn get_pair_address(pool_id: u128) -> (ContractAddress, ContractAddress) {
        let pool: MySwapPool = pool_asset.read(pool_id);
        let token0 = pool.token_a_address;
        let token1 = pool.token_b_address;
        return (token0, token1);
    }
}




