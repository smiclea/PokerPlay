package models.analyzers
{
	import models.constants.Cards;
	import models.vo.CardVO;

	public class HandAnalyzer
	{
		static public const TOP_PAIR :String = "topPair";
		static public const OVER_PAIR :String = "overPair";
		static public const TWO_PAIR :String = "twoPair";
		static public const TRIPS :String = "trips";
		static public const STRAIGHT :String = "straight";
		static public const FLUSH :String = "flush";
		static public const FULL_HOUSE :String = "fullHouse";
		static public const QUADS :String = "quads";
		static public const STRAIGHT_FLUSH :String= "straightFlush";
		static public const ROYAL_FLUSH :String= "royalFlush";
		
		static public const OESD :String = "OESD";
		static public const FLUSH_DRAW :String = "flushDraw";
		static public const MONSTER_DRAW :String = "monsterDraw";
		static public const GUTSHOT :String = "gutshot";
		static public const DOUBLE_GUTSHOT :String = "doubleGutshot";
		static public const OVERCARD :String = "overcard";
		static public const GUTSHOT_OVERCARD :String = "gutshotOvercard";
		
		public function HandAnalyzer()
		{
		}
		
		static public function analyze(userCards :Array, tableCards :Array) :String
		{
			// monster made hands
			if (isRoyalFlush(userCards, tableCards))
				return ROYAL_FLUSH;
			
			if (isStraightFlush(userCards, tableCards))
				return STRAIGHT_FLUSH;
			
			if (isFourOfAKind(userCards, tableCards))
				return QUADS;
			
			if (isFullHouse(userCards, tableCards))
				return FULL_HOUSE;
			
			if (isFlush(userCards, tableCards))
				return FLUSH;
			
			if (isStraight(userCards, tableCards))
				return STRAIGHT;
			
			if (isTrips(userCards, tableCards))
				return TRIPS;
			
			if (isTwoPair(userCards, tableCards))
				return TWO_PAIR;
			
			//made hands
			if (isOverPair(userCards, tableCards))
				return OVER_PAIR;
			
			if (isTopPair(userCards, tableCards))
				return TOP_PAIR;
			
			//draws
			if (isMonsterDraw(userCards, tableCards))
				return MONSTER_DRAW;
			
			if (isStraight(userCards, tableCards, true))
				return OESD;
				
			if (isFlushDraw(userCards, tableCards))
				return FLUSH_DRAW;
			
			if (isStraight(userCards, tableCards, false, false, true))
				return DOUBLE_GUTSHOT;
			
			if (isGutshotOvercard(userCards, tableCards))
				return GUTSHOT_OVERCARD;
			
			if (isStraight(userCards, tableCards, false, true))
				return GUTSHOT;
			
			if (isOvercard(userCards, tableCards))
				return OVERCARD;
			
			return "";
		}
		
		static private function isGutshotOvercard(userCards :Array, tableCards :Array) :Boolean
		{
			if (isOvercard(userCards, tableCards) && isStraight(userCards, tableCards, false, true))
				return true;
			
			return false;
		}
		
		static private function isOvercard(userCards :Array, tableCards :Array) :Boolean
		{
			Cards.sortCardsByRank(userCards);
			Cards.sortCardsByRank(tableCards);
			
			if ((userCards[0] as CardVO).isRankGreaterThan(tableCards[0].rank) &&
				(userCards[1] as CardVO).isRankGreaterThan(tableCards[0].rank))
				return true;
			
			return false;
		}
		
		static private function isMonsterDraw(userCards :Array, tableCards :Array) :Boolean
		{
			if (isStraight(userCards, tableCards, true) && isFlushDraw(userCards, tableCards))
				return true;
			
			return false;
		}
		
		static private function isRoyalFlush(userCards :Array, tableCards :Array) :Boolean
		{
			var sortedCards :Array = Cards.sortMultipleCardsByRank(userCards, tableCards);
			
			if (isStraightFlush(userCards, tableCards) && sortedCards[0].rank == "A")
				return true;
			
			return false;
		}
		
		static private function isStraightFlush(userCards :Array, tableCards :Array) :Boolean
		{
			if (isFlush(userCards, tableCards) && isStraight(userCards, tableCards))
				return true;
			
			return false;
		}
		
		static private function isFourOfAKind(userCards :Array, tableCards :Array) :Boolean
		{
			var i :int;
			var j :int;
			
			var sortedCards :Array = Cards.sortMultipleCardsByRank(userCards, tableCards);
			var bufferCards :Object = {};
			var sameRankCount :int = 0;
			
			for (i = 0; i < sortedCards.length; i++)
			{
				for (j = 0; j < sortedCards.length; j++)
				{
					if (sortedCards[i].rank == sortedCards[j].rank && sortedCards[i].suit != sortedCards[j].suit &&
						!bufferCards[sortedCards[j].rank + sortedCards[j].suit])
					{
						sameRankCount++;
						bufferCards[sortedCards[j].rank + sortedCards[j].suit] = 1;
					}
				}
				
				if (sameRankCount == 3)
					return true;
				else
					sameRankCount = 0;
			}
			
			return false;
		}
		
		static private function isFullHouse(userCards :Array, tableCards :Array) :Boolean
		{
			var i :int;
			var j :int;
			
			var sortedCards :Array = Cards.sortMultipleCardsByRank(userCards, tableCards);
			var sameRankCount :int = 0;
			var bufferCards :Object = {};
			var tripsCard :CardVO;
			var pairCard :CardVO;
			
			for (i = 0; i < sortedCards.length; i++)
			{
				for (j = 0; j < sortedCards.length; j++)
				{
					if (sortedCards[i].rank == sortedCards[j].rank && sortedCards[i].suit != sortedCards[j].suit &&
						!bufferCards[sortedCards[j].rank + sortedCards[j].suit] && !bufferCards[sortedCards[i].rank + sortedCards[i].suit])
					{
						sameRankCount++;
						bufferCards[sortedCards[j].rank + sortedCards[j].suit] = 1;
					}
				}
				
				if (sameRankCount == 2)
					tripsCard = sortedCards[i] as CardVO;
				
				if (sameRankCount == 1)
					pairCard = sortedCards[i] as CardVO;
				
				sameRankCount = 0;
			}
			
			if (tripsCard && pairCard)
				return true;
			
			return false;
		}
		
		static private function isFlush(userCards :Array, tableCards :Array) :Boolean
		{
			var i :int;
			var j :int;
			
			var sameSuitCount :int = 0;
			var rankBuffer :Object = {};
			
			if (userCards[0].suit != userCards[1].suit)
				return false;
			
			for (i = 0; i < tableCards.length; i++)
			{
				for (j = 0; j < tableCards.length; j++)
				{
					if (tableCards[i].rank != tableCards[j].rank && tableCards[i].suit == tableCards[j].suit &&
						!rankBuffer[tableCards[i].rank])
					{
						sameSuitCount++;
						rankBuffer[tableCards[i].rank] = 1;
					}
				}
			}
			
			if (sameSuitCount >= 3)
				return true;
			
			return false;
		}
		
		static private function isStraight(userCards :Array, tableCards :Array, checkOESD :Boolean = false, checkGutshot :Boolean = false, checkDoubleGutshot :Boolean = false) :Boolean
		{
			var i :int;
			var j :int;
			
			var sortedCards :Array = Cards.sortMultipleCardsByRank(userCards, tableCards);
			var consecs :Array = [];
			var currentCons :int = 0;
			
			for (i = 0; i < sortedCards.length; i++)
			{
				var card :CardVO = sortedCards[i];
				var nextCard :CardVO;
				
				if (i == sortedCards.length - 1)
				{
					if (currentCons > 0)
					{
						consecs[consecs.length-1].consecCount = currentCons+1;
						consecs[consecs.length-1].cards.push(card);
						currentCons = 0;
					}
					break;
				}
				else
					nextCard = sortedCards[i+1];
				
				if (card.rankDiff(nextCard.rank) == 1)
				{
					currentCons++;
					
					if (currentCons==1)
						consecs.push({consecCount: currentCons, cards: [card]});
					else
					{
						consecs[consecs.length-1].consecCount = currentCons;
						consecs[consecs.length-1].cards.push(card);
					}
				}
				else if (currentCons > 0)
				{
					consecs[consecs.length-1].consecCount = currentCons+1;
					consecs[consecs.length-1].cards.push(card);
					currentCons = 0;
				}
			}
			
			var userCardsConsec :int = 0;
			var consecCountCheck :int = (checkOESD) ? 4 : (checkGutshot) ? 2 : (checkDoubleGutshot) ? 3 : 5;
			var consecsCountRepeat :int = 0;
			
			for (i = 0; i < consecs.length; i++)
			{
				if (consecs[i].consecCount == consecCountCheck)
				{
					consecsCountRepeat++;
					
					for (j = 0; j < consecs[i].cards.length; j++)
						for (var k :int = 0; k < userCards.length; k++)
							if (userCards[k].rank == consecs[i].cards[j].rank)
								userCardsConsec++;
				}
			}
			
			if (checkDoubleGutshot)
			{
				if (consecsCountRepeat > 0)
					return isDoubleGutshot(userCards, sortedCards, consecs);
				
				return false;
			}
			
			if (checkGutshot)
			{
				if (consecsCountRepeat >= 2)
					return isGutshot(userCards, sortedCards, consecs);
				
				return false;
			}
			
			if (userCardsConsec == 2)
				return true;
			
			return false;
		}
		
		static private function isGutshot(userCards :Array, sortedCards :Array, consecs :Array) :Boolean
		{
			var i :int, j :int, k :int;
			var gutshotCards :Array = [];
			var userCardsCount :int = 0;
			
			for (i = 0; i < consecs.length; i++)
			{
				if (consecs[i].cards.length == 2)
				{
					if (i < consecs.length - 1)
					{
						if (consecs[i].cards[consecs[i].cards.length-1].rankDiff(consecs[i+1].cards[0].rank) == 2)
						{
							gutshotCards = gutshotCards.concat(consecs[i].cards);
							gutshotCards = gutshotCards.concat(consecs[i+1].cards);
						}
					}
				}
			}
			
			for (i = 0; i < userCards.length; i++)
				for (j = 0; j < gutshotCards.length; j++)
					if (userCards[i].isEqual(gutshotCards[j]))
						userCardsCount++;
			
			if (userCardsCount == 2)
				return true;
			
			return false;
		}
		
		static private function isDoubleGutshot(userCards :Array, sortedCards :Array, consecs :Array) :Boolean
		{
			var i :int, j :int, k :int;
			var gutshotCount :int = 0;
			
			for (i = 0; i < sortedCards.length; i++)
			{
				var found :Boolean = false;
				
				for (j = 0; j < consecs.length; j++)
					for (k = 0; k < consecs[j].cards.length; k++)
						if (sortedCards[i].isEqual(consecs[j].cards[k]))
							found = true;
				
				if (!found)
					for (j = 0; j < consecs.length; j++)
						if (sortedCards[i].rankDiff(consecs[j].cards[0].rank) == 2 || 
							sortedCards[i].rankDiff(consecs[j].cards[consecs[j].cards.length-1].rank) == 2)
							gutshotCount++;
			}
			
			if (gutshotCount >= 2)
				return true;
			
			return false;
		}
		
		static private function isTrips(userCards :Array, tableCards :Array) :Boolean
		{
			var i :int;
			var j :int;
			
			var sortedCards :Array = Cards.sortMultipleCardsByRank(userCards, tableCards);
			var sameRankCount :int = 0;
			var tripsCard :CardVO;
			var bufferCards :Object = {};
			
			for (i = 0; i < sortedCards.length; i++)
			{
				for (j = 0; j < sortedCards.length; j++)
				{
					if (sortedCards[i].rank == sortedCards[j].rank && sortedCards[i].suit != sortedCards[j].suit &&
						!bufferCards[sortedCards[j].suit])
					{
						sameRankCount++;
						bufferCards[sortedCards[j].suit] = 1;
					}
				}
				
				if (sameRankCount == 2)
					tripsCard = sortedCards[i] as CardVO;
				else
					sameRankCount = 0;
			}
			
			if (tripsCard)
				for (i = 0; i < userCards.length; i++)
					if (userCards[i].rank == tripsCard.rank)
						return true;
			
			return false;
		}
		
		static private function isFlushDraw(userCards :Array, tableCards :Array) :Boolean
		{
			var i :int;
			var j :int;
			
			var sameSuitCount :int = 0;
			var rankBuffer :Object = {};
			
			if (userCards[0].suit != userCards[1].suit)
				return false;
			
			for (i = 0; i < tableCards.length; i++)
			{
				for (j = 0; j < tableCards.length; j++)
				{
					if (tableCards[i].rank != tableCards[j].rank && tableCards[i].suit == tableCards[j].suit &&
						!rankBuffer[tableCards[i].rank])
					{
						sameSuitCount++;
						rankBuffer[tableCards[i].rank] = 1;
					}
				}
			}
			
			if (sameSuitCount >= 2)
				return true;
			
			return false;
		}
		
		static private function isTwoPair(userCards :Array, tableCards :Array) :Boolean
		{
			var i :int;
			var j :int;
			var pairMatches :int = 0;
			var bufferCard :Object = {};
			var alreadyPaired :Object = {};
			
			for (i = 0; i < userCards.length; i++)
			{
				for (j = 0; j < tableCards.length; j++)
				{
					if (userCards[i].rank == tableCards[j].rank && !bufferCard[tableCards[j].rank + tableCards[j].suit]
						&& !alreadyPaired[userCards[i].rank + userCards[i].suit])
					{
						pairMatches++;
						bufferCard[tableCards[j].rank + tableCards[j].suit] = 1;
						alreadyPaired[userCards[i].rank + userCards[i].suit] = 1;
					}
				}
			}
			
			if (pairMatches == 2)
				return true;
			
			return false;
		}
		
		static private function isOverPair(userCards :Array, tableCards :Array) :Boolean
		{
			var i :int;
			var j :int;
			var pairCard :CardVO;
			var topRank :String
			
			Cards.sortCardsByRank(tableCards);
			
			if (userCards[0].rank == userCards[1].rank)
				pairCard = userCards[0] as CardVO;
			
			if (pairCard && pairCard.isRankGreaterThan(tableCards[0].rank))
				return true;
			
			return false;
		}
		
		static private function isTopPair(userCards :Array, tableCards :Array) :Boolean
		{
			var i :int;
			var j :int;
			var pairCard :CardVO;
			var topRank :String
			
			Cards.sortCardsByRank(tableCards);
			
			for (i = 0; i < userCards.length; i++)
			{
				for (j = 0; j < tableCards.length; j++)
				{
					if (userCards[i].rank == tableCards[j].rank)
						pairCard = userCards[i] as CardVO;
				}
			}
			
			
			if (pairCard && pairCard.rank == tableCards[0].rank)
				return true;
			
			return false;
		}
	}
}