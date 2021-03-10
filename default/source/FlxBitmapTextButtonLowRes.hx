import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.ui.FlxButton.FlxTypedButton;
import flixel.util.FlxColor;

/**
 * A button with `FlxBitmapText` field as a `label`.
 */
class FlxBitmapTextButtonLowRes extends FlxTypedButton<FlxBitmapText>
{
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Void->Void)
	{
		super(X, Y, OnClick);
		this.width = 43;
		this.height = 15;
		loadGraphic("assets/images/button.png", true, 43, 15);

		if (Label != null)
		{
			label = new FlxBitmapText();
			label.width = 43;
			label.text = Label;
			label.color = 0xFF333333;
			label.useTextColor = true;
			label.alignment = FlxTextAlign.CENTER;

			for (offset in labelOffsets)
			{
				offset.set(0, 5);
			}
			labelOffsets[2].set(0, 6);

			label.x = X + labelOffsets[status].x;
			label.y = Y + labelOffsets[status].y;

			label.color = FlxColor.BLACK;

			label.autoSize = false;
			label.useTextColor = true;
			label.fieldWidth = 43;
			label.height = 15;
			label.alignment = FlxTextAlign.CENTER;
			label.offset.y = 0;
			var t = label.height; // just to force calculation

			if (label.textHeight > 9)
			{
				label.offset.y = 3;
			}
		}
	}

	/**
	 * Updates the size of the text field to match the button.
	 */
	override function resetHelpers():Void
	{
		super.resetHelpers();

		if (label != null)
		{
			label.width = width;
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (label != null)
		{
			label.update(elapsed);
		}
	}
}
