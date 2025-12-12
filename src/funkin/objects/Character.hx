package funkin.objects;

class Character extends FunkinSprite {
	public static inline var default_name:String = 'bf';
	public var name(default, set):String = default_name;
	public var singDuration:Float = 4;
	public var danceInterval:Int = 2;
	public var healthColor:FlxColor = 0xFFA1A1A1;
	public var cameraOffset:FlxPoint = FlxPoint.get(0, 0);
	public var icon:String = '';
	public var dancer:Bool = false;
	public var autoIdle:Bool = true;
	public var specialAnim:Bool = false;

	function set_name(v:String):String {
		change(v);
		return name = v;
	}

	function change(name:String) {
		scale.set(1, 1);
		offset.set(0, 0);
		cameraOffset.set(0, 0);
		icon = 'bf';
		singDuration = 4;
		danceInterval = 2;
		antialiasing = true;
		flipX = false;

		switch name {
			case 'gf':
				frames = Paths.animateAtlas('characters/GF_assets');
				anim.addBySymbolIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 24, false);
				anim.addBySymbolIndices('danceRight', 'GF Dancing Beat', [for (i in 15...30) i], 24, false);
				anim.addBySymbol('singLEFT', 'GF left note', 24, false);
				anim.addBySymbol('singDOWN', 'GF Down Note', 24, false);
				anim.addBySymbol('singUP', 'GF Up Note', 24, false);
				anim.addBySymbol('singRIGHT', 'GF Right Note', 24, false);
				anim.addBySymbol('cheer', 'GF Cheer', 24, false);
				anim.addBySymbolIndices('sad', 'gf sad', [for (i in 0...13) i], 24, false);

				setOffset('singLEFT', [0, -19]);
				setOffset('singDOWN', [0, -20]);
				setOffset('singUP', [0, -4]);
				setOffset('singRIGHT', [0, -20]);
				setOffset('sad', [-2, -21]);
				offset.set(185, -124);

				icon = 'gf';
				danceInterval = 1;

			case 'dad':
				frames = Paths.sparrowAtlas('characters/daddyDearest');
				animation.addByPrefix('idle', 'idle', 24, false);
				animation.addByPrefix('singLEFT', 'singLEFT', 24, false);
				animation.addByPrefix('singDOWN', 'singDOWN', 24, false);
				animation.addByPrefix('singUP', 'singUP', 24, false);
				animation.addByPrefix('singRIGHT', 'singRIGHT', 24, false);

				setOffset('singLEFT', [-10, 9]);
				setOffset('singDOWN', [2, -31]);
				setOffset('singUP', [-9, 47]);
				setOffset('singRIGHT', [-3, 26]);
				cameraOffset.set(160, -105);
				icon = 'dad';

			case 'bf-dead':
				frames = Paths.sparrowAtlas('characters/bf-dead');
				animation.addByPrefix('idle', 'BF dies', 24, false);
				animation.addByPrefix('loop', 'BF Dead Loop', 24, false);
				animation.addByPrefix('confirm', 'BF Dead confirm', 24, false);

				setOffset('loop', [0, -6]);
				setOffset('confirm', [0, 58]);
				offset.set(55, -350);
				singDuration = 0;
				autoIdle = false;
				icon = 'bf';

			default:
				frames = Paths.sparrowAtlas('characters/bf');
				animation.addByPrefix('idle', 'idle', 24, false);
				animation.addByPrefix('singLEFT', 'sing left', 24, false);
				animation.addByPrefix('singDOWN', 'sing down', 24, false);
				animation.addByPrefix('singUP', 'sing up', 24, false);
				animation.addByPrefix('singRIGHT', 'sing right', 24, false);
				animation.addByPrefix('missLEFT', 'miss left', 24, false);
				animation.addByPrefix('missDOWN', 'miss down', 24, false);
				animation.addByPrefix('missUP', 'miss up', 24, false);
				animation.addByPrefix('missRIGHT', 'miss right', 24, false);
				animation.addByPrefix('cheer', 'hey', 24, false);
				animation.addByPrefix('scared', 'shaking', 24, true);

				setOffset('singLEFT', [11, -7]);
				setOffset('singDOWN', [-13, -52]);
				setOffset('singUP', [-41, 28]);
				setOffset('singRIGHT', [-45, -6]);
				setOffset('missLEFT', [8, 18]);
				setOffset('missDOWN', [-13, -22]);
				setOffset('missUP', [-38, 24]);
				setOffset('missRIGHT', [-40, 21]);
				setOffset('cheer', [3, 5]);
				offset.set(40, -350);
				cameraOffset.set(-250, 210);
				icon = 'bf';
		}
	}

	public function new(?x:Float, ?y:Float, ?name:String, ?player:Bool = true) {
		name ??= default_name;
		super(x, y);

		this.name = name;

		if (animation.exists('danceLeft') || animation.exists('danceRight')) {
			danceList = ['danceLeft', 'danceRight'];
			dancer = true;
		} else danceList = ['idle'];

		animation.finishCallback = anim -> {
			specialAnim = false;
			if (!animation.exists('$anim-loop')) return;
			animation.play('$anim-loop');
		}

		dance(true);
	}

	public var dancing(get, never):Bool;
	function get_dancing():Bool {
		return animation.curAnim != null && (danceList.contains(animation.curAnim.name) || loopDanceList.contains(animation.curAnim.name));
	}

	var _singTimer:Float = 0.0;
	override function update(elapsed:Float) {
		super.update(elapsed);
		if (!autoIdle || specialAnim || dancing) return;

		_singTimer -= elapsed * (singDuration * (Conductor.stepCrotchet * 0.25));
		if (_singTimer <= 0.0) dance(true);
	}

	var animIndex:Int = 0;
	var danceList(default, set):Array<String>;
	var loopDanceList:Array<String>;
	// there could be a better way of detecting looped dancing butttttt
	function set_danceList(value:Array<String>):Array<String> {
		loopDanceList = [for (anim in value) '$anim-loop'];
		return danceList = value;
	}
	public function dance(?forced:Bool = false) {
		if (!forced && animation.curAnim == null) return;

		// support for gf/spooky kids characters
		if (dancer && !forced) forced = dancing;

		var finished:Bool = animation.curAnim?.finished ?? true;
		var looped:Bool = animation.curAnim?.looped ?? false;
		if (!forced && ((dancing && (!looped && !finished)) || _singTimer > 0.0)) return;

		playAnim(danceList[animIndex]);
		animIndex = FlxMath.wrap(animIndex + 1, 0, danceList.length - 1);
	}

	override function updateHitbox():Void {
		var oldOffset:FlxPoint = FlxPoint.get();
		oldOffset.copyFrom(offset);
		super.updateHitbox();
		offset.copyFrom(oldOffset);
		oldOffset.put();
	}

	override function playAnim(name:String, ?forced:Bool = true) {
		super.playAnim(name, forced);
		if (name.startsWith('sing') || name.startsWith('miss')) {
			_singTimer = singDuration * (Conductor.stepCrotchet * 0.15);
		}
	}
}
