package gameObjects.userInterface;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import meta.CoolUtil;
import meta.InfoHud;
import meta.data.Conductor;
import meta.data.Timings;
import meta.state.PlayState;

using StringTools;

class SonicHUD extends FlxTypedGroup<FlxBasic>
{
	// set up variables and stuff here
	var infoBar:FlxText; // small side bar like kade engine that tells you engine info
	var accuracyText:FlxText;
	var accuracyText2:FlxText;

	var scoreLast:Float = -1;
	var scoreDisplay:String;
	var scoreGroup:FlxTypedGroup<FlxSprite>;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var SONG = PlayState.SONG;
	public var ratingIcon:FlxSprite;
	public var flagIcon:FlxSprite;
	private var stupidHealth:Float = 0;

	var curBeat = 0;

	// eep
	public function new()
	{
		// call the initializations and stuffs
		super();

		// fnf mods
		var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop';

		// le healthbar setup
		var barY = FlxG.height - (7 * 6);
		if (Init.trueSettings.get('Downscroll'))
			barY = 3 * 6;
		
		var UIBox:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('UI/default/sonic/bg'));
		UIBox.setGraphicSize(Std.int(UIBox.width * 6));
		UIBox.updateHitbox();
		UIBox.scrollFactor.set();
		UIBox.antialiasing = false;
		add(UIBox);

		if (Init.trueSettings.get('Downscroll'))
		{
			UIBox.flipY = true;
			UIBox.y -= 1; 
		}

		healthBarBG = new FlxSprite(0,
			barY).loadGraphic(Paths.image(ForeverTools.returnSkinAsset('healthBar', PlayState.assetModifier, PlayState.changeableSkin, 'UI')));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = false;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.visible = false;
		// healthBar
		add(healthBar);

		scoreGroup = new FlxTypedGroup<FlxSprite>();
		add(scoreGroup);

		for (index in 0...6)
		{
			var scoreNum:FlxSprite = new FlxSprite(8 * index * 6, barY - (1 * 6)).loadGraphic(Paths.image('UI/default/sonic/score'), true, 8, 8);
			scoreNum.animation.add('idle', [0,1,2,3,4,5,6,7,8,9], 0, false);
			scoreNum.animation.frameIndex = 0;

			scoreNum.x += 2 * 6;
			scoreNum.setGraphicSize(Std.int(scoreNum.width * 6));
			scoreNum.updateHitbox();
			scoreGroup.add(scoreNum);
		}

		accuracyText = new FlxText(0, barY, 0, "000000.00%");
		accuracyText.autoSize = false;
		accuracyText.borderSize = 0;
		accuracyText.setFormat(Paths.font("smb1.ttf"), 8, FlxColor.WHITE, LEFT);
		accuracyText.setGraphicSize(Std.int(accuracyText.width * 6));
		accuracyText.scrollFactor.set();
		accuracyText.antialiasing = false;
		add(accuracyText);

		accuracyText2 = new FlxText(0, barY + (1 * 6) + 2, 0, "000000.00%");
		accuracyText2.autoSize = false;
		accuracyText2.borderSize = 0;
		accuracyText2.setFormat(Paths.font("pixel_smaller.ttf"), 5, FlxColor.WHITE, LEFT);
		accuracyText2.setGraphicSize(Std.int(accuracyText2.width * 6));
		accuracyText2.scrollFactor.set();
		accuracyText2.antialiasing = false;
		add(accuracyText2);

		ratingIcon = new FlxSprite(0, 
			barY + (1 * 6)).loadGraphic(Paths.image("UI/default/sonic/rankings"), true, 8, 8);
		ratingIcon.animation.add("icon", [0, 1, 2, 3, 4, 5, 6, 7], 0, false);
		ratingIcon.animation.frameIndex = 0;
		
		ratingIcon.setGraphicSize(Std.int(ratingIcon.width * 6));
		ratingIcon.antialiasing = false;
		add(ratingIcon);

		flagIcon = new FlxSprite(0, barY + (1 * 6)).loadGraphic(Paths.image("UI/default/sonic/flags"), true, 8, 8);
		flagIcon.animation.add("icon", [0, 1, 2], 0, false);
		flagIcon.animation.frameIndex = 1;

		flagIcon.setGraphicSize(Std.int(flagIcon.width * 6));
		flagIcon.antialiasing = false;
		add(flagIcon);

		updateScoreText();

		// small info bar, kinda like the KE watermark
		// based on scoretxt which I will set up as well
		var infoDisplay:String = CoolUtil.dashToSpace(PlayState.SONG.song) + ' - ' + CoolUtil.difficultyFromNumber(PlayState.storyDifficulty);
		var engineDisplay:String = "Forever Engine BETA v" + Main.gameVersion;
		var engineBar:FlxText = new FlxText(0, FlxG.height - 30, 0, engineDisplay, 16);
		engineBar.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		engineBar.updateHitbox();
		engineBar.x = FlxG.width - engineBar.width - 5;
		engineBar.scrollFactor.set();
		engineBar.visible = false;
		add(engineBar);

		infoBar = new FlxText(5, FlxG.height - 30, 0, infoDisplay, 20);
		infoBar.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoBar.scrollFactor.set();
		infoBar.visible = false;
		add(infoBar);
	}

	public function flicker(object:FlxBasic)
	{
		if (object.visible && FlxG.random.bool(3))
		{
			object.visible = false;
		}
		else
		{
			object.visible = true;
		}
	}

	override public function update(elapsed:Float)
	{
		// pain, this is like the 7th attempt
		healthBar.percent = (PlayState.health * 50);
	}

	private final divider:String = ' - ';

	public function updateScoreText()
	{
		var importSongScore = PlayState.songScore;
		var importPlayStateCombo = PlayState.combo;
		var importMisses = PlayState.misses;
		var scoreText = Std.string(importSongScore);

		///
		var accuracyString = Std.string(Math.floor(Timings.getAccuracy() * 100) / 100);
		var stringSplit = accuracyString.split(".");
		switch (stringSplit[0].length)
		{
			case 1:
				stringSplit[0] = "00" + stringSplit[0];
			case 2:
				stringSplit[0] = "0" + stringSplit[0];
		}
		if (stringSplit[1].length == 1)
			stringSplit[1] = "0" + stringSplit[1];
		if (stringSplit[1] == null)
			stringSplit[1] = "00";
		accuracyText.text = stringSplit[0];
		accuracyText2.text = "." + stringSplit[1] + '%';
		///

		var isNegative:Bool = false;
		if (scoreText.charAt(0) == "-") 
		{
			scoreText = scoreText.substr(1);
			isNegative = true;
		}

		// lol i'm lazy and don't want to use math for this
		switch (scoreText.length)
		{
			case 1:
				scoreText = "00000" + scoreText;
			case 2:
				scoreText = "0000" + scoreText;
			case 3:
				scoreText = "000" + scoreText;
			case 4:
				scoreText = "00" + scoreText;
			case 5:
				scoreText = "0" + scoreText;
		}

		var index = 0;
		for (scoreNum in scoreGroup)
		{
			scoreNum.animation.frameIndex = Std.parseInt(scoreText.charAt(index));
			scoreNum.color = (isNegative) ? 0xB53120 : 0xFFFFFF;
			index += 1;
		}

		// testing purposes
		var displayAccuracy:Bool = Init.trueSettings.get('Display Accuracy');
		if (displayAccuracy)
		{
			// scoreText += divider + Std.string(Math.floor(Timings.getAccuracy() * 100) / 100) + '%' + Timings.comboDisplay;
			// scoreText += divider + 'Combo Breaks: ' + Std.string(PlayState.misses);
			// scoreText += divider + 'Rank: ' + Std.string(Timings.returnScoreRating().toUpperCase());
		}

		accuracyText.x = FlxG.width - (18 * 6);
		accuracyText2.x = accuracyText.x + (24 * 6);
		ratingIcon.x = FlxG.width - (47 * 6);
		flagIcon.x = ratingIcon.x - (8 * 6);

		ratingIcon.animation.frameIndex = Timings.ratingIntFinal;
		flagIcon.animation.frameIndex = Timings.comboDisplay;

		// update playstate
		PlayState.detailsSub = scoreText;
		PlayState.updateRPC(false);
	}

	public function beatHit()
	{
		
	}
}
