// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract BatchTransfer is Ownable{

    event BatchSent(address token, uint256 total);

    using SafeMath for uint256;

    uint256 private _arrayLimit = 200;

    function batchTransfer(address[] memory addrArr, uint256[] memory amountArr) public payable {
        require(addrArr.length > 0,"array's length must more than 0");
        require(addrArr.length <= _arrayLimit,"array's length must less than _arrayLimit");
        require(addrArr.length == amountArr.length,"wrong length");

        for (uint256 i = 0;i < addrArr.length; i++) {
            payable(addrArr[i]).transfer(amountArr[i]);
        }

        emit BatchSent(0x000000000000000000000000000000000000bEEF,msg.value);
    }


    function batchTransferToken(address payable[] memory addrArr, 
         uint256[] memory amountArr,
         address _token
        ) external {
        require(addrArr.length <= _arrayLimit,"array's length must less than _arrayLimit");
        IERC20 token = IERC20(address(_token));

        require(addrArr.length == amountArr.length, "Amount of addresses or transfer values are wrong");
        uint256 totalAmount = sum(amountArr);
        require(token.allowance(msg.sender, address(this)) >= totalAmount, "Allowance is less than amounts to transfer");

        //Initialize token and transfer
        for (uint i=0; i < addrArr.length; i++) {
           token.transferFrom(msg.sender,addrArr[i],amountArr[i]);
        }

        emit BatchSent(_token,totalAmount);
   
    } 

    function sum(uint256[] memory amountArr) internal pure returns(uint256 totalAmount){
        totalAmount = 0;

        for (uint i=0; i < amountArr.length; i++) {
            totalAmount += amountArr[i];
        }
    }

    function getArrayLimit() external view returns(uint256) {
        return _arrayLimit;
    }

    function setArrayLimit(uint256 arrayLimit) external onlyOwner {
        require(arrayLimit > 0,"arrayLimit can't less than 1");
        _arrayLimit = arrayLimit;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Withdrawable amount is 0");
        payable(msg.sender).transfer(balance);
    }

}
