// use zeroable::Zeroable;
// use starknet::get_caller_address;
// use starknet::contract_address_const;
// use starknet::ContractAddress;
// use starknet::ContractAddressZeroable;
// use starknet::StorageAccess;
// use starknet::StorageBaseAddress;
// use starknet::SyscallResult;
// use starknet::storage_read_syscall;
// use starknet::storage_write_syscall;
// use starknet::storage_address_from_base_and_offset;
// use traits::Into;
// use traits::TryInto;
// use option::OptionTrait;
// use starknet::contract_address;
// #[derive(Copy, Drop)]
// struct MySwapPool {
//     name: u128,
//     token_a_address: ContractAddress,
//     token_a_reserves: u128,
//     token_b_address: ContractAddress,
//     token_b_reserves: u128,
//     fee_percentage: u128,
//     cfmm_type: u128,
//     liq_token: u128,
// }

// impl MySwapPoolSerde of serde::Serde::<MySwapPool> {
//         fn serialize(ref serialized: Array::<felt252>, input: MySwapPool) {
//             serde::Serde::<u128>::serialize(ref serialized, input.name);
//             serde::Serde::<ContractAddress>::serialize(ref serialized, input.token_a_address);
//             serde::Serde::<u128>::serialize(ref serialized, input.token_a_reserves);
//             serde::Serde::<ContractAddress>::serialize(ref serialized, input.token_b_address);
//             serde::Serde::<u128>::serialize(ref serialized, input.token_b_reserves);
//             serde::Serde::<u128>::serialize(ref serialized, input.fee_percentage);
//             serde::Serde::<u128>::serialize(ref serialized, input.cfmm_type);
//             serde::Serde::<u128>::serialize(ref serialized, input.liq_token);
//         }
//         fn deserialize(ref serialized: Span::<felt252>) -> Option::<MySwapPool> {
//             Option::Some(
//                 MySwapPool {
//                     name: serde::Serde::<u128>::deserialize(ref serialized)?,
//                     token_a_address: serde::Serde::<ContractAddress>::deserialize(ref serialized)?,
//                     token_a_reserves: serde::Serde::<u128>::deserialize(ref serialized)?,
//                     token_b_address: serde::Serde::<ContractAddress>::deserialize(ref serialized)?,
//                     token_b_reserves: serde::Serde::<u128>::deserialize(ref serialized)?,
//                     fee_percentage: serde::Serde::<u128>::deserialize(ref serialized)?,
//                     cfmm_type: serde::Serde::<u128>::deserialize(ref serialized)?,
//                     liq_token: serde::Serde::<u128>::deserialize(ref serialized)?,
//                 }
//             )
//         }
//     }

// impl MySwapPool_StorageAccess of StorageAccess::<MySwapPool> {
//     fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult::<MySwapPool> {
//         Result::Ok(
//             MySwapPool {
//                 name: storage_read_syscall(
//                     address_domain, storage_address_from_base_and_offset(base, 0_u8)
//                 )?.try_into().unwrap(),
//                 token_a_address: storage_read_syscall(
//                     address_domain, storage_address_from_base_and_offset(base, 1_u8)
//                 )?.try_into().unwrap(),
//                 token_a_reserves: storage_read_syscall(
//                     address_domain, storage_address_from_base_and_offset(base, 2_u8)
//                 )?.try_into().unwrap(),
//                 token_b_address: storage_read_syscall(
//                     address_domain, storage_address_from_base_and_offset(base, 3_u8)
//                 )?.try_into().unwrap(),
//                 token_b_reserves: storage_read_syscall(
//                     address_domain, storage_address_from_base_and_offset(base, 4_u8)
//                 )?.try_into().unwrap(),
//                 fee_percentage: storage_read_syscall(
//                     address_domain, storage_address_from_base_and_offset(base, 3_u8)
//                 )?.try_into().unwrap(),
//                 cfmm_type: storage_read_syscall(
//                     address_domain, storage_address_from_base_and_offset(base, 4_u8)
//                 )?.try_into().unwrap(),
//                 liq_token: storage_read_syscall(
//                     address_domain, storage_address_from_base_and_offset(base, 4_u8)
//                 )?.try_into().unwrap(),
//             }
//         )
//     }

//     fn write(
//         address_domain: u32, base: StorageBaseAddress, value: MySwapPool
//     ) -> SyscallResult::<()> {
//         storage_write_syscall(
//             address_domain, storage_address_from_base_and_offset(base, 0_u8), value.name.into()
//         )?;
//         storage_write_syscall(
//             address_domain,
//             storage_address_from_base_and_offset(base, 1_u8),
//             value.token_a_address.into()
//         )?;
//         storage_write_syscall(
//             address_domain,
//             storage_address_from_base_and_offset(base, 2_u8),
//             value.token_a_reserves.into()
//         )?;
//         storage_write_syscall(
//             address_domain,
//             storage_address_from_base_and_offset(base, 3_u8),
//             value.token_b_address.into()
//         )?;
//         storage_write_syscall(
//             address_domain,
//             storage_address_from_base_and_offset(base, 4_u8),
//             value.token_b_reserves.into()
//         )?;
//         storage_write_syscall(
//             address_domain,
//             storage_address_from_base_and_offset(base, 2_u8),
//             value.fee_percentage.into()
//         )?;
//         storage_write_syscall(
//             address_domain, storage_address_from_base_and_offset(base, 3_u8), value.cfmm_type.into()
//         )?;
//         storage_write_syscall(
//             address_domain, storage_address_from_base_and_offset(base, 4_u8), value.liq_token.into()
//         )
//     }
// }



// #[abi]
// trait IERC20 {
//     fn balance_of(account: ContractAddress) -> u128;
//     fn transfer(recipient: ContractAddress, amount: u128) -> bool;
//     fn transfer_from(sender: ContractAddress, recipient: ContractAddress, amount: u128) -> bool;
//     fn approve(spender: ContractAddress, amount: u128) -> bool;
// }


// #[abi]
// trait IFactory {
//     // fn get_pair(token0: ContractAddress, token1: ContractAddress) -> ContractAddress;
//     // fn get_pool(pool_id: u128) -> MySwapPool;
//     fn _myswap_pool_id(token0: ContractAddress, token1: ContractAddress) -> u128;
// }


// #[abi]
// trait IRouter {
//     // fn factory() -> ContractAddress;
//     fn add_liquidity(
//         a_address: ContractAddress,
//         a_amount: u128,
//         a_min_amount: u128,
//         b_address: ContractAddress,
//         b_amount: u128,
//         b_min_amount: u128,
//     ) -> (u128, u128); //actual1 and actual2
//     // fn swap_exact_tokens_for_tokens(
//     //     amountIn: u128,
//     //     amountOutMin: u128,
//     //     path: Array::<ContractAddress>,
//     //     to: ContractAddress,
//     //     deadline: u64,
//     // ) -> Array::<u128>;
//     fn swap(
//         pool_id: u128, token_from_addr: ContractAddress, amount_from: u128, amount_to_min: u128
//     ) -> u128;
// }

// #[contract]
// mod jedi_liquidity {
//     use starknet::ContractAddress;
//     use array::ArrayTrait;
//     use array::SpanTrait;
//     use zeroable::Zeroable;
//     use starknet::ContractAddressZeroable;
//     use starknet::get_caller_address;
//     use starknet::get_contract_address;
//     use starknet::contract_address_const;


//     use super::IPair;
//     use super::IPairDispatcherTrait;
//     use super::IPairDispatcher;

//     use super::IERC20;
//     use super::IERC20DispatcherTrait;
//     use super::IERC20Dispatcher;

//     use super::IRouter;
//     use super::IRouterDispatcherTrait;
//     use super::IRouterDispatcher;

//     use super::IFactory;
//     use super::IFactoryDispatcherTrait;
//     use super::IFactoryDispatcher;
//     use super::MySwapPool;

//     struct Storage {
//         _factory: ContractAddress,
//         _router: ContractAddress,
//         _deadline: u64,
//         my_swap_poolinfo: LegacyMap::<(ContractAddress, ContractAddress), u128>,
//         pool_asset: LegacyMap::<u128, MySwapPool>,
//     }

//     #[view]
//     fn get_router() -> ContractAddress {
//         _router::read()
//     }

//     fn set_router(router_address: ContractAddress) {
//         _router::write(router_address);
//     }

//     #[event]
//     fn zapped_in(
//         sender: ContractAddress,
//         from_token: ContractAddress,
//         pool_address: ContractAddress,
//         lp_amount: u128
//     ) {}


//     // External point of interaction
//     #[external]
//     fn zap_in(
//         from_token_address: ContractAddress,
//         pool_id: u128,
//         amount: u128,
//         min_pool_token: u128,
//         amount_from:u128,
//     ) -> u128 {
//         assert(!pool_id.is_zero(), 'zero address');
//         assert(!from_token_address.is_zero(), 'from zero address');
//         assert(amount != 0_u128, 'zero amount');

//         let sender = get_caller_address();
//         let contract_address = get_contract_address();

//         IERC20Dispatcher {
//             contract_address: from_token_address
//         }.transfer_from(sender, contract_address, amount);

//         let lp_bought: u128 = _perform_zap_in(from_token_address, pool_id, amount,0_u128,amount_from);

//         assert(lp_bought >= min_pool_token, 'less than minimum');

//         IERC20Dispatcher { contract_address: pair_address }.transfer(sender, lp_bought);

//         zapped_in(sender, from_token_address, pair_address, lp_bought, );

//         lp_bought
//     }


//     // perform zap_in functionality. Consider changing names, right now just copied off Jedi
//     fn _perform_zap_in(
//         from_token_address: ContractAddress,
//         pair_id: u128,
//         amount: u128,
//         amount_to_min: u128,
//         amount_from: u128,
//     ) -> (u128, u128) {
//         let mut intermediate_amt: u128 = 0_u128;
//         let mut intermediate_token: ContractAddress = contract_address_const::<0>();
//         let (token0, token1) = get_pair_address(pair_id);

//         if (from_token_address == token0) {
//             intermediate_amt = amount;
//             intermediate_token = from_token_address;
//         } else {
//             if (from_token_address == token1) {
//                 intermediate_amt = amount;
//                 intermediate_token = from_token_address;
//             } else {
//                 let (temp_amt, temp_token) = _fill_quote(
//                     pool_id, from_token_address, amount_from, amount_to_min, amount
//                 );
//                 intermediate_amt = temp_amt;
//                 intermediate_token = temp_token;
//             }
//         }

//         let (token0_bought, token1_bought) = _swap_intermediate(
//             intermediate_token, token0, token1, intermediate_amt
//         );
//         _jedi_deposit(token0, token1, token0_bought, token1_bought)
//     }

//     // Actual liquidity call when both tokens are swapping into respective markets and amounts are satisfied
//     fn _jedi_deposit(
//         token0: ContractAddress, token1: ContractAddress, token0_bought: u128, token1_bought: u128, 
//     ) -> u128 {
//         let router: ContractAddress = _router::read();

//         IERC20Dispatcher { contract_address: token0 }.approve(router, token0_bought);
//         IERC20Dispatcher { contract_address: token1 }.approve(router, token1_bought);

//         // let contract_address = get_contract_address();
//         let deadline: u64 = _deadline::read();
//         let (amountA, amountB) = IRouterDispatcher {
//             contract_address: router
//         }.add_liquidity(token0, token0_bought, 1_u128, token1, token1_bought, 1_u128, );

//         let sender = get_caller_address();

//         if (amountA < token0_bought) { // Swap residual amount to loan_amt and transfer back to borrow contract
//         }
//         if (amountB < token1_bought) { //Swap residual amount here to loan_amt as well
//         }

//         return (amountA, amountB);
//     }

//     // get pair token addresses
//     fn _get_pair_tokens(pool_id: ContractAddress) -> (ContractAddress, ContractAddress) {
//         let token0 = IPairDispatcher { contract_address: pair_address }.token0();
//         let token1 = IPairDispatcher { contract_address: pair_address }.token1();

//         (token0, token1)
//     }


//     // fill quote for when token does not belong to A or B
//     fn _fill_quote(
//         pool_id: u128,
//         token_from_addr: ContractAddress,
//         amount_from: u128,
//         amount_to_min: u128,
//         amount: u128,
//     ) -> (u128, ContractAddress) {
//         let (token0, token1) = get_pair_address(pool_id);
//         let contract_address = get_contract_address();

//         let initial_balance0: u128 = IERC20Dispatcher {
//             contract_address: token0
//         }.balance_of(contract_address);
//         let initial_balance1: u128 = IERC20Dispatcher {
//             contract_address: token1
//         }.balance_of(contract_address);

//         let router = _router::read();
//         let deadline = _deadline::read();

//         IERC20Dispatcher { contract_address: token_from_addr }.approve(router, amount);

//         let amounts = IRouterDispatcher {
//             contract_address: router
//         }.swap(pool_id, token_from_addr, amount_from, amount_to_min, deadline);

//         let token_bought: u128 = *amounts[1_u32];
//         assert(token_bought > 0, 'token bought less than 0');

//         let contract_token0_balance: u128 = IERC20Dispatcher {
//             contract_address: token0
//         }.balance_of(contract_address);

//         let final_balance0: u128 = contract_token0_balance - initial_balance0;

//         let contract_token1_balance: u128 = IERC20Dispatcher {
//             contract_address: token1
//         }.balance_of(contract_address);

//         let final_balance1: u128 = contract_token1_balance - initial_balance1;

//         let (amount_bought, intermediate_token) = if final_balance1 < final_balance0 {
//             (final_balance0, token0)
//         } else {
//             (final_balance1, token1)
//         };

//         assert(amount_bought != 0_u128, 'Amount 0, revert');

//         (amount_bought, intermediate_token)
//     }


//     // swap intermediate token to A or B market
//     fn _swap_intermediate(
//         intermediate_token: ContractAddress,
//         token0: ContractAddress,
//         token1: ContractAddress,
//         amount: u128,
//         pool_id: u128,
//     ) -> (u128, u128) {
//         let factory: ContractAddress = _factory::read();
//         let pair_address = IFactoryDispatcher {
//             contract_address: factory
//         }._myswap_pool_id(token0, token1);

//         let (res0, res1) = get_pair_reserves();
//         let mut token1_bought = 0_u128;
//         let mut token0_bought = 0_u128;
//         let mut amount_to_swap = 0_u128;

//         let amount_div_2 = amount / 2_u128;

//         if (intermediate_token == token0) {
//             let swap_amount: u128 = _calculate_swap_in_amount(res0, amount);

//             amount_to_swap = if swap_amount <= 0 {
//                 amount_div_2
//             } else {
//                 swap_amount
//             };

//             token1_bought = _token_to_token(intermediate_token, token1, amount_to_swap, pool_id);
//             token0_bought = amount - amount_to_swap;
//         } else {
//             let swap_amount: u128 = _calculate_swap_in_amount(res1, amount);

//             amount_to_swap = if swap_amount <= 0 {
//                 amount_div_2
//             } else {
//                 swap_amount
//             };
//             token0_bought = _token_to_token(intermediate_token, token0, amount_to_swap, pool_id);
//             token1_bought = amount - amount_to_swap;
//         }

//         (token0_bought, token1_bought)
//     }

//     // swap tokens for tokens
//     fn _token_to_token(
//         from_token: ContractAddress, to_token: ContractAddress, token_to_trade: u128, pool_id: u128, 
//     ) -> u128 {
//         if (from_token == to_token) {
//             token_to_trade
//         } else {
//             let factory: ContractAddress = _factory::read();
//             let router: ContractAddress = _router::read();
//             IERC20Dispatcher { contract_address: from_token }.approve(router, token_to_trade);

//             let pool_id = IFactoryDispatcher {
//                 contract_address: factory
//             }._myswap_pool_id(from_token, to_token);
//             assert(!pool_id.is_zero(), 'pool id is 0');

//             let mut path = ArrayTrait::new();
//             path.append(from_token);
//             path.append(to_token);

//             let contract_address = get_contract_address();
//             let amounts = IRouterDispatcher {
//                 contract_address: router
//             }.swap(pool_id, from_token, to_token, 0_u128);

//             let token_bought: u128 = *amounts[1_u32];
//             assert(token_bought > 0_u128, 'Token bought less than 0');
//             token_bought
//         }
//     }

//     // Calculate amount which is equaivalent to root computation
//     // (-b +- sqrRoot(4ac)) / 2a
//     fn _calculate_swap_in_amount(reserve_in: u128, user_in: u128) -> u128 {
//         let user_in_mul_3988000_add_reserve_in_mul_3988009 = user_in * 3988000_u128
//             + reserve_in * 3988009_u128;
//         let reserve_in_mul_user_in_mul_3988000_add_reserve_in_mul_3988009 = reserve_in
//             * user_in_mul_3988000_add_reserve_in_mul_3988009;
//         let sqrt = u128_sqrt(reserve_in_mul_user_in_mul_3988000_add_reserve_in_mul_3988009);

//         let reserve_in_mul_1997 = reserve_in * 1997_u128;
//         let sqrt_sub_reserve_in_mul_1997 = sqrt - reserve_in_mul_1997;

//         let amount_to_swap = sqrt_sub_reserve_in_mul_1997 / 1994_u128;

//         amount_to_swap
//     }

//     fn get_pair_address(pool_id: u128) -> (ContractAddress, ContractAddress) {
//         let pool: MySwapPool = pool_asset.read(pool_id);
//         let token0 = pool.token_a_address;
//         let token1 = pool.token_b_address;
//         return (token0, token1);
//     }

//     fn get_pair_reserves(pool_id: u128) -> (u128, u128) {
//         let pool: MySwapPool = pool_asset.read(pool_id);
//         let res1 = pool.token_a_reserves;
//         let res2 = pool.token_b_reserves;
//     }
// }

