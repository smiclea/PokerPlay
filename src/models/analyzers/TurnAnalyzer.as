package models.analyzers
{
	import models.constants.Actions;
	import models.constants.GamePhases;

	public class TurnAnalyzer extends AbstractAnalyzer
	{
		public function TurnAnalyzer()
		{
		}
		
		static public function analyzeCards(userCards :Array, tableCards :Array, players :Array, actionsLog :Array) :String
		{
			var handType :String = HandAnalyzer.analyze(userCards, tableCards);
			
			var hasInitiative :Boolean = playerHasInitiative(actionsLog, GamePhases.FLOP);
			var numRaisesBeforeUser :int = getNumRaisesBeforeUser(players);
			var numRaisesAfterUser :int = getNumRaisesAfterUser(players);
			
			if (numRaisesAfterUser > 1)
			{
				if (handType == HandAnalyzer.MONSTER_DRAW || handType == HandAnalyzer.FLUSH_DRAW)
				{
					log("More than one bet after you and you have: " + handType);
					return Actions.CALL;
				} else if (handType == HandAnalyzer.OESD || handType == HandAnalyzer.DOUBLE_GUTSHOT)
				{
					log("You have: " + handType + " - call if no opponent flush is possible");
					return Actions.READ_LOG;
				}
			}
			
			if (numRaisesAfterUser == 1 || numRaisesBeforeUser == 1)
			{
				if (HandAnalyzer.isMadeHand(handType))
				{
					log("Someone bet before you or after you and you have: " + handType);
					return Actions.RAISE;
				} else if (handType == HandAnalyzer.TOP_PAIR || handType == HandAnalyzer.OVER_PAIR || handType == HandAnalyzer.MONSTER_DRAW || handType == HandAnalyzer.FLUSH_DRAW 
					|| handType == HandAnalyzer.OESD || handType == HandAnalyzer.DOUBLE_GUTSHOT)
				{
					log("Someone bet before you or after you and you have: " + handType);
					return Actions.CALL;
				} else if (handType == HandAnalyzer.GUTSHOT || handType == HandAnalyzer.GUTSHOT_OVERCARD)
				{
					log("10:1 - if you are getting 10:1 pot odds you should call. Someone bet before you or after you and you have: " + handType);
					return Actions.READ_LOG;
				} else
				{
					log("Someone bet before you or after you and you have a weak hand");
					return Actions.FOLD;
				}
			} else if (numRaisesAfterUser > 1 || numRaisesBeforeUser > 1)
			{
				if (HandAnalyzer.isMadeHand(handType))
				{
					log("You hand: " + handType + " - raise if you believe you have the best hand considering the community cards, otherwise call. There was one bet and one or more raises.");
					return Actions.READ_LOG;
				} else
				{
					log("There was one bet and one or more raises and you have a weak hand");
					return Actions.FOLD;
				}
			}
			
			if (hasInitiative)
			{
				if (numRaisesBeforeUser == 0)
				{
					if (HandAnalyzer.isMadeHand(handType) || (numAvailablePlayers(players) <= 3 && HandAnalyzer.isDraw(handType)))
					{
						log("There was no bet before you, you have the initiative and a) you have a made hand or b) you have a draw but you are against 2 opponents at most. You have: " + handType);
						return Actions.RAISE;
					}
					
					log("You don't have a made hand or you have a draw but there are more than two opponents or you have trash. You have: " + handType);
					return Actions.CHECK;
					
				}
			} else if (numRaisesBeforeUser == 0)
			{
				if (HandAnalyzer.isMadeHand(handType))
				{
					log("You don't have initiative, there were no raises and you have two-pair or better. You have: " +handType);
					return Actions.RAISE;
				} else
				{
					log("You don't have the initiative, there were no raises and you don't have two-pair or better. You have: " + handType);
					return Actions.CHECK;
				}
			}
			
			return "NO ACTION FOUND";
		}
		
	}
}