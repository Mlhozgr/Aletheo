pragma solidity >=0.7.0 <0.8.0;

import "./I.sol";

contract FoundingEvent {
	mapping(address => uint) public contributions;
	address payable private _deployer;
	bool private _lgeOngoing;
	address private _staking;
	bool private _notInit;

	constructor() {_deployer = msg.sender;_notInit = true;_lgeOngoing = true;}
	function init(address c) public {require(msg.sender == _deployer && _notInit == true);delete _notInit; _staking = c;}

	function depositEth() external payable {
		require(_lgeOngoing == true);
		uint amount = msg.value;
		uint deployerShare = amount/200; amount -= deployerShare; _deployer.transfer(deployerShare);
		contributions[msg.sender] += amount;
		if (block.number >= 12638999) {_createLiquidity();}
	}

	function _createLiquidity() internal {
		address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
		address token = 0xdff92dCc99150Df99D54BC3291bD7e5522bB1Edd;// hardcoded token address after erc20 will be deployed
		address staking = _staking;
		address factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
		address tknETHLP = I(factory).getPair(token,WETH);
		if (tknETHLP == address(0)) {tknETHLP=I(factory).createPair(token, WETH);}
		uint ETHDeposited = address(this).balance;
		I(WETH).deposit{value: ETHDeposited}();
		I(token).transfer(tknETHLP, 1e24);
		I(WETH).transfer(tknETHLP, ETHDeposited);
		I(tknETHLP).mint(staking);
		I(staking).init(ETHDeposited, tknETHLP);
		delete _staking; delete _lgeOngoing; delete _deployer;
	}
}
