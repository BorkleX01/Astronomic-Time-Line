package model
{
	import com.adaptiveelearning.capi.CAPIInterface;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.filters.GlowFilter;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.formatters.NumberFormatter;

	public class TimeScalerFactory
	{
		public function TimeScalerFactory()	{}
		
		public static function newReleaseModel():TimeScalerModel {
			var m:TimeScalerModel = new TimeScalerModel();
			
			m.imageURL 					= "http://aelp.smartsparrow.com/repo/datasource/images01";
			m.dataURL 					= "http://aelp.smartsparrow.com/repo/datasource/eventsBank7.csv";
			m.zoomDefaultMin 			= -7000000000;
			m.zoomDefaultMax			= 7000000000;
			m.zoomMin					= m.zoomDefaultMin;
			m.zoomMax					= m.zoomDefaultMax;
			m.timelineDropMin 			= -6000000000;
			m.timelineDropMin 			= 6000000000;
			m.yearOfBirth 				= 1974;
			m.filteredEventsChanged 	= true; // default to true in case no filter is initially provided
			m.resetZoom();
			
			return m;
		}
		
		public static function newDebugModel():TimeScalerModel {
			var m:TimeScalerModel = newReleaseModel();
			
			m.imageURL 					= "data/images";
			m.dataURL 					= "data/eventsBank7.csv";
			
			return m;
		}
		
		public static function newIcon(desc:String):MovieClip {
			// The CSV file is NOT linked to this
			// If you make a change to an event name in the CSV, it must also be changed here!
			
			var iconClasses:Dictionary = new Dictionary();
			
			iconClasses['Formation of Earth/Solar System'] = formation_of_earth;
			iconClasses['Moon Forming Impact'] = moon_forming_impact;
			iconClasses['Late Heavy Bombardment'] = late_heavy_bombardment;
			iconClasses['Oldest Evidence for Life'] = oldest_evidence_for_life;
			iconClasses['Oldest Bacterial Fossils (microfossils)'] = oldest_bacterial_fossils;
			iconClasses['Oldest Stromatolites (macrofossils)'] = oldest_stromatolites;
			iconClasses['Oldest Eukaryote Biosignature'] = oldest_eukaryote_biosignature;
			iconClasses['Snowball Earth'] = snowball_earth;
			iconClasses['Oldest Biosignature for Multicellularity'] = oldest_biosignature_for_multicellularity;
			iconClasses['Rise of Oxygen'] = rise_of_oxygen;
			iconClasses['Oldest Eukaryote Fossils'] = oldest_eukaryote_fossils;
			iconClasses['Oldest Animal Fossils (Ediacara)'] = oldest_animal_fossils;
			iconClasses['Cambrian Explosion'] = cambrian_explosion;
			iconClasses['Oldest Land Plant Fossils'] = oldest_land_plant_fossils;
			iconClasses['Oldest Land Animal Fossils'] = oldest_land_animal_fossils;
			iconClasses['Permian-Triassic Extinction'] = permian_triassic_extinction;
			iconClasses['Oldest Dinosaur Fossils'] = oldest_dinosaur_fossils;
			iconClasses['Dinosaur Extinction'] = dinosaur_extinction;
			iconClasses['Ice Ages Begin'] = ice_ages_begin;
			iconClasses['Earliest Use of Stone Tools by Human Ancestors'] = earliest_stone_tools;
			iconClasses['Last Glacial Maximum'] = last_glacial_maximum;
			iconClasses['Agriculture Invented'] = agriculture_invented;
			iconClasses['Rome Founded'] = rome_founded;
			iconClasses['Rome Collapses'] = rome_collapses;
			iconClasses['Renaissance'] = renaissance;
			iconClasses['Industrial Revolution'] = industrial_revolution;
			iconClasses['First Radio Broadcast'] = first_radio_broadcast;
			iconClasses['First Human Steps on Extraterrestrial Body'] = first_human_steps_on_et_body;
			iconClasses['Your Birth'] = your_birth;
			iconClasses['Today'] = today;
			iconClasses['Biosphere Collapses'] = biosphere_collapses;
			iconClasses['Evaporation of the Oceans'] = evaporation_of_the_oceans;
			iconClasses['Death of the Earth'] = death_of_the_earth;
			
			return new (iconClasses[desc] as Class)() as MovieClip;
		}
		
		public static function newCommaNumberFormatter():NumberFormatter {
			var commaFormatter:NumberFormatter = new NumberFormatter();
			commaFormatter.useThousandsSeparator = true;
			commaFormatter.useNegativeSign = true;
			commaFormatter.thousandsSeparatorFrom = ',';
			commaFormatter.thousandsSeparatorTo = ',';
			commaFormatter.precision = '0';
			commaFormatter.decimalSeparatorFrom = '.';
			commaFormatter.decimalSeparatorTo = '.';
			
			return commaFormatter;
		}
		
		public static function newHoverGlow():GlowFilter {
			return new GlowFilter(0xFFFFFF, .2, 6 , 6 , 2);
		}
		
		public static function newSelectedGlow():GlowFilter {
			return new GlowFilter(0x00FF00, .6, 6, 6, 2);
		}
	}
}