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

{ TODO }
unit AI;

interface

uses
	ChessboardSquare;


type
	{ Possible situations that pieces may constitute }
	GameViolation = (
		ValidArrangement,
		KingInCheck,
		KingsNextToOther
	);


procedure ComputeNextMove(const king, rook: PSquare);
procedure ReportGameViolation(violation: GameViolation);
procedure ResetAI;

function GetNextIntendedPosition: PSquare;
function IsPieceIntendedToMoveKing: boolean;



implementation

type
	{ Major part of state in AI finite machine defining general behavior }
	AIPhase = (
		InitialPhase,
		StandardPhase,
		KingsNextToOtherPhase,
		KingInCheckPhaze,
		NearWallPhase
	);

	{ Minor part of state in AI finite machine, specific for every phase }
	AIState = 1..21;

	{
	 AI tries to force user's king into board border, where computer's king
	 forces it into corner. Borders are numbered as members of congruence
	 class from the upper one clockwise.
	}
	ForceDirection = (
		PushingUp,
		PushingRight,
		PushingDown,
		PushingLeft
	);

	{ Defining of forward or backward movement in one direction }
	MoveDirection = -1..1;


const
	DirectionsCount = Ord(High(ForceDirection))
		- Ord(Low(ForceDirection)) + 1;


var
	{
	 Current phase of AI state machine. Transition may be move of piece
	 or empty step, often cause by exception
	}
	currentAIPhase: AIPhase;
	{ Current state of AI in context of current phase }
	currentAIState: AIState;

	{ Phase that AI intends to perform if kings are not next to each other }
	intendedAIPhase: AIPhase;
	{ State in phase that AI intends to perform }
	intendedAIState: AIState;

	{ Position where AI intends to move its piece in the current turn }
	nextIntendedPosition: Square;
	{ Information about what piece AI intends to move, king or rook }
	isKingIntendedToMove: boolean;

	{ Direction of pushing where the user's king is expected }
	userKingDirection: ForceDirection;





	soucasny_smer_pohybu: MoveDirection; {urcuje smer pohybu pri klidnem pohybu (tedy
		v etape c.1). Smer zavisi na 'userKingDirection'.
		Muze nabyvat hodnot 1 pro pohyb vpravo a -1 pro pohyb vlevo}















var

	informace_o_tahu_pocitace: GameViolation; {Pokud se pocitac pokusi provest svuj tah,
		zde je ulozeny hodnota vyjadrujici, co tah pocitace zpusobi.
		Nabyva hodnot ValidArrangement, KingInCheck a KingsNextToOther}









	nastal_pri_pohybu_posun_o_radek: boolean; {Promenna udava pribliznejsi
		obraz, kde se hracuv kral nachazi}












































{Vzhledem ke "klidovemu" smeru pohybu a vlozenemu parametru se vypocita
 skutecny smer pohybu na sachovnici. Hodnoty parametru mohou byt 0 az 3,
 kde 0 je "klidovy" smer pohybu a ostatni jsou podle hodinovych rucicek}
procedure navrhniPosunFigurkyPocitace(const figurka_pocitace: PSquare;
	smer_posunu:integer);
begin
	nextIntendedPosition := figurka_pocitace^;

	if (smer_posunu mod 2) = 1 then
	begin
		case userKingDirection of
			PushingUp: nextIntendedPosition.x := nextIntendedPosition.x +
				(((smer_posunu + 2) mod DirectionsCount) - 2);
			PushingRight: nextIntendedPosition.y := nextIntendedPosition.y +
				(smer_posunu - 2);
			PushingDown: nextIntendedPosition.x := nextIntendedPosition.x +
				(smer_posunu - 2);
			PushingLeft: nextIntendedPosition.y := nextIntendedPosition.y +
				(((smer_posunu + 2) mod DirectionsCount) - 2);
		end;
	end
	else
	begin
		case ForceDirection((Ord(userKingDirection) + smer_posunu) mod DirectionsCount) of
			PushingUp: nextIntendedPosition.y := nextIntendedPosition.y +
				soucasny_smer_pohybu;
			PushingRight: nextIntendedPosition.x := nextIntendedPosition.x +
				soucasny_smer_pohybu;
			PushingDown: nextIntendedPosition.y := nextIntendedPosition.y -
				soucasny_smer_pohybu;
			PushingLeft: nextIntendedPosition.x := nextIntendedPosition.x -
				soucasny_smer_pohybu;
		end;
	end;
end;


{Procedura nastavi vsechny potrebne promenne pro vykonani dalsiho tahu}
procedure chystanyPostupPocitace(const pozice_figurky: PSquare;
              postup_po_smeru, postup_kolmo_ke_smeru: integer; figurka: boolean;
              etapa_pocitace: AIPhase; stav_pocitace: AIState);
var cyklus,
    smer_posunu_figurky:integer;
begin
    nextIntendedPosition := pozice_figurky^;

    if (postup_po_smeru >= 0) then
    begin
        smer_posunu_figurky := 0;
    end else begin
        smer_posunu_figurky := 2;
        postup_po_smeru := postup_po_smeru * (-1);
    end;

    for cyklus := 1 to postup_po_smeru do
        navrhniPosunFigurkyPocitace(@nextIntendedPosition, smer_posunu_figurky);

    if (postup_kolmo_ke_smeru >= 0) then
    begin
        smer_posunu_figurky := 3;
    end else begin
        smer_posunu_figurky := 1;
        postup_kolmo_ke_smeru := postup_kolmo_ke_smeru * (-1);
    end;

    for cyklus := 1 to postup_kolmo_ke_smeru do
        navrhniPosunFigurkyPocitace(@nextIntendedPosition, smer_posunu_figurky);

    isKingIntendedToMove := figurka;
    intendedAIPhase := etapa_pocitace;
    intendedAIState := stav_pocitace;
end;


{Pokud nastane nejaka vyjimka (kralove vedle sebe, sach, naraz do zdi),
 funkce nastavi novou etapu a stav k vykonani. Funkce vraci vzdy TRUE}
function vyvolaniVyjimkyPriNahleSituaci(vyjimka_etapa: AIPhase;
             vyjimka_stav: AIState):boolean;
begin
    currentAIPhase := vyjimka_etapa;
    currentAIState := vyjimka_stav;
    informace_o_tahu_pocitace := ValidArrangement;
    vyvolaniVyjimkyPriNahleSituaci := TRUE;
end;


{Funkci jsou dana cisla posunu. Pokud by pri alespon jednom posunu (po
 smeru nebo kolmo ke smeru) figurka skonci na sachovnici, vraci funkce
 hodnotu FALSE. Tato funkce se pouziva k velmi vyjimecnym stavum hry,
 napriklad pokud muze nastat Pat nebo bezprostredni Sach-Mat}
function jeFigurkaTakBlizkoKraje(poz_figurky: PSquare; po_smeru,
             kolmo_ke_smeru:integer):boolean;
var je_figurka_tak_blizko_kraje:boolean;
begin
    je_figurka_tak_blizko_kraje := TRUE;

    chystanyPostupPocitace(poz_figurky, po_smeru, 0,
        isKingIntendedToMove, intendedAIPhase,
        intendedAIState);
    if (IsValidSquare(@nextIntendedPosition))
        then je_figurka_tak_blizko_kraje := FALSE;

    chystanyPostupPocitace(poz_figurky, 0, kolmo_ke_smeru,
        isKingIntendedToMove, intendedAIPhase,
        intendedAIState);
    if (IsValidSquare(@nextIntendedPosition))
        then je_figurka_tak_blizko_kraje := FALSE;

    jeFigurkaTakBlizkoKraje := je_figurka_tak_blizko_kraje;
end;


{Mozek programu - V zavislosti na pozici vlastni veze a krale,
 na predchozich tazich a na stavovych hlasenich, procedura vygeneruje
 tah svoji figurkou a dalsi mozny postup}
procedure ComputeNextMove(const king, rook: PSquare);
var vnitrni_AI_etapa_pocitace: AIPhase;
    vnitrni_AI_stav_pocitace: AIState;
    vyvolana_vnitrni_zmena_stavu:boolean;
begin

    vnitrni_AI_etapa_pocitace := currentAIPhase;
    vnitrni_AI_stav_pocitace := currentAIState;

    repeat

        vyvolana_vnitrni_zmena_stavu := FALSE;

        case vnitrni_AI_etapa_pocitace of

    {                  ETAPA c.0 - Pocatecni etapa                  }
    { Na zacatku pocitac nevi vubec nic o pozici hracova krale.     }
    { V teto etape jsou figurky pocitace presunuty do libovolneho   }
    { rohu sachovnice a postaveny do standardniho postaveni.        }

            InitialPhase: begin
                case vnitrni_AI_stav_pocitace of
                    1: begin
                        informace_o_tahu_pocitace := ValidArrangement;
                        nastal_pri_pohybu_posun_o_radek := FALSE;

                        if (((king^.x = 1) or
                            (king^.x = CHESSBOARD_DIMENSION)) and
                           ((king^.y = 1) or
                            (king^.y = CHESSBOARD_DIMENSION))) then
                        begin
                            if ((rook^.x = king^.x) or
                               (rook^.y = king^.y)) then
                            begin
                                nextIntendedPosition.x := king^.x +
                                    (((king^.x + 1) mod (CHESSBOARD_DIMENSION + 1)) - 1);
                                nextIntendedPosition.y := king^.y +
                                    (((king^.y + 1) mod (CHESSBOARD_DIMENSION + 1)) - 1);
                                isKingIntendedToMove := false;
                                intendedAIPhase := InitialPhase;
                                intendedAIState := 2;
                            end else
                                vyvolana_vnitrni_zmena_stavu :=
                                    vyvolaniVyjimkyPriNahleSituaci(InitialPhase, 2);
                        end else begin
                            if (((king^.x = 1) or
                                (king^.x = CHESSBOARD_DIMENSION)) or
                               ((king^.y = 1) or
                                (king^.y = CHESSBOARD_DIMENSION)))
                            then vyvolana_vnitrni_zmena_stavu :=
                                     vyvolaniVyjimkyPriNahleSituaci(InitialPhase, 4)
                            else vyvolana_vnitrni_zmena_stavu :=
                                     vyvolaniVyjimkyPriNahleSituaci(InitialPhase, 11);
                        end;
                    end;
                    2: begin
                        nextIntendedPosition.x := king^.x +
                            (((king^.x + 1) mod (CHESSBOARD_DIMENSION + 1)) - 1);
                        nextIntendedPosition.y := king^.y;
                        isKingIntendedToMove := true;
                        intendedAIPhase := InitialPhase;
                        intendedAIState := 4;

                        if (informace_o_tahu_pocitace = KingsNextToOther) then
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(InitialPhase, 3);
                    end;
                    3: begin
                        nextIntendedPosition.x := king^.x;
                        nextIntendedPosition.y := king^.y +
                            (((king^.y + 1) mod (CHESSBOARD_DIMENSION + 1)) - 1);
                        isKingIntendedToMove := true;
                        intendedAIPhase := InitialPhase;
                        intendedAIState := 4;
                    end;
                    4: begin
                        soucasny_smer_pohybu := 1;

                        if (king^.x = 1) then
                        begin
                            userKingDirection := PushingDown;
                        end;
                        if (king^.x = CHESSBOARD_DIMENSION) then
                        begin
                            userKingDirection := PushingUp;
                        end;
                        if (king^.y = 1) then
                        begin
                            userKingDirection := PushingRight;
                        end;
                        if (king^.y = CHESSBOARD_DIMENSION) then
                        begin
                            userKingDirection := PushingLeft;
                        end;

                        navrhniPosunFigurkyPocitace(king, 3);

                        if ((nextIntendedPosition.x = rook^.x) and
                           (nextIntendedPosition.y = rook^.y)) then
                        begin
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(InitialPhase, 6);
                        end else begin
                            if ((nextIntendedPosition.x = rook^.x) or
                               (nextIntendedPosition.y = rook^.y))
                            then vyvolana_vnitrni_zmena_stavu :=
                                     vyvolaniVyjimkyPriNahleSituaci(InitialPhase, 5)
                            else chystanyPostupPocitace(rook, 0, 1,
                                     false, InitialPhase, 5);
                        end;
                    end;
                    5: chystanyPostupPocitace(king, 0, 1,
                           false, InitialPhase, 6);
                    6: begin
                        if (((king^.x = 2) or
                            (king^.x = CHESSBOARD_DIMENSION - 1)) or
                           ((king^.y = 2) or
                            (king^.y = CHESSBOARD_DIMENSION - 1))) then
                        begin
                            navrhniPosunFigurkyPocitace(king, 0);
                            navrhniPosunFigurkyPocitace(@nextIntendedPosition, 0);

                            if (IsValidSquare(@nextIntendedPosition))
                            then chystanyPostupPocitace(king, 1, 0,
                                     true, InitialPhase, 8)
                            else chystanyPostupPocitace(king, -1, 0,
                                     true, InitialPhase, 8);

                            if (informace_o_tahu_pocitace = KingsNextToOther) then
                                vyvolana_vnitrni_zmena_stavu :=
                                    vyvolaniVyjimkyPriNahleSituaci(InitialPhase, 7);
                        end else
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(InitialPhase, 9);
                    end;
                    7: begin
                            navrhniPosunFigurkyPocitace(king, 0);
                            navrhniPosunFigurkyPocitace(@nextIntendedPosition, 0);

                            if (IsValidSquare(@nextIntendedPosition)) then
                            begin
                                chystanyPostupPocitace(king, -1, 1,
                                     true, InitialPhase, 6);
                                userKingDirection :=
                                    ForceDirection((Ord(userKingDirection) + 1) mod DirectionsCount);
                            end else begin
                                chystanyPostupPocitace(king, 1, 1,
                                     true, InitialPhase, 6);
                                userKingDirection :=
                                    ForceDirection((Ord(userKingDirection) - 1) mod DirectionsCount);
                            end;
                    end;
                    8: begin
                        navrhniPosunFigurkyPocitace(rook, 0);
                        navrhniPosunFigurkyPocitace(@nextIntendedPosition, 0);

                        if (IsValidSquare(@nextIntendedPosition))
                        then chystanyPostupPocitace(rook, 1, 0,
                                 false, InitialPhase, 9)
                        else chystanyPostupPocitace(rook, -1, 0,
                                 false, InitialPhase, 9);
                    end;
                    9: begin
                        chystanyPostupPocitace(king, 1, 1,
                            true, InitialPhase, 11);

                        if (informace_o_tahu_pocitace = KingsNextToOther) then
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(InitialPhase, 10);
                    end;
                    10: chystanyPostupPocitace(king, -1, 1,
                            true, InitialPhase, 11);
                    11: begin
                        soucasny_smer_pohybu := 1;

                        if ((king^.x <> rook^.x) and
                           (king^.y <> rook^.y)) then
                        begin
                            if (((king^.x - rook^.x) = 1) and
                               ((king^.y - rook^.y) = 1)) then
                            begin
                                userKingDirection := PushingRight;
                            end;
                            if (((king^.x - rook^.x) = 1) and
                               ((king^.y - rook^.y) = (-1))) then
                            begin
                                userKingDirection := PushingDown;
                            end;
                            if (((king^.x - rook^.x) = (-1)) and
                               ((king^.y - rook^.y) = 1)) then
                            begin
                                userKingDirection := PushingUp;
                            end;
                            if (((king^.x - rook^.x) = (-1)) and
                               ((king^.y - rook^.y) = (-1))) then
                            begin
                                userKingDirection := PushingLeft;
                            end;

                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(InitialPhase, 13);
                        end else begin
                            if ((king^.x - rook^.x) = 1) then
                            begin
                                userKingDirection := PushingDown;
                            end;
                            if ((king^.x - rook^.x) = (-1)) then
                            begin
                                userKingDirection := PushingUp;
                            end;
                            if ((king^.y - rook^.y) = 1) then
                            begin
                                userKingDirection := PushingRight;
                            end;
                            if ((king^.y - rook^.y) = (-1)) then
                            begin
                                userKingDirection := PushingLeft;
                            end;

                            chystanyPostupPocitace(rook, -1, 0,
                                 false, InitialPhase, 13);
                        end;
                    end;
                    12: begin

                        chystanyPostupPocitace(king, 1, 0,
                            true, InitialPhase, 13);

                        if (informace_o_tahu_pocitace = KingsNextToOther) then
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(KingsNextToOtherPhase, 2);
                    end;
                    13: begin
                        navrhniPosunFigurkyPocitace(king, 0);
                        navrhniPosunFigurkyPocitace(@nextIntendedPosition, 0);

                        if (not (IsValidSquare(@nextIntendedPosition))) then
                        begin
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(InitialPhase, 13);

                            userKingDirection :=
                                ForceDirection((Ord(userKingDirection) + 1) mod DirectionsCount);
                            soucasny_smer_pohybu := soucasny_smer_pohybu * (-1);
                        end else begin
                            navrhniPosunFigurkyPocitace(king, 1);
                            navrhniPosunFigurkyPocitace(@nextIntendedPosition, 2);

                            if (((rook^.x - king^.x) =
                                   (((nextIntendedPosition.x + 1) mod
                                   (CHESSBOARD_DIMENSION + 1)) - 1)) and
                               ((rook^.y - king^.y) =
                                   (((nextIntendedPosition.y + 1) mod
                                   (CHESSBOARD_DIMENSION + 1)) - 1)))
                            then vyvolana_vnitrni_zmena_stavu :=
                                     vyvolaniVyjimkyPriNahleSituaci(InitialPhase, 14)
                            else chystanyPostupPocitace(rook, 1, 0,
                                     false, InitialPhase, 12);
                        end;
                    end;
                    14: chystanyPostupPocitace(rook, 0, -2,
                            false, InitialPhase, 15);
                    15: chystanyPostupPocitace(rook, -2, 0,
                            false, StandardPhase, 1);
                end;
            end;

    {                  ETAPA c.1 - Standartni etapa                 }
    { V teto etape ma pocitac uz matnou predstavu, kde se nachazi   }
    { hracuv kral. Snazi se ho tedy "natlacit ke zdi". To dociluje  }
    { tim, ze pomoci svych figurek projde cely radek a pak se       }
    { posune o jeden vys, postupne tedy zatlaci krale ke zdi. Je to }
    { standartni pohyb pocitace. Pokud nastane neobvykla situace    }
    { (kralove vedle sebe, sach, naraz do zdi), vyvola se vyjimka,  }
    { ktera zpusobi zmenu etapy.                                    }

            StandardPhase: begin
                case vnitrni_AI_stav_pocitace of
                    1: begin
                        if (jeFigurkaTakBlizkoKraje(king, 4, 1)) then
                        begin
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(KingsNextToOtherPhase, 17);
                            nextIntendedPosition := king^;
                        end else
                            chystanyPostupPocitace(king, 1, 0,
                                 true, StandardPhase, 2);

                        navrhniPosunFigurkyPocitace(@nextIntendedPosition, 0);
                        if ((informace_o_tahu_pocitace <> ValidArrangement) or
                           (not (IsValidSquare(@nextIntendedPosition)))) then begin

                            if (informace_o_tahu_pocitace = KingsNextToOther) then begin
                                currentAIPhase := KingsNextToOtherPhase;
                                currentAIState := 1;
                                vyvolana_vnitrni_zmena_stavu := TRUE;
                            end;

                            if not(IsValidSquare(@nextIntendedPosition)) then begin
                                currentAIPhase := NearWallPhase;
                                currentAIState := 1;
                                vyvolana_vnitrni_zmena_stavu := TRUE;
                            end;

                            if (informace_o_tahu_pocitace = KingInCheck) then begin
                                currentAIPhase := KingInCheckPhaze;
                                currentAIState := 1;
                                vyvolana_vnitrni_zmena_stavu := TRUE;
                            end;

                            informace_o_tahu_pocitace := ValidArrangement;
                        end;
                        navrhniPosunFigurkyPocitace(@nextIntendedPosition, 2);
                    end;
                    2: begin
                        chystanyPostupPocitace(rook, 1, 0,
                            false, StandardPhase, 1);
                    end;
                end;
            end;

    {                  ETAPA c.2 - Blizkost kralu                   }
    { Tato etapa se vyvola, pokud se pocitac pokusi posunout sveho  }
    { krale vedle hracova krale (muze se vsak vyvolat v jinych      }
    { situacich). Ukolem teto etapy je v konecnem poctu tahu        }
    { posunout sve figurky alespon o policko dopredu, i kdyz jim    }
    { v tom hracuv kral vsemozne brani a nasledne se vratit do      }
    { standartni etapy.                                             }

            KingsNextToOtherPhase: begin
                case vnitrni_AI_stav_pocitace of
                    1: chystanyPostupPocitace(rook, 1, 0,
                           false, KingsNextToOtherPhase, 2);
                    2: begin
                        chystanyPostupPocitace(king, 1, 0,
                            true, StandardPhase, 1);

                        if (informace_o_tahu_pocitace = KingsNextToOther) then
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(KingsNextToOtherPhase, 3);
                    end;
                    3: begin
                        chystanyPostupPocitace(king, 1, -1,
                            true, KingsNextToOtherPhase, 7);

                        if (informace_o_tahu_pocitace = KingsNextToOther) then
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(KingsNextToOtherPhase, 4);
                    end;
                    4: chystanyPostupPocitace(rook, 1, 0,
                           false, KingsNextToOtherPhase, 5);
                    5: begin
                        chystanyPostupPocitace(king, 1, 0,
                            true, KingsNextToOtherPhase, 2);

                        if (informace_o_tahu_pocitace = KingsNextToOther) then
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(KingsNextToOtherPhase, 6);
                    end;
                    6: if (jeFigurkaTakBlizkoKraje(rook, -2, 9))
                       then chystanyPostupPocitace(rook, 0, 1,
                                false, KingInCheckPhaze, 5)
                       else chystanyPostupPocitace(rook, -2, 0,
                                false, StandardPhase, 1);
                    7: begin
                        chystanyPostupPocitace(king, 0, 1,
                            true, StandardPhase, 1);

                        navrhniPosunFigurkyPocitace(@nextIntendedPosition, 0);
                        if not(IsValidSquare(@nextIntendedPosition)) then begin
                            navrhniPosunFigurkyPocitace(@nextIntendedPosition, 2);
                            currentAIPhase := KingsNextToOtherPhase;
                            currentAIState := 2;
                            if (soucasny_smer_pohybu = 1) then
                                userKingDirection :=
                                ForceDirection((Ord(userKingDirection) + 1) mod DirectionsCount)
                            else
                                userKingDirection :=
                                ForceDirection((Ord(userKingDirection) - 1) mod DirectionsCount);
                            soucasny_smer_pohybu := soucasny_smer_pohybu * -1;
                            vyvolana_vnitrni_zmena_stavu := TRUE;
                        end;
                        navrhniPosunFigurkyPocitace(@nextIntendedPosition, 2);

                        if (informace_o_tahu_pocitace = KingsNextToOther) then
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(KingsNextToOtherPhase, 8);
                    end;
                    8: begin
                        chystanyPostupPocitace(king, -1, 1,
                            true, KingsNextToOtherPhase, 2);

                        if (informace_o_tahu_pocitace = KingsNextToOther) then
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(KingsNextToOtherPhase, 9);
                    end;
                    9: if (jeFigurkaTakBlizkoKraje(rook, 4, 3))
                       then chystanyPostupPocitace(king, 1, 0,
                                true, KingsNextToOtherPhase, 21)
                       else chystanyPostupPocitace(rook, 0, 1,
                                false, KingsNextToOtherPhase, 10);
                    10: begin
                        chystanyPostupPocitace(king, 0, 1,
                            true, KingsNextToOtherPhase, 7);

                        if (informace_o_tahu_pocitace = KingsNextToOther) then
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(KingsNextToOtherPhase, 11);
                    end;
                    11: if (jeFigurkaTakBlizkoKraje(rook, 3, 2))
                        then chystanyPostupPocitace(rook, 0, 1,
                                 // TODO: false, -1, -1)
                                 false, KingsNextToOtherPhase, 1)	// TODO: Tohle je jen na oko
                        else chystanyPostupPocitace(rook, 1, 0,
                                 false, KingsNextToOtherPhase, 12);
                    12: if (jeFigurkaTakBlizkoKraje(king, 2, 4)) then begin
                            chystanyPostupPocitace(king, 1, 0,
                                true, KingsNextToOtherPhase, 19);
                        end else begin
                            chystanyPostupPocitace(king, 1, 1,
                                true, KingsNextToOtherPhase, 7);

                            if (informace_o_tahu_pocitace = KingsNextToOther) then
                                vyvolana_vnitrni_zmena_stavu :=
                                    vyvolaniVyjimkyPriNahleSituaci(KingsNextToOtherPhase, 13);
                        end;
                    13: chystanyPostupPocitace(rook, 1, 0,
                            false, KingsNextToOtherPhase, 14);
                    14: chystanyPostupPocitace(king, 0, 1,
                            true, KingsNextToOtherPhase, 15);
                    15: chystanyPostupPocitace(king, 0, 1,
                            true, KingsNextToOtherPhase, 16);
                    16: chystanyPostupPocitace(rook, -2, 0,
                            false, StandardPhase, 1);
                    17: chystanyPostupPocitace(king, 0, -1,
                            true, KingsNextToOtherPhase, 18);
                    18: chystanyPostupPocitace(rook, 0, -1,
                            false, StandardPhase, 1);
                    19: chystanyPostupPocitace(rook, 0, -2,
                            false, KingsNextToOtherPhase, 20);
                    20: chystanyPostupPocitace(king, 0, -1,
                            true, KingsNextToOtherPhase, 7);
                    21: chystanyPostupPocitace(rook, 0, 2,
                            // TODO: false, -1, -1);
                            false, KingsNextToOtherPhase, 1);	// TODO: Tohle je jen na oko
                end;
            end;

    {                        ETAPA c.3 - Sach                       }
    { Pokud ve standartni etape da vez pocitace sach krali hrace,   }
    { potom se vyvola etapa. Ta se potom posune o jeden radek a     }
    { dojde do jeho konce radku v "nouzovem rezimu".                }

            KingInCheckPhaze: begin
                case vnitrni_AI_stav_pocitace of
                    1: begin
                        chystanyPostupPocitace(rook, 0, 1,
                            false, KingInCheckPhaze, 2);
                        nastal_pri_pohybu_posun_o_radek := TRUE;
                    end;
                    2: begin
                        chystanyPostupPocitace(king, 0, 1,
                                true, KingInCheckPhaze, 3);

                        if (informace_o_tahu_pocitace = KingsNextToOther) then
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(KingsNextToOtherPhase, 7);
                    end;
                    3: begin
                        chystanyPostupPocitace(rook, 1, 0,
                            false, KingInCheckPhaze, 4);

                        navrhniPosunFigurkyPocitace(@nextIntendedPosition, 0);
                        navrhniPosunFigurkyPocitace(@nextIntendedPosition, 0);
                        if ((informace_o_tahu_pocitace <> ValidArrangement) or
                           (not (IsValidSquare(@nextIntendedPosition)))) then begin

                            if not(IsValidSquare(@nextIntendedPosition)) then begin
                                currentAIPhase := NearWallPhase;
                                currentAIState := 1;
                                vyvolana_vnitrni_zmena_stavu := TRUE;
                            end;

                            if (informace_o_tahu_pocitace = KingInCheck) then begin
                                currentAIPhase := KingInCheckPhaze;
                                currentAIState := 1;
                                vyvolana_vnitrni_zmena_stavu := TRUE;
                            end;

                            informace_o_tahu_pocitace := ValidArrangement;
                        end;
                        navrhniPosunFigurkyPocitace(@nextIntendedPosition, 2);
                        navrhniPosunFigurkyPocitace(@nextIntendedPosition, 2);

                    end;
                    4: begin
                        chystanyPostupPocitace(king, 1, 0,
                            true, KingInCheckPhaze, 3);

                        if (informace_o_tahu_pocitace = KingsNextToOther) then begin
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(KingsNextToOtherPhase, 3);
                        end;
                    end;
                    5: chystanyPostupPocitace(king, 1, -1,
                           true, KingInCheckPhaze, 6);
                    6: chystanyPostupPocitace(rook, -1, 0,
                           false, KingInCheckPhaze, 7);
                    7: chystanyPostupPocitace(rook, 0, -2,
                           false, StandardPhase, 1);
                end;
            end;

    {                  ETAPA c.4 - Narazeni do zdi                  }
    { Etapa se vyvola, pokud figurky pocitace pri standartnim       }
    { pohybu po radku dojdou k jeho konci. Potom se bud zmeni smer  }
    { pohybu nebo se figurky posunou o jeden radek, pokud pri       }
    { prochazeni tohoto radku nebyla vyvolana etapa c.3.            }

            NearWallPhase: begin
                case vnitrni_AI_stav_pocitace of
                    1: begin
                        if (nastal_pri_pohybu_posun_o_radek = TRUE) then begin
                            chystanyPostupPocitace(rook, 2, 0,
                                false, StandardPhase, 1);
                            soucasny_smer_pohybu := soucasny_smer_pohybu * -1;
                            nastal_pri_pohybu_posun_o_radek := FALSE;
                        end else
                            chystanyPostupPocitace(king, 0, 1,
                                true, NearWallPhase, 2);

                        if (informace_o_tahu_pocitace = KingsNextToOther) then
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(NearWallPhase, 3);
                    end;
                    2: chystanyPostupPocitace(rook, 0, 1,
                           false, StandardPhase, 1);
                    3: begin
                        chystanyPostupPocitace(king, -1, 1,
                            true, NearWallPhase, 4);

                        if (informace_o_tahu_pocitace = KingsNextToOther) then
                            vyvolana_vnitrni_zmena_stavu :=
                                vyvolaniVyjimkyPriNahleSituaci(NearWallPhase, 6);
                    end;
                    4: chystanyPostupPocitace(rook, 0, 1,
                           false, NearWallPhase, 5);
                    5: chystanyPostupPocitace(rook, -1, 0,
                           false, StandardPhase, 1);
                    6: chystanyPostupPocitace(rook, 0, 1,
                           false, NearWallPhase, 7);
                    7: chystanyPostupPocitace(king, -1, 1,
                           true, NearWallPhase, 5);
                end;
            end;
        end;

        vnitrni_AI_etapa_pocitace := currentAIPhase;
        vnitrni_AI_stav_pocitace := currentAIState;

    until not vyvolana_vnitrni_zmena_stavu

end;
















{ Notify AI of violation which its next intended move may cause }
procedure ReportGameViolation(violation: GameViolation);
begin
	informace_o_tahu_pocitace := violation;

	if violation <> KingsNextToOther then
	begin
		currentAIState := intendedAIState;
		currentAIPhase := intendedAIPhase;
	end;
end;


{ TODO }
procedure ResetAI;
begin
	currentAIPhase := InitialPhase;
	currentAIState := Low(AIState);

	intendedAIPhase := currentAIPhase;
	intendedAIState := currentAIState;

	nextIntendedPosition.x := 0;
	nextIntendedPosition.y := 0;
	isKingIntendedToMove := false;

	soucasny_smer_pohybu := 1;


	informace_o_tahu_pocitace := ValidArrangement;
	userKingDirection := PushingUp;
	nastal_pri_pohybu_posun_o_radek := false;
end;


{ Get position where AI intends to move its king or rook }
function GetNextIntendedPosition: PSquare;
begin
	GetNextIntendedPosition := @nextIntendedPosition;
end;


{ Check whether AI intends to move with king (or with rook) }
function IsPieceIntendedToMoveKing: boolean;
begin
	IsPieceIntendedToMoveKing := isKingIntendedToMove;
end;


begin
	ResetAI;
end.


end.
