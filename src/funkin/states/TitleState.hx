package funkin.states;

class TitleState extends FunkinState {
	var gf:FunkinSprite;
	var logo:FunkinSprite;
	var text:FunkinSprite;
	var alphabet:Alphabet;
	var titleGroup:FlxTypedSpriteGroup<FunkinSprite>;

	var curWacky:Array<String> = [];
	var textColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var textAlphas:Array<Float> = [1, .64];
	var seenIntro:Bool = false;
	var accepted:Bool = false;
	override function create():Void {
		super.create();

		Conductor.bpm = 102;
		Conductor.inst = FlxG.sound.load(Paths.music('freakyMenu'), 0, true);
		curWacky = FlxG.random.getObject(getIntroTexts());

		add(titleGroup = new FlxTypedSpriteGroup<FunkinSprite>());

		titleGroup.add(gf = new FunkinSprite(512, 40));
		gf.frames = Paths.sparrowAtlas('gfDanceTitle');
		gf.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
		gf.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
		gf.playAnim('danceLeft');

		titleGroup.add(logo = new FunkinSprite(-150, 0));
		logo.frames = Paths.sparrowAtlas(Main.watermarks ? 'KadeEngineLogoBumpin' : 'logoBumpin');
		logo.y = Main.watermarks ? 1500 : -100;
		logo.animation.addByPrefix('fuck', 'logo bumpin', 24, false);
		logo.playAnim('fuck');

		titleGroup.add(text = new FunkinSprite(100, 576));
		text.frames = Paths.sparrowAtlas('pressEnter');
		text.animation.addByPrefix('idle', 'ENTER IDLE', 0, false);
		text.animation.addByPrefix('pressed', 'ENTER PRESSED', 24, true);
		text.playAnim('idle');

		add(alphabet = new Alphabet(0, 200, '', BOLD, CENTER));
		alphabet.fieldWidth = FlxG.width;

		Conductor.play();
		Conductor.inst.fadeIn(4, 0, 0.7);
		titleGroup.visible = false;
		persistentUpdate = true;
	}

	var titleTimer:Float = 0;
	function updateText(elapsed:Float) {
		if (!seenIntro || accepted) return;

		titleTimer += FlxMath.bound(elapsed, 0, 1);
		if (titleTimer > 2) titleTimer -= 2;

		var timer:Float = titleTimer;
		if (timer >= 1) timer = -timer + 2;
				
		timer = FlxEase.quadInOut(timer);
				
		text.color = FlxColor.interpolate(textColors[0], textColors[1], timer);
		text.alpha = FlxMath.lerp(textAlphas[0], textAlphas[1], timer);
	}

	var time:Float = 0.0;
	override function update(elapsed:Float) {
		titleGroup.update(elapsed);
		updateText(elapsed);

		if (Main.watermarks) {
			time += elapsed;
			var axis:Float = (time % 8 >= 4) ? -1 : 1;
			logo.angle = FlxMath.lerp(-axis * 4, axis * 4, FlxEase.quartInOut((time % 4) / 4));
		}

		if (Controls.justPressed('accept') || FlxG.mouse.justPressed) {
			if (accepted) {
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.switchState(new MainMenuState());
				return;
			}

			if (!seenIntro) skipIntro();
			else {
				accepted = true;
				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sfx('confirmMenu'), 0.7);
				text.color = FlxColor.WHITE;
				text.alpha = 1;
				text.playAnim('pressed');
				new FlxTimer().start(2, function(_) {
					FlxG.switchState(new MainMenuState());
				});
			}
		}
	}

	function getIntroTexts():Array<Array<String>> 
		return [for (i in Paths.text('data/introText.txt').split('\n')) i.split('--')];

	var curBeat:Int = 0;
	override function beatHit(_) {
		curBeat++;

		logo.playAnim('fuck', true);
		gf.playAnim('dance${curBeat % 2 == 0 ? 'Left' : 'Right'}', true);

		if (seenIntro) return;

		switch curBeat {
			case 1:
				alphabet.text = 'ninjamuffin99\nphantomArcade\nkawaisprite\nevilsk8er';
			case 3:
				alphabet.text += '\npresent';
			case 4:
				alphabet.text = '';
			case 5:
				if (Main.watermarks)
					alphabet.text = 'Kade Engine\nby';
				else
					alphabet.text = 'In Partnership\nwith';
			case 7:
				if (Main.watermarks)
					alphabet.text += '\nKadeDeveloper';
				else {
					alphabet.text += 'Newgrounds';
					//ngSpr.visible = true;
				}
			case 8:
				alphabet.text = '';
				//ngSpr.visible = false;
			case 9:
				alphabet.text = curWacky[0];
			case 11:
				alphabet.text += '\n${curWacky[1]}';
			case 12:
				alphabet.text = '';
			case 13:
				alphabet.text = 'Friday';
			case 14:
				alphabet.text += '\nNight';
			case 15:
				alphabet.text += '\nFunkin';

			case 16:
				skipIntro();
		}
	}

	function skipIntro() {
		if (seenIntro) return;
		seenIntro = true;
		FlxG.camera.flash(FlxColor.WHITE, 2);
		Conductor.inst.time = 9400;
		if (Conductor.inst.fadeTween != null) Conductor.inst.fadeTween.cancel();
		Conductor.inst.volume = 0.7;

		titleGroup.visible = true;
		remove(alphabet);
		alphabet.destroy();

		if (Main.watermarks) {
			FlxTween.tween(logo, {y: -100}, 1.4, {ease: FlxEase.expoInOut});
		}
	}
}