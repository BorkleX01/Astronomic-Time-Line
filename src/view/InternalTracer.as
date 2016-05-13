package view
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	public class InternalTracer extends MovieClip
	{
		
		public function InternalTracer(mc:MovieClip) 
		{
			tracerLoc = mc.tracerText;
			tracerLoc.text = this.name;
			
		}
		
		public function traceX(obj:Object)
		{
			tracerLoc.text += "\n";
			tracerLoc.text += this.name + ": " + String(obj); 
		}
		public static function traceY(obj:Object)
		{
			tracerLoc.text += "\n";
			tracerLoc.text += "static tracer: " + String(obj); 
		}
		public static var tracerLoc:TextField;
	}
	
	
}