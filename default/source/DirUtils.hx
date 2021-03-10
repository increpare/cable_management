enum RelativeDir
{
	forward;
	back;
	left;
	right;
}

enum AbsoluteDir
{
	north;
	south;
	east;
	west;
}

typedef LineMask =
{
	var startIndex:Int;
	var endIndex:Int;
}

typedef Position =
{
	var x:Int;
	var y:Int;
}

typedef PositionOffset =
{
	var x:Int;
	var y:Int;
}

class DirUtils
{
	public static function PointIndex(pos:Position):Int
	{
		return 4 * pos.y + pos.x;
	}

	public static function FlipLeftRight(rel:RelativeDir):RelativeDir
	{
		switch (rel)
		{
			case forward:
				return forward;
			case back:
				return back;
			case left:
				return right;
			case right:
				return left;
		}
	}

	public static function AbsoluteDirectionToPositionOffset(abs:AbsoluteDir):PositionOffset
	{
		switch (abs)
		{
			case north:
				return {x: 0, y: -1};
			case south:
				return {x: 0, y: 1};
			case east:
				return {x: 1, y: 0};
			case west:
				return {x: -1, y: 0};
		}
	}

	public static function movePosByAbsoluteDirection(pos:Position, abs:AbsoluteDir):Position
	{
		var delta = AbsoluteDirectionToPositionOffset(abs);

		return {x: pos.x + delta.x, y: pos.y + delta.y};
	}

	public static function startPosToAbsDirection(pos:Position):AbsoluteDir
	{
		switch (pos)
		{
			case {x: 0, y: _}:
				return east;
			case {x: 3, y: _}:
				return west;
			case {x: _, y: 0}:
				return south;
			case {x: _, y: 3}:
				return north;
			default:
				throw "error startPosToAbsDirection of " + pos;
		}
	}

	public static function validPosition(pos:Position):Bool
	{
		switch (pos)
		{
			case {x: 0, y: 0}:
				return false;
			case {x: 0, y: 3}:
				return false;
			case {x: 3, y: 0}:
				return false;
			case {x: 3, y: 3}:
				return false;
			case {x: x, y: y}:
				if (x < 0 || x > 3 || y < 0 || y > 3)
				{
					return false;
				}
				else
				{
					return true;
				}
		}
	}

	public static function flipRelativeDir(dir:RelativeDir):RelativeDir
	{
		switch (dir)
		{
			case forward:
				return back;
			case back:
				return forward;
			case left:
				return right;
			case right:
				return left;
		}
	}

	public static function rotateAbsoluteDir(abs:AbsoluteDir, rel:RelativeDir):AbsoluteDir
	{
		switch (abs)
		{
			case north:
				switch (rel)
				{
					case forward:
						return north;
					case back:
						return south;
					case left:
						return west;
					case right:
						return east;
				}
			case south:
				switch (rel)
				{
					case forward:
						return south;
					case back:
						return north;
					case left:
						return east;
					case right:
						return west;
				}
			case east:
				switch (rel)
				{
					case forward:
						return east;
					case back:
						return west;
					case left:
						return north;
					case right:
						return south;
				}
			case west:
				switch (rel)
				{
					case forward:
						return west;
					case back:
						return east;
					case left:
						return south;
					case right:
						return north;
				}
		}
	}
}
