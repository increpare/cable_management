package;

import DirUtils.Position;
import KachelInhalt.KachelZustand;
import Komponent.KomponentKachel;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import openfl.display.BitmapData;

typedef RankInfo =
{
	var rankThreshold:Int;
	var name:String;
}

class PlayState extends FlxState
{
	var brett_ox:Int = 18;
	var brett_oy:Int = 39;

	public static inline var kachel_breite:Int = 7;
	public static inline var kachel_hoehe:Int = 7;

	public static inline var brett_breite:Int = 63;
	public static inline var brett_hoehe:Int = 56;

	public static inline var raster_breite:Int = 12;
	public static inline var raster_hoehe:Int = 8;

	private var kabelkacheln:Array<WireSquare> = [
		"1,0,3", "1,0,0,0", "1,0,0,3", "1,0,2,2", "1,0,0,2,0", "1,0,0,2,3", "2,0,0,2", "2,0,0,3,2", "1,0,3:2,0,2", "1,0,3:2,0,0,0", "1,0,3:2,0,0,2",
		"1,0,3:2,0,0,3,0", "1,0,3:2,0,0,3,2", "1,0,3:3,1,2,0", "1,0,3:3,1,2,2", "1,0,3:3,1,2,3,0", "1,0,3:3,1,2,3,2", "1,0,3:3,2,2", "1,0,3:3,2,0,2",
		"1,0,3:1,3,3,3", "1,0,0,0:2,0,2", "1,0,0,0:2,0,0,0", "1,0,0,0:2,0,0,2", "1,0,0,0:2,0,3,0", "1,0,0,0:2,0,0,3,0", "1,0,0,0:3,1,2,0", "1,0,0,0:3,1,2,2",
		"1,0,0,0:3,1,2,3,0", "1,0,0,3:2,0,2", "1,0,0,3:2,0,0,2", "1,0,0,3:2,0,3,0", "1,0,0,3:3,1,2,0", "1,0,0,3:3,1,2,2", "1,0,2,0:2,0,0,0",
		"1,0,2,0:2,0,0,3,0", "1,0,2,0:2,0,0,3,2", "1,0,2,2:3,2,0,2", "1,0,2,2:1,3,3,3", "1,0,0,2,0:2,0,0,0", "1,0,0,2,0:2,0,3,0", "1,0,0,2,3:2,0,3,0",
		"2,0,0,0:3,1,0,2,2,0", "2,0,3,0:3,2,0,2"
	].map(WireSquare.deserialize);

	var kachelleiste:Array<WireSquare>;
	var kacheltasten:Array<FlxSprite>;
	var kacheltasten_ausgewaehlt:Array<FlxSprite>;

	var komponent:Komponent;
	var komponentTaste:FlxMySpriteButton;
	var komponentTaste_ausgewaehlt:FlxMySpriteSelectedButton;
	var komponentText:FlxBitmapText;
	var tooltipboundary:FlxSprite;
	var tooltipbg:FlxSprite;
	var tooltip:FlxBitmapText;
	var errorText:FlxBitmapText;

	var tooltips:Map<FlxObject, String> = [];

	public var rank:Int;

	public static var charIndices:Map<String, Int> = [
		"a" => 0, "b" => 1, "c" => 2, "d" => 3, "e" => 4, "f" => 5, "g" => 6, "h" => 7, "i" => 8, "j" => 9, "k" => 10, "l" => 11, "m" => 12, "n" => 13,
		"o" => 14, "p" => 15, "q" => 16, "r" => 17, "s" => 18, "t" => 19, "u" => 20, "v" => 21, "w" => 22, "x" => 23, "y" => 24, "z" => 25, "." => 26,
		"," => 27, "!" => 28, "€" => 29, "0" => 30, "1" => 31, "2" => 32, "3" => 33, "4" => 34, "5" => 35, "6" => 36, "7" => 37, "8" => 38, "9" => 39,
		"(" => 40, ")" => 41, " " => 42, "%" => 43, // st
		"^" => 44, // nd
		"&" => 45, // rd
		"*" => 46, // th
	];
	public static var MAXRANK:Int = 39;
	public static var RANK:Int = MAXRANK;
	public static var RANKINFO:Array<RankInfo> = [
		{
			rankThreshold: 39,
			name: "Amateur Cable Management consusltant",
		},
		{
			rankThreshold: 30,
			name: "Computer build specialist",
		},
		{
			rankThreshold: 23,
			name: "Microcip designer",
		},
		{
			rankThreshold: 15,
			name: "Cyborg implant specialist",
		},
		{
			rankThreshold: 7,
			name: "Genetics research facility",
		},
	];
	public static inline var COL_BG:FlxColor = 0xff9cabb1;
	public static inline var COL_BLACK:FlxColor = 0xff000000;
	public static inline var COL_TILE_DARK:FlxColor = COL_BG;
	public static inline var COL_TILE_LIGHT:FlxColor = 0xff9badb7;

	var _bg:FlxSprite;

	private function onMakeSale() {}

	var rand:FlxRandom = new FlxRandom();

	private function aktualiziereOberflaeche():Void
	{
		makeSaleBtn.visible = zustand.geloest == "TRUE";
		addPartBtn.visible = zustand.geloest == "TRUE";
		errorText.visible = zustand.geloest != "TRUE";
		errorText.text = "ERROR: " + zustand.geloest;
	}

	private var schatten_masken:Array<String> = ["10|10|11", "1", "11", "11|10", "1111", "111", "111|111", "11|11"];
	private var namen:Array<String> = ["cpu", "psu", "gpu", "heat sink", "ram", "ssd"];

	private function onAddPart()
	{
		zustand.Inhalt = zustand.Inhalt.map(ki ->
		{
			switch (ki)
			{
				case WireSquare(w, z):
					return KachelInhalt.WireSquare(w, Fest);
				case Komponent(k, z):
					return KachelInhalt.Komponent(k, Fest);
				case Leer:
					return KachelInhalt.Leer;
			}
		});
		zustand.rechneSignaleAus();
		zustand.render(zustandSprite.pixels, ausgewaehlterKachelIndex == 0);
		aktualiziereOberflaeche();

		neuerKomponent();
	}

	private function neuerKomponent()
	{
		var schatten_mask:String = rand.getObject(schatten_masken);
		var name:String = rand.getObject(namen);

		var ausgabe_pool = [];
		for (c => f in zustand.offeneAusgaben)
		{
			for (i in 0...f)
			{
				ausgabe_pool.push(c);
			}
		}
		trace("ausgabe_pool", ausgabe_pool);
		rand.shuffle(ausgabe_pool);
		trace("ausgabe_pool postshuffle", ausgabe_pool);

		trace("zustand.offeneAusgaben", zustand.offeneAusgaben);

		var eingabeZahl = rand.weightedPick([50, 10, 1]) + 1;
		var ausgabeZahl = rand.weightedPick([40, 30, 20, 10]);

		if (eingabeZahl == zustand.offeneAusgaben.length && ausgabeZahl == 0)
		{
			ausgabeZahl = 1;
		}

		if (eingabeZahl > ausgabe_pool.length)
		{
			eingabeZahl = ausgabe_pool.length;
		}

		trace("eingabeZahl", eingabeZahl);
		trace("ausgabeZahl", ausgabeZahl);

		var verbindungen = ausgabe_pool.slice(0, eingabeZahl).map((z) -> -z);
		for (i in 0...ausgabeZahl)
		{
			verbindungen.push(rand.getObject([1, 2, 3]));
		}
		var freiplatzZahl = Komponent.schattenFreiplatzzahl(schatten_mask);
		while (verbindungen.length < freiplatzZahl)
		{
			verbindungen.push(0);
		}
		trace("verbindungen", verbindungen);
		rand.shuffle(verbindungen);
		trace("verbindungen postshuffle", verbindungen);

		komponent = Komponent.vonSilhouette(name, 100 * eingabeZahl * eingabeZahl, schatten_mask, verbindungen, true);
		komponentTaste.label.loadGraphicFromSprite(komponent.render());
		komponentTaste.zentriere_Sprite();
		komponentTaste_ausgewaehlt.members[1].loadGraphicFromSprite(komponent.render());
		komponentTaste_ausgewaehlt.zentriere_Sprite();
		ausgewaehlterKachel_Spr.loadGraphicFromSprite(auswahltasten[0].label);

		komponentText.text = komponent.name + " (E" + komponent.wert + 4 + ")";
	}

	private function onMutedClick()
	{
		FlxG.sound.muted = !FlxG.sound.muted;
		updateMuteUI();
	}

	private function onUnmutedClick()
	{
		FlxG.sound.muted = !FlxG.sound.muted;
		updateMuteUI();
	}

	private function onHelpClick() {}

	private function onExitClick() {}

	var makeSaleBtn:FlxBitmapTextButtonLowRes;
	var addPartBtn:FlxBitmapTextButtonLowRes;
	var exitBtn:FlxIconButton;
	var mutedBtn:FlxIconButton;
	var unmutedBtn:FlxIconButton;
	var helpBtn:FlxIconButton;
	var drehBtnDisabled:FlxSprite;
	var drehBtn:FlxIconButton;
	var gummiBtn:FlxMySpriteButton;
	var zustandSprite:FlxSprite;

	private function updateMuteUI()
	{
		mutedBtn.visible = FlxG.sound.muted;
		unmutedBtn.visible = !FlxG.sound.muted;
	}

	var auswahltasten:Array<FlxMySpriteButton> = [];
	var auswahltasten_ausgewaehlt:Array<FlxMySpriteSelectedButton> = [];
	var ausgewaehlterKachel_Spr:FlxSprite;
	var ausgewaehlterKachel:KachelInhalt;
	var ausgewaehlterKachelIndex:Int = -1;

	private function onKachelAuswahl(i:Int)
	{
		trace(i);
		ausgewaehlterKachelIndex = i;
		for (k in 0...auswahltasten_ausgewaehlt.length)
		{
			if (k == i)
			{
				auswahltasten[k].visible = false;
				auswahltasten[k].label.visible = false;
				auswahltasten_ausgewaehlt[k].visible = true;
			}
			else
			{
				auswahltasten[k].visible = true;
				auswahltasten[k].label.visible = true;

				auswahltasten_ausgewaehlt[k].visible = false;
			}
		}

		ausgewaehlterKachel_Spr.loadGraphicFromSprite(auswahltasten[i].label);

		if (i == 0)
		{
			ausgewaehlterKachel = Komponent(komponent, Geplant);
		}
		else
		{
			ausgewaehlterKachel = WireSquare(kachelleiste[i - 1], Geplant);
		}
		zustand.rechneSignaleAus();
		zustand.render(zustandSprite.pixels, ausgewaehlterKachelIndex == 0);
		aktualiziereOberflaeche();

		if (ausgewaehlterKachelIndex == 4)
		{
			drehBtn.visible = false;
			drehBtnDisabled.visible = true;
		}
		else
		{
			drehBtn.visible = true;
			drehBtnDisabled.visible = false;
		}
	}

	private static var rankSpr:FlxSprite;

	private var rankTxt:FlxBitmapText;

	private function machRankSprite():Void
	{
		if (rankSpr != null)
		{
			return;
		}

		rankSpr = new FlxSprite(9, 17);
		var bmd = new BitmapData(4 * 39, 77, true, FlxColor.TRANSPARENT);
		for (i in 0...39)
		{
			bmd.fillRect(new openfl.geom.Rectangle(4 * i, 76 - 2 * i, 4 * 38, 1), FlxColor.BLACK);
		}

		rankSpr.loadGraphic(bmd, true, 4, 77);
		for (i in 0...39)
		{
			rankSpr.animation.add("" + (i + 1), [i], 0, false);
		}
	}

	override public function create()
	{
		super.create();

		this.rank = 7;
		this.bgColor = COL_BG;

		_bg = new FlxSprite(0, 0, "assets/images/bg.png");
		add(_bg);

		machRankSprite();
		add(rankSpr);
		rankSpr.animation.play("" + rank);
		tooltips[rankSpr] = "Current rank: " + rank + ". The better you do in a level, the high your rank jumps!";

		rankTxt = new FlxBitmapText(TitleScreen.fontAngelCode);
		rankTxt.color = FlxColor.BLACK;

		rankTxt.text = "" + rank;
		rankTxt.angle = 270;
		if (rankTxt.text.length == 2)
		{
			rankTxt.x = 0;
			rankTxt.y = 64;
		}
		else
		{
			rankTxt.x = 2;
			rankTxt.y = 66;
		}
		rankTxt.origin.x = 0;
		rankTxt.origin.y = 0;
		add(rankTxt);

		makeSaleBtn = new FlxBitmapTextButtonLowRes(104, 40, "Make Sale", onMakeSale);
		makeSaleBtn.label.font = TitleScreen.fontAngelCode;
		makeSaleBtn.color = PlayState.COL_BG;
		tooltips[makeSaleBtn] = "Click on this to sell close the contract and sell the system!";

		add(makeSaleBtn);

		addPartBtn = new FlxBitmapTextButtonLowRes(104, 56, "Add extra part", onAddPart);
		addPartBtn.label.font = TitleScreen.fontAngelCode;
		addPartBtn.color = PlayState.COL_BG;
		add(addPartBtn);
		tooltips[addPartBtn] = "Confirm the current part placement and see about adding another part.";

		exitBtn = new FlxIconButton(185, 1, "assets/images/audio_icon_exit.png", 12, 12, onExitClick);
		exitBtn.color = PlayState.COL_BG;
		add(exitBtn);
		tooltips[exitBtn] = "Leave to title screen";

		mutedBtn = new FlxIconButton(185, 14, "assets/images/audio_icon_muted.png", 12, 12, onMutedClick);
		mutedBtn.color = PlayState.COL_BG;
		add(mutedBtn);
		tooltips[mutedBtn] = "Unmute the audio";

		unmutedBtn = new FlxIconButton(185, 14, "assets/images/audio_icon_unmuted.png", 12, 12, onUnmutedClick);
		unmutedBtn.color = PlayState.COL_BG;
		add(unmutedBtn);
		tooltips[unmutedBtn] = "Mute the audio";

		helpBtn = new FlxIconButton(185, 27, "assets/images/audio_icon_help.png", 12, 12, onHelpClick);
		helpBtn.color = PlayState.COL_BG;
		add(helpBtn);
		tooltips[helpBtn] = "Help screen.";

		updateMuteUI();

		zustand = new Zustand(raster_breite, raster_hoehe);
		zustandSprite = new FlxSprite(18, 39);
		zustandSprite.makeGraphic(raster_breite * kachel_breite, raster_hoehe * kachel_hoehe, FlxColor.TRANSPARENT, false, "zustandsprite");
		zustandSprite.pixels.fillRect(zustandSprite.pixels.rect, FlxColor.TRANSPARENT);
		add(zustandSprite);

		highlightSprites_yx = [];
		for (j in 0...raster_hoehe)
		{
			var zeile:Array<FlxSprite> = [];
			for (i in 0...raster_breite)
			{
				var s = new FlxSprite(brett_ox + i * kachel_breite, brett_oy + j * kachel_hoehe);
				s.makeGraphic(kachel_breite, kachel_hoehe, FlxColor.BLACK);
				s.alpha = 0.2;
				add(s);
				zeile.push(s);
			}
			highlightSprites_yx.push(zeile);
		}

		komponentText = new FlxBitmapText(TitleScreen.fontAngelCode);
		komponentText.x = 46;
		komponentText.y = 15;
		komponentText.color = FlxColor.BLACK;
		add(komponentText);

		komponent = Komponent.vonSilhouette("CPU", 100, "11|11|11", [1, 1, 0, 0, 0, 2, 0, 2], true);

		komponentTaste_ausgewaehlt = new FlxMySpriteSelectedButton(17, 12, 25, 25, komponent.render(), "assets/images/sprite_btn_bg_big.png");
		add(komponentTaste_ausgewaehlt);
		auswahltasten_ausgewaehlt.push(komponentTaste_ausgewaehlt);
		komponentTaste = new FlxMySpriteButton(17, 12, 25, 25, komponent.render(), "assets/images/sprite_btn_bg_big.png", () -> onKachelAuswahl(0));
		add(komponentTaste);
		auswahltasten.push(komponentTaste);
		tooltips[komponentTaste] = "Place component (shortcut: 1)";

		ausgewaehlterKachel_Spr = new FlxSprite(-100, -100);
		ausgewaehlterKachel_Spr.alpha = 0.5;
		add(ausgewaehlterKachel_Spr);

		komponentText.text = komponent.name + " (E" + komponent.wert + 4 + ")";

		rand.shuffle(kabelkacheln);

		kachelleiste = kabelkacheln.splice(30, 3); // [kabelkacheln[3], kabelkacheln[4], kabelkacheln[5]];
		for (kachel in kachelleiste)
		{
			for (p in kachel.paths)
			{
				p.farbe = 4;
			}
		}

		kacheltasten = kachelleiste.map(ws -> ws.makeGraphic());
		kacheltasten_ausgewaehlt = kachelleiste.map(ws -> ws.makeGraphic());

		for (i => kt in kacheltasten)
		{
			var schaltflaeche_ausgewaehlt = new FlxMySpriteSelectedButton(43 + 12 * i, 26, 11, 11, kacheltasten_ausgewaehlt[i],
				"assets/images/sprite_btn_bg_small.png");

			add(schaltflaeche_ausgewaehlt);
			tooltips[schaltflaeche_ausgewaehlt.bg] = "Place connector (shortcut: " + (i + 1) + ")";

			auswahltasten_ausgewaehlt.push(schaltflaeche_ausgewaehlt);

			var schaltflaeche = new FlxMySpriteButton(43 + 12 * i, 26, 11, 11, kt, "assets/images/sprite_btn_bg_small.png", () -> onKachelAuswahl(i + 1));
			// schaltflaeche.label.offset.x = 4;
			// schaltflaeche.label.offset.y = 4;

			add(schaltflaeche);
			tooltips[schaltflaeche] = "Place connector (shortcut: " + (i + 1) + ")";

			auswahltasten.push(schaltflaeche);
		}

		drehBtn = new FlxIconButton(43 + 12 * kacheltasten.length, 26, "assets/images/audio_icon_turn.png", 11, 11, () -> onDrehClick(true));
		drehBtnDisabled = new FlxSprite(drehBtn.x, drehBtn.y, "assets/images/dreh_disabled.png");
		add(drehBtnDisabled);
		tooltips[drehBtnDisabled] = "No piece to piece selected. Gurrll, can't rotate until you've done that.";

		drehBtnDisabled.visible = false;
		add(drehBtn);
		tooltips[drehBtn] = "Turn the piece (shortcut: R or mousewheel)";

		var schaltflaeche_gummi_ausgewaehlt = new FlxMySpriteSelectedButton(43 + 12 * kacheltasten.length + 12, 26, 11, 11,
			new FlxSprite(0, 0, "assets/images/gummi_sprite.png"), "assets/images/sprite_btn_bg_small.png");

		add(schaltflaeche_gummi_ausgewaehlt);
		auswahltasten_ausgewaehlt.push(schaltflaeche_gummi_ausgewaehlt);

		gummiBtn = new FlxMySpriteButton(43 + 12 * kacheltasten.length + 12, 26, 11, 11, new FlxSprite(0, 0, "assets/images/gummi_sprite.png"),
			"assets/images/sprite_btn_bg_small.png", () -> onKachelAuswahl(4));
		add(gummiBtn);
		auswahltasten.push(gummiBtn);
		tooltips[gummiBtn] = "Rubber (shortcut: 5, or hold shift)";

		tooltipboundary = new FlxSprite(0, 0);
		tooltipboundary.makeGraphic(1, 1, FlxColor.BLACK);

		tooltipbg = new FlxSprite(0, 0);
		tooltipbg.makeGraphic(1, 1, COL_BG);

		tooltip = new FlxBitmapText(TitleScreen.fontAngelCode);
		tooltip.x = 5;
		tooltip.y = 5;
		tooltip.color = FlxColor.BLACK;
		tooltip.backgroundColor = FlxColor.RED;
		tooltip.text = "Oh nice!";

		add(tooltipboundary);
		add(tooltipbg);
		add(tooltip);

		errorText = new FlxBitmapText(TitleScreen.fontAngelCode);
		errorText.x = 104;
		errorText.y = 40;
		errorText.color = FlxColor.BLACK;
		errorText.text = "Error:";
		errorText.autoSize = false;
		errorText.multiLine = true;
		errorText.wordWrap = true;
		errorText.fieldWidth = 43;
		errorText.visible = false;

		add(errorText);

		onKachelAuswahl(1);

		zustand.rechneSignaleAus();
		zustand.render(zustandSprite.pixels, ausgewaehlterKachelIndex == 0);
		aktualiziereOberflaeche();
	}

	public var zustand:Zustand;
	public var highlightSprites_yx:Array<Array<FlxSprite>>;

	public static function getInhaltZustand(ki:KachelInhalt):KachelZustand
	{
		switch (ki)
		{
			case WireSquare(w, z):
				return z;
			case Komponent(k, z):
				return z;
			case Leer:
				return KachelZustand.Fest; // whatever
		}
	}

	public function getInhaltMask(ki:KachelInhalt):Array<Position>
	{
		switch (ki)
		{
			case WireSquare(w, z):
				return [{x: w.x, y: w.y}];
			case Komponent(k, z):
				return k.kacheln.map(kk -> {x: kk.offset.x + k.x, y: kk.offset.y + k.y});
			case Leer:
				return [];
		}
	}

	private function onDrehClick(?dir:Bool = true):Void
	{
		if (ausgewaehlterKachelIndex == 4)
		{
			return;
		}
		if (ausgewaehlterKachelIndex == 0)
		{
			komponent = komponent.dreh(dir);
			komponentTaste.label.loadGraphicFromSprite(komponent.render());
			komponentTaste.zentriere_Sprite();
			komponentTaste_ausgewaehlt.members[1].loadGraphicFromSprite(komponent.render());
			komponentTaste_ausgewaehlt.zentriere_Sprite();
		}
		else
		{
			kachelleiste[ausgewaehlterKachelIndex - 1] = kachelleiste[ausgewaehlterKachelIndex - 1].dreh(dir);

			kacheltasten[ausgewaehlterKachelIndex - 1] = kachelleiste[ausgewaehlterKachelIndex - 1].makeGraphic();
			kacheltasten_ausgewaehlt[ausgewaehlterKachelIndex - 1] = kachelleiste[ausgewaehlterKachelIndex - 1].makeGraphic();

			auswahltasten[ausgewaehlterKachelIndex].label.loadGraphicFromSprite(kachelleiste[ausgewaehlterKachelIndex - 1].makeGraphic());
			auswahltasten_ausgewaehlt[ausgewaehlterKachelIndex].members[1].loadGraphicFromSprite(kachelleiste[ausgewaehlterKachelIndex - 1].makeGraphic());
		}

		// komponentTaste_ausgewaehlt.members[1].loadGraphicFromSprite(komponentTaste_ausgewaehlt_img);
		// komponentTaste.label.loadGraphicFromSprite(komponentTas);

		ausgewaehlterKachel_Spr.loadGraphicFromSprite(auswahltasten[ausgewaehlterKachelIndex].label);

		if (ausgewaehlterKachelIndex == 0)
		{
			ausgewaehlterKachel = Komponent(komponent, Geplant);
		}
		else
		{
			ausgewaehlterKachel = WireSquare(kachelleiste[ausgewaehlterKachelIndex - 1], Geplant);
		}
	}

	private function onGummiClick():Void {}

	public inline function copyInhalt(ki:KachelInhalt):KachelInhalt
	{
		switch (ki)
		{
			case WireSquare(w, z):
				return WireSquare(w.copy(), z);
			case Komponent(k, z):
				return Komponent(k.copy(), z);
			case Leer:
				return Leer;
		}
	}

	private var alteauswahl = 0;

	private function updateHinweise():Void
	{
		// tooltipbg.alpha = 0.85;
		// tooltipboundary.alpha = 0.85;
		if (FlxG.keys.justPressed.R)
		{
			onDrehClick(true);
		}
		if (FlxG.keys.justPressed.ONE)
		{
			onKachelAuswahl(0);
		}
		if (FlxG.keys.justPressed.SHIFT)
		{
			alteauswahl = ausgewaehlterKachelIndex;
			onKachelAuswahl(4);
		}

		if (FlxG.keys.justReleased.SHIFT)
		{
			onKachelAuswahl(alteauswahl);
		}
		if (FlxG.keys.justPressed.TWO)
		{
			onKachelAuswahl(1);
		}
		if (FlxG.keys.justPressed.THREE)
		{
			onKachelAuswahl(2);
		}
		if (FlxG.keys.justPressed.FOUR)
		{
			onKachelAuswahl(3);
		}
		if (FlxG.keys.justPressed.FIVE)
		{
			onDrehClick(true);
		}
		if (FlxG.keys.justPressed.SIX)
		{
			onKachelAuswahl(4);
		}
		var mx = FlxG.mouse.x;
		var my = FlxG.mouse.y;

		var gefunden = false;
		for (button => tip in tooltips)
		{
			if (button.visible && button.overlapsPoint(new FlxPoint(mx, my)))
			{
				tooltip.text = tip;
				tooltip.autoSize = false;
				tooltip.multiLine = true;
				tooltip.wordWrap = true;

				tooltip.fieldWidth = 60;

				tooltip.draw(); // update

				var width = tooltip.getLineWidth(0);
				for (i in 1...tooltip.numLines)
				{
					var curwidth = tooltip.getLineWidth(i);
					width = curwidth > width ? curwidth : width;
				}
				tooltip.width = width;

				tooltip.x = mx + 2;
				tooltip.y = my - tooltip.height - 5;
				gefunden = true;
			}
		}

		if (!gefunden)
		{
			tooltipbg.visible = false;
			tooltipboundary.visible = false;
			tooltip.visible = false;
			return;
		}

		tooltipbg.visible = true;
		tooltipboundary.visible = true;
		tooltip.visible = true;

		if (tooltip.x + tooltip.width + 2 > FlxG.width)
		{
			tooltip.x = FlxG.width - 2 - tooltip.width;
		}
		if (tooltip.y + tooltip.height + 2 > FlxG.height)
		{
			tooltip.y = FlxG.height - 2 - tooltip.height;
		}

		if (tooltip.y < 2)
		{
			tooltip.y = FlxG.mouse.y + 4;
		}
		if (tooltip.x < 2)
		{
			tooltip.x = 2;
		}

		tooltipbg.scale.x = tooltip.width + 1;
		tooltipbg.scale.y = tooltip.height - 1;
		tooltipbg.x = tooltip.x - 1;
		tooltipbg.y = tooltip.y - 1;
		tooltipbg.updateHitbox();
		tooltipboundary.scale.x = tooltip.width + 3;
		tooltipboundary.scale.y = tooltip.height + 1;
		tooltipboundary.x = tooltip.x - 2;
		tooltipboundary.y = tooltip.y - 2;
		tooltipboundary.updateHitbox();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.N)
		{
			FlxG.switchState(new PlayState());
		}
		var mx = FlxG.mouse.x;
		var my = FlxG.mouse.y;

		// Mouseposition am Raster ausrichten:
		var rx = Math.floor((mx - brett_ox) / kachel_breite);
		var ry = Math.floor((my - brett_oy) / kachel_hoehe);

		for (j in 0...raster_hoehe)
		{
			var zeile = highlightSprites_yx[j];
			for (i in 0...raster_breite)
			{
				var sprite = zeile[i];
				sprite.alpha = 0;
			}
		}

		if (zustand.enthieltPunkt(rx, ry))
		{
			switch (ausgewaehlterKachel)
			{
				case WireSquare(w, _):
				case Komponent(k, _):
					rx -= Math.floor((k.breite - 1) / 2);
					ry -= Math.floor((k.hoehe - 1) / 2);
					k.x = rx;
					k.y = ry;
					zustand.fitKomponent(k);
					rx = k.x;
					ry = k.y;
				case Leer:
			}

			mx = rx * kachel_breite + brett_ox;
			my = ry * kachel_hoehe + brett_oy;

			ausgewaehlterKachel_Spr.x = mx;
			ausgewaehlterKachel_Spr.y = my;
			ausgewaehlterKachel_Spr.alpha = 1.0;

			if (ausgewaehlterKachelIndex == 4)
			{
				// wenn gummi
				if (FlxG.mouse.pressed)
				{
					var anygone:Bool = false;
					zustand.Inhalt = zustand.Inhalt.filter(ki ->
					{
						var zustand = getInhaltZustand(ki);
						if (zustand == Fest)
						{
							return true;
						}
						var mask = getInhaltMask(ki);
						for (mp in mask)
						{
							if (mp.x == rx && mp.y == ry)
							{
								anygone = true;
								return false;
							}
						}
						return true;
					});
					if (anygone)
					{
						zustand.rechneSignaleAus();
						zustand.render(zustandSprite.pixels, ausgewaehlterKachelIndex == 0);
						aktualiziereOberflaeche();
					}
				}
			}
			else
			{
				var ignorieregeplanntekomponent = false;

				switch (ausgewaehlterKachel)
				{
					case WireSquare(w, z):
						w.x = rx;
						w.y = ry;
					case Komponent(k, z):
						k.x = rx;
						k.y = ry;
						ignorieregeplanntekomponent = true;
					case Leer:
				}

				var overlaps = false;

				var inhaltmask = getInhaltMask(ausgewaehlterKachel);
				var zustandmask = zustand.getInhaltMask(false, ignorieregeplanntekomponent);

				for (im in inhaltmask)
				{
					for (zsm in zustandmask)
					{
						if (im.x == zsm.x && im.y == zsm.y)
						{
							var s = highlightSprites_yx[im.y][im.x];
							s.color = 0xffeb6c82;
							s.alpha = 0.5;
							overlaps = true;
						}
					}
				}
				if (FlxG.mouse.justPressed && !overlaps)
				{
					if (ignorieregeplanntekomponent)
					{
						zustand.Inhalt = zustand.Inhalt.filter(ki ->
						{
							switch (ki)
							{
								case WireSquare(w, z):
									return true;
								case Komponent(k, z):
									return z == Fest;
								case Leer:
									return true;
							}
						});
					}

					zustand.Inhalt.push(copyInhalt(ausgewaehlterKachel));
					zustand.rechneSignaleAus();
					zustand.render(zustandSprite.pixels, ausgewaehlterKachelIndex == 0);
					aktualiziereOberflaeche();
				}
				else if (FlxG.mouse.wheel > 0)
				{
					onDrehClick(false);
				}
				else if (FlxG.mouse.wheel < 0)
				{
					onDrehClick(true);
				}
			}
		}
		else
		{
			ausgewaehlterKachel_Spr.alpha = 0.0;
		}

		updateHinweise();
	}
}
