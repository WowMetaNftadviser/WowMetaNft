// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;
import './SafeMath.sol';
import './IERC20.sol';
import './ERC20.sol';
import './Context.sol';
import './Ownable.sol';


contract WOW  is ERC20("WOW-token", "WOW"), Ownable{
    using SafeMath for uint256;
    uint256 public constant tokenMaxNum =  10**18 *10000000000; //max limit

    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public burnRate =  200;
    uint256 public constant burnRateMax = 10000;
    uint256 public constant burnRateUL = 1000;

    mapping(address => bool) public whitelist;

    event WhitelistUpdate(address indexed _address, bool statusBefore, bool status);
    event BurnRateUpdate(uint256 burnRateBefore,uint256 burnRate);

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {

        uint256 tokentotalSupply =   totalSupply();
        if(tokentotalSupply>=tokenMaxNum)
        {
            return false;
        }

        if(tokentotalSupply.add(_amount)>tokenMaxNum && tokentotalSupply<tokenMaxNum)
        {
            _amount = tokenMaxNum.sub(tokentotalSupply);
        }

        uint256 balanceBefore = balanceOf(_to);

        _mint(_to, _amount);
        uint256 balanceAfter = balanceOf(_to);
        return balanceAfter >= balanceBefore;

    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {

        if (whitelist[sender] || whitelist[recipient])
         {
            super._transfer(sender, recipient,amount);
            return;
         }

        uint256  burnAmt = amount.mul(burnRate).div(burnRateMax);

        amount = amount.sub(burnAmt);

        super._transfer(sender, recipient, amount);
        if(burnAmt>0)
        {
            super._transfer(sender, burnAddress, burnAmt);
         }

    }

    function setburnRate(uint256 _burnRate) external onlyOwner{

        require(_burnRate <= burnRateUL, "too high");
        uint256 burnRateBefore = burnRate;
        burnRate = _burnRate;
        emit BurnRateUpdate(burnRateBefore,burnRate);
    }

    function setWhitelist(address _address,bool status) external onlyOwner{

        bool statusBefore = whitelist[_address];
        whitelist[_address] = status;
        emit WhitelistUpdate(_address,statusBefore, status);
    }

}
