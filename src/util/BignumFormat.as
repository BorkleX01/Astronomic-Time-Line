package util {

	/**
	 * ...
	 * @author Eugene Phang
	 */
	public class BignumFormat {

		public function BignumFormat() {}
		

		public function formatThumbYear(num:Number):void {
			var presentOrderOfMag:int=String(num.toFixed()).length;

			//detectOrderOfMag(presentExtent);//can be 1?
			var scale:Number=1 * Math.pow(10, presentOrderOfMag - 1);

		}

		
		public function format3(procThis:Number, scale:Number, extent:Number):String {
			return procThis.toString();
		}


		public function format(procThis:Number, scale:Number, extent:Number):String {
			var stringLength:uint=String(Math.abs(procThis).toFixed()).length;
			//return procThis + " " + stringLength + "\n" + scale;
			switch (stringLength) {
				case 10:
					return procThis / 1000000000 + "Ga"
					break;
				case 9:
					return procThis / 1000000 + "Ma"
					break;
				case 8:
					return procThis / 1000000 + "Ma"
					break;
				case 7:
					return procThis / 1000000 + "Ma"
					break;
				case 6:
					return procThis / 1000 + "ka"
					break;
				case 5:
					return procThis / 1000 + "ka"
					break;
				case 4:
					return procThis / 1000 + "ka"
					break;
				default:
					return procThis.toString();
					break;
			}
		}


		public function format4(procThis:Number, scale:Number, extent:Number):String {
			switch (scale) {
				case 100000000000:
					return procThis * 100 / scale + "Ga";
					break;
				case 10000000000:
					return procThis * 10 / scale + "Ga";
					break;
				case 1000000000:
					return procThis / scale + "Ga";
					break;
				case 100000000:
					return procThis * 100 / scale + "Ma";
					break;
				case 10000000:
					return procThis * 10 / scale + "Ma";
					break;
				case 1000000:
					return procThis / scale + "Ma";
					break;
				case 100000:
					return procThis * 100 / scale + "ka";
					break;
				case 10000:
					return procThis * 10 / scale + "ka";
					break;
				case 1000:
					return procThis / scale + "ka";
					break;
				default:
					return procThis.toString();
					break;
			}
		}
	}
}


/*ka (for kiloannum), is a unit of time equal to one thousand (103) years.
   Ma (for megaannum), is a unit of time equal to one million (106) years. It is commonly used in scientific disciplines such as geology, paleontology, and celestial mechanics to signify very long time periods into the past or future. For example, the dinosaur species Tyrannosaurus rex was abundant approximately 65 Ma (65 million years) ago (ago may not always be mentioned; if the quantity is specified while not explicitly discussing a duration, one can assume that "ago" is implied; the alternative but deprecated "mya" unit includes "ago" explicitly.). In astronomical applications, the year used is the Julian year of precisely 365.25 days. In geology and paleontology, the year is not so precise and varies depending on the author.
   Ga (for gigaannum), is a unit of time equal to 109 years (one billion on the short scale, one milliard on the long scale). It is commonly used in scientific disciplines such as cosmology and geology to signify extremely long time periods in the past. For example, the formation of the Earth occurred approximately 4.57 Ga (4.57 billion years) ago.
 * */
/*103 	1 kiloannum 	millennium = 1000 anna 	103 a, 104 a, 105 a
   106 	1 megaannum 	epoch = 1,000,000 anna 	106 a, 107 a, 108 a
   109 	1 gigaannum 	aeon = 1,000,000,000 anna
   13.7 Ga = 1.37×1010 a ≈ 13.7 billion years, the approximate age of the Universe 	109 a, 1010 a, 1011 a
   1012 	1 teraannum 	--- 	1012 a, 1013 a, 1014 a
   1015 	1 petaannum 	--- 	1015 a, 1016 a, 1017 a
   1018 	1 exaannum 	-- 	1018 a, 1019 a, 1020 a
   1021 	1 zettaannum 	-- 	1021 a, 1022 a, 1023 a
   1024 	1 yottaannum 	-- 	1024 a, 1025 a, 1026 and more*/
