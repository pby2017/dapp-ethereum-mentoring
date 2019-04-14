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

    uint public INIT_TOKEN_VALUE = 100;

    // 멘토링 struct
    struct MentStruct{
        uint fee;
        uint timestamp;
        bool isValid;
    }

    MentSupplyToken tokenContract = new MentSupplyToken();

    // mentoring (fee, timestamp, isValid) 관리
    mapping(uint=>MentStruct) public ments;
    // 유저 네임 관리
    mapping(address=>string) public usersName;
    // 초기 토큰 지급 여부 관리
    mapping(address=>bool) public receivedInitToken;
    // mentoring (date, place, subject, content, mentor, mentee) 관리
    mapping(uint=>string) public mentoringDate;
    mapping(uint=>string) public mentoringPlace;
    mapping(uint=>string) public mentoringSubject;
    mapping(uint=>string) public mentoringContent;
    mapping(uint=>address) public mentorAddress;
    mapping(uint=>address) public menteeAddress;
    // mentoring 개수 관리
    uint public countOfMents;
    // 초기 토큰 지급, mentoring 등록, mentoring 저장 이벤트 관리
    event InitTokenResponded(address _address);
    event RegisterMentoring(address _address);
    event SaveMentoring(address _address);
    
    constructor() public {
    }
    
    function registerMentoring(address _mentorAddress, address _menteeAddress, uint _fee, string memory _mentoringSubject) public {
        // mentoring 개수 증가
        countOfMents = countOfMents.add(1);
        // mentoring(fee, timestamp, isValid) struct 생성
        ments[countOfMents] = MentStruct(_fee, now, true);
        // mentoring(subject, mentor, mentee) 저장
        mentoringSubject[countOfMents] = _mentoringSubject;
        mentorAddress[countOfMents] = _mentorAddress;
        menteeAddress[countOfMents] = _menteeAddress;
        // mentoring 등록 완료 이벤트
        emit RegisterMentoring(msg.sender);
    }
    
    // id, deposit, timestamp, date, place, subject, content, mentor, mentee, valid
    function saveMentoring(uint _id, string memory _date, string memory _place, string memory _content) public {
        // mentee의 토큰 여분 체크
        require(tokenContract.balanceOf(menteeAddress[_id]) >= ments[_id].fee);
        // mentee가 mentor에게 토큰 지급
        tokenContract.transfer(menteeAddress[_id], mentorAddress[_id], ments[_id].fee);
        // mentoring 등록 후 나머지 미입력 정보 (date, place, content) 저장
        mentoringDate[_id] = _date;
        mentoringPlace[_id] = _place;
        mentoringContent[_id] = _content;
        // mentoring 유효 해제
        ments[_id].isValid = false;
        // mentoring 저장 완료 이벤트
        emit SaveMentoring(msg.sender);
    }
    
    function requestInitToken() public {
        // 시작 토큰 전송
        tokenContract.transfer(msg.sender, INIT_TOKEN_VALUE);
        // 이미 시작 토큰 받았다고 표시
        receivedInitToken[msg.sender] = true;
        // event 호출
        emit InitTokenResponded(msg.sender);
    }
    
    function isReceivedInitToken() public view returns (bool) {
        // 이미 시작 토큰을 받았는지 체크
        return receivedInitToken[msg.sender];
    }
    
    function isValidMentoring(uint _id) public view returns (bool) {
        // mentoring 유효 여부 체크
        return ments[_id].isValid;
    }
    
    function setUserName(address _address, string memory _name) public {
        // user 네임 저장
        usersName[_address] = _name;
    }
    
    function getUserName(address _address) public view returns (string memory){
        // user 네임 반환
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
        // mentoring 개수 반환
        return countOfMents;
    }
    
    function getMent(uint _id) public view returns(
        uint, uint, uint, string memory, string memory, string memory, string memory, address, address, bool){
        // stack deep 문제 대처
        uint id = _id;
        // 멘토링 관리 목록에 보여줄 내용 반환
        // mentoring id, fee, timestamp, 
        // date, place, subject, content, 
        // mentor, mentee, valid
        return (
            id,
            ments[id].fee,
            ments[id].timestamp,
            mentoringDate[id],
            mentoringPlace[id],
            mentoringSubject[id],
            mentoringContent[id],
            mentorAddress[id],
            menteeAddress[id],
            ments[id].isValid);
    }
}