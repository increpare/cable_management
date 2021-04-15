import flixel.FlxSprite;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.IBitmapDrawable;

using DirUtils;

enum KomponentKachelStromdarstellungszustand
{
	voll;
	teil;
	leer;
	keine;
}

class KomponentKachel
{
	// colors:
	// 1,2,3...8 colours
	// 9 black..used just for multicomponents (OR 5 actually?)
	public var connections:Array<Int>; // clockwise from left side of top. negative input, positive output.
	public var offset:Position;
	public var geladen:Bool;

	public function copy():KomponentKachel
	{
		return new KomponentKachel(connections.copy(), {x: offset.x, y: offset.y});
	}

	public function dreh(breite:Int, hoehe:Int, dir:Bool):KomponentKachel
	{
		if (dir)
		{
			var newConnections = new Array<Int>();
			for (i in 0...connections.length)
			{
				newConnections.push(connections[(i + 2) % connections.length]);
			}
			var newOffset = {x: offset.y, y: breite - offset.x - 1};
			return new KomponentKachel(newConnections, newOffset);
		}
		else
		{
			var newConnections = new Array<Int>();
			for (i in 0...connections.length)
			{
				newConnections.push(connections[(i - 2 + connections.length) % connections.length]);
			}
			var newOffset = {x: hoehe - offset.y - 1, y: offset.x};
			return new KomponentKachel(newConnections, newOffset);
		}
	}

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
		this.geladen = false;
	}

	public static var connektorcoordinaten:Array<Position> = [
		{x: 1, y: 0},
		{x: 2, y: 0},
		{x: 3, y: 1},
		{x: 3, y: 2},
		{x: 2, y: 3},
		{x: 1, y: 3},
		{x: 0, y: 2},
		{x: 0, y: 1},
	];

	public function drawToGraphic(bmd:BitmapData, offsetX:Int, offsetY:Int, ?alpha:Bool = false,
			stromdarstellung:KomponentKachelStromdarstellungszustand = keine)
	{
		bmd.fillRect(new openfl.geom.Rectangle(offsetX + 1, offsetY + 1, 5, 5), alpha ? 0x88000000 : FlxColor.BLACK);
		bmd.fillRect(new openfl.geom.Rectangle(offsetX + 2, offsetY + 2, 3, 3), stromdarstellung == voll ? 0xffedba4c : FlxColor.TRANSPARENT);

		if (stromdarstellung == keine) {}
		else if (stromdarstellung == teil)
		{
			bmd.setPixel32(offsetX + 3, offsetY + 3, 0xffedba4c);
		}
		else if (stromdarstellung == leer)
		{
			bmd.setPixel32(offsetX + 3, offsetY + 3, 0xff000000);
		}

		for (i => fidx in connections)
		{
			if (fidx == 0)
				continue;
			var input = fidx < 0;
			var farbe = WireSquare.verbindung_farben[(input ? -fidx : fidx) - 1];
			if (alpha)
			{
				var col = new FlxColor(farbe);
				col.alpha = 88;
				farbe = col;
			}
			var pos = connektorcoordinaten[i];
			// trace(StringTools.hex(farbe, 8));
			bmd.setPixel32(offsetX + 2 * pos.x, offsetY + 2 * pos.y, farbe);
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
				bmd.setPixel32(offsetX + px, offsetY + py, farbe);
			}
		}

		if (stromdarstellung == voll)
		{
			for (i => fidx in connections)
			{
				if (i % 2 == 1)
				{
					continue;
				}
				if (fidx == 0)
					continue;
				var input = fidx < 0;
				var farbe = WireSquare.verbindung_farben[(input ? -fidx : fidx) - 1];
				if (alpha)
				{
					var col = new FlxColor(farbe);
					col.alpha = 88;
					farbe = col;
				}

				if (farbe != 0xff000000)
				{
					continue;
				}
				farbe = 0xffedba4c;

				var pos = connektorcoordinaten[i];
				var pos2 = connektorcoordinaten[i + 1];
				var pos_mitte = {
					x: ((pos.x + pos2.x) / 2),
					y: ((pos.y + pos2.y) / 2)
				};

				var px = Math.round(2 * pos_mitte.x);
				var py = Math.round(2 * pos_mitte.y);

				trace(StringTools.hex(farbe, 8));
				bmd.setPixel32(offsetX + px, offsetY + py, farbe);

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
				bmd.setPixel32(offsetX + px, offsetY + py, farbe);
			}
		}
	}

	public function makeGraphic():FlxSprite
	{
		var s = new FlxSprite(0, 0);
		var key = serialize();
		s.makeGraphic(7, 7, FlxColor.TRANSPARENT, false, key);

		var bmd = s.pixels;
		drawToGraphic(bmd, 0, 0);

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

	// ob dieser die Quelle von Signalen ist oder nicht.
	public var initial:Bool;

	public var hatstrom:Bool;

	public function ueberlappt(x:Int, y:Int):Bool
	{
		for (k in kacheln)
		{
			if (k.offset.x + this.x == x && k.offset.y + this.y == y)
			{
				return true;
			}
		}
		return false;
	}

	public function enthieltPunkt(x:Int, y:Int):Bool
	{
		return x >= this.x && y >= this.y && x < this.x + breite && y < this.y + hoehe;
	}

	public function copy():Komponent
	{
		var k = new Komponent(name, wert, kacheln.map(k -> k.copy()), this.initial, this.hatstrom);
		k.x = this.x;
		k.y = this.y;
		return k;
	}

	public function dreh(dir:Bool):Komponent
	{
		var newX:Int = 0;
		var newY:Int = 0;
		var newBreite:Int = hoehe;
		var newHoehe:Int = breite;
		var newKacheln = kacheln.map(k -> k.dreh(breite, hoehe, dir));
		var newName = name;
		var newWert = wert;
		var newInitial = initial;
		var newHatstrom = hatstrom;
		return new Komponent(newName, newWert, newKacheln, newInitial, newHatstrom);
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

	public function renderTo(bmd:BitmapData, ox:Int, oy:Int, ?alpha:Bool = false):Void
	{
		for (kachel in kacheln)
		{
			kachel.drawToGraphic(bmd, ox + 7 * kachel.offset.x, oy + 7 * kachel.offset.y, alpha, keine);
		}
	}

	public function render():FlxSprite
	{
		var result = new FlxSprite(0, 0);
		result.makeGraphic(breite * 7, hoehe * 7, FlxColor.TRANSPARENT, true);
		var bmd = result.pixels;
		renderTo(bmd, 0, 0);
		return result;
	}

	public function new(name:String, wert:Int, kacheln:Array<KomponentKachel>, initial:Bool, hatstrom:Bool)
	{
		this.x = 0;
		this.y = 0;
		this.kacheln = kacheln;
		this.name = name;
		this.wert = wert;
		this.initial = initial;
		this.hatstrom = hatstrom;

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

	public function GetVerbindungFarbe(x:Int, y:Int, verbindungIndex):Int
	{
		var x_lokal = x - this.x;
		var y_lokal = y - this.y;
		for (kk in kacheln)
		{
			if (kk.offset.x == x_lokal && kk.offset.y == y_lokal)
			{
				return kk.connections[verbindungIndex];
			}
		}
		trace("ERROR: nothing found at " + x + "," + y);
		return 0;
	}

	public static function schattenFreiplatzzahl(silhouetteString:String):Int
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

		var freiplatzzahl:Int = 0;
		// erst bastele kacheln mit offsets
		for (y => rowstring in silhouetteraster)
		{
			for (x => char in rowstring.split(""))
			{
				if (char == "1")
				{
					if (silhouetteraster[y - 1].charAt(x) == '1')
					{
						// etwas daroben
					}
					else
					{
						freiplatzzahl += 2;
					}
					if (silhouetteraster[y + 1].charAt(x) == '1')
					{
						// etwas darunter
					}
					else
					{
						freiplatzzahl += 2;
					}
					if (silhouetteraster[y].charAt(x - 1) == '1')
					{
						// etwas links
					}
					else
					{
						freiplatzzahl += 2;
					}
					if (silhouetteraster[y].charAt(x + 1) == '1')
					{
						// etwas rechts
					}
					else
					{
						freiplatzzahl += 2;
					}
				}
			}
		}
		return freiplatzzahl;
	}

	public static function vonSilhouette(name:String, wert:Int, silhouetteString:String, gewunschteVerbindungen:Array<Int>, initial:Bool):Komponent
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
		return new Komponent(name, wert, komponentkacheln, initial, initial);
	}
}
