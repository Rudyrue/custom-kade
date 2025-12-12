package funkin.objects;

import funkin.objects.Strumline;
import funkin.backend.Song.Chart;
import funkin.objects.Note;
import lime.app.Application;
import lime.ui.KeyCode;

class PlayField extends FlxSpriteGroup {
	public var strumlines:FlxTypedSpriteGroup<Strumline>;
	public var playerID(default, set):Int = 1;
	function set_playerID(value:Int):Int {
		if (playerID == value) return value;

		if (value >= strumlines.length) return playerID;
		for (i => line in strumlines.members) line.ai = (value == i) ? botplay : true;

		return playerID = value;
	}
	public var currentPlayer(get, never):Strumline;
	function get_currentPlayer():Strumline {
		if (playerID >= strumlines.length) {
			return strumlines.members[strumlines.length - 1];
		}

		return strumlines.members[playerID];
	}

	@:unreflective public var botplay(default, set):Bool = false;
	function set_botplay(value:Bool):Bool {
		return botplay = currentPlayer.ai = value;
	}

	public var rate(default, set):Float = 1.0;
	function set_rate(value:Float):Float {
		#if FLX_PITCH
		Conductor.rate = value;

		rate = value;
		#else
		rate = 1.0; // ensuring -Crow
		#end

		return rate;
	}

	public var scrollSpeed(default, set):Float = 1.0;
	function set_scrollSpeed(value:Float) {
		if (scrollSpeed == value) return scrollSpeed;

		for (obj in sustains.members) {
			if (!obj.exists) continue;
			obj.calcHeight(value);
		}
		return scrollSpeed = value;
	}
	public var downscroll:Bool = false;
	var sustainInterval:Float = 120;
	var unspawnedNotes:Array<NoteData> = [];
	var notes:FlxTypedSpriteGroup<Note>;

	// wish i could just have it in `notes` but whatever
	var sustains:FlxTypedSpriteGroup<Sustain>;

	var leftSide(get, never):Strumline;
	function get_leftSide():Strumline {
		return strumlines.members[0];
	}

	var rightSide(get, never):Strumline;
	function get_rightSide():Strumline {
		return strumlines.members[1];
	}

	public dynamic function noteHit(strumline:Strumline, note:Note):Void {}
	public dynamic function noteMiss(strumline:Strumline, note:Note):Void {}
	public dynamic function sustainHit(strumline:Strumline, note:Sustain, mostRecent:Bool):Void {}
	public dynamic function ghostTap(strumline:Strumline, lane:Int):Void {}
	public dynamic function noteSpawned(note:Note):Void {}

	public function new(strumlines:Array<Strumline>, ?playerID:Int = 0) {
		super();

		add(sustains = new FlxTypedSpriteGroup<Sustain>());
		sustains.active = false;
		add(this.strumlines = new FlxTypedSpriteGroup<Strumline>());
		for (line in strumlines) this.strumlines.add(line);
		add(notes = new FlxTypedSpriteGroup<Note>());
		notes.active = false;
		
		this.playerID = playerID;

		Application.current.window.onKeyDown.add(input);
		Application.current.window.onKeyUp.add(release);
	}

	var noteSpawnIndex:Int = 0;
	var noteSpawnDelay:Float = 1500;
	override function update(elapsed:Float) {
		while (noteSpawnIndex < unspawnedNotes.length) {
			final noteData:NoteData = unspawnedNotes[noteSpawnIndex];
			final hitTime:Float = (noteData.time - Settings.data.noteOffset) - Conductor.rawTime;
			if (hitTime > noteSpawnDelay) break;

			var note = addNote(noteData, notes, Note);
			if (noteData.length > 0) {
				note.sustain = addNote(noteData, sustains, Sustain);
				//note.sustain.type = note.type;
				final strum:StrumNote = strumlines.members[note.data.player].members[note.data.lane];
				note.sustain.calcHeight(scrollSpeed);
			}
			noteSpawnIndex++;
		}

		for (obj in notes.members) {
			if (!obj.exists) continue;

			obj.update(elapsed);

			final strumline:Strumline = strumlines.members[obj.data.player];
			final strum:StrumNote = strumline.members[obj.data.lane];
	 		obj.followStrum(strum, downscroll, scrollSpeed);

			if (strum.parent.ai)
				botplayInputs(strum, obj);

			if (!obj.missed && obj.tooLate && obj.data.player == playerID) {
				obj.missed = true;
				noteMiss(strumline, obj);
			}

			if (obj.time < Conductor.rawTime - 300 * Conductor.rate)
				obj.kill();
		}

		for (obj in sustains.members) {
			if (!obj.exists) continue;

			final strumline:Strumline = strumlines.members[obj.data.player];
			final strum:StrumNote = strumline.members[obj.data.lane];

			obj.update(elapsed);

			obj.followStrum(strum, downscroll, scrollSpeed);

			sustainInputs(strum, obj, scrollSpeed);
			obj.calcHeight(scrollSpeed);

			if (obj.time + obj.data.length + 300 * Conductor.rate < Conductor.rawTime)
				obj.kill();
		}

		super.update(elapsed);
	}

	function botplayInputs(strum:StrumNote, note:Note) {
		if (note.time > Conductor.visualTime) return;

		note.wasHit = true;
		if (note.sustain != null)
			note.sustain.wasHit = true;
		note.kill();

		glowStrum(strum, note);

		noteHit(strum.parent, note);
	}

	function addNote<T:Note>(data:NoteData, group:FlxTypedSpriteGroup<T>, cls:Class<T>):T {
		var strumline:Strumline = strumlines.members[data.player];

		var note:T = group.recycle(cls);
		group.remove(note, true); // keep ordering
		group.add(cast note.setup(data));
		//if (note.texture == '') note.texture = strumline.skin;

		return note;
	}

	function glowStrum(strum:StrumNote, note:Note):Bool {
		if (strum.parent.ai && !Settings.data.cpuStrums) return false;

		strum.playAnim('notePressed', true);
		strum.quantColors = note.quantColors;
		strum.color = note.color;
		return true;
	}

	dynamic function sustainInputs(strum:StrumNote, note:Sustain, noteSpeed:Float) {
		if (!note.wasHit || note.missed) return;

		var held:Bool = held[note.data.lane];
		var playerHeld:Bool = (held || note.coyoteTimer > 0);
		var heldKey:Bool = (!strum.parent.ai && playerHeld) || (strum.parent.ai && note.time <= Conductor.rawTime);

		final coyoteLim = 0.175 * note.coyoteHitMult * rate;
		if(note.coyoteTimer < coyoteLim && held) {
			if (!glowStrum(strum, note))
				strum.playAnim('default', true);
		}

		note.coyoteTimer = held ? coyoteLim : note.coyoteTimer - FlxG.elapsed;
		note.coyoteAlpha = strum.parent.ai ? 1 : 0.6 + 0.4 * (note.coyoteTimer / coyoteLim);
		if (strum.parent.ai && note.coyoteTimer <= 0) {
			note.coyoteTimer = coyoteLim;
			sustainHit(strum.parent, note, true);
			glowStrum(strum, note);
		}

		final curHolds = strum.parent.curHolds;
		if (!heldKey) {
			if (!strum.parent.ai) {
				noteMiss(strum.parent, note);
				curHolds.remove(note);
				note.coyoteAlpha = 0.2;
				note.missed = true;
			}

			return;
		}

		note.timeOffset = -Math.min(note.hitTime, 0);
		note.forceHeightRecalc = true;
		strum.isHolding = true;

		if (!curHolds.contains(note)) {
			// we want the most recent, but we also dont wanna prioritize super short sustains
			final idx = note.data.length >= 250 ? curHolds.length : 0;
			curHolds.insert(idx, note);
		} else if (note.time + note.data.length <= Conductor.rawTime) {
			curHolds.remove(note);
			note.kill();
			strum.isHolding = !strum.parent.ai && held;
			if (strum.parent.ai && strum.animation.finished)
				strum.playAnim('default', true);
			note.untilTick = 0; // Hit it one last time, to make sure 
		}


		note.untilTick -= FlxG.elapsed * 1000;
		if (note.untilTick > 0) return;

		note.untilTick = sustainInterval;
		if (strum.parent.ai || held)
			glowStrum(strum, note);
		sustainHit(strum.parent, note, curHolds[curHolds.length - 1] == note);
	}

	var keys:Array<String> = [
		'note_left',
		'note_down',
		'note_up',
		'note_right'
	];

	var held:Array<Bool> = [for (i in 0...4) false];
	inline function input(id:KeyCode, _):Void {
		// i hate this check but whatever it works
		if (botplay || (FlxG.state.subState != null && !FlxG.state.persistentUpdate)) return; 

		final dir:Int = Controls.convertStrumKey(keys, Controls.convertLimeKeyCode(id));
		if (dir == -1 || held[dir]) return;
		held[dir] = true;

		var currentStrum:StrumNote = currentPlayer.members[dir];
		currentStrum.isHolding = true;

		for (sustain in sustains.members) {
			if (!sustain.exists || !sustain.wasHit || sustain.data.player != playerID || sustain.data.lane != dir) continue;

			sustain.coyoteTimer = 0.175 * sustain.coyoteHitMult;
			sustainHit(currentPlayer, sustain, true);
			glowStrum(currentStrum, sustain);
		}

		var closestDistance:Float = Math.POSITIVE_INFINITY;
		var noteToHit:Note = null;
		for (note in notes.members) {
			if (!note.exists) continue;
			if (note.data.player != playerID || !note.hittable || note.data.lane != dir) continue;
			
			var distance:Float = Math.abs(note.hitTime);
			if (distance < closestDistance) {
				closestDistance = distance;
				noteToHit = note;
			}
		}

		if (noteToHit == null) {
			currentStrum.playAnim('pressed', true);
			ghostTap(currentPlayer, dir);
			return;
		}

		noteHit(currentPlayer, noteToHit);
		noteToHit.wasHit = true;
		if (noteToHit.sustain != null)
			noteToHit.sustain.wasHit = true;
		noteToHit.kill();
		glowStrum(currentStrum, noteToHit);
	}

	inline function release(id:KeyCode, _):Void {
		if (botplay) return;
		
		final dir:Int = Controls.convertStrumKey(keys, Controls.convertLimeKeyCode(id));
		if (dir == -1) return;
		held[dir] = false;

		currentPlayer.members[dir].playAnim('default', true);
		currentPlayer.members[dir].isHolding = false;
	}

	override function destroy():Void {
		Application.current.window.onKeyDown.remove(input);
		Application.current.window.onKeyUp.remove(release);
	}

	public function load(chart:Chart) {
		for (note in unspawnedNotes) {
			note = null;
		}
		unspawnedNotes.resize(0);
		noteSpawnIndex = 0;

		for (section in chart.notes) {
			for (note in section.sectionNotes) {
				var noteToPush:NoteData = {
					time: Math.max(0, note[0]),
					lane: Std.int(note[1] % Strumline.keyCount),
					length: note[2],
					player: Std.int(Math.min(note[1] > (Strumline.keyCount - 1) != section.mustHitSection ? 1 : 0, strumlines.length - 1)),
					type: note[3]
				};

				if (noteToPush.type == 2) continue; // mines for simfiles

				var point:Conductor.TimingPoint = Conductor.getPointFromTime(noteToPush.time);
				noteToPush.quant = Conductor.getQuantFromTime(noteToPush.time);
				noteToPush.beat = Conductor.getBeatFromTime(noteToPush.time) + ((noteToPush.time - point.time) / Conductor.calculateCrotchet(point.bpm));
				unspawnedNotes.push(noteToPush);
			}
		}

		unspawnedNotes.sort((a, b) -> return Std.int(a.time - b.time));
	
		var curIndex = noteSpawnIndex;
		var highestIdx = noteSpawnIndex;
		var highestDensity = 0;
		var sustainDensity = 0;
		var sustainDensityHigh = 0;
		while (curIndex < unspawnedNotes.length) {
			final stopAt = unspawnedNotes[curIndex].time + (noteSpawnDelay + Judgement.max.timing + 25); // add the miss window as well
			while (highestIdx < unspawnedNotes.length && unspawnedNotes[highestIdx].time <= stopAt) {
				if (unspawnedNotes[highestIdx].length > 0)
					++sustainDensity;
				++highestIdx;
			}

			final curDensity = (highestIdx - curIndex);
			highestDensity = (curDensity > highestDensity) ? curDensity : highestDensity;
			sustainDensityHigh = (sustainDensity > sustainDensityHigh) ? sustainDensity : sustainDensityHigh;
			if (highestIdx >= unspawnedNotes.length - 1) // we've reached the end, no need for more
				break;
			if (unspawnedNotes[curIndex].length > 0)
				--sustainDensity;
			++curIndex;
		}

		for (i in 0...highestDensity) {
			var newNote = new Note();
			newNote.kill();
			this.notes.add(newNote);
		}
		for (i in 0...sustainDensityHigh) {
			var newNote = new Sustain();
			newNote.kill();
			this.sustains.add(newNote);
		}
	}
}