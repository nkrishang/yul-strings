// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {StringStore} from "../src/StringStore.sol";

contract StringStoreTest is Test {
    StringStore public store;

    function setUp() public {
        store = new StringStore();
        store.setName("Trying to check the savings from storing and reading strings using inline assembly");
    }

    function test_fuzz(string memory x) public {
        store.setName(x);

        string memory name = store.getName();
        assertEq(name, x);
    }
    
    // StringStore (inline-assembly): 14,908 gas
    // StringStoreReference:          15,645 gas
    function test_benchmark_getName() public view {
        store.getName();
    }

    // StringStore (inline-assembly): 21,203 gas
    // StringStoreReference:          21,734 gas
    function test_benchmark_setName() public {
        store.setName("WhatAboutARidiculouslyLargeNameLike....Tom");
    }
}
