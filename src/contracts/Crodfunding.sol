// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Crowdfunding {
    mapping(address => uint) public Contributors;
    address public manager;
    uint public minContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public numOfcontributors;

    constructor(uint _target, uint _deadline) {
        target = _target;
        deadline = block.timestamp + _deadline;
        minContribution = 100 wei;
        manager = msg.sender;
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "the deadline has been passed");
        require(
            msg.value >= minContribution,
            "the minimum contribution of 100 wei is not met"
        );

        if (Contributors[msg.sender] == 0) {
            numOfcontributors++;
        }
        Contributors[msg.sender] = msg.value;
        raisedAmount += msg.value;
    }

    function balance() public view returns (uint) {
        return address(this).balance;
    }
}
