package;

import WireSquare;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		WireSquare.GenerateAll();
		addChild(new FlxGame(0, 0, PlayState));
	}
}
