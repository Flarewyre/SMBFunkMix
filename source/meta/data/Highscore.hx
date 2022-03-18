package meta.data;

import flixel.FlxG;

using StringTools;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	public static var songData:Map<String, Array<Int>> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songData:Map<String, Array<Int>> = new Map<String, Array<Int>>();
	#end
	public static var saveVersion:Int = 1;

	public static function saveSongData(song:String, score:Int = 0, rating:Int = 0, combo:Int = 0)
	{
		var daSong:String = formatSong(song);

		if (songData.exists(daSong))
		{
			if (songData.get(daSong)[2] < combo)
			{
				setData(daSong, [score, rating, combo]);
				trace("A");
			}
			else if (songData.get(daSong)[2] == combo && songData.get(daSong)[0] < score)
			{
				setData(daSong, [score, rating, combo]);
				trace("B");
			}
		}
		else
			setData(daSong, [score, rating, combo]);
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0):Void
	{
		var daWeek:String = formatSong('week' + week);

		if (songScores.exists(daWeek))
		{
			if (songScores.get(daWeek) < score)
				setScore(daWeek, score);
		}
		else
			setScore(daWeek, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setData(song:String, data:Array<Int>):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songData.set(song, data);
		FlxG.save.data.songData = songData;
		FlxG.save.data.saveVersion = saveVersion;
		FlxG.save.flush();
	}

	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.data.saveVersion = saveVersion;
		FlxG.save.flush();
	}

	public static function formatSong(song:String):String
	{
		var daSong:String = song.toLowerCase();

		var difficulty:String = '-' + CoolUtil.difficultyFromNumber(1).toLowerCase();
		difficulty = difficulty.replace('-normal', '');

		daSong += difficulty;

		return daSong;
	}

	public static function getData(song:String):Array<Int>
	{
		if (!songData.exists(formatSong(song)))
			setData(formatSong(song), [0, 0, 0]);

		return songData.get(formatSong(song));
	}

	public static function getWeekScore(week:Int):Int
	{
		if (!songScores.exists(formatSong('week' + week)))
			setScore(formatSong('week' + week), 0);

		return songScores.get(formatSong('week' + week));
	}

	public static function load():Void
	{
		if (FlxG.save.data.songData != null)
		{
			songData = FlxG.save.data.songData;
		}
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
	}
}
