class Zustand
{
	public var breite:Int;
	public var hoehe:Int;

	public var Inhalt:Array<KachelInhalt>;

	public function new(breite:Int, hoehe:Int)
	{
		this.breite = breite;
		this.hoehe = hoehe;
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
				case WireSquare(w):
					if (w.x == x && w.y == y)
					{
						return k;
					}
				case Komponent(komponent):
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
