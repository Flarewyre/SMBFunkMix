package meta.data.dependency;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.Transition;
import flixel.addons.transition.TransitionData;
import flixel.util.FlxColor;

/**
 *
 * Transition overrides
 * @author HelloSammu
 *
**/
class FNFTransition extends Transition
{
	var back:FlxSprite;
	var camStarted:Bool = false;

	public override function new(data:TransitionData)
	{
		// Inherit from super
		super(data);

		// Take note of background fade
		back = _effect.members[0];
		back.visible = false;

		var bg:FlxSprite = new FlxSprite(0, FlxG.height).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 1;
		add(bg);
	}

	public override function update(gameTime:Float)
	{
		// Since the transition can start before other cameras are made, we need to make it after the start!
		if (!camStarted)
		{
			var camList = FlxG.cameras.list;
			camera = camList[camList.length - 1];
			back.camera = camera;
		}

		super.update(gameTime * 5000); // lol shitty fix
	}
}
