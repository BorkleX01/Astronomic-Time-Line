package model
{
	import com.adaptiveelearning.capi.CAPIDescription;
	import com.adaptiveelearning.capi.CAPIInterface;
	import com.adaptiveelearning.capi.CAPIType;
	import com.adaptiveelearning.utils.CallLaterUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(name="change", type="flash.events.Event")]
	public class TimelineEventObject extends EventDispatcher
	{
		private var callLater:CallLaterUtil;
		private var stage:DisplayObject;
		public function TimelineEventObject(stage:DisplayObject) {
			this.stage = stage;
			callLater = new CallLaterUtil(stage);
			
			initCAPI();
		}
		
		
		public var CAPI:CAPIInterface = new CAPIInterface(this);
		
		private function initCAPI():void {
			
			CAPI.addCAPIState("index", 			CAPIType.NUMBER, true);
			CAPI.addCAPIState("name", 			CAPIType.STRING, true);
			CAPI.addCAPIState("date", 			CAPIType.NUMBER, true);
			CAPI.addCAPIState("userDate", 		CAPIType.NUMBER, true);
			CAPI.addCAPIState("discrepancy", 	CAPIType.NUMBER, true);
			CAPI.addCAPIState("isPlaced", 		CAPIType.BOOLEAN, true);
			CAPI.addCAPIState("isCorrect", 		CAPIType.BOOLEAN, true);
			CAPI.addCAPIState("isSelected", 	CAPIType.BOOLEAN, true);
			CAPI.addCAPIState("forceCorrect", 	CAPIType.BOOLEAN, true);
			CAPI.addCAPIState("enabled", 		CAPIType.BOOLEAN, true, new CAPIDescription("(Note: overriden by forceCorrect) Set enabled to false to lock the event to the " +
																							"list or timeline (depending on where it was last placed). Set forceCorrect to false " +
																							"to be able to change this value"));
		}
		
		//-------------- Properties -------------// 
		
		
		public var forceCorrectHasChanged:Boolean;
		
		private var _forceCorrect:Boolean;
		public function get forceCorrect():Boolean { return _forceCorrect; }
		public function set forceCorrect(value:Boolean):void {
			if (_forceCorrect == value) return;
			
			_forceCorrect = value;
			forceCorrectHasChanged = true;
			
			//force enabled to equal forceCorrect
			_enabled = !_forceCorrect;
			isOnTimeline = _forceCorrect;
			
			invalidate();
		}
		
		
		private var _includeInView:Boolean;
		public function get includeInView():Boolean { return _includeInView; }
		public function set includeInView(value:Boolean):void {
			_includeInView = value;
			invalidate();
		}
		
		
		private var _isOnTimeline:Boolean;
		public function get isOnTimeline():Boolean { return _isOnTimeline; }
		public function set isOnTimeline(value:Boolean):void {
			_isOnTimeline = value;
			invalidate();
		}
		
		
		private var _enabled:Boolean;
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void {
			//cancel out if force correct is true
			if (forceCorrect) return;
			
			_enabled = value;
			
			invalidate();
		}
		
		
		private var _visualIndex:int;
		public function get visualIndex():int { return _visualIndex; }
		public function set visualIndex(value:int):void {
			_visualIndex = value;
			invalidate();
		}
		
		
		//eventIndex
		private var _index:int;
		public function get index():int { return _index; }
		public function set index(value:int):void {
			_index = value;
			invalidate();
		}
		
		
		//eventName
		private var _name:String;
		public function get name():String { return _name; }
		public function set name(value:String):void {
			_name = value;
			invalidate();
		}
		
		//eventDate
		private var _date:Number;
		public function get date():Number { return _date; }
		public function set date(value:Number):void {
			_date = value;
			invalidate();
		}
		
		
		private var _userDate:Number;
		public function get userDate():Number { return _userDate; }
		public function set userDate(value:Number):void {
			_userDate = value;
			invalidate();
		}
		
		
		private var _description:String;
		public function get description():String { return _description; }
		public function set description(value:String):void {
			_description = value;
			invalidate();
		}
		
		
		private var _linkURL:String;
		public function get linkURL():String { return _linkURL; }
		public function set linkURL(value:String):void {
			_linkURL = value;
			invalidate();
		}
		
		
		private var _imagePath:String;
		public function get imagePath():String { return _imagePath; }
		public function set imagePath(value:String):void {
			_imagePath = value;
			invalidate();
		}
		
		
		private var _isSelected:Boolean
		public function get isSelected():Boolean { return _isSelected; }
		public function set isSelected(value:Boolean):void { 
			_isSelected = value;
		}
		
		
		//-------------- Read Only Properties -------------// 
		
		public function set isCorrect(value:Boolean):void {} //read-only
		public function get isCorrect():Boolean {
			return (userDate == date);
		}
		
		
		public function set discrepancy(value:Number):void {} //read-only
		public function get discrepancy():Number {
			return Math.abs(userDate - date);
		}
		
		
		public function set isPlaced(value:Boolean):void {} //read-only
		public function get isPlaced():Boolean {
			return isOnTimeline;
		}
		
		//-------------- Support Methods -------------// 
		
		
		private var _invalidateFlag:Boolean;
		public function invalidate():void {
			if (!_invalidateFlag) {
				callLater.callLaterByFrames(2, this, commitProperties);
			}
			
			_invalidateFlag = true;
		}
		
		
		private function commitProperties():void {
			dispatchEvent(new Event(Event.CHANGE));
			_invalidateFlag = false;
		}
	}
}