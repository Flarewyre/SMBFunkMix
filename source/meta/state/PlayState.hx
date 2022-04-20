package meta.state;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.shapes.FlxShapeBox; 
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import gameObjects.*;
import gameObjects.userInterface.*;
import gameObjects.userInterface.notes.*;
import gameObjects.userInterface.notes.Strumline.UIStaticArrow;
import meta.*;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Song.SwagSong;
import meta.state.charting.*;
import meta.state.menus.*;
import meta.subState.*;
import openfl.display.GraphicsShader;
import openfl.events.KeyboardEvent;
import openfl.filters.ShaderFilter;
import openfl.media.Sound;
import openfl.utils.Assets;
import sys.io.File;
import gameObjects.userInterface.GameboyPowerdown;
import flixel.addons.plugin.screengrab.FlxScreenGrab;

using StringTools;

#if !html5
import meta.data.dependency.Discord;
#end

class PlayState extends MusicBeatState
{
	public static var startTimer:FlxTimer;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 2;

	public static var songMusic:FlxSound;
	public static var vocals:FlxSound;

	public static var campaignScore:Int = 0;

	public static var dadOpponent:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public static var dadOpponent2:Character;
	public static var boyfriend2:Boyfriend;

	public static var assetModifier:String = 'base';
	public static var changeableSkin:String = 'default';

	private var unspawnNotes:Array<Note> = [];
	private var ratingArray:Array<String> = [];
	private var allSicks:Bool = true;

	// if you ever wanna add more keys
	private var numberOfKeys:Int = 4;

	// get it cus release
	// I'm funny just trust me
	private var curSection:Int = 0;
	private var camFollow:FlxObject;
	private var camFollowLerp:FlxObject;
	public var shakeTime:Float;
	public var shakeIntensity:Float;
	public var shakeOffset:Float;
	public var shakeDir:Int = 1;
	public var nextShake:Float;

	// Discord RPC variables
	public static var songDetails:String = "";
	public static var detailsSub:String = "";
	public static var detailsPausedText:String = "";

	private static var prevCamFollow:FlxObject;

	private var curSong:String = "";
	private var gfSpeed:Int = 1;

	public static var health:Float = 1; // mario
	public static var gbHealth:Float = 2;
	public static var powerup:Int = 2;
	public static var combo:Int = 0;
	public static var bfPrefix:String = "";
	public static var isGameboy:Bool = false;
	public static var isMari0:Bool = false;
	public static var isSMM:Bool = false;
	public static var isSonic:Bool = false;

	public var beatsUntilSpawn:Int = -1;
	public var damageCooldown:Float = 0;
	public static var misses:Int = 0;

	public var generatedMusic:Bool = false;

	private var startingSong:Bool = false;
	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var inCutscene:Bool = false;

	var canPause:Bool = false;

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	public static var camHUD:FlxCamera;
	public static var camGame:FlxCamera;
	public static var dialogueHUD:FlxCamera;

	public var camDisplaceX:Float = 0;
	public var camDisplaceY:Float = 0; // might not use depending on result

	public static var defaultCamZoom:Float = 1;

	public static var forceZoom:Array<Float>;

	public static var songScore:Int = 0;

	var storyDifficultyText:String = "";

	public static var iconRPC:String = "";

	public static var songLength:Float = 0;

	private var stageBuild:Stage;

	public static var uiHUD:ClassHUD;
	public static var gameboyHUD:GameboyHUD;
	public static var mari0HUD:Mari0HUD;
	public static var smmHUD:SMMHUD;
	public static var sonicHUD:SonicHUD;

	public static var daPixelZoom:Float = 6;
	public static var determinedChartType:String = "";

	// strumlines
	private var dadStrums:Strumline;
	private var boyfriendStrums:Strumline;

	public static var strumLines:FlxTypedGroup<Strumline>;
	public static var strumHUD:Array<FlxCamera> = [];

	private var allUIs:Array<FlxCamera> = [];

	public var ratingPos:FlxPoint;
	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo objects in an array
	public static var lastCombo:Array<FlxSprite>;

	public static var blackBox:FlxShapeBox;
	public static var marioSwim:FlxSprite;
	
	public static var verticalBridge:FlxSprite;
	public static var horizontalBridge:FlxSprite;
	public static var isHorizontal:Bool;
	public static var bfAnimLock:Float;
	public static var ddAnimLock:Float;

	public var bfX:Float;
	public var bfVelocity:Float;
	public var bfAccel:Float = 750;
	public var bfSpeed:Float = 450;
	public var bfFriction:Float = 900;
	public var platformerControls:Bool;

	public var fireballs:FlxTypedGroup<FlxSprite>;
	public var beatsLeft:Int = 0;
	public var nextFlash:Float = 0;
	public var nextFlip:Float = 0;
	public var bfHitbox:FlxSprite;
	public var fireSpots:Int = 2;
	public var fireCooldown:Float = 0;

	public var targetY:Float;
	public var dadVelocity:Float;
	public var dadPos:Float;
	public var spikeDead:Bool;
	public var originalY:Float;

	public var bfDeathFake:FlxSprite;
	public var bfDeathVelocity:Float;
	public var bfDeathPos:Float;
	public var fakeDeath:Bool;
	public var disableControls:Bool;

	public var tailsPos:FlxPoint;
	public var tailsTarget:FlxPoint;

	public var luigiPos:FlxPoint;
	public var luigiTarget:FlxPoint;

	public var marioPos:FlxPoint;
	public var marioTarget:FlxPoint;
	public var groundPos:Float;
	public var marioVelocity:Float;
	public var marioBounces:Int;

	public var gameboyFade:FlxSprite;

	public static var mustHit:Bool; 

	public var secretFunnyCharts:Array<Array<Note>> = [];
	public var secretFunnyCharacters:Array<Array<String>> = [];

	var extraCharts:Array<Dynamic> = [];

	public function getCamPos()
	{
		var camPos = (Init.trueSettings.get('Downscroll')) ? (49 * 6) : (32 * 6);
		if ((Init.trueSettings.get('Downscroll')) && isGameboy)
			camPos -= 8 * 6;
		return camPos;
	}

	// at the beginning of the playstate
	override public function create()
	{
		super.create();
		Conductor.songPosition = 0;

		// reset any values and variables that are static
		songScore = 0;
		combo = 0;
		health = 1;
		gbHealth = 2;
		powerup = 2;
		misses = 0;
		mustHit = false;
		// sets up the combo object array
		lastCombo = [];

		defaultCamZoom = 1;
		forceZoom = [0, 0, 0, 0];

		Timings.callAccuracy();

		assetModifier = 'base';
		changeableSkin = 'default';

		// stop any existing music tracks playing
		resetMusic();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// create the game camera
		camGame = new FlxCamera();
		ratingPos = new FlxPoint();

		// create the hud camera (separate so the hud stays on screen)
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		allUIs.push(camHUD);
		FlxCamera.defaultCameras = [camGame];

		// default song
		if (SONG == null)
			SONG = Song.loadFromJson('test', 'test');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		/// here we determine the chart type!
		// determine the chart type here
		determinedChartType = "FNF";

		//
		isSonic = (SONG.song.toLowerCase() == 'cross-console-clash');

		// set up a class for the stage type in here afterwards
		curStage = "";
		// call the song's stage if it exists
		if (SONG.stage != null)
			curStage = SONG.stage;

		if (SONG.song.toLowerCase() == 'balls')
		{
			SONG.player1 = 'luigi-player';
			SONG.player2 = 'mario';
		}
		if (isSonic)
		{
			SONG.player1 = 'mario-ccc';
			SONG.player2 = 'sonic';
		}
		if (SONG.player1 == 'bf-glitch' && Init.trueSettings.get("Photosensitivity"))
		{
			SONG.player1 = 'bf';
		}

		// cache ratings LOL
		displayRating('sick', 'early', true);
		popUpCombo(true);

		stageBuild = new Stage(curStage);
		add(stageBuild);

		isGameboy = (curStage == 'camera');
		isMari0 = (curStage == 'test-chamber');
		isSMM = (curStage == 'smm');

		/*
			Everything related to the stages aside from things done after are set in the stage class!
			this means that the girlfriend's type, boyfriend's position, dad's position, are all there

			It serves to clear clutter and can easily be destroyed later. The problem is,
			I don't actually know if this is optimised, I just kinda roll with things and hope
			they work. I'm not actually really experienced compared to a lot of other developers in the scene,
			so I don't really know what I'm doing, I'm just hoping I can make a better and more optimised
			engine for both myself and other modders to use!
		 */

		bfPrefix = SONG.player1;

		marioSwim = new FlxSprite().loadGraphic(Paths.image('backgrounds/water/mario'), true, 24, 32);
		marioSwim.animation.add("swim", [0, 1, 2, 3, 4, 5], 9);
		marioSwim.animation.play("swim");

		marioSwim.scrollFactor.set(1, 1);
		marioSwim.antialiasing = false;
		marioSwim.setGraphicSize(Std.int(marioSwim.width * 6));
		marioSwim.updateHitbox();
		marioSwim.visible = false;

		// set up characters here too
		gf = new Character(0, 0, stageBuild.returnGFtype(curStage));
		gf.scrollFactor.set(1, 1);

		dadOpponent = new Character((8*6) - 1, (3*6) - 2, SONG.player2);
		boyfriend = new Boyfriend((10*6) - 1, (11*6) - 1, SONG.player1);

		dadOpponent2 = new Character(0, 0, (isSMM) ? SONG.player2 : 'tails');
		boyfriend2 = new Boyfriend(0, 0, 'luigi-ccc');

		// if you want to change characters later use setCharacter() instead of new or it will break
		var camPos:FlxPoint = new FlxPoint(boyfriend.getMidpoint().x, boyfriend.getMidpoint().y);

		// set the dad's position (check the stage class to edit that!)
		// reminder that this probably isn't the best way to do this but hey it works I guess and is cleaner
		stageBuild.dadPosition(curStage, dadOpponent, gf, camPos, SONG.player2);

		// I don't like the way I'm doing this, but basically hardcode stages to charts if the chart type is the base fnf one
		// (forever engine charts will have non hardcoded stages)

		changeableSkin = 'default';
		assetModifier = 'pixel';
		if (isGameboy)
		{
			assetModifier = 'gameboy';
		}
		else if (isMari0)
		{
			assetModifier = 'mari0';

		}
		else if (isSMM)
		{
			assetModifier = 'mari0';
		}

		// isPixel = true;

		// reposition characters
		stageBuild.repositionPlayers(curStage, boyfriend, dadOpponent, gf);
		originalY = dadOpponent.y;

		camPos.x = boyfriend.getMidpoint().x;
		camPos.y = boyfriend.getMidpoint().y;

		if (isSonic)
		{
			var epicSwagSong:SwagSong = Song.loadFromJson('cross-console-clash-2', SONG.song);
			extraCharts[0] = ChartLoader.generateChartType(epicSwagSong, determinedChartType);
			extraCharts[0].sort(sortByShit);
			Timings.accuracyMaxCalculation(extraCharts[0]);

			dadOpponent2.x = dadOpponent.x - (42 * 6);
			dadOpponent2.y = dadOpponent.y - (8 * 6);

			boyfriend2.x = boyfriend.x + (40 * 6);
			boyfriend2.y = boyfriend.y - (16 * 6);
		}
		else if (isSMM)
		{
			dadOpponent2.x = dadOpponent.x + (2 * 6);
			dadOpponent2.y = dadOpponent.y + (2 * 6);
			dadOpponent2.color = FlxColor.BLACK;

			boyfriend2.x = boyfriend.x + (2 * 6);
			boyfriend2.y = boyfriend.y + (2 * 6);
			boyfriend2.color = FlxColor.BLACK;
		}
		dadOpponent2.visible = (isSonic || isSMM);
		boyfriend2.visible = (isSonic || isSMM);


		fireballs = new FlxTypedGroup(6);
		var sprite:FlxSprite;
		for (i in 0...6)
		{
			var sprite = new FlxSprite(0, 0).loadGraphic(Paths.image('backgrounds/ghost/fireball'), true, 16, 48);
			sprite.animation.add('warning', [3], 12, false);
			sprite.animation.add('shoot', [0, 1, 2], 12, false);
			sprite.animation.add('retract', [2, 1, 0, 4], 12, false);
			sprite.animation.play("warning");

			sprite.setGraphicSize(Std.int(sprite.width * 6));
			sprite.updateHitbox();
			sprite.exists = false;

			fireballs.add(sprite);
		}

		add(fireballs);


		// add characters
		add(marioSwim);
		add(gf);

		// add limo cus dumb layering
		if (curStage == 'highway')
			add(stageBuild.limo);

		add(dadOpponent2);
		add(boyfriend2);

		add(dadOpponent);
		add(boyfriend);

		add(stageBuild.foreground);

		// force them to dance
		dadOpponent.dance();
		gf.dance();
		boyfriend.dance();

		// set song position before beginning
		Conductor.songPosition = -(Conductor.crochet * 4);

		// EVERYTHING SHOULD GO UNDER THIS, IF YOU PLAN ON SPAWNING SOMETHING LATER ADD IT TO STAGEBUILD OR FOREGROUND
		// darken everything but the arrows and ui via a flxsprite
		var darknessBG:FlxSprite = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		darknessBG.alpha = Init.trueSettings.get('Stage Darkness') * 0.01;
		darknessBG.scrollFactor.set(0, 0);
		add(darknessBG);

		// strum setup
		strumLines = new FlxTypedGroup<Strumline>();

		// generate the song
		generateSong(SONG.song);

		// set the camera position to the center of the stage
		camPos.set(gf.x + (gf.frameWidth / 2), gf.y + (gf.frameHeight / 2));

		// create the game camera
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);

		camFollowLerp = new FlxObject(0, 0, 1, 1);
		camFollowLerp.setPosition(camPos.x, camPos.y);
		// check if the camera was following someone previously
		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		if (boyfriend.curCharacter != "luigi-player" && boyfriend.curCharacter != "bf-camera")
			powerupVisuals(boyfriend.animation.name);
		if (bfPrefix == 'bf-water')
			marioSwim.visible = true;

		// actually set the camera up
		var camLerp = Main.framerateAdjust(0.04);
		FlxG.camera.follow(camFollowLerp, LOCKON, camLerp);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollowLerp.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		// initialize ui elements
		startingSong = true;
		startedCountdown = true;

		//
		var placement = (FlxG.width / 2);
		dadStrums = new Strumline(placement - (FlxG.width / 4), this, dadOpponent, false, true, false, 4, Init.trueSettings.get('Downscroll'));
		dadStrums.visible = !Init.trueSettings.get('Centered Notefield');
		boyfriendStrums = new Strumline(placement + (!Init.trueSettings.get('Centered Notefield') ? (FlxG.width / 4) : 0), this, boyfriend, true, false, true,
			4, Init.trueSettings.get('Downscroll'));

		strumLines.add(dadStrums);
		strumLines.add(boyfriendStrums);

		// strumline camera setup
		strumHUD = [];
		for (i in 0...strumLines.length)
		{
			// generate a new strum camera
			strumHUD[i] = new FlxCamera();
			strumHUD[i].bgColor.alpha = 0;

			strumHUD[i].cameras = [camHUD];
			allUIs.push(strumHUD[i]);
			FlxG.cameras.add(strumHUD[i]);
			// set this strumline's camera to the designated camera
			strumLines.members[i].cameras = [strumHUD[i]];
		}
		add(strumLines);

		if (isGameboy)
		{
			gameboyHUD = new GameboyHUD();
			add(gameboyHUD);
			gameboyHUD.cameras = [camHUD];
		}
		else if (isMari0)
		{
			mari0HUD = new Mari0HUD();
			add(mari0HUD);
			mari0HUD.cameras = [camHUD];
		}
		else if (isSMM)
		{
			smmHUD = new SMMHUD();
			add(smmHUD);
			smmHUD.cameras = [camHUD];
		}
		else if (isSonic)
		{
			sonicHUD = new SonicHUD();
			add(sonicHUD);
			sonicHUD.cameras = [camHUD];
		}
		else
		{
			uiHUD = new ClassHUD();
			add(uiHUD);
			uiHUD.cameras = [camHUD];
		}
		//

		// create a hud over the hud camera for dialogue
		dialogueHUD = new FlxCamera();
		dialogueHUD.bgColor.alpha = 0;
		FlxG.cameras.add(dialogueHUD);

		verticalBridge =  new FlxSprite(96 * 6, 50 * 6).loadGraphic(Paths.image("UI/default/mari0/bridge-vertical"), true, 24, 120);
		verticalBridge.animation.add("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34], 9, true);
		verticalBridge.animation.play("idle");

		verticalBridge.setGraphicSize(Std.int(verticalBridge.width * 6));
		verticalBridge.antialiasing = false;
		verticalBridge.cameras = [dialogueHUD];
		verticalBridge.alpha = 0.9;
		verticalBridge.visible = false;
		add(verticalBridge);

		horizontalBridge =  new FlxSprite(66.5 * 6, 64 * 6).loadGraphic(Paths.image("UI/default/mari0/bridge-horizontal"), true, 160, 24);
		horizontalBridge.animation.add("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34], 9, true);
		horizontalBridge.animation.play("idle");

		horizontalBridge.setGraphicSize(Std.int(horizontalBridge.width * 6));
		horizontalBridge.antialiasing = false;
		horizontalBridge.cameras = [dialogueHUD];
		horizontalBridge.alpha = 0.9;
		horizontalBridge.visible = false;
		add(horizontalBridge);

		blackBox = new FlxShapeBox(0, 0, FlxG.width, FlxG.height, {thickness: 0, color: FlxColor.TRANSPARENT}, FlxColor.WHITE);
		blackBox.color = FlxColor.BLACK;
		blackBox.cameras = [dialogueHUD];
		blackBox.visible = false;
		add(blackBox);

		bfX = boyfriend.x;

		bfHitbox = new FlxSprite().makeGraphic(8 * 6, 16 * 6);
		bfHitbox.visible = false;
		add(bfHitbox);

		gameboyFade = new FlxSprite((18 * 6) + 0.005, (-2 * 6) + 1).loadGraphic(Paths.image('characters/camera/fade'), true, 124, 76);
		gameboyFade.animation.add('in', [0, 1, 2, 3, 4], 24, false);
		gameboyFade.animation.add('out', [4, 3, 2, 1, 0], 24, false);
		gameboyFade.animation.play('out');

		gameboyFade.setGraphicSize(Std.int(gameboyFade.width * 6));
		gameboyFade.updateHitbox();
		gameboyFade.visible = isGameboy;
		add(gameboyFade);

		tailsPos = new FlxPoint(dadOpponent2.x - (80 * 6), dadOpponent2.y - (64 * 6));
		tailsTarget = new FlxPoint(dadOpponent2.x, dadOpponent2.y);

		luigiPos = new FlxPoint(boyfriend2.x + (64 * 6), boyfriend2.y - (20 * 6));
		luigiTarget = new FlxPoint(boyfriend2.x, boyfriend2.y);

		marioPos = new FlxPoint(boyfriend.x, boyfriend.y);
		marioTarget = new FlxPoint(boyfriend.x, boyfriend.y);
		groundPos = boyfriend.y;

		// call the funny intro cutscene depending on the song
		if (!skipCutscenes())
			songIntroCutscene();
		else
			startCountdown();

		/**
		 * SHADERS
		 *
		 * This is a highly experimental code by gedehari to support runtime shader parsing.
		 * Usually, to add a shader, you would make it a class, but now, I modified it so
		 * you can parse it from a file.
		 *
		 * This feature is planned to be used for modcharts
		 * (at this time of writing, it's not available yet).
		 *
		 * This example below shows that you can apply shaders as a FlxCamera filter.
		 * the GraphicsShader class accepts two arguments, one is for vertex shader, and
		 * the second is for fragment shader.
		 * Pass in an empty string to use the default vertex/fragment shader.
		 *
		 * Next, the Shader is passed to a new instance of ShaderFilter, neccesary to make
		 * the filter work. And that's it!
		 *
		 * To access shader uniforms, just reference the `data` property of the GraphicsShader
		 * instance.
		 *
		 * Thank you for reading! -gedehari
		 */

		// Uncomment the code below to apply the effect

		/*
		var shader:GraphicsShader = new GraphicsShader("", File.getContent("./assets/shaders/vhs.frag"));
		FlxG.camera.setFilters([new ShaderFilter(shader)]);
		*/
	}

	var staticDisplace:Int = 0;

	function isMovementAnim():Bool
	{
		return boyfriend.animation.name == 'run' || boyfriend.animation.name == 'skid';
	}

	function spawnFireballs()
	{
		beatsLeft = 4;
		fireCooldown = 0.5;

		var safeSpots:Array<Int> = [];
		for (i in 0...fireSpots)
		{
			safeSpots.push(FlxG.random.int(0, 5));
		}
		
		var index = 0;
		for (fireball in fireballs.members)
		{
			fireball.x = (64 * 6) + (16 * index * 6);
			fireball.exists = !safeSpots.contains(index);

			fireball.animation.play("warning");
			fireball.visible = false;
			index += 1;
		}
	}

	function updateFireballs(elapsed:Float)
	{
		nextFlash -= elapsed;
		if (nextFlash <= 0)
		{
			nextFlash = 0.2 * (beatsLeft / 4);
			for (fireball in fireballs.members)
			{
				fireball.visible = !fireball.visible;
			}
		}
	}

	function shootFire()
	{
		for (fireball in fireballs.members)
		{
			fireball.visible = true;
			fireball.animation.play("shoot");
		}
	}

	function hitDetection()
	{
		if (damageCooldown <= 0)
		{
			for (fireball in fireballs.members)
			{
				if (fireball.exists && (bfHitbox.x + (8 * 6)) > fireball.x)
				{
					if (bfHitbox.x < fireball.x + (16 * 6))
					{
						trace(bfHitbox.x);
						trace(fireball.x);
						if (damageCooldown <= 0)
						{
							powerupCall();
							damageCooldown = 2;
						}
					}
				}
			}
		}
	}

	function depressStrums()
	{
		for (arrow in boyfriendStrums.receptors)
		{
			arrow.playAnim('static');
		}
	}

	function boyfriendMovement(elapsed:Float)
	{
		var moveDirection = 0;
		if (controls.LEFT)
		{
			moveDirection -= 1;
		}
		if (controls.RIGHT)
		{
			moveDirection += 1;
		}


		bfVelocity += bfAccel * moveDirection * elapsed;
		if (moveDirection == -1 && bfVelocity <= -bfSpeed)
		{
			bfVelocity = -bfSpeed;
		}
		if (moveDirection == 1 && bfVelocity >= bfSpeed)
		{
			bfVelocity = bfSpeed;
		}

		if (moveDirection == 0)
		{
			if (bfVelocity > 0)
			{
				bfVelocity -= bfFriction * elapsed;
				if (bfVelocity <= 0)
				{
					bfVelocity = 0;
				}
			}
			if (bfVelocity < 0)
			{
				bfVelocity += bfFriction * elapsed;
				if (bfVelocity >= 0)
				{
					bfVelocity = 0;
				}
			}
		}
		else
		{
			boyfriend.animation.curAnim.frameRate = 10.5 * FlxMath.bound((Math.abs(bfVelocity) / bfSpeed), 0.5, 1);
			boyfriend.flipX = (moveDirection == 1);

			if (Math.abs(bfVelocity) > 0 && FlxMath.signOf(bfVelocity) != moveDirection)
			{
				bfVelocity += bfAccel * moveDirection * 2 * elapsed;
				if (boyfriend.animation.name != "skid") // itsa spooky month
					boyfriend.playAnim("skid");
			}
		}

		if (Math.abs(bfVelocity) > 0 && boyfriend.animation.name != "run")
		{
			if (!(Math.abs(bfVelocity) > 0 && FlxMath.signOf(bfVelocity) != moveDirection))
				boyfriend.playAnim("run");
		}
		else if (Math.abs(bfVelocity) == 0 && isMovementAnim())
		{
			boyfriend.playAnim("idle");
			boyfriend.animation.curAnim.frameRate = 12;
			boyfriend.animation.curAnim.curFrame = 6;
		}

		bfX += bfVelocity * elapsed;
		if (bfX > (152 * 6))
		{
			bfX = 152 * 6;
			bfVelocity = 0;
		}
		if (bfX < (68 * 6))
		{
			bfX = 68 * 6;
			bfVelocity = 0;
		}

		boyfriend.x = Std.int(bfX / 6) * 6;
		// pixel alignment
		if (powerup != 0)
		{
			boyfriend.x -= 1.5;
		}
		else
		{
			boyfriend.x -= 12;
		}
	}

	public function roar()
	{
		dadOpponent.playAnim('roarStart');
		new FlxTimer().start(0.25, function(tmr:FlxTimer)
		{
			shakeIntensity = 4;
			shakeTime = 2;
		});
	}

	override public function update(elapsed:Float)
	{
		stageBuild.stageUpdateConstant(elapsed, boyfriend, gf, dadOpponent);
		hiddenChartUpdate();

		super.update(elapsed);

		//this is for cutscene tests ig
		// if (FlxG.keys.pressed.E)
		// {
		// 	endSong();
		// }

		nextShake -= elapsed;
		if (nextShake <= 0)
		{
			shakeDir = -shakeDir;
			nextShake = 0.025;
		}

		if (shakeTime > 0 && !Init.trueSettings.get("Photosensitivity"))
		{
			shakeTime -= elapsed;
			var moveStrength = shakeIntensity * ((shakeTime / 2) + 1);

			shakeOffset = Std.int((shakeDir * moveStrength) / 6) * 6;
			FlxG.camera.y = shakeOffset;

			if (shakeTime <= 0)
			{
				shakeTime = 0;
				shakeOffset = 0;
				FlxG.camera.y = 0;
				if (dadOpponent.animation.name == 'explode')
				{
					dadOpponent.visible = false;
				}
			}
		}

		if (marioBounces > 0)
		{
			if (marioPos.y > groundPos)
			{
				marioBounces -= 1;
				if (marioBounces > 0)
				{
					marioPos.y = groundPos - 6;
					marioVelocity = -800;
					boyfriend.playAnim("jump");
				}
				else
				{
					marioPos.y = groundPos;
					marioVelocity = 0;
					boyfriend.playAnim("idle");
				}
			}

			marioVelocity += 6000 * elapsed;
			marioPos.y += marioVelocity * elapsed;
		}

		if (targetY > 0 && dadOpponent.y < targetY)
		{
			dadPos += 4000 * elapsed;
			dadOpponent.y = Std.int(dadPos / 6) * 6;
			if (dadPos >= targetY)
			{
				dadPos = targetY;
				dadOpponent.y = targetY;
				dadOpponent.playAnim("idle");
				targetY = 0;
			}
		}

		if (spikeDead && dadOpponent.y < 128 * 6)
		{
			dadVelocity += (12.5 * 130 * elapsed);

			dadPos += dadVelocity * elapsed;
			dadOpponent.y = Std.int(dadPos / 6) * 6;

			if (dadOpponent.y > 128 * 6)
			{
				spikeDead = false;
			}
		}

		if (fakeDeath && boyfriend.y < 128 * 6)
		{
			bfDeathVelocity += (12.5 * 130 * elapsed);

			bfDeathPos += bfDeathVelocity * elapsed;
			bfDeathFake.y = Std.int(bfDeathPos / 6) * 6;
			boyfriend.visible = false;
		}

		if (fireCooldown > 0)
		{
			fireCooldown -= elapsed;
			if (fireCooldown < 0)
			{
				fireCooldown = 0;
			}
		}

		if (bfAnimLock > 0)
		{
			bfAnimLock -= elapsed;
			if (bfAnimLock <= 0)
			{
				bfAnimLock = 0;
				boyfriend.animation.play('idle');
			}
		}

		if (ddAnimLock > 0)
		{
			ddAnimLock -= elapsed;
			if (ddAnimLock <= 0)
			{
				ddAnimLock = 0;
				dadOpponent.animation.play('idle');
			}
		}

		if (bfPrefix == 'bf-water')
		{
			boyfriend.x = marioSwim.x - (3 * 6);
			boyfriend.y = marioSwim.y + (21 * 6);
			
			boyfriend.x -= 2;
			boyfriend.y += 1;
		}

		FlxG.camera.followLerp = FlxG.updateFramerate / 60;
		// camFollowLerp.x = FlxMath.lerp(camFollowLerp.x, camFollow.x, elapsed * 2);
		// camFollowLerp.y = FlxMath.lerp(camFollowLerp.y, camFollow.y, elapsed * 2);

		// camFollowLerp.x = Std.int(camFollowLerp.x / 6) * 6;
		// camFollowLerp.y = Std.int(camFollowLerp.y / 6) * 6;
		camFollowLerp.x = FlxG.width / 2;
		camFollowLerp.y = getCamPos();

		var isMinus = (SONG.song == 'Wrong-Warp');
		if (ratingPos != null)
		{			
			var speed = 200;
			ratingPos.y -= speed * elapsed;
		}
		if (lastRating != null && ratingPos != null)
		{
			var increment = 6;
			if (isMinus)
			{
				increment = 18;
				if (FlxG.random.bool(5))
					ratingPos.y += 12;
			}
			lastRating.y = Std.int(ratingPos.y / increment) * increment;
		}

		if (isGameboy)
		{
			lastRating.x = 84 * 6;
			lastRating.y = 83 * 6;
			lastRating.y += 1;
			
			if (Init.trueSettings.get('Downscroll'))
			{
				lastRating.y = -10 * 6;
				lastRating.y += 1;
			}
		}

		if (health > 2)
			health = 2;
		if (gbHealth > 2)
			gbHealth = 2;
		
		if (damageCooldown > 0)
		{
			boyfriend.alpha = FlxG.game.ticks % 2;
			damageCooldown -= elapsed;
			if (damageCooldown <= 0)
			{
				damageCooldown = 0;
				boyfriend.alpha = 1;
			}
		}

		// dialogue checks
		if (dialogueBox != null && dialogueBox.alive) {
			// wheee the shift closes the dialogue
			if (FlxG.keys.justPressed.SHIFT)
				dialogueBox.closeDialog();

			// the change I made was just so that it would only take accept inputs
			if (controls.ACCEPT && dialogueBox.textStarted)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				dialogueBox.curPage += 1;

				if (dialogueBox.curPage == dialogueBox.dialogueData.dialogue.length)
					dialogueBox.closeDialog()
				else
					dialogueBox.updateDialog();
			}

		}

		if (!inCutscene) {
			// pause the game if the game is allowed to pause and enter is pressed
			if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
			{
				// update drawing stuffs
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// open pause substate
				if (!isGameboy)
				{
					openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
				else
				{
					openSubState(new GameboyPauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
				updateRPC(true);
			}

			if (FlxG.keys.justPressed.SIX)
			{
				boyfriendStrums.autoplay = !boyfriendStrums.autoplay;
			}

			// charting state (more on that later)
			if ((FlxG.keys.justPressed.SEVEN) && (!startingSong))
			{
				resetMusic();
				Main.switchState(this, new OriginalChartingState());
			}

			///*
			if (startingSong)
			{
				if (startedCountdown)
				{
					Conductor.songPosition += elapsed * 1000;
					if (Conductor.songPosition >= 0)
						startSong();
				}
			}
			else
			{
				// Conductor.songPosition = FlxG.sound.music.time;
				Conductor.songPosition += elapsed * 1000;

				if (!paused)
				{
					songTime += FlxG.game.ticks - previousFrameTime;
					previousFrameTime = FlxG.game.ticks;

					// Interpolation type beat
					if (Conductor.lastSongPos != Conductor.songPosition)
					{
						songTime = (songTime + Conductor.songPosition) / 2;
						Conductor.lastSongPos = Conductor.songPosition;
						// Conductor.songPosition += FlxG.elapsed * 1000;
						// trace('MISSED FRAME');
					}
				}

				// Conductor.lastSongPos = FlxG.sound.music.time;
				// song shit for testing lols
			}

			// boyfriend.playAnim('singLEFT', true);
			// */

			if (isGameboy && generatedMusic && PlayState.SONG.notes[Std.int((curStep + 2) / 16)] != null)
			{
				if (PlayState.SONG.notes[Std.int((curStep + 2) / 16)].mustHitSection != boyfriend.visible)
				{
					if (gameboyFade.animation.name == 'out')
					{
						gameboyFade.animation.play('in');
					}
				}
				if (PlayState.SONG.notes[Std.int((curStep + 2) / 16)].mustHitSection == boyfriend.visible)
				{
					if (gameboyFade.animation.name == 'in')
					{
						gameboyFade.animation.play('out');
					}
				}
			}

			if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if (isGameboy)
				{
					boyfriend.visible = PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection;
					dadOpponent.visible = !boyfriend.visible;
				}
				
				if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					var char = dadOpponent;

					var getCenterX = FlxG.width;//boyfriend.getMidpoint().x - (36 * 6);
					var getCenterY = FlxG.height;//boyfriend.getMidpoint().y - (24 * 6);
					switch (dadOpponent.curCharacter)
					{
					}

					camFollow.setPosition(getCenterX, getCenterY);

					if (char.curCharacter == 'mom')
						vocals.volume = 0.75;

					/*
						if (SONG.song.toLowerCase() == 'tutorial')
						{
							FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
						}
					 */
				}
				else
				{
					var char = boyfriend;

					var getCenterX = FlxG.width;//char.getMidpoint().x - (36 * 6);
					var getCenterY = FlxG.height;//char.getMidpoint().y - (24 * 6);
					switch (curStage)
					{
					}

					camFollow.setPosition(getCenterX, getCenterY);

					/*
						if (SONG.song.toLowerCase() == 'tutorial')
						{
							FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
						}
					 */
				}

				mustHit = PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection;
			}

			var easeLerp = 0.95;
			// camera stuffs
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom + forceZoom[0], FlxG.camera.zoom, easeLerp);
			for (hud in allUIs)
				hud.zoom = FlxMath.lerp(1 + forceZoom[1], hud.zoom, easeLerp);

			// not even forcezoom anymore but still
			FlxG.camera.angle = FlxMath.lerp(0 + forceZoom[2], FlxG.camera.angle, easeLerp);
			for (hud in allUIs)
				hud.angle = FlxMath.lerp(0 + forceZoom[3], hud.angle, easeLerp);

			if ((health <= 0 || gbHealth <= 0) && startedCountdown)
			{
				var screenCap = FlxScreenGrab.grab();
				// startTimer.active = false;
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				if (!isGameboy)
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
				else
				{
					var screenCap = FlxScreenGrab.grab();

					Main.switchState(this, new GameboyPowerdown(screenCap));
				}

				// discord stuffs should go here
			}

			// spawn in the notes from the array
			if ((unspawnNotes[0] != null) && ((unspawnNotes[0].strumTime - Conductor.songPosition) < 3500))
			{
				if (unspawnNotes[0].noteType == 0 && beatsUntilSpawn == 0 && unspawnNotes[0].mustPress && !unspawnNotes[0].isSustainNote) {
					unspawnNotes[0].noteType = (powerup == 0) ? 1 : 2;
					unspawnNotes[0].changeSkin();
					beatsUntilSpawn = -1;
				}

				var dunceNote:Note = unspawnNotes[0];

				// push note to its correct strumline
				strumLines.members[Math.floor((dunceNote.noteData + (dunceNote.mustPress ? 4 : 0)) / numberOfKeys)].push(dunceNote);
				unspawnNotes.splice(unspawnNotes.indexOf(dunceNote), 1);
			}

			for (extraNotes in extraCharts)
			{
				if ((extraNotes[0] != null) && ((extraNotes[0].strumTime - Conductor.songPosition) < 3500))
				{
					if (extraNotes[0].noteType == 0 && beatsUntilSpawn == 0 && extraNotes[0].mustPress && !extraNotes[0].isSustainNote) {
						extraNotes[0].noteType = (powerup == 0) ? 1 : 2;
						extraNotes[0].changeSkin();
						beatsUntilSpawn = -1;
					}

					extraNotes[0].noteAlt = 1;
					var dunceNote:Note = extraNotes[0];

					// push note to its correct strumline
					strumLines.members[Math.floor((dunceNote.noteData + (dunceNote.mustPress ? 4 : 0)) / numberOfKeys)].push(dunceNote);
					extraNotes.splice(extraNotes.indexOf(dunceNote), 1);
				}
			}

			noteCalls();

			if (SONG.song.toLowerCase() == "boo-blitz")
			{
				if (PlayState.SONG.notes[Std.int(curStep / 16)] != null)
				{
					platformerControls = !SONG.notes[Std.int(curStep / 16)].mustHitSection;
				}
				else
				{
					platformerControls = true;
				}

				if (!platformerControls)
				{
					boyfriend.flipX = false;
					boyfriend.animation.curAnim.frameRate = 12;
					bfVelocity = 0;
					if (isMovementAnim())
					{
						boyfriend.playAnim("idle");
					}
				}
			}
		}

		if (platformerControls)
		{
			boyfriendMovement(elapsed);
			bfHitbox.x = boyfriend.x - (1 * 6);
			bfHitbox.y = boyfriend.y - (3 * 6);
			
			if (boyfriend.flipX)
			{
				bfHitbox.x -= (2 * 6);
			}
		}

		if (beatsLeft > 0)
		{
			updateFireballs(elapsed);
		}
		else
		{
			nextFlip -= elapsed;
			if (nextFlip <= 0)
			{
				for (fireball in fireballs.members)
				{
					fireball.flipX = !fireball.flipX;
				}
				nextFlip = 0.075;
			}
		}

		if (fireballs.members[0].animation.name == 'shoot')
		{
			hitDetection();
		}

		var isMinus = SONG.song == 'Wrong-Warp';
		if (isMinus && !Init.trueSettings.get("Photosensitivity") && Std.int(Sys.time() * 1000) % 12 == 0)
		{
			if (FlxG.random.bool(8))
			{
				dadOpponent.alpha = 0;
				boyfriend.alpha = 0;
			}
			else
			{
				dadOpponent.alpha = 1;
				boyfriend.alpha = 1;
			}
		}

		if (isSMM)
		{
			dadOpponent2.animation.frameIndex = dadOpponent.animation.frameIndex;
			boyfriend2.animation.frameIndex = boyfriend.animation.frameIndex;

			dadOpponent2.alpha = dadOpponent.alpha * 0.36;
			boyfriend2.alpha = boyfriend.alpha * 0.36;
		}

		if (isSonic)
		{
			dadOpponent2.x = Std.int(tailsPos.x / 6) * 6;
			dadOpponent2.y = Std.int(tailsPos.y / 6) * 6;

			dadOpponent2.x -= 2;

			boyfriend2.x = Std.int(luigiPos.x / 6) * 6;
			boyfriend2.y = Std.int(luigiPos.y / 6) * 6;

			boyfriend.x = Std.int(marioPos.x / 6) * 6;
			boyfriend.y = Std.int(marioPos.y / 6) * 6;
		}
	}

	function hiddenChartUpdate()
	{
		// hidden charts
		for (currentBGChart in 0...secretFunnyCharts.length)
		{
			// among us or somethig liek that god help me i havent slept in like 24 hours
			if (secretFunnyCharts[currentBGChart][0] != null)
			{
				var noteData = secretFunnyCharts[currentBGChart][0];

				if (noteData.strumTime <= Conductor.songPosition)
				{
					var playerCharacter = boyfriend; // for must hit sections
					var enemyCharacter = dadOpponent; // for not those

					// hey maker you can change the charactrers depedning on song here your welcoem asfnbjifak

					// player char
					switch (secretFunnyCharacters[currentBGChart][0]) {
						case "luigi":
							playerCharacter = boyfriend2;
					}

					// enemy char
					switch (secretFunnyCharacters[currentBGChart][1]) {
						case "tails":
							enemyCharacter = dadOpponent2;
						case "bullet":
							stageBuild.blasterBro.animation.play('shoot', true);
							enemyCharacter = null;
					}

					// awesome
					var chosenCharacter = enemyCharacter;
					if (noteData.mustPress)
						chosenCharacter = playerCharacter;
					
					if (chosenCharacter != null)
						characterPlayAnimation(noteData, chosenCharacter);
					
					secretFunnyCharts[currentBGChart].splice(secretFunnyCharts[currentBGChart].indexOf(noteData), 1);
				}
			}
		}
	}

	function noteCalls()
	{
		// (control stuffs don't go here they go in noteControls(), I just have them here so I don't call them every. single. time. noteControls() is called)
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var holdControls = [left, down, up, right];
		var pressControls = [leftP, downP, upP, rightP];
		var releaseControls = [leftR, downR, upR, rightR];

		if (disableControls)
		{
			holdControls = [false, false, false, false];
			pressControls = [false, false, false, false];
			releaseControls = [false, false, false, false];
		}

		// reset strums
		for (strumline in strumLines)
		{
			// strumline.autoplay = true;
			// handle strumline stuffs
			var i = 0;
			for (uiNote in strumline.receptors)
			{
				if (strumline.autoplay)
					strumCallsAuto(uiNote);
			}

			if (strumline.splashNotes != null)
				for (i in 0...strumline.splashNotes.length)
				{
					strumline.splashNotes.members[i].x = strumline.receptors.members[i].x - 48;
					strumline.splashNotes.members[i].y = strumline.receptors.members[i].y - 56;
				}
		}

		// if the song is generated
		if (generatedMusic && startedCountdown)
		{
			for (strumline in strumLines)
			{
				if (!strumline.autoplay)
					controlPlayer(strumline.character, strumline.autoplay, strumline, holdControls, pressControls, releaseControls);
				else if (strumline.character == boyfriend)
				{

					if ((boyfriend != null && boyfriend.animation != null)
						&& (boyfriend.holdTimer > Conductor.stepCrochet * (4 / 1000)))
					{
						if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
							boyfriend.dance();
					}
					
					if (isSonic)
					{
						if ((boyfriend2 != null && boyfriend2.animation != null)
							&& (boyfriend2.holdTimer > Conductor.stepCrochet * (4 / 1000)))
						{
							if (boyfriend2.animation.curAnim.name.startsWith('sing') && !boyfriend2.animation.curAnim.name.endsWith('miss'))
								boyfriend2.dance();
						}
					}

				}

				strumline.notesGroup.forEachAlive(function(daNote:Note)
				{
					// set the notes x and y
					var downscrollMultiplier = 1;
					if (Init.trueSettings.get('Downscroll'))
						downscrollMultiplier = -1;

					var roundedSpeed = FlxMath.roundDecimal(daNote.noteSpeed, 2);
					var receptorPosY:Float = strumline.receptors.members[Math.floor(daNote.noteData)].y + Note.swagWidth / 6;
					var psuedoY:Float = (downscrollMultiplier * -((Conductor.songPosition - daNote.strumTime) * (0.45 * roundedSpeed)));
					var psuedoX = 25 + daNote.noteVisualOffset;

					daNote.y = strumline.receptors.members[Math.floor(daNote.noteData)].y
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX);
					// painful math equation
					daNote.x = strumline.receptors.members[Math.floor(daNote.noteData)].x
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY);

					if (daNote != null && daNote.animation != null && daNote.animation.curAnim != null && daNote.isSustainNote)
					{
						// note alignments (thanks pixl for pointing out what made old downscroll weird)
						if ((daNote.animation.curAnim.name.endsWith('holdend')) && (daNote.prevNote != null))
						{
							if (Init.trueSettings.get('Downscroll'))
								daNote.y += (daNote.prevNote.height);
							else
								daNote.y -= ((daNote.prevNote.height / 2));
						}
						else
							daNote.y -= ((daNote.height / 2) * downscrollMultiplier);
						if (Init.trueSettings.get('Downscroll'))
							daNote.flipY = true;
					}

					// also set note rotation
					daNote.angle = -daNote.noteDirection;

					// hell breaks loose here, we're using nested scripts!
					mainControls(daNote, strumline.character, strumline, strumline.autoplay);

					// check where the note is and make sure it is either active or inactive
					if (daNote.y > FlxG.height)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}

					if (daNote.noteType == 4 || daNote.noteType == 5 || daNote.noteType == 6)
					{
						daNote.visible = false;
					}

					// if the note is off screen (above)
					if (((!Init.trueSettings.get('Downscroll')) && (daNote.y < -daNote.height))
						|| ((Init.trueSettings.get('Downscroll')) && (daNote.y > (FlxG.height + daNote.height))))
					{
						if ((daNote.tooLate || !daNote.wasGoodHit) && (daNote.mustPress) && (daNote.noteType != 3) && !strumline.autoplay)
						{
							vocals.volume = 0;
							missNoteCheck((Init.trueSettings.get('Ghost Tapping') || platformerControls) ? true : false, daNote.noteData, boyfriend, true);
							// ambiguous name
							Timings.updateAccuracy(0);
						}

						daNote.active = false;
						daNote.visible = false;

						// note damage here I guess
						daNote.kill();
						if (strumline.notesGroup.members.contains(daNote))
							strumline.notesGroup.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
		}
	}

	function controlPlayer(character:Character, autoplay:Bool, characterStrums:Strumline, holdControls:Array<Bool>, pressControls:Array<Bool>,
			releaseControls:Array<Bool>)
	{
		if (!autoplay)
		{
			// check if anything is pressed
			if (pressControls.contains(true))
			{
				// check all of the controls
				for (i in 0...pressControls.length)
				{
					// and if a note is being pressed
					if (pressControls[i])
					{
						// improved this a little bit, maybe its a lil
						var possibleNoteList:Array<Note> = [];
						var pressedNotes:Array<Note> = [];

						characterStrums.notesGroup.forEachAlive(function(daNote:Note)
						{
							if ((daNote.noteData == i) && daNote.canBeHit && !daNote.tooLate && !daNote.wasGoodHit)
								possibleNoteList.push(daNote);
						});
						possibleNoteList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

						// if there is a list of notes that exists for that control
						if (possibleNoteList.length > 0)
						{
							var eligable = true;
							var firstNote = true;
							// loop through the possible notes
							for (coolNote in possibleNoteList)
							{
								for (noteDouble in pressedNotes)
								{
									if (Math.abs(noteDouble.strumTime - coolNote.strumTime) < 10)
										firstNote = false;
									else
										eligable = false;
								}

								if (eligable)
								{
									goodNoteHit(coolNote, character, characterStrums, firstNote); // then hit the note
									pressedNotes.push(coolNote);
								}
								// end of this little check
							}
							//
						}
						else // else just call bad notes
							if (!Init.trueSettings.get('Ghost Tapping') && !platformerControls)
								missNoteCheck(true, i, character, true);
					}
					//
				}
			}

			// check if anything is held
			if (holdControls.contains(true))
			{
				// check notes that are alive
				characterStrums.notesGroup.forEachAlive(function(coolNote:Note)
				{
					if (coolNote.canBeHit && coolNote.mustPress && coolNote.isSustainNote && holdControls[coolNote.noteData])
						goodNoteHit(coolNote, character, characterStrums);
				});
			}

			// control camera movements
			// strumCameraRoll(characterStrums, true);

			characterStrums.receptors.forEach(function(strum:UIStaticArrow)
			{
				if ((pressControls[strum.ID]) && (strum.animation.curAnim.name != 'confirm'))
					strum.playAnim('pressed');
				if (releaseControls[strum.ID])
					strum.playAnim('static');
				//
			});
		}

		// reset bf's animation
		if ((character != null && character.animation != null)
			&& (character.holdTimer > Conductor.stepCrochet * (4 / 1000) && (!holdControls.contains(true) || autoplay)))
		{
			if (character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss'))
				character.dance();
		}

		if (isSonic)
		{
			if ((boyfriend2 != null && boyfriend2.animation != null)
				&& (boyfriend2.holdTimer > Conductor.stepCrochet * (4 / 1000) && (!holdControls.contains(true) || autoplay)))
			{
				if (boyfriend2.animation.curAnim.name.startsWith('sing') && !boyfriend2.animation.curAnim.name.endsWith('miss'))
					boyfriend2.dance();
			}
		}
	}

	function goodNoteHit(coolNote:Note, character:Character, characterStrums:Strumline, ?canDisplayJudgement:Bool = true)
	{
		if (!coolNote.wasGoodHit)
		{
			coolNote.wasGoodHit = true;
			vocals.volume = 0.75;

			if (coolNote.noteType != 3 && coolNote.noteType != 4 && coolNote.noteType != 5)
			{
				if ((character == boyfriend && bfAnimLock < 0.35) || (character != boyfriend && ddAnimLock < 0.35))
				{
					var animChar = character;
					if (isSonic && coolNote.noteAlt == 1)
					{
						coolNote.noteAlt = 0;
						if (animChar == boyfriend)
						{
							animChar = boyfriend2;
						}
						else
						{
							animChar = dadOpponent2;
						}
					}
					characterPlayAnimation(coolNote, animChar);

					if (characterStrums.receptors.members[coolNote.noteData] != null)
						characterStrums.receptors.members[coolNote.noteData].playAnim('confirm', true);
				}
			}

			if (coolNote.noteType == 4 || coolNote.noteType == 5)
			{
				if (coolNote.noteType == 5)
				{
					if ((isHorizontal && !horizontalBridge.visible) || (!isHorizontal && !verticalBridge.visible))
					{
						isHorizontal = !isHorizontal;
					}
					bfAnimLock = 0.5;
					boyfriend.animation.play("shoot");
					stageBuild.bfParticles.animation.play("shoot");
				}
				else
				{
					ddAnimLock = 0.5;
					dadOpponent.animation.play("shoot");
					stageBuild.mParticles.animation.play("shoot");
				}

				if (isHorizontal)
				{
					horizontalBridge.y = FlxG.random.int(32, 96) * 6;
					horizontalBridge.visible = (coolNote.noteType == 4);
				}
				else
				{
					verticalBridge.x = FlxG.random.int(96, 160) * 6;
					verticalBridge.visible = (coolNote.noteType == 4);
				}
	
				isHorizontal = !isHorizontal;
			}

			if (coolNote.noteType == 6)
			{
				boyfriend.animation.play("hey");
				dadOpponent.animation.play("hey");
				stageBuild.enemyVelocity = -325;
				stageBuild.enemyY -= 1;

				bfAnimLock = 0.5;
				ddAnimLock = 0.5;
			}

			if (canDisplayJudgement)
			{
				// special thanks to sam, they gave me the original system which kinda inspired my idea for this new one

				// get the note ms timing
				var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition);
				// trace(noteDiff);
				// get the timing
				if (coolNote.strumTime < Conductor.songPosition)
					ratingTiming = "late";
				else
					ratingTiming = "early";

				// loop through all avaliable judgements
				var foundRating:String = 'miss';
				var lowestThreshold:Float = Math.POSITIVE_INFINITY;
				for (myRating in Timings.judgementsMap.keys())
				{
					var myThreshold:Float = Timings.judgementsMap.get(myRating)[1];
					if (noteDiff <= myThreshold && (myThreshold < lowestThreshold))
					{
						foundRating = myRating;
						lowestThreshold = myThreshold;
					}
				}

				if (!coolNote.isSustainNote)
				{
					if (coolNote.noteType < 3)
					{
						increaseCombo(foundRating, coolNote.noteData, character);
						popUpScore(foundRating, ratingTiming, characterStrums, coolNote);

						if (coolNote.noteType > 0 && powerup < 2)
						{
							FlxG.sound.play(Paths.sound('powerup'), 1);
							powerup = Std.int(coolNote.noteType);
							powerupVisuals(boyfriend.animation.name);
						}

						if (isGameboy)
							healthCall(Timings.judgementsMap.get(foundRating)[5]);
					}
					else
					{
						missNoteCheck(true, coolNote.noteData, character, false, true);
					}
				}
				else if (coolNote.isSustainNote)
				{
					// call updated accuracy stuffs
					Timings.updateAccuracy(100, true);
					if (coolNote.animation.name.endsWith('holdend') && isGameboy)
						healthCall(100);
				}
			}

			if (!coolNote.isSustainNote)
			{
				// coolNote.callMods();
				coolNote.kill();
				if (characterStrums.notesGroup.members.contains(coolNote))
					characterStrums.notesGroup.remove(coolNote, true);
				coolNote.destroy();
			}
			//
		}
	}

	function missNoteCheck(?includeAnimation:Bool = false, direction:Int = 0, character:Character, popMiss:Bool = false, lockMiss:Bool = false)
	{
		if (includeAnimation)
		{
			var stringDirection:String = UIStaticArrow.getArrowFromNumber(direction);
			character.playAnim('sing' + stringDirection.toUpperCase() + 'miss', lockMiss);
		}
		if (boyfriend.curCharacter == "luigi-player" || boyfriend.curCharacter == "bf-camera")
			powerup = 0;
		decreaseCombo(popMiss);

		//
	}

	function characterPlayAnimation(coolNote:Note, character:Character)
	{
		// alright so we determine which animation needs to play
		// get alt strings and stuffs
		var stringArrow:String = '';
		var altString:String = '';

		var baseString = 'sing' + UIStaticArrow.getArrowFromNumber(coolNote.noteData).toUpperCase();

		// I tried doing xor and it didnt work lollll
		if (coolNote.noteAlt > 0)
			altString = '-alt';
		if (((SONG.notes[Math.floor(curStep / 16)] != null) && (SONG.notes[Math.floor(curStep / 16)].altAnim))
			&& (character.animOffsets.exists(baseString + '-alt')))
		{
			if (altString != '-alt')
				altString = '-alt';
			else
				altString = '';
		}

		stringArrow = baseString + altString;
		// if (coolNote.foreverMods.get('string')[0] != "")
		//	stringArrow = coolNote.noteString;

		character.playAnim(stringArrow, true);
		character.holdTimer = 0;
	}

	private function strumCallsAuto(cStrum:UIStaticArrow, ?callType:Int = 1, ?daNote:Note):Void
	{
		switch (callType)
		{
			case 1:
				// end the animation if the calltype is 1 and it is done
				if ((cStrum.animation.finished) && (cStrum.canFinishAnimation))
					cStrum.playAnim('static');
			default:
				// check if it is the correct strum
				if (daNote.noteData == cStrum.ID)
				{
					// if (cStrum.animation.curAnim.name != 'confirm')
					cStrum.playAnim('confirm'); // play the correct strum's confirmation animation (haha rhymes)

					// stuff for sustain notes
					if ((daNote.isSustainNote) && (!daNote.animation.curAnim.name.endsWith('holdend')))
						cStrum.canFinishAnimation = false; // basically, make it so the animation can't be finished if there's a sustain note below
					else
						cStrum.canFinishAnimation = true;
				}
		}
	}

	private function mainControls(daNote:Note, char:Character, strumline:Strumline, autoplay:Bool):Void
	{
		var notesPressedAutoplay = [];
		// I have no idea what I have done
		var downscrollMultiplier = 1;
		if (Init.trueSettings.get('Downscroll'))
			downscrollMultiplier = -1;

		// im very sorry for this if condition I made it worse lmao
		///*
		if (daNote.isSustainNote
			&& (((daNote.y + daNote.offset.y <= (strumline.receptors.members[Math.floor(daNote.noteData)].y + Note.swagWidth / 2))
			&& !Init.trueSettings.get('Downscroll'))
			|| (((daNote.y - (daNote.offset.y * daNote.scale.y) + daNote.height)
			>= (strumline.receptors.members[Math.floor(daNote.noteData)].y + Note.swagWidth / 2))
			&& Init.trueSettings.get('Downscroll')))
			&& (autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
		{
			var swagRectY = ((strumline.receptors.members[Math.floor(daNote.noteData)].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y);
			var swagRect = new FlxRect(0, 0, daNote.width * 2, daNote.height * 2);
			// I feel genuine pain
			// basically these should be flipped based on if it is downscroll or not
			if (Init.trueSettings.get('Downscroll'))
			{
				swagRect.height = swagRectY;
				// I'm literally a dumbass
				swagRect.y += swagRect.height - daNote.height;
			}
			else
			{
				swagRect.y = swagRectY;
				swagRect.height -= swagRect.y;
			}

			daNote.clipRect = swagRect;
		}
		// */

		// here I'll set up the autoplay functions
		if (autoplay)
		{
			// check if the note was a good hit
			if (daNote.strumTime <= Conductor.songPosition && daNote.noteType != 3)
			{
				// use a switch thing cus it feels right idk lol
				// make sure the strum is played for the autoplay stuffs
				/*
					charStrum.forEach(function(cStrum:UIStaticArrow)
					{
						strumCallsAuto(cStrum, 0, daNote);
					});
				 */

				// kill the note, then remove it from the array
				var canDisplayJudgement = false;
				if (strumline.displayJudgements)
				{
					canDisplayJudgement = true;
					for (noteDouble in notesPressedAutoplay)
					{
						if (noteDouble.noteData == daNote.noteData)
						{
							// if (Math.abs(noteDouble.strumTime - daNote.strumTime) < 10)
							canDisplayJudgement = false;
							// removing the fucking check apparently fixes it
							// god damn it that stupid glitch with the double judgements is annoying
						}
						//
					}
					notesPressedAutoplay.push(daNote);
				}

				goodNoteHit(daNote, char, strumline, canDisplayJudgement);
			}
			//
		}

		// unoptimised asf camera control based on strums
		strumCameraRoll(strumline.receptors, daNote.mustPress);
	}

	private function strumCameraRoll(cStrum:FlxTypedGroup<UIStaticArrow>, mustHit:Bool)
	{
		if (!Init.trueSettings.get('No Camera Note Movement'))
		{
			var camDisplaceExtend:Float = 1.5;
			var camDisplaceSpeed = 0.0125;
			if (PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if ((PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && mustHit)
					|| (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && !mustHit))
				{
					if ((cStrum.members[0].animation.curAnim.name == 'confirm') && (camDisplaceX > -camDisplaceExtend))
						camDisplaceX -= camDisplaceSpeed;
					else if ((cStrum.members[3].animation.curAnim.name == 'confirm') && (camDisplaceX < camDisplaceExtend))
						camDisplaceX += camDisplaceSpeed;
				}
			}
		}
		//
	}

	override public function onFocus():Void
	{
		if (!paused)
			updateRPC(false);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		updateRPC(true);
		super.onFocusLost();
	}

	public static function updateRPC(pausedRPC:Bool)
	{
		#if !html5
		var displayRPC:String = (pausedRPC) ? detailsPausedText : songDetails.toUpperCase();

		if (health > 0 && gbHealth > 0)
		{
			if (Conductor.songPosition > 0 && !pausedRPC)
				Discord.changePresence(displayRPC, detailsSub, iconRPC, true, songLength - Conductor.songPosition);
			else
				Discord.changePresence(displayRPC, detailsSub, iconRPC);
		}
		#end
	}

	var animationsPlay:Array<Note> = [];

	private var ratingTiming:String = "";

	function popUpScore(baseRating:String, timing:String, strumline:Strumline, coolNote:Note)
	{
		// set up the rating
		var score:Int = 50;

		// notesplashes
		if (baseRating == "sick")
			// create the note splash if you hit a sick
			createSplash(coolNote, strumline);
		else
 			// if it isn't a sick, and you had a sick combo, then it becomes not sick :(
			if (allSicks)
				allSicks = false;

		displayRating(baseRating, timing);
		Timings.updateAccuracy(Timings.judgementsMap.get(baseRating)[3]);
		score = Std.int(Timings.judgementsMap.get(baseRating)[2]);

		songScore += score;

		popUpCombo();
	}

	public function createSplash(coolNote:Note, strumline:Strumline)
	{
		// play animation in existing notesplashes
		var noteSplashRandom:String = (Std.string((FlxG.random.int(0, 1) + 1)));
		if (strumline.splashNotes != null)
			strumline.splashNotes.members[coolNote.noteData].playAnim('anim' + noteSplashRandom);
	}

	private var createdColor = FlxColor.fromRGB(204, 66, 66);

	function popUpCombo(?preload:Bool = false)
	{
		var comboString:String = Std.string(combo);
		var negative = false;
		if ((comboString.startsWith('-')) || (combo == 0))
			negative = true;
		var stringArray:Array<String> = comboString.split("");
		// deletes all combo sprites prior to initalizing new ones
		if (lastCombo != null)
		{
			while (lastCombo.length > 0)
			{
				lastCombo[0].kill();
				lastCombo.remove(lastCombo[0]);
			}
		}

		for (scoreInt in 0...stringArray.length)
		{
			// numScore.loadGraphic(Paths.image('UI/' + pixelModifier + 'num' + stringArray[scoreInt]));
			var numScore = ForeverAssets.generateCombo('combo', stringArray[scoreInt], (!negative ? allSicks : false), assetModifier, changeableSkin, 'UI',
				negative, createdColor, scoreInt);
			add(numScore);
			// hardcoded lmao
			if (!Init.trueSettings.get('Simply Judgements'))
			{
				add(numScore);
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.kill();
					},
					startDelay: Conductor.crochet * 0.002
				});
			}
			else
			{
				add(numScore);
				// centers combo
				numScore.y += 10;
				numScore.x -= 95;
				numScore.x -= ((comboString.length - 1) * 22);
				lastCombo.push(numScore);
				FlxTween.tween(numScore, {y: numScore.y + 20}, 0.1, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});
			}
			if (preload)
				numScore.visible = false;
			// hardcoded lmao
			if (Init.trueSettings.get('Fixed Judgements'))
			{
				numScore.cameras = [camHUD];
				numScore.y += 50;
			}
				numScore.x += 100;
		}
	}

	function powerupVisuals(animation:String)
	{
		var prefix = bfPrefix;
		var prefixMatches = (prefix == 'bf');
		if (prefix == "bf-glitch" || prefix == "bf-smm")
		{
			prefixMatches = true;
		}

		if (prefixMatches && powerup == 0 && boyfriend.curCharacter != (prefix + '-small'))
		{
			boyfriend.x -= 5;
			boyfriend.y -= 4;
		}

		if (prefixMatches && powerup != 0 && boyfriend.curCharacter == (prefix + '-small'))
		{
			boyfriend.x += 5;
			boyfriend.y += 4;
		}

		switch (powerup)
		{
			case 0:
				boyfriend.setCharacter(boyfriend.x, boyfriend.y, prefix + "-small");
				if (curSong != '2-PLAYER-GAME')
					beatsUntilSpawn = 24;
			case 1:
				boyfriend.setCharacter(boyfriend.x, boyfriend.y, prefix);
				if (curSong != '2-PLAYER-GAME')
					beatsUntilSpawn = 48;
			case 2:
				boyfriend.setCharacter(boyfriend.x, boyfriend.y, prefix + "-fire");
				beatsUntilSpawn = -1;
		}

		if (isSMM)
		{
			boyfriend2.setCharacter(boyfriend.x + (2 * 6), boyfriend.y + (2 * 6), boyfriend.curCharacter);
		}
		boyfriend.playAnim(animation);
	}

	function powerupCall()
	{
		if (damageCooldown <= 0)
			damageCooldown = 2;

		powerup--;
		if (powerup < 0)
		{
			boyfriend2.visible = false;

			// startTimer.active = false;
			persistentUpdate = false;
			//persistentDraw = false;
			paused = true;
			resetMusic();
			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		} 
		else
		{
			FlxG.sound.play(Paths.sound('power_down'), 1);
			powerupVisuals(boyfriend.animation.name);
		}
	}

	function decreaseCombo(?popMiss:Bool = false)
	{
		// painful if statement
		if (((combo > 5) || (combo < 0)) && (gf.animOffsets.exists('sad')))
			gf.playAnim('sad');

		if (combo > 0)
			combo = 0; // bitch lmao
		else
			combo--;

		// misses
		songScore -= 10;
		misses++;

		if (damageCooldown <= 0 && !isGameboy)
			powerupCall();
			stageBuild.missAnim();

		// display negative combo
		if (popMiss)
		{
			// doesnt matter miss ratings dont have timings
			displayRating("miss", 'late');
			if (isGameboy)
				healthCall(Timings.judgementsMap.get("miss")[3]);
		}
		popUpCombo();

		// gotta do it manually here lol
		Timings.updateFCDisplay();
	}

	function increaseCombo(?baseRating:String, ?direction = 0, ?character:Character)
	{
		// trolled this can actually decrease your combo if you get a bad/shit/miss
		if (baseRating != null)
		{
			if (Timings.judgementsMap.get(baseRating)[3] > 0)
			{
				if (combo < 0)
					combo = 0;
				combo += 1;
			}
			else
				missNoteCheck(true, direction, character, false, true);
		}
	}

	public function displayRating(daRating:String, timing:String, ?cache:Bool = false)
	{
		/* so you might be asking
			"oh but if the rating isn't sick why not just reset it"
			because miss judgements can pop, and they dont mess with your sick combo
		 */
		var rating = ForeverAssets.generateRating('$daRating', (daRating == 'sick' ? allSicks : false), timing, assetModifier, changeableSkin, 'UI');
		add(rating);

		if (boyfriend != null)
		{
			rating.x = boyfriend.x - (12 * 6);
			rating.y = boyfriend.y;
		}

		if (!Init.trueSettings.get('Simply Judgements'))
		{
			if (lastRating != null)
			{
				lastRating.kill();
			}
			add(rating);
			lastRating = rating;
			FlxTween.tween(rating, {alpha: 1}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					rating.kill();
				},
				startDelay: Conductor.crochet * 0.00125
			});
		}
		else
		{
			if (lastRating != null)
			{
				lastRating.kill();
			}
			add(rating);
			lastRating = rating;
			FlxTween.tween(rating, {y: rating.y + 20}, 0.2, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});
			FlxTween.tween(rating, {"scale.x": 0, "scale.y": 0}, 0.1, {
				onComplete: function(tween:FlxTween)
				{
					rating.kill();
				},
				startDelay: Conductor.crochet * 0.00125
			});
		}
		// */

		if (Init.trueSettings.get('Fixed Judgements'))
		{
			// bound to camera
			rating.cameras = [camHUD];
			rating.screenCenter();
		}

		if (ratingPos != null)
			ratingPos.y = rating.y;

		if (isGameboy)
		{
			lastRating.x = 84 * 6;
			lastRating.y = 83 * 6;
			lastRating.y += 1;

			if (Init.trueSettings.get('Downscroll'))
			{
				lastRating.y = -10 * 6;
				lastRating.y += 1;
			}
		}

		// return the actual rating to the array of judgements
		Timings.gottenJudgements.set(daRating, Timings.gottenJudgements.get(daRating) + 1);

		// set new smallest rating
		if (Timings.smallestRating != daRating) {
			if (Timings.judgementsMap.get(Timings.smallestRating)[0] < Timings.judgementsMap.get(daRating)[0])
				Timings.smallestRating = daRating;
		}

		if (cache)
			rating.visible = false;
		
	}

	function healthCall(?ratingMultiplier:Float = 0)
	{
		// health += 0.012;
		var healthBase:Float = 0.06;
		gbHealth += (healthBase * (ratingMultiplier / 100));
	}

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			songMusic.play();
			songMusic.onComplete = endSong;
			vocals.play();

			resyncVocals();

			#if !html5
			// Song duration in a float, useful for the time left feature
			songLength = songMusic.length;

			// Updating Discord Rich Presence (with Time Left)
			updateRPC(false);
			#end
		}
	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		songDetails = CoolUtil.dashToSpace(SONG.song);
		if (songDetails == 'Hop Hop Heights')
		{
			songDetails = 'Hop-Hop Heights';
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + songDetails;

		// set details for song stuffs
		detailsSub = "";

		// Updating Discord Rich Presence.
		updateRPC(false);

		curSong = songData.song;
		if (curSong == '2-PLAYER-GAME')
		{
			powerup = 1;
			powerupVisuals("idle");
		}

		songMusic = new FlxSound().loadEmbedded(Sound.fromFile('./' + Paths.inst(SONG.song)), false, true);
		songMusic.volume = 0.75;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Sound.fromFile('./' + Paths.voices(SONG.song)), false, true);
		else
			vocals = new FlxSound();
		vocals.volume = 0.75;

		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);

		// generate the chart
		unspawnNotes = ChartLoader.generateChartType(SONG, determinedChartType);
		// sometime my brain farts dont ask me why these functions were separated before

		// load external charts
		// stole from shubs i am tird 
		#if windows 
		var existingCharts = CoolUtil.returnAssetsLibrary('external', 'assets/songs/' + SONG.song);
		trace(existingCharts);

		if (existingCharts != null) {
			for (i in 0...existingCharts.length)
			{
				var thisSong = existingCharts[i].substring(0, existingCharts[i].indexOf("."));
				var epicSwagSong:SwagSong = Song.loadFromJson("external/" + thisSong, SONG.song);
				secretFunnyCharts[i] = ChartLoader.generateChartType(epicSwagSong);
				secretFunnyCharacters[i] = [epicSwagSong.player1, epicSwagSong.player2];

				// sort through them
				secretFunnyCharts[i].sort(sortByShit);
			}
		}
                #end 
		// sort through them
		unspawnNotes.sort(sortByShit);
		// give the game the heads up to be able to start
		generatedMusic = true;

		Timings.accuracyMaxCalculation(unspawnNotes);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function resyncVocals():Void
	{
		vocals.pause();

		songMusic.play();
		Conductor.songPosition = songMusic.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	override function stepHit()
	{
		super.stepHit();

		///*
		if (Math.abs(songMusic.time - Conductor.songPosition) > 20
		|| (SONG.needsVoices && Math.abs(vocals.time - Conductor.songPosition) > 20))
			resyncVocals();
		//*/

		if (curStep % 4 == 0)
		{
			resyncVocals();
		}

		if (curStep == 79.75 * 4 && curSong == 'Cross-Console-Clash')
		{
			dadOpponent.playAnim("hey");
			disableControls = true;
			depressStrums();

			dadOpponent.animation.finishCallback = function(s:String){
				dadOpponent.playAnim("loop");
				dadOpponent.animation.finishCallback = null;
			}
		}

		if (curStep == (81.5 * 4) && curSong == 'Cross-Console-Clash')
		{
			boyfriend.playAnim("hey", true);
		}

		if (curStep == 83.75 * 4 && curSong == 'Cross-Console-Clash')
		{
			disableControls = false;
		}
	}

	private function charactersDance(curBeat:Int)
	{
		if ((curBeat % gfSpeed == 0) && (gf.animation.curAnim.name.startsWith("dance")))
			gf.dance();
			stageBuild.dance();

		if (!platformerControls && boyfriend.animation.curAnim.name.startsWith("idle") && (curBeat % 2 == 0 || boyfriend.quickDancer))
			boyfriend.dance();

		// added this for opponent cus it wasn't here before and skater would just freeze
		if ((dadOpponent.animation.curAnim.name.startsWith("idle") || dadOpponent.animation.curAnim.name.startsWith("shy")) && (curBeat % 2 == 0 || dadOpponent.quickDancer))
			dadOpponent.dance();
		
		if (isSonic || isSMM)
		{
			if (boyfriend2.animation.curAnim.name.startsWith("idle") && (curBeat % 2 == 0 || boyfriend2.quickDancer))
				boyfriend2.dance();
	
			// added this for opponent cus it wasn't here before and skater would just freeze
			if (dadOpponent2.animation.curAnim.name.startsWith("idle") && (curBeat % 2 == 0 || dadOpponent2.quickDancer))
				dadOpponent2.dance();
		}
	}

	override function beatHit()
	{
		super.beatHit();

		// if ((FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) && (!Init.trueSettings.get('Reduced Movements')))
		// {
		// 	FlxG.camera.zoom += 0.015;
		// 	camHUD.zoom += 0.05;
		// 	for (hud in strumHUD)
		// 		hud.zoom += 0.05;
		// }

		if (beatsUntilSpawn > 0)
		{
			beatsUntilSpawn--;
			if (beatsUntilSpawn <= 0)
			{
				beatsUntilSpawn = 0;
			}
		}

		if (SONG.song.toLowerCase() == "boo-blitz")
		{
			if (beatsLeft > 0)
			{
				beatsLeft -= 1;
				if (beatsLeft <= 0)
				{
					shootFire();
				}
			}
			else
			{
				if (beatsLeft < 0)
				{
					if (fireballs.members[0].animation.name == 'shoot')
					{
						for (fireball in fireballs.members)
						{
							fireball.animation.play('retract');
						}
					}
				}
				else
				{
					beatsLeft -= 1;
				}
			}

			if (curBeat > 95 && fireSpots > 1)
			{
				fireSpots = 1;
			}

			if (curBeat % 8 == 0 && !SONG.notes[Std.int(curStep / 16)].mustHitSection && fireCooldown <= 0 && curBeat < 256)
			{
				spawnFireballs();
			}
		}

		if (SONG.song.toLowerCase() == "koopa-armada")
		{
			if (dadOpponent != null)
			{
				if (dadOpponent.animation.name == 'roarStart' && dadOpponent.animation.finished)
				{
					dadOpponent.playAnim('roar');
				}
				if (curBeat == 272)
				{
					roar();
					boyfriend.playAnim('hey');
				}
			}
		}

		if (SONG.song.toLowerCase() == "hop-hop-heights")
		{
			if (curBeat == 198)
			{
				dadOpponent.playAnim("explode");
				dadOpponent.y += 3 * 6;
				shakeIntensity = 4;
				shakeTime = 2;
			}
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
			}
		}

		if (isGameboy)
		{
			gameboyHUD.beatHit();
		}
		else if (isMari0)
		{
			mari0HUD.beatHit();
		}
		else if (isSMM)
		{
			smmHUD.beatHit();
		}
		else if (isSonic)
		{
			sonicHUD.beatHit();
		}
		else
		{
			uiHUD.beatHit();
		}

		if (curBeat == 96 && curSong == 'Hop-Hop-Heights')
		{
			dadOpponent.setCharacter(dadOpponent.x, dadOpponent.y, "bob-omb-lit");
		}
		if (curBeat == 164 && curSong == 'Destruction-Dance')
		{
			spikeDead = true;
			dadOpponent.playAnim("death");
			dadVelocity = -750;
			dadPos = dadOpponent.y;
			stageBuild.bomb.animation.play('boom');
		}
		if (curBeat == 175 && curSong == 'Destruction-Dance')
		{
			spikeDead = false;

			targetY = originalY + 56;
			dadOpponent.setCharacter(dadOpponent.x + 5, -128, "waluigi");
			dadPos = dadOpponent.y;
			dadOpponent.playAnim("singDOWN");
		}
		if (curBeat == 274 && curSong == 'Destruction-Dance')
		{
			bfDeathFake = new FlxSprite(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y).loadGraphic(Paths.image('characters/bf-dead'));
			bfDeathFake.setGraphicSize(Std.int(bfDeathFake.width * 6));
			bfDeathFake.antialiasing = false;
			bfDeathFake.cameras = [PlayState.strumHUD[PlayState.strumHUD.length - 1]];
			add(bfDeathFake);

			boyfriend.visible = false;
			fakeDeath = true;
			disableControls = true;
			depressStrums();
			bfDeathVelocity = -750;
			bfDeathPos = bfDeathFake.y;

			boyfriend.x = 1000000;

			stageBuild.bomb2.animation.play('boom');
		}

		if (curBeat == 150 && curSong == 'Cross-Console-Clash')
		{
			disableControls = true;
			depressStrums();
		}

		if (curBeat == 151 && curSong == 'Cross-Console-Clash')
		{
			marioBounces = 2;
			marioVelocity = -800;
			boyfriend.playAnim("jump");
			boyfriend.flipX = true;
		}
		
		if (curBeat == 152 && curSong == 'Cross-Console-Clash')
			dadOpponent.playAnim("wave", true);

		if (curBeat == 154 && curSong == 'Cross-Console-Clash')
			boyfriend.flipX = false;

		if (curBeat == 156 && curSong == 'Cross-Console-Clash')
		{
			dadOpponent2.playAnim("fly", true);
			FlxTween.tween(tailsPos, { x: tailsTarget.x - 16, y: tailsTarget.y }, 1.1, {ease: FlxEase.quadOut, onComplete: tailsLanded});
		}

		if (curBeat == 162 && curSong == 'Cross-Console-Clash')
		{
			boyfriend2.playAnim("jump", true);
			FlxTween.tween(luigiPos, { x: luigiTarget.x }, 0.5, {ease: FlxEase.quintOut});
			FlxTween.tween(luigiPos, { y: luigiTarget.y }, 0.3, {ease: FlxEase.sineIn, onComplete: luigiArrived});
		}

		//
		charactersDance(curBeat);

		// stage stuffs
		stageBuild.stageUpdate(curBeat, boyfriend, gf, dadOpponent);
	}

	public function tailsLanded(tween)
	{
		dadOpponent.playAnim('idle', true);
		dadOpponent2.playAnim('skid', true);
		FlxTween.tween(tailsPos, { x: tailsTarget.x }, 0.3, {ease: FlxEase.sineOut, onComplete: tailsArrived});
	}

	public function tailsArrived(tween)
	{
		dadOpponent2.playAnim('idle', true);
	}

	public function luigiArrived(tween)
	{
		boyfriend2.playAnim('idle', true);
		disableControls = false;
	}
	

	//
	//
	/// substate stuffs
	//
	//

	public static function resetMusic()
	{
		// simply stated, resets the playstate's music for other states and substates
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null)
			vocals.stop();
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			// trace('null song');
			if (songMusic != null)
			{
				//	trace('nulled song');
				songMusic.pause();
				vocals.pause();
				//	trace('nulled song finished');
			}

			// trace('ui shit break');
			if ((startTimer != null) && (!startTimer.finished))
				startTimer.active = false;
		}

		// trace('open substate');
		super.openSubState(SubState);
		// trace('open substate end ');
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (songMusic != null && !startingSong)
				resyncVocals();

			if ((startTimer != null) && (!startTimer.finished))
				startTimer.active = true;
			paused = false;

			///*
			updateRPC(false);
			// */
		}

		super.closeSubState();
	}

	/*
		Extra functions and stuffs
	 */
	/// song end function at the end of the playstate lmao ironic I guess
	private var endSongEvent:Bool = false;

	function endSong():Void
	{
		canPause = false;
		songMusic.volume = 0;
		vocals.volume = 0;

		var wasCompleted = Highscore.getData(SONG.song)[0] != 0;
		var allCompleted = true;

		Highscore.saveSongData(SONG.song, songScore, Timings.ratingIntFinal, Timings.comboDisplay);

		for (i in 0...Main.gameWeeks.length)
		{
			for (j in 0...Main.gameWeeks[i][0].length)
			{
				var songName = Main.gameWeeks[i][0][j];
				if (Highscore.getData(songName)[0] == 0)
				{
					allCompleted = false;
					break;
				}
			} 
		}

		if (allCompleted && !wasCompleted && SONG.song != 'Green-Screen' && SONG.song != 'balls')
		{
			Main.switchState(this, new CreditsState());
		}
		else
		{
			if (!isStoryMode)
			{
				Main.switchState(this, new FreeplayState());
			}
			else
			{
				// set the campaign's score higher
				campaignScore += songScore;

				// remove a song from the story playlist
				storyPlaylist.remove(storyPlaylist[0]);

				// set up transitions
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				switch (SONG.song.toLowerCase())
				{
					case 'lethal-lava-lair':
						CutsceneState.sceneNum = 6;
						Main.switchState(this, new CutsceneState());
					case 'koopa-armada':
						CutsceneState.sceneNum = 7;
						Main.switchState(this, new CutsceneState());
					default:
						// check if there aren't any songs left
						if ((storyPlaylist.length <= 0) && (!endSongEvent))
						{
							// play menu music
							ForeverTools.resetMenuMusic();

							// change to the menu state
							Main.switchState(this, new MainMenuState());

							// save the week's score if the score is valid
							if (SONG.validScore)
								Highscore.saveWeekScore(storyWeek, campaignScore);

							// flush the save
							FlxG.save.flush();
						}
						else
							songEndSpecificActions();
				}
			}
		}
		//
	}

	private function songEndSpecificActions()
	{
		switch (SONG.song.toLowerCase())
		{
			case 'eggnog':
				// make the lights go out
				var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
					-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				blackShit.scrollFactor.set();
				add(blackShit);
				camHUD.visible = false;

				// oooo spooky
				FlxG.sound.play(Paths.sound('Lights_Shut_off'));

				// call the song end
				var eggnogEndTimer:FlxTimer = new FlxTimer().start(Conductor.crochet / 1000, function(timer:FlxTimer)
				{
					callDefaultSongEnd();
				}, 1);
			default:
				callDefaultSongEnd();
		}
	}

	private function callDefaultSongEnd()
	{
		var difficulty:String = '-' + CoolUtil.difficultyFromNumber(storyDifficulty).toLowerCase();
		difficulty = difficulty.replace('-normal', '');

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		
		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
		ForeverTools.killMusic([songMusic, vocals]);
		switch(PlayState.SONG.song.toLowerCase()){
			case 'bricks-and-lifts':
				CutsceneState.sceneNum = 1;
				FlxG.switchState(new CutsceneState());
			case 'lethal-lava-lair':
				CutsceneState.sceneNum = 2;
				FlxG.switchState(new CutsceneState());
			case 'hop-hop-heights':
				CutsceneState.sceneNum = 4;
				FlxG.switchState(new CutsceneState());
			case 'koopa-armada':
				CutsceneState.sceneNum = 5;
				FlxG.switchState(new CutsceneState());
		}

		// deliberately did not use the main.switchstate as to not unload the assets
		//FlxG.switchState(new PlayState());
		
	}

	var dialogueBox:DialogueBox;

	public function songIntroCutscene()
	{
		switch (curSong.toLowerCase())
		{
			case "winter-horrorland":
				inCutscene = true;
				var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				add(blackScreen);
				blackScreen.scrollFactor.set();
				camHUD.visible = false;

				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					remove(blackScreen);
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					camFollow.y = -2050;
					camFollow.x += 200;
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}

						});

					});
				});
			case 'roses':
				// the same just play angery noise LOL
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
				callTextbox();
			case 'thorns':
				inCutscene = true;
				for (hud in allUIs)
					hud.visible = false;

				var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
				red.scrollFactor.set();

				var senpaiEvil:FlxSprite = new FlxSprite();
				senpaiEvil.frames = Paths.getSparrowAtlas('cutscene/senpai/senpaiCrazy');
				senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
				senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
				senpaiEvil.scrollFactor.set();
				senpaiEvil.updateHitbox();
				senpaiEvil.screenCenter();

				add(red);
				add(senpaiEvil);
				senpaiEvil.alpha = 0;
				new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
				{
					senpaiEvil.alpha += 0.15;
					if (senpaiEvil.alpha < 1)
						swagTimer.reset();
					else
					{
						senpaiEvil.animation.play('idle');
						FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
						{
							remove(senpaiEvil);
							remove(red);
							FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
							{
								for (hud in allUIs)
									hud.visible = true;
								callTextbox();
							}, true);
						});
						new FlxTimer().start(3.2, function(deadTime:FlxTimer)
						{
							FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
						});
					}
				});
			default:
				callTextbox();
		}
		//
	}

	function callTextbox() {
		var dialogPath = Paths.json(SONG.song.toLowerCase() + '/dialogue');
		if (sys.FileSystem.exists(dialogPath))
		{
			startedCountdown = false;

			dialogueBox = DialogueBox.createDialogue(sys.io.File.getContent(dialogPath));
			dialogueBox.cameras = [dialogueHUD];
			dialogueBox.whenDaFinish = startCountdown;

			add(dialogueBox);
		}
		else
			startCountdown();
	}

	public static function skipCutscenes():Bool {
		// pretty messy but an if statement is messier
		if (Init.trueSettings.get('Skip Text') != null
		&& Std.isOfType(Init.trueSettings.get('Skip Text'), String)) {
			switch (cast(Init.trueSettings.get('Skip Text'), String))
			{
				case 'never':
					return false;
				case 'freeplay only':
					if (!isStoryMode)
						return true;
					else
						return false;
				default:
					return true;
			}
		}

		return false;
	}

	public static var swagCounter:Int = 0;

	private function startCountdown():Void
	{
		var isMinus = SONG.song == 'Wrong-Warp';
		var sound1 = 'countdown';
		var sound2 = 'countdownend';
		var assetPath = 'UI/default/pixel/countdown';
		var soundVol = 0.5;

		if (isMinus)
		{
			sound1 = 'coin';
			sound2 = 'pause';
			assetPath = 'UI/default/pixel/countdown-glitched';
			soundVol = 1;
		}
		if (isGameboy)
		{
			assetPath = 'UI/default/gameboy/countdown';
		}
		if (isMari0)
		{
			assetPath = 'UI/default/mari0/countdown';
		}
		if (isSMM)
		{
			assetPath = 'UI/default/mari0/countdown';
		}
		if (isSonic)
		{
			sound1 = 'sonic_countdown';
			sound2 = 'sonic_countdownend';
			assetPath = 'UI/default/sonic/countdown';
			soundVol = 0.25;
		}

		inCutscene = false;
		Conductor.songPosition = -(Conductor.crochet * 7);
		swagCounter = 0;

		camHUD.visible = true;

		var animFPS = (isSonic) ? 9 : 0;
		var countdown:FlxSprite = new FlxSprite(0, 16 * 6).loadGraphic(Paths.image(assetPath), true, 33, 17);
		countdown.animation.add("3", [0, 4], animFPS, true);
		countdown.animation.add("2", [1, 5], animFPS, true);
		countdown.animation.add("1", [2, 6], animFPS, true);
		countdown.animation.add("go", [3, 7], animFPS, true);
		countdown.animation.play("3");

		countdown.setGraphicSize(Std.int(countdown.width * 6));
		countdown.antialiasing = false;
		countdown.visible = false;

		countdown.screenCenter(X);
		countdown.x = Std.int(countdown.x / 6) * 6;
		add(countdown);

		startTimer = new FlxTimer().start(Conductor.crochet / 500, function(tmr:FlxTimer)
		{
			startedCountdown = true;

			if (boyfriend != null)
			{
				charactersDance(curBeat);
			}

			switch (swagCounter)
			{
				case 0:
					countdown.visible = true;
					
					Conductor.songPosition = -(Conductor.crochet * 7);
					countdown.animation.play("3");
					FlxG.sound.play(Paths.sound(sound1), soundVol);
				case 1:
					Conductor.songPosition = -(Conductor.crochet * 5);
					countdown.animation.play("2");
					FlxG.sound.play(Paths.sound(sound1), soundVol);
				case 2:
					Conductor.songPosition = -(Conductor.crochet * 3);
					countdown.animation.play("1");
					FlxG.sound.play(Paths.sound(sound1), soundVol);
				case 3:
					Conductor.songPosition = -(Conductor.crochet * 1);
					countdown.animation.play("go");
					FlxG.sound.play(Paths.sound(sound2), soundVol);
				case 4:
					countdown.visible = false;
					canPause = true;
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}
}
