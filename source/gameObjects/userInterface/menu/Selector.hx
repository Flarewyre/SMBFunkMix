package gameObjects.userInterface.menu;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import meta.data.dependency.FNFSprite;
import meta.data.font.Alphabet;

class Selector extends FlxTypedSpriteGroup<FlxSprite>
{
	//
	var leftSelector:FNFSprite;
	var rightSelector:FNFSprite;

	public var optionChosen:FlxText;
	public var chosenOptionString:String = '';
	public var options:Array<String>;

	public var fpsCap:Bool = false;
	public var darkBG:Bool = false;

	public function new(x:Float = 0, y:Float = 0, word:String, options:Array<String>, fpsCap:Bool = false, darkBG:Bool = false)
	{
		// call back the function
		super(x, y);

		this.options = options;
		trace(options);

		// oops magic numbers
		var shiftX = 3;
		var shiftY = 3;
		// generate multiple pieces

		this.fpsCap = fpsCap;
		this.darkBG = darkBG;

		leftSelector = createSelector(shiftX, shiftY, word, 'left');
		rightSelector = createSelector(shiftX + (22 * 4 * 6), shiftY, word, 'right');
		rightSelector.flipX = true;

		add(leftSelector);
		add(rightSelector);

		chosenOptionString = Std.string(Init.trueSettings.get(word));
		if (chosenOptionString.length <= 2)
			chosenOptionString = "0" + chosenOptionString;
		optionChosen = new FlxText(shiftX + (17 * 4 * 6), shiftY - (5 * 6) - 3, 0, chosenOptionString);

		optionChosen.setFormat(Paths.font("pixel_small.ttf"), 5);
		optionChosen.setGraphicSize(Std.int(optionChosen.width * 6));
		optionChosen.updateHitbox();

		add(optionChosen);
	}

	public function createSelector(objectX:Float = 0, objectY:Float = 0, word:String, dir:String):FNFSprite
	{
		var returnSelector = new FNFSprite(objectX, objectY).loadGraphic(Paths.image("menus/pixel/options/arrows"), true, 6, 6);

		returnSelector.animation.add('idle', [0], 24, false);
		returnSelector.animation.add('press', [1], 24, false);
		//returnSelector.addOffset('press', 0, -10);
		returnSelector.playAnim('idle');

		returnSelector.antialiasing = false;
		returnSelector.setGraphicSize(Std.int(6 * 6));
		returnSelector.updateHitbox();

		return returnSelector;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		for (object in 0...objectArray.length)
			objectArray[object].setPosition(x + positionLog[object][0], y + positionLog[object][1]);
	}

	public function selectorPlay(whichSelector:String, animPlayed:String = 'idle')
	{
		switch (whichSelector)
		{
			case 'left':
				leftSelector.playAnim(animPlayed);
			case 'right':
				rightSelector.playAnim(animPlayed);
		}
	}

	var objectArray:Array<FlxSprite> = [];
	var positionLog:Array<Array<Float>> = [];

	override public function add(object:FlxSprite):FlxSprite
	{
		objectArray.push(object);
		positionLog.push([object.x, object.y]);
		return super.add(object);
	}
}
