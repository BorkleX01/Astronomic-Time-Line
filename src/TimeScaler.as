package
{
	import com.adaptiveelearning.capi.CAPIInterface;
	import com.adaptiveelearning.utils.CallLaterUtil;
	
	import events.TimeScalerEvent;
	
	import fl.controls.Button;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.utils.Dictionary;
	
	import model.TimeScalerFactory;
	import model.TimeScalerModel;
	import model.TimelineEventObject;
	
	import view.InfoContent;
	import view.ScrollList;
	import view.SystemMarker;
	import view.TimelineEventView;
	import view.TimelineScrollerBar;
	import view.TimelineView;
	import view.TimelineZoomer;
	
	[SWF(frameRate="30", height="600", width="950")]
	public class TimeScaler extends Sprite
	{
		//set to false for release
		public static const DEBUG_MODE:Boolean = false;
		
		private var timeScalerModel:TimeScalerModel;
		private var resetEventsButton:MovieClip;
		private var resetZoomButton:MovieClip;
		private var numEventsPlacedTF:TextField;
		private var infoContentView:InfoContent;
		private var listView:ScrollList;
		private var timelineView:TimelineView;
		private var timelineZoomer:TimelineZoomer;
		private var timelineScrollerBar:TimelineScrollerBar;
		private var discrepancyMarkers:Dictionary;
		private var scaleBarHotspot:MovieClip;
		private var timelineEventViewContainer:Sprite;
		private var markersContainer:Sprite;
		
		//array of all timelineEvent views
		private var timelineEventViews:Array;
		
		
		public function TimeScaler() {
			if (DEBUG_MODE) {
				timeScalerModel = TimeScalerFactory.newDebugModel();
			} else {
				timeScalerModel = TimeScalerFactory.newReleaseModel();
			}
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			timeScalerModel.initStage(this);
			
			//listen for any changes to the model
			timeScalerModel.addEventListener(Event.CHANGE, updateDisplay);
			
			//load the csv data for timeline events. This will trigger the first updateDisplay() call when loaded.
			timeScalerModel.loadEventObjects();
		}
		
		
		public function get CAPI():CAPIInterface {
			return timeScalerModel.CAPI;
		}
		
		
		// ---------- Main Display Update Method ---------//
		
		protected function updateDisplay(event:Event = null):void 
		{
			//trace("updateDisplay() in Document class");
			if (timeScalerModel.timelineEvents == null || timeScalerModel.timelineEvents.length == 0) return;
			
			// only initialize on the first run
			init();
			
			//update scroll list
			listView.updateDisplay();
			
			//update info content panel
			infoContentView.updateDisplay();
			
			//update num events placed
			numEventsPlacedTF.text = (timeScalerModel.getNumberOfEventsPlaced()) + "/" 
										+ timeScalerModel.filteredTimelineEvents.length + " events placed";
			
			//reset zoom if changed
			if (timeScalerModel.zoomHasChanged) {
				timelineZoomer.stopZoom();
				timeScalerModel.resetZoom();
			}
			
			//update timeline
			timelineScrollerBar.disabled = timeScalerModel.zoomDisabled;
			timelineZoomer.disabled = timeScalerModel.zoomDisabled;
			resetZoomButton.visible = !timeScalerModel.zoomDisabled;
			
			var timelineEventView:TimelineEventView
			
			//setting any children that have been forced correct to main stage so they can be placed on the timeline
			for each (timelineEventView in timelineEventViews) {
				if (timelineEventView.data.forceCorrect && !timelineEventViewContainer.contains(timelineEventView)) {
					timelineEventViewContainer.addChild(timelineEventView);
				}
			}
			
			timelineView.updateDisplay();
			
			var marker:SystemMarker;
			
			//update discrepancy markers (if showing correct states)
			if (timeScalerModel.showCorrects) 
			{
				//trace("showCorrects true , manage markers:");
				for each (timelineEventView in timelineEventViews) {
					marker = discrepancyMarkers[timelineEventView];
					
					if (timelineEventView.data.isOnTimeline && timelineEventView.data.includeInView)
					{
						
						if (isNaN(timelineEventView.data.userDate) || (timelineEventView.data.userDate < timeScalerModel.zoomMax && timelineEventView.data.userDate > timeScalerModel.zoomMin)) 
						{
							//trace(timelineEventView.data.name + " no userdate or userdate within zoom bounds.");
							//only show the marker if the userdate is within the current min max bounds - this is needed
							// for when the zoomMin and zoomMax are defined after events have already been placed
							
							marker.y = scaleBarHotspot.y + scaleBarHotspot.height;
							marker.x = timeScalerModel.scaleFactor * (marker.date - timeScalerModel.presentZoomBegin);
							marker.state = (marker.date < timeScalerModel.presentZoomBegin ? SystemMarker.OFF_TIMELINE_LEFT
											: marker.date > timeScalerModel.presentZoomEnd ? SystemMarker.OFF_TIMELINE_RIGHT
											: SystemMarker.ON_TIMELINE);
							
							markersContainer.addChildAt(marker, 0);
						} 
						else 
						{
							//trace("marker object has a userdate value or userdate value outside zoom bounds.")
							if (markersContainer.contains(marker)) {
								marker.visible = false;
								markersContainer.removeChild(marker);
								continue;
							}
						}
					}
					
					marker.updateDisplay();
				}
				
				//add highlighted marker to top of display list
				var highlightedEventView:TimelineEventView = getEventViewByData(timeScalerModel.highlightedTimelineEvent)
				if (highlightedEventView 
						&& discrepancyMarkers[highlightedEventView]
						&& highlightedEventView.data.isOnTimeline
						&& highlightedEventView.data.includeInView) {
					
					marker = discrepancyMarkers[highlightedEventView];
					
					if (marker){
						markersContainer.addChild(marker);
					}
				}
				
			} else if (!timeScalerModel.showCorrects) {
				//clear markers
				for each (var clearMarker:SystemMarker in discrepancyMarkers) {
					if (markersContainer.contains(clearMarker)) {
						markersContainer.removeChild(clearMarker);
						clearMarker.visible = false;
					}
				}
			}
		}
		
		
		//------------ Initialisation ----------//
		
		
		private var initialised:Boolean;
		public function init():void {
			if (initialised) return;
			
			initialised = true;
			
			var newContextMenu:ContextMenu = new ContextMenu();
			newContextMenu.hideBuiltInItems();
			contextMenu = newContextMenu;
			
			//all assets are provided by the ViewAsset class due to asset management in previous 
			// project. This means that all the assets have already been added to the stage, and 
			// are just being passed as a reference through to the class views (InfoContent, ScrollList
			// TimelineScaler etc). The class views are themselves not added to the stage, but instead 
			// just setup and configure the provided assets via the model.
			var mc:ViewAsset = new ViewAsset();
			addChild(mc);
			
			markersContainer = new Sprite();
			addChild(markersContainer);
			
			timelineEventViewContainer = new Sprite();
			addChild(timelineEventViewContainer);
			
			scaleBarHotspot = mc.scaleBarHotspot;
			
			//create timeline event views
			timelineEventViews = [];
			discrepancyMarkers = new Dictionary();
			var numTimelineObjects:int = timeScalerModel.timelineEvents.length;
			for (var i:int = 0; i < numTimelineObjects; i++) 
			{
				//trace("make new thumbX and new marker for: "+timeScalerModel.timelineEvents[i])
				var eView:TimelineEventView = new TimelineEventView(timeScalerModel.timelineEvents[i] as TimelineEventObject, timeScalerModel);
				eView.addEventListener(TimeScalerEvent.VIEW_EVENT_DETAILS, onViewEventDetails);
				eView.addEventListener(TimeScalerEvent.START_DRAG, onStartEventDrag);
				eView.addEventListener(TimeScalerEvent.STOP_DRAG, onStopEventDrag);
				eView.addEventListener(TimeScalerEvent.SELECT_EVENT, onEventSelection);
				eView.addEventListener(TimeScalerEvent.DESELECT_EVENT, onEventDeselect);
				timelineEventViews.push(eView);
				
				discrepancyMarkers[eView] = new SystemMarker(eView, timeScalerModel);
			}
			
			
			//initialise the main info panel
			infoContentView = new InfoContent(mc.infoPanel.infoPlacer, timeScalerModel);
			
			//intialize the list scroller
			listView = new ScrollList(mc.scrollBar, mc.selectaPanel, timeScalerModel, timelineEventViews);
			
			//initialize the timeline
			timelineView = new TimelineView(mc.scaleBar, scaleBarHotspot, timeScalerModel, timelineEventViews);
			
			//initialize the timeline zoomer
			timelineZoomer = new TimelineZoomer(mc.scaleBar, scaleBarHotspot, timeScalerModel);
			timelineZoomer.addEventListener(TimeScalerEvent.RENDER_TIMELINE, renderTimeline);
			
			//initialize the timeline scroll bar
			timelineScrollerBar = new TimelineScrollerBar(mc.timeScroller, timeScalerModel);
			timelineScrollerBar.addEventListener(TimeScalerEvent.RENDER_TIMELINE, renderTimeline);
			
			//initialize remaining individual components
			resetEventsButton = mc.resetEventsButton;
			resetEventsButton.addEventListener(MouseEvent.CLICK, onResetEvents);
			resetEventsButton.buttonMode = true;
			
			resetZoomButton = mc.resetZoomButton;
			resetZoomButton.addEventListener(MouseEvent.CLICK, onResetZoom);
			resetZoomButton.buttonMode = true;
			
			numEventsPlacedTF = mc.numEventsPlacedTF;
			
			timeScalerModel.scaleBarHeight = scaleBarHotspot.height;
			timeScalerModel.scaleBarX = scaleBarHotspot.x;
			
			updateDisplay();
			
			//runCAPITest();
		}
		
		
		private function runCAPITest():void {
			var callLater:CallLaterUtil = new CallLaterUtil(this);
			callLater.callLaterByFrames(90, this,
				function ():void {
					timeScalerModel.CAPI.applyValue("eventsToUse", ['0','1','2','3','4','5','6']);
					timeScalerModel.CAPI.applyValue("Events.Event0.forceCorrect", true);
					//timeScalerModel.CAPI.applyValue("Events.Event5.forceCorrect", true);
					//timeScalerModel.CAPI.applyValue("Events.Event9.forceCorrect", true);
					timeScalerModel.CAPI.applyValue("showCorrects", true);
					//timeScalerModel.CAPI.applyValue("zoomMin", -4000000000);
					//timeScalerModel.CAPI.applyValue("zoomMax", -3000000000);
				}
				,null);
		}
		
		
		private function renderTimeline(event:Event):void {
			updateDisplay();
		}
		
		
		private function getEventViewByData(eventObject:TimelineEventObject):TimelineEventView {
			for each (var eventView:TimelineEventView in timelineEventViews) {
				if (eventView.data == eventObject) return eventView;
			}
			
			return null;
		}
		
		
		// ------------------- Event Handlers ---------------- //
		
		
		protected function onResetEvents(event:MouseEvent):void {
			var numTimelineObjects:int = timeScalerModel.timelineEvents.length;
			for each (var eView:TimelineEventView in timelineEventViews) {
				if (eView.data.enabled) {
					eView.data.isOnTimeline = false;
					eView.data.userDate = NaN;
				}
				eView.updateDisplay();
			}
			
			updateDisplay();
		}
		
		
		protected function onResetZoom(event:MouseEvent):void {
			timelineZoomer.stopZoom();
			timeScalerModel.resetZoom();
		}
		
		
		private function onViewEventDetails(event:Event):void {
			if (event.target is TimelineEventView) {			
				timeScalerModel.highlightedTimelineEvent = (event.target as TimelineEventView).data as TimelineEventObject;
			}
		}
		
		
		private function onStartEventDrag(event:Event):void {
			updateDisplay();
			
			var timelineEventView:TimelineEventView = event.target as TimelineEventView;
			var newPos:Point = timelineEventView.parent.localToGlobal(new Point(timelineEventView.x, timelineEventView.y));
			newPos = globalToLocal(newPos);
			
			timelineEventView.x = newPos.x;
			timelineEventView.y = newPos.y;
			
			timelineEventView.data.isOnTimeline = false;
			
			timelineEventViewContainer.addChild(timelineEventView);
		}
		
		
		private function onStopEventDrag(event:Event):void {
			//no logic here, the timeline and list view components updateDisplay() methods should take care of the rest
			
			var hotspotLeway:int = 100;
			var timelineEventView:TimelineEventView = event.target as TimelineEventView;
			trace("onStopEventDrag():  width: " + width + " mouseX: "+mouseX);
			if (mouseY < height && mouseY > 0 && mouseX < Math.abs(width) && mouseX > 0) 
			{
				//mouse is on the stage
				
				if (mouseY > scaleBarHotspot.y - hotspotLeway 
					&& mouseY < scaleBarHotspot.y + scaleBarHotspot.height + hotspotLeway) {
					//mouse is over the timeline
					
					timelineEventView.data.isOnTimeline = true;
				}
			}
			
			if (!timelineEventView.data.isOnTimeline) {
				//reset the userDate if the eventView was not dropped on the timeline
				timelineEventView.data.userDate = NaN;
			}
			
			timelineEventView.updateDisplay();
			updateDisplay();
		}
		
		
		private function onEventSelection(event:Event):void {
			var prevSelectedView:TimelineEventView;
			if (timeScalerModel.selectedTimelineEvent) {
				prevSelectedView = timelineEventViews[timeScalerModel.selectedTimelineEvent.index] as TimelineEventView;
			}
			
			var timelineEventView:TimelineEventView = event.target as TimelineEventView;
			timeScalerModel.selectedTimelineEvent = timelineEventView.data;
			timelineEventView.updateDisplay();
			
			if (prevSelectedView) {
				prevSelectedView.updateDisplay();
			}
		}
		
		
		private function onEventDeselect(event:Event):void {
			var timelineEventView:TimelineEventView = event.target as TimelineEventView;
			if (timeScalerModel.selectedTimelineEvent == timelineEventView.data) {
				//deselect all only if the current event is actually selected
				timeScalerModel.selectedTimelineEvent = null;
				timelineEventView.updateDisplay();
			}
		}
	}
}