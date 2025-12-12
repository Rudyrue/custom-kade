package funkin.backend;

import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;


#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class KadeEngineFPS extends openfl.display.Sprite {
	// the current frame rate expressed using frames-per-second
	public var currentFPS(default, null):Int;

	// the rate at which the counter updates in milliseconds
	final pollingRate:Float = 1000;

	public var text:TextField;
	public var background:Bitmap;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0xFFFFFFFF) {
		super();

		this.x = x;
		this.y = y;

		addChild(background = new Bitmap(new BitmapData(93, 1, true, 0x99000000)));

        addChild(text = new TextField());
        text.autoSize = LEFT;
		text.x = x + 4;
		text.y = y + 5;
		text.mouseEnabled = text.selectable = false;
		text.defaultTextFormat = new TextFormat('assets/fonts/vcr.ttf', 14, color, JUSTIFY);
		updateText();
	}

	var _frames:Int = 0;
	var _current:Int = 0;
	var _fpsTime:Float = 0.0;
	var _pollingRateTime:Float = 0.0;

	@:noCompletion
	override function __enterFrame(delta:Float):Void {
		_frames++;
		_fpsTime += delta;

		// forcing fps to be updated every second instead
		// because basing it on `_pollingRate` would cause fps to be higher or lower
		// depending on what it is
		if (_fpsTime >= 1000) {
  			currentFPS = _frames;
 			_fpsTime = _frames = 0;
		}

		// so instead we use polling rate just to update the text itself
		_pollingRateTime += delta;
		if (_pollingRateTime < pollingRate) return;

		updateText();
		_pollingRateTime = 0.0;
	}

	public dynamic function updateText() {
		var textString:String = ''; // openfl sucks cock

		if (Settings.data.fpsCounter) {
			textString = 'FPS: $currentFPS';
			if (Settings.data.watermarks) textString += '\n';
		}

		if (Settings.data.watermarks) textString += 'KE v${Main.kadeEngineVer}';

		text.text = textString;

		background.visible = textString.length != 0;
		background.height = text.height + 20;
	}
}
