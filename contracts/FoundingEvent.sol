pragma solidity >=0.7.0 <0.8.0;

// Author: Sam Porter
// With LGE it's now possible to create fairer distribution and fund promising projects without VC vultures at all.
// Non-upgradeable, not owned, liquidity is being created automatically on first transaction after last block of LGE.
// Founders' liquidity is not locked, instead an incentive to keep it is introduced.
// The Event lasts for ~2 months to ensure fair distribution.
// 0,5% of contributed Eth goes to developer for earliest development expenses including audits and bug bounties.
// Blockchain needs no VCs, no authorities.

import "./I.sol";

contract FoundingEvent {
	mapping(address => uint) public contributions;
	address payable private _deployer;
	uint88 private _phase;
	bool private _lgeOngoing;
	uint private _ETHDeposited;

	constructor() {_deployer = msg.sender;_lgeOngoing = true;}

	function depositEth() external payable {
		require(_lgeOngoing == true);
		uint amount = msg.value;
		if (block.number >= 12550000) {uint phase = _phase; if(block.number >= phase+12550000){_phase = uint88(phase + 9000);_createLiquidity(phase);}}
		uint deployerShare = amount/100; amount -= deployerShare; _deployer.transfer(deployerShare);
		contributions[msg.sender] += amount;
	}

	function _createLiquidity(uint phase) internal {
		address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
		address token = 0x95A28A02Ffb969e48B78554777f223445661fB9f;
		address staking = 0xB0b3E52e432b80D3A37e15AB6BBF4673225e160f;
		address factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
		address tknETHLP = I(factory).getPair(token,WETH);
		if (tknETHLP == address(0)) {tknETHLP=I(factory).createPair(token, WETH);}
		_ETHDeposited += address(this).balance;
		uint ethToDeposit = address(this).balance;
		uint tokenToDeposit = 1e23;
		if (phase == 81000) {I(staking).init(_ETHDeposited, tknETHLP);delete _lgeOngoing; delete _ETHDeposited; delete _phase; delete _deployer;}
		I(WETH).deposit{value: ethToDeposit}();
		I(token).transfer(tknETHLP, tokenToDeposit);
		I(WETH).transfer(tknETHLP, ethToDeposit);
		I(tknETHLP).mint(staking);
	}
}
