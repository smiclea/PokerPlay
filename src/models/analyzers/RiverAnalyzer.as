package models.analyzers
{
	import models.constants.Actions;
	import models.constants.GamePhases;
	import models.vo.ActionLogVO;

	public class RiverAnalyzer extends AbstractAnalyzer
	{
		public function RiverAnalyzer()
		{
		}
		
		static public function analyzeCards(userCards :Array, tableCards :Array, players: Array, actionsLog :Array) :String
		{
			var handType :String = HandAnalyzer.analyze(userCards, tableCards);
			
			var hasInitiative :Boolean = playerHasInitiative(actionsLog, GamePhases.TURN);
			var numRaisesBeforeUser :int = getNumRaisesBeforeUser(players);
			var numRaisesAfterUser :int = getNumRaisesAfterUser(players);
			var previousTopPair :Boolean = userPreviouslyActionedTopPair(actionsLog);
			
			if (hasInitiative)
			{
				if (numRaisesAfterUser == 0 && numRaisesBeforeUser == 0 && HandAnalyzer.isMadeHand(handType))
				{
					log("You have initiative and a made hand with no bets before or after you. You have: " + handType);
					return Actions.RAISE;
				}
				
				if (numRaisesAfterUser > 0)
				{
					log("You have: " + handType + ". If it's possible that the opponent has a better hand, call the raise. If you have the best hand, raise further.");
					return Actions.READ_LOG;
				}
				
				if (numRaisesBeforeUser > 0)
				{
					if (HandAnalyzer.isMadeHand(handType))
					{
						log("You have: " + handType + ". Raise if it's not likely that there's a better hand. Otherwise call.");
						return Actions.READ_LOG;
					} else
					{
						log("You don't have a made hand and an opponent bet before you.");
						return Actions.FOLD;
					}
				}
			} else 
			{
				if (handType == HandAnalyzer.TOP_PAIR)
				{
					if (numRaisesAfterUser == 0 && numRaisesBeforeUser == 0 )
					{
						log("You have a top pair, you don't have initiative, and no action before you.");
						return Actions.RAISE;
					} else if (numRaisesAfterUser == 1 || numRaisesBeforeUser == 1)
					{
						log("You have a top pair, you don't have initiative, and someone rised before or after you.");
						return Actions.CALL;
					} else if (numRaisesAfterUser >= 2 || numRaisesBeforeUser >= 2)
					{
						log("You have a top pair, you don't have initiative, and more then one rised before or after you.");
						return Actions.FOLD;
					}
				}
				
				if (HandAnalyzer.isMonsterHand(handType))
				{
					log("You have: " + handType + ". Bet or raise if you think there might be a better hand, otherwise call.");
					return Actions.READ_LOG;
				}
				
				if (previousTopPair)
				{
					if (numRaisesAfterUser == 0 && numRaisesBeforeUser == 0)
					{
						log("You have called/raised with a top-pair or overpair on the flop or turn and no action yet on the river");
						return Actions.RAISE;
					} else if (numRaisesAfterUser >= 1 || numRaisesBeforeUser >= 1)
					{
						log("You have called/raised with a top-pair or overpair on the flop or turn, there is action on the river");
						return Actions.FOLD;
					}
				}
				
				if (numAvailablePlayers(players) == 2 && numRaisesBeforeUser == 1)
				{
					log("If you have a simple pair, call. You have one opponent and no top pair or better hand.");
					return Actions.READ_LOG;
				}
				
				log("You have: " + handType + ". You seem to have a weak hand.");
				return Actions.FOLD;
			}
			
			
			return "NO ACTION FOUND";
		}
		
		static private function  userPreviouslyActionedTopPair(actionsLog :Array) :Boolean
		{
			for (var i :int = 0; i < actionsLog.length; i++)
			{
				var al :ActionLogVO = actionsLog[i];
				
				if (al.gamePhase == GamePhases.FLOP || al.gamePhase == GamePhases.TURN)
					if (al.player.isUser && (al.player.action == Actions.RAISE || al.player.action == Actions.CALL))
						if (al.handType == HandAnalyzer.TOP_PAIR || al.handType == HandAnalyzer.OVER_PAIR)
							return true;
			}
			
			return false;
		}
	}
}