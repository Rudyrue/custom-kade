package funkin.substates;

import openfl.Lib;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.input.keyboard.FlxKey;

class PauseMenu extends FlxSubState {
	var grpMenuShit:FlxTypedSpriteGroup<Alphabet>;

	public static var goToOptions:Bool = false;
	public static var goBack:Bool = false;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to Menu'];
	var curSelected:Int = 0;

	static var pauseMusic:FlxSound;

	var difficulty:String;
	var songName:String;
	var deaths:Int;

	var bg:FlxSprite;

	public function new(song:String, difficulty:String, deaths:Int) {
		super();
		this.songName = song;
		this.difficulty = difficulty;
		this.deaths = deaths;
	}

	override function create() {
		super.create();

		pauseMusic ??= FlxG.sound.load(Paths.music('Breakfast'), 0, true);
		if (!goToOptions) {
			pauseMusic.time = FlxG.random.float(0, pauseMusic.length * 0.75);
			pauseMusic.play();
			pauseMusic.volume = 0;
		} else menuItems.remove('Resume');
		goToOptions = false;

		add(bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK));
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0.6;
		bg.scrollFactor.set();

		var song:FlxText = new FlxText(20, 15, 0, songName, 32);
		song.font = Paths.font("vcr.ttf");
		song.x = FlxG.width - (song.width + 20);
		song.alpha = 0;
		add(song);

		var songDifficulty:FlxText = new FlxText(20, 47, 0, difficulty.toUpperCase(), 32);
		songDifficulty.font = Paths.font('vcr.ttf');
		songDifficulty.x = FlxG.width - (songDifficulty.width + 20);
		songDifficulty.alpha = 0;
		add(songDifficulty);

		var blueballed:FlxText = new FlxText(20, 15 + 64, 0, 'Blueballed: $deaths', 32);
		blueballed.font = Paths.font('vcr.ttf');
		blueballed.x = FlxG.width - (blueballed.width + 20);
		blueballed.alpha = 0;
		add(blueballed);

		add(grpMenuShit = new FlxTypedSpriteGroup<Alphabet>());

		for (index => option in menuItems) {
			final alphabet:Alphabet = grpMenuShit.add(new Alphabet(90, 320, option, BOLD, LEFT));
			alphabet.isMenuItem = true;
			alphabet.targetY = index;
		}

		changeSelection();

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(song, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(songDifficulty, {alpha: 1, y: songDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballed, {alpha: 1, y: blueballed.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float) {
		grpMenuShit.update(elapsed);

		if (pauseMusic.volume < 0.7) pauseMusic.volume += elapsed;

		if (Controls.justPressed('ui_up')) changeSelection(-1);
		else if (Controls.justPressed('ui_down')) changeSelection(1);

		if (FlxG.mouse.wheel != 0) changeSelection(-FlxG.mouse.wheel);

		if (Controls.justPressed('accept') || FlxG.mouse.justPressed) {
			var daSelected:String = menuItems[curSelected];

			switch (daSelected) {
				case "Resume":
					FlxG.state.persistentUpdate = true;
					close();
					Conductor.resume();
				case "Restart Song":
					FlxG.resetState();
				case "Options":
					goToOptions = true;
					close();
				case "Exit to Menu":
					PlayState.self.endSong(true);
			}
		}
	}

	override function destroy() {
		grpMenuShit.destroy();
		if (!goToOptions) {
			pauseMusic.stop();
			pauseMusic.destroy();
			pauseMusic = null; // gotta love it when i make a half-static variable (i fucking LOVE FLIXEL0
		}
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void {
		FlxG.sound.play(Paths.sfx('scrollMenu'), 0.4);

		curSelected = FlxMath.wrap(curSelected + change, 0, grpMenuShit.length - 1);

		for (i => item in grpMenuShit.members) {
			item.targetY = i - curSelected;
			item.alpha = curSelected == i ? 1 : 0.5;
		}
	}
}
