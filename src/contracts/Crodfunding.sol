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

    struct Request {
        string description;
        address payable recipient;
        uint value;
        bool isCompleted;
        uint numOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint => Request) public requests;
    uint public numRequest;

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

    function refund() public {
        require(
            block.timestamp > deadline,
            "the funding phase is not finished"
        );
        require(
            raisedAmount < target,
            "the raised amount has not reached the target amount"
        );

        address payable user = payable(msg.sender);
        user.transfer(Contributors[msg.sender]);
        Contributors[msg.sender] = 0;
    }

    modifier onlyManager() {
        require(
            msg.sender == manager,
            "only the manager can call this function"
        );
        _;
    }

    function createRequest(
        string memory _desc,
        address payable _recipient,
        uint _value
    ) public onlyManager {
        Request storage newRequest = requests[numRequest];
        numRequest++;
        newRequest.description = _desc;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.isCompleted = false;
        newRequest.numOfVoters = 0;
    }

    function voteRequest(uint _requestNo) public {
        require(Contributors[msg.sender] > 0, "only contributors can vote");

        Request storage req = requests[_requestNo];
        require(req.voters[msg.sender] == false, "you're already voted");
        req.voters[msg.sender] = true;
        req.numOfVoters++;
    }

    function pay(uint _requestNo) public onlyManager {
        require(raisedAmount >= target);
        Request storage req = requests[_requestNo];
        require(req.isCompleted == false, "the funds have already been paid");
        require(
            req.numOfVoters > numOfcontributors / 2,
            "not enough contributors backing this project"
        );
        req.recipient.transfer(req.value);
        req.isCompleted = true;
    }
}
