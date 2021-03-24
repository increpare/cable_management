import flixel.FlxSprite;
import flixel.util.FlxColor;
import lime.text.harfbuzz.HBGlyphPosition;
import openfl.display.BitmapData;
import openfl.display.IBitmapDrawable;

using DirUtils;

class Path
{
	public var start:Position;
	public var trajectory:Array<RelativeDir>;
	//-1 is empty
	// 0-3 colors
	// 4 is empty
	public var farbe:Int;

	public function copy():Path
	{
		return new Path(start, trajectory.copy(), farbe);
	}

	public function dreh(dir:Bool):Path
	{
		var newStart:Position = dir ? {x: start.y, y: 3 - start.x} : {x: 3 - start.y, y: start.x};
		var newFarbe = farbe;
		var newTrajectory = trajectory.copy();
		return new Path(newStart, newTrajectory, farbe);
	}

	public function maskPoints():LineMask
	{
		var end = endPoint();

		var si = -1;
		var ei = -1;
		for (i in 0...StartingPoints.length)
		{
			var startingPoint = StartingPoints[i];
			if (start.x == startingPoint.x && start.y == startingPoint.y)
			{
				si = i;
			}
			if (end.x == startingPoint.x && end.y == startingPoint.y)
			{
				ei = i;
			}
		}

		return {startIndex: si, endIndex: ei};
	}

	public function serialize():String
	{
		var result = start.x + "," + start.y;
		for (d in trajectory)
		{
			result += ',' + d.getIndex();
		}
		return result;
	}

	public static function deserialize(s:String):Path
	{
		var ints = s.split(",").map(Std.parseInt);
		var start:Position = {x: ints[0], y: ints[1]};
		ints.splice(0, 2);
		var trajectory:Array<RelativeDir> = ints.map(i -> RelativeDir.createByIndex(i));
		return new Path(start, trajectory);
	}

	public static function comparePaths(a:Path, b:Path):Int
	{
		var as = Std.string(a);
		var bs = Std.string(b);

		if (as > bs)
		{
			return 1;
		}
		else if (as < bs)
		{
			return -1;
		}
		else
		{
			return 0;
		}
	}

	public function flip():Void
	{
		start = endPoint();
		trajectory.reverse();
		trajectory = trajectory.map(DirUtils.FlipLeftRight);
	}

	public function rotated():Path
	{
		var newStart = {x: 3 - start.y, y: start.x};
		var result = new Path(newStart, trajectory.copy());

		var end = result.endPoint();
		var start_index = DirUtils.PointIndex(result.start);
		var end_index = DirUtils.PointIndex(end);
		if (start_index > end_index)
		{
			result.flip();
		}

		return result;
	}

	public function new(start:Position, trajectory:Array<RelativeDir>, farbe:Int = -1)
	{
		this.start = start;
		this.trajectory = trajectory;
		this.farbe = farbe;
	}

	public function endPoint():Position
	{
		var curPos = start;
		var curFacing_AbsoluteDirection = DirUtils.startPosToAbsDirection(curPos);
		for (rel in trajectory)
		{
			// move cur forward
			curPos = DirUtils.movePosByAbsoluteDirection(curPos, curFacing_AbsoluteDirection);
			curFacing_AbsoluteDirection = DirUtils.rotateAbsoluteDir(curFacing_AbsoluteDirection, rel);
			// find new absolute direction
		}
		curPos = DirUtils.movePosByAbsoluteDirection(curPos, curFacing_AbsoluteDirection);

		return curPos;
	}

	public function trajectoryPoints():Array<Position>
	{
		var result = [start];
		var curPos = start;
		var curFacing_AbsoluteDirection = DirUtils.startPosToAbsDirection(curPos);
		for (rel in trajectory)
		{
			// move cur forward
			curPos = DirUtils.movePosByAbsoluteDirection(curPos, curFacing_AbsoluteDirection);
			result.push(curPos);
			curFacing_AbsoluteDirection = DirUtils.rotateAbsoluteDir(curFacing_AbsoluteDirection, rel);
			// find new absolute direction
		}
		curPos = DirUtils.movePosByAbsoluteDirection(curPos, curFacing_AbsoluteDirection);
		result.push(curPos);

		return result;
	}

	public static var StartingPoints = [
		{x: 1, y: 0}, {x: 2, y: 0},
		{x: 3, y: 1}, {x: 3, y: 2},
		{x: 2, y: 3}, {x: 1, y: 3},
		{x: 0, y: 2}, {x: 0, y: 1}
	];

	public static function PositionToConnectionIndex(p:Position):Int
	{
		for (i => ep in StartingPoints)
		{
			if (p.x == ep.x && p.y == ep.y)
			{
				return i;
			}
		}
		return -1;
	}

	public function startConnectionIndex():Int
	{
		return PositionToConnectionIndex(start);
	}

	public function endConnectionIndex():Int
	{
		return PositionToConnectionIndex(endPoint());
	}

	public function isValid():Bool
	{
		var end = endPoint();
		var found = false;
		for (sp in StartingPoints)
		{
			if (sp.x == end.x && sp.y == end.y)
			{
				found = true;
				break;
			}
		}
		if (found == false)
		{
			return false;
		}

		var trajectory_Points = trajectoryPoints();

		if (trajectory_Points.filter(function(pos) return DirUtils.validPosition(pos) == false).length > 0)
		{
			return false;
		}

		for (i in 1...(trajectory_Points.length - 1))
		{
			var point = trajectory_Points[i];
			for (sp in StartingPoints)
			{
				if (sp.x == point.x && sp.y == point.y)
				{
					return false;
				}
			}
		}

		var start_index = DirUtils.PointIndex(start);
		var end_index = DirUtils.PointIndex(end);
		if (start_index > end_index)
		{
			return false;
		}
		return true;
	}

	public static function nastyOverlap(a:Path, b:Path):Bool
	{
		var pas = a.trajectoryPoints();
		var pbs = b.trajectoryPoints();

		for (i in 1...(pas.length - 1))
		{
			var pa = pas[i];
			for (j in 1...(pbs.length - 1))
			{
				var pb = pbs[j];
				if (pa.x == pb.x && pa.y == pb.y)
				{
					// both must be in the middle of straight stretches
					// just need to check along one axis
					if (Math.abs(pas[i + 1].x - pas[i].x) != Math.abs(pas[i].x - pas[i - 1].x))
					{
						return true;
					}
					if (Math.abs(pbs[j + 1].x - pbs[j].x) != Math.abs(pbs[j].x - pbs[j - 1].x))
					{
						return true;
					}

					if (Math.abs(pas[i + 1].x - pas[i].x) == Math.abs(pbs[j + 1].x - pbs[j].x)
						&& Math.abs(pas[i + 1].y - pas[i].y) == Math.abs(pbs[j + 1].y - pbs[j].y))
					{
						return true;
					}

					// both must be going in opposite directions
				}
			}
		}
		return false;
	}
}

class WireSquare
{
	public var x:Int;
	public var y:Int;
	public var paths:Array<Path>;

	public static var verbindung_farben = [0xffca3232, 0xff37946e, 0xffcabb32, 0xff37946e, 0xff000000];

	public function dreh(dir:Bool):WireSquare
	{
		var newPaths = paths.map(p -> p.dreh(dir));
		return new WireSquare(newPaths);
	}

	public function copy():WireSquare
	{
		var ws = new WireSquare(paths.map(p -> p.copy()));
		ws.x = this.x;
		ws.y = this.y;
		return ws;
	}

	public function render(bmd:BitmapData, ox:Int, oy:Int)
	{
		for (i in 0...this.paths.length)
		{
			var path = this.paths[i];
			var trajectory = path.trajectoryPoints();
			for (j in 0...(trajectory.length - 1))
			{
				var p = trajectory[j];
				var q = trajectory[j + 1];
				var farbe = verbindung_farben[path.farbe];

				var light = new FlxColor(farbe);
				light.alpha = 5 * 16 + 5;
				var farbe_light = light;
				bmd.setPixel32(ox + 2 * p.x, oy + 2 * p.y, farbe);
				bmd.setPixel32(ox + Math.round((2 * p.x + 2 * q.x) / 2), oy + Math.round((2 * p.y + 2 * q.y) / 2), farbe);
				bmd.setPixel32(ox + 2 * q.x, oy + 2 * q.y, farbe);

				var dx = q.x - p.x;
				var dy = q.y - p.y;

				var left_x = q.x - dy;
				var left_y = q.y + dx;

				var right_x = q.x + dy;
				var right_y = q.y - dx;

				var left_pixel = bmd.getPixel32(ox + Math.round((2 * left_x + 2 * q.x) / 2), oy + Math.round((2 * left_y + 2 * q.y) / 2));
				var right_pixel = bmd.getPixel32(ox + Math.round((2 * right_x + 2 * q.x) / 2), oy + Math.round((2 * right_y + 2 * q.y) / 2));
				trace(StringTools.hex(left_pixel, 8), StringTools.hex(right_pixel, 8));
				if (left_pixel == farbe)
				{
					bmd.setPixel32(ox + Math.round((2 * left_x + 2 * q.x) / 2), oy + Math.round((2 * left_y + 2 * q.y) / 2), farbe_light);
				}
				if (right_pixel == farbe)
				{
					bmd.setPixel32(ox + Math.round((2 * right_x + 2 * q.x) / 2), oy + Math.round((2 * right_y + 2 * q.y) / 2), farbe_light);
				}
			}
		}
	}

	public function makeGraphic():FlxSprite
	{
		var s = new FlxSprite(0, 0);
		var key = serialize();
		s.makeGraphic(7, 7, FlxColor.TRANSPARENT, false, key);

		var colors = [0xffac3232, 0xffd95763, 0xffd77bba, 0xff76428a];
		var bmd = s.pixels;
		render(bmd, 0, 0);

		return s;
	}

	public function serialize():String
	{
		var result = "";
		for (i => p in paths)
		{
			if (i > 0)
			{
				result += ":";
			}
			result += p.serialize();
		}
		return result;
	}

	public static function deserialize(s:String):WireSquare
	{
		var paths = s.split(":").map(Path.deserialize);
		return new WireSquare(paths);
	}

	public function rotated():WireSquare
	{
		var newpaths:Array<Path> = [];
		for (p in paths)
		{
			var rotated = p.rotated();
			newpaths.push(rotated);
		}
		newpaths.sort(Path.comparePaths);
		return new WireSquare(newpaths);
	}

	public function toString():String
	{
		var result = "\n";
		var grid = [
			// y then x
			[".", ".", ".", "."],
			[".", ".", ".", "."],
			[".", ".", ".", "."],
			[".", ".", ".", "."]
		];

		for (i in 0...paths.length)
		{
			var path = paths[i];
			var trajectory = path.trajectoryPoints();
			for (p in trajectory)
			{
				grid[p.y][p.x] = Std.string(i);
			}
		}

		var result = "";
		for (row in grid)
		{
			for (char in row)
			{
				result += char;
			}
			result += "\n";
		}
		result += "\n";

		for (i in 0...paths.length)
		{
			var path = paths[i];
			result += Std.string(path.start.x) + "," + Std.string(path.start.y) + " : " + Std.string(path.trajectory) + "\n";
		}

		result += "\n\n" + this.calculateMask();
		return result;
	}

	public function new(paths:Array<Path>)
	{
		this.x = 0;
		this.y = 0;
		this.paths = paths;
	}

	public function complexity():Int
	{
		var result = 0;
		for (p in paths)
		{
			result += 10 * p.trajectory.length;
			for (entry in p.trajectory)
			{
				if (entry == left || entry == right)
				{
					result++;
				}
			}
		}
		return result;
	}

	public function calculateMask():String
	{
		var maskarray = [-1, -1, -1, -1, -1, -1, -1, -1];
		var lineMasks = paths.map(function(p) return p.maskPoints());
		for (i in 0...lineMasks.length)
		{
			var lm = lineMasks[i];
			var min = lm.startIndex < lm.endIndex ? lm.startIndex : lm.endIndex;
			maskarray[lm.startIndex] = min;
			maskarray[lm.endIndex] = min;
		}
		var result = "";
		for (n in maskarray)
		{
			if (n == -1)
			{
				result += ".";
			}
			else
			{
				result += Std.string(n);
			}
		}
		return result;
	}

	public static function compareMasks(a:WireSquare, b:WireSquare):Int
	{
		var as = a.calculateMask();
		var bs = b.calculateMask();

		if (as > bs)
		{
			return 1;
		}
		else if (as < bs)
		{
			return -1;
		}
		else
		{
			return 0;
		}
	}

	public function isValid():Bool
	{ // checks for nicely overlapping paths
		for (i in 0...paths.length)
		{
			var path1 = paths[i];
			for (j in (i + 1)...paths.length)
			{
				var path2 = paths[j];
				if (Path.nastyOverlap(path1, path2))
				{
					return false;
				}
			}
		}
		return true;
	}

	private static function GenerateAllTrajectoriesOfLength(n:Int):Array<Array<RelativeDir>>
	{
		if (n == 0)
		{
			return [[]];
		}
		var smaller_trajectories = GenerateAllTrajectoriesOfLength(n - 1);
		var relative_directions:Array<RelativeDir> = [forward, left, right]; // back not a valid part of trajectories
		var result:Array<Array<RelativeDir>> = [];

		for (smaller_trajectory in smaller_trajectories)
		{
			for (rel in relative_directions)
			{
				var trajectory = smaller_trajectory.concat([rel]);
				result.push(trajectory);
			}
		}

		return result;
	}

	public static function GenerateAll():Array<WireSquare>
	{
		var possible_trajectories:Array<Array<RelativeDir>> = [];

		// var testWire = new Path({x: 1, y: 0}, [left, left, left]);
		// trace(testWire.isValid());
		// var testWireSquare1 = new WireSquare([new Path({x: 1, y: 0}, [left, forward)]);
		// var testWireSquare2 = new WireSquare([new Path({x: 1, y: 0}, [forward, right)]);
		for (n in 1...5)
		{
			possible_trajectories = possible_trajectories.concat(GenerateAllTrajectoriesOfLength(n));
		}
		var validPaths:Array<Path> = [];

		for (sP in Path.StartingPoints)
		{
			for (trajectory in possible_trajectories)
			{
				var path = new Path(sP, trajectory);

				if (path.isValid())
				{
					validPaths.push(path);
				}
			}
		}
		// for (path in validPaths)
		// {
		// 	trace(path);
		// 	trace(path.trajectoryPoints());
		// }
		trace("NUMBER OF PATHS " + validPaths.length);
		var allCombinationsOfPaths = validPaths.map(function(path) return [path]);

		var pathSetsOfSizeN_minus_one = allCombinationsOfPaths.copy();

		for (i in 1...4)
		{
			var pathSetsOfSizeN = [];

			for (pathSetOfSizeN_minus_one in pathSetsOfSizeN_minus_one)
			{
				for (path in validPaths)
				{
					if (pathSetOfSizeN_minus_one.indexOf(path) == -1)
					{
						if (Path.comparePaths(path, pathSetOfSizeN_minus_one[pathSetOfSizeN_minus_one.length - 1]) > 0)
						{
							var pathSetOfSizeN = pathSetOfSizeN_minus_one.copy();

							pathSetOfSizeN.push(path);
							pathSetOfSizeN.sort(Path.comparePaths);
							pathSetsOfSizeN.push(pathSetOfSizeN);
						}
					}
				}
			}
			allCombinationsOfPaths = allCombinationsOfPaths.concat(pathSetsOfSizeN);
			pathSetsOfSizeN_minus_one = pathSetsOfSizeN;
		}
		for (path in validPaths)
		{
			// trace(path);
		}
		var allPossibleWireSquares = allCombinationsOfPaths.map(function(pathset) return new WireSquare(pathset));

		trace("NUMBER OF PATH SETS " + allPossibleWireSquares.length);
		allPossibleWireSquares = allPossibleWireSquares.filter(function(wireSquare) return wireSquare.isValid());

		for (wireSquare in allPossibleWireSquares)
		{
			// trace(".\n" + wireSquare.toString());
		}
		trace("NUMBER OF PATH SETS (filtered) " + allPossibleWireSquares.length);
		var maskDictionary:Map<String, WireSquare> = [];
		for (wireSquare in allPossibleWireSquares)
		{
			var mask = wireSquare.calculateMask();
			if (maskDictionary.exists(mask))
			{
				var newComplexity = wireSquare.complexity();
				var old = maskDictionary[mask];
				var oldComplexity = old.complexity();

				if (oldComplexity > newComplexity)
				{
					maskDictionary[mask] = wireSquare;
				}
			}
			else
			{
				maskDictionary[mask] = wireSquare;
			}
		}
		allPossibleWireSquares = [];
		for (value in maskDictionary)
		{
			allPossibleWireSquares.push(value);
		}
		for (wireSquare in allPossibleWireSquares)
		{
			trace(".\n" + wireSquare.toString());
		}
		trace("NUMBER OF PATH SETS (filtered by parsimony) " + allPossibleWireSquares.length);
		// normalise rotation values and filter thereby
		maskDictionary = [];
		for (wireSquare in allPossibleWireSquares)
		{
			var wireSquares:Array<WireSquare> = [wireSquare];

			for (i in 0...3)
			{
				wireSquares.push(wireSquares[wireSquares.length - 1].rotated());
			}
			wireSquares.sort(WireSquare.compareMasks);
			var normalisedWireSquare = wireSquares[0];
			var mask = normalisedWireSquare.calculateMask();

			if (maskDictionary.exists(mask))
			{
				var old = maskDictionary[mask];
			}
			else
			{
				maskDictionary[mask] = wireSquare;
			}
		}
		allPossibleWireSquares = [];
		for (value in maskDictionary)
		{
			allPossibleWireSquares.push(value);
		}
		for (wireSquare in allPossibleWireSquares)
		{
			trace(".\n" + wireSquare.toString());
		}
		trace("NUMBER OF PATH SETS (normalising rotation) " + allPossibleWireSquares.length);
		return allPossibleWireSquares;
	}
}
