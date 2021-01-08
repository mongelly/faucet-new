pragma solidity ^0.4.24;

import "./builtin.sol";

contract Faucet {
    
    using Builtin for Faucet;
    Extension extension = Builtin.getExtension();
    
    address delegator;
    uint256 defaultVETAmount;
    uint256 defaultVTHOAmount;
    
    constructor() public {
        defaultVETAmount = 100  * 1000000000000000000;
        defaultVTHOAmount = 5000 * 1000000000000000000;
    }
    
    function setDefaultAmount(uint256 _vetamount,uint256 _vthoamount) public isMaster{
        defaultVETAmount = _vetamount * 1000000000000000000;
        defaultVTHOAmount = _vthoamount * 1000000000000000000;
        emit DefaultAmountChanged(_vetamount,_vthoamount);
    }
    
    function getDefaultAmount() public view returns(uint256,uint256){
        return (defaultVETAmount,defaultVTHOAmount);
    }
    
    
    function replaceMaster(address _new) public isMaster{
       this.$setMaster(_new);
    }
    
    function getMaster() public view returns(address) {
        return this.$master();
    }
    
    function setDelegator(address _delegator) public isMaster{
        delegator = _delegator;
        emit DelegatorChanged(delegator);
    }
    
    function getDelegator() public view returns(address){
        return delegator;
    }
    
    function deposit() public payable{}
    
    function claim() public validDelegator{
        require((defaultVETAmount <= address(this).balance && defaultVTHOAmount <= this.$energy()),"insufficient balance");
        address(msg.sender).transfer(defaultVETAmount);
        this.$moveEnergyTo(msg.sender,defaultVTHOAmount);
    }
    
    function withdraw(address _receiver) public isMaster{
        address(_receiver).transfer(address(this).balance);
        this.$moveEnergyTo(_receiver,this.$energy());
    }
    
    event DelegatorChanged(address indexed _delegator);
    event DefaultAmountChanged(uint256 indexed _vet,uint256 indexed _vtho);
    
    modifier isMaster(){
        require(msg.sender == this.$master(),"permission denied");
        _;
    }
    
    modifier validDelegator(){
        require(extension.txGasPayer() == delegator,"invalid delegator");
        _;
    }
}