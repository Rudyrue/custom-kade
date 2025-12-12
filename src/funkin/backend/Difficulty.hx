package funkin.backend;

class Difficulty {
	public static final default_list:Array<String> = ['Easy', 'Normal', 'Hard'];
	public static final default_current:String = 'Hard';

	public static var list:Array<String> = default_list.copy();
	public static var current:String = default_current;

	// just a `Util.format` wrapper for `Difficulty.current`
	inline public static function format(?name:String):String {
		return Util.format(name ?? current);
	}

	inline public static function reset() {
		list = default_list.copy();
		current = default_current;
	}

	inline public static function copyFrom(diffs:Array<String>) {
		list = diffs.copy();
	}
}