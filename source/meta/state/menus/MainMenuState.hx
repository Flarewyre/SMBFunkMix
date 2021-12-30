package meta.state.menus;

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

	var bg:FlxSprite; // the background has been separated for more control
	var magenta:FlxSprite;

	var menuItems:Array<String> = ['STORY MODE', 'FREEPLAY', 'OPTIONS'];
	var canSnap:Array<Float> = [];
	var canControl:Bool = true;

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

		// uh
		persistentUpdate = persistentDraw = true;

		// background
		bg = new FlxSprite();
		bg.loadGraphic(Paths.image('menus/pixel/title/bg'));
		bg.setGraphicSize(Std.int(bg.width * 6));
		bg.updateHitbox();
		bg.antialiasing = false;
		add(bg);

		// logo
		var logo = new FlxSprite(6 * 6, 4 * 6);
		logo.loadGraphic(Paths.image('menus/pixel/title/logo'));
		logo.setGraphicSize(Std.int(logo.width * 6));
		logo.updateHitbox();
		logo.antialiasing = false;
		add(logo);

		// version
		var version = new FlxSprite(132 * 6, 112 * 6);
		version.loadGraphic(Paths.image('menus/pixel/title/version'));
		version.setGraphicSize(Std.int(version.width * 6));
		version.updateHitbox();
		version.antialiasing = false;
		add(version);

		selector = new FlxSprite(0, (12 * 6)).loadGraphic(Paths.image('menus/pixel/title/selector'));
		selector.setGraphicSize(Std.int(selector.width * 6));
		selector.antialiasing = false;
		add(selector);

		grpMenuShit2 = new FlxTypedGroup<FlxText>();
		add(grpMenuShit2);

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:FlxText = new FlxText(0, (16 * 6 * i) + (62 * 6), 0, menuItems[i], 8);
			songText.scrollFactor.set();
			songText.setFormat(Paths.font("smb1.ttf"), 8);
			songText.setGraphicSize(Std.int(songText.width * 6));
			songText.updateHitbox();

			if (i == 0)
			{
				songText.screenCenter(X);
				songText.x = (Std.int(songText.x / 6) * 6) + (16 * 6);
			}
			else
			{
				songText.x = grpMenuShit.members[0].x;
			}

			var songText2:FlxText = new FlxText(0, (16 * 6 * i) + (68 * 6), 0, menuItems[i], 8);
			songText2.scrollFactor.set();
			songText2.setFormat(Paths.font("smb1.ttf"), 8);
			songText2.setGraphicSize(Std.int(songText2.width * 6));
			songText2.updateHitbox();
			songText2.x = songText.x + 1 * 6;
			songText2.y = songText.y + 1 * 6;
			songText2.color = 0x000000;

			grpMenuShit2.add(songText2);
			grpMenuShit.add(songText);
		}

		changeSelection();
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
		}
		else
		{
			accepted = false;
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];
			var menuItem = grpMenuShit.members[curSelected];
			var menuItemBG = grpMenuShit2.members[curSelected];
			canControl = false;

			switch (daSelected)
			{
				case "STORY MODE":
					FlxG.sound.play(Paths.sound('coin'), 1);
					FlxFlicker.flicker(menuItem, 0.8, 0.05, false);
					FlxFlicker.flicker(menuItemBG, 0.8, 0.05, false);
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

						Main.switchState(this, new PlayState());
					});
				case "FREEPLAY":
					FlxG.sound.play(Paths.sound('stomp'), 1);
					
					FlxFlicker.flicker(menuItem, 0.8, 0.05, false);
					FlxFlicker.flicker(menuItemBG, 0.8, 0.05, false);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						Main.switchState(this, new FreeplayState());
					});
				case "OPTIONS":
					FlxG.sound.play(Paths.sound('stomp'), 1);
					FlxFlicker.flicker(menuItem, 0.8, 0.05, false);
					FlxFlicker.flicker(menuItemBG, 0.8, 0.05, false);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						Main.switchState(this, new OptionsMenuState());
					});
			}
		}
	}
		// colorTest += 0.125;
		// bg.color = FlxColor.fromHSB(colorTest, 100, 100, 0.5);

	// 	var up = controls.UP;
	// 	var down = controls.DOWN;
	// 	var up_p = controls.UP_P;
	// 	var down_p = controls.DOWN_P;
	// 	var controlArray:Array<Bool> = [up, down, up_p, down_p];

	// 	if ((controlArray.contains(true)) && (!selectedSomethin))
	// 	{
	// 		for (i in 0...controlArray.length)
	// 		{
	// 			// here we check which keys are pressed
	// 			if (controlArray[i] == true)
	// 			{
	// 				// if single press
	// 				if (i > 1)
	// 				{
	// 					// up is 2 and down is 3
	// 					// paaaaaiiiiiiinnnnn
	// 					if (i == 2)
	// 						curSelected--;
	// 					else if (i == 3)
	// 						curSelected++;

	// 					FlxG.sound.play(Paths.sound('scrollMenu'));
	// 				}
	// 				/* idk something about it isn't working yet I'll rewrite it later
	// 					else
	// 					{
	// 						// paaaaaaaiiiiiiiinnnn
	// 						var curDir:Int = 0;
	// 						if (i == 0)
	// 							curDir = -1;
	// 						else if (i == 1)
	// 							curDir = 1;

	// 						if (counterControl < 2)
	// 							counterControl += 0.05;

	// 						if (counterControl >= 1)
	// 						{
	// 							curSelected += (curDir * (counterControl / 24));
	// 							if (curSelected % 1 == 0)
	// 								FlxG.sound.play(Paths.sound('scrollMenu'));
	// 						}
	// 				}*/

	// 				if (curSelected < 0)
	// 					curSelected = optionShit.length - 1;
	// 				else if (curSelected >= optionShit.length)
	// 					curSelected = 0;
	// 			}
	// 			//
	// 		}
	// 	}
	// 	else
	// 	{
	// 		// reset variables
	// 		counterControl = 0;
	// 	}

	// 	if ((controls.ACCEPT) && (!selectedSomethin))
	// 	{
	// 		//
	// 		selectedSomethin = true;
	// 		FlxG.sound.play(Paths.sound('confirmMenu'));

	// 		FlxFlicker.flicker(magenta, 0.8, 0.1, false);

	// 		menuItems.forEach(function(spr:FlxSprite)
	// 		{
	// 			if (curSelected != spr.ID)
	// 			{
	// 				FlxTween.tween(spr, {alpha: 0, x: FlxG.width * 2}, 0.4, {
	// 					ease: FlxEase.quadOut,
	// 					onComplete: function(twn:FlxTween)
	// 					{
	// 						spr.kill();
	// 					}
	// 				});
	// 			}
	// 			else
	// 			{
	// 				FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
	// 				{
	// 					var daChoice:String = optionShit[Math.floor(curSelected)];

	// 					switch (daChoice)
	// 					{
	// 						case 'story mode':
	// 							Main.switchState(this, new StoryMenuState());
	// 						case 'freeplay':
	// 							Main.switchState(this, new FreeplayState());
	// 						case 'options':
	// 							transIn = FlxTransitionableState.defaultTransIn;
	// 							transOut = FlxTransitionableState.defaultTransOut;
	// 							Main.switchState(this, new OptionsMenuState());
	// 					}
	// 				});
	// 			}
	// 		});
	// 	}

	// 	if (Math.floor(curSelected) != lastCurSelected)
	// 		updateSelection();

	// 	super.update(elapsed);

	// 	menuItems.forEach(function(menuItem:FlxSprite)
	// 	{
	// 		menuItem.screenCenter(X);
	// 	});
	// }

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
			// item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (bullShit == curSelected)
			{
				// item.alpha = 1;
				selector.x = item.x - (16 * 6);
				selector.y = item.y;

				selector.x += (6 * 6);
				selector.y += (7 * 6);

				selector.x += 2;
				selector.y += 2;
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
