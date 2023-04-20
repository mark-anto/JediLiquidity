use zeroable::Zeroable;
use starknet::get_caller_address;
use starknet::contract_address_const;
use starknet::ContractAddress;
use starknet::ContractAddressZeroable;
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
    fn remove_liquidity(
        a_address: ContractAddress,
        a_amount: u128,
        a_min_amount: u128,
        b_address: ContractAddress,
        b_amount: u128,
        b_min_amount: u128,
    ) -> (u128, u128);
    fn swap(
        pool_id: u128, token_from_addr: ContractAddress, amount_from: u128, amount_to_min: u128
    ) -> u128;
}