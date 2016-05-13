package view
{
	import com.adaptiveelearning.utils.CallLaterUtil;
	
	import events.TimeScalerEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	
	import model.TimeScalerFactory;
	import model.TimeScalerModel;
	import model.TimelineEventObject;
	
	import mx.formatters.NumberFormatter;
	
	[Event(name="viewEventDetails", type="events.TimeScalerEvent")]
	[Event(name="selectEvent", type="events.TimeScalerEvent")]
	[Event(name="stopEventDrag", type="events.TimeScalerEvent")]
	[Event(name="startEventDrag", type="events.TimeScalerEvent")]
	public class TimelineEventView extends Sprite
	{
		private var mc:ThumbX;
		private var tsModel:TimeScalerModel;
		
		public function TimelineEventView(data:TimelineEventObject, timeScalerModel:TimeScalerModel) {
			super();
			
			this.tsModel = timeScalerModel;
			this.data = data;
		}
		
		
		
		public function init():void 
		{
			//trace("new timeline event placer ");
			//check for data
			if (data == null) return;
			
			//setup main asset
			if (mc == null) {
				mc = new ThumbX();
				addChild(mc);
			}
			
			//setup icon
			createIcon();
			
			mc.panelBG.mouseEnabled = mc.panelBG.mouseChildren = false;
			mc.field1x.descField.text = data.name;
			mc.field1x.descField.autoSize = TextFieldAutoSize.LEFT;
			mc.field1x.descField.y = (45 - mc.field1x.descField.height) / 2;
			mc.hotSpot.addEventListener(MouseEvent.MOUSE_OVER , onMouseOver);
			
			updateDisplay();
		}
		
		
		public function updateDisplay(event:Event=null):void {
			if (!data.includeInView) {
				visible = false;
				return;
			}
			
			visible = true;
			mc.indexTF.text = (data.visualIndex >= 0) ? (data.visualIndex).toString() : '';
			
			mc.icon.alpha = data.enabled ? 1 : 0.5;
			
			if (data.isOnTimeline || (_isDragging && y > 350)) {
				//on the timeline or dragging near the timeline (small icon view)
				switchView(true);
				
				mc.filters = [];
				
				if (tsModel.selectedTimelineEvent == data && data.enabled) {
					//selected & enabled
					
					mc.field1x.visible = true;
					mc.field2x.visible = true;
					mc.panelBG.visible = true;
					mc.filters = [TimeScalerFactory.newSelectedGlow()];
					
					if (_isMouseOver) {
						scaleUp();
					} else {
						scaleDown();
					}
				}
				else if (_isMouseOver){
					//mouse over
					
					mc.field1x.visible = true;
					mc.field2x.visible = true;
					mc.panelBG.visible = true;
					mc.filters = [];
					scaleUp(); 
				} else {
					//all else
					
					mc.field1x.visible = false;
					mc.field2x.visible = false;
					mc.panelBG.visible = false;
					mc.filters = [];
					scaleDown();
				}
				
				updateYearsText(data.forceCorrect);
				
			} else {
				//is in the list or dragging near the list (large rectangular view)
				switchView(false);
				
				mc.filters = [];
				
				if (_isMouseOver && !_isDragging && data.enabled) {
					//mouse over animation
					mc.gotoAndPlay("stasis");
				} else {
					//all other states
					mc.gotoAndStop(0);
				}
			}
			
			
			if (data.forceCorrectHasChanged) {
				tsModel.invalidate();
				data.forceCorrectHasChanged = false;
			}
		}
		
		
		private var _isMouseOver:Boolean;
		public function get isMouseOver():Boolean { return _isMouseOver; };
		public function set isMouseOver(value:Boolean):void { 
			_isMouseOver = value;
			
			if (value) {
				mc.hotSpot.removeEventListener(MouseEvent.MOUSE_OVER , onMouseOver);
				
				mc.hotSpot.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				mc.hotSpot.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				
				//show detail content
				dispatchEvent(new TimeScalerEvent(TimeScalerEvent.VIEW_EVENT_DETAILS));
			} else {
				_isMouseButtonDown = false;
				
				mc.hotSpot.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				mc.hotSpot.addEventListener(MouseEvent.MOUSE_OVER , onMouseOver);
			}
			
			updateDisplay();
		}

		
		protected function onMouseOver(event:MouseEvent):void {
			_isMouseButtonDown = event.buttonDown;
			isMouseOver = true;
		}
		
		
		protected function onMouseOut(event:MouseEvent):void {
			isMouseOver = false;
		}
		
		
		private var _isMouseButtonDown:Boolean;
		
		protected function onMouseDown(event:MouseEvent):void {
			if (!data.enabled) return;
			_isMouseButtonDown = true;
			_isDragging = false;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, drag);
			stage.addEventListener(Event.MOUSE_LEAVE, stopDragging);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseClick);
		}
		
		
		protected function onMouseClick(event:MouseEvent):void 
		{
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseClick);
			
			if (!data.enabled) return;
			
			_isMouseButtonDown = false;
			
			if (data.isOnTimeline && !data.isSelected && !_isDragging) {
				dispatchEvent(new TimeScalerEvent(TimeScalerEvent.SELECT_EVENT));
			} else if (data.isOnTimeline && data.isSelected) {
				dispatchEvent(new TimeScalerEvent(TimeScalerEvent.DESELECT_EVENT));
			}
			
			stopDragging();
		}
		
		
		private var _isDragging:Boolean;
		public function get isDragging():Boolean { return _isDragging; }; 
		
		protected function drag(event:MouseEvent):void {
			if (!_isDragging) {
				startDrag();
				dispatchEvent(new TimeScalerEvent(TimeScalerEvent.START_DRAG));
				_isDragging = true;
			}
			
			if (data.isSelected) {
				dispatchEvent(new TimeScalerEvent(TimeScalerEvent.DESELECT_EVENT));
			}
			
			var realCoord:Number = Math.round(x / tsModel.scaleFactor + tsModel.presentZoomBegin);
			data.userDate = Math.round(realCoord / tsModel.timelineSmallScale) * tsModel.timelineSmallScale;
			
			updateDisplay();
		}
		
		
		private var _justDragged:Boolean;
		protected function stopDragging(event:Event = null):void 
		{
			trace("stopDragging()");
			stopDrag();
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, drag);
			stage.removeEventListener(Event.MOUSE_LEAVE, stopDragging);
			
			_isDragging = false;
			
			dispatchEvent(new TimeScalerEvent(TimeScalerEvent.STOP_DRAG, true));
		}
		
		
		private function scaleUp():void {
			mc.scaleX = mc.scaleY = 1.2;
		}
		private function scaleDown():void {
			mc.scaleX = mc.scaleY = 1;
		}
		
		
		private function createIcon():void {
			if (mc.icon == null) {
				mc.icon = TimeScalerFactory.newIcon(data.name);
				mc.icon.mouseEnabled = false;
				mc.icon.x = mc.thumbMask.x;
				mc.icon.y = mc.thumbMask.y;
				mc.icon.height = mc.thumbMask.height + 2;
				mc.icon.width  = mc.thumbMask.width + 2;
				mc.addChild(mc.icon);
			}
		}		
		
		
		private var _iconMode:Boolean;
		public function switchView(showIconMode:Boolean):void {
			if (_iconMode == showIconMode) return;
			
			_iconMode = showIconMode
			
			if (_iconMode) {
				if (tsModel && tsModel.stage !== null) {
					x = tsModel.stage.mouseX;
					y = tsModel.stage.mouseY;
				}
				
				mc.gotoAndStop("compact");
				mc.hotSpot.gotoAndStop(2);
				mc.icon.x = mc.thumbMask.x;
				mc.icon.y = mc.thumbMask.y;
				mc.thumbBG.visible = false;
				scaleUp();
				
			} else {
				mc.gotoAndStop("stasis");
				mc.hotSpot.gotoAndStop(1);
				mc.icon.x = mc.thumbMask.x;
				mc.icon.y = mc.thumbMask.y;
				mc.thumbBG.visible = true;
				mc.field1x.visible = true;
				scaleDown();
				
				filters = [];
			}
		}
		
		
		private function updateYearsText(showCorrect:Boolean=false):void {
			var formatter:NumberFormatter = TimeScalerFactory.newCommaNumberFormatter();
			
			var date:Number = showCorrect ? data.date : data.userDate;
			
			if (date >= 0) {
				mc.field2x.text = formatter.format(Math.abs(Math.round(date))) + " years from now";
				//mc.field2x.text = Math.abs(Math.round(date)) + " years from now";
			} else {
				mc.field2x.text = formatter.format(Math.abs(Math.round(date))) + " years ago";
				//mc.field2x.text = Math.abs(Math.round(date)) + " years ago";
			}
		}
		
		
		private var _data:TimelineEventObject;
		public function get data():TimelineEventObject { return _data; }
		public function set data(value:TimelineEventObject):void
		{
			if (_data == null) {
				_data = value;
				init();
			} else {
				_data = value;
			}
			
			_data.addEventListener(Event.CHANGE, updateDisplay);
		}
	}
}