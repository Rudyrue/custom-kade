package funkin.backend;

import animate.FlxAnimateFrames;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.util.typeLimit.OneOfTwo;
import lime.app.Promise;
import lime.app.Future;
import openfl.media.Sound;
import openfl.display.BitmapData;
import openfl.system.System;

// credits to Chris Speciale (lead openfl maintainer) for giving me this abstract lmao
// was a pain in the ass to deal with Dynamic
abstract CachedAsset(Dynamic) {
    // cast from FlxGraphic to CachedAsset
    @:from static inline function fromFlxGraphic(graphic:FlxGraphic):CachedAsset {
        return cast graphic;
    }
    // cast from Sound to CachedAsset
    @:from static inline function fromSound(sound:Sound):CachedAsset {
        return cast sound;
    }

    // cast from CachedAsset to FlxGraphic
    @:to inline function toFlxGraphic():FlxGraphic {
        return cast this;
    }

    // cast from CachedAsset to Sound
    @:to inline function toSound():Sound {
        return cast this;
    }
}

class Paths {
	public static final IMAGE_EXT:String = 'png';
	public static final SOUND_EXT:String = 'ogg';
	public static final VIDEO_EXT:String = 'mp4';

	public static var cachedAssets:Map<String, CachedAsset> = [];
	public static var trackedAssets:Array<String> = [];
	public static var dumpExclusions:Array<String> = ['assets/music/freakyMenu.$SOUND_EXT'];


	inline public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key)) dumpExclusions.push(key);
	}

	public static dynamic function destroyAsset(key:String, ?asset:CachedAsset) {
		if (asset == null) {
			asset = cachedAssets[key];
			if (asset == null) return;
		}

		switch (Type.typeof(asset)) {
			// destroying method for graphics
			case TClass(FlxGraphic):
				var graphic:FlxGraphic = asset;

				@:privateAccess
				if (graphic.bitmap != null && graphic.bitmap.__texture != null)
					graphic.bitmap.__texture.dispose();
				FlxG.bitmap.remove(graphic);

				graphic = null;
			// destroying method for sounds
			case TClass(Sound):
				(asset:Sound).close();
				
			// if grabbed asset doesn't exist then we stop the function
			default:
				trace('uh oh failed asset !!!!! "$key"');
				return;
		}

		cachedAssets.remove(key);
	}

	// deload unused assets from memory
	public static dynamic function clearUnusedMemory() {
		for (key => asset in cachedAssets) {
			if (trackedAssets.contains(key) || dumpExclusions.contains(key)) continue;	
			destroyAsset(key, asset);
		}

		System.gc();
	}

	// clear all except specific assets from memory
	public static dynamic function clearExcept(assets:Array<String>) {
		trackedAssets = assets;
		clearUnusedMemory();
	}

	// clear all assets from memory
	public static dynamic function clearStoredMemory() {
		for (key => asset in cachedAssets) {
			if (dumpExclusions.contains(key)) continue;
			destroyAsset(key, asset);
		}

		trackedAssets = [];
		System.gc();
	}

	public static function get(path:String, ?subFolder:String):String {
		if (subFolder != null && subFolder.length != 0) {
			path = '$subFolder/$path';
		}

		return 'assets/$path';
	}

	public static function exists(path:String, ?subFolder:String):Bool {
		return FileSystem.exists(get(path, subFolder));
	}

	public static function image(key:String, ?subFolder:String = 'images', ?pushToGPU:Null<Bool>):FlxGraphic {
		if (key.lastIndexOf('.') < 0) key += '.$IMAGE_EXT';
		key = get(key, subFolder);

		if (cachedAssets.exists(key)) return cachedAssets[key];
		
		if (!FileSystem.exists(key)) return null;

		if (!trackedAssets.contains(key)) trackedAssets.push(key);
		return cacheBitmap(key, key, pushToGPU);
	}

	public static function imageAsync(key:String, ?subFolder:String = 'images', ?pushToGPU:Null<Bool>):Future<FlxGraphic> {
		final future:Future<FlxGraphic> = new Future<FlxGraphic>(() -> {
			// Force gpu cache to be off since uploading textures to gpu isn't thread safe. (-Bolo)
			return image(key, subFolder, false);
		}, true);

		final graphicPromise:Promise<FlxGraphic> = new Promise<FlxGraphic>();

		future.onComplete((graphic:FlxGraphic) -> {
			// At this point we are on the main thread context again.
			if (pushToGPU) {
				var bitmapData:BitmapData = graphic.bitmap;

				@:privateAccess
				if (bitmapData != null && FlxG.stage.context3D != null) {
					bitmapData.lock();
					bitmapData.getTexture(FlxG.stage.context3D);
					bitmapData.getSurface();

					bitmapData.readable = true;
					bitmapData.image = null;
				}
			}

			graphicPromise.complete(graphic);
		});

		return graphicPromise.future;
	}

	public static function cacheBitmap(key:String, cacheKey:String, ?pushToGPU:Bool = false):FlxGraphic {
		//bitmap.disposeImage();

		final bitmapO:BitmapData = funkin.backend.OptimizedBitmapData.fromFile(key, pushToGPU);
		if (pushToGPU) funkin.backend.utils.BitmapDataUtil.toHardware(bitmapO);

		final graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmapO, false, cacheKey);
		graph.persist = true;
		graph.destroyOnNoUse = false;

		cachedAssets.set(cacheKey, graph);
		return graph;
	}

	public static function audio(key:String, ?subFolder:String):Sound {
		if (key.lastIndexOf('.') < 0) key += '.$SOUND_EXT';
		key = get(key, subFolder);

		if (cachedAssets.exists(key)) return cachedAssets[key];
		if (!FileSystem.exists(key)) return null;
		
		var file:Sound = Sound.fromFile(key);
		cachedAssets.set(key, file);
		if (!trackedAssets.contains(key)) trackedAssets.push(key);
		return file;
	}

	public static function sfx(key:String, ?subFolder:String = 'sfx'):Sound {
		return audio(key, subFolder);
	}

	public static function music(key:String, ?subFolder:String = 'music'):Sound {
		return audio(key, subFolder);
	}

	public static function text(key:String, ?subFolder:String):String {
		key = get(key, subFolder);

		if (!FileSystem.exists(key)) return '';
		return sys.io.File.getContent(key);
	}

	public static function font(key:String, ?subFolder:String = 'fonts'):String {
		return get(key, subFolder);
	}

	static function combineAtlas(atlasA:FlxAtlasFrames, atlasB:FlxAtlasFrames):FlxAtlasFrames {
		if (atlasA is FlxAnimateFrames) {
			@:privateAccess if (atlasB is FlxAnimateFrames && cast (atlasA, FlxAnimateFrames).addedCollections.contains(cast atlasB))
				return atlasA;
			return atlasA.addAtlas(atlasB, false);
		}

		@:privateAccess if (atlasA is FlxAnimateFrames && cast (atlasB, FlxAnimateFrames).addedCollections.contains(cast atlasA))
			return atlasB;
		return atlasB.addAtlas(atlasA, false);
	}

	public static function multiAtlas(keys:Array<String>, ?subFolder:String = 'images') {
		function getFrames(key:String, subFolder:String):OneOfTwo<FlxAtlasFrames, FlxAnimateFrames> {
			var frames:OneOfTwo<FlxAtlasFrames, FlxAnimateFrames> = null;
			if (exists('$subFolder/$key/Animation.json')) frames = cast animateAtlas(key, subFolder);
			else frames = cast sparrowAtlas(key, subFolder);

			return frames;
		}

		var parentFrames = cast getFrames(keys[0], subFolder);
		if (keys.length == 1) return parentFrames;

		if (parentFrames == null) return null;

		for (i in 1...keys.length) {
			var extraFrames = cast getFrames(keys[i], subFolder);
			if (extraFrames == null) continue;
			parentFrames = combineAtlas(parentFrames, extraFrames);
		}

		return parentFrames;
	}

	public static function animateAtlas(path:String, ?subFolder:String = 'images'):FlxAnimateFrames {
		return FlxAnimateFrames.fromAnimate(get(path, subFolder));
	}

	public static function sparrowAtlas(key:String, ?subFolder:String = 'images'):FlxAtlasFrames {
		final xmlPath:String = get('$key.xml', subFolder);
		if (!FileSystem.exists(xmlPath)) return null;

		return FlxAtlasFrames.fromSparrow(image(key, subFolder), File.getContent(xmlPath));

	}
}