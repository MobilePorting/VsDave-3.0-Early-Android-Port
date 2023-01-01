package;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import Controls.KeyboardScheme;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.util.FlxTimer;
#if desktop
import Discord.DiscordClient;
#end

class OptionsMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	var controlsStrings:Array<String> = [];

	private var grpControls:FlxTypedGroup<Alphabet>;
	var versionShit:FlxText;

	var languages:Array<Language> = new Array<Language>();
	var currentLanguage:Int = 0;
	var curLanguage:String = LanguageManager.save.data.language;
	override function create()
	{
                Paths.clearUnusedMemory();
                Paths.clearStoredMemory();

		#if desktop
		DiscordClient.changePresence("In the Options Menu", null);
		#end
		var menuBG:FlxSprite = new FlxSprite();
		
		languages = LanguageManager.getLanguages();

		controlsStrings = CoolUtil.coolStringFile( 
			LanguageManager.getTextString('change_keybind')
			+ "\n" + (FlxG.save.data.newInput ? LanguageManager.getTextString('option_ghostTapping_on') : LanguageManager.getTextString('option_ghostTapping_off')) 
			+ "\n" + (FlxG.save.data.downscroll ? LanguageManager.getTextString('option_downscroll') : LanguageManager.getTextString('option_upscroll'))
			+ "\n" + (FlxG.save.data.songPosition ? LanguageManager.getTextString('option_songPosition_on') : LanguageManager.getTextString('option_songPosition_off'))
			+ "\n" + (FlxG.save.data.eyesores ? LanguageManager.getTextString('option_eyesores_enabled') : LanguageManager.getTextString('option_eyesores_disabled')) 
			+ "\n" + (FlxG.save.data.donoteclick ? LanguageManager.getTextString('option_selfAwareness_on') : LanguageManager.getTextString('option_selfAwareness_off'))
			+ "\n" + (FlxG.save.data.donoteclick ? LanguageManager.getTextString('option_hitsound_on') : LanguageManager.getTextString('option_hitsound_off'))
			+ "\n" + (FlxG.save.data.freeplayCuts ? LanguageManager.getTextString('option_freeplay_cutscenes_on') : LanguageManager.getTextString('option_freeplay_cutscenes_off'))
			+ "\n" + (FlxG.save.data.middlescroll ? LanguageManager.getTextString('option_middlescroll_on') : LanguageManager.getTextString('option_middlescroll_off'))
                        + "\n" + (FlxG.save.data.noteCamera ? LanguageManager.getTextString('option_noteCamera_on') : LanguageManager.getTextString('option_noteCamera_off'))
			+ "\n" + LanguageManager.getTextString('cur_language')
			);
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.antialiasing = true;
		menuBG.loadGraphic(MainMenuState.randomizeBG());
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...controlsStrings.length)
		{
				var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, controlsStrings[i], true, false);
				controlLabel.screenCenter(X);
				controlLabel.itemType = 'Vertical';
				controlLabel.isMenuItem = true;
				controlLabel.targetY = i;
				grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		versionShit = new FlxText(5, FlxG.height - 18, 0, "Offset (Left, Right): " + FlxG.save.data.offset, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

                #if mobile
                addVirtualPad(UP_DOWN, A_B_C);
                #end

                #if mobile
                var xd:FlxText = new FlxText(10, 14, 0, 'Press C to customize your android controls', 16);
                xd.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                xd.borderSize = 2.4;
                xd.scrollFactor.set();
                add(xd);
                #end

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

                #if mobile
                if (virtualPad.buttonC.justPressed)
                {
                removeVirtualPad();
		openSubState(new mobile.MobileControlsSubState());
                }
                #end

		if (controls.BACK)
			FlxG.switchState(new MainMenuState());
		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);

		if (controls.RIGHT_R)
		{
			FlxG.save.data.offset++;
			versionShit.text = "Offset (Left, Right): " + FlxG.save.data.offset;
		}

		if (controls.LEFT_R)
		{
			FlxG.save.data.offset--;
			versionShit.text = "Offset (Left, Right): " + FlxG.save.data.offset;
		}	
		if (controls.ACCEPT)
		{
			grpControls.remove(grpControls.members[curSelected]);
			switch(curSelected)
			{
				case 0:
					new FlxTimer().start(0.01, function(timer:FlxTimer)
					{
						FlxG.switchState(new ChangeKeybinds());
					});
					updateGroupControls(LanguageManager.getTextString('change_keybind'), 0, 'Vertical');
				case 1:
					FlxG.save.data.newInput = !FlxG.save.data.newInput;
					updateGroupControls((FlxG.save.data.newInput ? LanguageManager.getTextString('option_ghostTapping_on') : LanguageManager.getTextString('option_ghostTapping_off')), 1, 'Vertical');	
				case 2:
					FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
					updateGroupControls((FlxG.save.data.downscroll ? LanguageManager.getTextString('option_downscroll') : LanguageManager.getTextString('option_upscroll')), 2, 'Vertical');
				case 3:
					FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
					updateGroupControls((FlxG.save.data.songPosition ? LanguageManager.getTextString('option_songPosition_on') : LanguageManager.getTextString('option_songPosition_off')), 3, 'Vertical');	
				case 4:
					FlxG.save.data.eyesores = !FlxG.save.data.eyesores;
					updateGroupControls((FlxG.save.data.eyesores ? LanguageManager.getTextString('option_eyesores_enabled') : LanguageManager.getTextString('option_eyesores_disabled')), 4, 'Vertical');
				case 5:
					FlxG.save.data.selfAwareness = !FlxG.save.data.selfAwareness;
					updateGroupControls((FlxG.save.data.selfAwareness ? LanguageManager.getTextString('option_selfAwareness_on') : LanguageManager.getTextString('option_selfAwareness_off')), 5, 'Vertical');
				case 6:
					FlxG.save.data.donoteclick = !FlxG.save.data.donoteclick;
					updateGroupControls((FlxG.save.data.donoteclick ? LanguageManager.getTextString('option_hitsound_on') : LanguageManager.getTextString('option_hitsound_off')), 6, 'Vertical');
				case 7:
					FlxG.save.data.freeplayCuts = !FlxG.save.data.freeplayCuts;
					updateGroupControls((FlxG.save.data.freeplayCuts ? LanguageManager.getTextString('option_freeplay_cutscenes_on') : LanguageManager.getTextString('option_freeplay_cutscenes_off')), 7, 'Vertical');
                                case 8:
					FlxG.save.data.middlescroll = !FlxG.save.data.middlescroll;
					updateGroupControls((FlxG.save.data.middlescroll ? LanguageManager.getTextString('option_middlescroll_on') : LanguageManager.getTextString('option_middlescroll_off')), 8, 'Vertical');
				case 9:
					FlxG.save.data.noteCamera = !FlxG.save.data.noteCamera;
					updateGroupControls((FlxG.save.data.noteCamera ? LanguageManager.getTextString('option_noteCamera_on') : LanguageManager.getTextString('option_noteCamera_off')), 9, 'Vertical');
				case 10:
					updateGroupControls(LanguageManager.getTextString('cur_language'), 9, 'Vertical');
					FlxG.switchState(new ChangeLanguageState());
			}
		}
	}

	var isSettingControl:Bool = false;

	override function beatHit()
	{
		super.beatHit();
		FlxTween.tween(FlxG.camera, {zoom:1.05}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
	}
	function updateGroupControls(controlText:String, yIndex:Int, controlTextItemType:String)
	{
		var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, controlText, true, false);
		ctrl.screenCenter(X);
		ctrl.isMenuItem = true;
		ctrl.targetY = curSelected - yIndex;
		ctrl.itemType = controlTextItemType;
		grpControls.add(ctrl);
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end
		
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
