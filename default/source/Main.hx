package;

import WireSquare;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(177, 97, TitleScreen));
	}
}
