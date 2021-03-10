import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.ui.FlxButton.FlxTypedButton;
import flixel.util.FlxColor;

/**
 * A button with `FlxBitmapText` field as a `label`.
 */
class FlxIconButton extends FlxTypedButton<FlxBitmapText>
{
	public function new(X:Float = 0, Y:Float = 0, path:FlxGraphicAsset, w:Int, h:Int, ?OnClick:Void->Void)
	{
		super(X, Y, OnClick);
		this.width = w;
		this.height = h;
		loadGraphic(path, true, w, h);
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
