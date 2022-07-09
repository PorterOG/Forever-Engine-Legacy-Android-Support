package meta.data;

import Paths.ChartType;
import gameObjects.userInterface.notes.*;
import gameObjects.userInterface.notes.Note.NoteType;
import meta.data.Section.SwagSection;
import meta.data.Song.SwagSong;
import states.PlayState;

/**
	This is the ChartParser class. it loads in charts, but also exports charts, the chart parameters are based on the type of chart, 
	say the base game type loads the base game's charts, the forever chart type loads a custom forever structure chart with custom features,
	and so on. This class will handle both saving and loading of charts with useful features and scripts that will make things much easier
	to handle and load, as well as much more modular!
**/

class ChartParser
{
	public static var songType:ChartType = UNDERSCORE;
	
	// hopefully this makes it easier for people to load and save chart features and such, y'know the deal lol
	public static function loadChart(songData:SwagSong, songType:ChartType = FNF_LEGACY):Array<Note>
	{
		var unspawnNotes:Array<Note> = [];
		var noteData:Array<SwagSection>;

		noteData = songData.notes;
		switch (songType)
		{
			case FNF:
			// placeholder until 0.3!
			case FNF_LEGACY:
				// load fnf style charts (PRE 0.3)
				var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

				for (section in noteData)
				{
					var coolSection:Int = Std.int(section.lengthInSteps / 4);

					for (songNotes in section.sectionNotes)
					{
						var daStrumTime:Float = songNotes[0] - Init.trueSettings['Offset']; // - | late, + | early
						var daNoteData:Int = Std.int(songNotes[1] % 4);
						// define the note's animation (in accordance to the original game)!
						var daNoteAlt:Float = 0;

						// very stupid but I'm lazy
						if (songNotes.length > 2) {
							daNoteAlt = songNotes[3];
						}
						/*
							rest of this code will be mostly unmodified, I don't want to interfere with how FNF chart loading works
							I'll keep all of the extra features in forever charts, which you'll be able to convert and export to very easily using
							the in engine editor 

							I'll be doing my best to comment the work below but keep in mind I didn't originally write it
						 */

						// check the base section
						var gottaHitNote:Bool = section.mustHitSection;

						// if the note is on the other side, flip the base section of the note
						if (songNotes[1] > 3)
							gottaHitNote = !section.mustHitSection;

						// define the note that comes before (previous note)
						var oldNote:Note;
						if (unspawnNotes.length > 0)
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						else // if it exists, that is
							oldNote = null;

						// create the new note
						var swagNote:Note = ForeverAssets.generateArrow(PlayState.assetModifier, daStrumTime, daNoteData, daNoteAlt);
						// set note speed
						swagNote.noteSpeed = songData.speed;

						// set the note's length (sustain note)
						swagNote.sustainLength = songNotes[2];
						swagNote.scrollFactor.set(0, 0);
						var susLength:Float = swagNote.sustainLength; // sus amogus

						// adjust sustain length
						susLength = susLength / Conductor.stepCrochet;
						// push the note to the array we'll push later to the playstate
						unspawnNotes.push(swagNote);
						// STOP POSTING ABOUT AMONG US
						// basically said push the sustain notes to the array respectively
						for (susNote in 0...Math.floor(susLength))
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
							var sustainNote:Note = ForeverAssets.generateArrow(PlayState.assetModifier,
								daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, daNoteAlt, true, oldNote);
							sustainNote.scrollFactor.set();

							unspawnNotes.push(sustainNote);
							sustainNote.mustPress = gottaHitNote;
							/*
								This is handled in engine anyways, not necessary!
								if (sustainNote.mustPress)
									sustainNote.x += FlxG.width / 2;
							 */
						}
						// oh and set the note's must hit section
						swagNote.mustPress = gottaHitNote;
					}
					daBeats += 1;
				}

			case FOREVER:
			// placeholder

			case UNDERSCORE:
				/**
					a copy of FNF_LEGACY, except we have notetypes, that's all
					I don't exactly know how fnf charts work, so I'm leaving it like this for the time being
					this chart type will be used for some tests with custom stuffs I might add on top of it

					- BeastlyGhost
				**/
				
				var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

				for (section in noteData) {
					var coolSection:Int = Std.int(section.lengthInSteps / 4);

					for (songNotes in section.sectionNotes)
					{
						var daStrumTime:Float = songNotes[0] - Init.trueSettings['Offset']; // - | late, + | early
						var daNoteData:Int = Std.int(songNotes[1] % 4);
						// define the note's type
						var daNoteAlt:Float = 0;
						var daNoteType:NoteType = NORMAL;

						// very stupid but I'm lazy
						if (songNotes.length > 2) {
							daNoteType = songNotes[3];
						}

						// check the base section
						var gottaHitNote:Bool = section.mustHitSection;

						// if the note is on the other side, flip the base section of the note
						if (songNotes[1] > 3)
							gottaHitNote = !section.mustHitSection;

						// define the note that comes before (previous note)
						var oldNote:Note;
						if (unspawnNotes.length > 0)
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						else // if it exists, that is
							oldNote = null;

						// create the new note
						var swagNote:Note = ForeverAssets.generateArrow(PlayState.assetModifier, daStrumTime, daNoteData, daNoteAlt, daNoteType);
						// set note speed
						swagNote.noteSpeed = songData.speed;

						// set the note's length (sustain note)
						swagNote.sustainLength = songNotes[2];
						swagNote.scrollFactor.set(0, 0);
						var susLength:Float = swagNote.sustainLength; // sus amogus

						// adjust sustain length
						susLength = susLength / Conductor.stepCrochet;
						// push the note to the array we'll push later to the playstate
						unspawnNotes.push(swagNote);
						// STOP POSTING ABOUT AMONG US
						// basically said push the sustain notes to the array respectively
						for (susNote in 0...Math.floor(susLength))
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
							var sustainNote:Note = ForeverAssets.generateArrow(PlayState.assetModifier,
								daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, daNoteAlt, true, oldNote, daNoteType);
							sustainNote.scrollFactor.set();

							unspawnNotes.push(sustainNote);
							sustainNote.mustPress = gottaHitNote;
						}
						// oh and set the note's must hit section
						swagNote.mustPress = gottaHitNote;
					}
					daBeats += 1;
				}
			case PSYCH:
			// placeholder

			/*
				This is basically the end of this section, of course, it loops through all of the notes it has to,
				But any optimisations and such like the ones sammu is working on won't be handled here, I want to keep this code as
				close to the original as possible with a few tweaks and optimisations because I want to go for the abilities to 
				load charts from the base game, export charts to the base game, and generally handle everything with an accuracy similar to that
				of the main game so it feels like loading things in works well.
			 */
		}

		return unspawnNotes;
	}
}
