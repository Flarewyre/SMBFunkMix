package meta.state.menus;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.effects.FlxFlicker;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import meta.state.menus.*;
import openfl.Assets;
import gameObjects.userInterface.GameboyStartup;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flash.display.Bitmap;

using StringTools;

/**
	This is the main menu state! Not a lot is going to change about it so it'll remain similar to the original, but I do want to condense some code and such.
	Get as expressive as you can with this, create your own menu!
**/
class MainMenuState extends MusicBeatState
{
	var grpMenuShit2:FlxTypedGroup<FlxText>;
	var grpMenuShit:FlxTypedGroup<FlxText>;

	var selector:FlxSprite;

	var curSelected:Int = 0;
	var curGroup:Int = 0;

	var bg:FlxSprite;
	var bg2:FlxSprite;
	var bgPos:FlxPoint;

	var submenu:FlxSprite;
	var submenuGroup:FlxTypedGroup<FlxBasic>;

	var mario:FlxSprite;
	var marioY:Float;
	var timeUntilStart:Float = 0.4;
	var marioVelocity:Float = 0;
	
	var thumbnail:FlxSprite;

	var menuItems:Array<String> = ['STORY MODE', 'FREEPLAY', 'OPTIONS', 'EXTRAS'];
	var menuItems2:Array<String> = ['CREDITS', 'RESET SAVE', 'BACK'];
	var menuItems3:Array<String> = ['WORLD 1', 'WORLD 2', 'BACK'];
	var curArray:Array<String>;
	var canSnap:Array<Float> = [];
	var canControl:Bool = true;
	var resetSave:Bool = false;
	var allCompleted:Bool = false;

	var codeStep:Int = 0;

	// the create 'state'
	override function create()
	{
		controls.setKeyboardScheme(None, false);
		super.create();

		// var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);

		// diamond.persist = true;
		// diamond.destroyOnNoUse = false;

		// FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.25, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
		// 	new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		// FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.25, new FlxPoint(0, 1), {asset: diamond, width: 32, height: 32},
		// 	new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		// */

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		#if !html5
		Discord.changePresence('MENU SCREEN', 'Main Menu');
		#end

		persistentUpdate = persistentDraw = true;
		submenuGroup = new FlxTypedGroup<FlxBasic>();

		bg = new FlxSprite();
		bg.loadGraphic(Paths.image('menus/pixel/title/bg'));
		bg.setGraphicSize(Std.int(bg.width * 6));
		bg.updateHitbox();
		bg.antialiasing = false;
		add(bg);

		bg2 = new FlxSprite();
		bg2.loadGraphic(Paths.image('menus/pixel/title/bg'));
		bg2.setGraphicSize(Std.int(bg2.width * 6));
		bg2.updateHitbox();
		bg2.antialiasing = false;
		add(bg2);

		bgPos = new FlxPoint();

		thumbnail = new FlxSprite(103 * 6, 38 * 6).loadGraphic(Paths.image('menus/pixel/title/thumbnails'), true, 46, 46);
		thumbnail.animation.add('idle', [0, 1, 2, 3], 0, false);
		thumbnail.animation.play('idle');
		thumbnail.animation.frameIndex = 0;

		thumbnail.setGraphicSize(Std.int(thumbnail.width * 6));
		thumbnail.updateHitbox();
		thumbnail.antialiasing = false;
		add(thumbnail);

		selector = new FlxSprite(0, (12 * 6)).loadGraphic(Paths.image('menus/pixel/title/selector'));
		selector.setGraphicSize(Std.int(selector.width * 6));
		selector.antialiasing = false;
		add(selector);

		submenu = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/pixel/title/delete-save'));
		submenu.setGraphicSize(Std.int(submenu.width * 6));
		submenu.updateHitbox();

		// submenu group
		var submenuText = new FlxText(0, 0, 0, 'Are you sure?\n\nPress L+R to confirm', 8);
		submenuText.scrollFactor.set();
		submenuText.setFormat(Paths.font("pixel_small.ttf"), 5, FlxColor.WHITE, CENTER);
		submenuText.setGraphicSize(Std.int(submenuText.width * 6));
		submenuText.updateHitbox();

		submenuText.screenCenter();
		submenuText.x = Std.int(submenuText.x / 6) * 6;
		submenuText.y = Std.int(submenuText.y / 6) * 6;
		submenuText.y -= 24 * 6;

		var submenuText2 = new FlxText(0, 0, 0, 'Press ESC to exit', 8);
		submenuText2.scrollFactor.set();
		submenuText2.setFormat(Paths.font("pixel_small.ttf"), 5, FlxColor.WHITE, CENTER);
		submenuText2.setGraphicSize(Std.int(submenuText2.width * 6));
		submenuText2.updateHitbox();

		submenuText2.screenCenter();
		submenuText2.x = Std.int(submenuText2.x / 6) * 6;
		submenuText2.y = Std.int(submenuText2.y / 6) * 6;
		submenuText2.y += 24 * 6;
		
		mario = new FlxSprite().loadGraphic(Paths.image('menus/pixel/title/mario'), true, 16, 16);
		mario.animation.add("idle", [0], 0, false);
		mario.animation.add("die", [1], 0, false);
		mario.setGraphicSize(Std.int(mario.width * 6));
		mario.updateHitbox();

		mario.screenCenter();
		mario.x = Std.int(mario.x / 6) * 6;
		mario.y = Std.int(mario.y / 6) * 6;
		marioY = mario.y;

		submenuGroup.add(submenuText);
		submenuGroup.add(submenuText2);
		submenuGroup.add(mario);

		grpMenuShit2 = new FlxTypedGroup<FlxText>();
		add(grpMenuShit2);

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		add(submenu);

		curArray = menuItems;
		addMenuItems();

		var bricks = new FlxSprite(0, 0);
		bricks.loadGraphic(Paths.image('menus/pixel/title/bricks'));
		bricks.setGraphicSize(Std.int(bricks.width * 6));
		bricks.updateHitbox();
		bricks.antialiasing = false;
		add(bricks);

		var version = new FlxSprite(0, 0);
		version.loadGraphic(Paths.image('menus/pixel/title/info'));
		version.setGraphicSize(Std.int(version.width * 6));
		version.updateHitbox();
		version.antialiasing = false;
		add(version);

		add(submenuGroup);

		submenu.visible = false;
		submenuGroup.visible = false;

		changeSelection();

		allCompleted = true;
		for (i in 0...Main.gameWeeks.length)
		{
			for (j in 0...Main.gameWeeks[i][0].length)
			{
				var songName = Main.gameWeeks[i][0][j];
				if (Highscore.getData(songName)[0] == 0)
				{
					allCompleted = false;
					break;
				}
			} 
		}
	}

	function addMenuItems()
	{
		grpMenuShit.clear();
		grpMenuShit2.clear();
		for (i in 0...curArray.length)
		{
			var songText:FlxText = new FlxText(10 * 6, (16 * 6 * i) + (29 * 6), 0, curArray[i], 8);
			songText.scrollFactor.set();
			songText.setFormat(Paths.font("smb1.ttf"), 8);
			songText.setGraphicSize(Std.int(songText.width * 6));
			songText.updateHitbox();

			var songText2:FlxText = new FlxText(0, 0, 0, curArray[i], 8);
			songText2.scrollFactor.set();
			songText2.setFormat(Paths.font("smb1.ttf"), 8);
			songText2.setGraphicSize(Std.int(songText2.width * 6));
			songText2.updateHitbox();
			songText2.x = songText.x + 1 * 6;
			songText2.y = songText.y + 1 * 6;
			songText2.color = 0x000000;

			grpMenuShit2.add(songText2);
			grpMenuShit.add(songText);

			canControl = true;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

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

			if (controls.BACK)
			{
				if (curGroup == 0)
				{
					Main.switchState(this, new TitleState());
				}
				else
				{
					changeCategorySelection(0);
				}
			}
		}
		else
		{
			accepted = false;
			if (submenu.visible)
			{
				if (!resetSave)
				{
					if (controls.BACK)
					{
						canControl = true;
						submenu.visible = false;
						submenuGroup.visible = false;
					}
					
					if (FlxG.keys.pressed.L && FlxG.keys.pressed.R)
					{
						mario.animation.play("die");

						if (FlxG.sound.music != null)
							FlxG.sound.music.stop();
						
						FlxG.sound.play(Paths.sound('death'), 1);

						new FlxTimer().start(3, wipeSave, 1);

						marioVelocity = -750;
						resetSave = true;
					}
				}
				else
				{
					timeUntilStart -= elapsed;
					if (timeUntilStart <= 0)
					{
						marioVelocity += (12.5 * 130 * elapsed);
						marioY += marioVelocity * elapsed;

						mario.y = Std.int(marioY / 6) * 6;
					}
				}
			}
		}

		if (accepted)
		{
			var daSelected:String = curArray[curSelected];
			var menuItem = grpMenuShit.members[curSelected];
			var menuItemBG = grpMenuShit2.members[curSelected];
			canControl = false;

			switch (daSelected)
			{
				case "WORLD 1":
					FlxG.sound.play(Paths.sound('coin'), 1);

					FlxFlicker.flicker(menuItem, 1, 0.05);
					FlxFlicker.flicker(menuItemBG, 1, 0.05);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						PlayState.storyPlaylist = Main.gameWeeks[0][0].copy();
						PlayState.isStoryMode = true;

						var diffic:String = '-' + CoolUtil.difficultyFromNumber(1).toLowerCase();
						diffic = diffic.replace('-normal', '');

						PlayState.storyDifficulty = 1;

						PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
						PlayState.storyWeek = 0;
						PlayState.campaignScore = 0;

						CutsceneState.sceneNum = 0;
						Main.switchState(this, new CutsceneState());
					});
				case "WORLD 2":
					FlxG.sound.play(Paths.sound('coin'), 1);

					FlxFlicker.flicker(menuItem, 1, 0.05);
					FlxFlicker.flicker(menuItemBG, 1, 0.05);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						PlayState.storyPlaylist = Main.gameWeeks[1][0].copy();
						PlayState.isStoryMode = true;

						var diffic:String = '-' + CoolUtil.difficultyFromNumber(1).toLowerCase();
						diffic = diffic.replace('-normal', '');

						PlayState.storyDifficulty = 1;

						PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
						PlayState.storyWeek = 0;
						PlayState.campaignScore = 0;

						CutsceneState.sceneNum = 3;
						Main.switchState(this, new CutsceneState());
					});
				case "STORY MODE":
					FlxG.sound.play(Paths.sound('stomp'), 1);

					FlxFlicker.flicker(menuItem, 1, 0.05);
					FlxFlicker.flicker(menuItemBG, 1, 0.05);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						changeCategorySelection(2);
					});
				case "STORY MODElol":
					FlxG.sound.play(Paths.sound('coin'), 1);

					FlxFlicker.flicker(menuItem, 1, 0.05);
					FlxFlicker.flicker(menuItemBG, 1, 0.05);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						PlayState.storyPlaylist = Main.gameWeeks[0][0].copy();
						PlayState.isStoryMode = true;

						var diffic:String = '-' + CoolUtil.difficultyFromNumber(1).toLowerCase();
						diffic = diffic.replace('-normal', '');

						PlayState.storyDifficulty = 1;

						PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
						PlayState.storyWeek = 0;
						PlayState.campaignScore = 0;

						CutsceneState.sceneNum = 5;
						Main.switchState(this, new CutsceneState());
					});
				case "FREEPLAY":
					FlxG.sound.play(Paths.sound('stomp'), 1);
					
					FlxFlicker.flicker(menuItem, 1, 0.05);
					FlxFlicker.flicker(menuItemBG, 1, 0.05);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						Main.switchState(this, new FreeplayState());
					});
				case "OPTIONS":
					FlxG.sound.play(Paths.sound('stomp'), 1);

					FlxFlicker.flicker(menuItem, 1, 0.05);
					FlxFlicker.flicker(menuItemBG, 1, 0.05);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						Main.switchState(this, new OptionsMenuState());
					});
				case "EXTRAS":
					FlxG.sound.play(Paths.sound('stomp'), 1);
					
					FlxFlicker.flicker(menuItem, 1, 0.05);
					FlxFlicker.flicker(menuItemBG, 1, 0.05);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						changeCategorySelection(1);
					});
				case "BACK":
					FlxG.sound.play(Paths.sound('stomp'), 1);
					
					FlxFlicker.flicker(menuItem, 1, 0.05);
					FlxFlicker.flicker(menuItemBG, 1, 0.05);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						changeCategorySelection(0);
					});
				case "CREDITS":
					if (allCompleted)
					{
						FlxG.sound.play(Paths.sound('coin'), 1);
						
						FlxFlicker.flicker(menuItem, 1, 0.05, true);
						FlxFlicker.flicker(menuItemBG, 1, 0.05, true);
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							Main.switchState(this, new CreditsState());
						});
					}
					else
					{
						FlxG.sound.play(Paths.sound('bump'), 1);
						canControl = true;
					}
				case "RESET SAVE":
					FlxG.sound.play(Paths.sound('stomp'), 1);
					
					FlxFlicker.flicker(menuItem, 1, 0.05, true);
					FlxFlicker.flicker(menuItemBG, 1, 0.05, true);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						submenu.visible = true;
						submenuGroup.visible = true;
					});
			}
		}

		bgPos.x -= 96 * elapsed;
		if (bgPos.x + bg.width <= 0)
		{
			bgPos.x = 0;
		}
		bg.x = Std.int(bgPos.x / 6) * 6;
		bg2.x = bg.x + bg.width;

		codeLogic();
	}

	function changeCategorySelection(newGroup:Int)
	{
		curGroup = newGroup;
		curSelected = 0;

		curArray = menuItems;
		if (newGroup == 1)
		{
			curArray = menuItems2;
		}
		if (newGroup == 2)
		{
			curArray = menuItems3;
		}

		addMenuItems();
		changeSelection();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = curArray.length - 1;
		if (curSelected >= curArray.length)
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
			// item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (bullShit == curSelected)
			{
				// item.alpha = 1;
				selector.x = item.x;
				selector.y = item.y;

				selector.x -= (4 * 6);
				selector.y += (7 * 6);

				selector.x += 4;
				selector.y += 4;
				// item.setGraphicSize(Std.int(item.width));
			}

			bullShit++;
		}

		thumbnail.animation.frameIndex = curSelected + (4 * curGroup);

		#if debug
		// trace('finished selection');
		#end
		//
	}

	function codeLogic()
	{
		if (FlxG.keys.anyJustPressed([UP, DOWN, LEFT, RIGHT, B, A]))
		{
			var resetCode = true;

			trace(codeStep);
			// fuck this code i hate it - codist

			switch (codeStep)
			{
				case 0:
					if (FlxG.keys.justPressed.UP)
						resetCode = false;
				case 1:
					if (FlxG.keys.justPressed.UP)
						resetCode = false;
				case 2:
					if (FlxG.keys.justPressed.DOWN)
						resetCode = false;
				case 3:
					if (FlxG.keys.justPressed.DOWN)
						resetCode = false;
				case 4:
					if (FlxG.keys.justPressed.LEFT)
						resetCode = false;
				case 5:
					if (FlxG.keys.justPressed.RIGHT)
						resetCode = false;
				case 6:
					if (FlxG.keys.justPressed.LEFT)
						resetCode = false;
				case 7:
					if (FlxG.keys.justPressed.RIGHT)
						resetCode = false;
				case 8:
					if (FlxG.keys.justPressed.B)
						resetCode = false;
				case 9:
					if (FlxG.keys.justPressed.A) {
						trace("wow");
						gotoEasterEgg();
					}
			} 

			if (resetCode)
				codeStep = 0;
			else
			{
				codeStep += 1;
			}
			
		}
	}

	function gotoEasterEgg():Void 
	{
		var screenCap = FlxScreenGrab.grab();

		Main.switchState(this, new GameboyStartup(screenCap));
	}

	function wipeSave(timer:FlxTimer):Void 
	{
		FlxG.save.erase();
		FlxG.save.close();

		Highscore.songData.clear();
		Highscore.songScores.clear();

		FlxG.resetGame();
	}
}
