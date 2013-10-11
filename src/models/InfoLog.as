package models
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class InfoLog
	{
		static private var _log :ArrayCollection; 
		
		public static function get logData():ArrayCollection
		{
			if (!_log)
				_log = new ArrayCollection();
			
			return _log;
		}
		
		public static function set logData(value:ArrayCollection):void
		{
			_log = value;
		}
		
		public function InfoLog()
		{
		}
		
		static public function log(text :String) :void
		{
			logData.addItemAt(text, 0);
		}
	}
}