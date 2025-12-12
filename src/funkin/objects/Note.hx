package funkin.objects;

import flixel.graphics.frames.FlxAtlasFrames;
import funkin.objects.Strumline;
import funkin.shaders.NoteShader;

@:structInit
@:publicFields
class NoteData {
	var time:Float = 0;
	var lane:Int = 0;
	var player:Int = 0;
	var length:Float = 0.0;
	var type:Int = 0;

	var quant:Int = -1;
	var beat:Float = 0;
}

class Note extends FunkinSprite {
	public static var colours:Array<String> = ['purple', 'blue', 'green', 'red'];
	public static var directions:Array<String> = ['left', 'down', 'up', 'right'];
	public var data:NoteData;

	public static var colourShader:NoteShader = new NoteShader();
	public var quantColors:Bool = false;
	public var byQuant:Bool = true;

/*	public static final quants:Array<FlxColor> = [
		0xFFF9393F, // 4th (red)
		0xFF00FFFF, // 8th (blue)
		0xFFC24B99, // 12th (purple)
		0xFF12FA05, // 16th (green)
		0xFFC24B99, // 20th (purple)
		0xFFC24B99, // 24th (purple)
		0xFF12FA05, // 32nd (green)
		0xFFC24B99, // 48th (purple)
		0xFF00FFFF, // 64th (blue)
		0xFFC24B99, // 96th (purple)
		0xFFC24B99, // 192nd (purple)
	];*/

	// arrowvortex colours
	// keeping these here because hte base kade ones are
	// fucking unreadable
	public static final quants:Array<FlxColor> = [
		0xFFFE2E2E, // 4th
		0xFF3E4FD4, // 8th
		0xFFBB32FF, // 12th
		0xFFFFFF28, // 16th
		0xFF5F5F5F, // 20th 
		0xFFFF7CC4, // 24th
		0xFFFF7F00, // 32nd
		0xFF38D1D1, // 48th
		0xFF0CF23E, // 64th
		0xFF5F5F5F, // 96th
		0xFF5F5F5F, // 192nd
	];

	public static var finalVertices:Array<Float> = [0, 0, 0, 0, 0, 0, 0, 0];

	public var distance:Float = 2000;

	public var rawTime(get, never):Float;
	function get_rawTime():Float return data.time;

	public var time(get, never):Float;
	function get_time():Float return rawTime - Settings.data.noteOffset;

	public var rawHitTime(get, never):Float;
	function get_rawHitTime():Float {
		return time - Conductor.rawTime;
	}

	public var hitTime(get, never):Float;
	function get_hitTime():Float {
		return time - Conductor.visualTime;
	}

	public var inHitRange(get, never):Bool;
	function get_inHitRange():Bool {
		final early:Bool = time < Conductor.rawTime + (Judgement.max.timing * Conductor.rate);
		final late:Bool = time > Conductor.rawTime - (Judgement.max.timing * Conductor.rate);

		return early && late;
	}

	public var tooLate(get, never):Bool;
	function get_tooLate():Bool {
		return hitTime < -(Judgement.max.timing + 25 * Conductor.rate);
	}

	public var missed:Bool = false;
	public var wasHit:Bool = false;
	public var isSustain:Bool = false;
	public var sustain:Sustain = null;

	public var hittable(get, never):Bool;
	function get_hittable():Bool return exists && inHitRange && !missed;

	public function new() {
		super();
	}

	public function setup(data:NoteData):Note {
		this.data = data;
		missed = false;
		wasHit = false;
		quantColors = Settings.data.quantization;
		sustain = null;
		isSustain = false;
		reload();

		if (!quantColors) color = 0xFFFFFFFF;
		else color = quants[byQuant ? Conductor.quants.indexOf(data.quant) : data.lane];

		//active = false;
		return this;
	}

	public static function getSkin(?name:String):FlxAtlasFrames {
		name ??= '';
		//name = Util.format(name);

		function getTextureKey(name:String):String {
			var key:String = name;
			if (!Settings.data.quantization) return key;

			key = '$name-quant';
			if (!Paths.exists('images/noteSkins/$key.xml')) key = name;
			return key;
		}

		return Paths.sparrowAtlas('noteSkins/${getTextureKey(name)}');
	}

	public function reload(?skin:String) {
		frames = getSkin(Settings.data.noteskin);
		loadAnims(colours[data.lane]);

		scale.set(Strumline.size, Strumline.size);
		loadAnims(colours[data.lane % colours.length]);
		updateHitbox();
	}

	function loadAnims(colour:String) {
		animation.addByPrefix('default', '${colour}0');
		playAnim('default');
		//active = false;
	}

	// custom kill handling for allowing sustain heads to stay "existant" when hit
	override public function kill():Void {
		alive = false;
		exists = false;
	}

	override public function revive():Void {
		alive = true;
		exists = true;
	}

	@:noDebug public function followStrum(strum:StrumNote, downscroll:Bool, scrollSpeed:Float) {
		visible = strum.visible && strum.parent.visible;
		distance = hitTime * 0.45 * scrollSpeed;
		distance *= downscroll ? -1 : 1;

		x = strum.x;
		y = strum.y + distance;
	}

	override public function drawComplex(camera:FlxCamera) {
		_frame.prepareMatrix(_matrix, ANGLE_0, checkFlipX(), checkFlipY());
		prepareMatrix(_matrix, camera);
		camera.drawNote(_frame, _matrix, colorTransform, blend, antialiasing, quantColors);
	}
}