using DirUtils;

class Path
{
	public var start:Position;
	public var trajectory:Array<RelativeDir>;

	public function rotate():Path
	{
		var newStart = {x: 3 - start.y, y: start.x};
		return new Path(newStart, trajectory.copy());
	}

	public function new(start:Position, trajectory:Array<RelativeDir>)
	{
		this.start = start;
		this.trajectory = trajectory;
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
	public var paths:Array<Path>;

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
			result += Std.string(path) + "\n";
		}

		return result;
	}

	public function new(paths:Array<Path>)
	{
		this.paths = paths;
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

	public static function GenerateAll():Void
	{
		var possible_trajectories:Array<Array<RelativeDir>> = [];

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

		for (path in validPaths)
		{
			trace(path);
			trace(path.trajectoryPoints());
		}
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
						var pathSetOfSizeN = pathSetOfSizeN_minus_one.copy();
						pathSetOfSizeN.push(path);
						pathSetsOfSizeN.push(pathSetOfSizeN);
					}
				}
			}
			allCombinationsOfPaths = allCombinationsOfPaths.concat(pathSetsOfSizeN);
			pathSetsOfSizeN_minus_one = pathSetsOfSizeN;
		}
		// for (path in validPaths)
		// {
		// 	trace(allCombinationsOfPaths);
		// }

		var allPossibleWireSquares = allCombinationsOfPaths.map(function(pathset) return new WireSquare(pathset));
		trace("NUMBER OF PATH SETS " + allPossibleWireSquares.length);
		allPossibleWireSquares = allPossibleWireSquares.filter(function(wireSquare) return wireSquare.isValid());
		for (wireSquare in allPossibleWireSquares)
		{
			trace(wireSquare.toString());
		}
		trace("NUMBER OF PATH SETS (filtered) " + allPossibleWireSquares.length);
	}
}
