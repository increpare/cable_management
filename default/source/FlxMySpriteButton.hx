import flixel.FlxSprite;
import flixel.math.FlxPoint;
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

	public function zentriere_Sprite():Void
	{
		var sprite = this.label;
		var w = this.width;
		var h = this.height;

		this.labelOffsets = [FlxPoint.get(), FlxPoint.get(), FlxPoint.get(0, 1)];
		// for (point in this.labelOffsets)
		// 	point.set(point.x - 1, point.y + 3);

		for (offset in this.labelOffsets)
		{
			offset.x += (w / 2) - sprite.width / 2;
			offset.y += (h / 2) - sprite.height / 2;
		}

		resetHelpers();
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
