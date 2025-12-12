package funkin.states;

class OptionsState extends FunkinState {
	override function create() {
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		persistentUpdate = true;

		var menuBG:FunkinSprite = new FunkinSprite().loadGraphic(Paths.image("desatBG"));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		add(menuBG);

		openSubState(new funkin.substates.OptionsMenu());
	}
}
