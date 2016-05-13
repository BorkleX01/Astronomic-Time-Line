package view
{
	import events.TimeScalerEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import model.TimeScalerFactory;
	import model.TimeScalerModel;
	
	import mx.formatters.NumberFormatter;
	
	
	
	/**
	 * ...
	 * @author Eugene Phang
	 */
	public class SystemMarker extends MovieClip
	{
		public static const OFF_TIMELINE_LEFT:String = "offTimelineLeft";
		public static const OFF_TIMELINE_RIGHT:String = "offTimelineRight";
		public static const ON_TIMELINE:String = "onTimeline";
		
		public var state:String;
		
		private var icon:MovieClip;
		private var toolTip:MovieClip;
		private var indicator:MovieClip;
		
		private var tsModel:TimeScalerModel;
		
		public var discrepancyLine:Sprite;
		public var eventView:TimelineEventView;
		
		
		public function SystemMarker(eventView:TimelineEventView, timeScalerModel:TimeScalerModel) 
		{
			this.eventView = eventView;
			this.tsModel = timeScalerModel;
			
			init();
		}
		
		
		private function init():void 
		{
			//trace("new system marker ");
			var mc:MovieClip = new SystemMarkerAsset();
			addChild(mc);
			
			discrepancyLine = new Sprite();
			discrepancyLine.alpha = 1;
			addChild(discrepancyLine);
			
			icon = TimeScalerFactory.newIcon(eventView.data.name);
			icon.width = 34
			icon.height = 34;
			icon.x = -16;
			icon.y = 4;
			
			toolTip = mc.revelation;
			toolTip.addChild(icon);
			
			indicator = mc.indicator;
			indicator.addEventListener(MouseEvent.CLICK, onClick);
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			
			eventView.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			eventView.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			eventView.addEventListener(MouseEvent.MOUSE_DOWN, updateDisplay);
			
			hideToolTip();
		}
		
		
		/**
		 * Render the discrepancy line that goes from the red arrow to the green arrow.
		 * If the mouse is over the thumb, it should be a white line.
		 * If the thumb is selected, it should be a green line.
		 * Otherwise, it should be a thin grey line.
		 */
		public function updateDisplay(event:Event = null):void 
		{
			
			if (!eventView.data.isOnTimeline || !eventView.data.includeInView) 
			{
				visible = false;
				return;
			} 
			else 
			{
				visible = true;
			}
			
			//hide line whilst drawing
			discrepancyLine.alpha = 0;
			discrepancyLine.graphics.clear();
			
			if (eventView.data.isSelected) {
				showTooltip();
				discrepancyLine.graphics.lineStyle(2, 0x00FF00);
			} else if (eventView.isMouseOver) {
				showTooltip();
				discrepancyLine.graphics.lineStyle(2, 0xFFFFFF);
			} else {
				hideToolTip();
				discrepancyLine.graphics.lineStyle(1, 0x666666);
			}
			
			
			//this is to ensure that when the user marker is not on the current time 
			// scale, the discrepency line is drawn to continue off the screen
			var lineAdjust:int = 0;
			var dateOnTimeline:Number;
			dateOnTimeline = (eventView.data.forceCorrect ? eventView.data.date : eventView.data.userDate);
			if (dateOnTimeline < tsModel.presentZoomBegin) {
				lineAdjust = -100;
			} else if (dateOnTimeline > tsModel.presentZoomEnd) {
				lineAdjust = 100;
			}
			
			//trace("draw line to join markers: " + eventView.data.name + " x= " + eventView.x);
			switch (state) 
			{
				case OFF_TIMELINE_LEFT:
					x = -50;
					toolTip.x = 80;
					
					discrepancyLine.graphics.moveTo(0, 0);
					discrepancyLine.graphics.lineTo(0, -tsModel.scaleBarHeight / 2);
					discrepancyLine.graphics.lineTo(lineAdjust + eventView.x - x, -tsModel.scaleBarHeight / 2);
					// 1.3 is a minor adjustment to get the line to touch the bottom of the userMarker
					discrepancyLine.graphics.lineTo(lineAdjust + eventView.x - x, -tsModel.scaleBarHeight / 1.3);
					discrepancyLine.graphics.moveTo(0, 0);
					break;
				case OFF_TIMELINE_RIGHT:
					x = 1050;
					toolTip.x = -280;
					
					discrepancyLine.graphics.moveTo(0, 0);
					discrepancyLine.graphics.lineTo(0, -tsModel.scaleBarHeight / 2);
					discrepancyLine.graphics.lineTo(lineAdjust + eventView.x - x, -tsModel.scaleBarHeight / 2);
					discrepancyLine.graphics.lineTo(lineAdjust + eventView.x - x, -tsModel.scaleBarHeight);
					discrepancyLine.graphics.moveTo(0, 0);
					break;
				default:
					toolTip.x = -75;
					
					discrepancyLine.graphics.lineTo(0, -tsModel.scaleBarHeight / 2);
					discrepancyLine.graphics.lineTo(lineAdjust + eventView.x - x, -tsModel.scaleBarHeight / 2);
					discrepancyLine.graphics.lineTo(lineAdjust + eventView.x - x, -tsModel.scaleBarHeight);
					discrepancyLine.graphics.moveTo(0, 0);
			}
			
			discrepancyLine.alpha = 1;
		}
		
		
		public function get date():Number {
			return eventView.data.date;
		}
		
		private function hideToolTip():void { 
			toolTip.visible = false;
		}
		
		private function showTooltip():void 
		{
			
			//trace("showTooltip(): " + formatter) 
			//truncate the string if too large for text box
			toolTip.title.text = (eventView.data.name.length < 30 ? eventView.data.name : eventView.data.name.substr(0, 30) + '...');
			
			var formatter:NumberFormatter = TimeScalerFactory.newCommaNumberFormatter();  
			var formatter2:NumberFormatter = new NumberFormatter();  
			
			//trace("showTooltip(): " + eventView.data.date + " f: " + formatter.format(Math.abs(Math.round(eventView.data.date))));
			//trace("showTooltip(): " + eventView.data.date + " f1: " + Math.abs(Math.round(eventView.data.date)));
			//trace("showTooltip(): " + eventView.data.date + " f2: " + formatter2.format(Math.abs(Math.round(eventView.data.date))));
			
			if (eventView.data.date >= 0) 
			{
				toolTip.field.text = formatter.format(Math.abs(Math.round(eventView.data.date))) + " years from now";
				//toolTip.field.text = Math.abs(Math.round(eventView.data.date)) + " years from now";
			} else {
				toolTip.field.text = formatter.format(Math.abs(Math.round(eventView.data.date))) + " years ago";
				//toolTip.field.text = Math.abs(Math.round(eventView.data.date)) + " years ago";
			}
			
			toolTip.visible = true;
		}
			
	
		private function onMouseOver(event:MouseEvent):void {
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			eventView.isMouseOver = true;
			
			updateDisplay();
		}
		
		
		private function onMouseOut(event:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			eventView.isMouseOver = false;
			
			updateDisplay();
		}
		
		
		private function onClick(event:MouseEvent):void {
			if (eventView.data.enabled) {
				eventView.dispatchEvent(new TimeScalerEvent(TimeScalerEvent.SELECT_EVENT));
			}
		}
		
		
		public function destroy():void {
			removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			indicator.removeEventListener(MouseEvent.CLICK, onClick);
			
			eventView.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			eventView.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			eventView = null;
		}
	}
}