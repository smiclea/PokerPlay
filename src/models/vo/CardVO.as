package models.vo
{
	import models.constants.Cards;

	[Bindable]
	public class CardVO
	{
		public var rank :String;
		public var suit :String;
		
		public function CardVO(rank :String, suit :String)
		{
			this.rank = rank;
			this.suit = suit;
		}
		
		public function isEqual(card :CardVO) :Boolean
		{
			return this.rank == card.rank && this.suit == card.suit;
		}
		
		public function rankDiff(rank :String) :int
		{
			return Math.abs(Cards.RANKS.indexOf(this.rank) - Cards.RANKS.indexOf(rank)) / 2;
		}
		
		public function isRankLessEqualThan(aRank :String) :Boolean
		{
			if (Cards.RANKS.indexOf(rank) >= Cards.RANKS.indexOf(aRank))
				return true;
			
			return false;
		}
		
		public function isRankGreaterEqualThan(aRank :String) :Boolean
		{
			if (Cards.RANKS.indexOf(rank) <= Cards.RANKS.indexOf(aRank))
				return true;
			
			return false;
		}
		
		public function isRankGreaterThan(aRank :String) :Boolean
		{
			if (Cards.RANKS.indexOf(rank) < Cards.RANKS.indexOf(aRank))
				return true;
			
			return false;
		}
		
	}
}