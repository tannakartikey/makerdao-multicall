// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

/// @title Multicall - Aggregate results from multiple read-only function calls
/// @author Michael Elliot <mike@makerdao.com>
/// @author Joshua Levine <joshua@makerdao.com>
/// @author Nick Johnson <arachnid@notdot.net>

contract Multicall {
    struct Call {
        address target;
        bytes callData;
    }

    function aggregate(Call[] memory calls) public returns (uint256 blockNumber, bytes[] memory) {
        uint blockNumber = block.number;
        // for(uint256 i = 0; i < calls.length; i++) {
        //     (bool success, bytes memory ret) = calls[i].target.call(calls[i].callData);
        //     require(success);
        //     returnData[i] = ret;
        // }
	assembly {
	    mstore(0x00, 0x20)
	    if iszero(0x80) { return(0x00, 0x40) }

	    let results

	    let n := mload(calls)
	    let end := add(add(calls, 0x20), shl(5, n))
	    let freeMemoryPointer := add(mload(0x40), 0x40)

	    for { let i := add(calls, 0x20) } iszero(eq(i, end)) { i := add(i, 0x20) } {
		let targetPointer := mload(i)
		let target := mload(targetPointer)

		let calldataSizePointer := mload(add(targetPointer, 0x20))
		let calldataSize := mload(calldataSizePointer)
		// let calldataPointer := add(calldataSizePointer, calldataSize)
		let calldataPointer := add(sub(32, calldataSize), add(calldataSizePointer, calldataSize))
		let calldata := mload(calldataPointer)

		mstore(results, calldata)
		let resultOfCall := call(gas(), target, 0, results, calldataSize, 0x00, 0x00)
		results := add(results, 0x20)

	    }

	  return (0x00, results)

	}
    }
    // Helper functions

    function getEthBalance(address addr) public view returns (uint256 balance) {
        balance = addr.balance;
    }

    function getBlockHash(uint256 blockNumber) public view returns (bytes32 blockHash) {
        blockHash = blockhash(blockNumber);
    }

    function getLastBlockHash() public view returns (bytes32 blockHash) {
        blockHash = blockhash(block.number - 1);
    }

    function getCurrentBlockTimestamp() public view returns (uint256 timestamp) {
        timestamp = block.timestamp;
    }

    function getCurrentBlockDifficulty() public view returns (uint256 difficulty) {
        difficulty = block.difficulty;
    }

    function getCurrentBlockGasLimit() public view returns (uint256 gaslimit) {
        gaslimit = block.gaslimit;
    }

    function getCurrentBlockCoinbase() public view returns (address coinbase) {
        coinbase = block.coinbase;
    }
}
