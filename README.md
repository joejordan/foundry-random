# Foundry Random [![Open in Gitpod][gitpod-badge]][gitpod] [![Github Actions][gha-badge]][gha] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

[gitpod]: https://gitpod.io/#https://github.com/joejordan/foundry-random
[gitpod-badge]: https://img.shields.io/badge/Gitpod-Open%20in%20Gitpod-FFB45B?logo=gitpod
[gha]: https://github.com/joejordan/foundry-random/actions
[gha-badge]: https://github.com/joejordan/foundry-random/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

***Generate reliably random numbers using Foundry's FFI cheat code.***

More than once now I have needed a reliably random number generator while using Foundry. Unfortunately, as of this writing, there is no `vm.random()` cheatcode included with this otherwise excellent development tool.

This project fills that gap by utilizing the FFI cheatcode to launch `cast wallet new`, a tool included with Foundry to quickly generate a new random keypair, and returning the generated private key as a `bytes32` value to the user. We have also included a few additional creature comforts via the inclusion of several plug-and-play random number generator functions to make life easier.

### Example Use Case

The original use case I had for this was seeding a smart contract deploy script with random attribute values that would remain constant for the life of the contract. Similar seeding functionality could also be useful for certain types of tests.

## Installation

### Foundry

First, run the install step:

```sh
forge install --no-commit joejordan/foundry-random
```

Then, add this to your `remappings.txt` file:

```text
foundry-random=lib/foundry-random/src/
```

## Usage

Import the library into your Solidity contract, i.e.

```solidity
import { FoundryRandom } from "foundry-random/FoundryRandom.sol";
```

The cleanest usage is probably to include it as an inherited contract on your Foundry Test or Script contract, as follows:


```solidity
contract FoundryRandomTest is PRBTest, FoundryRandom {

   function setUp() public {
      // solhint-disable-previous-line no-empty-blocks
   }

   function testRandomNumber() public {
      uint256 randomNum;
      
      // generate a random number between 0 and 255
      randomNum = randomNumber(type(uint8).max);
      assertLte(randomNum, type(uint8).max);

      // generate a random number between 10 and 100
      randomNum = randomNumber(10, 100);
      assertGte(randomNum, 10);
      assertLte(randomNum, 100);
   }
}

```

Check out the [tests](https://github.com/joejordan/foundry-random/blob/main/test/FoundryRandom.t.sol) for more usage examples.

## Contribute

Contributions are welcome! [Open](https://github.com/joejordan/foundry-random/issues/new) an issue or submit a PR. There is always room for improvement. The instructions below will walk you through setting up for contributions.

### Pre-Requisites

You will need the following software on your machine:

- [Git](https://git-scm.com/downloads)
- [Foundry](https://github.com/foundry-rs/foundry)
- [Node.js](https://nodejs.org/en/download/)
- [Yarn](https://yarnpkg.com/)

### Set Up

Clone this repository:

```bash
$ git clone https://github.com/joejordan/foundry-random.git
```

Then, inside the project's directory, run this to install dependencies:

```bash
$ yarn install
```

Your environment should now be ready for your improvements.

## Security

This code has not been professionally audited by any third parties. If you include this codebase or parts of it in a professional audit, please let me know via [Twitter Direct Message](https://twitter.com/JJordan) for inclusion in this documentation.

If you discover any security issues with this codebase, please report them via [Twitter Direct Message](https://twitter.com/JJordan).

### Disclaimer

This is experimental software and is provided on an "as is" basis. No expressed or implied warranties are granted of any kind. I will not be liable for any loss, direct or indirect, related to the use or misuse of this codebase.

## Acknowledgements

- [Gonçalo Sá](https://twitter.com/GNSPS) for his fantastic [solidity-bytes-utils](https://github.com/GNSPS/solidity-bytes-utils) library.
- All of the contributors to the [Foundry toolkit](https://github.com/foundry-rs/foundry) for bringing Solidity development to the next level.

## License

foundry-random is released under the [MIT License](./LICENSE.md).
