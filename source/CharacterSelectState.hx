package;

import lime.app.Application;
import haxe.Exception;
import Controls.Control;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.system.FlxSoundGroup;
import flixel.math.FlxPoint;
import openfl.geom.Point;
import flixel.*;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.util.FlxStringUtil;
#if windows
import lime.app.Application;
#end

/**
	hey you fun commiting people, 
	i don't know about the rest of the mod but since this is basically 99% my code 
	i do not give you guys permission to grab this specific code and re-use it in your own mods without asking me first.
	the secondary dev, ben
 */
class CharacterInSelect
{
	public var name:String;
	public var noteMs:Array<Float>;
	public var forms:Array<CharacterForm>;

	public function new(name:String, noteMs:Array<Float>, forms:Array<CharacterForm>)
	{
		this.name = name;
		this.noteMs = noteMs;
		this.forms = forms;
	}
}

class CharacterForm
{
	public var name:String;
	public var polishedName:String;
	public var noteType:String;
	public var noteMs:Array<Float>;

	public function new(name:String, polishedName:String, noteMs:Array<Float>, noteType:String = 'normal')
	{
		this.name = name;
		this.polishedName = polishedName;
		this.noteType = noteType;
		this.noteMs = noteMs;
	}
}

class CharacterSelectState extends MusicBeatState
{
	public var char:Boyfriend;
	public var current:Int = 0;
	public var curForm:Int = 0;
	public var notemodtext:FlxText;
	public var characterText:FlxText;
	public var wasInFullscreen:Bool;

	public var funnyIconMan:HealthIcon;

	var strummies:FlxTypedGroup<FlxSprite>;

	var notestuffs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	public var isDebug:Bool = false;

	public var PressedTheFunny:Bool = false;

	var selectedCharacter:Bool = false;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var currentSelectedCharacter:CharacterInSelect;

	var noteMsTexts:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

	var arrows:Array<FlxSprite> = [];

	public var characters:Array<CharacterInSelect> = [
		new CharacterInSelect('bf', [1, 1, 1, 1], [
			new CharacterForm('bf', 'Boyfriend', [1, 1, 1, 1]),
			new CharacterForm('bf-pixel', 'Pixel Boyfriend', [1, 1, 1, 1])
		]),
		new CharacterInSelect('dave', [0.25, 0.25, 2, 2], [
			new CharacterForm('dave', 'Dave', [0.25, 0.25, 2, 2]),
			new CharacterForm('dave-annoyed', 'Dave (Insanity)', [0.25, 0.25, 2, 2]),
			new CharacterForm('dave-splitathon', 'Dave (Splitathon)', [0.25, 0.25, 2, 2])
		]),
		new CharacterInSelect('bambi', [0, 0, 3, 0], [
			new CharacterForm('bambi-new', 'Bambi', [0, 0, 3, 0]),
			new CharacterForm('bambi-splitathon', 'Bambi (Splitathon)', [0, 0, 3, 0]),
			new CharacterForm('bambi-angey', 'Bambie', [0, 0, 3, 0]),
			new CharacterForm('bambi', 'Mr. Bambi', [0, 0, 3, 0])
		]),
		new CharacterInSelect('tristan', [2, 0.5, 0.5, 0.5],
			[
				new CharacterForm('tristan', 'Tristan', [2, 0.5, 0.5, 0.5]),
				new CharacterForm('tristan-festival', 'Tristan (Festival)', [2, 0.5, 0.5, 0.5]),
				new CharacterForm('tristan-golden', 'Golden Tristan', [0.25, 0.25, 0.25, 2])
			]),
		new CharacterInSelect('dave-angey', [2, 2, 0.25, 0.25], [new CharacterForm('dave-angey', '3D Dave', [2, 2, 0.25, 0.25], '3D')]),
		new CharacterInSelect('bambi-3d', [0, 3, 0, 0], [
			new CharacterForm('bambi-3d', '[EXPUNGED] (Bambi)', [0, 3, 0, 0], '3D'),
			new CharacterForm('bambi-unfair', '[EXPUNGED] (Unfair)', [0, 3, 0, 0], '3D'),
			new CharacterForm('expunged', '[EXPUNGED]', [0, 3, 0, 0], '3D')
		]),
		new CharacterInSelect('the-shart-fellars', [0, 3, 0, 0], [
			new CharacterForm('cockey', 'Cockey', [1, 1, 1, 1]),
			new CharacterForm('pissey', 'Pissey', [1, 1, 1, 1]),
			new CharacterForm('pooper', 'Pooper', [1, 1, 1, 1])
		])
	];

	var bgShader:Shaders.GlitchEffect;

	public function new()
	{
		super();
	}

	override public function create():Void
	{
		Paths.clearUnusedMemory();
		Paths.clearStoredMemory();

		super.create();

		if (PlayState.SONG.song.toLowerCase() == 'exploitation')
		{
			if (FlxG.fullscreen)
			{
				FlxG.fullscreen = false;
				wasInFullscreen = true;
			}
		}

		Conductor.changeBPM(110);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

		if (FlxG.save.data.charactersUnlocked == null)
		{
			reset();
		}
		currentSelectedCharacter = characters[current];

		if (PlayState.SONG.song.toLowerCase() == "exploitation")
			FlxG.sound.playMusic(Paths.music("badEnding"), 1, true);
		else
			FlxG.sound.playMusic(Paths.music("goodEnding"), 1, true);

		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('backgrounds/shared/sky_night'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.75, 0.75);
		bg.active = false;

		if (PlayState.SONG.song.toLowerCase() == "exploitation")
		{
			bg.loadGraphic(Paths.image('backgrounds/void/redsky', 'shared'));

			bgShader = new Shaders.GlitchEffect();
			bgShader.waveAmplitude = 0.1;
			bgShader.waveFrequency = 5;
			bgShader.waveSpeed = 2;

			bg.shader = bgShader.shader;
		}
		add(bg);

		var stageHills:FlxSprite = new FlxSprite(-225, -125).loadGraphic(Paths.image('backgrounds/dave-house/night/hills'));
		stageHills.setGraphicSize(Std.int(stageHills.width * 1.25));
		stageHills.updateHitbox();
		stageHills.antialiasing = true;
		stageHills.scrollFactor.set(0.8, 0.8);
		stageHills.active = false;
		add(stageHills);

		var gate:FlxSprite = new FlxSprite(-200, -125).loadGraphic(Paths.image('backgrounds/dave-house/night/gate'));
		gate.setGraphicSize(Std.int(gate.width * 1.2));
		gate.updateHitbox();
		gate.antialiasing = true;
		gate.scrollFactor.set(0.9, 0.9);
		gate.active = false;
		add(gate);

		var stageFront:FlxSprite = new FlxSprite(-225, -125).loadGraphic(Paths.image('backgrounds/dave-house/night/grass'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.2));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.active = false;
		add(stageFront);

		FlxG.camera.zoom = 0.75;
		camHUD.zoom = 0.75;

		char = new Boyfriend(FlxG.width / 2, FlxG.height / 2, "bf");
		char.screenCenter();
		char.y = 450;
		add(char);

		strummies = new FlxTypedGroup<FlxSprite>();
		strummies.cameras = [camHUD];

		add(strummies);
		generateStaticArrows(false);

		notemodtext = new FlxText((FlxG.width / 3.5) + 80, 40, 0, "1.00x       1.00x        1.00x       1.00x", 30);
		notemodtext.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		notemodtext.scrollFactor.set();
		notemodtext.alpha = 0;
		notemodtext.y -= 10;
		FlxTween.tween(notemodtext, {y: notemodtext.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * 0)});
		notemodtext.cameras = [camHUD];
		add(notemodtext);

		characterText = new FlxText((FlxG.width / 9) - 50, (FlxG.height / 8) - 225, "Boyfriend");
		characterText.font = 'Comic Sans MS Bold';
		characterText.setFormat(Paths.font("comic.ttf"), 90, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		characterText.autoSize = false;
		characterText.fieldWidth = 1080;
		characterText.borderSize = 7;
		characterText.screenCenter(X);
		characterText.cameras = [camHUD];
		characterText.antialiasing = true;
		add(characterText);

		var resetText = new FlxText((FlxG.width / 2) + 350, (FlxG.height / 8) - 200, LanguageManager.getTextString('character_reset'));
		resetText.font = 'Comic Sans MS Bold';
		resetText.setFormat(Paths.font("comic.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		resetText.autoSize = false;
		resetText.fieldWidth = FlxG.height;
		resetText.borderSize = 5;
		resetText.cameras = [camHUD];
		resetText.antialiasing = true;
		add(resetText);

		funnyIconMan = new HealthIcon('bf', true);
		funnyIconMan.cameras = [camHUD];
		funnyIconMan.visible = false;
		funnyIconMan.antialiasing = true;
		updateIconPosition();
		add(funnyIconMan);

		var tutorialThing:FlxSprite = new FlxSprite(-150, -50).loadGraphic(Paths.image('ui/charSelectGuide'));
		tutorialThing.setGraphicSize(Std.int(tutorialThing.width * 1.5));
		tutorialThing.antialiasing = true;
		tutorialThing.cameras = [camHUD];
		add(tutorialThing);

		var arrowLeft:FlxSprite = new FlxSprite(5, 0).loadGraphic(Paths.image("ui/ArrowLeft_Idle", "preload"));
		arrowLeft.screenCenter(Y);
		arrowLeft.scrollFactor.set();
		arrows[0] = arrowLeft;
		add(arrowLeft);

		var arrowRight:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("ui/ArrowRight_Idle", "preload"));
		arrowRight.screenCenter(Y);
		arrowRight.x = 1280 - arrowRight.width - 5;
		arrowRight.scrollFactor.set();
		arrows[1] = arrowRight;
		add(arrowRight);

		#if mobile
		addVirtualPad(LEFT_FULL, A_B_X_Y);
		addVirtualPadCamera();
		#end
	}

	private function generateStaticArrows(noteType:String = 'normal', regenerated:Bool):Void
	{
		if (regenerated)
		{
			if (strummies.length > 0)
			{
				strummies.forEach(function(babyArrow:FlxSprite)
				{
					remove(babyArrow);
					strummies.remove(babyArrow);
				});
			}
		}
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, 0);

			var noteAsset:String = 'notes/NOTE_assets';
			switch (noteType)
			{
				case '3D':
					noteAsset = 'notes/NOTE_assets_3D';
			}

			babyArrow.frames = Paths.getSparrowAtlas(noteAsset);
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			babyArrow.x += Note.swagWidth * i;
			switch (Math.abs(i))
			{
				case 0:
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.ID = i;

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 3.5));
			babyArrow.y -= 10;
			babyArrow.alpha = 0;

			var baseDelay:Float = regenerated ? 0 : 0.5;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: baseDelay + (0.2 * i)});
			babyArrow.cameras = [camHUD];
			strummies.add(babyArrow);
		}
	}

	override public function update(elapsed:Float):Void
	{
		if (bgShader != null)
		{
			bgShader.shader.uTime.value[0] += elapsed;
		}
		Conductor.songPosition = FlxG.sound.music.time;

		var controlSet:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];

		super.update(elapsed);

		if (#if mobile virtualPad.buttonB.justPressed || #end FlxG.keys.justPressed.ESCAPE)
		{
			if (wasInFullscreen)
			{
				FlxG.fullscreen = true;
			}
			LoadingState.loadAndSwitchState(new FreeplayState());
		}

		if (#if mobile virtualPad.buttonY.justPressed || #end FlxG.keys.justPressed.SEVEN)
		{
			for (character in characters)
			{
				unlockCharacter(character.name); // unlock everyone
			}
		}

		for (i in 0...controlSet.length)
		{
			if (controlSet[i] && !PressedTheFunny)
			{
				switch (i)
				{
					case 0:
						char.playAnim(char.nativelyPlayable ? 'singLEFT' : 'singRIGHT', true);
					case 1:
						char.playAnim('singDOWN', true);
					case 2:
						char.playAnim('singUP', true);
					case 3:
						char.playAnim(char.nativelyPlayable ? 'singRIGHT' : 'singLEFT', true);
				}
			}
		}
		if (controls.ACCEPT)
		{
			if (isLocked(characters[current].forms[curForm].name))
			{
				FlxG.camera.shake(0.05, 0.1);
				FlxG.sound.play(Paths.sound('badnoise1'), 0.9);
				return;
			}
			if (PressedTheFunny)
			{
				return;
			}
			else
			{
				PressedTheFunny = true;
			}
			selectedCharacter = true;
			var heyAnimation:Bool = char.animation.getByName("hey") != null;
			char.playAnim(heyAnimation ? 'hey' : 'singUP', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd'));
			new FlxTimer().start(1.9, endIt);
		}
		if (#if mobile virtualPad.buttonLeft.justPressed || #end FlxG.keys.justPressed.LEFT && !selectedCharacter)
		{
			curForm = 0;
			current--;
			if (current < 0)
			{
				current = characters.length - 1;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			arrows[0].loadGraphic(Paths.image("ui/ArrowLeft_Pressed", "preload"));
		}

		if (#if mobile virtualPad.buttonRight.justPressed || #end FlxG.keys.justPressed.RIGHT && !selectedCharacter)
		{
			curForm = 0;
			current++;
			if (current > characters.length - 1)
			{
				current = 0;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			arrows[1].loadGraphic(Paths.image("ui/ArrowRight_Pressed", "preload"));
		}

		if (FlxG.keys.justReleased.LEFT)
			arrows[0].loadGraphic(Paths.image("ui/ArrowLeft_Idle", "preload"));
		if (FlxG.keys.justReleased.RIGHT)
			arrows[1].loadGraphic(Paths.image("ui/ArrowRight_Idle", "preload"));

		if (#if mobile virtualPad.buttonDown.justPressed || #end FlxG.keys.justPressed.DOWN && !selectedCharacter)
		{
			curForm--;
			if (curForm < 0)
			{
				curForm = characters[current].forms.length - 1;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
		if (#if mobile virtualPad.buttonUp.justPressed || #end FlxG.keys.justPressed.UP && !selectedCharacter)
		{
			curForm++;
			if (curForm > characters[current].forms.length - 1)
			{
				curForm = 0;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
		if (#if mobile virtualPad.buttonX.justPressed || #end FlxG.keys.justPressed.R && !selectedCharacter)
		{
			reset();
			FlxG.resetState();
		}
	}

	public static function unlockCharacter(character:String)
	{
		if (!FlxG.save.data.charactersUnlocked.contains(character))
		{
			FlxG.save.data.charactersUnlocked.push(character);
		}
	}

	public static function isLocked(character:String):Bool
	{
		return !FlxG.save.data.charactersUnlocked.contains(character);
	}

	public static function reset()
	{
		FlxG.save.data.charactersUnlocked = new Array<String>();
		unlockCharacter('bf');
		unlockCharacter('bf-pixel');
		FlxG.save.flush();
	}

	public function UpdateBF()
	{
		var newSelectedCharacter = characters[current];
		if (currentSelectedCharacter.forms[curForm].noteType != newSelectedCharacter.forms[curForm].noteType)
		{
			generateStaticArrows(newSelectedCharacter.forms[curForm].noteType, true);
		}

		currentSelectedCharacter = newSelectedCharacter;
		characterText.text = currentSelectedCharacter.forms[curForm].polishedName;
		char.destroy();
		char = new Boyfriend(FlxG.width / 2, FlxG.height / 2, currentSelectedCharacter.forms[curForm].name);
		char.screenCenter();
		char.y = 450;

		switch (char.curCharacter)
		{
			case 'bf-pixel':
				char.y -= 50;
				char.x -= 50;
			case 'dave' | 'dave-annoyed':
				char.y = 260;
			case 'dave-splitathon':
				char.y = 260;
				char.x -= 25;
			case 'bambi' | 'bambi-old':
				char.y = 400;
			case 'bambi-new':
				char.y = 400;
			case 'bambi-splitathon':
				char.y = 475;
				char.x -= 25;
			case 'bambi-angey':
				char.y = 475;
			case 'dave-angey':
				char.y = 150;
				char.x -= 50;
			case 'tristan':
				char.y = 425;
			case 'tristan-golden':
				char.y -= 50;
			case 'bambi-3d':
				char.x += 250;
				char.y = 600;
			case 'bambi-unfair':
				char.x += 200;
				char.y = 750;
		}
		add(char);
		funnyIconMan.changeIcon(char.curCharacter);
		funnyIconMan.color = FlxColor.WHITE;
		if (isLocked(characters[current].forms[curForm].name))
		{
			char.color = FlxColor.BLACK;
			funnyIconMan.color = FlxColor.BLACK;
			characterText.text = '???';
		}
		characterText.screenCenter(X);
		updateIconPosition();
		notemodtext.text = FlxStringUtil.formatMoney(currentSelectedCharacter.forms[curForm].noteMs[0])
			+ "x       "
			+ FlxStringUtil.formatMoney(currentSelectedCharacter.forms[curForm].noteMs[3])
			+ "x        "
			+ FlxStringUtil.formatMoney(currentSelectedCharacter.forms[curForm].noteMs[2])
			+ "x       "
			+ FlxStringUtil.formatMoney(currentSelectedCharacter.forms[curForm].noteMs[1])
			+ "x";
	}

	override function beatHit()
	{
		super.beatHit();
		if (char != null && !selectedCharacter && curBeat % 2 == 0)
		{
			char.playAnim('idle', true);
		}
	}

	function updateIconPosition()
	{
		// var xValues = CoolUtil.getMinAndMax(funnyIconMan.width, characterText.width);
		var yValues = CoolUtil.getMinAndMax(funnyIconMan.height, characterText.height);

		funnyIconMan.x = characterText.x + characterText.width / 2;
		funnyIconMan.y = characterText.y + ((yValues[0] - yValues[1]) / 2);
	}

	public function endIt(e:FlxTimer = null)
	{
		PlayState.characteroverride = currentSelectedCharacter.name;
		PlayState.formoverride = currentSelectedCharacter.forms[curForm].name;
		PlayState.curmult = currentSelectedCharacter.forms[curForm].noteMs;

		if (PlayState.SONG.song.toLowerCase() == "exploitation")
		{
			FlxG.save.data.exploitationState = 'in';
			FlxG.fullscreen = false;
			FlxG.sound.play(Paths.sound('error'), 0.9);

			#if windows
			Application.current.window.alert("Null Object Reference\nat PlayState.hx, line 60\nat ApplicationMain.hx, line 54\n\nUnexpected object: 'expunged'\nSee 'log.txt' for details",
				"Vs Dave");
			#end
		}

		LoadingState.loadAndSwitchState(new PlayState());
	}
}
