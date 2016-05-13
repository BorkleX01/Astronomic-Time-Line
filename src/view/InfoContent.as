package view
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import model.TimeScalerModel;
	import model.TimelineEventObject;
	
	public class InfoContent
	{
		private var timeScalerModel:TimeScalerModel;
		private var mc:MovieClip;
	
		private var infoContentArray:Array;
		
		public function InfoContent(viewAsset:MovieClip, model:TimeScalerModel)
		{
			super();
			
			mc = viewAsset;
			timeScalerModel = model;
			init();
		}
		
		
		private function init():void {
			infoContentArray = [];
			
			for each (var eventObject:TimelineEventObject in timeScalerModel.timelineEvents) {
				infoContentArray.push(
					new InfoContentPanel(
						eventObject.index,
						eventObject.name,
						eventObject.description,
						eventObject.linkURL,
						timeScalerModel.imageURL + '/' + eventObject.imagePath)
				);
			}
			
			updateDisplay();
		}
		
		
		private var currentHighlightedEvent:TimelineEventObject;
		public function updateDisplay():void {
			if (timeScalerModel.highlightedTimelineEvent != currentHighlightedEvent) {
				while (mc.numChildren > 0) mc.removeChildAt(0);
				
				if (timeScalerModel.highlightedTimelineEvent != null) {
					var infoMC:InfoContentPanel = infoContentArray[timeScalerModel.highlightedTimelineEvent.index];
					
					mc.addChild(infoMC);
				}
			}
		}
	}
}