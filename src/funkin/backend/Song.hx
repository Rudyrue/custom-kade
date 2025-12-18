package funkin.backend;

#if FEATURE_STEPMANIA
import moonchart.formats.StepMania;
import moonchart.formats.BasicFormat.BasicNoteType;
#end

typedef Event = {
	var name:String;
	var position:Float;
	var value:Float;
	var type:String;
}

typedef Chart = {
	var ?songName:String;
	var song:String;

	var chartVersion:String;
	var offset:Float;
	var notes:Array<Section>;
	var eventObjects:Array<Event>;
	var needsVoices:Bool;
	var speed:Float;
	var bpm:Float;
	var player1:String;
	var player2:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
}

typedef Section = {
	var sectionNotes:Array<Array<Dynamic>>;
	var lengthInSteps:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
	var CPUAltAnim:Bool;
	var playerAltAnim:Bool;
}

class Song {
	public static function createDummyFile():Chart {
		return {
			notes: [],
			speed: 1.0,
			offset: 0.0,
			chartVersion: 'KE 1.8',
			stage: 'stage',
			gfVersion: 'gf',
			player1: 'bf',
			player2: 'bf',
			needsVoices: false,
			eventObjects: [],
			bpm: 120,
			noteStyle: '',
			song: '',
			songName: 'Unknown'
		}
	} 

	public static function loadFromPath(path:String):Chart {
		if (!FileSystem.exists(path)) return createDummyFile();

		var file:Chart = cast Json.parse(File.getContent(path)).song;

		if (file.songName == null || file.songName.length == 0) {
			file.songName = file.song;
		}

		if (file.eventObjects == null || file.eventObjects.length == 0) {
			file.eventObjects = [{name: "Init BPM", position: 0, value: file.bpm, type: 'BPM Change'}];

			// this sucks having to translate sections into time
			// and then translating it into beats
			// and then translating it back into time again
			// but whatever thank you kadedeveloper
			var bpm:Float = file.bpm;
			var position:Float = 0;
			var lastPosition:Float = 0;
			var beat:Float = 0;
			var index:Int = 1;
			for (section in file.notes) {
				if (section.changeBPM == true) {
					bpm = section.bpm;
					file.eventObjects.push({name: 'FNF BPM Change $index', position: beat, value: bpm, type: 'BPM Change'});
					index++;
				}

				final len = (section.lengthInSteps ?? 16) * 0.25;
				position += Conductor.calculateCrotchet(bpm) * len;

				beat += (position - lastPosition) / Conductor.calculateCrotchet(bpm);
				lastPosition = position;
			}
		}

		return file;
	}

	public static function load(song:String, diff:String):Chart {
		var file = loadFromPath('assets/songs/$song/${Difficulty.format(diff)}.json');

		var meta = getMetaFile(song);
		if (meta != null) {
			if (meta.offset != null) file.offset = meta.offset;
			if (meta.name != null) file.songName = meta.name;
		}

		return file;
	}

	public static function getMetaFile(songID:String) {
		if (!FileSystem.exists('assets/songs/$songID/_meta.json')) return null;
		return Json.parse(File.getContent('assets/songs/$songID/_meta.json'));
	}

	public static function exists(song:String, difficulty:String):Bool {
		return Paths.exists('songs/$song/$difficulty.json');
	}

	#if FEATURE_STEPMANIA
	public static function getSimfilePath(song:String):String {
		var path:String = '';
		for (file in FileSystem.readDirectory('assets/sm/$song')) {
			if (!file.endsWith('.sm')) continue;
			path = 'assets/sm/$song/$file';
			break;
		}

		return path;
	}

	public static function simfileExists(song:String):Bool {
		return FileSystem.exists(getSimfilePath(song));
	}
	#end
}

#if FEATURE_STEPMANIA
class FNFChart extends moonchart.formats.fnf.FNFKade {
 	public function new() {
    	super();

		@:privateAccess { // uuHGHGHGUGUHGUHGUHGUHGHUGUHGHUGHUHUGHUG
			legacy.offsetHolds = false;
			legacy.bakedOffset = false;
			legacy.noteTypeResolver.register(2, BasicNoteType.MINE);
		}
  	}
}
#end