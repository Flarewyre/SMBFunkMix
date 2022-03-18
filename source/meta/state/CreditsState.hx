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
import flixel.math.FlxMath;
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
import haxe.Json;

using StringTools;

class CreditsState extends MusicBeatState
{
	var image1:FlxSprite;
	var image2:FlxSprite;
	var screenHeight:Int = 120 * 6;
	var screenCount:Int = 17;
	var curScreen:Int = 0;

	var nextImage:Float;
	var switchScreen:Bool;
	var yPos:Float;

	var music:FlxSound;
	override public function create():Void
	{
		super.create();

		nextImage = 6;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		music = new FlxSound().loadEmbedded(Paths.file('images/menus/pixel/credits/dx-credits.ogg'), false, true);
		music.volume = 0.9;
		FlxG.sound.list.add(music);
		music.play();

		image1 = new FlxSprite();
		image1.loadGraphic(Paths.image('menus/pixel/credits/screens/0'));
		image1.setGraphicSize(Std.int(image1.width * 6));
		image1.updateHitbox();
		add(image1);

		image2 = new FlxSprite(0, screenHeight);
		image2.loadGraphic(Paths.image('menus/pixel/credits/screens/0'));
		image2.setGraphicSize(Std.int(image2.width * 6));
		image2.updateHitbox();
		add(image2);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		nextImage -= elapsed;
		if (nextImage <= 0 && curScreen != 17)
		{
			
			var imageName = Std.string(curScreen + 1);
			if (curScreen + 1 == 15)
			{
				var saveData = Highscore.getData("Green-Screen");
				if (saveData[0] != 0)
					imageName += '-alt';
			}

			nextImage = 5.125;
			image2 = new FlxSprite(0, screenHeight);
			image2.loadGraphic(Paths.image('menus/pixel/credits/screens/' + imageName));
			image2.setGraphicSize(Std.int(image2.width * 6));
			image2.updateHitbox();
			add(image2);

			switchScreen = true;
			curScreen++;
		}

		if (switchScreen)
		{
			yPos -= 500 * elapsed;
			if (yPos < -screenHeight)
			{
				yPos = 0;
				switchScreen = false;

				var imageName = Std.string(curScreen);
				if (curScreen == 15)
				{
					var saveData = Highscore.getData("Green-Screen");
					if (saveData[0] != 0)
						imageName += '-alt';
				}

				image1 = new FlxSprite(0, screenHeight);
				image1.loadGraphic(Paths.image('menus/pixel/credits/screens/' + imageName));
				image1.setGraphicSize(Std.int(image1.width * 6));
				image1.updateHitbox();
				add(image1);
			}

			image1.y = Std.int(yPos / 6) * 6;
			image2.y = image1.y + screenHeight;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

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

		if (pressedEnter)
		{
			image1.visible = false;
			image2.visible = false;
			Main.switchState(this, new MainMenuState());
		}
	}
}
