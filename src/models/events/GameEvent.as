package models.events
{
	import flash.events.Event;
	
	public class GameEvent extends Event
	{
		static public const NEW_GAME :String = "newGame";
		
		public function GameEvent(type:String)
		{
			super(type);
		}
	}
}