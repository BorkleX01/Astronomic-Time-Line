package model
{
	import com.adaptiveelearning.capi.CAPIArrayWrapper;
	import com.adaptiveelearning.capi.CAPIDescription;
	import com.adaptiveelearning.capi.CAPIEvent;
	import com.adaptiveelearning.capi.CAPIInterface;
	import com.adaptiveelearning.capi.CAPIType;
	import com.adaptiveelearning.utils.CallLaterUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import view.TimelineEventView;
	
	[Event(name="change", type="flash.events.Event")]
	public class TimeScalerModel extends EventDispatcher
	{
		public function TimeScalerModel() {}
		
		
		private var callLater:CallLaterUtil;
		public var stage:DisplayObject;
		public function initStage(stage:DisplayObject):void {
			this.stage = stage;
			callLater = new CallLaterUtil(stage);
			
			invalidate();
		}
		
		
		public function loadEventObjects():void {
			var dataRecords:DataParser = new DataParser(dataURL, 1, presentYear, yearOfBirth);
			dataRecords.addEventListener("dataLoaded", eventsLoaded);
		}
		
		
		public var eventsWrapper:CAPIArrayWrapper;
		
		protected function eventsLoaded(event:Event):void {
			var dataRecords:DataParser = event.target as DataParser;
			
			timelineEvents = new ArrayCollection();
			
			for (var i:int = 0; i < dataRecords.f1.length; i++)
			{
				var timelineEvent:TimelineEventObject = new TimelineEventObject(stage);
				timelineEvent.date = Number(dataRecords.f1[i]);
				timelineEvent.name = dataRecords.f2[i];
				timelineEvent.imagePath = dataRecords.f3[i];
				timelineEvent.description = dataRecords.f4[i];
				timelineEvent.linkURL = dataRecords.f5[i];
				timelineEvent.includeInView = true;
				timelineEvent.index = i;
				timelineEvent.visualIndex = i + 1;
				timelineEvent.enabled = true;
				
				timelineEvents.addItem(timelineEvent);
			}
			
			invalidate();
			
			//timeline events must be instantiated prior to setting it up in CAPI. Be sure not 
			// to destroy or replace the reference or CAPI will break.			
			eventsWrapper = new CAPIArrayWrapper("Events", "Event", timelineEvents, true);			
			CAPI.addDynamicObject("Events", this, "eventsWrapper", true);
			
			CAPI.dispatchEvent(new CAPIEvent(CAPIEvent.READY));
		}
		
		
		public var CAPI:CAPIInterface = initCAPI();
		
		public function initCAPI():CAPIInterface {
			
			var newCAPI: CAPIInterface = new CAPIInterface(this);
			newCAPI.waitForReadyEvent = true;
			
			newCAPI.addCAPIState("Reset", 				CAPIType.BOOLEAN, 	false, 	new CAPIDescription("", null, false, true));
			newCAPI.addCAPIState("showCorrects", 		CAPIType.BOOLEAN,	false, 	new CAPIDescription("", null, false, true));
			newCAPI.addCAPIState("isCorrect", 			CAPIType.BOOLEAN,	false, 	new CAPIDescription("", null, false, true));
			newCAPI.addCAPIState("yearOfBirth", 		CAPIType.NUMBER, 	true, 	new CAPIDescription("", null, false, true));
			newCAPI.addCAPIState("eventsToUse", 		CAPIType.ARRAY, 	true, 	new CAPIDescription("List the index values of all events you would like to appear in the Sim", null, false, true));
			newCAPI.addCAPIState("zoomMin", 			CAPIType.NUMBER, 	true, 	new CAPIDescription("The minimum zoom value (must be more than -7000000000)", null, false, true));
			newCAPI.addCAPIState("zoomMax", 			CAPIType.NUMBER, 	true, 	new CAPIDescription("The maximum zoom value (must be less than 7000000000)", null, false, true));
			newCAPI.addCAPIState("zoomDisabled", 		CAPIType.BOOLEAN, 	true, 	new CAPIDescription("Disable Zooming", null, false, true));
			
			return newCAPI;
		}
		
		
		// ------------- Model Methods-----------------------//
		
		
		public function getNumberOfEventsPlaced():int {
			var count:int = 0;
			for each (var timelineEvent:TimelineEventObject in filteredTimelineEvents) {
				if (timelineEvent.isOnTimeline) {
					count++;
				}
			}
			return count;
		}
		
		
		public function getEventObjectByName(name:String):TimelineEventObject {
			for each (var timelineEvent:TimelineEventObject in filteredTimelineEvents) {
				if (timelineEvent.name == name) {
					return timelineEvent;
				}
			}
			return null;
		}
		
		
		public function resetZoom():void {
			presentZoomBegin = zoomMin;// = zoomDefaultMin;
			presentZoomEnd = zoomMax;// = zoomDefaultMax;
			zoomHasChanged = false;
			
			invalidate();
		}
		
		
		//-------------- Primary Model Properties -------------// 
		
				
		public function set eventsToUse(value:Array):void { 
			var eventsToUseCollection:ArrayCollection = new ArrayCollection();
			for each (var stringIndex: String in value) {
				eventsToUseCollection.addItem(parseInt(stringIndex));
			}
			filteredTimelineEvents = eventsToUseCollection;
		}
		public function get eventsToUse():Array { 
			var indexArray:Array = [];
			
			for each (var timelineEventObject:TimelineEventObject in filteredTimelineEvents) {
				indexArray.push(timelineEventObject.index.toString());
			}
			
			return indexArray;
		}
		
		//this is set to true by the model but should be set to false by the app when neccessary 
		public var filteredEventsChanged:Boolean;
		
		//The filtered timeline events property is mainly used for updating the individual event
		// data objects. So this property is not used directly
		private var _filteredTimlineEvents:ArrayCollection;
		public function get filteredTimelineEvents():ArrayCollection { 
			//if filter doesn't exist, use the full timeline events object
			if (_filteredTimlineEvents == null || _filteredTimlineEvents.length == 0) {
				return timelineEvents;
			} 
			return _filteredTimlineEvents;
		}
		public function set filteredTimelineEvents(value:ArrayCollection):void {
			if (_filteredTimlineEvents == value) return;
			
			//update individual event objects
			if (timelineEvents){
				_filteredTimlineEvents = new ArrayCollection();
				var visIndex:int = 0;
				var numEvents:int = timelineEvents.length;
				for (var i:int=0; i < numEvents; i++ in timelineEvents) {
					var tEvent:TimelineEventObject = timelineEvents[i];
					if (value.getItemIndex(i) != -1) {
						tEvent.includeInView = true;
						tEvent.visualIndex = ++visIndex;
						_filteredTimlineEvents.addItem(tEvent);
					} else {
						tEvent.includeInView = false;
						tEvent.visualIndex = -1;
					}
				}
			}
			filteredEventsChanged = true;
			invalidate();
		}

		
		private var _timelineEvents:ArrayCollection;
		public function get timelineEvents():ArrayCollection { return _timelineEvents; }
		public function set timelineEvents(value:ArrayCollection):void {
			_timelineEvents = value;
			invalidate();
		}
		
		
		private var _selectedTimelineEvent:TimelineEventObject;
		public function get selectedTimelineEvent():TimelineEventObject { return _selectedTimelineEvent; }
		public function set selectedTimelineEvent(value:TimelineEventObject):void {
			_selectedTimelineEvent = value;
			_highlightedTimelineEvent = value;
			
			for each (var timelineEventObject:TimelineEventObject in filteredTimelineEvents) {
				timelineEventObject.isSelected = (timelineEventObject == value);
			}
			
			invalidate();
		}
		
		
		private var _highlightedTimelineEvent:TimelineEventObject;
		public function get highlightedTimelineEvent():TimelineEventObject { return _highlightedTimelineEvent; }
		public function set highlightedTimelineEvent(value:TimelineEventObject):void {
			_highlightedTimelineEvent = value;
			invalidate();
		}
		
		
		private var _showCorrects:Boolean;
		public function get showCorrects():Boolean { return _showCorrects; }
		public function set showCorrects(value:Boolean):void {
			_showCorrects = value;
			invalidate();
		}
		
		
		public var zoomHasChanged:Boolean;
		
		private var _zoomMin:Number;
		public function get zoomMin():Number { return _zoomMin; }
		public function set zoomMin(value:Number):void {
			//if (_zoomMin == value) return;
			if (value < zoomDefaultMin) value = zoomDefaultMin;
			_zoomMin = value;
			zoomHasChanged = true;
			invalidate();
		}
		
		
		private var _zoomMax:Number;
		public function get zoomMax():Number { return _zoomMax; }
		public function set zoomMax(value:Number):void {
			//if (_zoomMax == value) return;
			if (value > zoomDefaultMax) value = zoomDefaultMax;
			_zoomMax = value;
			zoomHasChanged = true;
			invalidate();
		}
		
		private var _zoomDisabled:Boolean;
		public function get zoomDisabled():Boolean { return _zoomDisabled; }
		public function set zoomDisabled(value:Boolean):void {
			_zoomDisabled = value;
			invalidate();
		}
		
		
		//-------------- Model Setup Properties -------------// 
		
		
		private var _presentZoomBegin:Number;
		public function get presentZoomBegin():Number { return _presentZoomBegin; }
		public function set presentZoomBegin(value:Number):void {
			if (value < zoomMin) value = zoomMin;
			
			_presentZoomBegin = Math.round(value);
			invalidate();
		}
		
		
		private var _presentZoomEnd:Number;
		public function get presentZoomEnd():Number { return _presentZoomEnd; }
		public function set presentZoomEnd(value:Number):void {
			if (value > zoomMax) value = zoomMax;
			
			_presentZoomEnd = Math.round(value);
			invalidate();
		}
		
		
		private var _scaleFactor:Number;
		public function get scaleFactor():Number { return _scaleFactor; }
		public function set scaleFactor(value:Number):void {
			_scaleFactor = value;
			invalidate();
		}
		
		
		private var _timelineDropMin:Number;
		public function get timelineDropMin():Number { return _timelineDropMin; }
		public function set timelineDropMin(value:Number):void {
			_timelineDropMin = value;
			invalidate();
		}
		
		private var _timelineDropMax:Number;
		public function get timelineDropMax():Number { return _timelineDropMax; }
		public function set timelineDropMax(value:Number):void {
			_timelineDropMax = value;
			invalidate();
		}
		
		private var _imageURL:String;
		public function get imageURL():String { return _imageURL; }
		public function set imageURL(value:String):void {
			_imageURL = value;
			invalidate();
		}
		
		
		private var _dataURL:String;
		public function get dataURL():String { return _dataURL; }
		public function set dataURL(value:String):void {
			_dataURL = value;
			invalidate();
		}
		
		
		private var _yearOfBirth:int;
		public function get yearOfBirth():int { return _yearOfBirth; }
		public function set yearOfBirth(value:int):void {
			if (value == -1) value = 0;
			
			_yearOfBirth = value;
			if (getEventObjectByName('Your Birth') != null) {
				getEventObjectByName('Your Birth').date = value;
			}
			invalidate();
		}
		
		
		private var _reset:Boolean;
		public function get Reset():Boolean { return _reset; }
		public function set Reset(value:Boolean):void {
			if (value == _reset) return;
			
			_reset = value;
			invalidate();
		}
	
		
		//---------- Basic (Quiet) properties ----------------//
		
		//these properties wont invalidate the model
		public var timelineMedScale:Number;
		public var timelineSmallScale:Number;
		public var zoomDefaultMin:Number;
		public var zoomDefaultMax:Number;
		public var scaleBarX:int;
		public var scaleBarHeight:int;
		
		
		//---------- Read Only properties -----------//
		
		
		public function set presentYear(value:int):void {}
		public function get presentYear():int {
			var today:Date = new Date();
			return presentYear = today.getFullYear(); 
		}
		
		public function set isCorrect(value:Boolean):void {}
		public function get isCorrect():Boolean {
			for each (var timelineEventObject:TimelineEventObject in filteredTimelineEvents) {
				if (!timelineEventObject.isCorrect && !timelineEventObject.forceCorrect) {
					return false;
				}
			}
			return true;
		}
		
		//-------------- Support Methods -------------// 
		
		
		private var _invalidateFlag:Boolean;
		public function invalidate():void {
			if (!_invalidateFlag && callLater != null) {
				callLater.callLaterByFrames(2, this, commitProperties);
				
				_invalidateFlag = true;
			}
		}
		
		
		private function commitProperties():void {
			if (Reset) {
				filteredTimelineEvents = timelineEvents;
				zoomMax = zoomDefaultMax;
				zoomMin = zoomDefaultMin;
				showCorrects = false;
				highlightedTimelineEvent = null;
				selectedTimelineEvent = null;
				
				for each (var timelineEvent:TimelineEventObject in timelineEvents) {
					timelineEvent.includeInView = true;
					timelineEvent.visualIndex = timelineEvent.index + 1;
					timelineEvent.forceCorrect = false;
					timelineEvent.isOnTimeline = false;
					timelineEvent.enabled = true;
					timelineEvent.isSelected = false;
					timelineEvent.userDate = NaN;
				}
				
				Reset = false;
			}
			
			dispatchEvent(new Event(Event.CHANGE));
			_invalidateFlag = false;
		}
	}
}