package flixel.graphics.tile;

import funkin.objects.Note;

import openfl.Vector;
import openfl.geom.ColorTransform;
import openfl.display.BlendMode;

import flixel.math.FlxMatrix;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem;

class FlxDrawNoteItem extends FlxDrawBaseItem<FlxDrawNoteItem> {
	static inline var VERTICES_PER_QUAD = #if (openfl >= "8.5.0") 4 #else 6 #end;
	static final backupColour:ColorTransform = new ColorTransform();

	var rects:Vector<Float>;
	var alphas:Array<Float>;
	var colorMultipliers:Array<Float>;
	var colorOffsets:Array<Float>;

	var verts:Array<Float>;

	public function new() {
		super();
		type = FlxDrawItemType.NOTE;
		rects = new Vector<Float>();
		alphas = [];
		colorMultipliers = [];
		colorOffsets = [];
		verts = [];
	}

	override public function reset():Void {
		super.reset();

		rects.length = 0;
		alphas.resize(0);
		colorMultipliers.resize(0);
		colorOffsets.resize(0);
		verts.resize(0);
	}

	override public function dispose():Void {
		super.dispose();

		rects = null;
		alphas = null;
		colorMultipliers = null;
		colorOffsets = null;
		verts = null;
	}

	public function addVertices(frame:FlxFrame, vertices:Array<Float>, ?transform:ColorTransform, ?alpha:Float) {
		var rect = frame.frame;
		rects.push(rect.x);
		rects.push(rect.y);
		rects.push(rect.width);
		rects.push(rect.height);

		verts = verts.concat(vertices);

		transform ??= backupColour;

		for (i in 0...VERTICES_PER_QUAD) {
			alphas.push(alpha);

			colorMultipliers.push(transform.redMultiplier);
			colorMultipliers.push(transform.greenMultiplier);
			colorMultipliers.push(transform.blueMultiplier);
			colorMultipliers.push(1);

			colorOffsets.push(transform.redOffset);
			colorOffsets.push(transform.greenOffset);
			colorOffsets.push(transform.blueOffset);
			colorOffsets.push(transform.alphaOffset);
		}
	}

	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform) {
		var rect = frame.frame;
		rects.push(rect.x);
		rects.push(rect.y);
		rects.push(rect.width);
		rects.push(rect.height);

		verts.push(matrix.transformX(0, 0));
		verts.push(matrix.transformY(0, 0));
		verts.push(matrix.transformX(frame.frame.width, 0));
		verts.push(matrix.transformY(frame.frame.width, 0));
		verts.push(matrix.transformX(0, frame.frame.height));
		verts.push(matrix.transformY(0, frame.frame.height));
		verts.push(matrix.transformX(frame.frame.width, frame.frame.height));
		verts.push(matrix.transformY(frame.frame.width, frame.frame.height));

		transform ??= backupColour;

		for (i in 0...VERTICES_PER_QUAD) {
			alphas.push(transform.alphaMultiplier);

			colorMultipliers.push(transform.redMultiplier);
			colorMultipliers.push(transform.greenMultiplier);
			colorMultipliers.push(transform.blueMultiplier);
			colorMultipliers.push(1);

			colorOffsets.push(transform.redOffset);
			colorOffsets.push(transform.greenOffset);
			colorOffsets.push(transform.blueOffset);
			colorOffsets.push(transform.alphaOffset);
		}
	}

	override public function render(camera:FlxCamera):Void {
		if (rects.length == 0)
			return;

		var shader = Note.colourShader;
		shader.bitmap.input = graphics.bitmap;
		shader.bitmap.filter = (camera.antialiasing || antialiasing) ? ANISOTROPIC16X : NEAREST;
		shader.alpha.value = alphas;

		shader.verts.value = verts;
		shader.canColor.value = [colored];
		shader.colorMultiplier.value = colorMultipliers;
		shader.colorOffset.value = colorOffsets;

		shader.hasTransform.value = [true];

		#if (openfl > "8.7.0")
		camera.canvas.graphics.overrideBlendMode(blend);
		#end
		camera.canvas.graphics.beginShaderFill(shader);
		camera.canvas.graphics.drawQuads(rects, null, null);
		camera.canvas.graphics.endFill();
		++FlxDrawBaseItem.drawCalls;
	}
}