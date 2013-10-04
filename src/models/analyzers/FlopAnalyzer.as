package models.analyzers
{
	import models.constants.Actions;

	public class FlopAnalyzer extends AbstractAnalyzer
	{
		static private const MONSTER_HAND :String = "monsterHand";
		
		public function FlopAnalyzer()
		{
		}
		
		static public function analyzeCards(userCards :Array, tableCards :Array, players :Array, raisesLog :Array) :String
		{
			var handType :String = HandAnalyzer.analyze(userCards, tableCards);
			
			if (isMonsterHand(handType))
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
				if (players[0].isUser)
				{
					if (raisesLog[raisesLog.length-1].isUser && players.length <= 3)
					{
						log("You raised before flop and there are at most two opponents");
						return Actions.RAISE;
					}
					else
					{
						log("You didn't raise before flop or there are more than two opponents");
						return Actions.FOLD;
					}
				}
				else
				{
					log("10 times - Call a bet or raise if the pot is at least 10 times the size of bet");
					return Actions.FOLD;
				}
			}
			
			if (handType == "")
			{
				if (raisesLog[raisesLog.length-1].isUser && players.length <= 3)
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
			
			return null;
		}
		
		static private function didUserRaiseBeforeFlop(players :Array, raisesLog :Array) :Boolean
		{
			
			
			return false;
		}
		
		static private function isMonsterHand(type :String) :Boolean
		{
			var cases :Object = {
				"twoPair": true,
				"trips" :true,
				"straight": true,
				"flush": true,
				"fullHouse" :true,
				"quads": true,
				"straightFlush": true,
				"royalFlush": true
			};
			
			return cases[type];
		}
		
		static private function getNumRaisesAfterUser(players :Array) :int
		{
			var userI :int = -1;
			var count :int = 0;
			var i:int;
			
			for (i = 0; i < players.length; i++)
			{
				if (players[i].isUser)
					userI = i;
				
				if (userI > -1 && i > userI)
					if (players[i].action == Actions.RAISE)
						count++;
			}
			
			for (i = 0; i < userI; i++)
				if (players[i].action == Actions.RAISE && players[i].oldAction)
					count++;
			
			return count;
		}
		
	}
}