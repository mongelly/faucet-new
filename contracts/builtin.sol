pragma solidity ^0.4.24;

import "./prototype.sol";
import "./energy.sol";
import "./extension.sol";

/**
 * @title Builtin
 * @dev The VeChainThor builtin contracts are encapsulated in library Builtin.
 * It's very easy to use it for the developer, just need import it.
 */
library Builtin {

    /// @return the instance of the contract "Extension".
    function getExtension() internal pure returns(Extension) {
        return Extension(uint160(bytes9("Extension")));
    }

    Energy constant energy = Energy(uint160(bytes6("Energy")));

    /// @return amount of VeThor in account 'self'.
    function $energy(address self) internal view returns(uint256 amount){
        return energy.balanceOf(self);
    }

    /// @notice transfer 'amount' of VeThor from account 'self' to account 'to'.
    function $moveEnergyTo(address self, address to, uint256 amount) internal{
        energy.move(self, to, amount);
    }

    Prototype constant prototype = Prototype(uint160(bytes9("Prototype")));

    /// @return master address of self
    function $master(address self) internal view returns(address){
        return prototype.master(self);
    }

    /// @notice 'newMaster' will be set to contract 'self' and this function only works when msg sender is the old master.
    function $setMaster(address self, address newMaster) internal {
        prototype.setMaster(self, newMaster);
    }

    /// @return the amount of VET at blockNumber
    function $balance(address self, uint blockNumber) internal view returns(uint256){
        return prototype.balance(self, blockNumber);
    }

    /// @return the amount of energy at blockNumber
    function $energy(address self, uint blockNumber) internal view returns(uint256){
        return prototype.energy(self, blockNumber);
    }

    /// @notice 'self' check if address self is a contract account
    function $hasCode(address self) internal view returns(bool){
        return prototype.hasCode(self);
    }
}
