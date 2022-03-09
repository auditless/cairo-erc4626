## SPDX-License-Identifier: AGPL-3.0-or-later

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import (
    ALL_ONES,
    Uint256,
    uint256_check,
    uint256_eq,
    uint256_lt,
    uint256_sub
)
from starkware.starknet.common.syscalls import (
    get_caller_address,
    get_contract_address
)

from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from openzeppelin.token.erc20.library import (
    ERC20_name,
    ERC20_symbol,
    ERC20_totalSupply,
    ERC20_decimals,
    ERC20_balanceOf,
    ERC20_allowance,
    ERC20_allowances,

    ERC20_initializer,
    ERC20_approve,
    ERC20_increaseAllowance,
    ERC20_decreaseAllowance,
    ERC20_transfer,
    ERC20_transferFrom,

    ERC20_mint,
    ERC20_burn,
)
from dependencies.erc4626.utils.fixedpointmathlib import mulDivUp, mulDivDown

## @title Generic ERC4626 vault
## @description An ERC4626-style vault implementation.
##              Adapted from the solmate implementation: https://github.com/Rari-Capital/solmate/blob/main/src/mixins/ERC4626.sol
## @author Peteris <github.com/Pet3ris>

# TODO: Apply uint256 checks for validity (uint256_check)

#############################################
##               CONSTRUCTOR               ##
#############################################

func ERC4626_initializer{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        asset: felt,
        name: felt,
        symbol: felt
    ):
    ERC20_initializer(name, symbol, 18)
    ERC4626_asset_.write(asset)
    return ()
end

#############################################
##                STORAGE                  ##
#############################################

@storage_var
func ERC4626_asset_() -> (asset: felt):
end

#############################################
##                 EVENTS                  ##
#############################################

@event
func ERC4626_deposit_event(from_: felt, to: felt, amount: Uint256, shares: Uint256):
end

@event
func ERC4626_withdraw_event(from_: felt, to: felt, amount: Uint256, shares: Uint256):
end

#############################################
##              MAX ACTIONS                ##
#############################################

func ERC4626_maxDeposit(to: felt) -> (maxAssets: Uint256):
    return (Uint256(ALL_ONES, ALL_ONES))
end

func ERC4626_maxMint(to: felt) -> (maxShares: Uint256):
    return (Uint256(ALL_ONES, ALL_ONES))
end

func ERC4626_maxRedeem{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(caller: felt) -> (maxShares: Uint256):
    return ERC20_balanceOf(caller)
end

#############################################
##                INTERNAL                 ##
#############################################

func ERC20_decreaseAllowance_manual{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(owner: felt, spender: felt, subtracted_value: Uint256) -> ():
    alloc_locals

    # This is vault logic, we place it here to avoid revoked references at callsite
    let (local msg_sender) = get_caller_address()
    if msg_sender == owner:
        return ()
    end

    # This is decreaseAllowance
    uint256_check(subtracted_value)
    let (local current_allowance: Uint256) = ERC20_allowances.read(owner=owner, spender=spender)
    let (local new_allowance: Uint256) = uint256_sub(current_allowance, subtracted_value)

    # validates new_allowance < current_allowance and returns 1 if true   
    let (enough_allowance) = uint256_lt(new_allowance, current_allowance)
    assert_not_zero(enough_allowance)

    ERC20_approve(spender, new_allowance)
    return ()
end
