// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract Stacking {
    using SafeMath for uint256;
    IERC20 public stakingToken;
    uint256 private _totalSupply;
    uint256 internal rewardPerTime;
    IERC20 internal BNB; //Native Token
    uint256 private bnbRPD; //per day reward of native token
    struct UserInfo {
        address uAddress;
        uint256 amount;
        uint256 timeOfEntrance;
        uint256 lastClaim;
    }
    mapping(address => UserInfo) _user;
    uint256 public rewards;

    constructor(address _stakingToken) {
        stakingToken = IERC20(_stakingToken);
    }

    function stack(uint256 _amount) public {
        _totalSupply += _amount;
        _user[msg.sender].amount += _amount;
        _user[msg.sender].timeOfEntrance = block.timestamp;
        _user[msg.sender].lastClaim = block.timestamp;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function calculate() public view returns (uint256) {
        uint256 time = block.timestamp - _user[msg.sender].lastClaim;
        uint256 cTime = time / 60;
        uint256 cValue = (_user[msg.sender].amount.mul(12)).div(100);
        uint256 vRation = cValue.div(1440);
        uint256 amount = vRation.mul(cTime);
        return amount;
    }

    function claimReward() external {
        uint256 reward = calculate();
        _user[msg.sender].lastClaim = block.timestamp;
        stakingToken.transfer(msg.sender, reward);
    }

    function withdraw(uint256 _amount) public {
        require(_amount <= _user[msg.sender].amount);
        _totalSupply -= _amount;
        _user[msg.sender].amount -= _amount;
        delete _user[msg.sender];
        stakingToken.transfer(msg.sender, _amount);
    }
}

