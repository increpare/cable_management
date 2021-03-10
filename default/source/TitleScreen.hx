package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.ui.FlxBitmapTextButton;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import lime.utils.Assets;

class TitleScreen extends FlxState
{
	var _playButton:FlxTypedButton<FlxBitmapText>;
	var _continueButton:FlxTypedButton<FlxBitmapText>;
	var _continueButton_disabled:FlxDisabledButton;

	function onNewGame()
	{
		onFade();
		// FlxG.sound.play(FlxAssets.getSound("assets/sounds/menu_hit_2"));
	}

	function onContinue()
	{
		onFade();
		// FlxG.sound.play(FlxAssets.getSound("assets/sounds/menu_hit_2"));
	}

	function onFade():Void
	{
		FlxG.switchState(new PlayState());
	}

	public static var fontAngelCode:FlxBitmapFont;

	override public function create()
	{
		super.create();

		this.bgColor = PlayState.COL_BG;

		if (fontAngelCode == null)
		{
			var textBytes = Assets.getText("assets/fonts/pixel.fnt");
			var XMLData = Xml.parse(textBytes);
			fontAngelCode = FlxBitmapFont.fromAngelCode("assets/fonts/pixel_0.png", XMLData);
		}

		var text = new FlxBitmapText(fontAngelCode);
		text.text = "KABELSALAT";
		text.x = 0;
		text.y = 20;
		text.scale.x = 2;
		text.scale.y = 2;
		text.autoSize = false;
		text.fieldWidth = FlxG.width;
		text.alignment = CENTER;
		text.color = FlxColor.WHITE;
		add(text);

		_playButton = new FlxBitmapTextButtonLowRes(FlxG.width / 2 - 43 / 2, text.y + text.height + 15, "NEW GAME", onNewGame);
		_playButton.label.font = fontAngelCode;
		_playButton.color = PlayState.COL_BG;

		add(_playButton);

		_continueButton = new FlxBitmapTextButtonLowRes(FlxG.width / 2 - 43 / 2, _playButton.y + _playButton.height + 3, "CONTINUE", onContinue);
		_continueButton.label.font = fontAngelCode;
		_continueButton.color = _playButton.color;
		_continueButton.label.color = _playButton.label.color;

		_continueButton.visible = false;

		add(_continueButton);

		_continueButton_disabled = new FlxDisabledButton(FlxG.width / 2 - 43 / 2, 60, "CONTINUE", onContinue);
		_continueButton_disabled.label.font = fontAngelCode;

		_continueButton_disabled.color = FlxColor.GRAY;
		_continueButton_disabled.label.color = FlxColor.BLACK;

		add(_continueButton_disabled);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
