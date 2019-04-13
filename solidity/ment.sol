pragma solidity ^0.5.0;

// ----------------------------------------------------------------------------
// 'FIXED' 'Example Fixed Supply Token' token contract
//
// Symbol      : FIXED
// Name        : Example Fixed Supply Token
// Total supply: 1,000,000.000000000000000000
// Decimals    : 18
//
// Enjoy.
//
// (c) BokkyPooBah / Bok Consulting Pty Ltd 2018. The MIT Licence.
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and a
// fixed supply
// ----------------------------------------------------------------------------
contract MentSupplyToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "MENT";
        name = "Ment Supply Token";
        decimals = 18;
        _totalSupply = 1000000 * 10**uint(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    function transfer(address _from, address to, uint tokens) public returns (bool success) {
        balances[_from] = balances[_from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(_from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () external payable {
        revert();
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
    function getOwner() public view returns (address){
        return owner;
    }
}

contract MentContract is Owned{
    using SafeMath for uint;

    // 멘토링 struct
    struct MentStruct{
        uint id;
        uint timestamp;
        string mentoringDate;
        string mentoringPlace;
        string mentoringSubject;
        string mentoringContent;
        address mentorAddress;
        address menteeAddress;
        bool isValid;
    }

    MentSupplyToken tokenContract = new MentSupplyToken();

    // 멘토링들
    MentStruct[] public ments;

    // address와 name 매핑
    mapping(address=>string) public usersName;
    
    // 토큰 지급 받았는지 여부, deposit 1회 했는지 여부, 개인 deposit 저장, 출결 상태 저장
    mapping(address=>bool) public receivedInitToken;
    // mapping(address=>bool) public hasDeposited;
    // mapping(address=>uint) public eachDeposits;
    // mapping(address=>uint8) public kindOfAttend;

    // 초기 토큰 지급량
    uint public INIT_TOKEN_VALUE = 100;

    // 전체 deposit 량 저장, 출결 시스템이 유효한지 여부
    // uint public allDeposit;
    // bool public mentValid;

    // 토큰 지급되면 호출, 출결 시스템 저장되면 호출, 종료되면 호출
    event InitTokenResponded(address _address);
    event RegisterMentoring(address _address);
    // event SetKindOfAttend(address _address);
    // event EndedMent(address _address);

    constructor() public {
        // mentValid = true;
        ments.push(MentStruct(ments.length, now, "", "", "", "", address(0), address(0), false));
    }
    
    // function deposit(uint _deposit, address _address) public {
    //     // deposit 여부 체크
    //     require(!hasDeposited[_address]);
    //     // 토큰량 체크
    //     require(tokenContract.balanceOf(_address) >= _deposit);
    //     // 토큰 전송
    //     tokenContract.transfer(_address, tokenContract.getOwner(), _deposit);
    //     // deposit 토큰 추가
    //     allDeposit = allDeposit.add(_deposit);
    //     // 개인 deposit 추가
    //     eachDeposits[_address] = _deposit;
    //     // deposit 상태 변경
    //     hasDeposited[_address] = true;
    // }
    function registerMentoring(address _mentorAddress, address _menteeAddress, string memory mentoringSubject) public {
        ments.push(MentStruct(ments.length, now, "", "", mentoringSubject, "", _mentorAddress, _menteeAddress, false));
        emit RegisterMentoring(msg.sender);
    }
    // function setKindOfAttend(uint8 _kindOfAttend, address _address) public {
    //     // 상태 변경 0: absent, 1: late, 2: attend 
    //     kindOfAttend[_address] = _kindOfAttend;
    //     emit SetKindOfAttend(msg.sender);
    // }    
    // function endMent(address[] memory _addresses) public {
    //     require(mentValid);
    //     mentValid = false;
    //     uint addressesLength = _addresses.length;
    //     uint amountOfWithdraw = 0;
    //     uint countOfAttend = 0;
    //     for(uint i=0; i<addressesLength; i++){
    //         // 출석자 돌려줌
    //         // 지각자 돌려줌
    //         if(kindOfAttend[_addresses[i]] == 2){
    //             amountOfWithdraw = eachDeposits[_addresses[i]];
    //             require(tokenContract.balanceOf(tokenContract.getOwner()) >= amountOfWithdraw);
    //             tokenContract.transfer(tokenContract.getOwner(), _addresses[i], amountOfWithdraw);
    //             countOfAttend = countOfAttend.add(1);
    //         } else if(kindOfAttend[_addresses[i]] == 1){
    //             amountOfWithdraw = eachDeposits[_addresses[i]].div(2);
    //             require(tokenContract.balanceOf(tokenContract.getOwner()) >= amountOfWithdraw);
    //             tokenContract.transfer(tokenContract.getOwner(), _addresses[i], amountOfWithdraw);
    //             kindOfAttend[_addresses[i]] = 0;
    //             hasDeposited[_addresses[i]] = false;
    //         } else {
    //             amountOfWithdraw = 0;
    //             hasDeposited[_addresses[i]] = false;
    //         }
    //         allDeposit = allDeposit.sub(amountOfWithdraw);
    //         eachDeposits[_addresses[i]] = 0;
    //     }
    //     // 출석자 보상해줌
    //     uint rewardFromRemainedDeposit = allDeposit.div(countOfAttend);
    //     for(uint i=0; i<addressesLength; i++){
    //         if(kindOfAttend[_addresses[i]] == 2){
    //             require(tokenContract.balanceOf(tokenContract.getOwner()) >= rewardFromRemainedDeposit);
    //             tokenContract.transfer(tokenContract.getOwner(), _addresses[i], rewardFromRemainedDeposit);
    //             allDeposit = allDeposit.sub(rewardFromRemainedDeposit);
    //             kindOfAttend[_addresses[i]] = 0;
    //             hasDeposited[_addresses[i]] = false;
    //         }
    //     }
    //     emit EndedMent(msg.sender);
    // }

    function requestInitToken() public {
        // 시작 토큰 전송
        tokenContract.transfer(msg.sender, INIT_TOKEN_VALUE);
        // 이미 시작 토큰 받았다고 표시
        receivedInitToken[msg.sender] = true;
        // event 호출
        emit InitTokenResponded(msg.sender);
    }

    // function isMentValid() public view returns (bool){
    //     // 유효한 출결 시스템인지 체크
    //     return mentValid;
    // }

    function isReceivedInitToken() public view returns (bool) {
        // 이미 시작 토큰을 받았는지 체크
        return receivedInitToken[msg.sender];
    }
    
    function setUserName(address _address, string memory _name) public {
        usersName[_address] = _name;
    }
    
    function getUserName(address _address) public view returns (string memory){
        return usersName[_address];
    }

    function getInitTokenValue() public view returns (uint) {
        // 초기 지급 토큰량 반환
        return INIT_TOKEN_VALUE;
    }
    
    function getTokenContractOwner() public view returns (address) {
        // 토큰 시스템 주소 반환
        return tokenContract.getOwner();
    }

    function getBalance(address _address) public view returns (uint){
        // 토큰 보유량 반환
        return tokenContract.balanceOf(_address);
    }
    
    function getCountOfMents() public view returns (uint) {
        return ments.length;
    }

    function getMent(uint _id) public view returns(
        uint, uint, string memory, string memory, string memory, string memory, address, address, bool){
        MentStruct memory mentStruct = ments[_id];
        // 멘토링 관리 목록에 보여줄 내용 반환
        return (
            mentStruct.id,
            mentStruct.timestamp,
            mentStruct.mentoringDate,
            mentStruct.mentoringPlace,
            mentStruct.mentoringSubject,
            mentStruct.mentoringContent,
            mentStruct.mentorAddress,
            mentStruct.menteeAddress,
            mentStruct.isValid);
    }
}
