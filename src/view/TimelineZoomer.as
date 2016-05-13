package view
{
	import events.TimeScalerEvent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import gs.TweenLite;
	
	import model.TimeScalerModel;

	public class TimelineZoomer extends EventDispatcher
	{
		private var tsModel:TimeScalerModel;
		private var scaleBar:MovieClip;
		private var scaleBarHotspot:MovieClip;
		private var stage:DisplayObject;
		
		public var lasso:Sprite;
		public var drawLassoBegin:Number;
		public var drawLassoEnd:Number;
		public var lassoSize:Number;
		
		
		public function TimelineZoomer(scaleBar:MovieClip, scaleBarHotspot:MovieClip, timeScalerModel:TimeScalerModel) {
			this.scaleBarHotspot = scaleBarHotspot;
			this.scaleBar = scaleBar;
			this.tsModel = timeScalerModel;
			
			if (scaleBarHotspot.stage == null) {
				scaleBarHotspot.addEventListener(Event.ADDED_TO_STAGE, init);
			}
			else {
				init();
			}
		}
		
		
		public function init(event:Event=null):void {
			scaleBarHotspot.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage = scaleBarHotspot.stage;
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			
			scaleBarHotspot.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
			
			lasso = new Sprite();
			lasso.alpha = .5;
			lasso.graphics.lineStyle(1);
		}

		
		private var _disabled:Boolean;
		public function set disabled(value:Boolean):void {
			if (_disabled == value) return;
			_disabled = value;
			
			if (_disabled) {
				stopZoom();
				scaleBarHotspot.removeEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
			} else {
				scaleBarHotspot.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
			}
		}
		
		//---------- Drawing the zoom lasso ----------//
		

		public function beginDrag(event:MouseEvent):void {
			drawLassoBegin = scaleBarHotspot.mouseX;
			
			scaleBar.addChild(lasso);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, drawScaleExtent);
		}
		
		
		public function drawScaleExtent(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP , lockRetrieveNewScale);
			lassoSize = Math.abs(scaleBarHotspot.mouseX - drawLassoBegin);
			
			if (scaleBarHotspot.mouseX > drawLassoBegin) {
				lasso.graphics.clear();
				lasso.graphics.beginFill(0xFF0000, .5);
				lasso.graphics.drawRect(drawLassoBegin, 0, scaleBarHotspot.mouseX - drawLassoBegin, scaleBar.height);
				lasso.graphics.endFill();
			} 
			else {
				lasso.graphics.clear();
				lasso.graphics.beginFill(0x0000FF, .5);
				lasso.graphics.drawRect(drawLassoBegin, 0, scaleBarHotspot.mouseX - drawLassoBegin, scaleBar.height);
				lasso.graphics.endFill();
				TweenLite.killTweensOf(this);
				zoomOut(lassoSize);
			}
			
			if (scaleBarHotspot.mouseX < 25 || scaleBarHotspot.mouseX > scaleBarHotspot.width - 25) {
				stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
			}
		}
		
		
		public function lockRetrieveNewScale(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, drawScaleExtent);
			stage.removeEventListener(MouseEvent.MOUSE_UP, lockRetrieveNewScale);
			
			lasso.graphics.clear();
			
			if (drawLassoBegin < scaleBarHotspot.mouseX)	{
				drawLassoEnd = scaleBarHotspot.mouseX;
				beginZoom(drawLassoBegin, drawLassoBegin + lassoSize);
				drawLassoBegin = scaleBarHotspot.mouseX;
			}	
		}
		
		
		/**
		 * If we were in the middle of a zoom, and the mouse left the screen and the button
		 * was released, kill the zoom.
		 */
		public function onMouseLeave(event:Event):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE , drawScaleExtent);
			stage.removeEventListener(MouseEvent.MOUSE_UP , lockRetrieveNewScale);
			
			stopZoom();
			lasso.graphics.clear();
		}
		
		
		public function stopZoom():void {
			TweenLite.killTweensOf(tsModel);
		}
		
		public function zoomDirect(left:Number, right:Number, duration:int=2):void {
			stopZoom();
			
			TweenLite.to(tsModel, duration, {presentZoomBegin:left, presentZoomEnd:right, onUpdate:applyZoom});
		}
		
		
		private function applyZoom():void {
			dispatchEvent(new TimeScalerEvent(TimeScalerEvent.RENDER_TIMELINE));
		}
		
		
		private var zoomAccelerator:Number = 0;
		private function zoomOut (lassoSize:Number, duration:Number=1):void {
			stopZoom();
			zoomAccelerator = lassoSize / tsModel.scaleFactor;
			if (lassoSize > 0) {
				TweenLite.to(tsModel, duration, {presentZoomBegin: tsModel.presentZoomBegin - zoomAccelerator, presentZoomEnd: tsModel.presentZoomEnd + zoomAccelerator, onUpdate: applyZoom});
			}
		}
		
		private function beginZoom(drawLassoBegin:Number, drawLassoEnd:Number, zoomDuration:Number=2):void {
			stopZoom();
			
			var newZoomBegin:Number = Math.round(drawLassoBegin / tsModel.scaleFactor + tsModel.presentZoomBegin) ;
			var newZoomEnd:Number = Math.round(drawLassoEnd / tsModel.scaleFactor + tsModel.presentZoomBegin);
			
			if ((newZoomEnd - newZoomBegin) > 100) {
				//	trace("normal zoom")
				TweenLite.to(tsModel, zoomDuration, {presentZoomBegin: newZoomBegin, presentZoomEnd: newZoomEnd, onUpdate: applyZoom} );
			}	
			else {
				//	trace("constrained zoom")
				var rightside:Number = newZoomBegin +100;
				TweenLite.to(tsModel, zoomDuration, {presentZoomBegin: newZoomBegin, presentZoomEnd: rightside, onUpdate: applyZoom} );
			}
		}
	}
}