package funkin.backend;

@:publicFields
@:structInit
class SaveVariables {
	// Gameplay
	var scrollSpeed:Float = 3;
	var noteOffset:Int = 0;
	var accuracyType:String = 'Simple';
	var ghostTapping:Bool = true;
	var scrollDirection:String = 'Up';
	var botplay:Bool = false;
	var framerate:Int = 60;
	var resetButton:Bool = false;
	var instantRespawn:Bool = false;
	var cameraZooming:Bool = true;

	// Appearance
	var noteskin:String = 'Arrows';
	var distractions:Bool = true;
	var centeredNotes:Bool = false;
	var healthBar:Bool = true;
	var judgeCounter:Bool = false;
	var laneUnderlay:Float = 0.0;
	var quantization:Bool = false;
	var accuracy:Bool = true;
	var timeBar:Bool = true;
	var notesPerSecond:Bool = false;
	var cpuStrums:Bool = true;
	var optimize:Bool = false;

	// Misc
	var fpsCounter:Bool = true;
	var flashingLights:Bool = true;
	var watermarks:Bool = Main.watermarks;
	var antialiasing:Bool = true;
	var resultsScreen:Bool = true;
	var hitGraph:Bool = true;

	var downscroll(get, never):Bool;
	function get_downscroll():Bool {
		return scrollDirection.toLowerCase() == 'down';
	}

	var wife3(get, never):Bool;
	function get_wife3():Bool {
		return accuracyType.toLowerCase() == 'complex';
	}
}

class Settings {
	public static var data:SaveVariables = {};
	public static final default_data:SaveVariables = {};

	public static function load() {
		FlxG.save.bind('settings', Util.getSavePath());

		final fields:Array<String> = Type.getInstanceFields(SaveVariables);
		for (i in Reflect.fields(FlxG.save.data)) {
			if (!fields.contains(i)) continue;

			if (Reflect.hasField(data, 'set_$i')) Reflect.setProperty(data, i, Reflect.field(FlxG.save.data, i));
			else Reflect.setField(data, i, Reflect.field(FlxG.save.data, i));
		}

		if (FlxG.save.data.framerate == null) {
			final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
			data.framerate = Std.int(FlxMath.bound(refreshRate * 2, 60, 240));
		}
	}

	public static function save() {
		for (key in Reflect.fields(data)) {
			// ignores variables with getters
			if (Reflect.hasField(data, 'get_$key')) continue;
			Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));
		}

		FlxG.save.flush();
	}

	public static function reset(?saveToDisk:Bool = false) {
		data = {};
		if (saveToDisk) save();
	}
}