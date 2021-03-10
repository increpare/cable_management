import flixel.FlxSprite;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.IBitmapDrawable;

using DirUtils;

class KomponentKachel
{
	// colors:
	// 1,2,3...8 colours
	// 9 black..used just for multicomponents
	public var connections:Array<Int>; // clockwise from left side of top. negative input, positive output.
	public var offset:Position;

	public function serialize():String
	{
		return Std.string(connections) + ":" + offset.x + "," + offset.y;
	}

	public static function deserialize(s:String):KomponentKachel
	{
		var split = s.split(":");
		var position_ar = split[1].split(",").map(Std.parseInt);

		var offset = {x: position_ar[0], y: position_ar[1]};
		var connections = split[0].split(",").map(Std.parseInt);
		return new KomponentKachel(connections, offset);
	}

	public function new(connections:Array<Int>, offset:Position)
	{
		this.connections = connections;
		this.offset = {x: offset.x, y: offset.y};
	}

	public static var connektorcoordinaten:Array<Position> = [
		{x: 1, y: 0},
		{x: 2, y: 0},
		{x: 3, y: 1},
		{x: 3, y: 2},
		{x: 1, y: 3},
		{x: 2, y: 3},
		{x: 0, y: 1},
		{x: 0, y: 2},
	];

	public function drawToGraphic(pixels:BitmapData, offsetX:Int, offsetY:Int)
	{
		var g = makeGraphic();
		pixels.copyPixels(g.pixels, g.pixels.rect, new openfl.geom.Point(offsetX, offsetY));
	}

	public function makeGraphic():FlxSprite
	{
		var s = new FlxSprite(0, 0);
		var key = serialize();
		s.makeGraphic(7, 7, FlxColor.TRANSPARENT, false, key);

		var bmd = s.pixels;
		bmd.fillRect(new openfl.geom.Rectangle(1, 1, 5, 5), FlxColor.BLACK);
		bmd.fillRect(new openfl.geom.Rectangle(2, 2, 3, 3), FlxColor.TRANSPARENT);

		for (i => fidx in connections)
		{
			if (fidx == 0)
				continue;
			var input = fidx < 0;
			var farbe = WireSquare.verbindung_farben[(input ? -fidx : fidx) - 1];
			var pos = connektorcoordinaten[i];
			trace(StringTools.hex(farbe, 8));
			bmd.setPixel32(2 * pos.x, 2 * pos.y, farbe);
			if (input == false)
			{
				var px = 2 * pos.x;
				var py = 2 * pos.y;
				if (px == 6)
				{
					px--;
				}
				if (px == 0)
				{
					px++;
				}
				if (py == 6)
				{
					py--;
				}
				if (py == 0)
				{
					py++;
				}
				bmd.setPixel32(px, py, farbe);
			}
		}

		return s;
	}
}

class Komponent
{
	public var x:Int;
	public var y:Int;
	public var kacheln:Array<KomponentKachel>;
	public var name:String;
	public var wert:Int;

	public var breite:Int;
	public var hoehe:Int;

	public function enthieltPunkt(x:Int, y:Int):Bool
	{
		return x >= this.x && y >= this.y && x < this.x + breite && y < this.y + hoehe;
	}

	private static function shuffleArray<T>(ar:Array<T>):Void
	{
		var rand = new FlxRandom();
		var n = ar.length;

		// for i from 0 to n−2 do
		for (i in 0...n - 1)
		{
			// j ← random integer such that i ≤ j < n
			var j = rand.int(i, n - 1);

			// exchange a[i] and a[j]
			var el = ar[i];
			ar[i] = ar[j];
			ar[j] = el;
		}
	}

	public function new(name:String, wert:Int, kacheln:Array<KomponentKachel>)
	{
		this.x = 0;
		this.y = 0;
		this.kacheln = kacheln;
		this.name = name;
		this.wert = wert;
		// rechne breite/hoehe aus
		var xs = kacheln.map(k -> k.offset.x);
		var ys = kacheln.map(k -> k.offset.y);
		xs.sort((a, b) -> b - a);
		ys.sort((a, b) -> b - a);

		var x_max = xs[0];
		var y_max = ys[0];

		breite = x_max + 1;
		hoehe = y_max + 1;
	}

	public static function vonSilhouette(name:String, wert:Int, silhouetteString:String, gewunschteVerbindungen:Array<Int>):Komponent
	{
		var silhouetteraster = silhouetteString.split("|");

		// pad with 0s
		silhouetteraster = silhouetteraster.map(a -> "0" + a + "0");
		var breite = silhouetteraster[0].length;
		var paddingrow = "";
		for (i in 0...breite)
		{
			paddingrow += "0";
		}
		silhouetteraster.insert(0, paddingrow);
		silhouetteraster.insert(silhouetteraster.length, paddingrow);

		// zufällige drehung NO don't do this

		var komponentkacheln:Array<KomponentKachel> = [];
		var freiplaetze:Array<Array<Int>> = [];
		// erst bastele kacheln mit offsets
		for (y => rowstring in silhouetteraster)
		{
			for (x => char in rowstring.split(""))
			{
				if (char == "1")
				{
					var kachelIndex = komponentkacheln.length;

					var mask = [0, 0, 0, 0, 0, 0, 0, 0];

					if (silhouetteraster[y - 1].charAt(x) == '1')
					{
						// etwas daroben
						mask[0] = 5;
						mask[1] = 5;
					}
					else
					{
						freiplaetze.push([kachelIndex, 0]);
						freiplaetze.push([kachelIndex, 1]);
					}
					if (silhouetteraster[y + 1].charAt(x) == '1')
					{
						// etwas darunter
						mask[4] = -5;
						mask[5] = -5;
					}
					else
					{
						freiplaetze.push([kachelIndex, 4]);
						freiplaetze.push([kachelIndex, 5]);
					}
					if (silhouetteraster[y].charAt(x - 1) == '1')
					{
						// etwas links
						mask[6] = 5;
						mask[7] = 5;
					}
					else
					{
						freiplaetze.push([kachelIndex, 6]);
						freiplaetze.push([kachelIndex, 7]);
					}
					if (silhouetteraster[y].charAt(x + 1) == '1')
					{
						// etwas rechts
						mask[2] = -5;
						mask[3] = -5;
					}
					else
					{
						freiplaetze.push([kachelIndex, 2]);
						freiplaetze.push([kachelIndex, 3]);
					}
					var kc = new KomponentKachel(mask, {x: x - 1, y: y - 1});
					komponentkacheln.push(kc);
				}
			}
		}
		// liste von mögliche verbindungspünkte
		shuffleArray(freiplaetze);

		for (i => gewuenschteVerbindung in gewunschteVerbindungen)
		{
			var platz = freiplaetze[i];

			komponentkacheln[platz[0]].connections[platz[1]] = gewuenschteVerbindung;
		}
		return new Komponent(name, wert, komponentkacheln);
	}
}
