// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

// library for string comparisons
library String {
      function compare(string memory a, string memory b) public pure  returns (bool) {
        return (sha256(abi.encodePacked((a))) == sha256(abi.encodePacked((b))));
    }
}
