package meta.state.menus;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.userInterface.menu.Checkmark;
import gameObjects.userInterface.menu.Selector;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.Discord;
import meta.data.dependency.FNFSprite;
import meta.data.font.Alphabet;
import meta.subState.OptionsSubstate;

/**
	Options menu rewrite because I'm unhappy with how it was done previously
**/
class OptionsMenuState extends MusicBeatState
{
	private var categoryMap:Map<String, Dynamic>;
	private var activeSubgroup:FlxTypedGroup<FlxText>;
	private var attachments:FlxTypedGroup<FlxBasic>;

	var curSelection = 0;
	var curPipe = 2;
	var curSelectedScript:Void->Void;
	var curCategory:String;

	var warpText:FlxText;
	var bg:FlxSprite;
	var bg2:FlxSprite;

	var lockedMovement:Bool = false;
	var isPipes:Bool = true;
	var enteringPipe:Bool = false;
	var marioY:Float = 0;

	var mario:FlxSprite;
	var pipes = ['prefs', 'ctrls', 'exit'];
	var grpPipes:FlxTypedGroup<FlxSprite>;
	var grpPipeText:FlxTypedGroup<FlxText>;

	override public function create():Void
	{
		super.create();

		// define the categories
		/* 
			To explain how these will work, each main category is just any group of options, the options in the category are defined
			by the first array. The second array value defines what that option does.
			These arrays are within other arrays for information storing purposes, don't worry about that too much.
			If you plug in a value, the script will run when the option is hovered over.
		 */

		// NOTE : Make sure to check Init.hx if you are trying to add options.

		#if !html5
		Discord.changePresence('OPTIONS MENU', 'Main Menu');
		#end

		categoryMap = [
			'main' => [
				[
					['preferences', callNewGroup],
					['appearance', callNewGroup],
					['controls', openControlmenu],
					['exit', exitMenu]
				]
			],
			'preferences' => [
				[
					['Downscroll', getFromOption],
					['Centered Notefield', getFromOption],
					['Ghost Tapping', getFromOption],
					['Quant Notes', getFromOption],
					['', null],
					["Framerate Cap", getFromOption],
					['FPS Counter', getFromOption],
					['Memory Counter', getFromOption],
					['Debug Info', getFromOption],
				]
			],
			'appearance' => [
				[
					['Common Settings', null],
					['', null],
					['Disable Antialiasing', getFromOption],
					['No Camera Note Movement', getFromOption],
					['Fixed Judgements', getFromOption],
					['Simply Judgements', getFromOption],
					['', null],
					['Accessibility Settings', null],
					['', null],
					['Filter', getFromOption],
					["Stage Darkness", getFromOption],
					['Reduced Movements', getFromOption],
					// this shouldn't be get from option, just testing
					['', null],
					['User Interface', null],
					['', null],
					["UI Skin", getFromOption],
					["Note Skin", getFromOption],
					['Disable Note Splashes', getFromOption],
					['Opaque Arrows', getFromOption],
					['Opaque Holds', getFromOption],
				]
			]
		];

		for (category in categoryMap.keys())
		{
			categoryMap.get(category)[1] = returnSubgroup(category);
			categoryMap.get(category)[2] = returnExtrasMap(categoryMap.get(category)[1]);
		}

		// background
		bg = new FlxSprite();
		bg.loadGraphic(Paths.image('menus/pixel/options/bg'));
		bg.setGraphicSize(Std.int(bg.width * 6));
		bg.updateHitbox();
		bg.antialiasing = false;
		add(bg);

		// background
		bg2 = new FlxSprite();
		bg2.loadGraphic(Paths.image('menus/pixel/options/bg2'));
		bg2.setGraphicSize(Std.int(bg2.width * 6));
		bg2.updateHitbox();
		bg2.antialiasing = false;
		bg2.visible = false;
		add(bg2);

		warpText = new FlxText((38 * 6), (20 * 6), 0, 'WELCOME TO\nWARP ZONE!', 8);
		warpText.scrollFactor.set();
		warpText.setFormat(Paths.font("smb1.ttf"), 8, FlxColor.WHITE, CENTER);
		warpText.setGraphicSize(Std.int(warpText.width * 6));
		warpText.updateHitbox();
		add(warpText);

		// LOAD MUSIC
		ForeverTools.playOptionsMusic();

		loadPipes();

		//loadSubgroup('main');
	}

	private var currentAttachmentMap:Map<FlxText, Dynamic>;

	function loadPipes()
	{
		isPipes = true;

		// kill previous subgroup attachments
		if (attachments != null)
			remove(attachments);

		// kill previous subgroup if it exists
		if (activeSubgroup != null)
			remove(activeSubgroup);

		mario = new FlxSprite(0, 56 * 6).loadGraphic(Paths.image("menus/pixel/options/mario"));
		mario.setGraphicSize(Std.int(mario.width * 6));
		mario.updateHitbox();
		mario.antialiasing = false;
		add(mario);

		grpPipes = new FlxTypedGroup<FlxSprite>();
		add(grpPipes);

		grpPipeText = new FlxTypedGroup<FlxText>();
		add(grpPipeText);

		var i = 0;
		for (groupName in pipes)
		{
			var pipeText:FlxText = new FlxText(2 * 6, 64 * 6, 0, groupName, 8);
			pipeText.x += 56 * 6 * i;
			pipeText.scrollFactor.set();
			pipeText.setFormat(Paths.font("smb1.ttf"), 8);
			pipeText.setGraphicSize(Std.int(pipeText.width * 6));
			pipeText.updateHitbox();

			if (i == 0)
				pipeText.x += 1 * 6;
			if (i == 2)
				pipeText.x += 4 * 6;
			grpPipeText.add(pipeText);

			var pipe = new FlxSprite(8 * 6, 88 * 6);
			pipe.x += 56 * 6 * i;

			pipe.loadGraphic(Paths.image('menus/pixel/options/pipe'));
			pipe.setGraphicSize(Std.int(pipe.width * 6));
			pipe.updateHitbox();
			pipe.antialiasing = false;
			grpPipes.add(pipe);

			i++;
		}

		mario.visible = true;
		bg.visible = true;
		warpText.visible = true;

		bg2.visible = false;

		selectPipe(0);
	}

	function loadPrefs()
	{
		isPipes = false;
		curSelection = 0;

		var subgroupName = "preferences";

		// unlock the movement
		lockedMovement = false;

		if (grpPipes != null)
			remove(grpPipes);
		
		if (grpPipeText != null)
			remove(grpPipeText);

		// kill previous subgroup attachments
		if (attachments != null)
			remove(attachments);

		// kill previous subgroup if it exists
		if (activeSubgroup != null)
			remove(activeSubgroup);

		// load subgroup lmfao
		activeSubgroup = categoryMap.get(subgroupName)[1];
		add(activeSubgroup);

		// set the category
		curCategory = subgroupName;

		// add all group attachments afterwards
		currentAttachmentMap = categoryMap.get(subgroupName)[2];
		attachments = new FlxTypedGroup<FlxBasic>();
		for (setting in activeSubgroup)
			if (currentAttachmentMap.get(setting) != null)
				attachments.add(currentAttachmentMap.get(setting));
		add(attachments);

		mario.visible = false;
		bg.visible = false;
		warpText.visible = false;
		
		bg2.visible = true;

		// fix weird glitch
		curSelection = 5;
		getFromOption();

		// reset the selection
		curSelection = 0;
		selectOption(curSelection);
	}

	function selectPipe(change:Int)
	{
		if (change != 0)
		{
			FlxG.sound.play(Paths.sound('menu_select'), 1);
		}

		curPipe += change;
		if (curPipe >= pipes.length)
			curPipe = 0;
		if (curPipe < 0)
			curPipe = pipes.length - 1;
		
		mario.x = 16 * 6;
		mario.x += 56 * 6 * curPipe;

		var i = 0;
		for (pipeText in grpPipeText.members) 
		{
			if (i == curPipe)
			{
				pipeText.visible = false;
			}
			else
			{
				pipeText.visible = true;
			}
			i++;
		}
	}

	function selectOption(newSelection:Int, playSound:Bool = true)
	{
		if ((newSelection != curSelection) && (playSound))
			FlxG.sound.play(Paths.sound('menu_select'), 1);

		// direction increment finder
		var directionIncrement = ((newSelection < curSelection) ? -1 : 1);

		// updates to that new selection
		curSelection = newSelection;

		// wrap the current selection
		if (curSelection < 0)
			curSelection = activeSubgroup.length - 1;
		else if (curSelection >= activeSubgroup.length)
			curSelection = 0;

		// set the correct group stuffs lol
		for (i in 0...activeSubgroup.length)
		{
			activeSubgroup.members[i].color = 0xE69C21;
			if (currentAttachmentMap != null)
				setAttachmentColor(currentAttachmentMap.get(activeSubgroup.members[i]), 0xE69C21);

			// check for null members and hardcode the dividers
			if (categoryMap.get(curCategory)[0][i][1] == null) {
				activeSubgroup.members[i].color = 0xFFFFFF;
			}
		}

		activeSubgroup.members[curSelection].color = 0xFFFFFF;
		if (currentAttachmentMap != null)
			setAttachmentColor(currentAttachmentMap.get(activeSubgroup.members[curSelection]), 0xFFFFFF);

		// what's the script of the current selection?
		for (i in 0...categoryMap.get(curCategory)[0].length)
			if (categoryMap.get(curCategory)[0][i][0] == activeSubgroup.members[curSelection].text)
				curSelectedScript = categoryMap.get(curCategory)[0][i][1];
		// wow thats a dumb check lmao

		// skip line if the selected script is null (indicates line break)
		if (curSelectedScript == null)
			selectOption(curSelection + directionIncrement, false);
	}

	function loadSubgroup(subgroupName:String)
	{
		if (subgroupName != 'main')
		{
			// unlock the movement
			lockedMovement = false;

			// kill previous subgroup attachments
			if (attachments != null)
				remove(attachments);

			// kill previous subgroup if it exists
			if (activeSubgroup != null)
				remove(activeSubgroup);

			// load subgroup lmfao
			activeSubgroup = categoryMap.get(subgroupName)[1];
			add(activeSubgroup);

			// set the category
			curCategory = subgroupName;

			// add all group attachments afterwards
			currentAttachmentMap = categoryMap.get(subgroupName)[2];
			attachments = new FlxTypedGroup<FlxBasic>();
			for (setting in activeSubgroup)
				if (currentAttachmentMap.get(setting) != null)
					attachments.add(currentAttachmentMap.get(setting));
			add(attachments);

			// reset the selection
			//curSelection = 0;
			selectOption(curSelection);
		}
		else
		{
			warpText.visible = true;
			//curSelection = 0;
		}
	}

	function setAttachmentColor(attachment:FlxSprite, newColor:FlxColor)
	{
		// oddly enough, you can't set alphas of objects that arent directly and inherently defined as a value.
		// ya flixel is weird lmao
		if (attachment != null)
			attachment.color = newColor;
		// therefore, I made a script to circumvent this by defining the attachment with the `attachment` variable!
		// pretty neat, huh?
	}

	var finalText:String;
	var textValue:String = '';
	var infoTimer:FlxTimer;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var upP = controls.UP_P;
		var downP = controls.DOWN_P;

		if (isPipes)
		{

			if (!lockedMovement)
			{
				if (leftP)
				{
					selectPipe(-1);
				}
				if (rightP)
				{
					selectPipe(1);
				}
				if (downP)
				{
					lockedMovement = true;
					enteringPipe = true;
					marioY = mario.y;
					FlxG.sound.play(Paths.sound('power_down'), 1);
				}

				if (controls.BACK)
				{
					Main.switchState(this, new MainMenuState());
				}
			}

			if (enteringPipe)
			{
				marioY += (1 * 6) * 48 * elapsed;
				mario.y = Std.int(marioY / 6) * 6;

				if (marioY > 88 * 6)
				{
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						enteringPipe = false;
						switch (curPipe)
						{
							case 0:
								loadPrefs();
							case 1:
								openSubState(new OptionsSubstate());
								lockedMovement = false;
								mario.y = 56 * 6;
							case 2:
								Main.switchState(this, new MainMenuState());
						}
					});
				}
			}
		}
		else
		{

			// just uses my outdated code for the main menu state where I wanted to implement
			// hold scrolling but I couldnt because I'm dumb and lazy
			if (!lockedMovement)
			{
				// check for the current selection
				if (curSelectedScript != null)
					curSelectedScript();

				if (upP)
				{
					selectOption(curSelection - 1);
				}
				if (downP)
				{
					selectOption(curSelection + 1);
				}
			}

			// move the attachments if there are any
			for (setting in currentAttachmentMap.keys())
			{
				if ((setting != null) && (currentAttachmentMap.get(setting) != null))
				{
					var thisAttachment = currentAttachmentMap.get(setting);
					thisAttachment.x = setting.x - (2 * 6);
					thisAttachment.y = setting.y + (5 * 6);
				}
			}

			if (controls.BACK)
			{
				loadPipes();
			}
		}
	}

	private function returnSubgroup(groupName:String):FlxTypedGroup<FlxText>
	{
		//
		var newGroup:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

		for (i in 0...categoryMap.get(groupName)[0].length)
		{
			if (Init.gameSettings.get(categoryMap.get(groupName)[0][i][0]) == null
				|| Init.gameSettings.get(categoryMap.get(groupName)[0][i][0])[3] != Init.FORCED)
			{
				var thisOption:FlxText = new FlxText(0, 0, 0, categoryMap.get(groupName)[0][i][0], 8);
				thisOption.alpha = 1;
				thisOption.setFormat(Paths.font("pixel_small.ttf"), 5);
				thisOption.setGraphicSize(Std.int(thisOption.width * 6));
				thisOption.updateHitbox();

				thisOption.screenCenter(X);
				thisOption.x = Std.int(thisOption.x / 6) * 6;
				thisOption.y += (8 * 6 * i) + (24 * 6);
				newGroup.add(thisOption);
			}
		}

		return newGroup;
	}

	private function returnExtrasMap(alphabetGroup:FlxTypedGroup<FlxText>):Map<FlxText, Dynamic>
	{
		var extrasMap:Map<FlxText, Dynamic> = new Map<FlxText, Dynamic>();
		for (letter in alphabetGroup)
		{
			if (Init.gameSettings.get(letter.text) != null)
			{
				switch (Init.gameSettings.get(letter.text)[1])
				{
					case Init.SettingTypes.Checkmark:
						// checkmark
						var checkmark = ForeverAssets.generateCheckmark(0, 0, 'checkboxThingie', 'base', 'default', 'UI');
						checkmark.playAnim(Std.string(Init.trueSettings.get(letter.text)) + ' finished');

						extrasMap.set(letter, checkmark);
					case Init.SettingTypes.Selector:
						// selector
						var selector:Selector = new Selector(0, 0, letter.text, Init.gameSettings.get(letter.text)[4],
							true);

						extrasMap.set(letter, selector);
					default:
						// dont do ANYTHING
				}
				//
			}
		}

		return extrasMap;
	}

	/*
		This is the base option return
	 */
	public function getFromOption()
	{
		if (Init.gameSettings.get(activeSubgroup.members[curSelection].text) != null)
		{
			switch (Init.gameSettings.get(activeSubgroup.members[curSelection].text)[1])
			{
				case Init.SettingTypes.Checkmark:
					// checkmark basics lol
					if (controls.ACCEPT)
					{
						FlxG.sound.play(Paths.sound('stomp'), 1);
						lockedMovement = true;
						FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
						{
							// LMAO THIS IS HUGE
							Init.trueSettings.set(activeSubgroup.members[curSelection].text,
								!Init.trueSettings.get(activeSubgroup.members[curSelection].text));
							
							updateCheckmark(currentAttachmentMap.get(activeSubgroup.members[curSelection]),
								Init.trueSettings.get(activeSubgroup.members[curSelection].text));

							// save the setting
							Init.saveSettings();
							lockedMovement = false;
						});
					}
				case Init.SettingTypes.Selector:
					var selector:Selector = currentAttachmentMap.get(activeSubgroup.members[curSelection]);

					if (!controls.LEFT)
						selector.selectorPlay('left');
					if (!controls.RIGHT)
						selector.selectorPlay('right');

					if (controls.RIGHT_P)
						updateSelector(selector, 1);
					else if (controls.LEFT_P)
						updateSelector(selector, -1);
				default:
					// none
			}
		}
	}

	function updateCheckmark(checkmark:FNFSprite, animation:Bool)
		checkmark.playAnim(Std.string(animation));

	function updateSelector(selector:Selector, updateBy:Int)
	{
		// bro I dont even know if the engine works in html5 why am I even doing this
		// lazily hardcoded fps cap
		var originalFPS = Init.trueSettings.get(activeSubgroup.members[curSelection].text);
		var increase = 15 * updateBy;
		if (originalFPS + increase < 30)
			increase = 0;
		// high fps cap
		if (originalFPS + increase > 360)
			increase = 0;

		if (updateBy == -1)
			selector.selectorPlay('left', 'press');
		else
			selector.selectorPlay('right', 'press');

		FlxG.sound.play(Paths.sound('menu_select'), 1);

		originalFPS += increase;
		var chosenOptionString = Std.string(originalFPS);
		if (chosenOptionString.length <= 2)
			chosenOptionString = "0" + chosenOptionString;

		selector.chosenOptionString = chosenOptionString;
		selector.optionChosen.text = chosenOptionString;
		Init.trueSettings.set(activeSubgroup.members[curSelection].text, originalFPS);
		Init.saveSettings();
	}

	public function callNewGroup()
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			lockedMovement = true;
			FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				loadSubgroup(activeSubgroup.members[curSelection].text);
			});
		}
	}

	public function openControlmenu()
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			lockedMovement = true;
			FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				openSubState(new OptionsSubstate());
				lockedMovement = false;
			});
		}
	}

	public function exitMenu()
	{
		//
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			lockedMovement = true;
			FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				Main.switchState(this, new MainMenuState());
				lockedMovement = false;
			});
		}
		//
	}
}
