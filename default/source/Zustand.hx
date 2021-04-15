import DirUtils.Position;
import KachelInhalt.KachelZustand;
import flixel.util.FlxColor;
import lime.math.Rectangle;
import openfl.display.BitmapData;
import openfl.display.GraphicsQuadPath;

enum VerbindungTyp
{
	eingabe;
	ausgabe;
	draht;
}

typedef ConnectionData =
{
	var kx:Int;
	var ky:Int;
	var kcon:Int;
	var target:KachelInhalt;
	var id:Int;
}

class Zustand
{
	public var breite:Int;
	public var hoehe:Int;
	public var Inhalt:Array<KachelInhalt>;
	public var geloest:String;
	public var komponentzahl:Int;
	public var offeneAusgaben:Array<Int>;

	public function new(breite:Int, hoehe:Int)
	{
		this.offeneAusgaben = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		this.breite = breite;
		this.hoehe = hoehe;
		this.Inhalt = [];
		this.geloest = "TRUE";
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

	private static function connectionDatasConnect(a:ConnectionData, b:ConnectionData):Bool
	{
		var b_flipped = flipConnectionData(b);
		return a.kx == b_flipped.kx && a.ky == b_flipped.ky && a.kcon == b_flipped.kcon;
	}

	private static function getConnDat(connections:Array<ConnectionData>, kx:Int, ky:Int, kcon:Int):ConnectionData
	{
		for (kd in connections)
		{
			if (kd.kx == kx && kd.ky == ky && kd.kcon == kcon)
			{
				return kd;
			}
		}
		return null;
	}

	private static function flipConnectionData(a:ConnectionData)
	{
		var offsets:Array<Position> = [
			{x: 0, y: -1},
			{x: 0, y: -1},
			{x: 1, y: 0},
			{x: 1, y: 0},
			{x: 0, y: 1},
			{x: 0, y: 1},
			{x: -1, y: 0},
			{x: -1, y: 0},
		];
		var flipConnectionIndex:Array<Int> = [5, 4, 7, 6, 1, 0, 3, 2];

		var offset = offsets[a.kcon];
		return {
			kx: a.kx + offset.x,
			ky: a.ky + offset.y,
			kcon: flipConnectionIndex[a.kcon],
			target: a.target,
			id: a.id
		};
	}

	private static function setFarbe(a:ConnectionData, farbe:Int)
	{
		switch (a.target)
		{
			case WireSquare(w, z):
				for (p in w.paths)
				{
					if (p.startConnectionIndex() == a.kcon)
					{
						p.farbe = farbe;
					}
					if (p.endConnectionIndex() == a.kcon)
					{
						p.farbe = farbe;
					}
				}
			case Komponent(k, z):
			// NFI
			case Leer:
		}
	}

	public function rechneSignaleAus():Void
	{
		for (i in 0...offeneAusgaben.length)
		{
			offeneAusgaben[i] = 0;
		}

		for (ki in Inhalt)
		{
			switch (ki)
			{
				case WireSquare(w, z):
					for (p in w.paths)
					{
						p.farbe = 4;
					}
				case Komponent(k, z):
					k.hatstrom = k.initial;
					for (kc in k.kacheln)
					{
						kc.geladen = k.hatstrom;
					}
				case Leer:
			}
		}

		var SignalTeile:Array<ConnectionData> = [];
		var id_counter = 0;

		komponentzahl = 0;
		geloest = "No components placed yet.";

		for (ki in Inhalt)
		{
			switch (ki)
			{
				case WireSquare(w, z):
					for (p in w.paths)
					{
						var neue_id = id_counter++;
						var ks:ConnectionData = {
							kx: w.x,
							ky: w.y,
							kcon: p.startConnectionIndex(),
							target: ki,
							id: neue_id
						}
						SignalTeile.push(ks);

						var ke:ConnectionData = {
							kx: w.x,
							ky: w.y,
							kcon: p.endConnectionIndex(),
							target: ki,
							id: neue_id
						}
						SignalTeile.push(ke);
					}
				case Komponent(k, z):
					komponentzahl++;
					if (z == Geplant)
					{
						geloest = "TRUE";
					}
					if (z == KachelZustand.Geplant) {}
					k.hatstrom = k.initial;
					for (kc in k.kacheln)
					{
						for (connectionindex => farbe in kc.connections)
						{
							if (farbe == 0 || farbe == 5 || farbe == -5)
								continue;

							var connectionData:ConnectionData = {
								kx: k.x + kc.offset.x,
								ky: k.y + kc.offset.y,
								kcon: connectionindex,
								target: ki,
								id: id_counter++
							}
							SignalTeile.push(connectionData);
						}
					}
				case Leer:
			}
		}

		var modifiziert:Bool = true;
		while (modifiziert)
		{
			modifiziert = false;

			for (i => st_i in SignalTeile)
			{
				for (j => st_j in SignalTeile)
				{
					if (j < i)
					{
						continue;
					}
					if (connectionDatasConnect(st_i, st_j))
					{
						if (st_i.id != st_j.id)
						{
							var minid = st_i.id < st_j.id ? st_i.id : st_j.id;
							var maxid = st_i.id < st_j.id ? st_j.id : st_i.id;
							for (i => st_k in SignalTeile)
							{
								if (st_k.id == maxid)
								{
									st_k.id = minid;
								}
							}
							modifiziert = true;
						}
					}
				}
			}
		}

		var gruppiert:Map<Int, Array<ConnectionData>> = [];
		for (st in SignalTeile)
		{
			var gruppe = gruppiert[st.id];
			if (gruppe == null)
			{
				gruppe = [];
				gruppiert[st.id] = gruppe;
			}
			gruppe.push(st);
		}

		for (id => gruppe in gruppiert)
		{
			var gruppeFarbe = 4;

			var eingaben:Array<ConnectionData> = [];
			var ausgaben:Array<ConnectionData> = [];
			var draht:Array<ConnectionData> = [];
			for (cd in gruppe)
			{
				switch (cd.target)
				{
					case WireSquare(w, z):
						draht.push(cd);
					case Komponent(k, z):
						var farbe = k.GetVerbindungFarbe(cd.kx, cd.ky, cd.kcon);
						if (farbe > 0 && farbe != 5)
						{
							offeneAusgaben[farbe]++;
							ausgaben.push(cd);
						}
						else if (farbe < 0)
						{
							offeneAusgaben[-farbe]--;
							eingaben.push(cd);
						}
					case Leer:
				}
			}

			if (ausgaben.length == 0)
			{
				gruppeFarbe = 4;
				if (eingaben.length > 0)
				{
					geloest = "Not all inputs are connected.";
				}
			}
			else if (ausgaben.length > 1)
			{
				gruppeFarbe = 5; // Farbe der Ungueltigkeit
				geloest = "Multiple outputs are connected together.";
			}
			else if (eingaben.length > 1)
			{
				gruppeFarbe = 5; // Farbe der Ungueltigkeit
				geloest = "Multiple inputs are connected together";
			}
			else if (eingaben.length == 1)
			{ // eine Aufgabe, eine Eingabe
				var eingabe_kd = eingaben[0];
				var eingabekomponent = switch (eingabe_kd.target)
				{
					case Komponent(k, z): k;
					default: null;
				};
				var eingabe_farbe = eingabekomponent.GetVerbindungFarbe(eingabe_kd.kx, eingabe_kd.ky, eingabe_kd.kcon);

				var ausgabe_kd = ausgaben[0];
				var ausgabekomponent = switch (ausgabe_kd.target)
				{
					case Komponent(k, z): k;
					default: null;
				};
				var ausgabe_farbe = ausgabekomponent.GetVerbindungFarbe(ausgabe_kd.kx, ausgabe_kd.ky, ausgabe_kd.kcon);

				if (eingabekomponent.x == ausgabekomponent.x && eingabekomponent.y == ausgabekomponent.y)
				{
					gruppeFarbe = 5;
					geloest = "Can't connect component to itself.";
				}
				else if (eingabe_farbe == -ausgabe_farbe)
				{
					gruppeFarbe = ausgabe_farbe - 1;
				}
				else
				{
					gruppeFarbe = 5;
					geloest = "Trying to connect two sockets of different colours.";
				}
			}
			else
			{
				var ausgabe_kd = ausgaben[0];
				var ausgabekomponent = switch (ausgabe_kd.target)
				{
					case Komponent(k, z): k;
					default: null;
				};
				var ausgabe_farbe = ausgabekomponent.GetVerbindungFarbe(ausgabe_kd.kx, ausgabe_kd.ky, ausgabe_kd.kcon);
				gruppeFarbe = ausgabe_farbe - 1;
			}

			for (kd in draht)
			{
				setFarbe(kd, gruppeFarbe);
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
