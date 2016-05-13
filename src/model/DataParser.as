package model {
	/**
	 * ...
	 * @author Eugene Phang
	 */
	import flash.events.*;
	import flash.net.*;
	import flash.system.Security;

	public class DataParser extends EventDispatcher {
		public var request1:URLRequest;
		public var loaderX:URLLoader;
		public var dataClump:String;
		public var dataHeader:Array;
		public var dataSegments:Array;
		public var segmentRegex:RegExp=/"startSequence"\t+/;
		public var key:Array;
		
		public var f0:Array=new Array();
		public var f1:Array=new Array();
		public var f2:Array=new Array();
		public var f3:Array=new Array();
		public var f4:Array=new Array();
		public var f5:Array=new Array();

		public var presentYear:int;
		public var dateOfBirth:int;

		public var col:int;


		public function DataParser(urlString:String, col:int, presentYear:int, dateOfBirth:int) {
			
			this.presentYear=presentYear;
			this.dateOfBirth=dateOfBirth;

			this.col=col;

			request1=new URLRequest(urlString);
			loaderX=new URLLoader(request1);
			loaderX.dataFormat=URLLoaderDataFormat.TEXT;
			loaderX.addEventListener(Event.COMPLETE, CSVLoaded);
			Security.allowDomain("*");
			loaderX.addEventListener(IOErrorEvent.IO_ERROR, csvLoadError)
		}


		public function csvLoadError(e:IOErrorEvent):void {
			//trace("IO error: " + e);
			this.dispatchEvent(new Event("loadError"));
		}


		public function CSVLoaded(e:Event):void {

			dataClump=String(loaderX.data);
			dataHeader=dataClump.split("\n", 3);

			dataSegments=dataClump.split(segmentRegex);
			key=String(dataSegments[1]).split("\n");

			extractGameStimuli(key, col);
		}


		public function extractGameStimuli(key:Array, col:int):void {
			// f0 is years
			// f1 is timeLocation
			// f2 is descArray
			// f3 is imagelocation
			// f4 is textBodyArray
			// f5 is linkArray

			// A double-quotation mark (") in any of the fields will break this parser.
			// Beware!
			// Recommendation: manually change all instances of " to '

			for (var i:int=0; i < key.length; i++) {
				var elementReg:Array=new Array();
				var columnIndex:int=2 + (col - 1) * 4;

				elementReg=key[i].split("\t");
				//trace('elementReg', elementReg);


				if ((elementReg[0] != undefined) && (Number(elementReg[0]) > 0)) {
					//trace("\nregister contents: "+ elementReg);
					//trace("col1: " + elementReg[1]);
					f0.push(elementReg[columnIndex].match(/[^"]+/))

					//trace("register1: " + elementReg[columnIndex]);
					if (elementReg[1].match(/[^"]+/) == "specific") {

						var procYear1:int=int(elementReg[columnIndex]) - presentYear;
						f1.push(procYear1);
							//trace("numYears: "+procYear);
					} else if (elementReg[1].match(/[^"]+/) == "dob") {
						var procYear2:int=(int(dateOfBirth) - int(presentYear));
						f1.push(procYear2);
							//trace("dob: " + procYear);
					} else if (elementReg[1].match(/[^"]+/) == "today") {
						f1.push(0);
							//trace("today: "+0)
					} else {
						f1.push(elementReg[columnIndex].match(/[^"]+/))
							//trace("default: "+ elementReg[columnIndex].match(/[^"]+/));
					}
					//trace("register2: " + elementReg[columnIndex + 1]);
					f2.push(elementReg[columnIndex + 1].match(/[^"]+/))

					//trace("register3: " +  elementReg[columnIndex + 2].match(/[^"]+/)  );

					// imageLocation
					f3.push(elementReg[columnIndex + 2].match(/[^"]+/));

					// text body paragraph
					f4.push(elementReg[columnIndex + 3].match(/[^"]+/));

					// link
					f5.push(elementReg[columnIndex + 4].match(/[^"]+/));

				}
				// trace('f0', f0);

			}
			
			this.dispatchEvent(new Event("dataLoaded"));
		}
	}
}
