package funkin.objects;

import funkin.backend.Judgement;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using flixel.util.FlxColorTransformUtil;

class JudgementSpr extends FunkinSprite {
	// using this instead of `alpha`
	// so you can set the `alpha` variable without fucking up anything
	var visibility(default, set):Float = 1;
	function set_visibility(v:Float):Float {
		if (visibility == v) return v;

		visibility = FlxMath.bound(v, 0, 1);
		updateColorTransform();
		return visibility;
	}

	var originalPos:FlxPoint;

	public function new(?x:Float, ?y:Float) {
		super(x, y);
		loadGraphic(Paths.image('ui/judgements'), true, 400, 150);
		originalPos = FlxPoint.get(x, y);
		
		visibility = 0;
		acceleration.y = 550;

		moves = true;
		active = true;
		scale.set(0.7, 0.7);
		updateHitbox();
	}
	
	public function display(timing:Float) {
		animation.frameIndex = Judgement.getIDFromTiming(timing);

		setPosition(originalPos.x, originalPos.y);
		velocity.set(-FlxG.random.int(0, 10), -FlxG.random.int(140, 175));
		visibility = 1;

		FlxTween.cancelTweensOf(this);
		FlxTween.tween(this, {visibility: 0}, 0.2, {startDelay: Conductor.crotchet * 0.001});
	}

	override function draw():Void {
		if (visibility <= 0) return;

		super.draw();
	}

	override function updateColorTransform():Void {
		if (colorTransform == null) return;

		useColorTransform = alpha != 1 || visibility != 1 || color != 0xffffff;
		if (useColorTransform) this.colorTransform.setMultipliers(color.redFloat, color.greenFloat, color.blueFloat, visibility * alpha);
		else this.colorTransform.setMultipliers(1, 1, 1, 1);

		dirty = true;
	}
}