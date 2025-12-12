package funkin;

import lime.app.Application;
import openfl.Lib;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxSubState;

class FunkinSubstate extends FlxSubState {
	public function new() {
		super();
	}

	override function create() {
		super.create();
		Application.current.window.onFocusIn.add(onWindowFocusIn);
		Application.current.window.onFocusOut.add(onWindowFocusOut);

		Conductor.onStep.add(stepHit);
		Conductor.onBeat.add(beatHit);
		Conductor.onMeasure.add(measureHit);
	}

	override function destroy() {
		Application.current.window.onFocusOut.remove(onWindowFocusOut);
		Application.current.window.onFocusIn.remove(onWindowFocusIn);

		Conductor.onStep.remove(stepHit);
		Conductor.onBeat.remove(beatHit);
		Conductor.onMeasure.remove(measureHit);
		super.destroy();
	}

	public function stepHit(step:Int):Void {

	}

	public function beatHit(beat:Int):Void {

	}

	public function measureHit(measure:Int):Void {
	
	}

	function onWindowFocusOut():Void {
	}

	function onWindowFocusIn():Void {

	}
}
