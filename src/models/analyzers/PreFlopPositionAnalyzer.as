package models.analyzers
{
	public class PreFlopPositionAnalyzer
	{
		static public const SB :String = "sb";
		static public const BB :String = "bb";
		static public const LATE :String = "late";
		static public const MIDDLE :String = "middle";
		static public const EARLY :String = "early";
		
		static private const POSITIONS_TABLE :Array = [
			{
				players: 10,
				pos: [SB, BB, EARLY, EARLY, EARLY, MIDDLE, MIDDLE, MIDDLE, LATE, LATE]
			},
			{
				players: 9,
				pos: [SB, BB, EARLY, EARLY, MIDDLE, MIDDLE, MIDDLE, LATE, LATE]
			},
			{
				players: 8,
				pos: [SB, BB, EARLY, MIDDLE, MIDDLE, MIDDLE, LATE, LATE]
			},
			{
				players: 7,
				pos: [SB, BB, EARLY, MIDDLE, MIDDLE, LATE, LATE]
			},
			{
				players: 6,
				pos: [SB, BB, EARLY, MIDDLE, LATE, LATE]
			},
			{
				players: 5,
				pos: [SB, BB, EARLY, MIDDLE, LATE]
			},
			{
				players: 4,
				pos: [SB, BB, EARLY, LATE]
			},
			{
				players: 3,
				pos: [SB, BB, EARLY]
			},
			{
				players: 2,
				pos: [SB, BB]
			}
		];
		
		public function PreFlopPositionAnalyzer()
		{
		}
		
		static public function positionGroup(position :int, posPlayers :Array) :String
		{
			for (var i :int = 0; i < POSITIONS_TABLE.length; i++)
			{
				if (posPlayers.length == POSITIONS_TABLE[i].players)
				{
					return POSITIONS_TABLE[i].pos[position];
				}
			}
			
			return null;
		}
	}
}