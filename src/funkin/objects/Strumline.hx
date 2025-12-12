package funkin.objects;

import funkin.objects.Note;

class Strumline extends FlxTypedSpriteGroup<StrumNote> {
	public static var size(default, set):Float = 0.65;
	static function set_size(value:Float) {
		swagWidth = 160.0 * value;
		return size = value;
	}
	public static var swagWidth:Float = 160.0 * size;
	public var curHolds:Array<Sustain> = [];
	public dynamic function character():Character return null;

	public static var keyCount:Int = 4;
	public var centerX:Float = 0;
	public var ai:Bool;
	
	public function new(?x:Float, ?y:Float, ?player:Bool = false, ?skin:String) {
		super(x, y);
		this.ai = !player;

		regenerate();

		// center the strumline on the x position we gave it
		// instead of basing the x position on the left side of the x axis
		this.x = x - (width * 0.5);
		centerX = x;
	}

	public function regenerate() {
		clear();

		var strum:StrumNote = null;
		for (i in 0...keyCount) {
			add(strum = new StrumNote(this, i));
			strum.scale.set(size, size);
			strum.updateHitbox();
			strum.x += swagWidth * i;
			strum.y += (swagWidth - strum.height) * 0.5;
		}
	}

	override function set_x(Value:Float):Float {
		centerX += Value - x;
		return super.set_x(Value);
	}
}

class StrumNote extends FunkinSprite {
	public var parent:Strumline;
	public var lane:Int;
	public var isHolding:Bool = false;
	public var quantColors:Bool = false;
	public function new(parent:Strumline, lane:Int) {
		super();

		this.parent = parent;
		this.lane = lane;

		animation.finishCallback = anim -> {
			active = false;
			
			var waitForAnim = !parent.ai || isHolding;

			if (waitForAnim || anim != 'notePressed') return;
			playAnim('default');
		}

		frames = Note.getSkin(Settings.data.noteskin);
		animation.addByPrefix('default', 'arrow${Note.directions[lane].toUpperCase()}', 24, true);
		animation.addByPrefix('pressed', '${Note.directions[lane]} press', 48, false);
		animation.addByPrefix('notePressed', '${Note.directions[lane]} confirm', 48, false);

		playAnim('default');
	}

	override function playAnim(name:String, ?forced:Bool = true) {
		quantColors = false;
		color = 0xFFFFFFFF;
		active = true;
		if (animation.exists(name)) animation.play(name, forced);
		centerOffsets();
		centerOrigin();
	}

	override public function drawComplex(camera:FlxCamera) {
		_frame.prepareMatrix(_matrix, ANGLE_0, checkFlipX(), checkFlipY());
		prepareMatrix(_matrix, camera);
		camera.drawNote(_frame, _matrix, colorTransform, blend, antialiasing, quantColors);
	}
}