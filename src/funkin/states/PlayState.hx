package funkin.states;

import funkin.objects.Strumline;
import funkin.objects.Note;
import funkin.objects.Character;
import funkin.backend.Song.Chart;
import funkin.objects.JudgementSpr;
import funkin.objects.ComboNums;
import funkin.objects.Bar;
import funkin.objects.CharIcon;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxStringUtil;
import funkin.objects.PlayField;
import funkin.substates.PauseMenu;
import funkin.substates.ResultsScreen;
#if FEATURE_STEPMANIA import moonchart.formats.StepMania; #end
import funkin.objects.Countdown;
import funkin.substates.OptionsMenu;
import funkin.objects.HitGraph;
import funkin.substates.GameOverSubstate;
import flixel.FlxObject;
import flixel.FlxBasic;

typedef PlayData = {
	var songName:String;
	var ?difficulty:String;
	var hits:Array<HitData>;
	var score:Int;
	var comboBreaks:Int;
	var highestCombo:Int;
	var accuracy:Float;
}

class PlayState extends FunkinState {
	var scoreTxt:FlxText;
	var healthBar:Bar;
	var iconP1:CharIcon;
	var iconP2:CharIcon;
	var timeBar:Bar;
	var timeTxt:FlxText;
	var judgeCounter:FlxText;
	var botplayTxt:FlxText;
	var playerStrums:Strumline;
	var opponentStrums:Strumline;

	public static var songID:String = '';
	public var songName:String = '';
	public static var song:Chart;
	public static var isSimfile:Bool = false;
	public static var storyMode:Bool = false;
	var skipCountdown:Bool = false;
	static var currentLevel:Int = 0;
	public static var songList:Array<String> = [];
	public static var self:PlayState;
	var died:Bool = false;
	var accuracyType:String = 'simple';
	var playfield:PlayField;

	var camOther:FlxCamera;
	var camHUD:FlxCamera;
	var hud:FlxSpriteGroup;
	
	var health(default, set):Float = 50;
	function set_health(value:Float):Float {
		value = FlxMath.bound(value, 0, 100);

		if (value <= 0) die();

		// update health bar
		health = value;
		healthBar.percent = FlxMath.remapToRange(FlxMath.bound(health, healthBar.bounds.min, healthBar.bounds.max), healthBar.bounds.min, healthBar.bounds.max, 0, 100);

		iconP1.animation.curAnim.curFrame = healthBar.percent < 20 ? 1 : 0; //If health is under 20%, change player icon to frame 1 (losing icon), otherwise, frame 0 (normal)
		iconP2.animation.curAnim.curFrame = healthBar.percent > 80 ? 1 : 0; //If health is over 80%, change opponent icon to frame 1 (losing icon), otherwise, frame 0 (normal)

		return health = value;
	}

	@:unreflective var disqualified:Bool = false;

	@:isVar public var botplay(get, set):Bool = false;

	var metronome:Bool = false;
	function set_botplay(value:Bool):Bool {
		// prevents players from just having botplay on the entire time
		// and then turning it off at the last note
		// and saving the play
		if (value) disqualified = true;

		playfield.botplay = value;
		botplayTxt.visible = value;
		return botplay = value;
	}

	function get_botplay():Bool {
		if (playfield == null) return false;
		// preventing someone doing `game.playfield.botplay = true;`
		// to get around disqualifying
		if (playfield.botplay) disqualified = true;
		return playfield.botplay;
	}

	var combo:Int = 0;
	var highestCombo:Int = 0;
	var score:Int = 0;
	var accuracy:Float = 0;
	var comboBreaks:Int = 0;
	var totalNotesPlayed:Float = 0;
	var totalNotesHit:Int = 0;
	var clearType:String;

	var judgeSprite:JudgementSpr;
	var comboNumbers:ComboNums;
	var countdown:Countdown;

	var bf:Character;
	var dad:Character;
	var gf:Character;

	public var defaultCamZoom:Float = 1;
	public var defaultHudZoom:Float = 1;
	var camFollow:FlxObject;

	var hits:Array<HitData> = [];
	var nps:Int = 0;
	var maxNPS:Int = 0;

	override function create() {
		FlxTransitionableState.skipNextTransIn = true;
		super.create();

		self = this;
		
		if (storyMode) songID = songList[currentLevel];

		var strumlineYPos:Float = Settings.data.downscroll ? FlxG.height - 50 - Strumline.swagWidth : 50;

		add(camFollow = new FlxObject(0, 0, 1, 1));

		FlxG.camera.visible = !Settings.data.optimize;
		camHUD = FlxG.cameras.add(new FlxCamera(), false);
		camHUD.bgColor.alpha = 0;

		camOther = FlxG.cameras.add(new FlxCamera(), false);
		camOther.bgColor.alpha = 0;

		accuracyType = Settings.data.accuracyType;

		add(gf = new Character(0, 0, 'gf', false));
		gf.screenCenter();
		add(bf = new Character(800, -100, 'bf'));
		add(dad = new Character(0, 0, 'dad', false));

		// fix for the camera starting off in the stratosphere
		camFollow.setPosition(gf.getMidpoint().x + gf.cameraOffset.x, gf.getMidpoint().y + gf.cameraOffset.y);

		FlxG.camera.follow(camFollow, LOCKON, 0);
		FlxG.camera.snapToTarget();

		opponentStrums = new Strumline(320, strumlineYPos);
		opponentStrums.character = function() return dad;
		playerStrums = new Strumline(960, strumlineYPos, true);
		playerStrums.character = function() return bf;

		var playerLaneUnderlay = new FunkinSprite(playerStrums.x).makeGraphic(1, 1, FlxColor.BLACK);
		playerLaneUnderlay.scale.set(playerStrums.width + 20, FlxG.height);
		playerLaneUnderlay.updateHitbox();
		playerLaneUnderlay.x += ((playerStrums.width - playerLaneUnderlay.scale.x) / 2);
		playerLaneUnderlay.alpha = Settings.data.laneUnderlay;
		playerLaneUnderlay.camera = camHUD;
		add(playerLaneUnderlay);

		var opponentLaneUnderlay = new FunkinSprite(opponentStrums.x).makeGraphic(1, 1, FlxColor.BLACK);
		opponentLaneUnderlay.scale.set(opponentStrums.width + 20, FlxG.height);
		opponentLaneUnderlay.updateHitbox();
		opponentLaneUnderlay.x += ((opponentStrums.width - opponentLaneUnderlay.scale.x) / 2);
		opponentLaneUnderlay.alpha = Settings.data.laneUnderlay;
		opponentLaneUnderlay.camera = camHUD;
		add(opponentLaneUnderlay);

		add(playfield = new PlayField([opponentStrums, playerStrums], 1));
		playfield.cameras = [camHUD];
		playfield.noteHit = noteHit;
		playfield.noteMiss = noteMiss;
		playfield.sustainHit = sustainHit;
		playfield.ghostTap = ghostTap;

		#if FEATURE_STEPMANIA 
		if (isSimfile) loadSimfile(songID);
		else
		#end 
		loadSong(songID);

		playfield.rate = Conductor.rate;
		playfield.scrollSpeed = (Settings.data.scrollSpeed == 1 ? song.speed : Settings.data.scrollSpeed);
		playfield.scrollSpeed /= Conductor.rate;
		playfield.downscroll = Settings.data.downscroll;

		makeStage(song.stage);
		moveCamera();

		if (Settings.data.centeredNotes) {
			opponentStrums.visible = opponentLaneUnderlay.visible = false;
			playerStrums.screenCenter(X);
			playerLaneUnderlay.screenCenter(X);
		}

		add(hud = new FlxSpriteGroup());
		hud.cameras = [camHUD];

		hud.add(judgeSprite = new JudgementSpr(400, 300));
		hud.add(comboNumbers = new ComboNums(400, 425));

		hud.add(healthBar = new Bar(0, Settings.data.downscroll ? 50 : 648, 'ui/healthBar', function() return health, 0, 100));
		healthBar.setColors(FlxColor.RED, FlxColor.LIME);
		healthBar.leftToRight = false;
		healthBar.screenCenter(X);
		healthBar.visible = Settings.data.healthBar;

		hud.add(iconP1 = new CharIcon(bf.icon, true));
		iconP1.y = healthBar.y - (iconP1.height * 0.5);
		iconP1.visible = Settings.data.healthBar;

		hud.add(iconP2 = new CharIcon(dad.icon));
		iconP2.y = healthBar.y - (iconP2.height * 0.5);
		iconP2.visible = Settings.data.healthBar;

		hud.add(judgeCounter = new FlxText(5, 0, 0, ''));
		judgeCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgeCounter.borderSize = 2;
		judgeCounter.borderQuality = 2;
		judgeCounter.scrollFactor.set();
		judgeCounter.visible = Settings.data.judgeCounter;
		updateJudgeCounter();
		judgeCounter.screenCenter(Y);

		hud.add(scoreTxt = new FlxText(0, Settings.data.downscroll ? 100 : 695, FlxG.width, '', 16));
		scoreTxt.font = Paths.font('vcr.ttf');
		scoreTxt.alignment = 'center';
		scoreTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
		scoreTxt.borderColor = FlxColor.BLACK;
		scoreTxt.screenCenter(X);
		updateScoreTxt();

		hud.add(botplayTxt = new FlxText(0, Settings.data.downscroll ? 200 : 548, 1000, "BOTPLAY", 20));
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.screenCenter(X);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 4;
		botplayTxt.borderQuality = 2;

		// pre-1.8 time bar
/*		add(timeBar = new Bar(0, 20, 'ui/healthBar', function() {
			return Conductor.inst.time;
		}, 0, Conductor.inst.length));
		timeBar.setColors(FlxColor.LIME, FlxColor.GRAY);
		timeBar.screenCenter(X);

		add(timeTxt = new FlxText(0, timeBar.y, FlxG.width, 'Fuck', 16));
		timeTxt.font = Paths.font('vcr.ttf');
		timeTxt.alignment = 'center';
		timeTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
		timeTxt.borderColor = FlxColor.BLACK;
		timeTxt.setPosition(timeBar.getMidpoint().x - (timeTxt.width * 0.5), timeBar.getMidpoint().y - (timeTxt.height * 0.5));*/

		// 1.8 time bar
		hud.add(timeBar = new Bar(0, Settings.data.downscroll ? 683 : 14, 'ui/timeBar', function() {
			if (Conductor.inst == null) return 0;
			return Conductor.inst.time;
		}, 0, Conductor.inst.length));
		timeBar.setColors(FlxColor.fromRGB(0, 255, 128), FlxColor.BLACK);
		timeBar.screenCenter(X);
		timeBar.visible = Settings.data.timeBar;

		hud.add(timeTxt = new FlxText(0, 0, timeBar.width, '$songName (0:00)', 16));
		timeTxt.font = Paths.font('vcr.ttf');
		timeTxt.alignment = 'center';
		timeTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
		timeTxt.borderColor = FlxColor.BLACK;
		timeTxt.borderSize = 1.25;
		timeTxt.setPosition(timeBar.getMidpoint().x - (timeTxt.width * 0.5), timeBar.getMidpoint().y - (timeTxt.height * 0.5));
		timeTxt.visible = Settings.data.timeBar;

		var watermark:FlxText = new FlxText(5, 695, 0, '$songName - ${isSimfile ? 'StepMania' : Difficulty.current} | KE 1.8', 16);
		watermark.font = Paths.font('vcr.ttf');
		watermark.borderStyle = FlxTextBorderStyle.OUTLINE;
		watermark.borderColor = FlxColor.BLACK;
		hud.add(watermark);

		hud.add(countdown = new Countdown());
		countdown.screenCenter();
		countdown.onStart = function() {
			Conductor.playing = true;
		}
		countdown.onFinish = function() {
			Conductor.play();
		}

		if (skipCountdown) {
			countdown.finished = true;
			countdown.onFinish();
		} else {
			Conductor._time = (Conductor.crotchet * -4);
			countdown.starting = true;
			countdown.start();
		}

		persistentUpdate = true;
		FlxG.mouse.visible = false;
		botplay = Settings.data.botplay;

		if (Settings.data.timeBar) {
			new FlxTimer().start(1, function(_) {
				timeTxt.text = '$songName (${FlxStringUtil.formatTime(Conductor.rawTime / 1000, false)})';

				nps = 0;
			}, 0);
		}
	}

	function noteHit(strumline:Strumline, note:Note) {
		var character = strumline.character();
		character.playAnim('sing${Note.directions[note.data.lane].toUpperCase()}', true);

		if (note.data.player != playfield.playerID) return;

		if (botplay) {
			judgeSprite.display(Judgement.list[1].timing);
			hits.push({
				time: note.time,
				diff: 90,
				judge: null
			});
			return;
		}

		var adjustedHitTime:Float = note.hitTime / playfield.rate;
		var judge:Judgement = Judgement.getFromTiming(adjustedHitTime);
		judge.hits++;

		score += judge.score;
		health += judge.health;
		nps++;
		if (maxNPS < nps) maxNPS = nps;

		switch accuracyType.toLowerCase() {
			case 'simple':
				totalNotesPlayed += judge.accuracy;
				totalNotesHit++;

			case 'complex':
				totalNotesPlayed += Etterna.wife3(adjustedHitTime);
				totalNotesHit += 2;
		}

		hits.push({
			time: note.time,
			diff: adjustedHitTime,
			judge: judge.name
		});

		accuracy = updateAccuracy();

		judgeSprite.display(adjustedHitTime);
		if (judge.breakCombo) {
			comboBreaks++;
			combo = 0;
		} else {
			comboNumbers.display(++combo);
			if (combo > highestCombo) highestCombo = combo;
		}

		updateScoreTxt();
		updateJudgeCounter();
	}

	function sustainHit(strumline:Strumline, note:Note, mostRecent:Bool) {
		if (!mostRecent) return;

		var character = strumline.character();
		character.playAnim('sing${Note.directions[note.data.lane].toUpperCase()}', true);
	}

	function updateJudgeCounter() {
		 if (!Settings.data.judgeCounter) return;

		var sicks:Int = Judgement.list[0].hits;
		var goods:Int = Judgement.list[1].hits;
		var bads:Int = Judgement.list[2].hits;
		var shits:Int = Judgement.list[3].hits;
		var misses:Int = FlxMath.maxInt(0, comboBreaks - shits);

		var resultText:String = 'Sicks: $sicks\nGoods: $goods\nBads: $bads\nShits: $shits\nMisses: $misses';

		judgeCounter.text = resultText;
	}

	function noteMiss(strumline:Strumline, note:Note) {
		var character = strumline.character();
		character.playAnim('miss${Note.directions[note.data.lane].toUpperCase()}', true);

		score -= 10; // why does missing subtract score by 10 but shits subtract by 300 ????????????? kade what are you doing

		comboBreaks++;
		combo = 0;
		health -= 7.5; // oh my GOD WHAT THE FUCK

		if (accuracyType.toLowerCase() == 'complex') {
			if (note.isSustain) totalNotesPlayed += Etterna.holdDropWeight;
			else {
				totalNotesPlayed += Etterna.missWeight;
				totalNotesHit += 2;
			}
		}

		hits.push({
			time: note.time,
			diff: 180,
			judge: 'miss',
			countMean: false
		});

		accuracy = updateAccuracy();
		updateScoreTxt();
		updateJudgeCounter();
	}

	function ghostTap(strumline:Strumline, dir:Int) {
		if (Settings.data.ghostTapping) return;

		health -= 10; // GOD DAMN KADE HOLY SHIT actually ykw to an extent it makes sense
	}

	function updateAccuracy() {
		switch accuracyType.toLowerCase() {
			case 'simple':
				return totalNotesPlayed / (totalNotesHit + comboBreaks);

			case 'complex':
				if (totalNotesHit <= 0) return 0.0;
				return (totalNotesPlayed / totalNotesHit) * 100;

			case _:
				return 0.0;
		}
	}

	var bg:FunkinSprite;
	var front:FunkinSprite;
	var leftLight:FunkinSprite;
	var rightLight:FunkinSprite;
	var curtains:FunkinSprite;
	function makeStage(name:String) {
		switch name {
			// i can't be bothered to port the other stages so week 1 works for now
			default:
				var assets = Paths.sparrowAtlas('week 1');
				addBehindObject(bg = new FunkinSprite(-600, -200), gf);
				bg.frames = assets;
				bg.animation.addByPrefix('FUCK', 'stageback', 0, false);
				bg.animation.play('FUCK');

				addBehindObject(front = new FunkinSprite(-650, 600), gf);
				front.frames = assets;
				front.animation.addByPrefix('FUCK', 'stagefront', 0, false);
				front.animation.play('FUCK');

				add(leftLight = new FunkinSprite(-125, -100));
				leftLight.frames = assets;
				leftLight.animation.addByPrefix('FUCK', 'stage_light', 0, false);
				leftLight.animation.play('FUCK');
				leftLight.scrollFactor.set(0.9, 0.9);

				add(rightLight = new FunkinSprite(1225, -100));
				rightLight.frames = assets;
				rightLight.animation.addByPrefix('FUCK', 'stage_light', 0, false);
				rightLight.animation.play('FUCK');
				rightLight.scrollFactor.set(0.9, 0.9);
				rightLight.flipX = true;

				add(curtains = new FunkinSprite(-500, -300));
				curtains.frames = assets;
				curtains.animation.addByPrefix('FUCK', 'stagecurtains', 0, false);
				curtains.animation.play('FUCK');
				curtains.scrollFactor.set(1.3, 1.3);

				bf.setPosition(900, 100);
				gf.setPosition(530, -50);
				dad.setPosition(200, 100);

				FlxG.camera.zoom = defaultCamZoom = 0.9;
		}
	}

	function addBehindObject(obj:FlxBasic, target:FlxBasic) {
		var position:Int = members.indexOf(target);
		if (position == -1) position = members.length;

		return insert(position, obj);
	}

	function updateScoreTxt() {
		// fucking hell dude
		clearType = Judgement.getClearType(null, comboBreaks);
		var npsText:String = 'NPS: $nps (Max $maxNPS) | ';

		var textToSet:String = (Settings.data.notesPerSecond ? npsText : '') + 'Score: $score | Combo Breaks: ${comboBreaks} |${Settings.data.accuracy ? ' Accuracy: ${MathUtil.truncateFloat(accuracy, 2)}% |' : ''} ($clearType)';
		if (totalNotesHit > 0) textToSet += ' ${Judgement.getRank(accuracy)}';

		scoreTxt.text = textToSet;
	}

	function updateIconScales(delta:Float):Void {
		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, Math.exp(-delta * 9));
		iconP1.scale.set(mult, mult);
		iconP1.centerOrigin();

		mult = FlxMath.lerp(1, iconP2.scale.x, Math.exp(-delta * 9));
		iconP2.scale.set(mult, mult);
		iconP2.centerOrigin();
	}

	var iconSpacing:Float = 20;
	function updateIconPositions():Void {
		iconP1.x = healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconSpacing;
		iconP2.x = healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconSpacing * 2;
	}

	#if FEATURE_STEPMANIA
	function loadSimfile(songID:String) {
		var simfile = new StepMania().fromFile(Song.getSimfilePath(songID));
		songName = simfile.data.TITLE;

		var timingPoints:Array<Conductor.TimingPoint> = [];
		var smMeta = simfile.getChartMeta();
		for (point in smMeta.bpmChanges) {
			timingPoints.push({
				time: point.time,
				bpm: point.bpm,
			});
		}

		var fnf = new funkin.backend.Song.FNFChart();
		song = cast fnf.fromFormat(simfile).data.song;

		Conductor.timingPoints = timingPoints;
		Conductor.bpm = smMeta.bpmChanges[0].bpm;
		Conductor.offset = smMeta.offset;
		Conductor.inst = FlxG.sound.load(Paths.audio('sm/$songID/${simfile.data.MUSIC}'));
		Conductor.inst.onComplete = function() finish();

		playfield.load(song);
	}
	#end

	function loadSong(songID:String) {
		song = Song.load(songID, Difficulty.current);
		songName = song.songName;

		var timingPoints:Array<Conductor.TimingPoint> = [];

		var time:Float = 0;
		var beat:Float = 0;
		var crotchet:Float = (60 / song.bpm) * 1000;
		for (event in song.eventObjects) {
			time += (event.position - beat) * crotchet;
			beat = event.position;
			crotchet = (60 / event.value) * 1000;

			timingPoints.push({
				time: time,
				bpm: event.value
			});
		}

		Conductor.timingPoints = timingPoints;
		Conductor.bpm = song.bpm;
		Conductor.offset = song.offset;
		Conductor.inst = FlxG.sound.load(Paths.audio('songs/$songID/Inst'));
		Conductor.inst.onComplete = function() finish();

		if (song.needsVoices) Conductor.vocals = FlxG.sound.load(Paths.audio('songs/$songID/Voices'));

		playfield.load(song);
	}

	function finish() {
		if (!disqualified) {
			Scores.set({
				songID: songID,
				difficulty: Difficulty.current,

				score: score,
				clearType: clearType,
				wife3: Settings.data.wife3,
				rate: Conductor.rate
			});

			Scores.save();
		}

		endSong();
	}

	public function endSong(?forceLeave:Bool = false) {
		persistentUpdate = false;
		Conductor.playing = false;

		function leave() {
			Conductor.inst = FlxG.sound.load(Paths.audio('freakyMenu', 'music'), 0.7, true);
			Conductor.inst.play();
			Conductor.inst.pitch = 1;
			FlxG.switchState(storyMode ? new StoryMenuState() : new FreeplayState());
			songList.resize(0);
			storyMode = false;
			isSimfile = false;
			currentLevel = 0;
		}

		// just leave regardless of what happens
		if (forceLeave) {
			leave();
			return;
		}

		var exitToMenu:Bool = currentLevel + 1 >= songList.length;
		if (!storyMode) exitToMenu = true;

		if (Settings.data.resultsScreen && !ResultsScreen.seenMenu) {
			openSubState(new ResultsScreen({
				songName: songName,
				difficulty: Difficulty.current,
				hits: hits,
				score: score,
				accuracy: accuracy,
				comboBreaks: comboBreaks,
				highestCombo: highestCombo
			}));
		} else if (exitToMenu) leave();
		else {
			FlxG.resetState();
			if (storyMode) currentLevel++;
		}
	}

	override function beatHit(beat:Int):Void {
		if (died) return;

		iconP1.scale.set(1.2, 1.2);
		iconP1.updateHitbox();

		iconP2.scale.set(1.2, 1.2);
		iconP2.updateHitbox();

		if (!bf.specialAnim && beat % bf.danceInterval == 0 && bf.active) {
			bf.dance();
		}

		if (!dad.specialAnim && beat % dad.danceInterval == 0 && dad.active) {
			dad.dance();
		}

		if (!gf.specialAnim && beat % gf.danceInterval == 0 && gf.active) {
			gf.dance();
		}
	}

	override function measureHit(measure:Int) {
		if (died) return;

		if (Settings.data.cameraZooming) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.0075;
		}

		moveCamera(measure);
	}

	override function update(elapsed:Float) {
		updateIconScales(elapsed);
		updateIconPositions();
		updateCameraScale(elapsed);
		
		super.update(elapsed);

		if (Controls.justPressed('pause')) openPauseMenu();
		if (Controls.justPressed('reset') && Settings.data.resetButton) die();

		if (FlxG.keys.justPressed.F8) botplay = !botplay;

		// fixes the follow lerp still applying even after pausing 
		// but keeping it unfixed for the nostolgia sovl
		FlxG.camera.followLerp = /*paused ? 0 :*/ 0.04 * Conductor.rate;
	}

	override function destroy() {
		super.destroy();
		Judgement.resetHits();
		self = null;
	}

	// i wish i knew a better way of doing this (yandere-dev core)
	// but i guess this works for now
	override function closeSubState() {
		super.closeSubState();

		if (PauseMenu.goToOptions) {
			if (PauseMenu.goBack) {
				PauseMenu.goBack = false;
				openPauseMenu();
			} else openSubState(new OptionsMenu());
		}
	}

	function openPauseMenu() {
		Conductor.pause();
		persistentUpdate = false;
		openSubState(new PauseMenu(songName, isSimfile ? 'StepMania' : Difficulty.current, 0));
	}

	function die() {
		if (died) return;
		if (Settings.data.instantRespawn) {
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
			return;
		}

		died = true;
		persistentUpdate = false;
		FlxG.camera.visible = true;
		camHUD.visible = false;
		camOther.visible = false;
		openSubState(new GameOverSubstate(bf.x, bf.y));
	}

	function updateCameraScale(delta:Float):Void {
		if (!Settings.data.cameraZooming) return;

		final scalingMult:Float = Math.exp(-delta * 6);
		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, scalingMult);
		camHUD.zoom = FlxMath.lerp(defaultHudZoom, camHUD.zoom, scalingMult);
	}

	function moveCamera(?measure:Int = 0) {
        measure = Std.int(Math.max(0, measure));
        if (song.notes[measure] == null) return;

		var char:Character = song.notes[measure].mustHitSection != true ? dad : bf;
		if (char == null) return;
		camFollow.setPosition(char.getMidpoint().x, char.getMidpoint().y);
		camFollow.x += char.cameraOffset.x;
		camFollow.y += char.cameraOffset.y;
    }
}