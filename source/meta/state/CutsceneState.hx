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
import meta.state.*;
import meta.state.menus.*;
import openfl.Assets;
import haxe.Json;

using StringTools;

// credits to Markl#8443 for a lot of this code
typedef FrameData = {
	public var frameIndex:Int;
	public var duration:Float;
}

typedef FrameArrayOutput = {
	var frames:Array<Int>;
	var fps:Float;
}
//

class CutsceneState extends MusicBeatState
{
	var layer1:FlxSprite;
	var layer2:FlxSprite;
	var layer3:FlxSprite;
	var music:FlxSound;
	var sounds:FlxSound;

	var frameRates = [
		20,
		20,
		24,
		20,
		16,
		20,
		96,
		96
	];

	public static var sceneNum:Int = 0;

	// this function too
	function getFrameIndexesExpanded(allData:Array<Dynamic>)
	{
		var totalDuration = 0;
		for (data in allData)
		{
			totalDuration += data.duration;
		}
		
		var i = 0;
		var output:FrameArrayOutput = {frames: [], fps: frameRates[sceneNum]};
		for (data in allData)
		{
			if (sceneNum < 6)
			{
				var percentOfFullDuration = Std.int((data.duration / totalDuration) * 100) + 1;
				for(j in 0...percentOfFullDuration)
				{
					output.frames.push(i);
				}
				i += 1;
			}
			else
			{
				for(j in 0...Std.int(data.duration / 12.5))
				{
					output.frames.push(i);
				}
				i += 1;
			}
		}
		return output;
	}
	//

	override public function create():Void
	{
		super.create();

		startCutscene();
	}

	function startCutscene()
	{
		if (sceneNum == 7)
		{
			cloudsPos = new FlxPoint();

			cloudsBottom = new FlxSprite(0, 97 * 6).loadGraphic(Paths.image('backgrounds/airship/bg-bottom'));
			cloudsBottom.scrollFactor.set(1, 1);
			cloudsBottom.antialiasing = false;
			cloudsBottom.setGraphicSize(Std.int(cloudsBottom.width * 6));
			cloudsBottom.updateHitbox();
			add(cloudsBottom);

			clouds = new FlxSprite(0, 16 * 6).loadGraphic(Paths.image('backgrounds/airship/bg'));
			clouds.scrollFactor.set(1, 1);
			clouds.antialiasing = false;
			clouds.setGraphicSize(Std.int(clouds.width * 6));
			clouds.updateHitbox();
			add(clouds);

			clouds2 = new FlxSprite(0, 16 * 6).loadGraphic(Paths.image('backgrounds/airship/bg'));
			clouds2.scrollFactor.set(1, 1);
			clouds2.antialiasing = false;
			clouds2.setGraphicSize(Std.int(clouds2.width * 6));
			clouds2.updateHitbox();
			add(clouds2);
		}

		var layer1Json = Paths.file('images/cutscene/' + sceneNum + '/layer1.json');
		var layer1Data = haxe.Json.parse(sys.io.File.getContent(layer1Json));

		var layer1FramesData = getFrameIndexesExpanded(layer1Data.frames);
		layer1 = new FlxSprite();
		layer1.frames = Paths.getPackerAtlasJson('cutscene/' + sceneNum + '/layer1');
		layer1.animation.add('cutscene', layer1FramesData.frames, layer1FramesData.fps, false);
		layer1.animation.play('cutscene');

		layer1.antialiasing = false;
		layer1.setGraphicSize(Std.int(layer1.width * 6));
		layer1.updateHitbox();
		add(layer1);
		
		var layer2Json = Paths.file('images/cutscene/' + sceneNum + '/layer2.json');
		var layer2Data = haxe.Json.parse(sys.io.File.getContent(layer2Json));

		var layer2FramesData = getFrameIndexesExpanded(layer2Data.frames);
		layer2 = new FlxSprite();
		layer2.frames = Paths.getPackerAtlasJson('cutscene/' + sceneNum + '/layer2');
		layer2.animation.add('cutscene', layer2FramesData.frames, layer2FramesData.fps, false);
		layer2.animation.play('cutscene');

		layer2.antialiasing = false;
		layer2.setGraphicSize(Std.int(layer2.width * 6));
		layer2.updateHitbox();
		add(layer2);

		if (sceneNum == 2)
		{
			for (i in 0...6)
			{
				var fireball:FlxSprite = new FlxSprite(fireballCenterX * 6, (fireballCenterY - (i * 8)) * 6).loadGraphic(Paths.image('backgrounds/castle/fireball'), true, 8, 8);
				fireball.animation.add("idle", [0, 1, 2, 3], 18);
				fireball.animation.play("idle");

				fireball.scrollFactor.set(1, 1);
				fireball.antialiasing = false;
				fireball.setGraphicSize(Std.int(fireball.width * 6));
				fireball.updateHitbox();
				add(fireball);
				fireballs.push(fireball);
			}
		}

		var layer3Json = Paths.file('images/cutscene/' + sceneNum + '/layer3.json');
		var layer3Data = haxe.Json.parse(sys.io.File.getContent(layer3Json));

		var layer3FramesData = getFrameIndexesExpanded(layer3Data.frames);
		layer3 = new FlxSprite();
		layer3.frames = Paths.getPackerAtlasJson('cutscene/' + sceneNum + '/layer3');
		layer3.animation.add('cutscene', layer3FramesData.frames, layer3FramesData.fps, false);
		layer3.animation.play('cutscene');

		layer3.antialiasing = false;
		layer3.setGraphicSize(Std.int(layer3.width * 6));
		layer3.updateHitbox();
		add(layer3);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		music = new FlxSound().loadEmbedded(Paths.file('images/cutscene/' + sceneNum + '/music.ogg'), false, true);
		music.volume = 0.5;
		FlxG.sound.list.add(music);
		music.play();

		sounds = new FlxSound().loadEmbedded(Paths.file('images/cutscene/' + sceneNum + '/sounds.ogg'), false, true);
		sounds.volume = 1;
		FlxG.sound.list.add(sounds);
		sounds.play();
	}

	var cloudsBottom:FlxSprite;
	var clouds:FlxSprite;
	var clouds2:FlxSprite;
	var cloudsPos:FlxPoint;

	var fireballs:Array<FlxSprite> = [];
	var fireballCenterX:Float = 77;
	var fireballCenterY:Float = 65;
	var fireballAngle:Float = 180;

	override function update(elapsed:Float)
	{
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

		if (pressedEnter || layer2.animation.finished)
		{
			if (!pressedEnter && sceneNum == 5)
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					loadSong();
				});
			}
			if (!pressedEnter && sceneNum == 7)
			{
				cloudsBottom.visible = false;
				clouds.visible = false;
				clouds2.visible = false;
				layer1.visible = false;
				layer2.visible = false;
				layer3.visible = false;
				music.stop();
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					Main.switchState(this, new EpilogueState());
				});
			}
			else
			{
				if (sceneNum == 6)
					Main.switchState(this, new MainMenuState());
				else if (sceneNum == 7)
					Main.switchState(this, new EpilogueState());
				else
					loadSong();
			}
		}

		if (sceneNum == 2)
		{
			fireballAngle -= elapsed * 75;
			if (fireballAngle < 0)
				fireballAngle = 360;

			var angleRadians = (Std.int(-fireballAngle / 7.5) * 7.5) * Math.PI/180;
			var i = 0;
			for (fireball in fireballs)
			{
				fireball.x = fireballCenterX * 6;
				fireball.y = fireballCenterY * 6;

				fireball.x += Math.cos(angleRadians) * i * 8 * 6;
				fireball.y += Math.sin(angleRadians) * i * 8 * 6;
				
				fireball.x = Std.int(fireball.x / 6) * 6;
				fireball.y = Std.int(fireball.y / 6) * 6;
				i += 1;
			}
		}

		if (sceneNum == 7)
		{
			cloudsPos.x -= 96 * elapsed;
			if (cloudsPos.x + clouds.width <= 0)
			{
				cloudsPos.x = 0;
			}
			clouds.x = Std.int(cloudsPos.x / 6) * 6;
			clouds2.x = clouds.x + clouds.width;
		}

		super.update(elapsed);
	}

	function loadSong():Void
	{
		Main.switchState(this, new PlayState());
	}
}
