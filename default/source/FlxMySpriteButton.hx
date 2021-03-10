import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.ui.FlxButton.FlxTypedButton;
import flixel.util.FlxColor;

class FlxMySpriteButton extends FlxTypedButton<FlxSprite>
{
	public function new(X:Float = 0, Y:Float = 0, w:Int, h:Int, sprite:FlxSprite, bg_image:FlxGraphicAsset, ?OnClick:Void->Void)
	{
		super(X, Y, OnClick);
		this.width = w;
		this.height = h;
		loadGraphic(bg_image, true, w, h);
		for (offset in this.labelOffsets)
		{
			offset.x += (w / 2) - sprite.width / 2;
			offset.y += (h / 2) - sprite.height / 2;
		}

		this.label = sprite;
	}

	/**
	 * Updates the size of the text field to match the button.
	 */
	override function resetHelpers():Void
	{
		super.resetHelpers();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
