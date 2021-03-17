import DirUtils.Position;
import flixel.util.FlxColor;
import lime.math.Rectangle;
import openfl.display.BitmapData;

class Zustand
{
	public var breite:Int;
	public var hoehe:Int;
	public var Inhalt:Array<KachelInhalt>;

	public function new(breite:Int, hoehe:Int)
	{
		this.breite = breite;
		this.hoehe = hoehe;
		this.Inhalt = [];
	}

	public function getInhaltMask(nurfest:Bool, ignorieregeplanntekomponent:Bool):Array<Position>
	{
		var result = [];
		for (ki in Inhalt)
		{
			switch (ki)
			{
				case WireSquare(w, z):
					if (nurfest && z == Geplant)
					{
						continue;
					}

					result.push({x: w.x, y: w.y});
				case Komponent(k, z):
					if (nurfest && z == Geplant)
					{
						continue;
					}
					if (ignorieregeplanntekomponent && z == Geplant)
					{
						continue;
					}
					result = result.concat(k.kacheln.map(kk -> {x: kk.offset.x + k.x, y: kk.offset.y + k.y}));
				case Leer:
					return [];
			}
		}
		return result;
	}

	public function removeAt(x:Int, y:Int)
	{
		for (i => ki in Inhalt)
		{
			switch (ki)
			{
				case WireSquare(w, z):
					if (w.x == x && w.y == y)
					{
						Inhalt.splice(i, 1);
						return;
					}
				case Komponent(k, z):
					if (k.ueberlappt(x, y))
					{
						Inhalt.splice(i, 1);
						return;
					}
				case Leer:
			}
		}
	}

	public function rechneSignaleAus():Void
	{
		for (ki in Inhalt)
		{
			switch (ki)
			{
				case WireSquare(w, z):
					for (p in w.paths)
					{
						p.farbe = -1;
					}
				case Komponent(k, z):

				case Leer:
			}
		}
	}

	public function render(pixels:BitmapData, ?alphageplannterKomponent:Bool = false):Void
	{
		pixels.fillRect(pixels.rect, FlxColor.TRANSPARENT);
		for (el in Inhalt)
		{
			switch (el)
			{
				case WireSquare(w, z):
					if (z == Geplant)
					{
						pixels.fillRect(new openfl.geom.Rectangle(PlayState.kachel_breite * w.x, PlayState.kachel_hoehe * w.y, PlayState.kachel_breite,
							PlayState.kachel_hoehe),
							0x99ffeab0);
					}
					w.render(pixels, PlayState.kachel_breite * w.x, PlayState.kachel_hoehe * w.y);
				case Komponent(komponent, z):
					if (z == Geplant)
					{
						var ms = komponent.kacheln.map(k -> {x: k.offset.x + komponent.x, y: k.offset.y + komponent.y});
						for (m in ms)
						{
							pixels.fillRect(new openfl.geom.Rectangle(PlayState.kachel_breite * m.x, PlayState.kachel_hoehe * m.y, PlayState.kachel_breite,
								PlayState.kachel_hoehe),
								0xbb86d19d);
						}
					}
					komponent.renderTo(pixels, PlayState.kachel_breite * komponent.x,
						PlayState.kachel_hoehe * komponent.y, z == Geplant && alphageplannterKomponent);
				case Leer:
					// sollte heirhin nicht reinkommen können
			}
		}
	}

	public function enthieltPunkt(x:Int, y:Int):Bool
	{
		return x >= 0 && y >= 0 && x < 0 + breite && y < 0 + hoehe;
	}

	public function getKachel(x:Int, y:Int):KachelInhalt
	{
		for (k in Inhalt)
		{
			switch (k)
			{
				case WireSquare(w, _):
					if (w.x == x && w.y == y)
					{
						return k;
					}
				case Komponent(komponent, _):
					if (komponent.enthieltPunkt(x, y))
					{
						return k;
					}
				case Leer:
					// sollte heirhin nicht reinkommen können
			}
		}

		return Leer;
	}

	public function fitKomponent(k:Komponent)
	{
		if (k.x < 0)
		{
			k.x = 0;
		}
		if (k.y < 0)
		{
			k.y = 0;
		}
		if (k.x + k.breite > breite)
		{
			k.x = breite - k.breite;
		}
		if (k.y + k.hoehe > hoehe)
		{
			k.y = hoehe - k.hoehe;
		}
	}
}
