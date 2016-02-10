package ui
{
	import flash.events.Event;
	
	public class PanelEvent extends Event
	{
		public static const BACK:String = 'socViewBack';
		public static const ACTION:String = 'socViewAction';
		public static const SOCIAL_ACTION:String = 'socialAction';
		
		//
		public function PanelEvent(type:String)
		{
			super(type, true);
		}
		
		public var socId:String;
		public var buttonId:String;
		
		public override function clone():Event
		{
			var cloneEvent:PanelEvent = new PanelEvent(this.type);
			cloneEvent.socId = socId;
			cloneEvent.buttonId = buttonId;
			return cloneEvent;
		}
	}
}