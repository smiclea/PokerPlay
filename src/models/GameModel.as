package models
{
	import flash.events.EventDispatcher;
	
	import models.analyzers.FlopAnalyzer;
	import models.analyzers.HandAnalyzer;
	import models.analyzers.PreFlopAnalyzer;
	import models.analyzers.RiverAnalyzer;
	import models.analyzers.TurnAnalyzer;
	import models.constants.Actions;
	import models.constants.GamePhases;
	import models.events.GameEvent;
	import models.vo.ActionLogVO;
	import models.vo.PlayerVO;

	[Event(name="newGame", type="models.events.GameEvent")]
	
	[Bindable]
	public class GameModel extends EventDispatcher
	{
		static private var _instance :GameModel;
		
		public var players :Array; //of PlayerVP
		public var message :String = "Waiting...";
		
		public var gamePhase :String = GamePhases.PRE_FLOP;
		
		public var userCards :Array; // of CardVO
		public var tableCards :Array; // of CardVO
		
		private var dealerId :int;
		
		private var posPlayers :Array;
		private var currentPos :int;
		private var raisePos :int;
		
		private var i :int;
		private var player :PlayerVO;
		
		private var actionsLog :Array = [];
		
		public function GameModel()
		{
		}
		
		static public function getInstance() :GameModel
		{
			if (!_instance)
				_instance = new GameModel();
			
			return _instance;
		}
		
		public function initGame() :void
		{
			players = [];
			
			for (i = 1; i <= 10; i++)
			{
				player = new PlayerVO(i, false, i-1);
				players.push(player);
			}
			
			setUser((players[4] as PlayerVO));
			setDealer((players[9] as PlayerVO));
		}
		
		public function setDealer(player :PlayerVO) :void
		{
			for (i = 0; i < players.length; i++)
			{
				if ((players[i] as PlayerVO).playerId == player.playerId)
				{
					(players[i] as PlayerVO).isDealer = true;
					dealerId = player.playerId;
				}
				else
					(players[i] as PlayerVO).isDealer = false;
				
				players[i].enabled = true;
			}
			
			updatePosition();
			
			initActions(true);
			updateActions();
		}
		
		public function resetGame() :void
		{
			updatePosition();
			
			initActions(true);
			updateActions();
		}
		
		public function newGame() :void
		{
			currentPos = 0;
			message = "New game! Game phase: " + gamePhase;
			
			increaseDealerPosition();
			
			dispatchEvent(new GameEvent(GameEvent.NEW_GAME));
		}
		
		private function increaseDealerPosition() :void
		{
			var id :int = -1;
			
			for (var i :int = 0; i < players.length; i++)
			{
				player = players[i] as PlayerVO;
				
				if (player.isDealer)
				{
					if (i == players.length - 1)
						id = 0;
					else
						id = i+1;
					
					setDealer(players[id] as PlayerVO);
					break;
				}
			}
		}
		
		private function initActions(isPreflop :Boolean = false) :void
		{
			removeActions();
			
			if (isPreflop)
			{
				(posPlayers[0] as PlayerVO).action = Actions.SB;
				(posPlayers[1] as PlayerVO).action = Actions.BB;
				
				if (posPlayers.length > 2)
					currentPos = 2;
				else
					currentPos = 0;
				
				
				raisePos = 2;
			}
			else
			{
				currentPos = 0;
				raisePos = 0;
			}
		}
		
		private function removeActions() :void
		{
			for (i = 0; i < players.length; i++)
			{
				player = players[i] as PlayerVO;
				
				player.toggleAllActions(false);
				player.action = null;
				player.oldAction = null;
			}
		}
		
		private function updateActions() :void
		{
			disableAllActions();
			
			player = posPlayers[currentPos] as PlayerVO; // enable current position actions
			
			player.toggleAllActions(true, false);
			
			var areRaises :Boolean = false;
			
			for (i = 0; i < posPlayers.length; i++)
			{
				var rPlayer :PlayerVO = posPlayers[i] as PlayerVO;
				
				if (rPlayer.action == Actions.RAISE)
					areRaises = true;
			}
			
			if (gamePhase != GamePhases.PRE_FLOP && !areRaises)
			{
				player.checkEnabled = true;
				player.callEnabled = false;
			}
			
			if (player.action == Actions.BB && !areRaises)
			{
				player.toggleAllActions(false);
				player.checkEnabled = true;
				player.raiseEnabled = true;
			}
		}
		
		public function recommendAction() :void
		{
			if (gamePhase == GamePhases.PRE_FLOP)
				recommendPreFlopAction();
			else if (gamePhase == GamePhases.FLOP)
				recommendFlopAction();
			else if (gamePhase == GamePhases.TURN)
				recommendTurnAction();
			else if (gamePhase == GamePhases.RIVER)
				recommendRiverAction();
		}
		
		private function recommendPreFlopAction() :void
		{
			if (!userCards || userCards.length != 2)
			{
				message = "No valid cards enterd!";
				return;
			}
			
			message = "You should: " + PreFlopAnalyzer.analyzeCards(userCards, currentPos, posPlayers, raisePos).toUpperCase();
		}
		
		private function recommendFlopAction() :void
		{
			if (!userCards || userCards.length != 2 || !tableCards || tableCards.length != 3)
			{
				message = "No valid cards enterd!";
				return;
			}
			
			message = "You should: " + FlopAnalyzer.analyzeCards(userCards, tableCards, posPlayers, actionsLog).toUpperCase();
		}
		
		private function recommendTurnAction() :void
		{
			if (!userCards || userCards.length != 2 || !tableCards || tableCards.length != 4)
			{
				message = "No valid cards enterd!";
				return;
			}
			
			message = "You should: " + TurnAnalyzer.analyzeCards(userCards, tableCards, posPlayers, actionsLog).toUpperCase();
		}
		
		private function recommendRiverAction() :void
		{
			if (!userCards || userCards.length != 2 || !tableCards || tableCards.length != 5)
			{
				message = "No valid cards enterd!";
				return;
			}
			
			message = "You should: " + RiverAnalyzer.analyzeCards(userCards, tableCards, posPlayers, actionsLog).toUpperCase();
		}
		
		private function disableAllActions() :void
		{
			for (i = 0; i < posPlayers.length; i++)
			{
				player = posPlayers[i] as PlayerVO;
				
				player.toggleAllActions(false);
			}
		}
		
		public function setUser(player :PlayerVO) :void
		{
			for (i = 0; i < players.length; i++)
			{
				if ((players[i] as PlayerVO).playerId == player.playerId)
					(players[i] as PlayerVO).isUser = true;
				else
					(players[i] as PlayerVO).isUser = false;
			}
		}
		
		public function updatePlayerAction() :void
		{
			player = posPlayers[currentPos];
			
			var actionLog :ActionLogVO = new ActionLogVO(player.action, player, gamePhase);
			
			if (player.isUser && gamePhase != GamePhases.PRE_FLOP)
				actionLog.handType = HandAnalyzer.analyze(userCards, tableCards);
			
			actionsLog.push(actionLog);
			
			if (player.action == Actions.RAISE)
				raisePos = currentPos;
			
			currentPos++;
			
			if (currentPos > posPlayers.length - 1)
				currentPos = 0;
			
			manageFoldedPlayersPosition();
			
			if (raisePos == currentPos)
			{
				increaseGamePhase();
				
				return;
			}
			
			updateActions();
			
			if (player.isUser)
				recommendAction();
		}
		
		private function manageFoldedPlayersPosition() :Boolean
		{
			if (posPlayers[currentPos].action == Actions.FOLD)
			{
				var noFoldPlayer :int = -1;
				var i :int;
				
				for (i = currentPos; i < posPlayers.length; i++)
				{
					if (posPlayers[i].action != Actions.FOLD)
					{
						noFoldPlayer = i;
						break;
					}
				}
				
				if (noFoldPlayer == -1)
				{
					for (i = 0; i < currentPos; i++)
					{
						if (posPlayers[i].action != Actions.FOLD)
						{
							noFoldPlayer = i;
							break;
						}
					}
				}
				
				if (noFoldPlayer > -1)
					currentPos = noFoldPlayer;
				else
					message = "All players have folded";
			}
			
			return false;
		}
		
		private function removeFoldedPlayers() :void
		{
			for (var i :int = 0; i < posPlayers.length; i++)
				if (posPlayers[i].action == Actions.FOLD)
					posPlayers[i].enabled = false;
		}
		
		private function increaseGamePhase() :void
		{
			if (gamePhase == GamePhases.PRE_FLOP)
				gamePhase = GamePhases.FLOP;
			else if (gamePhase == GamePhases.FLOP)
				gamePhase = GamePhases.TURN;
			else if (gamePhase == GamePhases.TURN)
				gamePhase = GamePhases.RIVER;
			else if (gamePhase == GamePhases.RIVER)
			{
				gamePhase = GamePhases.PRE_FLOP;
				newGame();
				return;
			}
			
			currentPos = 0;
			message = "New game phase: " + gamePhase;
			
			removeFoldedPlayers();
			
			updatePosition();
			
			initActions();
			updateActions();
		}
		
		public function updatePosition() :void
		{
			var currPos :int = -1;
			
			posPlayers = [];
			
			for (i = 0; i < players.length; i++)
			{
				player = players[i] as PlayerVO;
				
				if (player.enabled && player.playerId > dealerId)
				{
					currPos++;
					player.position = currPos;
					
					posPlayers.push(player);
				}
			}
			
			for (i = 0; i < players.length; i++)
			{
				player = players[i] as PlayerVO;
				
				if (player.enabled && player.playerId <= dealerId)
				{
					currPos++;
					player.position = currPos;
					
					posPlayers.push(player);
				}
			}
			
			for (i = 0; i < players.length; i++)
			{
				player = players[i] as PlayerVO;
				
				if (!player.enabled)
					player.position = -1;
			}
		}
	}
}