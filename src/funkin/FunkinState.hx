package funkin;

import lime.app.Application;
import flixel.FlxBasic;
import openfl.Lib;

class FunkinState extends FlxTransitionableState {
	override function create() {
		Paths.clearUnusedMemory();

		Conductor.reset();

		Conductor.onStep.add(stepHit);
		Conductor.onBeat.add(beatHit);
		Conductor.onMeasure.add(measureHit);

		super.create();
	}

	public function stepHit(step:Int):Void {}
	public function beatHit(beat:Int):Void {}
	public function measureHit(measure:Int):Void {}
}
