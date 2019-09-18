# Basic checkmate: King and rook (blind AI) vs. king (user)

Chess endgame simulator of king and rook (AI) vs. king (user) where AI does not know position of the user king.

## Summary

The program simulates chess endgame where computer put into checkmate a user in finite number of steps. This is the basic variant of checkmate where user's king faces the computer with king and rook. In order to make the problem more complicated, the computer does not know the position of the opponent's king, it may receive only these messages: Check, checkmate or inaccessible square.

## Features

 * AI that always beats player (with exception, see Known Issues)
 * Randomly generated chessboard
 * Simple text GUI with history of every move
 * Syntax compliant with all main dialects: Free/Turbo Pascal, Object Pascal and (Borland) Delphi
 * No advance programming techniques like OOP, exceptions or reflection, only plain Pascal syntax
 * The program that does not use heap allocation

## Requirements

Any compiler able to parse supported Pascal dialect. There is provided a configuration file of Free Pascal compiler and Lazarus project file.

## Installation

To compile source code with Free Pascal Compiler, execute

```
fpc [-dRELEASE] Checkmate.pas
```

for Release version and

```
fpc -dDEBUG Checkmate.pas
```

for Debug version. To compile Lazarus project file use lazbuild tool:

```
lazbuild Checkmate.lpi
```

The debug version needs to be compiled with additional flag:

```
lazbuild --build-mode="Debug" Checkmate.lpi
```

## Documentation

The program is controlled by keyboard. See ```Usage``` at start of the application.

## Known Issues

The AI may fail to beat user at the very beginning of the game, where new chessboard is randomly generated. The user king may be everywhere and after the first move the rook of computer may not be protected by king.

## License

This project is licensed under the terms of the BSD 3-clause "New" (or "Revised") license. See the [LICENSE](LICENSE) file for more details.
