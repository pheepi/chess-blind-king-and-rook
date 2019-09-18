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

{ It contains position of pieces and check their valid setup }
unit BoardRepresentation;

interface

uses
	ChessboardSquare;


procedure SetRandomGenerator;
procedure ResetRandomGame;

function GetUserKing: PSquare;
function GetComputerKing: PSquare;
function GetComputerRook: PSquare;

procedure SetComputerKing(const king: PSquare);
procedure SetComputerRook(const rook: PSquare);

function IsUserKingInCheck: boolean;
function IsUserKingInCheckMovingUK(const king: PSquare): boolean;
function IsUserKingInCheckMovingCK(const king: PSquare): boolean;
function IsUserKingInCheckMovingCR(const rook: PSquare): boolean;
function MayUserKingMove: boolean;



implementation

uses
	Crt;


var
	userKing: Square;	{ Position of user king }
	computerKing: Square;	{ Position of computer king }
	computerRook: Square;	{ Position of computer rook }


{ Initialize internal position of pieces }
procedure Initialize;
begin
	SetSquare(@userKing, 0, 0);
	SetSquare(@computerKing, 0, 0);
	SetSquare(@computerRook, 0, 0);
end;


{ Set pseudo-randomizer to initial value }
procedure SetRandomGenerator;
begin
	Randomize;
end;


{ Create random position on chessboard }
procedure GenerateRandomPosition(position: PSquare);
begin
	SetSquare(position, Succ(random(CHESSBOARD_DIMENSION)),
		Succ(random(CHESSBOARD_DIMENSION)));
end;


{ Generate random positions of pieces (not deterministic, but simple) }
procedure ResetRandomGame;
begin
	GenerateRandomPosition(@computerKing);
{ TODO: Vygenerovat bezpecnou startovni pozici, a deterministicky }
	repeat
		GenerateRandomPosition(@computerRook);
	until not ArePositionsEqual(@computerRook, @computerKing);

	repeat
		GenerateRandomPosition(@userKing);
	until (not ArePositionsEqual(@userKing, @computerKing))
		and (not ArePositionsEqual(@userKing, @computerRook))
		and (not ArePositionsNextToOther(@userKing, @computerKing))
		and (not ArePositionsNextToOther(@userKing, @computerRook))
		and (not IsUserKingInCheck) and MayUserKingMove;
end;


{ Get reference to current user king position }
function GetUserKing: PSquare;
begin
	GetUserKing := @userKing;
end;


{ Get reference to current computer king position }
function GetComputerKing: PSquare;
begin
	GetComputerKing := @computerKing;
end;


{ Get reference to current computer rook position }
function GetComputerRook: PSquare;
begin
	GetComputerRook := @computerRook;
end;


{ Set new current position of computer king }
procedure SetComputerKing(const king: PSquare);
begin
	assert(IsValidSquare(king));
	computerKing := king^;
end;


{ Set new current position of computer rook }
procedure SetComputerRook(const rook: PSquare);
begin
	assert(IsValidSquare(rook));
	computerRook := rook^;
end;


{ Check whether user king is in check by computer rook (private function) }
function IsUserKingInCheckPrivate(const pUserKing, pComputerKing,
	pComputerRook: PSquare): boolean;
begin
	IsUserKingInCheckPrivate := (HasSameRowOrColumn(pUserKing,
		pComputerRook) and (not IsSquareBetween(pUserKing,
		pComputerRook, pComputerKing)))
end;


{ Check whether user king is in check by computer rook }
function IsUserKingInCheck: boolean;
begin
	IsUserKingInCheck := IsUserKingInCheckPrivate(@userKing,
		@computerKing, @computerRook);
end;


{ Check whether user king is in check by computer rook after its move }
function IsUserKingInCheckMovingUK(const king: PSquare): boolean;
begin
	IsUserKingInCheckMovingUK := IsUserKingInCheckPrivate(king,
		@computerKing, @computerRook);
end;


{ Check whether user king is in check after computer king move }
function IsUserKingInCheckMovingCK(const king: PSquare): boolean;
begin
	IsUserKingInCheckMovingCK := IsUserKingInCheckPrivate(@userKing,
		king, @computerRook);
end;


{ Check whether user king is in check after computer rook move }
function IsUserKingInCheckMovingCR(const rook: PSquare): boolean;
begin
	IsUserKingInCheckMovingCR := IsUserKingInCheckPrivate(@userKing,
		@computerKing, rook);
end;


{ Detect whether moving of user king does not cause check }
function MayUserKingMove: boolean;
var
	position: Square;
	i, j: integer;
begin
	MayUserKingMove := false;

	for i := -1 to 1 do
	begin
		for j := -1 to 1 do
		begin
			if (i = 0) and (j = 0) then
			begin
				continue;
			end;

			position.x := userKing.x + i;
			position.y := userKing.y + j;
			if not IsValidSquare(@position) then
			begin
				continue;
			end;

			if ArePositionsNextToOther(@computerKing,
				@position) then
			begin
				continue;
			end;

			if not IsUserKingInCheckMovingUK(@position) then
			begin
				MayUserKingMove := true;
				break;
			end;
		end;
	end;
end;


begin
	Initialize;
end.


end.
