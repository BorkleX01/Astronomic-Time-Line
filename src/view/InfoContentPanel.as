package view
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	public class InfoContentPanel extends MovieClip
	{
		public var imgLoc:String;
		public var infoTitle:String;
		public var linkText:String;
		public var textBody:String;
		public var index:int;
		
		public var requestX:URLRequest;
		public var loaderX:Loader;
		public var image:Bitmap;
		
		private var mc:InfoContentAsset;
		
		public function InfoContentPanel(index:int , infoTitle:String,  textBody:String, linkText:String, imgURL:String) 
		{
			super();
			
			this.mc = new InfoContentAsset();
			addChild(mc);
			
			//trace("info Content: "+index);
			this.index = index;
			this.imgLoc = imgLoc;
			this.textBody = textBody;
			this.index = index;
			this.infoTitle = infoTitle;
			this.linkText = linkText;
			//this.alpha = 0;
			
			requestX = new URLRequest(imgURL);
			loaderX = new Loader();
			
			loaderX.contentLoaderInfo.addEventListener(Event.COMPLETE, imgLoaded);
			loaderX.load(requestX);
		}
		
		
		public function imgLoaded(e:Event):void
		{
			var contentWidth:int = 595;
			
			//trace("info panel: "+e.currentTarget);
			image = Bitmap(loaderX.content);
			mc.addChild(image);
			image.x = contentWidth - image.width;
			
			mc.titleTF.text = infoTitle;
			mc.titleTF.x = 0;//image.width + 5;
			
			mc.descriptionParagraph.text = textBody;
			mc.descriptionParagraph.x = 0;//image.width + 5;
			
			mc.linkBtn.linkURL = linkText;
			mc.linkBtn.useHandCursor = true;
			mc.linkBtn.buttonMode = true;
			mc.linkBtn.addEventListener(MouseEvent.CLICK, onMouseClick);
			
			if (linkText != '' && linkText != 'none' && linkText != '\n') {
				mc.linkBtn.linkTF.text = "Read more here";
			} else {
				//trace('failed:', infoTitle);
				mc.linkBtn.linkTF.text = "";
			}
			
			mc.linkBtn.x = 0;//image.width + 5;
			
			
			mc.descriptionParagraph.width = mc.titleTF.width = mc.linkBtn.width = mc.linkBtn.linkTF.width = contentWidth - image.width - 10;
		}
		
		protected function onMouseClick(event:MouseEvent):void {
			if (linkText && linkText.length > 0) {
				navigateToURL(new URLRequest(linkText), "_blank");
			}
			
		}
	}
}