package funkin.objects;

import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;
import haxe.Json;
import flixel.util.FlxAxes;
import flixel.FlxObject;

// custom-psych alphabet but kade engine-ified
class Alphabet extends FlxTypedSpriteGroup<AlphabetLine> {
    public var type(default, set):AlphabetGlyphType;

    public var alignment(default, set):AlphabetAlignment;

    public var text(default, set):String;

	public var changeX:Bool = true;
	public var changeY:Bool = true;

	public var scaleX(default, set):Float = 1.0;
	public var scaleY(default, set):Float = 1.0;

	public var letters(get, never):Array<AlphabetGlyph>;
	function get_letters():Array<AlphabetGlyph> {
		return [for (line in members) {
			for (glyph in line) glyph;
		}];
	}

    public var targetY:Int = 0;

    public var isMenuItem:Bool = false;

    public var distancePerItem:FlxPoint = FlxPoint.get(20, 120);
	public var spawnPos:FlxPoint = FlxPoint.get();
	public var fieldWidth:Float = 0;

    public function new(x:Float = 0, y:Float = 0, text:String = "", ?type:AlphabetGlyphType = BOLD, ?alignment:AlphabetAlignment = LEFT, ?size:Float = 1.0) {
        super(x, y);
		this.spawnPos.set(x, y);

        @:bypassAccessor this.type = type;
        this.text = text;
		this.alignment = alignment;
    }

    override function update(elapsed:Float) {
        if (!isMenuItem) {
			super.update(elapsed);
			return;
		}

		var lerpVal:Float = Math.exp(-elapsed * 9.6);
		if (changeX) x = FlxMath.lerp((targetY * distancePerItem.x) + spawnPos.x, x, lerpVal);
		if (changeY) y = FlxMath.lerp((targetY * 1.3 * distancePerItem.y) + spawnPos.y, y, lerpVal);
    }

	public function snapToPosition() {
		if (!isMenuItem) return;

		if (changeX) x = (targetY * distancePerItem.x) + spawnPos.x;
		if (changeY) y = (targetY * 1.3 * distancePerItem.y) + spawnPos.y;
	}

    // --------------- //
    // [ Private API ] //
    // --------------- //

	static final Y_PER_ROW:Float = 60;

    @:noCompletion
    function updateText(newText:String, ?force:Bool = false) {
        if (text == newText && !force) return; // what's the point of regenerating

        for (glyph in members) glyph.destroy();
        clear();

        final glyphPos:FlxPoint = FlxPoint.get();
        var rows:Int = 0;

        var line:AlphabetLine = new AlphabetLine();

        for (i in 0...newText.length) {
            final char:String = newText.charAt(i);
            if (char == "\n") {
                glyphPos.x = 0;
                glyphPos.y = ++rows * Y_PER_ROW;
                add(line);
                line = new AlphabetLine();
                continue;
            }

            final spaceChar:Bool = (char == " ");
            if (spaceChar) {
                glyphPos.x += 28;
                continue;
            }

            if (!AlphabetGlyph.allGlyphs.exists(char.toLowerCase())) continue;

            final glyph:AlphabetGlyph = new AlphabetGlyph(glyphPos.x, glyphPos.y, char, type);
            glyph.row = rows;
            glyph.color = color;
            glyph.spawnPos.copyFrom(glyphPos);
            line.add(glyph);

            glyphPos.x += glyph.width;
        }

        if (members.indexOf(line) == -1) add(line);
        
        glyphPos.put();
    }

    public function updateAlignment(align:AlphabetAlignment) {
        final totalWidth:Float = fieldWidth > 0 ? fieldWidth : width;
        for (line in members) {
            line.x = switch (align) {
                case LEFT: x;
                case CENTER: (totalWidth - line.width) * 0.5;
                case RIGHT: x + (totalWidth - line.width);
            }
        }
    }

	@:noCompletion
	function set_scaleX(value:Float):Float {
		updateScale(value, scaleY);
		return value;
	}

	@:noCompletion
	function set_scaleY(value:Float):Float {
		updateScale(scaleX, value);
		return value;
	}

    public function updateScale(?_x:Float, ?_y:Float) {
		_x ??= scaleX;
		_y ??= scaleY;

		@:bypassAccessor scaleX = _x;
		@:bypassAccessor scaleY = _y;

        for (line in members) {
            for (glyph in line) {
                glyph.scale.set(_x, _y);
                glyph.updateHitbox();
                glyph.setPosition(line.x + (glyph.spawnPos.x * _x), line.y + (glyph.spawnPos.y * _y));
            }
        }

        updateAlignment(alignment);
    }

    @:noCompletion
    inline function set_type(newType:AlphabetGlyphType):AlphabetGlyphType {
        type = newType;
        updateText(text, true);
        updateScale(scaleX, scaleY);
        return newType;
    }

    @:noCompletion
    function set_text(newText:String):String {
        newText = newText.replace('\\n', '\n');
        updateText(newText);
        updateScale(scaleX, scaleY);
        return text = newText;
    }

    @:noCompletion
    inline function set_alignment(newAlign:AlphabetAlignment):AlphabetAlignment {
        alignment = newAlign;
        updateScale(scaleX, scaleY);
        return newAlign;
    }

    @:noCompletion
    override function set_color(value:Int) {
        for(line in members)
            line.color = value;
        return super.set_color(value);
    }

    override function destroy() {
        distancePerItem.put();
        super.destroy();
    } 
}

class AlphabetLine extends FlxTypedSpriteGroup<AlphabetGlyph> {
    @:noCompletion
    override function set_color(value:Int) {
        for(letter in members)
            letter.color = value;

        return super.set_color(value);
    }
}

enum abstract AlphabetAlignment(String) from String to String {
    var LEFT = "left";
    var CENTER = "center";
    var RIGHT = "right";
}

typedef Glyph = {
	var ?anim:Null<String>;
	var ?offsets:Array<Float>;
	var ?offsetsBold:Array<Float>;
}

class AlphabetGlyph extends FunkinSprite {
	public var image(default, set):String;
	public static var allGlyphs:Map<String, Glyph> = [
		// letters
		"a" => {},
		"b" => {},
		"c" => {},
		"d" => {},
		"e" => {},
		"f" => {},
		"g" => {},
		"h" => {},
		"i" => {},
		"j" => {},
		"k" => {},
		"l" => {},
		"m" => {},
		"n" => {},
		"o" => {},
		"p" => {},
		"q" => {},
		"r" => {},
		"s" => {},
		"t" => {},
		"u" => {},
		"v" => {},
		"w" => {},
		"x" => {},
		"y" => {},
		"z" => {},

		// numbers
		"0" => {},
		"1" => {},
		"2" => {},
		"3" => {},
		"4" => {},
		"5" => {},
		"6" => {},
		"7" => {},
		"8" => {},
		"9" => {},

		// accented letters
		"á" => {},
		"é" => {},
		"í" => {},
		"ó" => {},
		"ú" => {},
		"à" => {},
		"è" => {},
		"ì" => {},
		"ò" => {},
		"ù" => {},
		"â" => {},
		"ê" => {},
		"î" => {},
		"ô" => {},
		"û" => {},
		"ã" => {},
		"ë" => {},
		"ï" => {},
		"õ" => {},
		"ü" => {},
		"ä" => {},
		"ö" => {},
		"å" => {},
		"ø" => {},
		"æ" => {},
		"ñ" => {},
		"ç" => {
			offsetsBold: [0, -11]
		},
		"š" => {},
		"ž" => {},
		"ý" => {},
		"ÿ" => {},

		// special characters
		"ß" => {},
		"&" => {
			offsetsBold: [0, 2]
		},
		"(" => {},
		")" => {},
		"[" => {},
		"]" => {
			offsetsBold: [0, -1]
		},
		"*" => {
			offsets: [0, 28],
			offsetsBold: [0, 40]
		},
		"+" => {
			offsets: [0, 7],
			offsetsBold: [0, 12]
		},
		"-" => {
			offsets: [0, 16],
			offsetsBold: [0, 16]
		},
		"<" => {
			offsetsBold: [0, -2]
		},
		">" => {
			offsetsBold: [0, -2]
		},
		"'" => {
			anim: 'apostrophe',
			offsets: [0, 32],
			offsetsBold: [0, 40]
		},
		"\"" => {
			anim: 'quote',
			offsets: [0, 32],
			offsetsBold: [0, 40]
		},
		"!" => {
			anim: 'exclamation'
		},
		"?" => {
			anim: 'question'
		},
		"." => {
			anim: 'period'
		},
		"❝" => {
			anim: 'start quote',
			offsets: [0, 24],
			offsetsBold: [0, 40]
		},
		"❞" => {
			anim: 'end quote',
			offsets: [0, 24],
			offsetsBold: [0, 40]
		},
		"_" => {},
		"#" => {},
		"$" => {},
		"%" => {},
		":" => {
			offsets: [0, 2],
			offsetsBold: [0, 8]
		},
		";" => {
			offsets: [0, -2],
			offsetsBold: [0, 4]
		},
		"@" => {},
		"^" => {
			offsets: [0, 28],
			offsetsBold: [0, 38]
		},
		"," => {
			anim: 'comma',
			offsets: [0, -6],
			offsetsBold: [0, -4]
		},
		"\\" => {
			anim: 'back slash'
		},
		"/" => {
			anim: 'forward slash'
		},
		"|" => {},
		"~" => {
			offsets: [0, 16],
			offsetsBold: [0, 20]
		},
		"¡" => {
			anim: 'inverted exclamation',
			offsets: [0, -20],
			offsetsBold: [0, -20]
		},
		"¿" => {
			anim: 'inverted question',
			offsets: [0, -20],
			offsetsBold: [0, -20]
		},
		"{" => {},
		"}" => {},
		"•" => {
			anim: 'bullet',
			offsets: [0, 18],
			offsetsBold: [0, 20]
		}
	];

	public var type(default, set):AlphabetGlyphType;
	public var char(default, set):String;

	public var row:Int = 0;
	public var spawnPos:FlxPoint = FlxPoint.get();
	public var letterOffset:Array<Float> = [0, 0];
	public var curGlyph:Glyph = null;

	public var parent:Alphabet;

	public function new(x:Float = 0, y:Float = 0, char:String = "", ?type:AlphabetGlyphType = BOLD) {
		super(x, y);
		image = 'alphabet';
		@:bypassAccessor this.type = type;
		this.char = char;
	}

	@:noCompletion
	inline function set_type(newType:String):String {
		set_char(char);
		return type = newType;
	}

	@:noCompletion
	function set_image(value:String):String {
		if (frames == null) {
			frames = Paths.sparrowAtlas(image = value);
			return value;
		}

		var lastAnim:String = null;
		if (animation != null) lastAnim = animation.name;

		frames = Paths.sparrowAtlas(image = value);
		
		if (lastAnim != null) {
			animation.addByPrefix(lastAnim, lastAnim, 24);
			animation.play(lastAnim, true);
			updateHitbox();
		}

		return value;
	}

	@:noCompletion
	inline function set_char(newChar:String):String {
		frames = Paths.sparrowAtlas(image);

		var converted:String = newChar.toLowerCase();
		final isLowerCase:Bool = converted == newChar;
		var suffix:String;

		curGlyph = allGlyphs[allGlyphs.exists(converted) ? converted : '?'];

		if (type == NORMAL) {
			if (Util.isLetter(converted)) suffix = isLowerCase ? 'lowercase' : 'uppercase';
			else suffix = 'normal';
		} else suffix = 'bold';

		converted = '${curGlyph.anim ?? converted} $suffix';
		
		animation.addByPrefix(converted, converted, 24);
		animation.play(converted);

		updateHitbox();

		return char = newChar;
	}

	override function destroy() {
		spawnPos.put();
		super.destroy();
	}

	public function updateLetterOffset() {
		if (animation.curAnim == null) return;

		var add:Float = 110;
		if (animation.curAnim.name.endsWith('bold')) {
			letterOffset = curGlyph.offsetsBold != null ? curGlyph.offsetsBold : [0.0, 0.0];
			add = 70;
		} else letterOffset = curGlyph.offsets != null ? curGlyph.offsets : [0.0, 0.0];

		add *= scale.y;
		offset.x += letterOffset[0] * scale.x;
		offset.y += letterOffset[1] * scale.y - (add - height);
	}

	override function updateHitbox() {
		super.updateHitbox();
		updateLetterOffset();
	}
}

enum abstract AlphabetGlyphType(String) from String to String {
	var BOLD = "bold";
	var NORMAL = "normal";
}