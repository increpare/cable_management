package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;

typedef RankInfo =
{
	var rankThreshold:Int;
	var name:String;
}

class PlayState extends FlxState
{
	var brett_ox:Int = 18;
	var brett_oy:Int = 39;

	var kachel_breite:Int = 7;
	var kachel_hoehe:Int = 7;

	var brett_breite:Int = 63;
	var brett_hoehe:Int = 56;

	var raster_breite:Int = 9;
	var raster_hoehe:Int = 8;

	private var kabelkacheln:Array<WireSquare> = [
		"1,0,3:1,0,3", "1,0,0,0:1,0,0,0", "1,0,0,3:1,0,0,3", "1,0,2,2:1,0,2,2", "1,0,0,2,0:1,0,0,2,0", "1,0,0,2,3:1,0,0,2,3", "2,0,0,2:2,0,0,2",
		"2,0,0,3,2:2,0,0,3,2", "1,0,3:1,0,3:2,0,2", "1,0,3:1,0,3:2,0,0,0", "1,0,3:1,0,3:2,0,0,2", "1,0,3:1,0,3:2,0,0,3,0", "1,0,3:1,0,3:2,0,0,3,2",
		"1,0,3:1,0,3:3,1,2,0", "1,0,3:1,0,3:3,1,2,2", "1,0,3:1,0,3:3,1,2,3,0", "1,0,3:1,0,3:3,1,2,3,2", "1,0,3:1,0,3:3,2,2", "1,0,3:1,0,3:3,2,0,2",
		"1,0,3:1,0,3:1,3,3,3", "1,0,0,0:1,0,0,0:2,0,2", "1,0,0,0:1,0,0,0:2,0,0,0", "1,0,0,0:1,0,0,0:2,0,0,2", "1,0,0,0:1,0,0,0:2,0,3,0",
		"1,0,0,0:1,0,0,0:2,0,0,3,0", "1,0,0,0:1,0,0,0:3,1,2,0", "1,0,0,0:1,0,0,0:3,1,2,2", "1,0,0,0:1,0,0,0:3,1,2,3,0", "1,0,0,3:1,0,0,3:2,0,2",
		"1,0,0,3:1,0,0,3:2,0,0,2", "1,0,0,3:1,0,0,3:2,0,3,0", "1,0,0,3:1,0,0,3:3,1,2,0", "1,0,0,3:1,0,0,3:3,1,2,2", "1,0,2,0:1,0,2,0:2,0,0,0",
		"1,0,2,0:1,0,2,0:2,0,0,3,0", "1,0,2,0:1,0,2,0:2,0,0,3,2", "1,0,2,2:1,0,2,2:3,2,0,2", "1,0,2,2:1,0,2,2:1,3,3,3", "1,0,0,2,0:1,0,0,2,0:2,0,0,0",
		"1,0,0,2,0:1,0,0,2,0:2,0,3,0", "1,0,0,2,3:1,0,0,2,3:2,0,3,0", "2,0,0,0:2,0,0,0:3,1,0,2,2,0", "2,0,3,0:2,0,3,0:3,2,0,2"
	].map(WireSquare.deserialize);

	var kachelleiste:Array<WireSquare>;
	var kacheltasten:Array<FlxSprite>;
	var kacheltasten_ausgewaehlt:Array<FlxSprite>;

	var komponent:Komponent;
	var komponentTaste:FlxMySpriteButton;
	var komponentTaste_ausgewaehlt:FlxMySpriteSelectedButton;
	var komponentText:FlxBitmapText;

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

	private function onAddPart() {}

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

	private function updateMuteUI()
	{
		mutedBtn.visible = FlxG.sound.muted;
		unmutedBtn.visible = !FlxG.sound.muted;
	}

	var auswahltasten:Array<FlxMySpriteButton> = [];
	var auswahltasten_ausgewaehlt:Array<FlxMySpriteSelectedButton> = [];

	var ausgewaehlterKachel_Spr:FlxSprite;
	var ausgewaehlterKachel:KachelInhalt;

	private function onKachelAuswahl(i:Int)
	{
		trace(i);
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
			ausgewaehlterKachel = Komponent(komponent);
		}
		else
		{
			ausgewaehlterKachel = WireSquare(kachelleiste[i - 1]);
		}
	}

	override public function create()
	{
		super.create();

		this.bgColor = COL_BG;

		_bg = new FlxSprite(0, 0, "assets/images/bg.png");
		add(_bg);

		makeSaleBtn = new FlxBitmapTextButtonLowRes(83, 40, "Make Sale", onMakeSale);
		makeSaleBtn.label.font = TitleScreen.fontAngelCode;
		makeSaleBtn.color = PlayState.COL_BG;

		add(makeSaleBtn);

		addPartBtn = new FlxBitmapTextButtonLowRes(83, 56, "Add extra part", onAddPart);
		addPartBtn.label.font = TitleScreen.fontAngelCode;
		addPartBtn.color = PlayState.COL_BG;
		add(addPartBtn);

		exitBtn = new FlxIconButton(164, 1, "assets/images/audio_icon_exit.png", 12, 12, onExitClick);
		exitBtn.color = PlayState.COL_BG;
		add(exitBtn);

		mutedBtn = new FlxIconButton(164, 14, "assets/images/audio_icon_muted.png", 12, 12, onMutedClick);
		mutedBtn.color = PlayState.COL_BG;
		add(mutedBtn);

		unmutedBtn = new FlxIconButton(164, 14, "assets/images/audio_icon_unmuted.png", 12, 12, onUnmutedClick);
		unmutedBtn.color = PlayState.COL_BG;
		add(unmutedBtn);

		helpBtn = new FlxIconButton(164, 27, "assets/images/audio_icon_help.png", 12, 12, onHelpClick);
		helpBtn.color = PlayState.COL_BG;
		add(helpBtn);

		updateMuteUI();

		highlightSprites_yx = [];
		for (j in 0...brett_hoehe)
		{
			var zeile:Array<FlxSprite> = [];
			for (i in 0...brett_breite)
			{
				var s = new FlxSprite(brett_ox + i * kachel_breite, brett_oy + j * kachel_hoehe);
				s.makeGraphic(kachel_breite, kachel_hoehe, FlxColor.WHITE);
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

		komponent = Komponent.vonSilhouette("CPU", 100, "111|001", [1, 1, -1, 2, -2]);
		var komponentTaste_img = new FlxSprite(19, 14);
		komponentTaste_img.makeGraphic(komponent.breite * 7, komponent.hoehe * 7, FlxColor.TRANSPARENT, true);
		var kt_bmd = komponentTaste_img.pixels;

		var komponentTaste_ausgewaehlt_img = new FlxSprite(19, 14);
		komponentTaste_ausgewaehlt_img.makeGraphic(komponent.breite * 7, komponent.hoehe * 7, FlxColor.TRANSPARENT, true);
		var kt_agw_bmd = komponentTaste_ausgewaehlt_img.pixels;

		for (kachel in komponent.kacheln)
		{
			kachel.drawToGraphic(kt_bmd, 7 * kachel.offset.x, 7 * kachel.offset.y);
			kachel.drawToGraphic(kt_agw_bmd, 7 * kachel.offset.x, 7 * kachel.offset.y);
		}

		komponentTaste_ausgewaehlt = new FlxMySpriteSelectedButton(17, 12, 25, 25, komponentTaste_ausgewaehlt_img, "assets/images/sprite_btn_bg_big.png");
		add(komponentTaste_ausgewaehlt);
		auswahltasten_ausgewaehlt.push(komponentTaste_ausgewaehlt);
		komponentTaste = new FlxMySpriteButton(17, 12, 25, 25, komponentTaste_img, "assets/images/sprite_btn_bg_big.png", () -> onKachelAuswahl(0));
		add(komponentTaste);
		auswahltasten.push(komponentTaste);

		ausgewaehlterKachel_Spr = new FlxSprite(-100, -100);
		ausgewaehlterKachel_Spr.alpha = 0.5;
		add(ausgewaehlterKachel_Spr);

		komponentText.text = komponent.name + " (E" + komponent.wert + 4 + ")";

		kachelleiste = kabelkacheln.splice(30, 3); // [kabelkacheln[3], kabelkacheln[4], kabelkacheln[5]];

		kacheltasten = kachelleiste.map(ws -> ws.makeGraphic());
		kacheltasten_ausgewaehlt = kachelleiste.map(ws -> ws.makeGraphic());

		for (i => kt in kacheltasten)
		{
			var schaltflaeche_ausgewaehlt = new FlxMySpriteSelectedButton(43 + 12 * i, 26, 11, 11, kacheltasten_ausgewaehlt[i],
				"assets/images/sprite_btn_bg_small.png");

			add(schaltflaeche_ausgewaehlt);
			auswahltasten_ausgewaehlt.push(schaltflaeche_ausgewaehlt);

			var schaltflaeche = new FlxMySpriteButton(43 + 12 * i, 26, 11, 11, kt, "assets/images/sprite_btn_bg_small.png", () -> onKachelAuswahl(i + 1));
			// schaltflaeche.label.offset.x = 4;
			// schaltflaeche.label.offset.y = 4;

			add(schaltflaeche);
			auswahltasten.push(schaltflaeche);
		}

		zustand = new Zustand(9, 8);

		onKachelAuswahl(1);
	}

	public var zustand:Zustand;
	public var highlightSprites_yx:Array<Array<FlxSprite>>;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		var mx = FlxG.mouse.x;
		var my = FlxG.mouse.y;

		// Mouseposition am Raster ausrichten:
		var rx = Math.floor((mx - brett_ox) / kachel_breite);
		var ry = Math.floor((my - brett_oy) / kachel_hoehe);

		switch (ausgewaehlterKachel)
		{
			case WireSquare(w):
			case Komponent(k):
				rx -= Math.floor((k.breite - 1) / 2);
				ry -= Math.floor((k.hoehe - 1) / 2);
				k.x = rx;
				k.y = ry;
				zustand.fitKomponent(k);
				rx = k.x;
				ry = k.y;
			case Leer:
		}
		if (zustand.enthieltPunkt(rx, ry))
		{
			mx = rx * kachel_breite + brett_ox;
			my = ry * kachel_hoehe + brett_oy;

			ausgewaehlterKachel_Spr.x = mx;
			ausgewaehlterKachel_Spr.y = my;
			ausgewaehlterKachel_Spr.alpha = 1.0;
		}
		else
		{
			ausgewaehlterKachel_Spr.alpha = 0.0;
		}
	}
}
