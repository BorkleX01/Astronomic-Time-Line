package view {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import gs.TweenLite;

	/**
	 * ...
	 * @author Eugene Phang
	 */
	public class ScrollerBar extends MovieClip {
		public var upperY:int;
		public var scrollLimitY:int;
		private var scrollPanel:MovieClip

		public var mc:MovieClip;


		public function ScrollerBar(mc:MovieClip) {
			super();

			//trace("Scroller Bar");
			this.mc=mc;
		}


		public function initView(scrollPanel:MovieClip):void {
			//trace("scrollBeltHeight: " + scrollPanel.scrollBelt.height);
			//trace("scrolBarHeight: " + scrollLimit.height);
			this.scrollPanel=scrollPanel;
			mc.scrollWidget.buttonMode=true;
			mc.scrollWidget.userHandCursor=true;
			mc.scrollWidget.mouseChildren=false;
			mc.scrollWidget.addEventListener(MouseEvent.MOUSE_DOWN, down);
			
			updateDimensions();
		}
		
		
		public function updateDimensions():void {
			if (scrollPanel != null) {
				
				upperY = scrollPanel.scrollBelt.height - mc.scrollLimit.height + 120;
				scrollLimitY = mc.scrollLimit.height - mc.scrollWidget.height / 2;
				
				mc.scrollWidget.visible = upperY > 120;
			}
		}


		public function down(e:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_DOWN, down);
			mc.stage.addEventListener(MouseEvent.MOUSE_UP, up)
			mc.stage.addEventListener(MouseEvent.MOUSE_MOVE, affectPanel);
			mc.scrollWidget.startDrag(false, new Rectangle(mc.scrollLimit.x - 3, mc.scrollLimit.y, 0, mc.scrollLimit.height - mc.scrollWidget.height))
		}


		public function up(e:MouseEvent):void {
			mc.stage.removeEventListener(MouseEvent.MOUSE_UP, up);
			mc.stage.removeEventListener(MouseEvent.MOUSE_MOVE, affectPanel);
			mc.scrollWidget.stopDrag();
			mc.scrollWidget.addEventListener(MouseEvent.MOUSE_DOWN, down);

		}


		public function affectPanel(e:MouseEvent):void {
			//scrollPanel.scrollBelt.y = 0 - (scrollWidget.y / scrollLimitY) * upperY;
			TweenLite.to(scrollPanel.scrollBelt, .4, {y: 0 - (mc.scrollWidget.y / scrollLimitY) * upperY})
		}
	}
}
