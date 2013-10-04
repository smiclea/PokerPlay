package models.events
{
	import flash.events.Event;
	
	import models.vo.PlayerVO;
	
	public class PlayerEvent extends Event
	{
		static public const PLAYER_ENABLE :String = "playerEnable";
		static public const PLAYER_DEALER :String = "playerDealer";	
		static public const PlAYER_USER :String = "playerUser";
		static public const PlAYER_ACTION :String = "playerAction";
		
		public var player :PlayerVO;
		
		public function PlayerEvent(type:String, player :PlayerVO = null)
		{
			super(type, true);
			
			this.player = player;
		}
	}
}