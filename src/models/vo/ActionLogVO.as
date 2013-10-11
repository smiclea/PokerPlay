package models.vo
{
	[Bindable]
	public class ActionLogVO
	{
		public var name :String;
		public var player :PlayerVO;
		public var gamePhase :String;
		public var handType :String;
		
		
		public function ActionLogVO(name :String = "", player :PlayerVO = null, gamePhase :String = "", handType :String = "")
		{
			this.name = name;
			this.player = player;
			this.gamePhase = gamePhase;
			this.handType = handType;
		}
	}
}