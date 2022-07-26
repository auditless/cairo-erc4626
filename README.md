# ERC4626 Vault Implementation

- `dependencies.erc4626`: contracts
- `openzeppelin`: OpenZeppelin `cairo-contracts` dependencies
- `tests`: pytest tests folder

## :warning: WARNING! :warning:

This code is entirely experimental, changing frequently and un-audited. Please do not use it in production!

## Features

- This code preserves the original `solmate` license
- Bring your own ERC20 token implementation (or use `openzeppelin` as seen in the mock contract)

## Reusability

How to reuse this code:
- Copy the `dependencies/erc4626` folder to your repository
- Copy the `openzeppelin` folder from the latest openzeppelin `cairo-contracts` implementation
- Copy the `ERC4626.cairo` contract into your own implementation
- Use your favorite ERC20 implementation with the contract
- Fill in the hook functions

Or feel free to get in touch with us on [Twitter](http://www.twitter.com/yagi_fi).

## How to contribute

Dependencies:

- `poetry` (Python package manager)
- Basic cairo system dependencies (see [Setting up the environment](https://www.cairo-lang.org/docs/quickstart.html))

Installation:

```
poetry install
```

## Thanks to

- t11s and solmate contributors for the [solmate](https://github.com/Rari-Capital/solmate) ERC4626 implementation and math
- OpenZeppelin team for the excellent [cairo-contracts](https://github.com/OpenZeppelin/cairo-contracts)
- Zorro team for the testing patterns in [zorro](https://github.com/zorro-project/zorro)

## Related

- Please check out Milan Cermak's repository which is also porting the solmate implementation [cairo-4626](https://github.com/milancermak/cairo-4626)
