package events
{
	import flash.events.Event;
	
	import model.TimelineEventObject;
	
	public class TimeScalerEvent extends Event
	{
		public static const START_DRAG:String = "startEventDrag";
		public static const STOP_DRAG:String = "stopEventDrag";
		public static const SELECT_EVENT:String = "selectEvent";
		public static const DESELECT_EVENT:String = "deselectEvent";
		public static const VIEW_EVENT_DETAILS:String = "viewEventDetails";
		public static const RENDER_TIMELINE:String = "renderTimeline";
		
		public function TimeScalerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}