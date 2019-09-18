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

{ Basic checkmate program: King and rook (blind computer) }
program Checkmate;

uses
	ChessboardSquare,
	UserInput,
	GameOutput,
	BoardRepresentation,
	AI;


{ Print chessboard with all pieces in current position }
procedure PrintCurrentChessboard;
var
	userKing, computerKing, computerRook: PSquare;
begin
	userKing := GetUserKing;
	computerKing := GetComputerKing;
	computerRook := GetComputerRook;

        PrintChessboard(userKing, computerKing, computerRook);
end;


{ Perform one user command and return if it is valid }
function PerformUserCommand: boolean;
var
	userKing, computerKing: PSquare;
	position: Square;
begin
	ReadCommand;

	if IsTerminating then
	begin
		Halt;
	end;

	userKing := GetUserKing;
	computerKing := GetComputerKing;

	if IsRestarting then
	begin
		ResetAI;
		ResetRandomGame;
		PrintNewGame;
		PrintCurrentChessboard;

		PerformUserCommand := false;
		exit;
	end;

	position := userKing^;
	ChangePositionByCommand(@position);

	if not IsValidSquare(@position)
		or ArePositionsNextToOther(computerKing, @position) then
	begin
		PerformUserCommand := false;
		exit;
	end;

	if IsUserKingInCheckMovingUK(@position) then
	begin
		PrintMovedIntoCheck;
		PrintCurrentChessboard;

		PerformUserCommand := false;
		exit;
	end;

	userKing^ := position;
	PerformUserCommand := true;
end;


{ Perform user turn }
procedure ExecuteUserTurn;
begin
	PrintCurrentChessboard;

	repeat until PerformUserCommand;
end;


{ Identify game violation that intented move of computer piece may cause }
function GetAIGameViolation: GameViolation;
var
	userKing, position: PSquare;
begin
	position := GetNextIntendedPosition;
	if IsPieceIntendedToMoveKing then
	begin
		userKing := GetUserKing;
		if ArePositionsNextToOther(userKing, position) then
			GetAIGameViolation := KingsNextToOther
		else if IsUserKingInCheckMovingCK(position) then
			GetAIGameViolation := KingInCheck
		else
			GetAIGameViolation := ValidArrangement;
	end
	else
	begin
		if IsUserKingInCheckMovingCR(position) then
			GetAIGameViolation := KingInCheck
		else
			GetAIGameViolation := ValidArrangement;
	end;
end;


{ TODO }
procedure ExecuteComputerTurn;
var
	computerKing, computerRook: PSquare;
	violation: GameViolation;
begin
	computerKing := GetComputerKing;
	computerRook := GetComputerRook;

	repeat
		ComputeNextMove(computerKing, computerRook);
		violation := GetAIGameViolation;
		ReportGameViolation(violation);
	until not (violation = KingsNextToOther);

	assert(IsValidSquare(GetNextIntendedPosition)); { TODO }
	if IsPieceIntendedToMoveKing then
		computerKing^ := GetNextIntendedPosition^
	else
		computerRook^ := GetNextIntendedPosition^;

	if violation = KingInCheck then
	begin
		PrintCheck;
	end;
end;


{ Set the game and repeat user's and computer's turns }
procedure RunGame;
begin
	SetRandomGenerator;
	ResetRandomGame;

	PrintUsage;
	PrintNewGame;

	repeat
		ExecuteUserTurn;
		ExecuteComputerTurn;
	until not MayUserKingMove;

	PrintCurrentChessboard;
	PrintCheckmate;
end;


begin
	RunGame;
end.
