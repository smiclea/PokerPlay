package models.vo
{
	[Bindable]
	public class PlayerVO
	{
		public var playerId :int;
		public var isUser :Boolean;
		public var position :int;
		public var enabled :Boolean;
		public var isDealer :Boolean;
		
		// operations
		public var checkEnabled :Boolean;
		public var foldEnabled :Boolean;
		public var raiseEnabled :Boolean;
		public var callEnabled :Boolean;
		
		public var action :String;
		public var oldAction :String;
		
		public function PlayerVO(playerId :int = NaN, isUser :Boolean = false, position :int = NaN, enabled :Boolean = true)
		{
			this.playerId = playerId;
			this.isUser = isUser;
			this.position = position;
			this.enabled = enabled;
		}
		
		public function toggleAllActions(enabled :Boolean = true, includeCheck :Boolean = true) :void
		{
			checkEnabled = (includeCheck) ? enabled : checkEnabled;
			foldEnabled = enabled;
			raiseEnabled = enabled;
			callEnabled = enabled;
		}
	}
}