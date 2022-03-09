## SPDX-License-Identifier: AGPL-3.0-or-later

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (
    get_caller_address,
    get_contract_address
)
from starkware.cairo.common.uint256 import (
    ALL_ONES,
    Uint256,
    uint256_check,
    uint256_eq,
    uint256_lt,
    uint256_sub
)

from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from openzeppelin.token.erc20.library import (
    ERC20_balanceOf,
    ERC20_mint,
    ERC20_burn,
    ERC20_totalSupply
)
from openzeppelin.utils.constants import TRUE

from dependencies.erc4626.library import (
    ERC4626_initializer,
    ERC4626_asset_,

    ERC4626_maxDeposit,
    ERC4626_maxMint,
    ERC4626_maxRedeem,

    ERC4626_deposit_event,
    ERC4626_withdraw_event,
    
    ERC20_decreaseAllowance_manual
)
from dependencies.erc4626.utils.fixedpointmathlib import (
    mulDivDown,
    mulDivUp,
)

## @title Generic ERC4626 vault (copy this to build your own).
## @description An ERC4626-style vault implementation.
##              Adapted from the solmate implementation: https://github.com/Rari-Capital/solmate/blob/main/src/mixins/ERC4626.sol
## @dev When extending this contract, don't forget to incorporate the ERC20 implementation.
## @author Peteris <github.com/Pet3ris>

# TODO: Apply uint256 checks for validity (uint256_check)

#############################################
##               CONSTRUCTOR               ##
#############################################

@constructor
func constructor{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        asset: felt,
        name: felt,
        symbol: felt
    ):
    ERC4626_initializer(asset, name, symbol)
    return ()
end

#############################################
##                GETTERS                  ##
#############################################

@view
func asset{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (asset: felt):
    return ERC4626_asset_.read()
end

#############################################
##               INTERNAL                  ##
#############################################

func ERC4626_assetsOf{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(user: felt) -> (assets: Uint256):
    alloc_locals
    let (local balance) = ERC20_balanceOf(user)
    return ERC4626_previewRedeem(balance)
end

#############################################
##                 ACTIONS                 ##
#############################################

func ERC4626_deposit{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(assets: Uint256, receiver: felt) -> (shares: Uint256):
    alloc_locals

    # Check for rounding error since we round down in previewDeposit.
    let (local shares) = ERC4626_previewDeposit(assets)
    with_attr error_message("ZERO SHARES"):
        let ZERO = Uint256(0, 0)
        let (shares_is_zero) = uint256_eq(shares, ZERO)
        assert shares_is_zero = 0
    end

    # Need to transfer before minting or ERC777s could reenter.
    let (asset) = ERC4626_asset_.read()
    let (local msg_sender) = get_caller_address()
    let (local this) = get_contract_address()
    IERC20.transferFrom(contract_address=asset, sender=msg_sender, recipient=this, amount=assets)

    ERC20_mint(receiver, shares)

    ERC4626_deposit_event.emit(msg_sender, receiver, assets, shares)

    afterDeposit(assets, shares)

    return (shares)
end

func ERC4626_mint{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(shares: Uint256, receiver: felt) -> (assets: Uint256):
    alloc_locals

    # No need to check for rounding error, previewMint rounds up.
    let (local assets) = ERC4626_previewMint(shares)

    # Need to transfer before minting or ERC777s could reenter.
    let (asset) = ERC4626_asset_.read()
    let (local msg_sender) = get_caller_address()
    let (local this) = get_contract_address()
    IERC20.transferFrom(contract_address=asset, sender=msg_sender, recipient=this, amount=assets)

    ERC20_mint(receiver, shares)

    ERC4626_deposit_event.emit(msg_sender, receiver, assets, shares)

    afterDeposit(assets, shares)

    return (assets)
end

func ERC4626_withdraw{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(assets: Uint256, receiver: felt, owner: felt) -> (shares: Uint256):
    alloc_locals
    # No need to check for rounding error, previewWithdraw rounds up.
    let (local shares) = ERC4626_previewWithdraw(assets)

    let (local msg_sender) = get_caller_address()
    ERC20_decreaseAllowance_manual(owner, msg_sender, shares)

    beforeWithdraw(assets, shares)

    ERC20_burn(owner, shares)

    ERC4626_withdraw_event.emit(owner, receiver, assets, shares)

    let (asset) = ERC4626_asset_.read()
    IERC20.transfer(contract_address=asset, recipient=receiver, amount=assets)

    return (shares)
end

func ERC4626_redeem{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(shares: Uint256, receiver: felt, owner: felt) -> (assets: Uint256):
    alloc_locals
    let (local msg_sender) = get_caller_address()
    ERC20_decreaseAllowance_manual(owner, msg_sender, shares)

    # Check for rounding error since we round down in previewRedeem.    
    let (local assets) = ERC4626_previewRedeem(shares)
    let ZERO = Uint256(0, 0)
    let (assets_is_zero) = uint256_eq(assets, ZERO)
    with_attr error_message("ZERO ASSETS"):
        assert assets_is_zero = 0
    end

    beforeWithdraw(assets, shares)

    ERC20_burn(owner, shares) 

    ERC4626_withdraw_event.emit(owner, receiver, assets, shares)

    let (asset) = ERC4626_asset_.read()
    IERC20.transfer(contract_address=asset, recipient=receiver, amount=assets)

    return (assets)
end

@external
func deposit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(assets: Uint256, receiver: felt) -> (shares: Uint256):
    return ERC4626_deposit(assets, receiver)
end

@external
func mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(shares: Uint256, receiver: felt) -> (assets: Uint256):
    return ERC4626_mint(shares, receiver)
end

@external
func withdraw{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(assets: Uint256, receiver: felt, owner: felt) -> (shares: Uint256):
    return ERC4626_withdraw(assets, receiver, owner)
end

@external
func redeem{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(shares: Uint256, receiver: felt, owner: felt) -> (assets: Uint256):
    return ERC4626_redeem(shares, receiver, owner)
end

#############################################
##              MAX ACTIONS                ##
#############################################

func ERC4626_maxWithdraw{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(from_: felt) -> (maxAssets: Uint256):
    return ERC4626_assetsOf(from_)
end

@view
func maxDeposit(to: felt) -> (maxAssets: Uint256):
    return ERC4626_maxDeposit(to)
end

@view
func maxMint(to: felt) -> (maxShares: Uint256):
    return ERC4626_maxMint(to)
end

@view
func maxWithdraw{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(from_: felt) -> (maxAssets: Uint256):
    return ERC4626_maxWithdraw(from_)
end

@view
func maxRedeem{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(caller: felt) -> (maxShares: Uint256):
    return ERC4626_maxRedeem(caller)
end

#############################################
##            PREVIEW ACTIONS              ##
#############################################

func ERC4626_previewDeposit{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(assets: Uint256) -> (shares: Uint256):
    alloc_locals

    let (local supply) = ERC20_totalSupply()
    let (local allAssets) = totalAssets()
    let ZERO = Uint256(0, 0)
    let (supply_is_zero) = uint256_eq(supply, ZERO)
    if supply_is_zero == 1:
        return (assets)
    end
    let (local z) = mulDivDown(assets, supply, allAssets)
    return (z)
end

func ERC4626_previewMint{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(shares: Uint256) -> (assets: Uint256):
    alloc_locals

    let (local supply) = ERC20_totalSupply()
    let (local allAssets) = totalAssets()
    let ZERO = Uint256(0, 0)
    let (supply_is_zero) = uint256_eq(supply, ZERO)
    if supply_is_zero == 1:
        return (shares)
    end
    let (local z) = mulDivUp(shares, allAssets, supply)
    return (z)
end

func ERC4626_previewWithdraw{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(assets: Uint256) -> (shares: Uint256):
    alloc_locals

    let (local supply) = ERC20_totalSupply()
    let (local allAssets) = totalAssets()
    let ZERO = Uint256(0, 0)
    let (supply_is_zero) = uint256_eq(supply, ZERO)
    if supply_is_zero == 1:
        return (assets)
    end
    let (local z) = mulDivUp(assets, supply, allAssets)
    return (z)
end

func ERC4626_previewRedeem{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
        }(shares: Uint256) -> (assets: Uint256):
    alloc_locals

    let (local supply) = ERC20_totalSupply()
    let (local allAssets) = totalAssets()
    let ZERO = Uint256(0, 0)
    let (supply_is_zero) = uint256_eq(supply, ZERO)
    if supply_is_zero == 1:
        return (shares)
    end
    let (local z) = mulDivDown(shares, allAssets, supply)
    return (z)
end


@view
func previewDeposit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(assets: Uint256) -> (shares: Uint256):
    return ERC4626_previewDeposit(assets)
end

@view
func previewMint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(shares: Uint256) -> (assets: Uint256):
    return ERC4626_previewMint(shares)
end

@view
func previewWithdraw{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(assets: Uint256) -> (shares: Uint256):
    return ERC4626_previewWithdraw(assets)
end

@view
func previewRedeem{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(shares: Uint256) -> (assets: Uint256):
    return ERC4626_previewRedeem(shares)
end

#############################################
##           HOOKS TO OVERRIDE             ##
#############################################

func totalAssets() -> (totalAssets: Uint256):
    return (Uint256(0, 0))
end

func beforeWithdraw(assets: Uint256, shares: Uint256):
    return ()
end

func afterDeposit(assets: Uint256, shares: Uint256):
    return ()
end

#############################################
##                 ERC20                    #
#############################################

# Don't forget to add your favorite ERC20 implementation here.
