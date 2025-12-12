package funkin.substates;

import flixel.FlxObject;
import funkin.objects.Character;

class GameOverSubstate extends FunkinSubstate {
	var bf:Character;
	var camFollow:FlxObject;

	public function new(x:Float, y:Float) {
		super();

		var bro = new FunkinSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
		bro.scale.set(FlxG.width * 2, FlxG.height * 2);
		bro.updateHitbox();
		add(bro);

		add(bf = new Character(x, y, 'bf-dead'));
		add(camFollow = new FlxObject(bf.getGraphicMidpoint().x - bf.offset.x, bf.getGraphicMidpoint().y - bf.offset.y, 1, 1));

		FlxG.sound.play(Paths.sfx('fnf_loss_sfx'));
		Conductor.timingPoints = null;
		Conductor.bpm = 100;
		FlxG.camera.follow(camFollow, LOCKON, 1);
		FlxG.camera.snapToTarget();

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));

		Conductor.stop();
		Conductor.inst = FlxG.sound.load(Paths.music('gameOver'), 1, true);
		Conductor.vocals = null;
	}

	var startVibin:Bool = false;

	override function update(elapsed:Float) {
		bf.update(elapsed);

		if (Controls.justPressed('accept')) endBullshit();

		if (Controls.justPressed('back')) {
			FlxG.camera.visible = false;
			Conductor.stop();
			PlayState.self.endSong(true);
		}

		if (bf.animation.curAnim.name == 'idle' && bf.animation.curAnim.finished) {
			Conductor.play();
			startVibin = true;
		}
	}

	override function beatHit(_) {
		if (!startVibin || isEnding) return;
		bf.playAnim('loop', true);
	}

	var isEnding:Bool = false;

	function endBullshit():Void {
		if (isEnding) return;

		isEnding = true;
		bf.playAnim('confirm', true);
		Conductor.stop();
		FlxG.sound.play(Paths.music('gameOverEnd'));
		new FlxTimer().start(0.7, function(tmr:FlxTimer) {
			camera.fade(FlxColor.BLACK, 2, false, function() {
				Conductor.inst = null;
				FlxG.resetState();
			});
		});
	}
}
