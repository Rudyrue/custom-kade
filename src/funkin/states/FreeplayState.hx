package funkin.states;

#if FEATURE_STEPMANIA import moonchart.formats.StepMania; #end
import funkin.objects.CharIcon;
import funkin.backend.Scores.ScoreData;

typedef SongData = {
	var id:String;
	var ?isSimfile:Bool;
	var audio:String;
}

class FreeplayState extends FunkinState {
	var list:Array<SongData> = [];
	var grpSongs:FlxTypedSpriteGroup<Alphabet>;
	var grpIcons:FlxTypedSpriteGroup<CharIcon>;
	static var curSelected:Int = 0;
	static var curDifficulty:Int = 0;
	var totalSongIndex:Int = -1;

	var scoreText:FlxText;
	var scoreBG:FunkinSprite;
	var diffText:FlxText;
	var previewText:FlxText;
	var clearTypeText:FlxText;
	var clearType:String;

	var curSong(get, never):SongData;
	function get_curSong():SongData return list[curSelected];

	var curScore:ScoreData;

	override function create():Void {
		super.create();

		var bg = new FunkinSprite(0, 0, Paths.image('blueBG'));
		bg.screenCenter();
		add(bg);

		add(grpSongs = new FlxTypedSpriteGroup<Alphabet>());
		add(grpIcons = new FlxTypedSpriteGroup<CharIcon>());

		scoreText = new FlxText(FlxG.width * 0.65, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		var scoreBG = new FunkinSprite(scoreText.x - 6, 0).makeGraphic(1, 1, 0xFF000000);
		scoreBG.scale.set(Std.int(FlxG.width * 0.4), 135);
		scoreBG.updateHitbox();
		scoreBG.alpha = 0.6;
		add(scoreBG);

		add(scoreText);

		add(diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24));
		diffText.font = scoreText.font;

		add(previewText = new FlxText(scoreText.x, scoreText.y + 96, 0, "Rate: " + FlxMath.roundDecimal(Conductor.rate, 2) + "x", 24));
		previewText.font = scoreText.font;

		add(clearTypeText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24));
		clearTypeText.font = diffText.font;

		for (line in File.getContent('assets/data/freeplaySongList.txt').split('\n')) {
			var params:Array<String> = line.split(':');
			var id:String = params[0];
			var icon:String = params[1];
			//var week:Int = Std.parseInt(params[2]);

			list.push({
				id: id,
				isSimfile: false,
				audio: 'Inst.${Paths.SOUND_EXT}'
			});

			addSong(id, icon);
		}

		#if FEATURE_STEPMANIA
		for (dir in FileSystem.readDirectory('assets/sm')) {
			if (!FileSystem.isDirectory('assets/sm/$dir')) continue;

			var sm = new StepMania().fromFile(Song.getSimfilePath(dir));
			list.push({
				id: dir,
				isSimfile: true,
				audio: sm.data.MUSIC
			});
			
			addSong(sm.data.TITLE, 'sm');
		}
		#end

		changeSelection();

		curDifficulty = Difficulty.list.indexOf(Difficulty.current);
		changeDifficulty();

		persistentUpdate = true;
		FlxG.mouse.visible = true;
	}

	function addSong(name:String, ?icon:String) {
		totalSongIndex++;

		var meta = Song.getMetaFile(name);
		var alphabet = new Alphabet(90, 320, meta?.name ?? name);
		alphabet.isMenuItem = true;
		alphabet.scaleX = Math.min(1, 980 / alphabet.width);
		alphabet.snapToPosition();
		alphabet.targetY = totalSongIndex;
		grpSongs.add(alphabet);

		grpIcons.add(new CharIcon(icon));
	}

	var holdTime:Float;
	var intendedScore:Int;
	var lerpScore:Int;
	override function update(elapsed:Float) {
		grpSongs.update(elapsed);

		var icon = null;
		for (i in 0...grpIcons.length) {
			icon = grpIcons.members[i];
			var item = grpSongs.members[i];

			icon.setPosition(item.x + (item.width + (icon.width * 0.05)), item.y - (item.height * 0.5));
		}

		if (Controls.justPressed('back') || FlxG.mouse.justPressedRight) {
			FlxG.switchState(new MainMenuState());
			FlxG.sound.play(Paths.sfx('cancelMenu'));
		}

		var leftPressed:Bool = Controls.justPressed('ui_left');
		if (FlxG.keys.pressed.SHIFT && (leftPressed || Controls.justPressed('ui_right'))) {
			var inc:Float = leftPressed ? -0.05 : 0.05;
			Conductor.rate = FlxMath.bound(Conductor.rate + inc, 0.5, 3);
			previewText.text = 'Rate: ${Conductor.rate}x';
			updateScore();
		}

		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		if (Math.abs(lerpScore - intendedScore) <= 10) lerpScore = intendedScore;
			
		scoreText.text = 'PERSONAL BEST: $lerpScore';

		songControls(elapsed);
		if (!FlxG.keys.pressed.SHIFT) difficultyControls();
	}

	function songControls(elapsed:Float) {
		var shiftMult:Int = FlxG.keys.pressed.SHIFT ? 3 : 1;

		final downJustPressed:Bool = Controls.justPressed('ui_down');
		if (downJustPressed || Controls.justPressed('ui_up')) {
			changeSelection(downJustPressed ? shiftMult : -shiftMult);
			holdTime = 0;
		}

		final downPressed:Bool = Controls.pressed('ui_down');
		if (downPressed || Controls.pressed('ui_up')) {
			var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
			holdTime += elapsed;
			var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

			if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				changeSelection((checkNewHold - checkLastHold) * (downPressed ? shiftMult : -shiftMult));
		}

		if (FlxG.mouse.wheel != 0) changeSelection(-shiftMult * FlxG.mouse.wheel, 0.2);

		if (Controls.justPressed('accept') || FlxG.mouse.justPressed) {
			PlayState.songID = curSong.id;
			PlayState.isSimfile = curSong.isSimfile;
			Difficulty.current = Difficulty.list[curDifficulty];
			FlxG.switchState(new PlayState());
		}
	}

	function difficultyControls() {
		if (curSong.isSimfile) return;

		final leftPressed:Bool = Controls.justPressed('ui_left');
		if (leftPressed || Controls.justPressed('ui_right')) changeDifficulty(leftPressed ? -1 : 1);
	}

	function changeSelection(?change:Int = 0, ?volume:Float = 0.4) {
		curSelected = FlxMath.wrap(curSelected + change, 0, list.length - 1);
		if (volume > 0.0) FlxG.sound.play(Paths.sfx('scrollMenu'), volume);

		for (i => item in grpSongs.members) {
			item.alpha = i == curSelected ? 1 : 0.5;
			item.targetY = i - curSelected;
			grpIcons.members[i].alpha = i == curSelected ? 1 : 0.5;
		}

		if (curSong.isSimfile && curSong.audio.endsWith('.mp3')) {
			Debug.logTrace('StepMania audio file is using an .mp3! Please convert it to .ogg.');
		} else {
			// apparently flixel doesn't cancel fade tweens when destroying sounds
			// thank you flixel
			if (Conductor.inst.fadeTween != null) Conductor.inst.fadeTween.cancel();
			Conductor.inst = FlxG.sound.load(Paths.audio('${curSong.id}/${curSong.audio}', curSong.isSimfile ? 'sm' : 'songs'), 0, true);
			Conductor.play();
			Conductor.inst.fadeIn(2, 0, 0.7);
		}

		changeDifficulty();
	}

	function changeDifficulty(?change:Int = 0) {
		if (!curSong.isSimfile) {
			curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length - 1);
			diffText.text = Difficulty.list[curDifficulty].toUpperCase();
		} else diffText.text = 'STEPMANIA';

		updateScore();
	}

	function updateScore() {
		curScore = Scores.get(curSong.id, Difficulty.list[curDifficulty]);
		intendedScore = curScore.score;
		clearTypeText.text = curScore.clearType;
		
		var width:Float = diffText.width > 100 ? diffText.width + 50 : 100;
		clearTypeText.x = diffText.x + width;
	}
}