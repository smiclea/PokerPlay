package models.analyzers
{
	import models.GameModel;
	import models.constants.Actions;
	import models.vo.PlayerVO;
	import models.InfoLog;

	public class PreFlopActionAnalyzer extends InfoLog
	{
		static public const ALL_FOLD :String = "allFold";
		static public const ONE_CALL_BB :String = "oneCallsBB";
		static public const TWO_MORE_CALL_BB :String = "twoMoreCallBB";
		static public const ONE_RAISE_ALL_FOLD :String = "oneRaiseAllFold";
		static public const ONE_RAISE_ONE_MORE_CALL :String = "oneRaiseOneMoreCall";
		static public const NO_ACTION :String = "noAction";
		
		
		public function PreFlopActionAnalyzer()
		{
		}
		
		static public function getActionsSummary(players :Array, raisePos :int) :String
		{
			var player :PlayerVO;
			var numFolds :int = 0;
			var numRaises :int = 0;
			var numCalls :int = 0;
			var numFoldSinceRaise :int;
			var j :int;
			
			
			if (players[0].isUser || players[1].isUser)
			{
				var sum :int = (players[0].isUser) ? 1 : 0;
				var totals :Object = getTotals(players);
				
				if (totals.folds == players.length - 1 - sum)
					return ALL_FOLD;
				
				if (totals.calls == 1 && totals.raises == 0)
					return ONE_CALL_BB;
				
				if (totals.calls > 1 && totals.raises == 0)
					return TWO_MORE_CALL_BB;
				
				if (totals.raises == 1)
				{
					numFoldSinceRaise = 0;
					
					var addToLength :int = 0;
					
					for (j = raisePos + 1; j < players.length; j++)
						if (players[j].action == Actions.FOLD)
							numFoldSinceRaise++;
					
					if (players[1].isUser && players[0].action == Actions.FOLD)
						numFoldSinceRaise++;
					
					if (players[1].isUser)
						addToLength++;
					
					if (numFoldSinceRaise == (players.length + addToLength) - (raisePos + 1))
						return ONE_RAISE_ALL_FOLD;
					
					return ONE_RAISE_ONE_MORE_CALL;
				}
			}
			
			for (var i :int = 0; i < players.length; i++)
			{
				player = players[i];
			
				if (player.action == Actions.RAISE)
					numRaises++;
				
				if (player.action == Actions.CALL)
					numCalls++;
				
				if (player.action == Actions.FOLD)
					numFolds++;
				
				if (player.isUser)
				{
					if (i == 2)
						return ONE_CALL_BB;
					
					if (i-numFolds-2 == 0)
						return ALL_FOLD;
					
					if (numRaises == 0 && numCalls == 1)
						return ONE_CALL_BB;
					
					if (numRaises == 0 && numCalls > 1)
						return TWO_MORE_CALL_BB;
					

					if (numRaises == 1)
					{
						numFoldSinceRaise = 0;
						
						for ( j = raisePos + 1; j < i; j++)
							if (players[j].action == Actions.FOLD)
								numFoldSinceRaise++;
						
						if (numFoldSinceRaise == i - (raisePos + 1))
							return ONE_RAISE_ALL_FOLD;
						
						return ONE_RAISE_ONE_MORE_CALL;
					}
				}
					
			}
			
			return null;
		}
		
		static private function getTotals(players :Array) :Object
		{
			var totals :Object = {
				calls: 0,
				raises: 0,
				folds: 0
			};
			
			for (var i :int = 0; i < players.length; i++)
			{
				if (players[i].action == Actions.CALL)
					totals.calls++;
				
				if (players[i].action == Actions.RAISE)
					totals.raises++;
				
				if (players[i].action == Actions.FOLD)
					totals.folds++;
			}
			
			return totals;
		}
	}
}