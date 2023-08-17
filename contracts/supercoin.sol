// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SuperToken is ERC20{

    struct TokenData{
        uint256 amount;
        uint256 createAt;
        uint256 expiryDate;
        address from;
    }

    struct UserData{
        uint256 totalTokens;
        TokenData[] tokenDetails;
    }

    struct UserHistory{
        uint256 totalEarning;
        TokenData[] earningHistory;
    }

    mapping (address=>UserData) private tokenBalance;

    mapping (address=>UserHistory) private tokenHistory;

    uint constant expiryTime=300;

    uint totalTokensIssued=0;

    address private _owner;

    constructor() ERC20("SuperCoin","SPC"){
        _owner=msg.sender;
    }

    function mint(address to,uint256 amount) external  onlyOwner {
        TokenData memory newTokens= TokenData(amount,block.timestamp,block.timestamp+expiryTime,_owner);

        _mint(to, amount);
        tokenBalance[to].totalTokens+=newTokens.amount;
        tokenHistory[to].totalEarning+=newTokens.amount;
        tokenBalance[to].tokenDetails.push(newTokens);
        tokenHistory[to].earningHistory.push(newTokens);
        totalTokensIssued+=amount;

    }


    function transferFrom(address from, address to, uint256 amount) public override returns(bool){

        require(tokenBalance[from].totalTokens>=amount,"Not Enough tokens!");
        TokenData memory newTokens= TokenData(amount,block.timestamp,block.timestamp+expiryTime,from);
        tokenBalance[from].totalTokens-=amount;
        tokenBalance[to].totalTokens+=amount;
        tokenHistory[to].totalEarning+=newTokens.amount;
        tokenHistory[to].earningHistory.push(newTokens);
        uint256 transact = amount;
        for(uint256 i=0;i<tokenBalance[from].tokenDetails.length && amount>0;i++){
            if(tokenBalance[from].tokenDetails[i].amount>0){
                if(tokenBalance[from].tokenDetails[i].amount>=amount){
                    tokenBalance[from].tokenDetails[i].amount-=amount;
                    amount=0;
                    break;
                }
                else{
                    amount-=tokenBalance[from].tokenDetails[i].amount;
                    tokenBalance[from].tokenDetails[i].amount=0;
                }
            }
        }

        _transfer(from, to, transact);

        return true;
    }


    function expireTokens(address user) public{
        uint expiredTokens=0;
        for(uint i=0;i<tokenBalance[user].tokenDetails.length;i++){
            if(tokenBalance[user].tokenDetails[i].expiryDate<block.timestamp && tokenBalance[user].tokenDetails[i].amount>0){
                expiredTokens+=tokenBalance[user].tokenDetails[i].amount;
                tokenBalance[user].tokenDetails[i].amount=0;
            }
        }
        _burn(user, expiredTokens);
        tokenBalance[user].totalTokens-=expiredTokens;
        totalTokensIssued-=expiredTokens;
    }

    function viewTokens(address user) public view returns(uint256){
        return tokenBalance[user].totalTokens;
    }

    function earningHistory(address user) public view returns(UserHistory memory){
        return tokenHistory[user];
    }

    function totalSupply() public override view returns(uint256){
        return totalTokensIssued;
    }

    modifier onlyOwner(){
        require(msg.sender==_owner, "Not Authorized!");
        _;
    }
}

