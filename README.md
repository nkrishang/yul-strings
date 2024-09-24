# How strings work in Solidity.

`src/StringStore.sol` illustrates how strings are written to and read from smart contract storage, using inline asssembly.
`src/StringStoreReference.sol` contains the reference written in very simple Solidity.

The inline assembly implementation does save gas compared to vanilla Solidity (see `test/StringStore.t.sol`)
Implementation | getName | setName |
--- | --- | --- |
Inline assembly | 14,908 | 21,023 |
Vanilla Solidity | 15,645 | 21,734 |

If you know of an even more optimized implementation of `StringStore`, please make a PR. I'd love to learn.

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```
