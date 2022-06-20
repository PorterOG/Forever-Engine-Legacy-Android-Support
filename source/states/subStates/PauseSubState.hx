package states.subStates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.CoolUtil;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.*;
import meta.data.font.Alphabet;
import states.*;
import states.menus.*;

class PauseSubState extends MusicBeatSubState
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;
	var pauseMusic:FlxSound;

	var pauseOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Exit to Options', 'Exit to menu'];
	var difficultyChoices:Array<String> = ['EASY', 'NORMAL', 'HARD', 'BACK'];

	var menuItems:Array<String> = [];

	public static var playingPause:Bool = false;

	public static var toOptions:Bool = false;

	public static var practiceText:FlxText;

	public function new(x:Float, y:Float)
	{
		super();

		toOptions = false;

		menuItems = pauseOG;

		if (!PlayState.isStoryMode) {
			pauseOG.insert(3, 'Toggle Practice Mode');
			pauseOG.insert(4, 'Toggle Autoplay');
		}

		if (!playingPause)
		{
			playingPause = true;
			pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
			pauseMusic.volume = 0;
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
			pauseMusic.ID = 9000;

			FlxG.sound.list.add(pauseMusic);
		}
		else
		{
			for (i in FlxG.sound.list)
			{
				if (i.ID == 9000) // jankiest static variable
					pauseMusic = i;
			}
		}

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += CoolUtil.dashToSpace(PlayState.SONG.song);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font('vcr.ttf'), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyFromNumber(PlayState.storyDifficulty);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var levelDeaths:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		levelDeaths.text += "Blue balled: " + PlayState.deaths;
		levelDeaths.scrollFactor.set();
		levelDeaths.setFormat(Paths.font('vcr.ttf'), 32);
		levelDeaths.updateHitbox();
		add(levelDeaths);

		practiceText = new FlxText(20, 15 + 96, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.updateHitbox();
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.visible = PlayState.disableDeath;
		add(practiceText);

		levelInfo.alpha = 0;
		levelDifficulty.alpha = 0;
		levelDeaths.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		levelDeaths.x = FlxG.width - (levelDeaths.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(levelDeaths, {alpha: 1, y: levelDeaths.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	private function regenMenu()
	{
		while (grpMenuShit.members.length > 0)
		{
			grpMenuShit.remove(grpMenuShit.members[0], true);
		}

		for (i in 0...menuItems.length)
		{
			var menuItem:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			menuItem.isMenuItem = true;
			menuItem.targetY = i;
			grpMenuShit.add(menuItem);
		}

		curSelected = 0;

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;
		
		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];
			if (menuItems == difficultyChoices)
			{
				if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song;
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					Main.switchState(this, new PlayState());
					PlayState.resetMusic();
					PlayState.deaths = 0;
					return;
				}
				menuItems = pauseOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					//
					PlayState.disableDeath = false;
					PlayState.contents.boyfriendStrums.autoplay = false;
					PlayState.uiHUD.autoplayTxt.visible = false;
					PlayState.preventScoring = false;
					practiceText.visible = false;
					//
					Main.switchState(this, new PlayState());
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					regenMenu();
				case "Exit to Options":
					toOptions = true;
					
					//
					PlayState.disableDeath = false;
					PlayState.contents.boyfriendStrums.autoplay = false;
					PlayState.uiHUD.autoplayTxt.visible = false;
					PlayState.preventScoring = false;
					practiceText.visible = false;
					//
					
					Main.switchState(this, new OptionsMenuState());
				case "Exit to menu":
					PlayState.resetMusic();

					//
					PlayState.disableDeath = false;
					PlayState.contents.boyfriendStrums.autoplay = false;
					PlayState.uiHUD.autoplayTxt.visible = false;
					PlayState.preventScoring = false;
					practiceText.visible = false;
					//
					
					PlayState.deaths = 0;

					if (PlayState.isStoryMode)
						Main.switchState(this, new StoryMenuState());
					else
						Main.switchState(this, new FreeplayState());

				//

				// Cheats

				case "Toggle Autoplay":
					PlayState.preventScoring = true;
					PlayState.contents.boyfriendStrums.autoplay = !PlayState.contents.boyfriendStrums.autoplay;
					PlayState.uiHUD.autoplayTxt.visible = PlayState.contents.boyfriendStrums.autoplay;
					PlayState.uiHUD.autoplayTxt.alpha = 1;
					PlayState.uiHUD.autoplaySine = 0;

				case "Toggle Practice Mode":
					PlayState.preventScoring = true;
					PlayState.disableDeath = !PlayState.disableDeath;
					practiceText.visible = PlayState.disableDeath;

				//

				// Change Difficulty
				case "EASY" | "NORMAL" | "HARD":
					PlayState.SONG = Song.loadFromJson(Highscore.formatSong(PlayState.SONG.song.toLowerCase(), curSelected), PlayState.SONG.song.toLowerCase());
					PlayState.storyDifficulty = curSelected;

					//
					PlayState.disableDeath = false;
					PlayState.contents.boyfriendStrums.autoplay = false;
					PlayState.uiHUD.autoplayTxt.visible = false;
					PlayState.preventScoring = false;
					practiceText.visible = false;
					//

					Main.switchState(this, new PlayState());
				case "BACK":
					menuItems = pauseOG;
					regenMenu();

				//
			}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		playingPause = false;

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		//
	}
}