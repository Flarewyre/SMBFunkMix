package meta.subState;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.Song.SwagSong;
import meta.data.font.Alphabet;
import meta.state.*;
import meta.state.menus.*;
import meta.data.*;
import gameObjects.userInterface.GameboyStartup;
import flixel.addons.plugin.screengrab.FlxScreenGrab;

class SongSubState extends MusicBeatSubState
{
	var grpMenuShit:FlxTypedGroup<FlxText>;

	var selector:FlxSprite;

	var menuItems:Array<String> = ['Play', 'Exit'];
	var menuPositioning:Array<Dynamic> = [];
	var curSelected:Int = 0;

	var transitionType = 1;
	var canControl:Bool = false;

	var bg:FlxSprite;
	var bgPos:Float;

	var song:Dynamic;

	public function new(selectedSong, unlocked:Bool = true)
	{
		super();

		song = selectedSong;
		var folderName = song.songName;
		if (folderName == "first-level-:)")
			folderName = "first-level";

		var songJson = Paths.file('songs/' + folderName + '/freeplay.json');

		var bgType:Int = 0;
		var thumbID:Int = 0;
		var songDesc:String = "I HAVE FURY!";

		if (sys.FileSystem.exists(songJson))
		{
			var songData = haxe.Json.parse(sys.io.File.getContent(songJson));
			bgType = songData.bgType;
			thumbID = songData.thumbnail;
			songDesc = (unlocked) ? songData.description : songData.hint;
		}

		if (!unlocked)
		{
			menuItems = ["Exit"];
			thumbID = 15;
			bgType = 6;
		}

		var saveData = Highscore.getData(song.songName);

		#if debug
		// trace('pause call');
		#end

		#if debug
		// trace('pause background');
		#end

		bg = new FlxSprite(0, 0);
		bg.loadGraphic(Paths.image('menus/pixel/song/bg'), true, 160, 120);
		bg.animation.add('idle', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 0, false);
		bg.animation.play('idle');
		bg.animation.frameIndex = bgType;

		bg.setGraphicSize(Std.int(bg.width * 6));
		bg.updateHitbox();
		bg.antialiasing = false;
		bg.alpha = 1;
		bg.scrollFactor.set();
		add(bg);
		bgPos = FlxG.height;

		var songDetails = CoolUtil.dashToSpace(song.songName);
		if (songDetails == 'Hop Hop Heights')
		{
			songDetails = 'Hop-Hop Heights';
		}

		if (!unlocked)
			songDetails = "???";

		var levelInfo:FlxText = new FlxText(0, (4 * 6), 0, "", 8);
		levelInfo.text += songDetails;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("smb1.ttf"), 8);
		levelInfo.setGraphicSize(Std.int(levelInfo.width * 6));
		levelInfo.updateHitbox();
		add(levelInfo);

		var description:FlxText = new FlxText(64 * 6, 23 * 6, 0, songDesc, 8);
		description.scrollFactor.set();
		description.setFormat(Paths.font("pixel_small.ttf"), 5);
		description.setGraphicSize(Std.int(description.width * 6));
		description.updateHitbox();
		add(description);

		var levelThumb:FlxSprite = new FlxSprite(5 * 6, 24 * 6).loadGraphic(Paths.image('menus/pixel/song/thumbnails'), true, 54, 54);
		levelThumb.animation.add('idle', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], 0, false);
		levelThumb.animation.play('idle');
		levelThumb.animation.frameIndex = thumbID;

		levelThumb.setGraphicSize(Std.int(levelThumb.width * 6));
		levelThumb.updateHitbox();
		levelThumb.antialiasing = false;
		levelThumb.alpha = 1;
		levelThumb.scrollFactor.set();
		add(levelThumb);


		var score:FlxText = new FlxText(3 * 6, 80 * 6, 0, Std.string(saveData[0]), 8);
		score.scrollFactor.set();
		score.setFormat(Paths.font("pixel_small.ttf"), 5);
		score.setGraphicSize(Std.int(score.width * 6));

		// again i'm lazy
		// i dont blame you - codist
		switch (score.text.length)
		{
			case 1:
				score.text = "00000" + score.text;
			case 2:
				score.text = "0000" + score.text;
			case 3:
				score.text = "000" + score.text;
			case 4:
				score.text = "00" + score.text;
			case 5:
				score.text = "0" + score.text;
		}

		score.updateHitbox();
		add(score);

		var flagIcon = new FlxSprite(40 * 6, 81 * 6).loadGraphic(Paths.image("UI/default/pixel/flags"), true, 8, 8);
		flagIcon.animation.add("icon", [0, 1, 2, 3, 4], 0, false);
		flagIcon.animation.frameIndex = (saveData[2] == 0) ? 4 : saveData[2];

		flagIcon.setGraphicSize(Std.int(flagIcon.width * 6));
		flagIcon.antialiasing = false;
		flagIcon.updateHitbox();
		add(flagIcon);

		var ratingIcon = new FlxSprite(49 * 6, 81 * 6).loadGraphic(Paths.image("UI/default/pixel/rankings"), true, 8, 8);
		ratingIcon.animation.add("icon", [0, 1, 2, 3, 4, 5, 6, 7], 0, false);
		ratingIcon.animation.frameIndex = saveData[1];
		
		ratingIcon.setGraphicSize(Std.int(ratingIcon.width * 6));
		ratingIcon.antialiasing = false;
		ratingIcon.updateHitbox();
		add(ratingIcon);


		selector = new FlxSprite(0, (12 * 6)).loadGraphic(Paths.image('menus/pixel/song/selector'));
		selector.setGraphicSize(Std.int(selector.width * 6));
		selector.antialiasing = false;
		add(selector);

		levelInfo.screenCenter(X);
		levelInfo.x = Std.int(levelInfo.x / 6) * 6;

		menuPositioning.push([levelInfo, levelInfo.y]);
		menuPositioning.push([description, description.y]);
		menuPositioning.push([levelThumb, levelThumb.y]);

		menuPositioning.push([score, score.y]);
		menuPositioning.push([flagIcon, flagIcon.y]);
		menuPositioning.push([ratingIcon, ratingIcon.y]);
		#if debug
		// trace('pause info');
		#end

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		if (!unlocked) {
			flagIcon.visible = false;
			ratingIcon.visible = false;
			score.visible = false;
		}


		for (i in 0...menuItems.length)
		{
			var songText:FlxText = new FlxText(10 * 6, (10 * 6 * i) + (94 * 6), 0, menuItems[i], 8);
			songText.scrollFactor.set();
			songText.setFormat(Paths.font("pixel_small.ttf"), 5);
			songText.setGraphicSize(Std.int(songText.width * 6));
			songText.updateHitbox();


			grpMenuShit.add(songText);
			menuPositioning.push([songText, songText.y]);
		}

		#if debug
		// trace('change selection');
		#end

		changeSelection();

		menuPositioning.push([selector, selector.y]);

		#if debug
		// trace('cameras');
		#end

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		
		FlxG.sound.play(Paths.sound('pause'), 1);

		#if debug
		// trace('cameras done');
		#end
	}

	override function update(elapsed:Float)
	{
		#if debug
		// trace('call event');
		#end

		super.update(elapsed);

		#if debug
		// trace('updated event');
		#end

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (canControl)
		{
			if (upP)
			{
				changeSelection(-1);
			}
			if (downP)
			{
				changeSelection(1);
			}
		}
		else
		{
			accepted = false;
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Play":
					if (song.songName != "Green-Screen")
					{
						FlxG.sound.play(Paths.sound('coin'), 1);
						FlxFlicker.flicker(grpMenuShit.members[curSelected], 0.8, 0.05, false);
						
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							var poop:String = Highscore.formatSong(song.songName.toLowerCase());

							PlayState.SONG = Song.loadFromJson(poop, song.songName.toLowerCase());
							PlayState.isStoryMode = false;
							PlayState.storyDifficulty = 1;

							PlayState.storyWeek = song.week;
							trace('CUR WEEK' + PlayState.storyWeek);

							if (FlxG.sound.music != null)
								FlxG.sound.music.stop();

							Main.switchState(this, new PlayState());
						});
					}
					else
					{
						var screenCap = FlxScreenGrab.grab();

						Main.switchState(this, new GameboyStartup(screenCap));
					}
				case "Exit":
					transitionType = -1;
					menuPositioning[menuPositioning.length - 1][1] = selector.y;
					canControl = false;
					FlxG.sound.play(Paths.sound('pause'), 1);
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}

		#if debug
		// trace('music volume increased');
		#end

		if (transitionType == 1)
		{
			bgPos -= (18 * 130 * elapsed);
			bg.y = Std.int(bgPos / 6) * 6; 
			if (bgPos <= 0)
			{
				bgPos = 0;
				bg.y = 0;
				transitionType = 0;
				canControl = true;
			}
			for (menuItem in menuPositioning)
			{
				menuItem[0].y = menuItem[1] + bg.y;
			}
		}

		if (transitionType == -1)
		{
			bgPos += (18 * 130 * elapsed);
			bg.y = Std.int(bgPos / 6) * 6; 
			if (bgPos >= FlxG.height)
			{
				bgPos = FlxG.height;
				bg.y = FlxG.height;
				transitionType = 0;
				close();
			}
			for (menuItem in menuPositioning)
			{
				menuItem[0].y = menuItem[1] + bg.y;
			}
		}
	}

	override function destroy()
	{
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;
		
		if (change != 0)
		{
			FlxG.sound.play(Paths.sound('menu_select'), 1);
		}

		var bullShit:Int = 0;

		#if debug
		// trace('mid selection');
		#end

		for (item in grpMenuShit.members)
		{
			//item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (bullShit == curSelected)
			{
				//item.alpha = 1;
				selector.x = item.x;
				selector.y = item.y;

				selector.x -= (2 * 6);
				selector.y += (5 * 6);

				selector.x -= 2;
				selector.y += 0.5;
				// item.setGraphicSize(Std.int(item.width));
			}

			bullShit++;
		}

		#if debug
		// trace('finished selection');
		#end
		//
	}
}
