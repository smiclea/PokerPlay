package presenters
{
	import flash.events.EventDispatcher;
	
	import models.GameModel;
	import models.constants.Cards;
	import models.vo.CardVO;

	[Bindable]
	public class TablePresenter extends EventDispatcher
	{
		public var userCards :String;
		public var tableCards :String;
		
		private var i :int;
		
		public function TablePresenter()
		{
		}
		
		public function updateTableCards() :void
		{
			var result :Array = [];
			
			//tableCards = "adts8h";
			
			var newString :String = "";
			
			if ((tableCards.length % 2) == 0 && tableCards.length >= 6)
			{
				for (i = 0; i < tableCards.length; i++)
				{
					if (i % 2 != 0)
					{
						var rank :String = tableCards.charAt(i-1).toUpperCase();
						var suit :String = tableCards.charAt(i).toLowerCase();
						
						newString += rank + suit; 
						if (Cards.RANKS.indexOf(rank) >= 0 && Cards.SUITS.indexOf(suit) >= 0)
							result.push(new CardVO(rank, suit));
						else
						{
							result = [];
							break;
						}
							
					}
				}
			}
			
			if (newString != "")
				tableCards = newString;
			
			GameModel.getInstance().tableCards = result;
		}
		
		public function updateUserCards() :void
		{
			var result :Array = [];
			
			//userCards = "qdjh";
			
			var newString :String = "";
			
			if (userCards.length == 4)
			{
				for (i = 0; i < userCards.length; i++)
				{
					if (i % 2 != 0)
					{
						var rank :String = userCards.charAt(i-1).toUpperCase();
						var suit :String = userCards.charAt(i).toLowerCase();
						newString += rank + suit; 
						
						if (Cards.RANKS.indexOf(rank) >= 0 && Cards.SUITS.indexOf(suit) >= 0)
							result.push(new CardVO(rank, suit));
						else
						{
							result = [];
							break;
						}
						
					}
				}
			}
			
			if (newString != "")
				userCards = newString;
			
			GameModel.getInstance().userCards = result;
		}
	}
}