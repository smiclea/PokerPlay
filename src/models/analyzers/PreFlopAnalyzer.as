package models.analyzers
{
	
	import models.constants.Actions;
	import models.constants.Cards;
	import models.vo.CardVO;

	[Bindable]
	public class PreFlopAnalyzer extends AbstractAnalyzer
	{
		static private const VERY_STRONG_HAND :String = "veryStrongHand";
		static private const STRONG_HAND :String = "strongHand";
		static private const MEDIOCRE_HAND :String = "mediocreHand";
		static private const SPECULATIVE_HAND :String = "speculativeHand";
		static private const MIXED_HAND :String = "mixedHand";
		
		static public function analyzeCards(userCards :Array, position :int, players :Array, raisePos: int) :String
		{
			var handStrength :String = handStrength(userCards);
			
			if (handStrength == "")
			{
				logData.addItemAt("You have trash hand.", 0);
				return Actions.FOLD;
			}
			
			if (handStrength == VERY_STRONG_HAND)
			{
				logData.addItemAt("You should CAP because you have a very strong hand.", 0);
				return Actions.RAISE;
			}
			
			var exception :String = treatExceptions(players, handStrength);

			if (exception)
				return exception;
			
			var action :String = getAction(handStrength, position, players, raisePos, userCards);
			
			if (!action)
			{
				logData.addItemAt("Couldn't find a play with current hand.", 0);
				action = Actions.FOLD;
			}
			
			return action;
		}
		
		static private function treatExceptions(players :Array, handStrength :String) :String
		{
			var userId :int = -1;
			var raiseCount :int = 0;
			var i :int;
			
			for (i = 0; i < players.length; i++)
			{
				if (userId > -1 && players[i].action == Actions.RAISE)
					raiseCount++;
				
				if (players[i].isUser)
					userId = i;
			}
			
			for (i = 0; i < userId; i++)
				if (players[i].oldAction && players[i].action == Actions.RAISE)
					raiseCount++;
			
			if (raiseCount == 1)
			{
				logData.addItemAt("Exactly one raise behind you.", 0);
				return Actions.RAISE;
			} else if (raiseCount > 1)
			{
				if (handStrength == STRONG_HAND)
				{
					logData.addItemAt("You have a strong hand. More than one raise behind you.", 0);
					return Actions.CALL;
				}
				else 
				{
					logData.addItemAt("More than one raise behind you.", 0);
					return Actions.FOLD;
				}
			}
			
			return null;
		}
		
		static private function getAction(handStrength :String, position :int, players :Array, raisePos :int, userCards :Array) :String
		{
			var actionSum :String = PreFlopActionAnalyzer.getActionsSummary(players, raisePos);
			var postionGroup :String = PreFlopPositionAnalyzer.positionGroup(position, players);
			
			logData.addItemAt("Hand strength: " + handStrength + ", Players action: " + actionSum + ", Position: " + postionGroup, 0);
			
			if (handStrength == STRONG_HAND)
			{
				if (actionSum == PreFlopActionAnalyzer.ALL_FOLD)
					return Actions.RAISE;
				
				if (actionSum == PreFlopActionAnalyzer.ONE_CALL_BB)
					return Actions.RAISE;
				
				if (actionSum == PreFlopActionAnalyzer.TWO_MORE_CALL_BB)
					return Actions.RAISE;
				
				if (actionSum == PreFlopActionAnalyzer.ONE_RAISE_ALL_FOLD)
				{
					if (postionGroup == PreFlopPositionAnalyzer.EARLY)
						return Actions.FOLD;
					else
						return Actions.RAISE;
				}
				
				if (actionSum == PreFlopActionAnalyzer.ONE_RAISE_ONE_MORE_CALL)
					return Actions.CALL;
			}
			
			if (handStrength == MEDIOCRE_HAND)
			{
				if (actionSum == PreFlopActionAnalyzer.ALL_FOLD)
				{
					if (postionGroup == PreFlopPositionAnalyzer.EARLY)
						return Actions.FOLD;
					else
						return Actions.RAISE;
				}
				
				if (actionSum == PreFlopActionAnalyzer.ONE_CALL_BB)
				{
					if (postionGroup == PreFlopPositionAnalyzer.EARLY)
						return Actions.FOLD;
					else
						return Actions.RAISE;
				}
				
				if (actionSum == PreFlopActionAnalyzer.TWO_MORE_CALL_BB)
				{
					if (postionGroup == PreFlopPositionAnalyzer.EARLY)
						return Actions.FOLD;
					else
						return Actions.RAISE;
				}
				
				if (actionSum == PreFlopActionAnalyzer.ONE_RAISE_ALL_FOLD)
				{
					if (postionGroup == PreFlopPositionAnalyzer.BB)
						return Actions.CALL;
					else
						return Actions.FOLD;
				}
				
				if (actionSum == PreFlopActionAnalyzer.ONE_RAISE_ONE_MORE_CALL)
				{
					var card1 :CardVO = userCards[0] as CardVO;
					var card2 :CardVO = userCards[1] as CardVO;
					
					if (postionGroup == PreFlopPositionAnalyzer.BB
						|| (card1.suit == card2.suit && Cards.areOfRanks(card1.rank, card2.rank, "K", "Q")))
						return Actions.CALL;
					else
						return Actions.FOLD;
				}
			}
			
			if (handStrength == SPECULATIVE_HAND)
			{
				if (actionSum == PreFlopActionAnalyzer.ALL_FOLD)
				{
					if (postionGroup == PreFlopPositionAnalyzer.EARLY || postionGroup == PreFlopPositionAnalyzer.MIDDLE)
						return Actions.FOLD;
					else
						return Actions.RAISE;
				}
				
				if (actionSum == PreFlopActionAnalyzer.ONE_CALL_BB)
				{
					if (postionGroup == PreFlopPositionAnalyzer.EARLY || postionGroup == PreFlopPositionAnalyzer.MIDDLE)
						return Actions.FOLD;
					
					if (postionGroup == PreFlopPositionAnalyzer.LATE || postionGroup == PreFlopPositionAnalyzer.SB)
						return Actions.CALL;
					
					return Actions.CHECK;
				}
				
				if (actionSum == PreFlopActionAnalyzer.TWO_MORE_CALL_BB)
				{
					if (postionGroup == PreFlopPositionAnalyzer.BB)
						return Actions.CHECK;
					
					return Actions.CALL;
				}
				
				if (actionSum == PreFlopActionAnalyzer.ONE_RAISE_ALL_FOLD)
				{
					if (postionGroup == PreFlopPositionAnalyzer.BB)
						return Actions.CALL;
					
					return Actions.FOLD;
				}
				
				if (actionSum == PreFlopActionAnalyzer.ONE_RAISE_ONE_MORE_CALL)
					return Actions.CALL;
			}
			
			if (handStrength == MIXED_HAND)
			{
				if (actionSum == PreFlopActionAnalyzer.ALL_FOLD)
				{
					if (postionGroup == PreFlopPositionAnalyzer.EARLY || postionGroup == PreFlopPositionAnalyzer.MIDDLE)
						return Actions.FOLD;
					
					return Actions.RAISE;
				}
				
				if (actionSum == PreFlopActionAnalyzer.ONE_CALL_BB)
				{
					if (postionGroup == PreFlopPositionAnalyzer.EARLY || postionGroup == PreFlopPositionAnalyzer.MIDDLE || postionGroup == PreFlopPositionAnalyzer.LATE)
						return Actions.FOLD;
					
					if (postionGroup == PreFlopPositionAnalyzer.SB)
						return Actions.CALL;
					
					return Actions.CHECK;
				}
				
				if (actionSum == PreFlopActionAnalyzer.TWO_MORE_CALL_BB)
				{
					if (postionGroup == PreFlopPositionAnalyzer.EARLY || postionGroup == PreFlopPositionAnalyzer.MIDDLE)
						return Actions.FOLD;
					
					if (postionGroup == PreFlopPositionAnalyzer.LATE || postionGroup == PreFlopPositionAnalyzer.SB)
						return Actions.CALL;
					
					return Actions.CHECK;
				}
				
				if (actionSum == PreFlopActionAnalyzer.ONE_RAISE_ALL_FOLD || actionSum == PreFlopActionAnalyzer.ONE_RAISE_ONE_MORE_CALL)
					return Actions.FOLD;
			}
			
			return null;
		}
		
		static private function handStrength(userCards :Array) :String
		{
			var card1 :CardVO = userCards[0] as CardVO;
			var card2 :CardVO = userCards[1] as CardVO;
			var strength :String = "";
			
			if ((card1.rank == card2.rank && card1.isRankGreaterEqualThan("Q")) ||
				Cards.areOfRanks(card1.rank, card2.rank, "A", "K"))
				strength = VERY_STRONG_HAND;
			
			if (card1.rank == card2.rank && card1.isRankGreaterEqualThan("9") && card1.isRankLessEqualThan("J")
			|| Cards.areOfRanks(card1.rank, card2.rank, "A", "Q") ||
			( Cards.areOfRanks(card1.rank, card2.rank, "A", "J") && card1.suit == card2.suit))
				strength = STRONG_HAND;
			
			if ( (Cards.areOfRanks(card1.rank, card2.rank, "A", "J") && card1.suit != card2.suit) ||
				Cards.areOfRanks(card1.rank, card2.rank, "A", "T") || Cards.areOfRanks(card1.rank, card2.rank, "K", "Q"))
				strength = MEDIOCRE_HAND;
			
			if (card1.rank == card2.rank && card1.isRankGreaterEqualThan("2") && card1.isRankLessEqualThan("8") ||
				(card1.suit == card2.suit && (Cards.areOfRanks(card1.rank, card2.rank, "K", "J") ||
					Cards.areOfRanks(card1.rank, card2.rank, "K", "T") ||
					Cards.areOfRanks(card1.rank, card2.rank, "Q", "J") ||
					Cards.areOfRanks(card1.rank, card2.rank, "Q", "T") ||
					Cards.areOfRanks(card1.rank, card2.rank, "J", "T") ||
					Cards.areOfRanks(card1.rank, card2.rank, "T", "9"))))
				strength = SPECULATIVE_HAND;
			
			if ((card1.suit != card2.suit && (Cards.areOfRanks(card1.rank, card2.rank, "K", "J") ||
				Cards.areOfRanks(card1.rank, card2.rank, "K", "T") ||
				Cards.areOfRanks(card1.rank, card2.rank, "Q", "J") ||
				Cards.areOfRanks(card1.rank, card2.rank, "Q", "T") ||
				Cards.areOfRanks(card1.rank, card2.rank, "J", "T"))) ||
				(card1.suit == card2.suit && (Cards.areOfRanks(card1.rank, card2.rank, "K", "9") || 
					Cards.areOfRanks(card1.rank, card2.rank, "8", "7") || 
					Cards.areOfRanks(card1.rank, card2.rank, "9", "8"))))
				strength = MIXED_HAND;
			
			if (card1.suit == card2.suit && Cards.areOfRank(card1.rank, card2.rank, "A"))
			{
				var badCard :CardVO;
				
				if (card1.isRankLessEqualThan("K"))
					badCard = card1;
				else
					badCard = card2;
				
				if (badCard.isRankGreaterEqualThan("2") && badCard.isRankLessEqualThan("9"))
					strength = MIXED_HAND;
			}
			
			return strength;
		}
	}
}