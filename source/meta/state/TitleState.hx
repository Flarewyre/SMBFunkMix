package meta.state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
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
	I hate this state so much that I gave up after trying to rewrite it 3 times and just copy pasted the original code
	with like minor edits so it actually runs in forever engine. I'll redo this later, I've said that like 12 times now

	I genuinely fucking hate this code no offense ninjamuffin I just dont like it and I don't know why or how I should rewrite it
**/
class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var disclaimer:FlxSprite;
	var disclaimerTime:Float = 5.0;

	var nextFlash:Float = 0.75;

	override public function create():Void
	{
		controls.setKeyboardScheme(None, false);
		super.create();

		disclaimer = new FlxSprite().loadGraphic(Paths.image('menus/pixel/intro/disclaimer'));
		disclaimer.setGraphicSize(Std.int(disclaimer.width * 6));
		disclaimer.updateHitbox();
		disclaimer.antialiasing = false;
		add(disclaimer);

		if (initialized)
		{
			disclaimerTime = 0;
			startIntro();
		}
	}

	var logo:FlxSprite;
	var deluxe:FlxSprite;
	var sparkle:FlxSprite;
	var titleText:FlxSprite;
	var bg:FlxSprite;
	var bg2:FlxSprite;
	var bgPos:FlxPoint;

	var velocity:Float;
	var logoY:Float;
	var bounces:Int = -1;
	var sparkleTime:Float = 7.3;

	function startIntro()
	{
		if (!initialized)
		{
			///*
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
			// */
		}

		#if !html5
		Discord.changePresence('TITLE SCREEN', 'Main Menu');
		#end

		ForeverTools.playTitleMusic();

		persistentUpdate = true;

		disclaimer.visible = false;

		bg = new FlxSprite().loadGraphic(Paths.image('menus/pixel/intro/bg'));
		bg.setGraphicSize(Std.int(bg.width * 6));
		bg.updateHitbox();
		bg.antialiasing = false;
		add(bg);

		bg2 = new FlxSprite().loadGraphic(Paths.image('menus/pixel/intro/bg'));
		bg2.setGraphicSize(Std.int(bg2.width * 6));
		bg2.updateHitbox();
		bg2.antialiasing = false;
		add(bg2);

		bgPos = new FlxPoint();

		var infoText:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/pixel/intro/spare-me-ninjas'));
		infoText.setGraphicSize(Std.int(infoText.width * 6));
		infoText.updateHitbox();
		infoText.antialiasing = false;
		add(infoText);

		titleText = new FlxSprite().loadGraphic(Paths.image('menus/pixel/intro/title-text'));
		titleText.setGraphicSize(Std.int(titleText.width * 6));
		titleText.updateHitbox();
		titleText.antialiasing = false;
		titleText.alpha = 0;
		titleText.visible = false;
		add(titleText);

		logo = new FlxSprite(14 * 6, 7 * 6);
		logo.frames = Paths.getPackerAtlasJson('menus/pixel/intro/logo');
		logo.animation.addByPrefix('flash', 'flash', 18, true);
		logo.animation.addByPrefix('idle', 'idle', 24, true);

		//logo.animation.add("flash", [0, 1, 2, 1], 18);
		logo.setGraphicSize(Std.int(logo.width * 6));
		logo.updateHitbox();
		logo.antialiasing = false;
		add(logo);

		logoY = -76;
		bounces = 6;

		deluxe = new FlxSprite(74 * 6, 44 * 6).loadGraphic(Paths.image('menus/pixel/intro/deluxe'), true, 80, 28);
		deluxe.animation.add('write', [0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 14, false);

		deluxe.setGraphicSize(Std.int(deluxe.width * 6));
		deluxe.updateHitbox();
		deluxe.antialiasing = false;
		add(deluxe);

		sparkle = new FlxSprite(91 * 6, 31 * 6).loadGraphic(Paths.image('menus/pixel/intro/sparkle'), true, 16, 24);
		sparkle.animation.add('sparkle', [1, 2, 3, 4, 5, 6, 7, 8, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 16, true);

		sparkle.setGraphicSize(Std.int(sparkle.width * 6));
		sparkle.updateHitbox();
		sparkle.antialiasing = false;
		add(sparkle);

		initialized = true;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (bounces > -1)
		{
			logo.y = Std.int(logoY) * 6;

			velocity += 300 * elapsed;
			logoY += velocity * elapsed;
			if (logoY > 7)
			{
				velocity = -15 * bounces;
				logoY = 6;
				bounces -= 1;
				if (bounces < 0)
				{
					logo.y = 7 * 6;
					deluxe.animation.play('write');
				}
			}
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && initialized)
		{
			bounces = -1;
			logo.y = 7 * 6;
			logo.animation.play('flash');
			deluxe.animation.play('write');
			deluxe.animation.curAnim.frameRate = 9999;
			titleText.visible = false;

			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound('title_confirm'), 0.45);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Check if version is outdated

				var version:String = "v" + Application.current.meta.get('version');
				/*
					if (version.trim() != NGio.GAME_VER_NUMS.trim() && !OutdatedSubState.leftState)
					{
						FlxG.switchState(new OutdatedSubState());
						trace('OLD VERSION!');
						trace('old ver');
						trace(version.trim());
						trace('cur ver');
						trace(NGio.GAME_VER_NUMS.trim());
					}
					else
					{ */
				Main.switchState(this, new MainMenuState());
				// }
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (disclaimerTime > 0)
		{
			disclaimerTime -= elapsed;
			if (pressedEnter)
			{
				disclaimerTime = 0;
			}

			if (disclaimerTime <= 0)
			{
				disclaimerTime = 0;
				startIntro();
			}
		}

		if (initialized)
		{
			bgPos.x -= 166 * elapsed;
			if (bgPos.x + bg.width <= 0)
			{
				bgPos.x = 0;
			}
			bg.x = Std.int(bgPos.x / 6) * 6;
			bg2.x = bg.x + bg.width;

			if (!transitioning)
			{
				nextFlash -= elapsed;
				if (nextFlash < 0)
				{
					nextFlash = 0.75;
					titleText.visible = !titleText.visible;
				}
			}

			if (sparkleTime > 0)
			{
				sparkleTime -= elapsed;
				if (sparkleTime <= 0)
				{
					sparkleTime = 0;
					sparkle.animation.play('sparkle');
					if (!transitioning)
					{
						logo.animation.play('idle');
					}
				}
			}
		}

		super.update(elapsed);
	}
}
