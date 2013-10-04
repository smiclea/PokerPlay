package models.constants
{
	import models.vo.CardVO;

	public class Cards
	{
		static public const RANKS :String = "A,K,Q,J,T,9,8,7,6,5,4,3,2";
		static public const SUITS :String = "s,d,c,h";
		
		static public function areOfRanks(isRank1 :String, isRank2 :String, ofRank1 :String, ofRank2 :String) :Boolean
		{
			if (isRank1 == ofRank1 && isRank2 == ofRank2)
				return true;
			
			if (isRank1 == ofRank2 && isRank2 == ofRank1)
				return true;
			
			return false;
		}
		
		static public function areOfRank(isRank1 :String, isRank2 :String, ofRank1 :String) :Boolean
		{
			if (isRank1 == ofRank1 || isRank2 == ofRank1)
				return true;
			
			return false;
		}
		
		static public function sortCardsByRank(cards :Array) :void
		{
			cards.sort(function (a :CardVO, b :CardVO) :int
			{
				if (RANKS.indexOf(a.rank) < RANKS.indexOf(b.rank))
					return -1;
				else if (RANKS.indexOf(a.rank) > RANKS.indexOf(b.rank))
					return 1;
				
				return 0;
			});
		}
		
		static public function sortMultipleCardsByRank(cards1 :Array, cards2 :Array) :Array
		{
			var result :Array = [];
			result = result.concat(cards1);
			result = result.concat(cards2);
			
			result.sort(function (a :CardVO, b :CardVO) :int
			{
				if (RANKS.indexOf(a.rank) < RANKS.indexOf(b.rank))
					return -1;
				else if (RANKS.indexOf(a.rank) > RANKS.indexOf(b.rank))
					return 1;
				
				return 0;
			});
			
			return result;
		}
	}
}