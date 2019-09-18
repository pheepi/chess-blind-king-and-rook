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

{ It prints out all text output }
unit GameOutput;

interface

uses
	ChessboardSquare;


procedure PrintUsage;
procedure PrintNewGame;
procedure PrintChessboard(const userKing, computerKing, computerRook: PSquare);
procedure PrintMovedIntoCheck;
procedure PrintCheck;
procedure PrintCheckmate;



implementation

const
	USER_KING = #36;	{ '$' character }
	COMPUTER_KING = #64;	{ '@' character }
	COMPUTER_ROOK = #38;	{ '&' character }
	LIGHT_SQUARE = #178;	{ Code of "light block" character }
	DARK_SQUARE = #176;	{ Code of "dark block" character }


{ Print usage (controls and game pieces) of the program }
procedure PrintUsage;
begin
	WriteLn('Basic checkmate: King and rook (blind computer)');
	WriteLn('Commands:');
	WriteLn('    789      yui        Movement of user king');
	WriteLn('    4 6  or  h k');
	WriteLn('    123      bnm');
	WriteLn('    TAB or r            Game restart');
	WriteLn('    ESCAPE, q or x      Program termination');
	WriteLn('Pieces:');
	WriteLn('    ' + USER_KING + ' (user king), ' + COMPUTER_KING
		+ ' (computer king), ' + COMPUTER_ROOK + ' (computer rook)');
	WriteLn;
end;


{ Print new game headline }
procedure PrintNewGame;
begin
	WriteLn('----==== NEW GAME ====----');
end;


{ Print chessboard with light and dark squares and all pieces }
procedure PrintChessboard(const userKing, computerKing,
	computerRook: PSquare);
var
	isLight: boolean;
	i, j: Coordinate;
begin
	Write(' ');

	for j := 0 to CHESSBOARD_DIMENSION - 1 do
	begin
		Write(Chr(j + Ord('A')));
	end;

	WriteLn;
	isLight := true;
	for i := 1 to CHESSBOARD_DIMENSION do
	begin
		Write(Chr(CHESSBOARD_DIMENSION - i + Ord('1')));

		for j := 1 to CHESSBOARD_DIMENSION do
		begin
			if HasPositionTheseCoordinates(userKing, i, j) then
			begin
				Write(USER_KING);
			end
			else if HasPositionTheseCoordinates(computerKing,
				i, j) then
			begin
				Write(COMPUTER_KING);
			end
			else if HasPositionTheseCoordinates(computerRook,
				i, j) then
			begin
				Write(COMPUTER_ROOK);
			end
			else if isLight then
			begin
				Write(LIGHT_SQUARE);
			end
			else
			begin
				Write(DARK_SQUARE);
			end;

			isLight := not isLight;
		end;

		isLight := not isLight;
		WriteLn;
	end;
end;


{ Inform about illegal move }
procedure PrintMovedIntoCheck;
begin
	WriteLn('King must not be moved into check!');
end;


{ Inform about check }
procedure PrintCheck;
begin
	WriteLn('Check!');
end;


{ Inform about checkmate }
procedure PrintCheckmate;
begin
	WriteLn('Checkmate! Game over.');
end;


end.
