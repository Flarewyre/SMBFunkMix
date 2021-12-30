package meta.subState;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.font.Alphabet;

using StringTools;

class OptionsSubstate extends MusicBeatSubState
{
	private var curSelection = 0;
	private var submenuGroup:FlxTypedGroup<FlxBasic>;
	private var submenuoffsetGroup:FlxTypedGroup<FlxBasic>;
	private var submenuOffsetValue:FlxText;

	private var offsetTemp:Float;

	// the controls class thingy
	override public function create():Void
	{
		// background
		var bg = new FlxSprite();
		bg.loadGraphic(Paths.image('menus/pixel/options/bg2'));
		bg.setGraphicSize(Std.int(bg.width * 6));
		bg.updateHitbox();
		bg.antialiasing = false;
		add(bg);

		super.create();

		keyOptions = generateOptions();
		updateSelection();

		submenuGroup = new FlxTypedGroup<FlxBasic>();
		submenuoffsetGroup = new FlxTypedGroup<FlxBasic>();

		submenu = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/pixel/options/submenu'));
		submenu.setGraphicSize(Std.int(submenu.width * 6));
		submenu.updateHitbox();

		submenu.screenCenter();
		submenu.x = Std.int(submenu.x / 6) * 6;
		submenu.y = Std.int(submenu.y / 6) * 6;

		// submenu group
		var submenuText = new FlxText(0, 0, 0, 'Press any key to rebind', 8);
		submenuText.scrollFactor.set();
		submenuText.setFormat(Paths.font("pixel_small.ttf"), 5, FlxColor.WHITE, CENTER);
		submenuText.setGraphicSize(Std.int(submenuText.width * 6));
		submenuText.updateHitbox();

		submenuText.screenCenter();
		submenuText.x = Std.int(submenuText.x / 6) * 6;
		submenuText.y = Std.int(submenuText.y / 6) * 6;
		submenuText.y -= 6 * 6;
		submenuGroup.add(submenuText);

		var submenuText2 = new FlxText(0, 0, 0, 'Escape to cancel', 8);
		submenuText2.scrollFactor.set();
		submenuText2.setFormat(Paths.font("pixel_small.ttf"), 5, FlxColor.WHITE, CENTER);
		submenuText2.setGraphicSize(Std.int(submenuText2.width * 6));
		submenuText2.updateHitbox();

		submenuText2.screenCenter();
		submenuText2.x = Std.int(submenuText.x / 6) * 6;
		submenuText2.y = Std.int(submenuText.y / 6) * 6;
		submenuText2.y += 6 * 6;
		submenuGroup.add(submenuText2);

		// submenuoffset group
		// this code formerly by codist but i edited it LOL
		var submenuOffsetText = new FlxText(0, 0, 0, 'Left or Right to edit', 8);
		submenuOffsetText.scrollFactor.set();
		submenuOffsetText.setFormat(Paths.font("pixel_small.ttf"), 5, FlxColor.WHITE, CENTER);
		submenuOffsetText.setGraphicSize(Std.int(submenuOffsetText.width * 6));
		submenuOffsetText.updateHitbox();

		submenuOffsetText.screenCenter();
		submenuOffsetText.x = Std.int(submenuOffsetText.x / 6) * 6;
		submenuOffsetText.y = Std.int(submenuOffsetText.y / 6) * 6;
		submenuOffsetText.y -= 24 * 6;
		submenuoffsetGroup.add(submenuOffsetText);

		var submenuOffsetText2 = new FlxText(0, 0, 0, 'Negative is Late', 8);
		submenuOffsetText2.scrollFactor.set();
		submenuOffsetText2.setFormat(Paths.font("pixel_small.ttf"), 5, FlxColor.WHITE, CENTER);
		submenuOffsetText2.setGraphicSize(Std.int(submenuOffsetText2.width * 6));
		submenuOffsetText2.updateHitbox();

		submenuOffsetText2.screenCenter();
		submenuOffsetText2.x = Std.int(submenuOffsetText2.x / 6) * 6;
		submenuOffsetText2.y = Std.int(submenuOffsetText2.y / 6) * 6;
		submenuOffsetText2.y -= 13 * 6;
		submenuoffsetGroup.add(submenuOffsetText2);

		var submenuOffsetText3 = new FlxText(0, 0, 0, 'Escape to Cancel', 8);
		submenuOffsetText3.scrollFactor.set();
		submenuOffsetText3.setFormat(Paths.font("pixel_small.ttf"), 5, FlxColor.WHITE, CENTER);
		submenuOffsetText3.setGraphicSize(Std.int(submenuOffsetText3.width * 6));
		submenuOffsetText3.updateHitbox();

		submenuOffsetText3.screenCenter();
		submenuOffsetText3.x = Std.int(submenuOffsetText3.x / 6) * 6;
		submenuOffsetText3.y = Std.int(submenuOffsetText3.y / 6) * 6;
		submenuOffsetText3.y += 17 * 6;
		submenuoffsetGroup.add(submenuOffsetText3);

		var submenuOffsetText4 = new FlxText(0, 0, 0, 'Enter to Save', 8);
		submenuOffsetText4.scrollFactor.set();
		submenuOffsetText4.setFormat(Paths.font("pixel_small.ttf"), 5, FlxColor.WHITE, CENTER);
		submenuOffsetText4.setGraphicSize(Std.int(submenuOffsetText4.width * 6));
		submenuOffsetText4.updateHitbox();

		submenuOffsetText4.screenCenter();
		submenuOffsetText4.x = Std.int(submenuOffsetText4.x / 6) * 6;
		submenuOffsetText4.y = Std.int(submenuOffsetText4.y / 6) * 6;
		submenuOffsetText4.y += 27 * 6;
		submenuoffsetGroup.add(submenuOffsetText4);

		submenuOffsetValue = new FlxText(0, 0, 0, "< 0ms >", 8, false);
		submenuOffsetValue.setFormat(Paths.font("smb1.ttf"), 8, 0xE69C21, CENTER);
		submenuOffsetValue.setGraphicSize(Std.int(submenuOffsetValue.width * 6));
		submenuOffsetValue.updateHitbox();

		submenuOffsetValue.screenCenter();
		submenuOffsetValue.x = Std.int(submenuOffsetValue.x / 6) * 6;
		submenuOffsetValue.y = Std.int(submenuOffsetValue.y / 6) * 6;
		submenuoffsetGroup.add(submenuOffsetValue);

		// alright back to my code :ebic:

		add(submenu);
		add(submenuGroup);
		add(submenuoffsetGroup);
		submenu.visible = false;
		submenuGroup.visible = false;
		submenuoffsetGroup.visible = false;
	}

	private var keyOptions:FlxTypedGroup<FlxText>;
	private var otherKeys:FlxTypedGroup<FlxText>;

	private function generateOptions()
	{
		keyOptions = new FlxTypedGroup<FlxText>();

		var arrayTemp:Array<String> = [];
		// re-sort everything according to the list numbers
		for (controlString in Init.gameControls.keys())
			arrayTemp[Init.gameControls.get(controlString)[1]] = controlString;

		arrayTemp.push("EDIT OFFSET"); // append edit offset to the end of the array

		for (i in 0...arrayTemp.length)
		{
			// generate key options lol
			var optionsText:FlxText = new FlxText(16 * 6, 24 * 6, 0, arrayTemp[i], 8);
			optionsText.y += (8 * i) * 6;

			optionsText.setFormat(Paths.font("pixel_small.ttf"), 5, FlxColor.WHITE, LEFT);
			optionsText.setGraphicSize(Std.int(optionsText.width * 6));
			optionsText.updateHitbox();
			optionsText.color = 0xE69C21;

			keyOptions.add(optionsText);
		}

		// stupid shubs you always forget this
		add(keyOptions);

		generateExtra(arrayTemp);

		return keyOptions;
	}

	private function generateExtra(arrayTemp:Array<String>)
	{
		otherKeys = new FlxTypedGroup<FlxText>();
		for (i in 0...arrayTemp.length)
		{
			for (j in 0...2)
			{
				var keyString = "";

				if (arrayTemp[i] != "EDIT OFFSET")
					keyString = getStringKey(Init.gameControls.get(arrayTemp[i])[0][j]);

				var secondaryText:FlxText = new FlxText(64 * 6, 24 * 6, 0, keyString, 8);
				secondaryText.x += (48 * j) * 6;
				secondaryText.y += (8 * i) * 6;

				secondaryText.setFormat(Paths.font("pixel_small.ttf"), 5, FlxColor.WHITE, LEFT);
				secondaryText.setGraphicSize(Std.int(secondaryText.width * 6));
				secondaryText.updateHitbox();
				secondaryText.color = 0xE69C21;

				// secondaryText.controlGroupID = i;
				// secondaryText.extensionJ = j;
				otherKeys.add(secondaryText);
			}
		}
		add(otherKeys);
	}

	private function getStringKey(arrayThingy:Dynamic):String
	{
		var keyString:String = 'none';
		if (arrayThingy != null)
		{
			var keyDisplay:FlxKey = arrayThingy;
			keyString = keyDisplay.toString();
		}

		keyString = keyString.replace(" ", "");

		return keyString;
	}

	private function updateSelection(equal:Int = 0)
	{
		if (equal != curSelection)
			FlxG.sound.play(Paths.sound('menu_select'), 1);

		curSelection = equal;
		// wrap the current selection
		if (curSelection < 0)
			curSelection = keyOptions.length - 1;
		else if (curSelection >= keyOptions.length)
			curSelection = 0;

		//
		for (i in 0...keyOptions.length)
		{
			keyOptions.members[i].color = 0xE69C21;
			//keyOptions.members[i].targetY = (i - curSelection) / 2;
		}
		keyOptions.members[curSelection].color = 0xFFFFFF;

		///*
		for (i in 0...otherKeys.length)
		{
			otherKeys.members[i].color = 0xE69C21;
			//otherKeys.members[i].targetY = (((Math.floor(i / 2)) - curSelection) / 2) - 0.25;
		}
		otherKeys.members[(curSelection * 2) + curHorizontalSelection].color = 0xFFFFFF;
		// */
	}

	private var curHorizontalSelection = 0;

	private function updateHorizontalSelection()
	{
		var left = controls.LEFT_P;
		var right = controls.RIGHT_P;
		var horizontalControl:Array<Bool> = [left, false, right];

		if (horizontalControl.contains(true))
		{
			for (i in 0...horizontalControl.length)
			{
				if (horizontalControl[i] == true)
				{
					curHorizontalSelection += (i - 1);

					if (curHorizontalSelection < 0)
						curHorizontalSelection = 1;
					else if (curHorizontalSelection > 1)
						curHorizontalSelection = 0;

					// update stuffs
					FlxG.sound.play(Paths.sound('menu_select'), 1);
				}
			}

			updateSelection(curSelection);
			//
		}
	}

	private var submenuOpen:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!submenuOpen)
		{
			var up = controls.UP;
			var down = controls.DOWN;
			var up_p = controls.UP_P;
			var down_p = controls.DOWN_P;
			var controlArray:Array<Bool> = [up, down, up_p, down_p];

			if (controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					// here we check which keys are pressed
					if (controlArray[i] == true)
					{
						// if single press
						if (i > 1)
						{
							// up is 2 and down is 3
							// paaaaaiiiiiiinnnnn
							if (i == 2)
								updateSelection(curSelection - 1);
							else if (i == 3)
								updateSelection(curSelection + 1);
						}
					}
					//
				}
			}

			//
			updateHorizontalSelection();

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('stomp'), 1);
				submenuOpen = true;

				FlxFlicker.flicker(otherKeys.members[(curSelection * 2) + curHorizontalSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
				{
					if (submenuOpen)
						openSubmenu();
				});
			}
			else if (controls.BACK)
				close();
		}
		else
			subMenuControl();
	}

	override public function close()
	{
		//
		Init.saveControls(); // for controls
		Init.saveSettings(); // for offset
		super.close();
	}
	
	private var submenu:FlxSprite;

	private function openSubmenu()
	{
		offsetTemp = Init.trueSettings['Offset'];

		submenu.visible = true;
		if (curSelection != keyOptions.length - 1)
			submenuGroup.visible = true;
		else
			submenuoffsetGroup.visible = true;
	}

	private function closeSubmenu()
	{
		submenuOpen = false;

		submenu.visible = false;

		submenuGroup.visible = false;
		submenuoffsetGroup.visible = false;
	}

	private function subMenuControl()
	{
		// I dont really like hardcoded shit so I'm probably gonna change this lmao
		if (curSelection != keyOptions.length - 1)
		{
			// be able to close the submenu
			if (FlxG.keys.justPressed.ESCAPE)
				closeSubmenu();
			else if (FlxG.keys.justPressed.ANY)
			{
				// loop through existing keys and see if there are any alike
				var checkKey = FlxG.keys.getIsDown()[0].ID;

				// check if any keys use the same key lol
				// for (i in 0...otherKeys.members.length)
				// {
				// 	///*
				// 	if (otherKeys.members[i].text == checkKey.toString())
				// 	{
				// 		// switch them I guess???
				// 		var oldKey = Init.gameControls.get(keyOptions.members[curSelection].text)[0][curHorizontalSelection];
				// 		Init.gameControls.get(keyOptions.members[otherKeys.members[i].controlGroupID].text)[0][otherKeys.members[i].extensionJ] = oldKey;
				// 		otherKeys.members[i].text = getStringKey(oldKey);
				// 	}
				// 	//*/
				// }

				// now check if its the key we want to change
				Init.gameControls.get(keyOptions.members[curSelection].text)[0][curHorizontalSelection] = checkKey;
				otherKeys.members[(curSelection * 2) + curHorizontalSelection].text = getStringKey(checkKey);

				var textInstance = otherKeys.members[(curSelection * 2) + curHorizontalSelection];
				textInstance.setFormat(Paths.font("pixel_small.ttf"), 5, FlxColor.WHITE, LEFT);
				textInstance.updateHitbox();

				// refresh keys
				controls.setKeyboardScheme(None, false);

				// update all keys on screen to have the right values
				// inefficient so I rewrote it lolllll
				/*for (i in 0...otherKeys.members.length)
					{
						var stringKey = getStringKey(Init.gameControls.get(keyOptions.members[otherKeys.members[i].controlGroupID].text)[0][otherKeys.members[i].extensionJ]);
						trace('running $i times, options menu');
				}*/

				// close the submenu
				closeSubmenu();
			}
			//
		}
		else
		{
			if (FlxG.keys.justPressed.ENTER)
			{
				Init.trueSettings['Offset'] = offsetTemp;
				closeSubmenu();
			}
			else if (FlxG.keys.justPressed.ESCAPE)
				closeSubmenu();

			var move = 0;
			if (FlxG.keys.pressed.LEFT)
				move = -1;
			else if (FlxG.keys.pressed.RIGHT)
				move = 1;

			offsetTemp += move * 0.1;

			submenuOffsetValue.text = "< " + Std.string(Math.floor(offsetTemp * 10) / 10) + " >";
			submenuOffsetValue.updateHitbox();
			submenuOffsetValue.screenCenter(X);
			submenuOffsetValue.x = Std.int(submenuOffsetValue.x / 6) * 6;
		}
	}
}
