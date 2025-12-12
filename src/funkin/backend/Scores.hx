package funkin.backend;

import flixel.util.FlxSave;

typedef ScoreData = {
	var songID:String;
	var difficulty:String;

	var score:Int;
	var rate:Float;
	var clearType:String;
	var wife3:Bool;
}

class Scores {
	public static var list:Array<ScoreData> = [];

	static var _save:FlxSave;

	public static function load():Void {
		_save ??= new FlxSave();
		_save.bind('scores', Util.getSavePath());

		if (_save.data.list != null) list = _save.data.list.copy();
	}

	public static function save():Void {
		_save.data.list = list.copy();
		_save.flush();
	}

	public static function reset(?saveToDisk:Bool = false) {
		list.resize(0);
		if (saveToDisk) save();
	}

	public static function get(songID:String, ?difficulty:String):ScoreData {
		difficulty ??= Difficulty.current;

		var scores:Array<ScoreData> = filter(list, songID, difficulty);
		if (scores.length == 0) {
			return {
				songID: songID,
				difficulty: difficulty,

				score: 0,
				wife3: Settings.data.wife3,
				rate: Conductor.rate,
				clearType: ''
			}
		}

		return scores[0];
	}

	public static function set(data:ScoreData):Void {
		var filteredList:Array<ScoreData> = filter(list, data.songID, data.difficulty);

		if (filteredList.length == 0) {
			list.push(data);
			return;
		}

		var old:ScoreData = list[list.indexOf(filteredList[0])];

		var oldClearType:Int = Std.int(Math.max(0, Judgement.clearTypes.indexOf(old.clearType)));
		var newClearType:Int = Std.int(Math.max(0, Judgement.clearTypes.indexOf(data.clearType)));

		// if the old clear type has a higher index than the new clear type
		// that means the new clear type is "higher" on the list
		// meaning the new clear type is better than the last

		//[
		//	'PFC',
		//	'GFC',
		//	'FC', <- new clear type (this one is better since indexOf() returns a lower number
		//	'SDCB',
		//	'Clear' <- old clear type
		//];
		if (oldClearType > newClearType) {
			old.clearType = data.clearType;
		}

		if (old.score < data.score) {
			old.score = data.score;
		}
	}

	public static function filter(scores:Array<ScoreData>, songID:String, difficulty:String):Array<ScoreData> {
		return scores.filter(function(score:ScoreData) {
			if (score.rate != Conductor.rate) return false;
			if (score.wife3 != Settings.data.wife3) return false;

			return score.songID == songID && score.difficulty == difficulty;
		});
	}
}