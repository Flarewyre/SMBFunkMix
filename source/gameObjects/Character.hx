package gameObjects;

/**
	The character class initialises any and all characters that exist within gameplay. For now, the character class will
	stay the same as it was in the original source of the game. I'll most likely make some changes afterwards though!
**/
import flixel.FlxG;
import flixel.addons.util.FlxSimplex;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import meta.*;
import meta.data.*;
import meta.data.dependency.FNFSprite;
import meta.state.PlayState;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Character extends FNFSprite
{
	// By default, this option set to FALSE will make it so that the character only dances twice per major beat hit
	// If set to on, they will dance every beat, such as Skid and Pump
	public var quickDancer:Bool = false;

	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);
		this.isPlayer = isPlayer;

		setCharacter(x, y, character);
	}

	public function setCharacter(x:Float, y:Float, character:String)
	{
		curCharacter = character;
		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/GF_assets');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				playAnim('danceRight');

			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('characters/gfPixel');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

			case 'bf-portal':
				frames = Paths.getSparrowAtlas('characters/bf-portal');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('singUPmiss', 'up', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down', 12, false);
				animation.addByPrefix('shoot', 'shoot', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'bf-portal-small':
				frames = Paths.getSparrowAtlas('characters/bf-portal-small');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('singUPmiss', 'up', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down', 12, false);
				animation.addByPrefix('shoot', 'shoot', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'bf-portal-fire':
				frames = Paths.getSparrowAtlas('characters/bf-portal-fire');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('singUPmiss', 'up', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down', 12, false);
				animation.addByPrefix('shoot', 'shoot', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;
			
			case 'bf':
				frames = Paths.getSparrowAtlas('characters/bf');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up0', 12, false);
				animation.addByPrefix('singLEFT', 'left0', 12, false);
				animation.addByPrefix('singRIGHT', 'right0', 12, false);
				animation.addByPrefix('singDOWN', 'down0', 12, false);
				animation.addByPrefix('singUPmiss', 'up0', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left0', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right0', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down0', 12, false);

				animation.addByPrefix('run', 'run', 12, true);
				animation.addByPrefix('skid', 'skid', 12, true);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'bf-small':
				frames = Paths.getSparrowAtlas('characters/bf-small');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up0', 12, false);
				animation.addByPrefix('singLEFT', 'left0', 12, false);
				animation.addByPrefix('singRIGHT', 'right0', 12, false);
				animation.addByPrefix('singDOWN', 'down0', 12, false);
				animation.addByPrefix('singUPmiss', 'up0', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left0', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right0', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down0', 12, false);

				animation.addByPrefix('run', 'run', 12, true);
				animation.addByPrefix('skid', 'skid', 12, true);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;
			case 'bf-fire':
				frames = Paths.getSparrowAtlas('characters/bf-fire');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up0', 12, false);
				animation.addByPrefix('singLEFT', 'left0', 12, false);
				animation.addByPrefix('singRIGHT', 'right0', 12, false);
				animation.addByPrefix('singDOWN', 'down0', 12, false);
				animation.addByPrefix('singUPmiss', 'up0', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left0', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right0', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down0', 12, false);

				animation.addByPrefix('run', 'run', 12, true);
				animation.addByPrefix('skid', 'skid', 12, true);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'bf-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD');
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				flipX = true;

			case 'bf-captured':
				frames = Paths.getSparrowAtlas('characters/bf-captured');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up0', 12, false);
				animation.addByPrefix('singLEFT', 'left0', 12, false);
				animation.addByPrefix('singRIGHT', 'right0', 12, false);
				animation.addByPrefix('singDOWN', 'down0', 12, false);
				animation.addByPrefix('singUPmiss', 'up0', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left0', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right0', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down0', 12, false);

				animation.addByPrefix('hey', 'hey', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'bf-captured-fire':
				frames = Paths.getSparrowAtlas('characters/bf-captured-fire');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up0', 12, false);
				animation.addByPrefix('singLEFT', 'left0', 12, false);
				animation.addByPrefix('singRIGHT', 'right0', 12, false);
				animation.addByPrefix('singDOWN', 'down0', 12, false);
				animation.addByPrefix('singUPmiss', 'up0', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left0', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right0', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down0', 12, false);

				animation.addByPrefix('hey', 'hey', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'bf-captured-small':
				frames = Paths.getSparrowAtlas('characters/bf-captured-small');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up0', 12, false);
				animation.addByPrefix('singLEFT', 'left0', 12, false);
				animation.addByPrefix('singRIGHT', 'right0', 12, false);
				animation.addByPrefix('singDOWN', 'down0', 12, false);
				animation.addByPrefix('singUPmiss', 'up0', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left0', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right0', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down0', 12, false);

				animation.addByPrefix('hey', 'hey', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;
	
			case 'bf-water':
				frames = Paths.getSparrowAtlas('characters/bf-water');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('singUPmiss', 'up', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;
			
			case 'bf-water-small':
				frames = Paths.getSparrowAtlas('characters/bf-water-small');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('singUPmiss', 'up', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'bf-water-fire':
				frames = Paths.getSparrowAtlas('characters/bf-water-fire');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('singUPmiss', 'up', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;
		
			case 'bf-glitch':
				frames = Paths.getSparrowAtlas('characters/bf-glitch');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up0', 12, false);
				animation.addByPrefix('singLEFT', 'left0', 12, false);
				animation.addByPrefix('singRIGHT', 'right0', 12, false);
				animation.addByPrefix('singDOWN', 'down0', 12, false);
				animation.addByPrefix('singUPmiss', 'up0', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left0', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right0', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down0', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'bf-glitch-small':
				frames = Paths.getSparrowAtlas('characters/bf-glitch-small');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up0', 12, false);
				animation.addByPrefix('singLEFT', 'left0', 12, false);
				animation.addByPrefix('singRIGHT', 'right0', 12, false);
				animation.addByPrefix('singDOWN', 'down0', 12, false);
				animation.addByPrefix('singUPmiss', 'up0', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left0', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right0', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down0', 12, false);
 
				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;
				
			case 'bf-glitch-fire':
				frames = Paths.getSparrowAtlas('characters/bf-glitch-fire');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up0', 12, false);
				animation.addByPrefix('singLEFT', 'left0', 12, false);
				animation.addByPrefix('singRIGHT', 'right0', 12, false);
				animation.addByPrefix('singDOWN', 'down0', 12, false);
				animation.addByPrefix('singUPmiss', 'up0', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left0', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right0', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down0', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'bf-smm':
				frames = Paths.getSparrowAtlas('characters/bf-smm');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up0', 12, false);
				animation.addByPrefix('singLEFT', 'left0', 12, false);
				animation.addByPrefix('singRIGHT', 'right0', 12, false);
				animation.addByPrefix('singDOWN', 'down0', 12, false);
				animation.addByPrefix('singUPmiss', 'up0', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left0', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right0', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down0', 12, false);
				animation.addByPrefix('hey', 'hey', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'bf-smm-small':
				frames = Paths.getSparrowAtlas('characters/bf-smm-small');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up0', 12, false);
				animation.addByPrefix('singLEFT', 'left0', 12, false);
				animation.addByPrefix('singRIGHT', 'right0', 12, false);
				animation.addByPrefix('singDOWN', 'down0', 12, false);
				animation.addByPrefix('singUPmiss', 'up0', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left0', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right0', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down0', 12, false);
				animation.addByPrefix('hey', 'hey', 12, false);
 
				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;
				
			case 'bf-smm-fire':
				frames = Paths.getSparrowAtlas('characters/bf-smm-fire');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up0', 12, false);
				animation.addByPrefix('singLEFT', 'left0', 12, false);
				animation.addByPrefix('singRIGHT', 'right0', 12, false);
				animation.addByPrefix('singDOWN', 'down0', 12, false);
				animation.addByPrefix('singUPmiss', 'up0', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left0', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right0', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down0', 12, false);
				animation.addByPrefix('hey', 'hey', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'bf-lakitu':
				frames = Paths.getSparrowAtlas('characters/bf-lakitu');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('singUPmiss', 'up', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'bf-lakitu-fire':
				frames = Paths.getSparrowAtlas('characters/bf-lakitu-fire');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('singUPmiss', 'up', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'bf-lakitu-small':
				frames = Paths.getSparrowAtlas('characters/bf-lakitu-small');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('singUPmiss', 'up', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'bf-camera':
				frames = Paths.getSparrowAtlas('characters/camera/bf-camera');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('singUPmiss', 'miss', 12, false);
				animation.addByPrefix('singLEFTmiss', 'miss', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'miss', 12, false);
				animation.addByPrefix('singDOWNmiss', 'miss', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'him':
				frames = Paths.getSparrowAtlas('characters/camera/him');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'mario-fire':
				frames = Paths.getSparrowAtlas('characters/mario-fire');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'mario-ccc-fire':
				frames = Paths.getSparrowAtlas('characters/mario-ccc-fire');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('hey', 'hey', 12, false);
				animation.addByPrefix('jump', 'jump', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'mario-ccc':
				frames = Paths.getSparrowAtlas('characters/mario-ccc');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('hey', 'hey', 12, false);
				animation.addByPrefix('jump', 'jump', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'mario-ccc-small':
				frames = Paths.getSparrowAtlas('characters/mario-ccc-small');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('hey', 'hey', 12, false);
				animation.addByPrefix('jump', 'jump', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'luigi-ccc':
				frames = Paths.getSparrowAtlas('characters/luigi-ccc');
				animation.addByPrefix('idle', 'idle', 9, true);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'right', 12, false);
				animation.addByPrefix('singRIGHT', 'left', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('jump', 'jump', 12, false);
				
				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'mario-fire-small':
				frames = Paths.getSparrowAtlas('characters/mario-fire-small');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'mario-portal':
				frames = Paths.getSparrowAtlas('characters/mario-portal');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('shoot', 'shoot', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'spike':
				frames = Paths.getSparrowAtlas('characters/spike');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('death', 'death', 0, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'waluigi':
				frames = Paths.getSparrowAtlas('characters/waluigi');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;
				
			case 'big-boo':
				frames = Paths.getSparrowAtlas('characters/big-boo');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('shy', 'shy', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'mario':
				frames = Paths.getSparrowAtlas('characters/mario');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'right', 12, false);
				animation.addByPrefix('singRIGHT', 'left', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			case 'mario-small':
				frames = Paths.getSparrowAtlas('characters/mario-small');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'mario-weird':
				frames = Paths.getSparrowAtlas('characters/mario-weird');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('hey', 'hey', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'luigi':
				frames = Paths.getSparrowAtlas('characters/luigi');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'luigi-water':
				frames = Paths.getSparrowAtlas('characters/luigi-water');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;
		
			case 'bullet-bill':
				frames = Paths.getSparrowAtlas('characters/bullet-bill');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;
			
			case 'luigi-player':
				frames = Paths.getSparrowAtlas('characters/luigi');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('singUPmiss', 'up', 12, false);
				animation.addByPrefix('singLEFTmiss', 'left', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'right', 12, false);
				animation.addByPrefix('singDOWNmiss', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'bowser':
				frames = Paths.getSparrowAtlas('characters/bowser');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('roarStart', 'startroar', 12, false);
				animation.addByPrefix('roar', 'roar', 18, true);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'bob-omb':
				frames = Paths.getSparrowAtlas('characters/bombomb');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'bob-omb-lit':
				frames = Paths.getSparrowAtlas('characters/bombomb-lit');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('explode', 'explode', 12, true);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'sonic':
				frames = Paths.getSparrowAtlas('characters/sonic');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('hey', 'hey', 12, false);
				animation.addByPrefix('loop', 'loop', 12, true);
				animation.addByPrefix('wave', 'wave', 12, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'tails':
				frames = Paths.getSparrowAtlas('characters/tails');
				animation.addByPrefix('idle', 'idle', 12, false);
				animation.addByPrefix('singUP', 'up', 12, false);
				animation.addByPrefix('singLEFT', 'left', 12, false);
				animation.addByPrefix('singRIGHT', 'right', 12, false);
				animation.addByPrefix('singDOWN', 'down', 12, false);
				animation.addByPrefix('fly', 'fly', 12, true);
				animation.addByPrefix('skid', 'skid', 12, true);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;
			
			default:
				trace(curCharacter);
				// set up animations if they aren't already

				// fyi if you're reading this this isn't meant to be well made, it's kind of an afterthought I wanted to mess with and
				// I'm probably not gonna clean it up and make it an actual feature of the engine I just wanted to play other people's mods but not add their files to
				// the engine because that'd be stealing assets
				var fileNew = curCharacter + 'Anims';
				if (OpenFlAssets.exists(Paths.offsetTxt(fileNew)))
				{
					var characterAnims:Array<String> = CoolUtil.coolTextFile(Paths.offsetTxt(fileNew));
					var characterName:String = characterAnims[0].trim();
					frames = Paths.getSparrowAtlas('characters/$characterName');
					for (i in 1...characterAnims.length)
					{
						var getterArray:Array<Array<String>> = CoolUtil.getAnimsFromTxt(Paths.offsetTxt(fileNew));
						animation.addByPrefix(getterArray[i][0], getterArray[i][1].trim(), 24, false);
					}
				}
				else
				{
					// DAD ANIMATION LOADING CODE
					tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST');
					frames = tex;
					animation.addByPrefix('idle', 'Dad idle dance', 30, false);
					animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
					animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
					animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
					animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

					playAnim('idle');
				}
		}

		// set up offsets cus why not
		if (OpenFlAssets.exists(Paths.offsetTxt(curCharacter + 'Offsets')))
		{
			var characterOffsets:Array<String> = CoolUtil.coolTextFile(Paths.offsetTxt(curCharacter + 'Offsets'));
			for (i in 0...characterOffsets.length)
			{
				var getterArray:Array<Array<String>> = CoolUtil.getOffsetsFromTxt(Paths.offsetTxt(curCharacter + 'Offsets'));
				addOffset(getterArray[i][0], Std.parseInt(getterArray[i][1]), Std.parseInt(getterArray[i][2]));
			}
		}

		dance();

		if (isPlayer) // fuck you ninjamuffin lmao
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf') && !curCharacter.startsWith('mario-ccc')  && !curCharacter.startsWith('luigi-ccc'))
				flipLeftRight();
			//
		}
		else if (curCharacter.startsWith('bf') && !curCharacter.startsWith('mario-ccc')  && !curCharacter.startsWith('luigi-ccc'))
			flipLeftRight();

		this.x = x;
		this.y = y;
	}

	function flipLeftRight():Void
	{
		// get the old right sprite
		var oldRight = animation.getByName('singRIGHT').frames;

		// set the right to the left
		animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;

		// set the left to the old right
		animation.getByName('singLEFT').frames = oldRight;

		// insert ninjamuffin screaming I think idk I'm lazy as hell

		if (animation.getByName('singRIGHTmiss') != null)
		{
			var oldMiss = animation.getByName('singRIGHTmiss').frames;
			animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
			animation.getByName('singLEFTmiss').frames = oldMiss;
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf') && !curCharacter.startsWith('mario-ccc') && !curCharacter.startsWith('luigi-ccc'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		var curCharSimplified:String = simplifyCharacter();
		switch (curCharSimplified)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
				if ((animation.curAnim.name.startsWith('sad')) && (animation.curAnim.finished))
					playAnim('danceLeft');
		}

		// Post idle animation (think Week 4 and how the player and mom's hair continues to sway after their idle animations are done!)
		if (animation.curAnim.finished && animation.curAnim.name == 'idle')
		{
			// We look for an animation called 'idlePost' to switch to
			if (animation.getByName('idlePost') != null)
				// (( WE DON'T USE 'PLAYANIM' BECAUSE WE WANT TO FEED OFF OF THE IDLE OFFSETS! ))
				animation.play('idlePost', true, false, 0);
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?forced:Bool = false)
	{
		if (!debugMode)
		{
			var curCharSimplified:String = simplifyCharacter();
			switch (curCharSimplified)
			{
				case 'gf':
					if ((!animation.curAnim.name.startsWith('hair')) && (!animation.curAnim.name.startsWith('sad')))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight', forced);
						else
							playAnim('danceLeft', forced);
					}
				default:
					// Left/right dancing, think Skid & Pump
					if (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null)
						playAnim((animation.curAnim.name == 'danceRight') ? 'danceLeft' : 'danceRight', forced);
					// Play normal idle animations for all other characters
					else
						if (curCharacter == 'big-boo')
						{
							if (PlayState.mustHit)
							{
								playAnim('shy', forced);
							}
							else
							{
								playAnim('idle', forced);
							}
						}
						else
						{
							playAnim('idle', forced);
						}
			}
		}
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animation.getByName(AnimName) != null)
			super.playAnim(AnimName, Force, Reversed, Frame);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	public function simplifyCharacter():String
	{
		var base = curCharacter;

		if (base.contains('-'))
			base = base.substring(0, base.indexOf('-'));
		return base;
	}
}
