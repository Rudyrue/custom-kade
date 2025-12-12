import flixel.graphics.FlxGraphic;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.math.FlxRect;

class InitState extends flixel.FlxState {
	override function create():Void {
		FlxG.autoPause = false;

		Settings.load();
		Scores.load();

		FlxG.fixedTimestep = false;

		// these look like ass bro
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(
			FADE, 
			FlxColor.BLACK, 
			1, 
			FlxPoint.get(0, -1), 
			{asset: diamond, width: 32, height: 32}, 
			FlxRect.get(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4)
		);

		FlxTransitionableState.defaultTransOut = new TransitionData(
			FADE, 
			FlxColor.BLACK, 
			0.7, 
			FlxPoint.get(0, 1), 
			{asset: diamond, width: 32, height: 32}, 
			FlxRect.get(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4)
		);

		//NoteskinHelpers.updateNoteskins();

/*		if (FlxG.save.data.volDownBind == null)
			FlxG.save.data.volDownBind = "MINUS";
		if (FlxG.save.data.volUpBind == null)
			FlxG.save.data.volUpBind = "PLUS";

		FlxG.sound.muteKeys = [FlxKey.fromString(FlxG.save.data.muteBind)];
		FlxG.sound.volumeDownKeys = [FlxKey.fromString(FlxG.save.data.volDownBind)];
		FlxG.sound.volumeUpKeys = [FlxKey.fromString(FlxG.save.data.volUpBind)];*/

		FlxG.mouse.visible = false;

		//FlxG.worldBounds.set(0, 0);
		FlxGraphic.defaultPersist = true;

		FlxG.plugins.add(new funkin.backend.Conductor());
		FlxG.switchState(Type.createInstance(Main.initialState, []));
	}
}