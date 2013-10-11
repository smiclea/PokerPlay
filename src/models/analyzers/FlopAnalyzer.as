package models.analyzers
{
	import models.constants.Actions;
	import models.constants.GamePhases;

	public class FlopAnalyzer extends AbstractAnalyzer
	{
		static private const MONSTER_HAND :String = "monsterHand";
		
		public function FlopAnalyzer()
		{
		}
		
		static public function analyzeCards(userCards :Array, tableCards :Array, players :Array, actionsLog :Array) :String
		{
			var handType :String = HandAnalyzer.analyze(userCards, tableCards);
			
			if (HandAnalyzer.isMonsterHand(handType))
			{
				log("You have a monster hand. You should CAP. Hand type: " + handType);
				return Actions.RAISE;
			}
			
			if (handType == HandAnalyzer.MONSTER_DRAW)
			{
				log("You have a monster draw. You should CAP.");
				return Actions.RAISE;
			}
			
			log("You have: " + handType);
			
			var numRaisesAfterUser :int = getNumRaisesAfterUser(players);
			var numPlayers :int = numAvailablePlayers(players);
			var hasInitiative :Boolean = playerHasInitiative(actionsLog, GamePhases.PRE_FLOP);
			
			if (handType == HandAnalyzer.TOP_PAIR || handType == HandAnalyzer.OVER_PAIR
				|| handType == HandAnalyzer.FLUSH_DRAW || handType == HandAnalyzer.OESD 
				|| handType == HandAnalyzer.DOUBLE_GUTSHOT || handType == HandAnalyzer.GUTSHOT_OVERCARD)
			{
				if (numRaisesAfterUser == 0)
				{
					log("No raises after you.");
					return Actions.RAISE;
				} else if (numRaisesAfterUser == 1)
				{
					log("One opponent raised after you.");
					return Actions.CALL;
				} else
				{
					log("More than one opponent raised after you.");
					return Actions.FOLD;
				}
			}
			
			if (handType == HandAnalyzer.GUTSHOT || handType == HandAnalyzer.OVERCARD)
			{
				if (noActionBeforeUser(players) && hasInitiative && numPlayers <= 3)
				{
					log("You raised before flop, there are at most two opponents and no action before you.");
					return Actions.RAISE;
				} 
				else
				{
					log("10 times - Call a bet or raise if the pot is at least 10 times the size of bet");
					return Actions.READ_LOG;
				}
			}
			
			if (handType == "")
			{
				if (hasInitiative && numPlayers <= 3)
				{
					log("Bluff. You were the last to raise and you are against two opponents at most.");
					return Actions.RAISE;
				}
				else
				{
					log("You have a worthless hand and weren't the last to raise or you are against more than two opponents.");
					return Actions.FOLD;
				}
			}
			
			return "NO ACTION FOUND";
		}
		
	}
}