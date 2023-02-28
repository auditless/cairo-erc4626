<p align="center">
  <a href="https://github.com/auditless/cairo-erc4626/actions/workflows/test.yaml">
    <img src="https://github.com/auditless/cairo-erc4626/actions/workflows/test.yaml/badge.svg?event=push" alt="CI Badge"/>
  </a>
</p>

# ERC4626 Vault Implementation [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/auditless/cairo-erc4626/blob/main/LICENSE)

[Built with **`auditless/cairo-template`**](https://github.com/auditless/cairo-template)

In progress Cairo 1.0 version.

## :warning: WARNING! :warning:

This code is entirely experimental, changing frequently and un-audited. Please do not use it in production!

## Dependencies

- Rust
- [Scarb](https://github.com/software-mansion/scarb)

## Installation

Install this as a Scarb package by adding the following to your `Scarb.toml` config:

```toml
[dependencies]
cairo_erc4626 = { git = "https://github.com/auditless/cairo-erc4626.git" }
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

## License

[MIT](https://github.com/auditless/cairo-template/blob/main/LICENSE) © [Auditless Limited](https://www.auditless.com)
