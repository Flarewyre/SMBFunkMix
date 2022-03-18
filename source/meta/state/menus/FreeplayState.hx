package meta.state.menus;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ColorTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
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
import meta.subState.*;

using StringTools;

class FreeplayState extends MusicBeatState
{
	//
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curSongPlaying:Int = -1;
	var curDifficulty:Int = 1;

	var songThread:Thread;
	var threadActive:Bool = true;

	private var grpSongs:FlxTypedGroup<FlxText>;
	private var grpIcons:FlxTypedGroup<FlxSprite>;
	private var grpFlags:FlxTypedGroup<FlxSprite>;
	private var grpRatings:FlxTypedGroup<FlxSprite>;

	private var curPlaying:Bool = false;
	private var canControl:Bool = true;

	private var mainColor = FlxColor.WHITE;

	private var existingSongs:Array<String> = [];
	private var existingDifficulties:Array<Array<String>> = [];

	private var selectedCategory:Int = 0;
	private var nextFlash:Float = 0.5;

	private var secretGroup:FlxTypedGroup<FlxSprite>;
	private var secretDoor:FlxSprite;
	
	private var secretCount:Int = 0;
	private var secretTimer:Float = 0;

	private var secretSongs:Array<String> = ["first-level-:)", "Green-Screen", "Wrong-Warp"];
	private var lockedSongs:Array<String> = [];

	var bg:FlxSprite;
	var arrow:FlxSprite;
	var grpName:FlxText;

	override function create()
	{
		super.create();

		selectedCategory = 0;

		/**
			Wanna add songs? They're in the Main state now, you can just find the week array and add a song there to a specific week.
			Alternatively, you can make a folder in the Songs folder and put your songs there, however, this gives you less
			control over what you can display about the song (color, icon, etc) since it will be pregenerated for you instead.
		**/
		// load in all songs that exist in folder
		// var folderSongs:Array<String> = CoolUtil.returnAssetsLibrary('songs', 'assets');

		///*
		// for (i in 0...Main.gameWeeks.length)
		// {
		// 	addWeek(Main.gameWeeks[i][0], i, Main.gameWeeks[i][1], Main.gameWeeks[i][2]);
		// 	for (j in cast(Main.gameWeeks[i][0], Array<Dynamic>))
		// 		existingSongs.push(j.toLowerCase());
		// }

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

		// SECRET STUFF
		secretGroup = new FlxTypedGroup<FlxSprite>();

		var secretBg = new FlxSprite(0, 0);
		secretBg.loadGraphic(Paths.image('menus/pixel/freeplay/firstLevel/bgfirst'));
		secretBg.setGraphicSize(Std.int(secretBg.width * 6));
		secretBg.updateHitbox();
		secretBg.antialiasing = false;
		secretGroup.add(secretBg);

		secretDoor = new FlxSprite(72*6, 51*6);
		secretDoor.loadGraphic(Paths.image('menus/pixel/freeplay/firstLevel/door'), true, 16, 32);
		
		var animSpeed = 15;
		secretDoor.animation.add("closed", [0], animSpeed, true);
		secretDoor.animation.add("open1", [1,2], animSpeed, false);
		secretDoor.animation.add("open2", [3,4], animSpeed, false);
		secretDoor.animation.add("open3", [5,6], animSpeed, false);
		secretDoor.animation.add("open4", [7,8], animSpeed, false);
		secretDoor.animation.add("open5", [9,10], animSpeed, false);

		secretDoor.animation.play("closed");
		
		secretDoor.setGraphicSize(Std.int(secretDoor.width * 6));
		secretDoor.updateHitbox();
		secretDoor.antialiasing = false;

		var secretDoorShadow = new FlxSprite(secretDoor.x + (2*6), secretDoor.y + (2*6));
		secretDoorShadow.loadGraphic(Paths.image('menus/pixel/freeplay/firstLevel/door_shadow'));
		secretDoorShadow.setGraphicSize(Std.int(secretDoorShadow.width * 6));
		secretDoorShadow.updateHitbox();
		secretDoorShadow.alpha = 0.36;
		secretDoorShadow.antialiasing = false;
		
		secretGroup.add(secretDoorShadow);
		secretGroup.add(secretDoor);

		var cursor = new FlxSprite();
		cursor.makeGraphic(15, 15, FlxColor.TRANSPARENT);

		FlxG.mouse.load(cursor.pixels);

		// LOAD CHARACTERS

		bg = new FlxSprite(0, 0);
		bg.loadGraphic(Paths.image('menus/pixel/freeplay/bg'), true, 160, 120);
		bg.animation.add('idle', [0, 1], 0, false);
		bg.animation.play('idle');

		bg.setGraphicSize(Std.int(bg.width * 6));
		bg.updateHitbox();
		bg.antialiasing = false;
		add(bg);

		secretGroup.visible = false;
		add(secretGroup);

		arrow = new FlxSprite(147 * 6, 104 * 6);
		arrow.loadGraphic(Paths.image('menus/pixel/freeplay/arrow'));
		arrow.setGraphicSize(Std.int(arrow.width * 6));
		arrow.updateHitbox();
		arrow.antialiasing = false;
		add(arrow);

		grpName = new FlxText(0, (103 * 6), 0, "STORY MODE", 8);
		grpName.scrollFactor.set();
		grpName.setFormat(Paths.font("smb1.ttf"), 8);
		grpName.setGraphicSize(Std.int(grpName.width * 6));
		grpName.updateHitbox();
		
		grpName.screenCenter(X);
		grpName.x = Std.int(grpName.x / 6) * 6;
		add(grpName);

		grpSongs = new FlxTypedGroup<FlxText>();
		add(grpSongs);

		grpIcons = new FlxTypedGroup<FlxSprite>();
		add(grpIcons);

		grpFlags = new FlxTypedGroup<FlxSprite>();
		add(grpFlags);

		grpRatings = new FlxTypedGroup<FlxSprite>();
		add(grpRatings);

		addWeeks();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);
	}

	function addWeeks()
	{
		songs = [];

		///*
		for (i in 0...Main.gameWeeks.length)
		{
			if (selectedCategory == Main.gameWeeks[i][4])
			{
				addWeek(Main.gameWeeks[i][0], i, Main.gameWeeks[i][1], Main.gameWeeks[i][2]);
				for (j in cast(Main.gameWeeks[i][0], Array<Dynamic>))
					existingSongs.push(j.toLowerCase());
			}
		}

		grpSongs.clear();
		grpIcons.clear();
		grpFlags.clear();
		grpRatings.clear();

		lockedSongs = [];

		for (i in 0...songs.length)
		{
			var saveData = Highscore.getData(songs[i].songName);

			var unlocked = true;
			if (secretSongs.contains(songs[i].songName) && saveData[0] == 0)
				unlocked = false;

			var songDetails = CoolUtil.dashToSpace(songs[i].songName);
			if (songDetails == 'Hop Hop Heights')
			{
				songDetails = 'Hop-Hop Heights';
			}

			if (!unlocked) 
			{
				lockedSongs.push(songs[i].songName);
				songDetails = "???";
			}
			
			var songText:FlxText = new FlxText((20 * 6), (9 * 6 * i) + (11 * 6), 0, songDetails, 8);
			songText.scrollFactor.set();
			songText.setFormat(Paths.font("pixel_small.ttf"), 5);
			songText.setGraphicSize(Std.int(songText.width * 6));
			songText.updateHitbox();
			grpSongs.add(songText);

			var iconName = "icons";
			if (selectedCategory == 1)
			{
				iconName = "icons2";
			}

			var icon:FlxSprite = new FlxSprite(15 * 6, songText.y + (5 * 6)).loadGraphic(Paths.image("menus/pixel/freeplay/" + iconName), true, 8, 8);
			icon.animation.add("icon", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 0, false);
			icon.animation.frameIndex = (unlocked) ? i : 9;

			icon.setGraphicSize(Std.int(icon.width * 6));
			icon.antialiasing = false;
			grpIcons.add(icon);

			var flag:FlxSprite = new FlxSprite(136 * 6, songText.y + (5 * 6)).loadGraphic(Paths.image("UI/default/pixel/flags"), true, 8, 8);
			flag.animation.add("icon", [0, 1, 2, 3, 4], 0, false);
			flag.animation.frameIndex = (saveData[2] == 0) ? 4 : saveData[2];

			flag.setGraphicSize(Std.int(flag.width * 6));
			flag.antialiasing = false;
			grpFlags.add(flag);

			var rating:FlxSprite = new FlxSprite(146 * 6, songText.y + (5 * 6)).loadGraphic(Paths.image("UI/default/pixel/rankings"), true, 8, 8);
			rating.animation.add("icon", [0, 1, 2, 3, 4, 5, 6, 7], 0, false);
			rating.animation.frameIndex = saveData[1];

			rating.setGraphicSize(Std.int(rating.width * 6));
			rating.antialiasing = false;
			grpRatings.add(rating);
		}
		changeSelection();
	}

	function changeCategorySelection(change:Int = 0)
	{
		var oldCategory = selectedCategory;
		selectedCategory += change;

		if (selectedCategory > 1)
			selectedCategory = 1;
		else if (selectedCategory < -1)
			selectedCategory = -1;

		if (oldCategory != selectedCategory)
		{
			addWeeks();
			FlxG.sound.play(Paths.sound('menu_select'), 1);

			var grpText = (selectedCategory == 0) ? "STORY MODE" : "CHALLENGES";

			if (selectedCategory == -1)
				grpText = "???";

			secretGroup.visible = (selectedCategory == -1) ? true : false;
			FlxG.mouse.visible = (selectedCategory == -1) ? true : false;

			grpName.text = grpText;
			grpName.updateHitbox();
			grpName.screenCenter(X);
			grpName.x = Std.int(grpName.x / 6) * 6;
		}

		arrow.x = (selectedCategory == 1) ? (6 * 6) : (147 * 6);
		arrow.flipX = (selectedCategory == 1) ? true : false;

		bg.animation.frameIndex = selectedCategory;
		curSelected = 0;

		changeSelection();
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

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var accepted = controls.ACCEPT;

		if (canControl)
		{
			if (upP)
				changeSelection(-1);
			else if (downP)
				changeSelection(1);

			if (leftP)
				changeCategorySelection(-1);
			if (rightP)
				changeCategorySelection(1);

			if (controls.BACK)
			{
				threadActive = false;
				Main.switchState(this, new MainMenuState());
			}
		}

		if (selectedCategory == -1)
		{
			// secret door
			var rect = new FlxRect(secretDoor.x, secretDoor.y, secretDoor.width, secretDoor.height);
			if (FlxMath.pointInFlxRect(FlxG.mouse.screenX, FlxG.mouse.screenY, rect))
			{
				if (FlxG.mouse.justPressed)
				{
					if (secretCount >= 10)
						return;

					secretCount += 1;
					secretTimer = 0.3;

					if (secretCount >= 10)
					{
						canControl = false;

						FlxG.sound.play(Paths.sound('door_open'), 0.5);
						secretDoor.animation.play("open" + Std.string(FlxG.random.int(1, 4)) );
						new FlxTimer().start(3.0, gotoEasterEgg, 1);
					} 
					else
					{
						FlxG.sound.play(Paths.sound('knock' + Std.string(FlxG.random.int(1, 4) )), 0.5);
					}
				}
			}

			secretTimer -= elapsed;
			if (secretCount > 0 && secretCount < 10 && secretTimer <= 0) {
				secretCount = 0;
			} 
		}

		if (accepted && canControl && selectedCategory != -1)
		{
			persistentUpdate = false;
			persistentDraw = true;

			var unlocked = !lockedSongs.contains(songs[curSelected].songName);
			openSubState(new SongSubState(songs[curSelected], unlocked));
		}

		nextFlash -= elapsed;
		if (nextFlash <= 0)
		{
			arrow.visible = !arrow.visible;
			nextFlash = 0.5;
		}
	}

	var lastDifficulty:String;

	function changeSelection(change:Int = 0)
	{
		if (selectedCategory < 0)
			return;

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

	function gotoEasterEgg(timer:FlxTimer):Void {

		var saveData = Highscore.getData("first-level-:)");
		
		trace(saveData);
		if (saveData[0] == 0)
		{
			var black = new FlxSprite();
			black.makeGraphic(1280, 1280, FlxColor.BLACK);
			add(black);

			var songName = "First-Level";
			var curDifficulty = 1;
			var poop:String = Highscore.formatSong(songName);

			PlayState.SONG = Song.loadFromJson(poop, songName);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = 0;
			trace('CUR WEEK' + PlayState.storyWeek);

			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			
			Main.switchState(this, new PlayState());
		}
		else
		{
			canControl = true;
			secretDoor.animation.play("closed");
			secretCount = 0;
		}
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
