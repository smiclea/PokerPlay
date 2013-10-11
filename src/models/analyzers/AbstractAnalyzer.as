package models.analyzers
{
	import models.InfoLog;
	import models.constants.Actions;
	import models.vo.ActionLogVO;
	import models.vo.PlayerVO;

	public class AbstractAnalyzer extends InfoLog
	{
		public function AbstractAnalyzer()
		{
		}
		
		static protected function getNumRaisesAfterUser(players :Array) :int
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
		
		static protected function numAvailablePlayers(players :Array) :int
		{
			var count :int = 0;
			
			for (var i :int = 0; i < players.length; i++)
				if (players[i].action != Actions.FOLD)
					count++;
			
			return count;
		}
		
		
		static protected function getNumRaisesBeforeUser(players :Array) :int
		{
			var count :int = 0;
			
			for (var i :int = 0; i < players.length; i++)
			{
				var player :PlayerVO = players[i] as PlayerVO;
				
				if (player.isUser)
					return count;
				
				if (player.action == Actions.RAISE)
					count++;
			}
			
			return count;
		}
		
		static protected function noActionBeforeUser(players :Array) :Boolean
		{
			var wasAction :Boolean = false;
			
			for (var i:int = 0; i < players.length; i++)
			{
				var player :PlayerVO = players[i] as PlayerVO;
				
				if (player.action == Actions.RAISE)
					wasAction = true;
				
				if (player.isUser && !wasAction)
					return true;
			}
			
			return false;
		}
		
		static protected function playerHasInitiative(actionsLog :Array, lastGamePhase :String) :Boolean
		{
			for (var i :int = actionsLog.length - 1; i >= 0; i--)
			{
				var log :ActionLogVO = actionsLog[i] as ActionLogVO;
				
				if (log.gamePhase == lastGamePhase)
				{
					if (log.name == Actions.RAISE)
					{
						if (log.player.isUser)
							return true;
						else
							return false;
					}
				}
			}
			
			return false;
		}
		
	}
}