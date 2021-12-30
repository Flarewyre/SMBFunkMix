package meta.state.menus;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ColorTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.userInterface.HealthIcon;
import lime.utils.Assets;
import meta.CoolUtil;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Song.SwagSong;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import openfl.media.Sound;
import sys.FileSystem;
import sys.thread.Thread;

using StringTools;

class FreeplayState extends MusicBeatState
{
	//
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curSongPlaying:Int = -1;
	var curDifficulty:Int = 1;

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var songThread:Thread;
	var threadActive:Bool = true;

	private var grpSongs:FlxTypedGroup<FlxText>;
	private var curPlaying:Bool = false;
	private var canControl:Bool = true;

	private var mainColor = FlxColor.WHITE;

	private var existingSongs:Array<String> = [];
	private var existingDifficulties:Array<Array<String>> = [];

	override function create()
	{
		super.create();

		/**
			Wanna add songs? They're in the Main state now, you can just find the week array and add a song there to a specific week.
			Alternatively, you can make a folder in the Songs folder and put your songs there, however, this gives you less
			control over what you can display about the song (color, icon, etc) since it will be pregenerated for you instead.
		**/
		// load in all songs that exist in folder
		// var folderSongs:Array<String> = CoolUtil.returnAssetsLibrary('songs', 'assets');

		///*
		for (i in 0...Main.gameWeeks.length)
		{
			addWeek(Main.gameWeeks[i][0], i, Main.gameWeeks[i][1], Main.gameWeeks[i][2]);
			for (j in cast(Main.gameWeeks[i][0], Array<Dynamic>))
				existingSongs.push(j.toLowerCase());
		}

		// */

		// for (i in folderSongs)
		// {
		// 	if (!existingSongs.contains(i.toLowerCase()))
		// 	{
		// 		var icon:String = 'gf';
		// 		var chartExists:Bool = FileSystem.exists(Paths.songJson(i, i));
		// 		if (chartExists)
		// 		{
		// 			var castSong:SwagSong = Song.loadFromJson(i, i);
		// 			icon = (castSong != null) ? castSong.player2 : 'gf';
		// 			addSong(CoolUtil.spaceToDash(castSong.song), 1, icon, FlxColor.WHITE);
		// 		}
		// 	}
		// }

		// LOAD MUSIC
		ForeverTools.playFreeplayMusic();

		#if !html5
		Discord.changePresence('FREEPLAY MENU', 'Main Menu');
		#end

		// LOAD CHARACTERS

		var map:FlxSprite = new FlxSprite(0, 93 * 6);
		map.loadGraphic(Paths.image('menus/pixel/freeplay/map'));
		map.setGraphicSize(Std.int(map.width * 6));
		map.updateHitbox();
		map.antialiasing = false;
		add(map);

		var infoText:FlxSprite = new FlxSprite(37 * 6, 10 * 6);
		infoText.loadGraphic(Paths.image('menus/pixel/freeplay/text'));
		infoText.setGraphicSize(Std.int(infoText.width * 6));
		infoText.updateHitbox();
		infoText.antialiasing = false;
		add(infoText);

		grpSongs = new FlxTypedGroup<FlxText>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:FlxText = new FlxText((22 * 6), (9 * 6 * i) + (30 * 6), 0, CoolUtil.dashToSpace(songs[i].songName), 8);
			songText.scrollFactor.set();
			songText.setFormat(Paths.font("smb1.ttf"), 8);
			songText.setGraphicSize(Std.int(songText.width * 6));
			songText.updateHitbox();
			grpSongs.add(songText);

			var icon:FlxSprite = new FlxSprite(12 * 6, songText.y + (7 * 6)).loadGraphic(Paths.image("menus/pixel/freeplay/icons"), true, 8, 8);
			icon.animation.add("icon", [0, 1, 2, 3, 4, 5, 6, 7], 0, false);
			icon.animation.frameIndex = i;

			icon.setGraphicSize(Std.int(icon.width * 6));
			icon.antialiasing = false;
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, songColor:FlxColor)
	{
		///*
		var coolDifficultyArray = [];
		for (i in CoolUtil.difficultyArray)
			if (FileSystem.exists(Paths.songJson(songName, songName + '-' + i))
				|| (FileSystem.exists(Paths.songJson(songName, songName)) && i == "NORMAL"))
				coolDifficultyArray.push(i);

		if (coolDifficultyArray.length > 0)
		{ //*/
			songs.push(new SongMetadata(songName, weekNum, songCharacter, songColor));
			existingDifficulties.push(coolDifficultyArray);
		}
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, ?songColor:Array<FlxColor>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];
		if (songColor == null)
			songColor = [FlxColor.WHITE];

		var num:Array<Int> = [0, 0];
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num[0]], songColor[num[1]]);

			if (songCharacters.length != 1)
				num[0]++;
			if (songColor.length != 1)
				num[1]++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var lerpVal = Main.framerateAdjust(0.1);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (canControl)
		{
			if (upP)
				changeSelection(-1);
			else if (downP)
				changeSelection(1);

			if (controls.BACK)
			{
				threadActive = false;
				Main.switchState(this, new MainMenuState());
			}
		}

		if (accepted && canControl)
		{
			FlxG.sound.play(Paths.sound('coin'), 1);
			FlxFlicker.flicker(grpSongs.members[curSelected], 0.8, 0.05, false);
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(),
					CoolUtil.difficultyArray.indexOf(existingDifficulties[curSelected][curDifficulty]));

				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				PlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + PlayState.storyWeek);

				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();

				threadActive = false;

				Main.switchState(this, new PlayState());
			});
		}
	}

	var lastDifficulty:String;

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;
		if (lastDifficulty != null && change != 0)
			while (existingDifficulties[curSelected][curDifficulty] == lastDifficulty)
				curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = existingDifficulties[curSelected].length - 1;
		if (curDifficulty > existingDifficulties[curSelected].length - 1)
			curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		lastDifficulty = existingDifficulties[curSelected][curDifficulty];
	}

	function changeSelection(change:Int = 0)
	{
		if (change != 0)
		{
			FlxG.sound.play(Paths.sound('menu_select'), 1);
		}

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		// set up color stuffs
		mainColor = songs[curSelected].songColor;

		// song switching stuffs

		var bullShit:Int = 0;

		for (item in grpSongs.members)
		{
			bullShit++;

			item.color = 0xE69C21;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (curSelected == bullShit - 1)
			{
				item.color = 0xFFFFFF;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		//

		trace("curSelected: " + curSelected);

		changeDiff();
	}

	function changeSongPlaying()
	{
		if (songThread == null)
		{
			songThread = Thread.create(function()
			{
				while (true)
				{
					if (!threadActive)
					{
						trace("Killing thread");
						return;
					}

					var index:Null<Int> = Thread.readMessage(false);
					if (index != null)
					{
						if (index == curSelected && index != curSongPlaying)
						{
							trace("Loading index " + index);

							var inst:Sound = Sound.fromFile('./' + Paths.inst(songs[curSelected].songName));

							if (index == curSelected && threadActive)
							{
								FlxG.sound.playMusic(inst);

								if (FlxG.sound.music.fadeTween != null)
									FlxG.sound.music.fadeTween.cancel();

								FlxG.sound.music.volume = 0.0;
								FlxG.sound.music.fadeIn(1.0, 0.0, 1.0);

								curSongPlaying = curSelected;
							}
							else
								trace("Nevermind, skipping " + index);
						}
						else
							trace("Skipping " + index);
					}
				}
			});
		}

		songThread.sendMessage(curSelected);
	}

	var playingSongs:Array<FlxSound> = [];
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var songColor:FlxColor = FlxColor.WHITE;

	public function new(song:String, week:Int, songCharacter:String, songColor:FlxColor)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.songColor = songColor;
	}
}
