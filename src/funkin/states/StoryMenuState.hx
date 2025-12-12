package funkin.states;

class StoryMenuState extends FunkinState {
	var tracksSprite:FunkinSprite;
	var tracklist:FlxText;
	var scoreTxt:FlxText;
	var weekTitle:FlxText;

	var diffSprite:FunkinSprite;
	var leftArrow:FunkinSprite;
	var rightArrow:FunkinSprite;
	var characters:FlxTypedSpriteGroup<MenuCharacter>;
	var weekSprGroup:FlxTypedSpriteGroup<WeekSprite>;

	var weeks:Array<WeekData> = [
		{
			title: 'Tutorial',
			image: 'tutorial',
			songs: ['tutorial'],
			characters: ['', 'bf', 'gf']
		},
		{
			title: 'Daddy Dearest',
			image: 'week1',
			songs: ['bopeebo', 'fresh', 'dadbattle'],
			characters: ['dad', 'bf', 'gf']
		},
		{
			title: 'Spooky Kids',
			image: 'week2',
			songs: ['spookeez', 'south'],
			characters: ['kids', 'bf', 'gf']
		},
		{
			title: 'Pico',
			image: 'week3',
			songs: ['pico', 'philly nice', 'blammed'],
			characters: ['pico', 'bf', 'gf']
		},
		{
			title: 'Mommy Mearest',
			image: 'week4',
			songs: ['satin panties', 'high', 'milf'],
			characters: ['mom', 'bf', 'gf']
		},
		{
			title: 'Christmas',
			image: 'week5',
			songs: ['cocoa', 'eggnog', 'winter horrorland'],
			characters: ['parents', 'bf', 'gf']
		},
		{
			title: 'Hating Simulator (ft. Moawling)',
			image: 'week6',
			songs: ['senpai', 'roses', 'thorns'],
			characters: ['senpai', 'bf', 'gf']
		}
	];

	var curWeek(get, never):WeekData;
	function get_curWeek():WeekData return weeks[curSelected];

	static var curSelected:Int = 0;
	static var curDiffSelected:Int = 0;

	override function create():Void {
		super.create();

		add(weekSprGroup = new FlxTypedSpriteGroup<WeekSprite>());

		// this is really dumb but whatever
		add(new FunkinSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK));

		var bgYellow = new FunkinSprite(0, 56).makeGraphic(1, 1, 0xFFF9CF51);
		bgYellow.scale.set(FlxG.width, 386);
		bgYellow.updateHitbox();
		add(bgYellow);

		add(scoreTxt = new FlxText(10, 10, 0, 'WEEK SCORE: 0', 32));
		scoreTxt.font = Paths.font('vcr.ttf');

		add(weekTitle = new FlxText(0, 10, 750, 'DADDY DEAREST', 32));
		weekTitle.font = Paths.font('vcr.ttf');
		weekTitle.alignment = 'right';
		weekTitle.alpha = 0.7;

		add(characters = new FlxTypedSpriteGroup<MenuCharacter>());
		for (i in 1...4) {
			characters.add(new MenuCharacter((FlxG.width - 960) * i - 150, 70));
		}

		add(tracksSprite = new FunkinSprite(0, 481).loadGraphic(Paths.image('tracks')));
		tracksSprite.x = 190 - (tracksSprite.width * 0.5);

		add(tracklist = new FlxText(0, tracksSprite.y + 60, 0, '', 32));
		tracklist.alignment = CENTER;
		tracklist.font = Paths.font('vcr.ttf');
		tracklist.color = 0xFFE55777;

		add(leftArrow = new FunkinSprite(850, 462));
		leftArrow.frames = Paths.sparrowAtlas('story ui');
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.playAnim('idle');
		
		add(diffSprite = new FunkinSprite(905, 475));                  // im gonna fucking end someone
		diffSprite.loadGraphic(Paths.image('difficulties'), true, 308, 67);

		add(rightArrow = new FunkinSprite(leftArrow.x + 376, leftArrow.y));
		rightArrow.frames = Paths.sparrowAtlas('story ui');
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.playAnim('idle');

		reload();
		changeSelection();

		curDiffSelected = Difficulty.list.indexOf(Difficulty.current);
		changeDifficulty();
		
		persistentUpdate = true;
	}

	var intendedScore:Int = 0;
	var lerpScore:Int = 0;
	override function update(elapsed:Float) {
		characters.update(elapsed);

		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		if (Math.abs(lerpScore - intendedScore) <= 10) lerpScore = intendedScore;
			
		scoreTxt.text = 'WEEK SCORE: $lerpScore';

		var offsetY:Float = weekSprGroup.members[curSelected].targetY;
		for (item in weekSprGroup.members)
			item.y = FlxMath.lerp(item.targetY - offsetY + 480, item.y, Math.exp(-elapsed * 10.2));

		controls();

		leftArrow.animation.play(Controls.pressed('ui_left') ? 'press' : 'idle');
		rightArrow.animation.play(Controls.pressed('ui_right') ? 'press' : 'idle');
	}

	var allowInputs:Bool = true;
	function controls() {
		if (!allowInputs) return;

		if (Controls.justPressed('back') || FlxG.mouse.justPressedRight) {
			FlxG.sound.play(Paths.sfx('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}
		
		if (Controls.justPressed('accept')) {
			allowInputs = false;
			FlxG.sound.play(Paths.sfx('confirmMenu'));
			PlayState.storyMode = true;
			PlayState.songList = curWeek.songs;
			Difficulty.current = Difficulty.list[curDiffSelected];
			for (char in characters.members) {
				if (char.name.length == 0 || !char.hasConfirmAnimation) continue;
				char.playAnim('confirm', true);
			}

			new FlxTimer().start(1, function(_) {
				Conductor.rate = 1;
				FlxG.switchState(new PlayState());
			});
		}

		var justPressedUp:Bool = Controls.justPressed('ui_up');
		if (justPressedUp || Controls.justPressed('ui_down')) changeSelection(justPressedUp ? -1 : 1);

		var leftJustPressed:Bool = Controls.justPressed('ui_left');
		if (leftJustPressed || Controls.justPressed('ui_right')) changeDifficulty(leftJustPressed ? -1 : 1);
	}

	function reload():Void {
		weekSprGroup.clear();

		var itemTargetY:Float = 0;
		for (i => week in weeks) {
			var weekSprite:WeekSprite = new WeekSprite(week.image);
			weekSprite.screenCenter(X);
			weekSprite.y = 452 + ((weekSprite.height + 20) * i);
			weekSprite.targetY = itemTargetY;
			weekSprGroup.add(weekSprite);

			itemTargetY += Math.max(weekSprite.height, 110) + 10;
		}

		changeSelection();
	}

	function changeSelection(?change:Int = 0) {
		curSelected = FlxMath.wrap(curSelected + change, 0, weeks.length - 1);

		for (i => sprite in weekSprGroup.members) {
			sprite.alpha = i == curSelected ? 1 : 0.5;
		}

		for (i => item in characters.members) {
			item.name = curWeek.characters[i];
		}

		var tracks:String = '';
		var songList:Array<String> = curWeek.songs;
		for (i => song in songList) {
			tracks += song.toUpperCase();
			if (i != songList.length - 1) tracks += '\n';
		}

		tracklist.text = tracks;
		tracklist.x = tracksSprite.getGraphicMidpoint().x - (tracklist.width * 0.5);

		weekTitle.text = curWeek.title.toUpperCase();
		weekTitle.x = FlxG.width - (weekTitle.width + 10);
	}

	function changeDifficulty(?dir:Int = 0) {
		curDiffSelected = FlxMath.wrap(curDiffSelected + dir, 0, Difficulty.list.length - 1);

		intendedScore = 0;
		for (song in curWeek.songs) {
			intendedScore += Scores.get(song, Difficulty.list[curDiffSelected]).score;
		}

		diffSprite.alpha = 0;
		diffSprite.animation.frameIndex = curDiffSelected;
		diffSprite.y = leftArrow.y - diffSprite.height + 50;

		FlxTween.cancelTweensOf(diffSprite);
		FlxTween.tween(diffSprite, {y: diffSprite.y + 30, alpha: 1}, 0.07);
	}
}

typedef WeekData = {
	var characters:Array<String>;
	var songs:Array<String>;
	var title:String;
	var image:String;
}

private class WeekSprite extends FunkinSprite {
	public var targetY:Float;

	public function new(name:String) {
		super();
		loadGraphic(Paths.image('storymenu/$name'));
	}	
}

class MenuCharacter extends FunkinSprite {
	public var name(default, set):String;
	public var hasConfirmAnimation:Bool = false;

	public function new(?x:Float, ?y:Float, ?name:String = 'bf') {
		super(x, y);
		frames = Paths.sparrowAtlas('campaign_menu_UI_characters');
		this.name = name;
	}

	function set_name(value:String):String {
		if (name == value) return value;

		if (value.length == 0) {
			visible = false;
			return name = value;
		}

		visible = true;
		scale.set(1, 1);
		offset.set(0, 0);
		flipX = false;
		hasConfirmAnimation = false;

		switch value {
			case 'bf':
				hasConfirmAnimation = true;
				animation.addByPrefix('idle', 'BF idle dance white', 24, true);
				animation.addByPrefix('confirm', 'BF HEY!!', 24, false);
				scale.set(0.8, 0.8);
				offset.set(40, 0);

			case 'gf':
				animation.addByPrefix('idle', 'GF Dancing Beat WHITE', 24, true);
				scale.set(0.5, 0.5);
				offset.set(0, 75);

			case 'dad':
				animation.addByPrefix('idle', 'Dad idle dance BLACK LINE', 24, true);
				scale.set(0.4, 0.4);
				offset.set(150, 75);

			case 'kids': 
				animation.addByPrefix('idle', 'spooky dance idle BLACK LINES', 24, true);
				scale.set(0.5, 0.5);
				offset.set(150, 20);

			case 'pico': 
				animation.addByPrefix('idle', 'Pico Idle Dance', 24, true);
				scale.set(0.7, 0.7);
				offset.set(150, 20);
				flipX = true;

			case 'mom':
				animation.addByPrefix('idle', 'Mom Idle BLACK LINES', 24, true);
				scale.set(0.4, 0.4);
				offset.set(110, 95);

			case 'parents':
				animation.addByPrefix('idle', 'Parent Christmas Idle Black Lines', 24, true);
				scale.set(0.4, 0.4);
				offset.set(250, 70);
			
			case 'senpai':
				animation.addByPrefix('idle', 'SENPAI idle Black Lines', 24, true);
				offset.set(100, -50);
		}

		playAnim('idle');

		return name = value;
	}
}
