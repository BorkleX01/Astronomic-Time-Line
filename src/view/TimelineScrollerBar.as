package view {
	import events.TimeScalerEvent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import model.TimeScalerModel;

	/**
	 * ...
	 * @author Eugene Phang
	 */
	public class TimelineScrollerBar extends EventDispatcher {
		public var dragRect01:Rectangle=new Rectangle();
		public var scrollCenter:Number;
		public var dragRectLoc:Number;

		private var mc:MovieClip;
		private var timeScrollWidget:MovieClip;
		private var stage:DisplayObject;

		private var tsModel:TimeScalerModel;


		public function TimelineScrollerBar(timeScrollerBar:MovieClip, model:TimeScalerModel) {
			mc=timeScrollerBar;
			timeScrollWidget=timeScrollerBar.timeScrollWidget;
			tsModel=model;
			
			if (mc.stage == null) {
				mc.addEventListener(Event.ADDED_TO_STAGE, init);
			}
			else {			
				init();
			}
		}

		private function init(event:Event=null):void {
			mc.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage=mc.stage;

			dragRect01.x=timeScrollWidget.x;
			dragRect01.y=timeScrollWidget.y;
			dragRect01.width=mc.width - timeScrollWidget.width - 6;
			dragRect01.height=0;
			timeScrollWidget.x=mc.width / 2 - timeScrollWidget.width / 2;
			scrollCenter=mc.width / 2 - timeScrollWidget.width / 2;

			timeScrollWidget.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}

		
		private var _disabled:Boolean;
		public function set disabled(value:Boolean):void {
			if (_disabled == value) return;
			_disabled = value;
			
			mc.visible = !_disabled;
		}

		private function mouseDown(e:MouseEvent):void {
			e.currentTarget.startDrag(false, dragRect01);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			stage.addEventListener(Event.ENTER_FRAME, onPressing);
		}


		private function mouseUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			stage.removeEventListener(Event.ENTER_FRAME, onPressing);
			timeScrollWidget.stopDrag();
			timeScrollWidget.x=scrollCenter;
		}


		private function onPressing(e:Event):void {
			dragRectLoc=((timeScrollWidget.x - scrollCenter) / (dragRect01.width));

			tsModel.presentZoomBegin+=dragRectLoc * tsModel.timelineMedScale;
			tsModel.presentZoomEnd+=dragRectLoc * tsModel.timelineMedScale;

			dispatchEvent(new TimeScalerEvent(TimeScalerEvent.RENDER_TIMELINE));
		}
	}
}
