package meta.subState;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.Boyfriend;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.Conductor.BPMChangeEvent;
import meta.data.Conductor;
import meta.state.*;
import meta.state.menus.*;

class GameOverSubstate extends MusicBeatSubState
{
	//
	var bf:FlxSprite;
	var bf2:FlxSprite;
	var camFollow:FlxObject;
	var stageSuffix:String = "-pixel";
	var velocity:Float = 0;
	var yPosition:Float = 0;
	var timeUntilStart:Float = 0.4;
	var timeUntilReset:Float = 3;

	public function new(x:Float, y:Float)
	{
		var daBoyfriendType = PlayState.bfPrefix;
		var daBf:String = '';
		switch (daBoyfriendType)
		{
			case 'luigi-player':
				daBf = 'luigi-dead';
				x += 3 * 6;
				x -= 3;
			case 'mario-ccc':
				daBf = 'mario-dead';
				x += 3 * 6;
				y += 16 * 6;
				x -= 3;

			case 'bf-portal':
				daBf = 'bf-portal-dead';
				x -= 2;
			case 'bf-smm':
				daBf = 'bf-smm-dead';
				x -= 2;
			default:
				daBf = 'bf-dead';
				x -= 2;
		}

		PlayState.boyfriend.visible = false;

		super();

		Conductor.songPosition = 0;

		if (PlayState.isSMM)
		{
			bf2 = new FlxSprite(x + (2 * 6), y).loadGraphic(Paths.image('characters/' + daBf));
			bf2.setGraphicSize(Std.int(bf2.width * 6));
			bf2.antialiasing = false;
			bf2.cameras = [PlayState.strumHUD[PlayState.strumHUD.length - 1]];

			bf2.color = FlxColor.BLACK;
			bf2.alpha = 0.36;
			add(bf2);
		}

		bf = new FlxSprite(x, y).loadGraphic(Paths.image('characters/' + daBf));
		bf.setGraphicSize(Std.int(bf.width * 6));
		bf.antialiasing = false;
		bf.cameras = [PlayState.strumHUD[PlayState.strumHUD.length - 1]];
		add(bf);

		yPosition = bf.y;

		FlxG.sound.play(Paths.sound('death'));
		Conductor.changeBPM(100);
		
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		// FlxG.camera.scroll.set();
		// FlxG.camera.target = null;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
			endBullshit();
		
		if (controls.BACK)
		{
			PlayState.blackBox.visible = true;
			close();
			Main.switchState(this, new MainMenuState());
		}

		timeUntilReset -= elapsed;
		if (timeUntilReset <= 0)
			endBullshit();

		if (timeUntilStart > 0)
		{
			timeUntilStart -= elapsed;
			if (timeUntilStart <= 0)
			{
				timeUntilStart = 0;
				velocity = -750;
			}
		}
		else
		{
			velocity += (12.5 * 130 * elapsed);
		}
		
		yPosition += velocity * elapsed;
		bf.y = Std.int(yPosition / 6) * 6;

		if (PlayState.isSMM)
			bf2.y = bf.y + (2 * 6);
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			//bf.playAnim('deathConfirm', true);
			// FlxG.sound.music.stop();
			// FlxG.sound.destroy();
			PlayState.blackBox.visible = true;
			close();
			Main.switchState(this, new PlayState());
			//
		}
	}
}
