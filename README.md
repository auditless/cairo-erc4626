# ERC4626 Vault Implementation

In progress Cairo 1.0 version.

## :warning: WARNING! :warning:

This code is entirely experimental, changing frequently and un-audited. Please do not use it in production!

## Dependencies

- Rust
- [Scarb](https://github.com/software-mansion/scarb)

## Installation

Use this locally as a scarb package. You can clone the repository
next to your project directory and add the following line in your
`Scarb.toml` config:

```toml
[dependencies]
cairo_erc4626 = { path = "../cairo_erc4626" }
```

## Contribution guide

First install the Cairo lang test runner globally:

```bash
make install
```

This will install the `cairo-test` binary.
Next, build the code and run the tests:

```bash
make build
make test
```

## Thanks to

- t11s and solmate contributors for the [solmate](https://github.com/Rari-Capital/solmate) ERC4626 implementation and math
- Quaireaux team for inspiration setting up Cairo 1.0 [quaireaux](https://github.com/keep-starknet-strange/quaireaux)
