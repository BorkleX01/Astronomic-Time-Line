package view
{
	import com.adaptiveelearning.utils.CallLaterUtil;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import model.TimeScalerModel;
	import model.TimelineEventObject;
	
	import util.BignumFormat;
	
	public class TimelineView extends EventDispatcher
	{
		private var scaleBar:MovieClip;
		private var scaleBarHotspot:MovieClip;
		private var tsModel:TimeScalerModel;
		private var timelineEventViews:Array;
		
		public function TimelineView(scaleBar:MovieClip, scaleBarHotspot:MovieClip, timeScalerModel:TimeScalerModel, views:Array) {
			this.scaleBar = scaleBar;
			this.scaleBarHotspot = scaleBarHotspot;
			this.tsModel = timeScalerModel;
			this.timelineEventViews = views;
			
			if (scaleBar.stage == null) {
				scaleBar.addEventListener(Event.ADDED_TO_STAGE, init);
			} else {
				init();
			}
		}
		
		
		public function updateDisplay():void {
			//redraw timeline scale, add events to timeline, draw markers etc. 
			
			commitBarRender();
			//trace("bar rendered");
			
			var numEvents:int = tsModel.timelineEvents.length;
			for (var i:int=0; i < numEvents; i++) {
				var timelineEventObject:TimelineEventObject = tsModel.timelineEvents[i] as TimelineEventObject;
				var timelineEventView:TimelineEventView = timelineEventViews[i] as TimelineEventView;
				
				if (!timelineEventObject.isOnTimeline) 
				{
					timelineEventView.alpha = 1;
					continue;
				}
				
				var date:Number = timelineEventObject.forceCorrect ? timelineEventObject.date : timelineEventObject.userDate;
				//trace("* thumbX management: ")
				if (timelineEventObject.includeInView
						&& date > tsModel.presentZoomBegin
						&& date < tsModel.presentZoomEnd) 
				{
					
					//event is not filtered, placed on the timeline, and is visible in the current range
					timelineEventView.x = scaleBar.x + tsModel.scaleFactor * (date - tsModel.presentZoomBegin);
					timelineEventView.y = scaleBar.y - 28;
					timelineEventView.alpha = 1;
					//trace(timelineEventObject.name + " is within present zoom , place thumbX. x=" + timelineEventView.x);
				} 
				else 
				{
					//event is not within the timline bounds or not included in the event filter
					
					timelineEventView.alpha = 0;
					timelineEventView.x = scaleBar.x + tsModel.scaleFactor * (date - tsModel.presentZoomBegin);
					timelineEventView.y = scaleBar.y - 28;
					//trace(timelineEventObject.name + " * is outside present zoom , thumbX invisible. x=" + + timelineEventView.x);
				}
				//trace("isOnTimeline: "+ timelineEventObject.isOnTimeline);
				//trace("isPlaced: "+ timelineEventObject.isPlaced);
			}
			
		}
		
		private var callLaterUtil:CallLaterUtil;
		private var _rendering:Boolean = false;
		public function renderBar():void {
			_rendering = true;
			
			callLaterUtil.doLater(this, updateDisplay, null);
		}

		
		public var largeScale:Number;
		public var medScale:Number;
		public var smallScale:Number;

		private var barWidth:Number;
		private var barHeight:Number;
		private var presentExtent:Number;
		private var newExtent:Number;
		private var smallestReprestableSlice:Number;
		private var bigLine:Sprite = new Sprite();
		private var medLine:Sprite = new Sprite();
		private var smallLine:Sprite = new Sprite();
		private var smallPassRegister:Number;
		private var medPassRegister:Number; 
		private var bigPassRegister:Number; 
		private var smallScaleAccumulator:Number = 0;
		private var lineSpace:Number;
		private var renderBegin:Number;
		private var renderBegin1:Number;
		private var renderBegin2:Number;
		private var presentMidpoint:Number;
		private var newMidpoint:Number;
		private var presentOrderOfMag:Number;
		
		private var textFormatter:TextFormat;
		private var bigNumFormatter:BignumFormat;
		
		
		private function commitBarRender():void {
			//trace("beginning bar render");
			
			presentExtent = tsModel.presentZoomEnd - tsModel.presentZoomBegin;
			
			tsModel.scaleFactor = barWidth / presentExtent;
			presentExtent = Math.abs(tsModel.presentZoomEnd - tsModel.presentZoomBegin);

			detectOrderOfMag(presentExtent);

			largeScale = 1 * Math.pow(10, presentOrderOfMag - 1);
			medScale = largeScale / 10;
			smallScale = medScale / 10;
			
			tsModel.timelineMedScale = medScale;
			tsModel.timelineSmallScale = smallScale;
			
			smallScaleAccumulator = smallScale;

			calculateRenderBegin();
			function calculateRenderBegin():void {
				var reg02a:Number=Math.floor(tsModel.presentZoomBegin / largeScale);
				var reg02b:Number=Math.floor(tsModel.presentZoomBegin / medScale);
				var reg02c:Number=Math.floor(tsModel.presentZoomBegin / smallScale);

				renderBegin=((reg02c * smallScale) - tsModel.presentZoomBegin) * tsModel.scaleFactor;
				//trace("renderBegin: "+renderBegin);
				renderBegin1=((reg02b * medScale) - tsModel.presentZoomBegin) * tsModel.scaleFactor;
				renderBegin2=((reg02a * largeScale) - tsModel.presentZoomBegin) * tsModel.scaleFactor;
			}

			lineSpace = (smallScale / presentExtent) * barWidth;

			smallPassRegister = renderBegin;
			//trace("freeze issue smallPassRegister2: " + smallPassRegister);
			medPassRegister = renderBegin1;
			bigPassRegister = renderBegin2;

			clearLines();
			
			if (bigLine.numChildren > 0) {
				for (var i:int=bigLine.numChildren - 1; i >= 0; i--) {
					bigLine.removeChildAt(i);
				}
			}

			while (smallPassRegister < barWidth) {
				smallLine.graphics.moveTo(smallPassRegister, barHeight - barHeight / 3);
				smallLine.graphics.lineTo(smallPassRegister, barHeight);

				smallPassRegister=smallPassRegister + lineSpace;

				if (medPassRegister < barWidth) {

					medLine.graphics.moveTo(medPassRegister, barHeight - 0);
					medLine.graphics.lineTo(medPassRegister, barHeight - barHeight);
					medPassRegister=medPassRegister + lineSpace * 10;


					var postionIndicator:TextField=new TextField();
					if (presentExtent < 2 * largeScale) {
						postionIndicator.text= bigNumFormatter.format((Math.round(medPassRegister / tsModel.scaleFactor + tsModel.presentZoomBegin)), largeScale, presentExtent);

						postionIndicator.y=barHeight / +2;
						postionIndicator.x=medPassRegister;
						postionIndicator.selectable=false;
						postionIndicator.width=postionIndicator.textWidth + 8;
						postionIndicator.height=postionIndicator.textHeight + 5;

						medLine.addChild(postionIndicator);
						postionIndicator.setTextFormat(textFormatter);
						postionIndicator.alpha=0.5 - 1 / ((Math.pow(10, presentOrderOfMag) / presentExtent));
					}

				}

				if (bigPassRegister < barWidth) {
					bigLine.graphics.moveTo(bigPassRegister, barHeight - 0);
					bigLine.graphics.lineTo(bigPassRegister, barHeight - barHeight);


					var postionIndicatorM:TextField=new TextField();

					postionIndicatorM.text=bigNumFormatter.format((Math.round(bigPassRegister / tsModel.scaleFactor + tsModel.presentZoomBegin)), largeScale, presentExtent);
					//postionIndicatorM.appendText(" "+largeScale);
					postionIndicatorM.y=barHeight / 2;
					postionIndicatorM.x=bigPassRegister;
					postionIndicatorM.selectable=false;
					postionIndicatorM.width=postionIndicatorM.textWidth + 8;
					postionIndicatorM.height=postionIndicatorM.textHeight + 5;
					bigLine.addChild(postionIndicatorM);

					postionIndicatorM.setTextFormat(textFormatter);

					bigPassRegister=bigPassRegister + lineSpace * 100;
				}
			}
		}
		
		
		
		private function clearLines():void {
			smallLine.graphics.clear();
			medLine.graphics.clear();
			bigLine.graphics.clear();
			
			scaleBar.addChild(smallLine);
			scaleBar.addChild(medLine);
			scaleBar.addChild(bigLine);
			
			if (medLine.numChildren > 0)
			{
				for (var i:int = medLine.numChildren-1 ; i >=0  ; i--)
					medLine.removeChildAt(i);
			}
			
			if (bigLine.numChildren > 0)
			{
				for (var j:int = bigLine.numChildren-1 ; j >0 ; j--)
					bigLine.removeChildAt(j); 
			}
			
			smallLine.graphics.lineStyle(.25,0xFFFFFF , .5-1/(( Math.pow(10, presentOrderOfMag )/presentExtent/3)));
			medLine.graphics.lineStyle(.25,0xFFFFFF , .5-1/(( Math.pow(10, presentOrderOfMag )*2/presentExtent)));
			bigLine.graphics.lineStyle(.25,0xFFFFFF , 1-1/(( Math.pow(10, presentOrderOfMag )*2/presentExtent)));
		}
		
		
		private function detectOrderOfMag(num:Number):void {
			presentOrderOfMag = String(num.toFixed()).length;
		}
		
		
		
		/**
		 * Initialise
		 */
		private function init(event:Event=null):void {
			scaleBar.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			callLaterUtil = new CallLaterUtil(scaleBar.stage);
			
			barWidth = scaleBar.width;
			barHeight = scaleBar.height;
			
			presentExtent = Math.abs(tsModel.presentZoomEnd - tsModel.presentZoomBegin);
			presentMidpoint = presentExtent / 2;
			
			scaleBar.addChild(smallLine);
			scaleBar.addChild(medLine);
			scaleBar.addChild(bigLine);
			
			tsModel.scaleFactor = barWidth / presentExtent;
				
			smallLine.graphics.lineStyle(.25,0xFFFFFF);
			medLine.graphics.lineStyle(.25,0xFFFFFF);
			bigLine.graphics.lineStyle(.25,0xFFFFFF);
			
			textFormatter = new TextFormat("_sans" , 9 , 0xFFFFFF);
			textFormatter.size = 11;
			
			bigNumFormatter = new BignumFormat();
		}
	}
}