pragma solidity ^0.4.0;

contract Game{

	struct Option {
		uint totalGet;
		BetInfo[] betInfo;
	}

	struct BetInfo {
		address betAddress;
		uint amount;
	}

	Option[2] public options;
	uint public bettingTime;
	uint public totoalReward;
	uint winner;

	enum State {Create, Betting, GettingResult, Dispatch, End}
	State state;

	modifier onlyAt(State _state){
		if(state != _state) throw;
		_;
	}

	// Stage 0: Create
	// Initialize
	function Game(uint _betTimePeriodInMinutes) {
		bettingTime = now + _betTimePeriodInMinutes * 1 minutes;
		state = State.Betting;
	}

	// Stage 1: Betting
	function bet(uint _option) payable onlyAt(State.Betting){
		if(_option >= options.length) throw;
		options[_option].betInfo.push(BetInfo(msg.sender, msg.value));
		options[_option].totalGet += msg.value;
		totoalReward += msg.value;
		if(now > bettingTime) state = State.GettingResult;
	}

	// Stage 2: Getting Result
	function getResult() onlyAt(State.GettingResult){
		winner = 1;
		state = State.Dispatch;
	}

	// Stage 3: Dispatch the reward
	function dispatch() onlyAt(State.Dispatch){
		if(winner >= options.length) throw;

		for(var i = 0; i < options[winner].betInfo.length; i++){
			var receiver = options[winner].betInfo[i].betAddress;
			var value = totoalReward * options[winner].betInfo[i].amount / options[winner].totalGet;
			if(!receiver.send(value)) throw;
		}
		state = State.End;
	}

	// helper function 
	function showBetInfosForA(uint _index) constant returns(address _address, uint _amount){
		_address = options[0].betInfo[_index].betAddress;
		_amount = options[0].betInfo[_index].amount;
	}

	function showWinner() constant returns(string _return){
		if(state <= State.GettingResult) _return = "no result";
		else if(winner == 0) _return = "winner is option A,";
		else if(winner == 1) _return = "winner is option B.";
		else throw;
	}

	function showState() constant returns(string _return){
		if(state == State.Create) _return = "Create";
		else if(state == State.Betting) _return = "Betting";
		else if(state == State.GettingResult) _return = "Getting result";
		else if(state == State.Dispatch) _return = "Dispatch";
		else if(state == State.End) _return = "End";
		else throw;
	}
}