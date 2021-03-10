import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.ui.FlxButton.FlxTypedButton;
import flixel.util.FlxColor;

class FlxMySpriteSelectedButton extends FlxTypedGroup<FlxSprite>
{
	public function new(X:Float = 0, Y:Float = 0, w:Int, h:Int, sprite:FlxSprite, bg_image:FlxGraphicAsset)
	{
		super();
		var bg = new FlxSprite(w, h);
		bg.loadGraphic(bg_image, true, w, h);
		bg.animation.add("selected", [3], 1, false);
		bg.animation.play("selected", true, false);
		bg.x = X;
		bg.y = Y;
		add(bg);

		sprite.x = X + (w / 2) - sprite.width / 2;
		sprite.y = Y + (h / 2) - sprite.height / 2;
		add(sprite);
	}
}
