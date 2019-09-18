{
Copyright (c) 2007 - 2019, David Skorvaga
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
}

{ It defines operations for a position/square of chessboard }
unit ChessboardSquare;

interface

const
	CHESSBOARD_DIMENSION = 8;	{ Width and height of chessboard }


type

{ Coordinate (row or column) on chessboard or next to it (invalid position) }
Coordinate = integer; { TODO: Pred(1)..Succ(CHESSBOARD_DIMENSION); }

PSquare = ^Square;
{ The position of a square on chessboard }
Square = record
	x, y: Coordinate;	{ Coordinates of a square chessboard (1 - 8) }
end;


function ArePositionsEqual(const position1, position2: PSquare): boolean;
function HasSameRow(const position1, position2: PSquare): boolean;
function HasSameColumn(const position1, position2: PSquare): boolean;
function HasSameRowOrColumn(const position1, position2: PSquare): boolean;

function HasPositionTheseCoordinates(const position: PSquare;
	const x, y: Coordinate): boolean;
function IsValidSquare(const square: PSquare): boolean;
function ArePositionsNextToOther(const position1,
	position2: PSquare): boolean;
function IsSquareBetween(const square1, square2, between: PSquare): boolean;

function GetX(const position: PSquare): Coordinate;
function GetY(const position: PSquare): Coordinate;
procedure SetSquare(position: PSquare; const x, y: Coordinate);

procedure MoveUp(position: PSquare);
procedure MoveDown(position: PSquare);
procedure MoveLeft(position: PSquare);
procedure MoveRight(position: PSquare);
procedure MoveLeftUp(position: PSquare);
procedure MoveLeftDown(position: PSquare);
procedure MoveRightUp(position: PSquare);
procedure MoveRightDown(position: PSquare);



implementation

{ Check whether positions are the same }
function ArePositionsEqual(const position1, position2: PSquare): boolean;
begin
	assert(position1 <> nil);
	assert(position2 <> nil);

	ArePositionsEqual := ((position1^.x = position2^.x)
		and (position1^.y = position2^.y));
end;


{ Check whether positions have the same x-coordinate }
function HasSameRow(const position1, position2: PSquare): boolean;
begin
	assert(position1 <> nil);
	assert(position2 <> nil);

	HasSameRow := (position1^.x = position2^.x);
end;


{ Check whether positions have the same y-coordinate }
function HasSameColumn(const position1, position2: PSquare): boolean;
begin
	assert(position1 <> nil);
	assert(position2 <> nil);

	HasSameColumn := (position1^.y = position2^.y);
end;


{ Check whether positions have the same x-coordinate or y-coordinate }
function HasSameRowOrColumn(const position1, position2: PSquare): boolean;
begin
	HasSameRowOrColumn := (HasSameRow(position1, position2)
		or HasSameColumn(position1, position2));
end;


{ Check whether position has the coordinates }
function HasPositionTheseCoordinates(const position: PSquare;
	const x, y: Coordinate): boolean;
begin
	assert(position <> nil);
	HasPositionTheseCoordinates := ((position^.x = x)
		and (position^.y = y));
end;


{ Check whether the position is a valid square of chessboard }
function IsValidSquare(const square: PSquare): boolean;
begin
	assert(square <> nil);
	IsValidSquare := ((square^.x > 0)
		and (square^.x <= CHESSBOARD_DIMENSION)
		and (square^.y > 0) and (square^.y <= CHESSBOARD_DIMENSION));
end;


{ Check whether squares are adjacent (even with corners) }
function ArePositionsNextToOther(const position1,
	position2: PSquare): boolean;
begin
	assert(IsValidSquare(position1));
	assert(position2 <> nil);

	ArePositionsNextToOther := ((Succ(position1^.x) >= position2^.x)
		and (Pred(position1^.x) <= position2^.x)
		and (Succ(position1^.y) >= position2^.y)
		and (Pred(position1^.y) <= position2^.y));
end;


{ Check whether a square is located on a line of other two squares }
function IsSquareBetween(const square1, square2, between: PSquare): boolean;
begin
	assert(square1 <> nil);
	assert(square2 <> nil);
	assert(between <> nil);

	IsSquareBetween :=
		(((square1^.x = square2^.x) and (between^.x = square1^.x)
		and (((square1^.y < between^.y) and (between^.y < square2^.y))
		or ((square1^.y > between^.y) and (between^.y > square2^.y))))
		or ((square1^.y = square2^.y) and (between^.y = square1^.y)
		and (((square1^.x < between^.x) and (between^.x < square2^.x))
		or ((square1^.x > between^.x)
		and (between^.x > square2^.x)))))
end;


{ Get x-coordinate of a square }
function GetX(const position: PSquare): Coordinate;
begin
	assert(position <> nil);
	GetX := position^.x;
end;


{ Get y-coordinate of a square }
function GetY(const position: PSquare): Coordinate;
begin
	assert(position <> nil);
	GetY := position^.y;
end;


{ Set new position with x and y coordinates }
procedure SetSquare(position: PSquare; const x, y: Coordinate);
begin
	assert(position <> nil);
	position^.x := x;
	position^.y := y;
end;


{ Change the position such that we move up in chessboard (decrement x) }
procedure MoveUp(position: PSquare);
begin
	assert(position <> nil);
	assert(position^.x > 0);

	Dec(position^.x);
end;


{ Change the position such that we move down in chessboard (increment x) }
procedure MoveDown(position: PSquare);
begin
	assert(position <> nil);
	assert(position^.x <= CHESSBOARD_DIMENSION);

	Inc(position^.x);
end;


{ Change the position such that we move left in chessboard (decrement y) }
procedure MoveLeft(position: PSquare);
begin
	assert(position <> nil);
	assert(position^.y > 0);

	Dec(position^.y);
end;


{ Change the position such that we move right in chessboard (increment y) }
procedure MoveRight(position: PSquare);
begin
	assert(position <> nil);
	assert(position^.y <= CHESSBOARD_DIMENSION);

	Inc(position^.y);
end;


{ Change the position such that we move left and up }
procedure MoveLeftUp(position: PSquare);
begin
	MoveLeft(position);
	MoveUp(position);
end;


{ Change the position such that we move left and down }
procedure MoveLeftDown(position: PSquare);
begin
	MoveLeft(position);
	MoveDown(position);
end;


{ Change the position such that we move right and up }
procedure MoveRightUp(position: PSquare);
begin
	MoveRight(position);
	MoveUp(position);
end;


{ Change the position such that we move right and down }
procedure MoveRightDown(position: PSquare);
begin
	MoveRight(position);
	MoveDown(position);
end;


end.
