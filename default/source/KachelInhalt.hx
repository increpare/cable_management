enum KachelZustand
{
	Fest;
	Geplant;
}

enum KachelInhalt
{
	WireSquare(w:WireSquare, z:KachelZustand);
	Komponent(k:Komponent, z:KachelZustand);
	Leer;
}
