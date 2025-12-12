package funkin.substates;

import flixel.FlxSubState;
import funkin.objects.Note;

class OptionsMenu extends FlxSubState {
	static var curSelected:Int = 0;
	public static var visibleRange:Array<Float> = [114, 640];
	var list:Array<OptionCategory> = [
		new OptionCategory(50, 40, 'Gameplay', [
			new Option('Scroll Speed', 'scrollSpeed', 'Change your scroll speed. (1 = Chart dependent)', Float(0.5, 5, 0.05)),
			new Option('Note Offset', 'noteOffset', 'How many milliseconds a note is offset in a chart, higher = earlier.', Float(-1000, 1000, 1)),
			new Option('Accuracy Type', 'accuracyType', 'Change how accuracy is calculated. (Simple = FNF/Stepmania, Complex = Etterna Wife3)', List(['Simple', 'Complex'])),
			new Option('Ghost Tapping', 'ghostTapping', 'Toggle counting pressing a directional input when no note is there as a miss.', Bool),
			new Option('Scroll Direction', 'scrollDirection', 'Which way the notes will scroll.', List(['Up', 'Down'])),
			new Option('Botplay', 'botplay', 'A bot plays for you!', Bool),
			{
				var opt = new Option('Framerate', 'framerate', 'Change the max FPS the game can run at.', Int(30, 1000, 2));
				opt.onChange = function(v) {
					FlxG.drawFramerate = FlxG.updateFramerate = v;
				}
				opt;
			},
			new Option('Reset Button', 'resetButton', 'Toggle pressing R to game over.', Bool),
			new Option('Instant Respawn', 'instantRespawn', 'Toggle if you want to instantly respawn after dying.', Bool),
			new Option('Camera Zooming', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
			new Option('this is just filler to test clipping', 'cameraZooming', 'Toggle the camera zoom in-game.', Bool),
		]),
		new OptionCategory(345, 40, 'Appearance', [
			new Option('Noteskin', 'noteskin', 'Change your current noteskin.', List(['Arrows', 'Circles'])),
			new Option('Distractions and Effects', 'distractions', 'Toggle stage distractions that can hinder your gameplay.', Bool),
			new Option('Centered Notes', 'centeredNotes', 'Put your lane in the center or on the right.', Bool),
			new Option('Health Bar', 'healthBar', 'Toggles health bar visibility.', Bool),
			new Option('Judgement Counter', 'judgeCounter', "Show your judgements that you've gotten in the song.", Bool),
			{
				var opt = new Option('Lane Underlay', 'laneUnderlay', 'How transparent your lane is, higher = more visible', Float(0, 1, 0.05));
				opt.formatText = function() {
					return '< ${opt.value * 100}% >';
				}
				opt;
			},
			new Option('Quantization', 'quantization', 'Change the colours of the notes depending on their timing rather than their direction.', Bool),
			new Option('Display Accuracy', 'accuracy', 'Display accuracy information on the info bar.', Bool),
			new Option('Time Bar', 'timeBar', 'Show the song\'s current position as a scrolling bar.', Bool),
			new Option('Display Notes per Second', 'notesPerSecond', 'Shows your current Notes per Second on the info bar.', Bool),
			new Option('CPU Strums', 'cpuStrums', 'Toggle the CPU\'s strumline lighting up when it hits a note.', Bool),
			new Option('Optimization', 'optimize', 'Disables the game camera, so the game runs faster.', Bool)
		]),
		new OptionCategory(640, 40, 'Misc', [
			new Option('FPS Counter', 'fpsCounter', 'Toggle the FPS counter.', Bool),
			new Option('Flashing Lights', 'flashingLights', 'Toggle flashing lights that can cause epileptic seizures and strain.', Bool),
			new Option('Watermarks', 'watermarks', 'Enable and disable all watermarks from the engine.', Bool),
			new Option('Antialiasing', 'antialiasing', 'Toggle antialiasing, improving graphics quality at a slight performance penalty.', Bool),
			new Option('Results Screen', 'resultsScreen', 'Show the score screen after the end of a song.', Bool),
			new Option('Hit Graph', 'hitGraph', 'Displays a graph of all of your hits in a song in the result screen.', Bool)
		]),
		new OptionCategory(935, 40, 'Saves', [
			new Option('Reset Scores', '', 'Reset your score on all songs and weeks. This is irreversible!', Button),
			new Option('Reset Settings', '', 'Reset ALL of your settings. This is irreversible!', Button)
		])
	];

	var background:FunkinSprite;
	var descBack:FunkinSprite;
	var descText:FlxText;

	var curCategory(default, set):OptionCategory;
	function set_curCategory(v:OptionCategory):OptionCategory {
		if (curCategory != null) {
			curCategory.bg.alpha = 0.3;
			curCategory.bg.color = FlxColor.BLACK;
			curCategory.focused = false;
		}

		v.bg.alpha = 0.2;
		v.bg.color = FlxColor.WHITE;

		curCategory = v;
		updateDisplay();
		return v;
	}

	var curOption(get, never):Option;
	function get_curOption():Option {
		if (curCategory == null) return null;
		return curCategory.options[curCategory.curSelected];
	}
	
	override function create():Void {
		if (PauseMenu.goToOptions) {
			var pauseBG = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
			pauseBG.scale.set(FlxG.width, FlxG.height);
			pauseBG.updateHitbox();
			pauseBG.alpha = 0.6;
			pauseBG.scrollFactor.set();
			add(pauseBG);
		}

		add(background = new FunkinSprite(50, 40).makeGraphic(1, 1, FlxColor.BLACK));
		background.scale.set(1180, 640);
		background.updateHitbox();
		background.alpha = 0.5;
		background.scrollFactor.set();

		add(descBack = new FunkinSprite(50, 640).makeGraphic(1, 1, FlxColor.BLACK));
		descBack.scale.set(1180, 38);
		descBack.updateHitbox();
		descBack.alpha = 0.3;
		descBack.scrollFactor.set();

		add(descText = new FlxText(descBack.x + 12, descBack.y + 8, 'this is a description i think !!!!!! FUCK FUCKKKKKKKKKKKKKKK'));
		descText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderSize = 2;

		for (i in 0...list.length) {
			var category = list[i];
			add(category);
		}

		curCategory = list[curSelected];
		updateDisplay(true);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var curHolding:Int = 0;
	var holdWait:Float;
	override function update(elapsed:Float) {
		var backPressed:Bool = Controls.justPressed('back');
		var leftJustPressed:Bool = Controls.justPressed('ui_left');
		var rightJustPressed:Bool = Controls.justPressed('ui_right');
		var leftPressed:Bool = Controls.pressed('ui_left');
		var rightPressed:Bool = Controls.pressed('ui_right');
		var upPressed:Bool = Controls.justPressed('ui_up');
		var downPressed:Bool = Controls.justPressed('ui_down');
		var acceptPressed:Bool = Controls.justPressed('accept');

		for (i in 0...list.length) {
			var category = list[i];
			if (FlxG.mouse.overlaps(category.bg) && (curSelected != i) && FlxG.mouse.justPressed) {
				curSelected = i;
				curCategory = category;
				curCategory.focused = true;
				curCategory.updateDisplay();
				updateDescription();
				break;
			}
		}

		if (curCategory.focused) {
			if (backPressed || FlxG.mouse.justPressedRight) {
				curCategory.focused = false;
				curCategory.updateDisplay();
				updateDescription();
				FlxG.sound.play(Paths.sfx('cancelMenu'));
			}

			if (upPressed || downPressed || FlxG.mouse.wheel != 0) {
				var dir:Int = FlxG.mouse.wheel != 0 ? -FlxG.mouse.wheel : (upPressed ? -1 : 1);
				curCategory.curSelected = FlxMath.wrap(curCategory.curSelected + dir, 0, curCategory.options.length - 1);
				curCategory.updateDisplay();
				updateDescription();
				FlxG.sound.play(Paths.sfx('scrollMenu'));
			}

			if (leftJustPressed || rightJustPressed) {
				curOption.change(leftJustPressed);
				updateOption();
				holdWait = 0.5;
				FlxG.sound.play(Paths.sfx('scrollMenu'));
			}

			if (leftPressed || rightPressed) {
				holdWait -= elapsed;
				if (holdWait <= 0) {
					holdWait = 0.035; // make the changing more consistent
					curOption.change(leftPressed);
					updateOption();
					FlxG.sound.play(Paths.sfx('scrollMenu'));
				}
			}

			if (acceptPressed) {
				if (curOption.type == Bool || curOption.type == Button) {
					curOption.change();
					if (curOption.type == Bool) updateOption();
					FlxG.sound.play(Paths.sfx('scrollMenu'));
				}
			}
		} else {
			if (backPressed || FlxG.mouse.justPressedRight) {
				if (PauseMenu.goToOptions) {
					PauseMenu.goBack = true;
					close();
				} else FlxG.switchState(new MainMenuState());
			}

			if (leftJustPressed || rightJustPressed) {
				curSelected = FlxMath.wrap(curSelected + (leftJustPressed ? -1 : 1), 0, list.length - 1);
				curCategory = list[curSelected];
				FlxG.sound.play(Paths.sfx('scrollMenu'));
			}

			if (acceptPressed) {
				curCategory.focused = true;
				curCategory.updateDisplay();
				updateDescription();
			}
		}
	}

	function updateDisplay(?forceRefresh:Bool = false) {
		for (i in 0...list.length) {
			var category = list[i];
			category.optionObjects.visible = curSelected == i;
			if (curSelected == i) {
				category.optionObjects.visible = true;
				if (!forceRefresh) category.updateDisplay();
			} else category.optionObjects.visible = false; 

			if (forceRefresh) category.updateDisplay();
		}

		updateDescription();
	}

	override function destroy() {
		super.destroy();
		Settings.save();
	}

	inline function updateDescription() {
		descText.text = curCategory.focused ? curOption.description : 'Please select a category.';
	}

	inline function updateOption() {
		curOption.parent.text = '> ${Option.getText(curOption)}';
	}
}

class OptionCategory extends FlxSpriteGroup {
	public var titleText:FlxText;
	public var bg:FunkinSprite;

	public var name:String;
	public var optionObjects:FlxTypedSpriteGroup<FlxText>;
	public var curSelected:Int = 0;
	public var focused:Bool = false;

	public var options:Array<Dynamic>;
	public function new(x:Float, y:Float, name:String, options:Array<Dynamic>, ?middleType:Bool = false) {
		super();
		this.options = options;
		scrollFactor.set();

		add(optionObjects = new FlxTypedSpriteGroup<FlxText>());

		add(bg = new FunkinSprite(x, y).makeGraphic(1, 1, FlxColor.WHITE));
		bg.scale.set(295, 64);
		bg.updateHitbox();
		bg.alpha = 0.4;
		bg.color = FlxColor.BLACK;

		add(titleText = new FlxText(x, y + 16, bg.scale.x, name));
		titleText.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleText.borderSize = 3;
		titleText.x += (bg.scale.x / 2) - (titleText.fieldWidth / 2);
		titleText.scrollFactor.set();

		for (i in 0...options.length) {
			var option = options[i];
			var text = new FlxText(72, titleText.y + 54 + (46 * i), 0, Option.getText(option));
			text.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.borderSize = 3;
			text.borderQuality = 1;
			text.scrollFactor.set();
			optionObjects.add(text);
			option.parent = text;
		}
	}

	public function updateDisplay(?forceRefresh:Bool = false) {
		if (!optionObjects.visible && !forceRefresh) return;

		for (i in 0...optionObjects.length) {
			var text = optionObjects.members[i];
			var option = options[i];
			// fuck scrolling for now i guess :clueless:
/*			if (curSelected != 0 && curSelected != options.length - 1 && options.length > 6) {
				if (curSelected >= (options.length - 1) / 2) text.y -= 46;
			}
*/
			if (
				text.y < OptionsMenu.visibleRange[0] - 24 || 
				text.y > OptionsMenu.visibleRange[1] - 24
			) text.alpha = 0;
			else {
				if (!focused) text.alpha = 0.4;
				else if (curSelected == i) {
					text.text = '> ${Option.getText(option)}';
					text.alpha = 1;
				}

				// im dumb and don't know how to put this in a else if 
				// so it goes here
				if (!focused || curSelected != i) {
					text.text = Option.getText(option);
					text.alpha = 0.4;
				}
			}
		}
	}
}

enum OptionType {
	Int(min:Int, max:Int, ?inc:Int, ?wrap:Bool);
	Float(min:Float, max:Float, ?inc:Float, ?wrap:Bool);
	Bool;
	List(options:Array<String>);
	Key;
	Button;
}

class Option {
	public var parent:FlxText;
	public var name:String;
	public var type:OptionType;
	@:isVar public var value(get, set):Dynamic;
	function get_value():Dynamic {
		return Reflect.field(Settings.data, id);
	}
	function set_value(v:Dynamic):Dynamic {
		Reflect.setField(Settings.data, id, v);
		onChange(v);
		return v;
	}

	var id:String;
	public var description:String;

	//type specific
	public var powMult:Float = 1;

	public function new(name:String, id:String, description:String, type:OptionType) {
		this.name = name;
		this.id = id;
		this.description = description;
		this.type = type;

		switch type {
			// (sorry srt)
			case Float(min, max, inc, wrap):
				// add some increment specific rounding to prevent .599999999999999999999
				inc ??= 0.05;
				// my desmos graph idea of 10 ^ floor(log(x)) did not work so now i need this
				while (inc < 1) {
					inc *= 10;
					powMult *= 10;
				}
				while (inc > 9) {
					inc *= 0.1;
					powMult *= 0.1;
				}

			// do i really have to do this for every switch case that uses enums
			case _:
		}
	}

	public function change(?left:Bool) {
		switch type {
			case Bool:
				value = !value;

			case Int(min, max, inc, wrap):
				inc ??= 1;
				inc *= left ? -1 : 1;
				wrap ??= false;

				var curVal:Float = value;
				final range = (max - min);
				// fuck you too FlxMath
				curVal = wrap ? (((curVal - min) + inc + range) % range) + min : FlxMath.bound(curVal + inc, min, max);
				value = Std.int(curVal);

			case Float(min, max, inc, wrap):
				inc ??= 0.05;
				inc *= left ? -1 : 1;
				wrap ??= false;

				var curVal:Float = value;
				final range = (max - min);
				// fuck you too FlxMath
				curVal = wrap ? (((curVal - min) + inc + range) % range) + min : FlxMath.bound(curVal + inc, min, max);
				value = Math.round(curVal * powMult) / powMult;

			case List(list):
				final inc:Int = left ? -1 : 1;
				value = list[FlxMath.wrap(list.indexOf(value) + inc, 0, list.length - 1)];

			case Button: onChange(null);

			case _:
		}
	}

	public dynamic function onChange(v:Dynamic) {}

	public dynamic function formatText():String {
		var result:String = '';
		switch type {
			case Bool:
				result = value ? 'ON' : 'OFF';

			case _:
				result = '< $value >';
		}

		return result;
	}

	public static function getText(option:Option):String {
		var result:String = option.name;

		if (option.type == Button) return result;
		return '$result: ${option.formatText()}';
	}
}