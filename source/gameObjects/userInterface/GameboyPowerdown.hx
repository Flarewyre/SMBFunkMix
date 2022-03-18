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
import meta.state.*;

class GameboyPowerdown extends FlxState
{
    var oldScreen:FlxSprite;
    override public function new(screenCapBitmap:Bitmap):Void
    {
        super();

        oldScreen = new FlxSprite();
        oldScreen.loadGraphic(screenCapBitmap.bitmapData);
        oldScreen.replaceColor(FlxColor.WHITE, 0x0F380F);
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

    function turnOn(timer:FlxTimer):Void {
        Main.switchState(this, new TitleState());
    }
}
