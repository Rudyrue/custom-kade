package funkin.backend;

@:structInit
class Judgement {
	public static var list:Array<Judgement> = [
		{
			name: 'sick',
			timing: 45,
			health: 2,
			score: 350,
			accuracy: 100
		},
		{
			name: 'good',
			timing: 90,
			score: 200,
			accuracy: 75
		},
		{
			name: 'bad',
			timing: 135,
			score: 0,
			health: -3,
			accuracy: 50
		},
		{
			name: 'shit',
			timing: 180,
			score: -300,
			health: -5,
			breakCombo: true,
			accuracy: -100 // ??????????????????? what the fuck kade
		}
	];

	public var timing:Float = 0;
	public var accuracy:Float = 0;
	public var health:Float = 0;
	public var score:Int = 0;
	public var name:String = '';
	public var hits:Int = 0;
	public var breakCombo:Bool = false;

	public static var max(get, never):Judgement;
	static function get_max():Judgement return list[list.length - 1];

	public static var min(get, never):Judgement;
	static function get_min():Judgement return list[0];

	inline public static function resetHits():Void {
		for (judge in list) judge.hits = 0;
	}

	public static function getIDFromTiming(noteDev:Float):Int {
		var value:Int = list.length - 1;

		for (i in 0...list.length) {
			if (Math.abs(noteDev) > list[i].timing) continue;
			value = i;
			break;
		}

		return value;
	}

	public static function getFromTiming(noteDev:Float):Judgement {
		var judge:Judgement = max;

		for (possibleJudge in list) {
			if (Math.abs(noteDev) > possibleJudge.timing) continue;
			judge = possibleJudge;
			break;
		}

		return judge;
	}

	public static var clearTypes:Array<String> = [
		'PFC',
		'GFC',
		'FC',
		'SDCB',
		'Clear'
	];
	public static function getClearType(?judges:Array<Judgement>, comboBreaks:Int) {
		judges ??= list;

		var result:String = 'N/A';

		var sicks:Int = judges[0].hits;
		var goods:Int = judges[1].hits;
		var bads:Int = judges[2].hits;
		var shits:Int = judges[3].hits;

		// you didn't hit a note !!!!!!! gRRR HIT A NOTE
		if (sicks == 0 && goods == 0 && bads == 0 && shits == 0) {
			return result;
		}

		if (comboBreaks == 0) {
			if (bads == 0 && shits == 0 && goods == 0)
				result = clearTypes[0]; // Perfect Full Combo (PFC)
			else if (bads == 0 && shits == 0 && goods >= 1)
				result = clearTypes[1]; // Good Full Combo (GFC)
			else result = clearTypes[2]; // Full Combo (FC)
		} else if (comboBreaks < 10)
			result = clearTypes[3]; // Single Digit Combo Break (SDCB)
		else result = clearTypes[4]; // Clear

		return result;
	}

	// WIFE TIME :)))) (based on Wife3)
	static var wifeConditions:Array<Array<Dynamic>> = [
		[99.9935, 'AAAAA'],
		[99.980, 'AAAA:'],
		[99.970, 'AAAA.'],
		[99.955, 'AAAA'],
		[99.90, 'AAA:'],
		[99.80, 'AAA.'],
		[99.70, 'AAA'],
		[99, 'AA:'],
		[96.50, 'AA.'],
		[93, 'AA'],
		[90, 'A:'],
		[85, 'A.'],
		[80, 'A'],
		[70, 'B'],
		[60, 'C'],
		[0, 'D']
	];
	public static function getRank(accuracy:Float):String {
		var result:String = '';
		for (i in 0...wifeConditions.length) {
			var rank:Array<Dynamic> = wifeConditions[i];
			var condition:Float = rank[0];

			if (condition > accuracy) continue;
			result = rank[1];
			break;
		}

		return result;
	}
}