package funkin.backend.utils;

final class MathUtil {
	/**
	 * Checks if a is less than b with considering a margin of error.
	 * 
	 * @param a Float
	 * @param b Float
	 * @param margin Float (Default: EPSILON)
	 * 
	 * @return Bool
	**/
	public static inline function lessThan(a:Float, b:Float, margin:Float = 0.0000001):Bool {
		return a < b - margin;
	}

	/**
	 * Checks if a is less than or equally b with considering a margin of error.
	 * 
	 * @param a Float
	 * @param b Float
	 * @param margin Float (Default: EPSILON)
	 * 
	 * @return Bool
	**/
	public static inline function lessThanEqual(a:Float, b:Float, margin:Float = 0.0000001):Bool {
		return a <= b - margin;
	}

	/**
	 * Checks if a is greater than b with considering a margin of error.
	 * 
	 * @param a Float
	 * @param b Float
	 * @param margin Float (Default: EPSILON)
	 * 
	 * @return Bool
	**/
	public static inline function greaterThan(a:Float, b:Float, margin:Float = 0.0000001):Bool {
		return a > b + margin;
	}

	/**
	 * Checks if a is greater than or equally b with considering a margin of error.
	 * 
	 * @param a Float
	 * @param b Float
	 * @param margin Float (Default: EPSILON)
	 * 
	 * @return Bool
	**/
	public static inline function greaterThanEqual(a:Float, b:Float, margin:Float = 0.0000001):Bool {
		return a >= b + margin;
	}

	/**
	 * Checks if a is approximately equal to b.
	 * 
	 * @param a Float
	 * @param b Float
	 * @param margin Float (Default: EPSILON)
	 * 
	 * @return Bool
	**/
	public static inline function equal(a:Float, b:Float, margin:Float = 0.0000001):Bool {
		return Math.abs(a - b) <= margin;
	}

	public static function maxInt(v0:Int, v1:Int)
		#if cpp
		return untyped __cpp__("((({0}) < ({1})) ? ({1}) : ({0}))", v0, v1);
		#else
		return v0 < v1 ? v1 : v0;
		#end

	public static function minInt(v0:Int, v1:Int)
		#if cpp
		return untyped __cpp__("((({0}) > ({1})) ? ({1}) : ({0}))", v0, v1);
		#else
		return v0 > v1 ? v1 : v0;
		#end

	public static function bound(value:Float, min:Float, max:Float):Float
		#if cpp
		return untyped __cpp__("((({0}) < ({1})) ? ({1}) : (({0}) > ({2})) ? ({2}) : ({0}))", value, min, max);
		#else
		return (value < min) ? min : (value > max) ? max : value;
		#end

	public static function boundInt(value:Int, min:Int, max:Int):Int
		#if cpp
		return untyped __cpp__("((({0}) < ({1})) ? ({1}) : (({0}) > ({2})) ? ({2}) : ({0}))", value, min, max);
		#else
		return (value < min) ? min : (value > max) ? max : value;
		#end

	public static function boolToInt(b:Bool):Int
		#if cpp
		return untyped __cpp__("(({0}) ? 1 : 0)", b);
		#else
		return b ? 1 : 0;
		#end

	public static function mean(values:Array<Float>):Float {
		final amount:Int = values.length;
		var result:Float = 0.0;

		var value:Float = 0;
		for (i in 0...amount) {
			value = values[i];
			if (value == 0)
				continue;
			result += value;
		}

		return result / amount;
	}

	public static function median(values:Array<Float>):Float {
		var result:Float = 0.0;
		var amount:Int = values.length;

		values.sort((a, b) -> return Std.int(a - b));
		
		if (amount % 2 == 0) {
			var leftVal:Int = Std.int(amount / 2) - 1;
			var rightVal:Int = leftVal + 1;

			result = (values[leftVal] + values[rightVal]) / 2;
		} else result = values[Std.int(amount / 2)];

		return result;
	}

	public static function mode(values:Array<Float>):Array<Float> {
		var result:Array<Float> = [];

		values.sort((a, b) -> return Std.int(a - b));

		

		return result;
	}

	public static function truncateFloat(number:Float, precision:Float = 2):Float {
		number *= (precision = Math.pow(10, precision));
		return Math.floor(number) / precision;
	}
}