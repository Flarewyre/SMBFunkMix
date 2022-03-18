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

class EpilogueState extends MusicBeatState
{
	
	var music:FlxSound;
	override public function create():Void
	{
		super.create();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		music = new FlxSound().loadEmbedded(Paths.file('images/menus/pixel/epilogue/music.ogg'), false, true);
		music.volume = 0.7;
		FlxG.sound.list.add(music);
		music.play();

		var image = new FlxSprite();
		image.loadGraphic(Paths.image('menus/pixel/epilogue/epilogue'));
		image.setGraphicSize(Std.int(image.width * 6));
		image.updateHitbox();
		add(image);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

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
			Main.switchState(this, new MainMenuState());
		}
	}
}
