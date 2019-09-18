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

{ The unit controls input of a user }
unit UserInput;

interface

uses
	ChessboardSquare;


function IsTerminating: boolean;
function IsRestarting: boolean;
procedure ReadCommand;
procedure ChangePositionByCommand(position: PSquare);



implementation

uses
	Crt;


const
	UP_KEY = '8';
	DOWN_KEY = '2';
	LEFT_KEY = '4';
	RIGHT_KEY = '6';
	LEFT_UP_KEY = '7';
	LEFT_DOWN_KEY = '1';
	RIGHT_UP_KEY = '9';
	RIGHT_DOWN_KEY = '3';

	UP_ALT_KEY = 'u';
	DOWN_ALT_KEY = 'n';
	LEFT_ALT_KEY = 'h';
	RIGHT_ALT_KEY = 'k';
	LEFT_UP_ALT_KEY = 'y';
	LEFT_DOWN_ALT_KEY = 'b';
	RIGHT_UP_ALT_KEY = 'i';
	RIGHT_DOWN_ALT_KEY = 'm';

	UP_KEY_CAP = 'U';
	DOWN_KEY_CAP = 'N';
	LEFT_KEY_CAP = 'H';
	RIGHT_KEY_CAP = 'K';
	LEFT_UP_KEY_CAP = 'Y';
	LEFT_DOWN_KEY_CAP = 'B';
	RIGHT_UP_KEY_CAP = 'I';
	RIGHT_DOWN_KEY_CAP = 'M';

	TERMINATION_KEY = #27;	{ Escape key that terminates the program }
	TERMINATION_ALT_KEY = 'q';	{ Alternative key for termination }
	TERMINATION_KEY_CAP = 'Q';	{ Capital letter key for termination }
	TERMINATION_ALT2_KEY = 'x';	{ Alternative key 2 for termination }
	TERMINATION_KEY_CAP2 = 'X';	{ Capital letter key 2 for termination }
	GAME_RESTART_KEY = #9;	{ Tab key that restart the game }
	GAME_RESTART_ALT_KEY = 'r';	{ Alternative key for game restart }
	GAME_RESTART_KEY_CAP = 'R';	{ Capital letter key for game restart }

	ACCEPTED_KEY_COUNT = 32;
	ACCEPTED_KEYS: array [0..ACCEPTED_KEY_COUNT - 1] of char
		= (UP_KEY, DOWN_KEY, LEFT_KEY, RIGHT_KEY, LEFT_UP_KEY,
		LEFT_DOWN_KEY, RIGHT_UP_KEY, RIGHT_DOWN_KEY, UP_ALT_KEY,
		DOWN_ALT_KEY, LEFT_ALT_KEY, RIGHT_ALT_KEY, LEFT_UP_ALT_KEY,
		LEFT_DOWN_ALT_KEY, RIGHT_UP_ALT_KEY, RIGHT_DOWN_ALT_KEY,
		UP_KEY_CAP, DOWN_KEY_CAP, LEFT_KEY_CAP, RIGHT_KEY_CAP,
		LEFT_UP_KEY_CAP, LEFT_DOWN_KEY_CAP, RIGHT_UP_KEY_CAP,
		RIGHT_DOWN_KEY_CAP, TERMINATION_KEY, TERMINATION_ALT_KEY,
		TERMINATION_KEY_CAP, TERMINATION_ALT2_KEY, TERMINATION_KEY_CAP2,
		GAME_RESTART_KEY, GAME_RESTART_ALT_KEY, GAME_RESTART_KEY_CAP);


var
	inputCommand: char;	{ Character that represents user command }


{ Indicate whether user has entered termination command }
function IsTerminating: boolean;
begin
	IsTerminating := ((inputCommand = TERMINATION_KEY)
		or (inputCommand = TERMINATION_ALT_KEY)
		or (inputCommand = TERMINATION_KEY_CAP)
		or (inputCommand = TERMINATION_ALT2_KEY)
		or (inputCommand = TERMINATION_KEY_CAP2));
end;


{ Indicate whether user has restarted the game }
function IsRestarting: boolean;
begin
	IsRestarting := ((inputCommand = GAME_RESTART_KEY)
		or (inputCommand = GAME_RESTART_ALT_KEY)
		or (inputCommand = GAME_RESTART_KEY_CAP));
end;


{ Repeat until user types a valid character of command }
procedure ReadCommand;
var
	isValid: boolean;
	i: integer;
begin
	repeat
		inputCommand := ReadKey;
		isValid := false;

		{ Check whether command is valid }
		for i := 0 to ACCEPTED_KEY_COUNT - 1 do
		begin
			if inputCommand = ACCEPTED_KEYS[i] then
			begin
				isValid := true;
				break;
			end;
		end;
	until isValid;
end;


{ Change the position depending on user input command }
procedure ChangePositionByCommand(position: PSquare);
begin
	case inputCommand of
		UP_KEY, UP_ALT_KEY, UP_KEY_CAP: MoveUp(position);
		DOWN_KEY, DOWN_ALT_KEY, DOWN_KEY_CAP: MoveDown(position);
		LEFT_KEY, LEFT_ALT_KEY, LEFT_KEY_CAP: MoveLeft(position);
		RIGHT_KEY, RIGHT_ALT_KEY, RIGHT_KEY_CAP: MoveRight(position);
		LEFT_UP_KEY, LEFT_UP_ALT_KEY, LEFT_UP_KEY_CAP:
			MoveLeftUp(position);
		LEFT_DOWN_KEY, LEFT_DOWN_ALT_KEY, LEFT_DOWN_KEY_CAP:
			MoveLeftDown(position);
		RIGHT_UP_KEY, RIGHT_UP_ALT_KEY, RIGHT_UP_KEY_CAP:
			MoveRightUp(position);
		RIGHT_DOWN_KEY, RIGHT_DOWN_ALT_KEY, RIGHT_DOWN_KEY_CAP:
			MoveRightDown(position);
		else	{ Do nothing when it is not command of move }
			assert(false);
	end;
end;


begin
	inputCommand := #0;
end.


end.
