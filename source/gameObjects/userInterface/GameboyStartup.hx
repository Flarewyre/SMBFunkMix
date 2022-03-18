package gameObjects.userInterface;

import flixel.math.FlxPoint;
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flash.display.Bitmap;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import meta.data.*;
import meta.state.PlayState;

class GameboyStartup extends FlxState
{
    var oldScreen:FlxSprite;
    var logo:FlxSprite;
    var logoPos:FlxPoint;

    override public function new(screenCapBitmap:Bitmap):Void
    {
        super();

        oldScreen = new FlxSprite();
        oldScreen.loadGraphic(screenCapBitmap.bitmapData);
        add(oldScreen);
    }

    override public function create():Void
    {
        super.create();

        if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

        FlxG.sound.play(Paths.sound('gameboy_off'));
        
        FlxTween.tween(oldScreen, { alpha: 0 }, 0.1);
        new FlxTimer().start(2.0, turnOn, 1);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (logo != null)
        {
            logo.y = Std.int(logoPos.y / 6) * 6;
        }
    }

    function turnOn(timer:FlxTimer):Void {
        FlxG.sound.play(Paths.sound('gameboy_on'));

        var bg = new FlxSprite();
		bg.makeGraphic(1280, 1280, 0xFF9bbc0f);
		add(bg);

        logoPos = new FlxPoint();

        logo = new FlxSprite(0, 0);
		logo.loadGraphic(Paths.image('cutscene/gameboy/logo'));
		logo.setGraphicSize(Std.int(logo.width * 6));
		logo.updateHitbox();
		logo.antialiasing = false;
        logo.screenCenter();
		add(logo);

        logoPos.y = logo.y;

        var centerY = logoPos.y;
        logoPos.y = -40;
        FlxTween.tween(logoPos, { y: centerY }, 1.95, {onComplete: tweenFinished});
    }
    
    function tweenFinished(tween):Void {
        FlxG.sound.play(Paths.sound('gameboy_startup'));

        new FlxTimer().start(2.0, gotoEasterEgg, 1);
    }

    function gotoEasterEgg(timer:FlxTimer):Void {
		var songName = "Green-Screen";
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
}
