package funkin.backend;

class Etterna {
	public static final missWeight:Float = -5.5;
	public static final mineWeight:Float = -7;
	public static final holdDropWeight:Float = -4.5;
		
	static final a1:Float = 0.254829592;
	static final a2:Float = -0.284496736;
	static final a3:Float = 1.421413741;
	static final a4:Float = -1.453152027;
	static final a5:Float = 1.061405429;
	static final p:Float = 0.3275911;
	static function werwerwerwerf(x:Float):Float {
		var neg = x < 0;
		x = Math.abs(x);
		var t = 1 / (1 + p * x);
		var y = 1 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * Math.exp(-x * x);
		return neg ? -y : y;
	}
	static var timeScale:Float = 1;
	public static function wife3(noteDiff:Float, ?ts:Float):Float { // https://github.com/etternagame/etterna/blob/0a7bd768cffd6f39a3d84d76964097e43011ce33/src/RageUtil/Utils/RageUtil.h
		ts ??= timeScale;
		if (ts > 1) ts = 1;
		var jPow:Float = 0.75;
		var maxPoints:Float = 2.0;
		var ridic:Float = 5 * ts;
		var shit_weight:Float = 200;
		var absDiff = Math.abs(noteDiff);
		var zero:Float = 65 * Math.pow(ts, jPow);
		var dev:Float = 22.7 * Math.pow(ts, jPow);
		if (absDiff <= ridic) return maxPoints;
		else if (absDiff <= zero) return maxPoints * werwerwerwerf((zero - absDiff) / dev);
		else if (absDiff <= shit_weight) return (absDiff - zero) * missWeight / (shit_weight - zero);
		return missWeight;
	}
}
