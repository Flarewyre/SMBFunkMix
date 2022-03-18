package meta.subState;

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
import flixel.util.FlxTimer;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.font.Alphabet;
import meta.state.*;
import meta.state.menus.*;
import gameObjects.userInterface.GameboyPowerdown;
import flixel.addons.plugin.screengrab.FlxScreenGrab;

class GameboyPauseSubState extends MusicBeatSubState
{
	var grpMenuShit:FlxTypedGroup<FlxText>;

	var selector:FlxSprite;

	var menuItems:Array<String> = ['CONTINUE', 'RETRY', 'END'];
	var menuPositioning:Array<Dynamic> = [];
	var curSelected:Int = 0;

	var transitionType = 1;
	var canControl:Bool = false;

	var bg:FlxSprite;
	var bgPos:Float;

	public function new(x:Float, y:Float)
	{
		super();
		#if debug
		// trace('pause call');
		#end

		#if debug
		// trace('pause background');
		#end

		var isMinus = PlayState.SONG.song == 'Wrong-Warp';
		var pausePath = 'menus/pixel/pause/gameboy/PAUSE';
		var marioPath = 'menus/pixel/pause/gameboy/walking';
		var barPath = 'menus/pixel/pause/gameboy/progressbar';

		bg = new FlxSprite(0, 0);
		bg.loadGraphic(Paths.image('menus/pixel/pause/gameboy/bg'));
		bg.setGraphicSize(Std.int(bg.width * 6));
		bg.updateHitbox();
		bg.antialiasing = false;
		bg.alpha = 1;
		bg.scrollFactor.set();
		add(bg);
		bgPos = FlxG.height;

		var songDetails = CoolUtil.dashToSpace(PlayState.SONG.song);
		var levelInfo:FlxText = new FlxText(0, (28 * 6), 0, "", 8);
		levelInfo.text += songDetails;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("smb1.ttf"), 8, 0x9BBC0F);
		levelInfo.setGraphicSize(Std.int(levelInfo.width * 6));
		levelInfo.updateHitbox();
		add(levelInfo);

		var pauseText:FlxSprite = new FlxSprite(0, (12 * 6)).loadGraphic(Paths.image(pausePath));
		pauseText.setGraphicSize(Std.int(pauseText.width * 6));
		pauseText.antialiasing = false;
		add(pauseText);

		var progressBar:FlxSprite = new FlxSprite(0, (60 * 6)).loadGraphic(Paths.image(barPath));
		progressBar.setGraphicSize(Std.int(progressBar.width * 6));
		progressBar.antialiasing = false;
		add(progressBar);

		var mario:FlxSprite = new FlxSprite(0, (56 * 6)).loadGraphic(Paths.image(marioPath), true, 16, 16);
		mario.animation.add("walk", [0, 0, 1, 2], 9, true);
		mario.animation.play("walk");

		mario.setGraphicSize(Std.int(mario.width * 6));
		mario.antialiasing = false;
		add(mario);

		selector = new FlxSprite(0, (12 * 6)).loadGraphic(Paths.image('menus/pixel/pause/gameboy/selector'));
		selector.setGraphicSize(Std.int(selector.width * 6));
		selector.antialiasing = false;
		add(selector);

		levelInfo.screenCenter(X);
		levelInfo.x = Std.int(levelInfo.x / 6) * 6;

		pauseText.screenCenter(X);
		pauseText.x = Std.int(pauseText.x / 6) * 6;

		progressBar.screenCenter(X);
		progressBar.x = Std.int(progressBar.x / 6) * 6;

		mario.x = progressBar.x - (25 * 6);
		mario.y = progressBar.y - (8 * 6);

		mario.x -= 2;
		mario.y += 2;

		var songProgress:Float = PlayState.songMusic.time / PlayState.songMusic.length;
		mario.x += Std.int(songProgress * 64) * 6;
		trace(songProgress);

		menuPositioning.push([levelInfo, levelInfo.y]);
		menuPositioning.push([pauseText, pauseText.y]);
		menuPositioning.push([progressBar, progressBar.y]);
		menuPositioning.push([mario, mario.y]);

		#if debug
		// trace('pause info');
		#end

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:FlxText = new FlxText(0, (16 * 6 * i) + (68 * 6), 0, menuItems[i], 8);
			songText.scrollFactor.set();
			songText.setFormat(Paths.font("smb1.ttf"), 8, 0x9BBC0F);
			songText.setGraphicSize(Std.int(songText.width * 6));
			songText.updateHitbox();

			if (i == 0)
			{
				songText.screenCenter(X);
				songText.x = Std.int(songText.x / 6) * 6;
			}
			else
			{
				songText.x = grpMenuShit.members[0].x;
			}
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
				case "CONTINUE":
					transitionType = -1;
					menuPositioning[menuPositioning.length - 1][1] = selector.y;
					canControl = false;
					FlxG.sound.play(Paths.sound('pause'), 1);
				case "RETRY":
					FlxG.sound.play(Paths.sound('stomp'), 1);
					PlayState.songMusic.stop();
					PlayState.vocals.stop();
					PlayState.blackBox.color = 0x0F380F;
					PlayState.blackBox.visible = true;
					close();

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxG.resetState();
					});
				case "END":
					PlayState.songMusic.stop();
					PlayState.vocals.stop();

					var screenCap = FlxScreenGrab.grab();

					Main.switchState(this, new GameboyPowerdown(screenCap));
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
				selector.x = item.x - (8 * 6);
				selector.y = item.y;

				selector.x += (5 * 6);
				selector.y += (7 * 6);

				selector.x -= 1;
				selector.y -= 1;
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
