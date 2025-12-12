package funkin.states;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;

class MainMenuState extends FunkinState {
	var camFollow:FlxObject;
	var optionGrp:FlxTypedSpriteGroup<FunkinSprite>;
	static var curSelected:Int = 0;
	var mouseControls:Bool = true;

	var options:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];

	override function create():Void {
		super.create();

		persistentUpdate = true;

		add(camFollow = new FlxObject(FlxG.width * 0.5, 0, 1, 1));

		var bg = new FunkinSprite().loadGraphic(Paths.image('yellowBG'));
		bg.scrollFactor.y = 0.1;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		
		bg.screenCenter();
		add(bg);

		add(optionGrp = new FlxTypedSpriteGroup<FunkinSprite>());

		var versionShit = new FlxText(5, FlxG.height - 18, 0, 'Friday Night Funkin\' v${Main.gameVer}');
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// meth :broken_heart:
		for (i => option in options) {
			var item:FunkinSprite = createItem(option, 0, FlxG.height * 1.6);
			optionGrp.add(item);

			if (Main.firstStart) {
				FlxTween.tween(item, {y: 60 + (i * 160)}, 1 + (i * 0.25), {ease: FlxEase.expoInOut});
			} else item.y = 60 + (i * 160);
		}

		changeSelection();

		Main.firstStart = false;
		FlxG.mouse.visible = true;
		persistentUpdate = true;
	}

	var accepted:Bool = false;
	override function update(elapsed:Float) {
		optionGrp.update(elapsed);

		if (accepted) {
			if (Controls.justPressed('accept') || FlxG.mouse.justPressed) {
				FlxTransitionableState.skipNextTransOut = true;
				goToState();
			}
			return;
		}

		final downJustPressed:Bool = Controls.justPressed('ui_down');
		if (downJustPressed || Controls.justPressed('ui_up')) changeSelection(downJustPressed ? 1 : -1);

		if (mouseControls && (FlxG.mouse.deltaScreenX != 0 || FlxG.mouse.deltaScreenY != 0)) {
			for (index => option in optionGrp.members) {
				if (!FlxG.mouse.overlaps(option) || curSelected == index) continue;

				changeSelection(index, true);
				break;
			}
		}

		if (Controls.justPressed('accept') || (mouseControls && FlxG.mouse.overlaps(optionGrp.members[curSelected]) && FlxG.mouse.justPressed)) {
			accepted = true;
			FlxG.sound.play(Paths.sfx('confirmMenu'));

			for (i => option in optionGrp.members) {
				if (i == curSelected) continue;

				FlxTween.tween(option, {alpha: 0}, 0.4, {
					ease: FlxEase.quadOut,
					onComplete: function(_) option.kill()
				});
			}

			FlxFlicker.flicker(optionGrp.members[curSelected], 1, 0.06, false, false, function(_) goToState());
		}
	}

	function goToState() {
		switch options[curSelected] {
			case 'story mode':
				FlxG.switchState(new StoryMenuState());

			case 'freeplay':
				FlxG.switchState(new FreeplayState());

			case 'options':
				FlxG.switchState(new OptionsState());
		}
	}

	function createItem(option:String, ?x:Float, ?y:Float):FunkinSprite {
		final item:FunkinSprite = new FunkinSprite(x, y);
		item.scrollFactor.set();
		item.frames = Paths.sparrowAtlas('FNF_main_menu_assets');
		item.animation.addByPrefix('idle', '$option basic', 24, true);
		item.animation.addByPrefix('selected', '$option white', 24, true);
		item.playAnim('idle');
		return item;
	}

	function changeSelection(?dir:Int = 0, ?usingMouse:Bool = false) {
		//var lastItem:FunkinSprite = optionGrp.members[curSelected];
		curSelected = usingMouse ? dir : FlxMath.wrap(curSelected + dir, 0, optionGrp.length - 1);
		var curItem:FunkinSprite = optionGrp.members[curSelected];

		// i guess i have to do this the dumb way
		var item = null;
		for (i in 0...optionGrp.length) {
			item = optionGrp.members[i];

			if (i == curSelected) {
				item.playAnim('selected');
				item.centerOffsets();
				item.screenCenter(X);
				continue;
			}

			item.playAnim('idle');
			item.updateHitbox();
			item.screenCenter(X);
		}
		item = null;

/*		lastItem.playAnim('idle');
		lastItem.updateHitbox();
		lastItem.screenCenter(X);

		curItem.playAnim('selected');
		curItem.centerOffsets();
		curItem.screenCenter(X);*/

		FlxG.sound.play(Paths.sfx('scrollMenu'));
		camFollow.setPosition(curItem.getGraphicMidpoint().x, curItem.getGraphicMidpoint().y);
	}
}