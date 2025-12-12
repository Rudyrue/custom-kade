package funkin.substates;

import flixel.FlxSubState;
import funkin.objects.HitGraph;
import funkin.states.PlayState;

class ResultsScreen extends FlxSubState {
	var bg:FunkinSprite;
	var graph:HitGraph;
	var data:PlayData;
	var music:FlxSound;
	public static var seenMenu = false;
	public function new(data:PlayData) {
		this.data = data;
		super();
	}

	override function create():Void {
		super.create();

		music = FlxG.sound.load(Paths.music('breakfast'), 0, true);
		music.play(false, FlxG.random.int(0, Std.int(music.length * 0.75)));

		add(bg = new FunkinSprite().makeGraphic(1, 1, FlxColor.BLACK));
		bg.scale.set(FlxG.width, FlxG.height);
		bg.alpha = 0;
		bg.updateHitbox();

		var text = new FlxText(20, -55, 0, "Song Cleared!");
		text.size = 34;
		text.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		text.color = FlxColor.WHITE;
		text.scrollFactor.set();
		add(text);

		var sick:Judgement = Judgement.list[0];
		var good:Judgement = Judgement.list[1];
		var bad:Judgement = Judgement.list[2];
		var shit:Judgement = Judgement.list[3];

		var sicks:String = 'Sicks - ${sick.hits}';
		var goods:String = 'Goods - ${good.hits}';
		var bads:String = 'Bads - ${bad.hits}';
		var comboBreaks:String = 'Combo Breaks: ${data.comboBreaks}';
		var highestCombo:String = 'Highest Combo: ${data.highestCombo}';
		var score:String = 'Score: ${data.score}';
		var accuracy:String = 'Accuracy: ${MathUtil.truncateFloat(data.accuracy, 2)}';
		var wife3:String = Settings.data.wife3 ? ' (Wife3)' : '';
		var rank:String = Judgement.getRank(data.accuracy);
		var rate:String = 'Rate: ${Conductor.rate}x';

		var comboText = new FlxText(20, -75, 0,
			'Judgements:\n$sicks\n$goods\n$bads\n\n$comboBreaks\n$highestCombo\n$score\n$accuracy%$wife3\n\n$rank\n$rate\n\n\nF1 - Replay song
        ');
		comboText.size = 28;
		comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		comboText.color = FlxColor.WHITE;
		comboText.scrollFactor.set();
		add(comboText);

		var contText = new FlxText(FlxG.width - 475, FlxG.height + 50, 0, 'Press ENTER to continue.');
		contText.size = 28;
		contText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		contText.color = FlxColor.WHITE;
		contText.scrollFactor.set();
		add(contText);
		
		// fuck it im just gonna manually calculate it i can't be arsed
		var mean:Float = 0;
		for (hit in data.hits) {
			if (hit.countMean == false) continue;
			mean += hit.diff;
		}
		mean /= data.hits.length;

		var settingsText = new FlxText(20, FlxG.height + 50, 0,
			'Mean: ${MathUtil.truncateFloat(mean, 2)}ms (SICK: ${sick.timing}ms, GOOD: ${good.timing}ms, BAD: ${bad.timing}ms, SHIT: ${shit.timing}ms)');
		settingsText.size = 16;
		settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
		settingsText.color = FlxColor.WHITE;
		settingsText.scrollFactor.set();
		add(settingsText);

		if (Settings.data.hitGraph) {
			FlxG.game.addChild(graph = new HitGraph(FlxG.width - 700, 45, 650, 400));
			graph.history = data.hits;
		}

		FlxTween.tween(bg, {alpha: 0.5}, 0.5);
		FlxTween.tween(text, {y: 20}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(comboText, {y: 145}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(contText, {y: FlxG.height - 45}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(settingsText, {y: FlxG.height - 35}, 0.5, {ease: FlxEase.expoInOut});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		seenMenu = true;
	}

	override function update(elapsed:Float) {
		graph.drawGraph();

		if (music.volume < 0.5)
			music.volume += 0.01 * elapsed;

		if (FlxG.keys.justPressed.ENTER) {
			music.fadeOut(0.3);
			PlayState.self.endSong();
		} else if (FlxG.keys.justPressed.F1) {
			music.fadeOut(0.3);
			FlxG.resetState();
		}
	}

	override function destroy() {
		if (Settings.data.hitGraph) {
			FlxG.game.removeChild(graph);
			graph = null;
		}
		super.destroy();
		seenMenu = false;
	}
}