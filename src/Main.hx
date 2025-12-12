package;

import openfl.display.Bitmap;
import lime.app.Application;
import openfl.display.BlendMode;
import openfl.text.TextFormat;
import flixel.util.FlxColor;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import funkin.shaders.ImageOutline;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;

class Main extends Sprite {
	public static var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	public static var framerate:Int = 120; // How many frames per second the game should run at.
	public static var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	public static var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var kadeEngineVer:String = '1.8';
	public static var gameVer:String = '0.2.7.1';

	public static var instance:Main;

	public static var watermarks = true; // Whether to put Kade Engine literally anywhere
	public static var firstStart:Bool = true;

	public function new() {
		instance = this;

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);

		super();

		// Run this first so we can see logs.
		Debug.onInitProgram();

		addChild(game = new FlxGame(InitState, gameWidth, gameHeight, framerate, skipSplash, startFullscreen));
		addChild(fpsCounter = new KadeEngineFPS(10, 3, 0xFFFFFF));

		// Finish up loading debug tools.
		Debug.onGameStart();
	}

	var game:FlxGame;

	public var fpsCounter:KadeEngineFPS;

	function onCrash(e:UncaughtErrorEvent):Void {
		e.preventDefault();
		e.stopImmediatePropagation();

		var errMsg:String = '${e.error}\n\n';

		for (stackItem in CallStack.exceptionStack(true)) {
			switch (stackItem) {
				case FilePos(_, file, line, _): errMsg += 'Called from $file:$line\n';
				default: Sys.println(stackItem);
			}
		}

		Sys.println('\n$errMsg');
	}
}
