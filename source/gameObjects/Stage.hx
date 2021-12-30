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
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
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

	var bgGirls:BackgroundGirls;

	public var curStage:String;

	var daPixelZoom = PlayState.daPixelZoom;

	public var foreground:FlxTypedGroup<FlxBasic>;

	var moveMult:Float = 0;
	public var platformPos1:Float;
	public var platformPos2:Float;

	var enemyX:Float;
	var enemyY:Float;
	
	var ogX:Float;
	var ogY:Float;

	var enemyVelocity:Float;
	var enemyType:Int;
	var beatsUntilRespawn:Int = 12;
	var spawned:Bool = false;

	var fireballs:Array<FNFSprite> = [];
	var fireballCenterX:Float;
	var fireballCenterY:Float;
	var fireballAngle:Float;

	public function new(curStage)
	{
		super();
		this.curStage = curStage;

		starsPos = new FlxPoint();
		coinsBackPos = new FlxPoint();
		coinsFrontPos = new FlxPoint();

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

				coinsBack = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/coins1'));
				coinsBack.scrollFactor.set(1, 1);
				coinsBack.antialiasing = false;
				coinsBack.setGraphicSize(Std.int(coinsBack.width * 6));
				coinsBack.updateHitbox();
				add(coinsBack);
				coinsBack2 = new FNFSprite(coinsBack.width, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/coins1'));
				coinsBack2.scrollFactor.set(1, 1);
				coinsBack2.antialiasing = false;
				coinsBack2.setGraphicSize(Std.int(coinsBack2.width * 6));
				coinsBack2.updateHitbox();
				add(coinsBack2);

				coinsFront = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/coins2'));
				coinsFront.scrollFactor.set(1, 1);
				coinsFront.antialiasing = false;
				coinsFront.setGraphicSize(Std.int(coinsFront.width * 6));
				coinsFront.updateHitbox();
				add(coinsFront);
				coinsFront2 = new FNFSprite(coinsFront.width, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/coins2'));
				coinsFront2.scrollFactor.set(1, 1);
				coinsFront2.antialiasing = false;
				coinsFront2.setGraphicSize(Std.int(coinsFront2.width * 6));
				coinsFront2.updateHitbox();
				add(coinsFront2);

				var platform:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/clouds'));
				platform.scrollFactor.set(1, 1);
				platform.antialiasing = false;
				platform.setGraphicSize(Std.int(platform.width * 6));
				platform.updateHitbox();
				add(platform);

			default:
				PlayState.defaultCamZoom = 0.9;
				curStage = 'stage';
				var bg:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('backgrounds/' + curStage + '/stageback'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;

				// add to the final array
				add(bg);

				var stageFront:FNFSprite = new FNFSprite(-650, 600).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;

				// add to the final array
				add(stageFront);

				var stageCurtains:FNFSprite = new FNFSprite(-500, -300).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;

				// add to the final array
				add(stageCurtains);
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
				dad.x -= 2.25;
				dad.y -= 2.5;
			
			case 'mario-fire':
				dad.x -= 1 * 6;
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
		}
	}

	public function repositionPlayers(curStage, boyfriend:Character, dad:Character, gf:Character):Void
	{

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			default:
				gf.visible = false;

				boyfriend.x += 91 * 6;
				boyfriend.y += 41 * 6;

				dad.x += 27 * 6;
				dad.y += 34 * 6;
			
			case 'underground':
				gf.visible = false;

				boyfriend.x += 96 * 6;
				boyfriend.y += 33 * 6;

				dad.x += 43 * 6;
				dad.y += 26 * 6;

			case 'castle':
				gf.visible = false;

				boyfriend.x += 135 * 6;
				boyfriend.y += 44 * 6;

				dad.y += 37 * 6;

			case 'sky':
				gf.visible = false;

				boyfriend.x += 106 * 6;
				boyfriend.y += 34 * 6;

				dad.x += 22 * 6;
				dad.y += 15 * 6;
		}

		if (boyfriend.curCharacter == 'luigi-player')
		{
			boyfriend.y -= 8 * 6;

			// pixel alignment
			boyfriend.x -= 3;
			boyfriend.y += 2;
		}
	}

	var curLight:Int = 0;
	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var startedMoving:Bool = false;

	public function stageUpdate(curBeat:Int, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
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
		}
	}

	public function stageUpdateConstant(elapsed:Float, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		switch (PlayState.curStage)
		{
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
				if (!Init.trueSettings.get('Reduced Movements'))
				{
					moveMult = 1;
				}
				else
				{
					moveMult = 0.5;
				}


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
