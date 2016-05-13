package view
{
	import events.TimeScalerEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import gs.TweenLite;
	
	import model.TimeScalerModel;
	import model.TimelineEventObject;
	
	public class ScrollList
	{
		private var scrollerBar:ScrollerBar;
		private var scrollBarMC:MovieClip;
		private var scrollPanelMC:MovieClip;
		private var timeScalerModel:TimeScalerModel;
		private var timelineEventViews:Array
		
		public function ScrollList(scrollBarMC:MovieClip, scrollPanelMC:MovieClip, timeScalerModel:TimeScalerModel, views:Array) {
			super();
			
			this.scrollBarMC = scrollBarMC;
			this.scrollPanelMC = scrollPanelMC;
			this.timeScalerModel = timeScalerModel;
			this.timelineEventViews = views;
			
			init();
		}
		
		
		public function init():void {
			scrollerBar = new ScrollerBar(scrollBarMC);
			
			//update scroller bar
			scrollerBar.initView(scrollPanelMC);
			
			updateDisplay();
		}
		
		
		public function updateDisplay():void {
			if (timeScalerModel.filteredTimelineEvents == null) return;
			
			//clear scroll list (no longer needed)
			//while (scrollPanelMC.scrollBelt.numChildren > 0) scrollPanelMC.scrollBelt.removeChildAt(0);
			
			var displayedCount:int = 0;
			
			//update scroll list and add to the current list if relevant
			for each (var eView:TimelineEventView in timelineEventViews) {
				if (!eView.data.includeInView) {
					if (scrollPanelMC.scrollBelt.contains(eView)) {
						scrollPanelMC.scrollBelt.removeChild(eView);
					}
					continue;
				}
				
				if (eView.data.isOnTimeline || eView.isDragging) continue;
				
				eView.visible = true;
				eView.x = 120;
				
				var newY:int = displayedCount++ * 65 + 30; 
				
				if (eView.y != newY && scrollPanelMC.scrollBelt.contains(eView)) {
					TweenLite.to(eView, 0.1, {y: newY});
				} else {
					eView.y = newY;
					scrollPanelMC.scrollBelt.addChild(eView);
				}
			}
			
			scrollerBar.updateDimensions();
			
			timeScalerModel.filteredEventsChanged = false;
		}
	}
}