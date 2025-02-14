// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;
import "../common/Enum.sol";

/// @title Executor - A contract that can execute transactions
/// @author Richard Meissner - <richard@gnosis.pm>
contract Executor {
    function execute(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 txGas
    ) internal returns (bool success) {
        if (operation == Enum.Operation.DelegateCall) {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                success := delegatecall(txGas, to, add(data, 0x20), mload(data), 0, 0)
            }
        } else {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                success := call(txGas, to, value, add(data, 0x20), mload(data), 0, 0)
                if eq(success, 0){
                    let ptr := mload(0x40)
                    // reassign free space ptr
                    mstore(0x40, add(ptr, add(returndatasize(), 0x20)))
                    // data size
                    mstore(ptr, returndatasize())
                    // data
                    returndatacopy(add(ptr, 0x20), 0, returndatasize())
                    revert(ptr, add(returndatasize(), 0x20))
                }
            }
        }
    }
}
