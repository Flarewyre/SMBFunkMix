package gameObjects;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameObjects.background.*;
import meta.CoolUtil;
import meta.data.Conductor;
import meta.data.dependency.FNFSprite;
import meta.state.PlayState;

using StringTools;

/**
	This is the stage class. It sets up everything you need for stages in a more organised and clean manner than the
	base game. It's not too bad, just very crowded. I'll be adding stages as a separate
	thing to the weeks, making them not hardcoded to the songs.
**/
class Stage extends FlxTypedGroup<FlxBasic>
{
	var halloweenBG:FNFSprite;
	var phillyCityLights:FlxTypedGroup<FNFSprite>;
	var phillyTrain:FNFSprite;
	var trainSound:FlxSound;

	public var limo:FNFSprite;

	public var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;

	var fastCar:FNFSprite;

	var upperBoppers:FNFSprite;
	var bottomBoppers:FNFSprite;
	var santa:FNFSprite;

	var enemy:FNFSprite;
	var enemies:FNFSprite;
	var enemies_shadow:FNFSprite;

	public var mParticles:FNFSprite;
	public var bfParticles:FNFSprite;

	var bgPlatform1:FNFSprite;
	var bgPlatform2:FNFSprite;

	var stars:FNFSprite;
	var stars2:FNFSprite;
	var coinsBack:FNFSprite;
	var coinsBack2:FNFSprite;
	var coinsFront:FNFSprite;
	var coinsFront2:FNFSprite;

	var starsPos:FlxPoint;
	var coinsBackPos:FlxPoint;
	var coinsFrontPos:FlxPoint;

	var waterBG:FNFSprite;
	var waterBG2:FNFSprite;
	var waterBGPos:FlxPoint;

	var cloudsBack:FNFSprite;
	var cloudsBack2:FNFSprite;
	var cloudsBackPos:FlxPoint;
	
	var cloudsFront:FNFSprite;
	var cloudsFront2:FNFSprite;
	var cloudsFrontPos:FlxPoint;

	var minusBG:FNFSprite;
	public var bomb:FNFSprite;
	public var bomb2:FNFSprite;

	var stormClouds:FNFSprite;
	var stormClouds2:FNFSprite;
	var stormCloudsPos:FlxPoint;
	public var gf:FNFSprite;
	public var blasterBro:FNFSprite;
	public var hands:FNFSprite;
	
	var terrain:FNFSprite;
	var terrain2:FNFSprite;
	var terrainPos:FlxPoint;
	var bfY:Float = (12 * 6) + (11*6);
	var billY:Float = (12 * 6) + (11*6);

	var billDelay:Float = 0;

	var bgGirls:BackgroundGirls;

	public var curStage:String;

	var daPixelZoom = PlayState.daPixelZoom;

	public var foreground:FlxTypedGroup<FlxBasic>;

	var moveMult:Float = 1;
	public var platformPos1:Float;
	public var platformPos2:Float;

	public var enemyX:Float;
	public var enemyY:Float;
	
	var ogX:Float;
	var ogY:Float;

	public var enemyVelocity:Float;
	var enemyType:Int;
	var beatsUntilRespawn:Int = 12;
	var spawned:Bool = false;

	var fireballs:Array<FNFSprite> = [];
	var fireballCenterX:Float;
	var fireballCenterY:Float;
	var fireballAngle:Float;

	var mVelocityX:Float = 0;
	var mVelocityY:Float = 0;
	var mSwimX:Float = 128 * 6;
	var mSwimY:Float = 16 * 6;
	var mSwimPower:Float = 1.85;
	var mSwimGravity:Float = 2.25;
	var swimThres:Float = 24 * 6;

	var bopLeft:Bool;
	var bopCooldown:Float;

	public function new(curStage)
	{
		super();
		this.curStage = curStage;

		starsPos = new FlxPoint();
		coinsBackPos = new FlxPoint();
		coinsFrontPos = new FlxPoint();
		waterBGPos = new FlxPoint();
		cloudsBackPos = new FlxPoint();
		cloudsFrontPos = new FlxPoint();
		stormCloudsPos = new FlxPoint();
		terrainPos = new FlxPoint(-160 * 2 * 6, 0);

		/// get hardcoded stage type if chart is fnf style
		if (PlayState.determinedChartType == "FNF")
		{
			// this is because I want to avoid editing the fnf chart type
			// custom stage stuffs will come with forever charts
			switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
			{
				default:
					curStage = 'overworld';
				case 'bricks-and-lifts':
					curStage = 'underground';
				case 'lethal-lava-lair':
					curStage = 'castle';
				case '2-player-game' | 'balls':
					curStage = 'sky';
				case 'deep-deep-voyage':
					curStage = 'water';
				case 'hop-hop-heights':
					curStage = 'athletic';
				case 'bullet-time':
					curStage = 'ice';
				case 'wrong-warp':
					curStage = 'minus';
				case 'green-screen':
					curStage = 'camera';
				case 'portal-power':
					curStage = 'test-chamber';
				case 'destruction-dance':
					curStage = 'wrecking-crew';
				case 'cross-console-clash':
					curStage = 'sonic';
				case 'first-level-:)':
					curStage = 'smm';
				case 'boo-blitz':
					curStage = 'ghost';
				case 'koopa-armada':
					curStage = 'airship';
			}

			PlayState.curStage = curStage;
		}

		// to apply to foreground use foreground.add(); instead of add();
		foreground = new FlxTypedGroup<FlxBasic>();

		//
		switch (curStage)
		{
			case 'overworld':
				curStage = 'overworld';

				var bg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'));
				bg.scrollFactor.set(1, 1);
				bg.antialiasing = false;
				bg.setGraphicSize(Std.int(bg.width * 6));
				bg.updateHitbox();
				add(bg);

				enemy = new FNFSprite(159 * 6, 41 * 6).loadGraphic(Paths.image('backgrounds/' + curStage + '/enemy'), true, 24, 24);
				enemy.animation.add("goomba", [0, 1], 6);
				enemy.animation.add("koopa-green", [2, 3], 6);
				enemy.animation.add("koopa-red", [4, 5], 6);
				enemy.animation.play("goomba");

				enemy.scrollFactor.set(1, 1);
				enemy.antialiasing = false;
				enemy.setGraphicSize(Std.int(enemy.width * 6));
				enemy.updateHitbox();
				enemy.visible = false;
				foreground.add(enemy);

				enemyX = enemy.x;
				enemyY = enemy.y;
				ogX = enemyX;
				ogY = enemyY;
			
			case 'underground':
				curStage = 'underground';

				var bg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'));
				bg.scrollFactor.set(1, 1);
				bg.antialiasing = false;
				bg.setGraphicSize(Std.int(bg.width * 6));
				bg.updateHitbox();
				add(bg);

				bgPlatform1 = new FNFSprite(-20 * 6, 24 * 6).loadGraphic(Paths.image('backgrounds/' + curStage + '/platform'));
				bgPlatform1.scrollFactor.set(1, 1);
				bgPlatform1.antialiasing = false;
				bgPlatform1.setGraphicSize(Std.int(bgPlatform1.width * 6));
				bgPlatform1.updateHitbox();

				bgPlatform1.x += 5;
				platformPos1 = bgPlatform1.y;
				add(bgPlatform1);

				bgPlatform2 = new FNFSprite(131 * 6, 84 * 6).loadGraphic(Paths.image('backgrounds/' + curStage + '/platform'));
				bgPlatform2.scrollFactor.set(1, 1);
				bgPlatform2.antialiasing = false;
				bgPlatform2.setGraphicSize(Std.int(bgPlatform2.width * 6));
				bgPlatform2.updateHitbox();

				bgPlatform2.x += 1;
				platformPos2 = bgPlatform2.y;
				add(bgPlatform2);

				var bricks:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bricks'));
				bricks.scrollFactor.set(1, 1);
				bricks.antialiasing = false;
				bricks.setGraphicSize(Std.int(bricks.width * 6));
				bricks.updateHitbox();
				foreground.add(bricks);
			
			case 'castle':
				curStage = 'castle';

				fireballCenterX = 77;
				fireballCenterY = 40;

				var bg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'));
				bg.scrollFactor.set(1, 1);
				bg.antialiasing = false;
				bg.setGraphicSize(Std.int(bg.width * 6));
				bg.updateHitbox();
				add(bg);

				var lava:FNFSprite = new FNFSprite(25 * 6, 68 * 6).loadGraphic(Paths.image('backgrounds/' + curStage + '/lava'), true, 112, 13);
				lava.animation.add("idle", [0, 1, 2, 3], 4);
				lava.animation.play("idle");

				lava.scrollFactor.set(1, 1);
				lava.antialiasing = false;
				lava.setGraphicSize(Std.int(lava.width * 6));
				lava.updateHitbox();
				add(lava);

				for (i in 0...6)
				{
					var fireball:FNFSprite = new FNFSprite(fireballCenterX * 6, (fireballCenterY - (i * 8)) * 6).loadGraphic(Paths.image('backgrounds/' + curStage + '/fireball'), true, 8, 8);
					fireball.animation.add("idle", [0, 1, 2, 3], 18);
					fireball.animation.play("idle");

					fireball.scrollFactor.set(1, 1);
					fireball.antialiasing = false;
					fireball.setGraphicSize(Std.int(fireball.width * 6));
					fireball.updateHitbox();
					add(fireball);
					fireballs.push(fireball);
				}
			
			case 'sky':
				curStage = 'sky';

				var bg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'));
				bg.scrollFactor.set(1, 1);
				bg.antialiasing = false;
				bg.setGraphicSize(Std.int(bg.width * 6));
				bg.updateHitbox();
				add(bg);

				stars = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/stars'));
				stars.scrollFactor.set(1, 1);
				stars.antialiasing = false;
				stars.setGraphicSize(Std.int(stars.width * 6));
				stars.updateHitbox();
				add(stars);
				stars2 = new FNFSprite(stars.width, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/stars'));
				stars2.scrollFactor.set(1, 1);
				stars2.antialiasing = false;
				stars2.setGraphicSize(Std.int(stars2.width * 6));
				stars2.updateHitbox();
				add(stars2);

				coinsBack = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/coins1'), true, 160, 80);
				coinsBack.scrollFactor.set(1, 1);
				coinsBack.antialiasing = false;
				coinsBack.setGraphicSize(Std.int(coinsBack.width * 6));
				coinsBack.updateHitbox();
				add(coinsBack);
				coinsBack2 = new FNFSprite(coinsBack.width, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/coins1'), true, 160, 80);
				coinsBack2.scrollFactor.set(1, 1);
				coinsBack2.antialiasing = false;
				coinsBack2.setGraphicSize(Std.int(coinsBack2.width * 6));
				coinsBack2.updateHitbox();
				add(coinsBack2);

				if (!Init.trueSettings.get("Photosensitivity"))
				{
					coinsBack.animation.add("idle", [0, 0, 0, 0, 0, 1, 2, 1], 9);
					coinsBack2.animation.add("idle", [0, 0, 0, 0, 0, 1, 2, 1], 9);
					coinsBack.animation.play("idle");
					coinsBack2.animation.play("idle");
				}

				coinsFront = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/coins2'), true, 160, 81);
				coinsFront.scrollFactor.set(1, 1);
				coinsFront.antialiasing = false;
				coinsFront.setGraphicSize(Std.int(coinsFront.width * 6));
				coinsFront.updateHitbox();
				add(coinsFront);
				coinsFront2 = new FNFSprite(coinsFront.width, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/coins2'), true, 160, 81);
				coinsFront2.scrollFactor.set(1, 1);
				coinsFront2.antialiasing = false;
				coinsFront2.setGraphicSize(Std.int(coinsFront2.width * 6));
				coinsFront2.updateHitbox();
				add(coinsFront2);

				if (!Init.trueSettings.get("Photosensitivity"))
				{
					coinsFront.animation.add("idle", [0, 0, 0, 0, 0, 1, 2, 1], 9);
					coinsFront2.animation.add("idle", [0, 0, 0, 0, 0, 1, 2, 1], 9);
					coinsFront.animation.play("idle");
					coinsFront2.animation.play("idle");
				}

				var platform:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/clouds'));
				platform.scrollFactor.set(1, 1);
				platform.antialiasing = false;
				platform.setGraphicSize(Std.int(platform.width * 6));
				platform.updateHitbox();
				add(platform);

			case 'water':
				curStage = 'water';

				waterBG = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'), true, 320, 81);
				waterBG.animation.add("idle", [0, 0, 0, 0, 0, 1, 2, 1], 9);
				waterBG.animation.play("idle");

				waterBG.scrollFactor.set(1, 1);
				waterBG.antialiasing = false;
				waterBG.setGraphicSize(Std.int(waterBG.width * 6));
				waterBG.updateHitbox();
				add(waterBG);

				waterBG2 = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'), true, 320, 81);

				if (!Init.trueSettings.get("Photosensitivity"))
				{
					waterBG2.animation.add("idle", [0, 0, 0, 0, 0, 1, 2, 1], 9);
					waterBG2.animation.play("idle");
				}

				waterBG2.scrollFactor.set(1, 1);
				waterBG2.antialiasing = false;
				waterBG2.setGraphicSize(Std.int(waterBG2.width * 6));
				waterBG2.updateHitbox();
				add(waterBG2);
			
			case 'athletic':
				curStage = 'athletic';

				var bg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'));
				bg.scrollFactor.set(1, 1);
				bg.antialiasing = false;
				bg.setGraphicSize(Std.int(bg.width * 6));
				bg.updateHitbox();
				add(bg);

				var fg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/fg'));
				fg.scrollFactor.set(1, 1);
				fg.antialiasing = false;
				fg.setGraphicSize(Std.int(fg.width * 6));
				fg.updateHitbox();
				add(fg);

				enemy = new FNFSprite(172 * 6, -18 * 6).loadGraphic(Paths.image('backgrounds/' + curStage + '/enemy'), true, 24, 24);
				enemy.animation.add("koopa-red", [4, 5], 6);
				enemy.animation.play("koopa-red");

				enemy.scrollFactor.set(1, 1);
				enemy.antialiasing = false;
				enemy.setGraphicSize(Std.int(enemy.width * 6));
				enemy.updateHitbox();
				foreground.add(enemy);
			
				enemyX = enemy.x;
				enemyY = enemy.y;
				ogX = enemyX;
				ogY = enemyY;

			case 'sonic':
				curStage = 'sonic';

				var water:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/water'), true, 160, 81);
				water.scrollFactor.set(1, 1);
				water.antialiasing = false;
				water.animation.add("idle", [0, 1, 2, 3], 9);
				water.animation.play("idle");

				water.setGraphicSize(Std.int(water.width * 6));
				water.updateHitbox();
				add(water);

				var bg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'));
				bg.scrollFactor.set(1, 1);
				bg.antialiasing = false;
				bg.setGraphicSize(Std.int(bg.width * 6));
				bg.updateHitbox();
				add(bg);

			case 'ice':
				curStage = 'ice';

				var bg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'));
				bg.scrollFactor.set(1, 1);
				bg.antialiasing = false;
				bg.setGraphicSize(Std.int(bg.width * 6));
				bg.updateHitbox();
				add(bg);

				cloudsBack = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/clouds1'));
				cloudsBack.scrollFactor.set(1, 1);
				cloudsBack.antialiasing = false;
				cloudsBack.setGraphicSize(Std.int(cloudsBack.width * 6));
				cloudsBack.updateHitbox();
				add(cloudsBack);
				cloudsBack2 = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/clouds1'));
				cloudsBack2.scrollFactor.set(1, 1);
				cloudsBack2.antialiasing = false;
				cloudsBack2.setGraphicSize(Std.int(cloudsBack2.width * 6));
				cloudsBack2.updateHitbox();
				add(cloudsBack2);

				cloudsFront = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/clouds2'));
				cloudsFront.scrollFactor.set(1, 1);
				cloudsFront.antialiasing = false;
				cloudsFront.setGraphicSize(Std.int(cloudsFront.width * 6));
				cloudsFront.updateHitbox();
				add(cloudsFront);
				cloudsFront2 = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/clouds2'));
				cloudsFront2.scrollFactor.set(1, 1);
				cloudsFront2.antialiasing = false;
				cloudsFront2.setGraphicSize(Std.int(cloudsFront2.width * 6));
				cloudsFront2.updateHitbox();
				add(cloudsFront2);

				terrain = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/terrain'), true, 216, 40);
				terrain.animation.add("idle", [0, 1, 2, 3], 0, false);
				terrain.animation.play("idle");

				terrain.scrollFactor.set(1, 1);
				terrain.antialiasing = false;
				terrain.setGraphicSize(Std.int(terrain.width * 6));
				terrain.updateHitbox();
				add(terrain);
			
			case 'minus':
				curStage = 'minus';

				minusBG = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'), true, 160, 81);
				minusBG.animation.add("glitch", [1, 2, 3, 0], 9, false);

				minusBG.scrollFactor.set(1, 1);
				minusBG.antialiasing = false;
				minusBG.setGraphicSize(Std.int(minusBG.width * 6));
				minusBG.updateHitbox();
				add(minusBG);
			
			case 'camera':
				curStage = 'camera';
				
				var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
				bg.color = 0x0F380F;
				bg.scrollFactor.set();
				add(bg);

			case 'test-chamber':
				curStage = 'test-chamber';

				var bg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'));
				bg.scrollFactor.set(1, 1);
				bg.antialiasing = false;
				bg.setGraphicSize(Std.int(bg.width * 6));
				bg.updateHitbox();
				add(bg);

				var fg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/fg'));
				fg.scrollFactor.set(1, 1);
				fg.antialiasing = false;
				fg.setGraphicSize(Std.int(fg.width * 6));
				fg.updateHitbox();
				foreground.add(fg);

				mParticles = new FNFSprite(-7 * 6, -18 * 6).loadGraphic(Paths.image('backgrounds/test-chamber/shooty_particles'), true, 288, 36);
				mParticles.animation.add("shoot", [0, 1, 2, 3, 4, 5], 15, false);
				mParticles.animation.play("shoot");
				
				mParticles.angle = 90;
				mParticles.scrollFactor.set(1, 1);
				mParticles.antialiasing = false;
				mParticles.setGraphicSize(Std.int(mParticles.width * 2));
				mParticles.updateHitbox();
				add(mParticles);

				bfParticles = new FNFSprite(12 * 6, 0 * 6).loadGraphic(Paths.image('backgrounds/test-chamber/shooty_particles'), true, 288, 36);
				bfParticles.animation.add("shoot", [0, 1, 2, 3, 4, 5], 15, false);
				bfParticles.animation.play("shoot");
				
				bfParticles.angle = 45;
				bfParticles.scrollFactor.set(1, 1);
				bfParticles.antialiasing = false;
				bfParticles.setGraphicSize(Std.int(bfParticles.width * 2));
				bfParticles.updateHitbox();
				add(bfParticles);

				mParticles.animation.frameIndex = 4;
				bfParticles.animation.frameIndex = 4;

			case 'wrecking-crew':
				curStage = 'wrecking-crew';

				var bg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'));
				bg.scrollFactor.set(1, 1);
				bg.antialiasing = false;
				bg.setGraphicSize(Std.int(bg.width * 6));
				bg.updateHitbox();
				add(bg);

				bomb = new FNFSprite(9 * 6, 25 * 6).loadGraphic(Paths.image('backgrounds/' + curStage + '/bomb'), true, 24, 24);
				bomb.animation.add("idle", [0], 0, false);
				bomb.animation.add("boom", [0, 1, 2, 3, 4, 5, 6, 7], 12, false);
				bomb.animation.play("idle");

				bomb.scrollFactor.set(1, 1);
				bomb.antialiasing = false;
				bomb.setGraphicSize(Std.int(bomb.width * 6));
				bomb.updateHitbox();
				add(bomb);

				bomb2 = new FNFSprite(81 * 6, 25 * 6).loadGraphic(Paths.image('backgrounds/' + curStage + '/bomb'), true, 24, 24);
				bomb2.animation.add("idle", [0], 0, false);
				bomb2.animation.add("boom", [0, 1, 2, 3, 4, 5, 6, 7], 12, false);
				bomb2.animation.play("idle");

				bomb2.scrollFactor.set(1, 1);
				bomb2.antialiasing = false;
				bomb2.setGraphicSize(Std.int(bomb2.width * 6));
				bomb2.updateHitbox();
				add(bomb2);

			case 'smm':
				curStage = 'smm';

				var bg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'));
				bg.scrollFactor.set(1, 1);
				bg.antialiasing = false;
				bg.setGraphicSize(Std.int(bg.width * 6));
				bg.updateHitbox();
				add(bg);

				var bg2:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg2'));
				bg2.scrollFactor.set(1, 1);
				bg2.antialiasing = false;
				bg2.setGraphicSize(Std.int(bg2.width * 6));
				bg2.updateHitbox();
				add(bg2);

				var coin_shadow:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/coin_shadow'), true, 160, 81);
				coin_shadow.animation.add("idle", [0, 0, 0, 0, 0, 1, 2, 1], 9);
				coin_shadow.animation.play("idle");

				coin_shadow.scrollFactor.set(1, 1);
				coin_shadow.antialiasing = false;
				coin_shadow.setGraphicSize(Std.int(coin_shadow.width * 6));
				coin_shadow.updateHitbox();
				coin_shadow.alpha = 0.36;
				add(coin_shadow);

				var coin:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/coin'), true, 160, 81);
				coin.animation.add("idle", [0, 0, 0, 0, 0, 1, 2, 1], 9);
				coin.animation.play("idle");

				coin.scrollFactor.set(1, 1);
				coin.antialiasing = false;
				coin.setGraphicSize(Std.int(coin.width * 6));
				coin.updateHitbox();
				add(coin);

				enemies_shadow = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/enemies_shadow'), true, 160, 81);
				enemies_shadow.animation.add("idle", [0, 1], 6);
				enemies_shadow.animation.play("idle");

				enemies_shadow.scrollFactor.set(1, 1);
				enemies_shadow.antialiasing = false;
				enemies_shadow.setGraphicSize(Std.int(enemies_shadow.width * 6));
				enemies_shadow.updateHitbox();
				enemies_shadow.alpha = 0.36;
				add(enemies_shadow);

				enemies = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/enemies'), true, 160, 81);
				enemies.animation.add("idle", [0, 1], 6);
				enemies.animation.play("idle");

				enemies.scrollFactor.set(1, 1);
				enemies.antialiasing = false;
				enemies.setGraphicSize(Std.int(enemies.width * 6));
				enemies.updateHitbox();
				add(enemies);

				var fg_shadow:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/fg_shadow'));
				fg_shadow.scrollFactor.set(1, 1);
				fg_shadow.antialiasing = false;
				fg_shadow.setGraphicSize(Std.int(fg_shadow.width * 6));
				fg_shadow.updateHitbox();
				fg_shadow.alpha = 0.36;
				foreground.add(fg_shadow);

				var fg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/fg'));
				fg.scrollFactor.set(1, 1);
				fg.antialiasing = false;
				fg.setGraphicSize(Std.int(fg.width * 6));
				fg.updateHitbox();
				foreground.add(fg);

			case 'ghost':
				curStage = 'ghost';

				var bg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'));
				bg.scrollFactor.set(1, 1);
				bg.antialiasing = false;
				bg.setGraphicSize(Std.int(bg.width * 6));
				bg.updateHitbox();
				add(bg);

			case 'airship':
				curStage = 'airship';

				stormClouds = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'));
				stormClouds.scrollFactor.set(1, 1);
				stormClouds.antialiasing = false;
				stormClouds.setGraphicSize(Std.int(stormClouds.width * 6));
				stormClouds.updateHitbox();
				add(stormClouds);

				stormClouds2 = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg'));
				stormClouds2.scrollFactor.set(1, 1);
				stormClouds2.antialiasing = false;
				stormClouds2.setGraphicSize(Std.int(stormClouds2.width * 6));
				stormClouds2.updateHitbox();
				add(stormClouds2);

				gf = new FNFSprite(101 * 6, 25 * 6).loadGraphic(Paths.image('backgrounds/' + curStage + '/gf'), true, 24, 32);
				gf.animation.add('danceLeft', [7, 8, 9, 0, 1], 12, false);
				gf.animation.add('danceRight', [2, 3, 4, 5, 6], 12, false);
				gf.animation.add('miss', [10, 11, 12, 13], 12, false);

				gf.x += 0.075;
				gf.scrollFactor.set(1, 1);
				gf.antialiasing = false;
				gf.setGraphicSize(Std.int(gf.width * 6));
				gf.updateHitbox();
				add(gf);

				var cage:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/cage'));
				cage.scrollFactor.set(1, 1);
				cage.antialiasing = false;
				cage.setGraphicSize(Std.int(cage.width * 6));
				cage.updateHitbox();
				add(cage);

				hands = new FNFSprite(101 * 6, 25 * 6).loadGraphic(Paths.image('backgrounds/' + curStage + '/hands'), true, 24, 32);
				hands.animation.add('danceLeft', [7, 8, 9, 0, 1], 12, false);
				hands.animation.add('danceRight', [2, 3, 4, 5, 6], 12, false);
				hands.animation.add('miss', [10, 11, 12, 13], 12, false);

				hands.x += 0.075;
				hands.scrollFactor.set(1, 1);
				hands.antialiasing = false;
				hands.setGraphicSize(Std.int(hands.width * 6));
				hands.updateHitbox();
				add(hands);

				blasterBro = new FNFSprite(0 * 6, 21 * 6).loadGraphic(Paths.image('backgrounds/' + curStage + '/blaster-bro'), true, 32, 32);
				blasterBro.animation.add('idle', [0, 1, 2], 12, false);
				blasterBro.animation.add('shoot', [3, 4, 5], 12, false);

				blasterBro.x += 0.075;
				blasterBro.scrollFactor.set(1, 1);
				blasterBro.antialiasing = false;
				blasterBro.setGraphicSize(Std.int(blasterBro.width * 6));
				blasterBro.updateHitbox();
				add(blasterBro);

				var fg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/fg'));
				fg.scrollFactor.set(1, 1);
				fg.antialiasing = false;
				fg.setGraphicSize(Std.int(fg.width * 6));
				fg.updateHitbox();
				add(fg);

		}
	}

	// return the girlfriend's type
	public function returnGFtype(curStage)
	{
		var gfVersion:String = 'gf-pixel';

		switch (curStage)
		{
		}

		return gfVersion;
	}

	// get the dad's position
	public function dadPosition(curStage, dad:Character, gf:Character, camPos:FlxPoint, songPlayer2):Void
	{
		switch (songPlayer2)
		{
			case 'mario-small':
				dad.x += 5 * 6;
				dad.y += 15 * 6;

				// pixel alignment
				dad.x -= 1.75;
				dad.y -= 2.5;
			
			case 'mario-fire':
				dad.x -= 1 * 6;
				dad.y -= 9 * 6;

				// pixel alignment
				dad.x += 2;
				dad.y -= 2;
			
			case 'mario-fire-small':
				dad.y -= 9 * 6;

				// pixel alignment
				dad.x += 2;
				dad.y -= 2;
				
			case 'luigi':
				dad.x += 3 * 6;
				dad.y += 7 * 6;

				// pixel alignment
				dad.x -= 2;
				dad.y += 3;
		
			case 'luigi-water':
				dad.x -= 6 * 6;
				dad.y -= 7 * 6;

				// pixel alignment
				dad.x -= 2;
				dad.y += 3;

			case 'spike':
				dad.x -= 1 * 6;
				dad.y -= 9 * 6;

				// pixel alignment
				dad.x += 2;
				dad.y -= 2;
			
			case 'waluigi':
				// pixel alignment
				dad.x += 1;
			
			case 'bob-omb':
				dad.x -= 1 * 6;

			case 'mario-weird':
				dad.x += 2 * 6;
				dad.y += 8 * 6;

				// pixel alignment
				dad.x += 0.5;
				dad.y -= 3;
			
			case 'big-boo':
				//pixel alignment
				dad.x -= 1.5;
			
			case 'bowser':
				dad.x += 3 * 6;
				dad.y += 5 * 6;
		}
	}

	public function repositionPlayers(curStage, boyfriend:Character, dad:Character, gf:Character):Void
	{

		gf.visible = false;
		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			default:
				boyfriend.x += 91 * 6;
				boyfriend.y += 41 * 6;

				dad.x += 27 * 6;
				dad.y += 34 * 6;
			
			case 'underground':
				boyfriend.x += 96 * 6;
				boyfriend.y += 33 * 6;

				dad.x += 43 * 6;
				dad.y += 26 * 6;

			case 'castle':
				boyfriend.x += 135 * 6;
				boyfriend.y += 44 * 6;

				dad.y += 37 * 6;

			case 'sky':
				boyfriend.x += 106 * 6;
				boyfriend.y += 34 * 6;

				dad.x += 22 * 6;
				dad.y += 15 * 6;

			case 'athletic':
				boyfriend.x += 99 * 6;
				boyfriend.y += 46 * 6;

				dad.x += 24 * 6;
				dad.y += 7 * 6;
			
			case 'ice':
				boyfriend.x += 116 * 6;
				boyfriend.y += 2 * 6;

				dad.x += 27 * 6;
				dad.y += 34 * 6;
			
			case 'minus':
				boyfriend.x += 109 * 6;
				boyfriend.y += 25 * 6;

				dad.x += 31 * 6;
				dad.y += 18 * 6;
			
			case 'camera':
				boyfriend.visible = false;

				boyfriend.x += 60 * 6;
				boyfriend.y += 19 * 6;

				// pixel alignment
				boyfriend.x -= 0.995;

				// lol
				dad.x = boyfriend.x;
				dad.y = boyfriend.y;
			
			case 'test-chamber':
				boyfriend.x += 99 * 6;
				boyfriend.y += 33 * 6;

				dad.x += 40 * 6;
				dad.y += 41 * 6;

				// pixel alignment
				dad.x += 2;
				dad.y += 1;

			case 'wrecking-crew':
				boyfriend.x += 95 * 6;
				boyfriend.y += 36 * 6;

				dad.x += 27 * 6;
				dad.y += 29 * 6;
			
			case 'sonic':
				boyfriend.x += 90 * 6;
				boyfriend.y += 25 * 6;

				dad.x += 50 * 6;
				dad.y += 35 * 6;

				// pixel alignment
				dad.x -= 0.5;
				dad.y -= 4;

				boyfriend.x += 0.5;
				boyfriend.y += 1;
			
			case 'smm':
				boyfriend.x += 96 * 6;
				boyfriend.y += 25 * 6;

				dad.x += 6 * 6;
				dad.y += 18 * 6;

			case 'ghost':
				boyfriend.x += 108 * 6;
				boyfriend.y += 24 * 6;

				dad.x += 21 * 6;
				dad.y += 18 * 6;

			case 'airship':
				boyfriend.x += 124 * 6;
				boyfriend.y += 41 * 6;

				dad.x += 33 * 6;
				dad.y += 18 * 6;
		}

		if (boyfriend.curCharacter == 'luigi-player')
		{
			boyfriend.y -= 8 * 6;

			// pixel alignment
			boyfriend.x -= 3;
			boyfriend.y += 2;
		}

		if (boyfriend.curCharacter == 'bf-lakitu')
		{

			// pixel alignment
			boyfriend.x -= 3;
			boyfriend.y -= 2;
		}

		if (boyfriend.curCharacter == 'bf-captured')
		{
			boyfriend.y -= 2 * 6;

			// pixel alignment
			boyfriend.x += 2.995;
		}
	}

	var curLight:Int = 0;
	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var startedMoving:Bool = false;

	public function stageUpdate(curBeat:Int, boyfriend:Boyfriend, gfVar:Character, dadOpponent:Character)
	{
		// trace('update backgrounds');
		switch (PlayState.curStage)
		{
			case 'overworld':
				if (beatsUntilRespawn > 0)
				{
					beatsUntilRespawn -= 1;
					if (beatsUntilRespawn <= 0)
					{
						beatsUntilRespawn = 0;
						spawned = true;
						enemy.visible = true;
					}
				}
			case 'minus':
				if (curBeat % 8 == 0 && !Init.trueSettings.get("Photosensitivity"))
				{
					minusBG.animation.play("glitch");
				}
		}
	}

	public function dance()
	{
		if (PlayState.curStage == 'airship')
		{
			if (bopCooldown <= 0)
			{
				var animName = (bopLeft) ? 'danceLeft' : 'danceRight';
				gf.animation.play(animName, true);
				hands.animation.play(animName, true);
				bopLeft = !bopLeft;
				bopCooldown = 0.05;

				blasterBro.animation.play('idle', true);
			}
		}
	}

	public function missAnim()
	{
		if (PlayState.curStage == 'airship')
		{
			gf.animation.play('miss', true);
			bopCooldown = 0.25;
		}
	}

	public function stageUpdateConstant(elapsed:Float, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		switch (PlayState.curStage)
		{
			case 'ice':
				// if (!Init.trueSettings.get("Photosensitivity"))
				// 	{
				// 		moveMult = 1;
				// 	}
				// 	else
				// 	{
				// 		moveMult = 0.5;
				// 	}	
	
				cloudsBackPos.x -= 180 * elapsed * moveMult;
				if (cloudsBackPos.x + cloudsBack.width <= 0)
				{
					cloudsBackPos.x = 0;
				}
				cloudsBack.x = Std.int(cloudsBackPos.x / 6) * 6;
				cloudsBack2.x = cloudsBack.x + cloudsBack.width;

				cloudsFrontPos.x -= 540 * elapsed * moveMult;
				if (cloudsFrontPos.x + cloudsFront.width <= 0)
				{
					cloudsFrontPos.x = 0;
				}
				cloudsFront.x = Std.int(cloudsFrontPos.x / 6) * 6;
				cloudsFront2.x = cloudsFront.x + cloudsFront.width;
				
				
				var targetBfY = ((terrain.flipY) ? (42 * 6) : (12 * 6)) + (11*6);
				bfY = FlxMath.lerp(bfY, targetBfY, elapsed * 5);

				PlayState.boyfriend.y = (Std.int(bfY / 6) * 6) + 1;

				if (billDelay <= 0)
				{
					var targetBillY = ((terrain.flipY) ? (42 * 6) : (12 * 6)) + (11*6);
					billY = FlxMath.lerp(billY, targetBillY, elapsed * 5);

					PlayState.dadOpponent.y = (Std.int(billY / 6) * 6) + 1;
				}
				else
				{
					billDelay -= elapsed;
				}

				terrainPos.x -= 1440 * elapsed * moveMult;
				if (terrainPos.x < (-160 * 2 * 6))
				{
					terrain.animation.frameIndex = FlxG.random.int(0, 3);
					terrain.flipY = FlxG.random.bool();
					billDelay = 0.4;

					terrainPos.x = 160 * 2 * 6;
					terrainPos.y = (terrain.flipY) ? (0 * 6) : (41 * 6);
				}
				terrain.x = Std.int(terrainPos.x / 6) * 6;
				terrain.y = Std.int(terrainPos.y / 6) * 6;

			case 'water':
				mVelocityY += mSwimGravity * elapsed;

				mSwimX += mVelocityX * (elapsed * 120);
				mSwimY += mVelocityY * (elapsed * 120);

				PlayState.marioSwim.x = Std.int(mSwimX / 6) * 6;
				PlayState.marioSwim.y = Std.int(mSwimY / 6) * 6;

				if (mSwimY > swimThres)
				{
					mVelocityY = -mSwimPower * FlxG.random.float(0.8, 1);
				}


				// if (!Init.trueSettings.get("Photosensitivity"))
				// {
				// 	moveMult = 1;
				// }
				// else
				// {
				// 	moveMult = 0.5;
				// }	

				waterBGPos.x -= 960 * elapsed * moveMult;
				if (waterBGPos.x + waterBG.width <= 0)
				{
					waterBGPos.x = 0;
				}
				waterBG.x = Std.int(waterBGPos.x / 6) * 6;
				waterBG2.x = waterBG.x + waterBG.width;

			case 'castle':
				fireballAngle += elapsed * 115;
				if (fireballAngle > 360)
					fireballAngle = fireballAngle % 360;

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

			case 'overworld':
				if (spawned)
				{
					enemyX -= (1 * 130 * elapsed * ((enemy.flipX) ? -1 : 1));
					if (enemyType != 2)
					{
						if (enemyX < (128 * 6))
						{
							enemyVelocity += (20 * 130 * elapsed);
						}
					}
					else
					{
						if (enemyX < (130 * 6))
						{
							enemy.flipX = true;
						}
					}
					enemyY += (enemyVelocity * elapsed);

					if (enemyY > 89 * 6 || (enemy.flipX && enemyX > ogX))
					{
						enemyX = ogX;
						enemyY = ogY;
						enemyVelocity = 0;
						
						enemyType = FlxG.random.int(0, 2);
						var enemyName = 'goomba';
						switch (enemyType)
						{
							case 1:
								enemyName = 'koopa-green';
							case 2:
								enemyName = 'koopa-red';
						}
						
						enemy.animation.play(enemyName);
						
						beatsUntilRespawn = FlxG.random.int(12, 36);
						spawned = false;
						enemy.visible = false;
						enemy.flipX = false;
					}

					enemy.x = Std.int(enemyX / 6) * 6;
					enemy.y = Std.int(enemyY / 6) * 6;
				}

			case 'underground':
				platformPos1 -= (3 * 130 * elapsed);
				platformPos2 -= (3 * 130 * elapsed);

				if (platformPos1 < -32 * 6)
				{
					platformPos1 += 192 * 6;
				}
				if (platformPos2 < -32 * 6)
				{
					platformPos2 += 192 * 6;
				}

				bgPlatform1.y = Std.int(platformPos1 / 6) * 6;
				bgPlatform2.y = Std.int(platformPos2 / 6) * 6;
			
			case 'sky':
				// if (!Init.trueSettings.get("Photosensitivity"))
				// {
				// 	moveMult = 1;
				// }
				// else
				// {
				// 	moveMult = 0.5;
				// }


				starsPos.x -= 25 * elapsed * moveMult;
				if (starsPos.x + stars.width <= 0)
				{
					starsPos.x = 0;
				}
				stars.x = Std.int(starsPos.x / 6) * 6;
				stars2.x = stars.x + stars.width;


				coinsBackPos.x -= 200 * elapsed * moveMult;
				if (coinsBackPos.x + coinsBack.width <= 0)
				{
					coinsBackPos.x = 0;
				}
				coinsBack.x = Std.int(coinsBackPos.x / 6) * 6;
				coinsBack2.x = coinsBack.x + coinsBack.width;


				coinsFrontPos.x -= 600 * elapsed * moveMult;
				if (coinsFrontPos.x + coinsFront.width <= 0)
				{
					coinsFrontPos.x = 0;
				}
				coinsFront.x = Std.int(coinsFrontPos.x / 6) * 6;
				coinsFront2.x = coinsFront.x + coinsFront.width;

			case 'athletic':
				enemyX -= (1 * 130 * elapsed * ((enemy.flipX) ? -1 : 1));
				if (enemyX < (114 * 6))
				{
					enemy.flipX = true;
				}

				if (enemy.flipX && enemyX > ogX)
				{
					enemy.flipX = false;
				}

				enemy.x = Std.int(enemyX / 6) * 6;
				enemy.y = Std.int(enemyY / 6) * 6;
			
			case 'smm':
				if (enemyY < 0)
				{
					enemyVelocity += (20 * 130 * elapsed);
				}
				else
				{
					enemyVelocity = 0;
					enemyY = 0;
				}

				enemyY += (enemyVelocity * elapsed);
				enemies.y = enemyY;
				enemies_shadow.y = enemies.y;
			
			case 'airship':
				stormCloudsPos.x -= 96 * elapsed * moveMult;
				if (stormCloudsPos.x + stormClouds.width <= 0)
				{
					stormCloudsPos.x = 0;
				}
				stormClouds.x = Std.int(stormCloudsPos.x / 6) * 6;
				stormClouds2.x = stormClouds.x + stormClouds.width;

				if (bopCooldown > 0)
				{
					bopCooldown -= elapsed;
					if (bopCooldown <= 0)
						bopCooldown = 0;
				}
		}
	}

	// PHILLY STUFFS!
	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	function updateTrainPos(gf:Character):Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset(gf);
		}
	}

	function trainReset(gf:Character):Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}
}
