DECLARE FUNCTION getPieceSize$ (pieceAngle%, pieceShape$)
DECLARE FUNCTION drawPiece! (curPieceX%, curPieceY%, pieceColor%, pieceAngle%, piece$)
DECLARE FUNCTION drawBlock! (x%, y%, pieceColor%)

SCREEN 12
RANDOMIZE TIMER

' Playfield is 2-12 X, 1-17 Y

' Background
LINE (0, 0)-(640, 480), 8, BF


' Draw pretty background
FOR x% = 0 TO 31
        gc = drawPiece(x%, 2, 4, 1, "L")
        gc = drawPiece(x%, 5, 8, 1, "L")
        gc = drawPiece(x%, 8, 1, 1, "L")
NEXT x%

LOCATE 15, 50
PRINT "     QB Tetris     "
LOCATE 16, 50
PRINT " robert-lerner.com "
LOCATE 17, 50
PRINT "  Space = Rotate   "
LOCATE 18, 50
PRINT "      A = Left     "
LOCATE 19, 50
PRINT "      D = Right    "
LOCATE 20, 50
PRINT "    Esc = Exit     "
LOCATE 21, 50
PRINT "   (c)2017-"; RIGHT$(DATE$, 4); "    "

' Tile Area
LINE (39, 39)-(261, 441), 0, BF

' Tile Area Border
LINE (39, 39)-(261, 441), 4, B




currentPieceX% = 7
currentPieceY% = 2
currentPieceShape$ = "Z"
currentPieceAngle% = 1
currentPieceWidth% = 3 ' for z @ 1
currentPieceHeight% = 2 ' for z @ 1
currentPieceColor% = 2

DO
        DO
                ' The resolution of keystrokes should be greater than
                ' the resolution of block moves due to gravity,
                ' otherwise only a 45-degree angle is possible.
                ' Therefore, only every X loops will
                ' "gravity" have an effect

                loopCounter% = loopCounter% + 1
                IF (loopCounter% = 5) THEN
                        currentPieceY% = currentPieceY% + 1
                        loopCounter% = 0
                END IF

                ' Compare last/current piece and see if redraw makes sense.
                ' Cut 115 draws down to 10 over a piece's fall and removed flicker.
                IF (lastPieceX% <> currentPieceX% OR lastPieceY% <> currentPieceY% OR lastPieceAngle% <> currentPieceAngle% OR lastPieceShape% <> currentPieceShape%) THEN
                        ' Erase old piece
                        x = drawPiece(lastPieceX%, lastPieceY%, 0, lastPieceAngle%, lastPieceShape$)

                        ' Draw New Piece
                        x = drawPiece(currentPieceX%, currentPieceY%, currentPieceColor%, currentPieceAngle%, currentPieceShape$)


                        ' Draw look ahead (collision detection) grid. TODO: test code
                        FOR y = currentPieceY% TO 21
                                FOR x = 2 TO 12
                                        LINE ((x * 20) + 10, (y * 20) + 10)-((x * 20) + 10, (y * 20) + 10), 15
                                NEXT x
                        NEXT y

                END IF

                ' Track current as last piece
                lastPieceX% = currentPieceX%
                lastPieceY% = currentPieceY%
                lastPieceShape$ = currentPieceShape$
                lastPieceAngle% = currentPieceAngle%
        
                ' Capture keystrokes, may need tobe after delay to catch ring buffer
                keyPress$ = INKEY$
                FOR delay = 1 TO 1000
                NEXT delay

                ' TODO: Remove -- looping construct for testing collision and
                ' new piece generation
                IF (currentPieceY% + currentPieceHeight% > 21) THEN
                        currentPieceY% = 0

                        ' Clear out old piece location as we'll consider it
                        ' "parked" at the bottom of the playfield. Here is
                        ' where we'll use the piece bag or random shit to grab a new
                        ' piece
                        lastPieceX% = -5
                        lastPieceY% = -5

                        ' Start figuring out new piece
                        currentPieceColor% = INT(RND * 8) + 1
                        currentPieceAngle% = 1'INT(RND * 4) + 1
                        currentPieceX% = 7 'center of screen if it's 10 wide 2 offset
                        currentPieceY% = 2
                        newPieceShape% = INT(RND * 7) + 1

                        'testing locking colors to shapes for prettier playfield
                        currentPieceColor% = newPieceShape%

                        SELECT CASE newPieceShape%
                        CASE 1
                                currentPieceShape$ = "O"
                        CASE 2
                                currentPieceShape$ = "I"
                        CASE 3
                                currentPieceShape$ = "S"
                        CASE 4
                                currentPieceShape$ = "Z"
                        CASE 5
                                currentPieceShape$ = "L"
                        CASE 6
                                currentPieceShape$ = "J"
                        CASE 7
                                currentPieceShape$ = "T"
                        END SELECT

                        size$ = getPieceSize$(currentPieceAngle%, currentPieceShape$)
                        currentPieceWidth% = VAL(LEFT$(size$, 1))
                        currentPieceHeight% = VAL(RIGHT$(size$, 1))


                END IF


        LOOP WHILE (keyPress$ = "")

        ' --- Key Pressed, handle moves ---

        keyId% = ASC(UCASE$(keyPress$))

        IF (keyId% = 27) THEN
                ' End program with Escape
                SYSTEM
        ELSEIF (keyId% = 32) THEN
                ' Rotate Piece with Spacebar
                currentPieceAngle% = currentPieceAngle% + 1
                IF (currentPieceAngle% > 4) THEN currentPieceAngle% = 1
                
                ' Update piece size information w/ rotation
                size$ = getPieceSize$(currentPieceAngle%, currentPieceShape$)
                currentPieceWidth% = VAL(LEFT$(size$, 1))
                currentPieceHeight% = VAL(RIGHT$(size$, 1))
                'todo: if rotating puts it off screen on right, force over one
                IF (currentPieceX% + currentPieceWidth% > 12) THEN
                        currentPieceX% = 13 - currentPieceWidth%
                END IF

        ELSEIF (keyId% = 65 AND currentPieceX% > 2) THEN
                ' A = Move Left
                currentPieceX% = currentPieceX% - 1
        ELSEIF (keyId% = 68 AND currentPieceX% + currentPieceWidth% <= 12) THEN
                ' D = Move Right
                currentPieceX% = currentPieceX% + 1
        ELSEIF (keyId% = 83) THEN
                ' S = Move Down (not going to implement yet)
        END IF


'        LOCATE 1, 1
 '       PRINT "Key: "; keyId%

LOOP

FUNCTION drawBlock! (x%, y%, pieceColor%)
        pieceX% = x% * 20
        pieceY% = y% * 20

        ' Box
        LINE (pieceX%, pieceY%)-(pieceX% + 20, pieceY% + 20), pieceColor%, BF

        ' Turns off needless highlights / shadows, as we will use
        ' color 0 to blank out piece when they move down
        IF (pieceColor% > 0) THEN
                ' Highlight
                LINE (pieceX% + 3, pieceY% + 3)-(pieceX% + 3, pieceY% + 17), pieceColor% + 8
                LINE (pieceX% + 3, pieceY% + 3)-(pieceX% + 17, pieceY% + 3), pieceColor% + 8
                ' Shadow     
                LINE (pieceX% + 3, pieceY% + 17)-(pieceX% + 17, pieceY% + 17), 0
                LINE (pieceX% + 17, pieceY% + 17)-(pieceX% + 17, pieceY% + 3), 0
        END IF
        drawBlock! = 1
END FUNCTION

FUNCTION drawPiece (curPieceX%, curPieceY%, pieceColor%, pieceAngle%, piece$)

        IF (piece$ = "T") THEN
                IF (pieceAngle% = 1) THEN
                        x = drawBlock(curPieceX% + 1, curPieceY% + 1, pieceColor%)
                        x = drawBlock(curPieceX%, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX% + 1, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX% + 2, curPieceY%, pieceColor%)
                ELSEIF (pieceAngle% = 2) THEN
                        x = drawBlock(curPieceX%, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX%, curPieceY% + 1, pieceColor%)
                        x = drawBlock(curPieceX%, curPieceY% + 2, pieceColor%)
                        x = drawBlock(curPieceX% - 1, curPieceY% + 1, pieceColor%)
                ELSEIF (pieceAngle% = 3) THEN
                        x = drawBlock(curPieceX% + 1, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX%, curPieceY% + 1, pieceColor%)
                        x = drawBlock(curPieceX% + 1, curPieceY% + 1, pieceColor%)
                        x = drawBlock(curPieceX% + 2, curPieceY% + 1, pieceColor%)
                ELSEIF (pieceAngle% = 4) THEN
                        x = drawBlock(curPieceX%, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX%, curPieceY% + 1, pieceColor%)
                        x = drawBlock(curPieceX%, curPieceY% + 2, pieceColor%)
                        x = drawBlock(curPieceX% + 1, curPieceY% + 1, pieceColor%)
                END IF
        ELSEIF (piece$ = "O") THEN
                x = drawBlock(curPieceX%, curPieceY%, pieceColor%)
                x = drawBlock(curPieceX% + 1, curPieceY%, pieceColor%)
                x = drawBlock(curPieceX%, curPieceY% + 1, pieceColor%)
                x = drawBlock(curPieceX% + 1, curPieceY% + 1, pieceColor%)
        ELSEIF (piece$ = "I") THEN

                IF (pieceAngle% = 1 OR pieceAngle% = 3) THEN
                        x = drawBlock(curPieceX%, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX%, curPieceY% + 1, pieceColor%)
                        x = drawBlock(curPieceX%, curPieceY% + 2, pieceColor%)
                        x = drawBlock(curPieceX%, curPieceY% + 3, pieceColor%)
                ELSE
                        x = drawBlock(curPieceX%, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX% + 1, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX% + 2, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX% + 3, curPieceY%, pieceColor%)
                END IF
        ELSEIF (piece$ = "J") THEN
                IF (pieceAngle% = 1) THEN
                        x = drawBlock(curPieceX% + 1, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX% + 1, curPieceY% + 1, pieceColor%)
                        x = drawBlock(curPieceX%, curPieceY% + 2, pieceColor%)
                        x = drawBlock(curPieceX% + 1, curPieceY% + 2, pieceColor%)
                ELSEIF (pieceAngle% = 2) THEN
                        x = drawBlock(curPieceX%, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX%, curPieceY% + 1, pieceColor%)
                        x = drawBlock(curPieceX% + 1, curPieceY% + 1, pieceColor%)
                        x = drawBlock(curPieceX% + 2, curPieceY% + 1, pieceColor%)
                ELSEIF (pieceAngle% = 3) THEN
                        x = drawBlock(curPieceX%, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX% + 1, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX%, curPieceY% + 1, pieceColor%)
                        x = drawBlock(curPieceX%, curPieceY% + 2, pieceColor%)
                ELSEIF (pieceAngle% = 4) THEN
                        x = drawBlock(curPieceX%, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX% + 1, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX% + 2, curPieceY%, pieceColor%)
                        x = drawBlock(curPieceX% + 2, curPieceY% + 1, pieceColor%)
                END IF
        ELSEIF (piece$ = "L") THEN
                IF (pieceAngle% = 1) THEN
                     x = drawBlock(curPieceX%, curPieceY%, pieceColor%)
                     x = drawBlock(curPieceX%, curPieceY% + 1, pieceColor%)
                     x = drawBlock(curPieceX%, curPieceY% + 2, pieceColor%)
                     x = drawBlock(curPieceX% + 1, curPieceY% + 2, pieceColor%)
                ELSEIF (pieceAngle% = 2) THEN
                     x = drawBlock(curPieceX%, curPieceY%, pieceColor%)
                     x = drawBlock(curPieceX% + 1, curPieceY%, pieceColor%)
                     x = drawBlock(curPieceX% + 2, curPieceY%, pieceColor%)
                     x = drawBlock(curPieceX%, curPieceY% + 1, pieceColor%)
                ELSEIF (pieceAngle% = 3) THEN
                     x = drawBlock(curPieceX%, curPieceY%, pieceColor%)
                     x = drawBlock(curPieceX% + 1, curPieceY%, pieceColor%)
                     x = drawBlock(curPieceX% + 1, curPieceY% + 1, pieceColor%)
                     x = drawBlock(curPieceX% + 1, curPieceY% + 2, pieceColor%)
                ELSEIF (pieceAngle% = 4) THEN
                     x = drawBlock(curPieceX% + 2, curPieceY%, pieceColor%)
                     x = drawBlock(curPieceX%, curPieceY% + 1, pieceColor%)
                     x = drawBlock(curPieceX% + 1, curPieceY% + 1, pieceColor%)
                     x = drawBlock(curPieceX% + 2, curPieceY% + 1, pieceColor%)
                END IF
        ELSEIF (piece$ = "S") THEN
                IF (pieceAngle% = 1 OR pieceAngle% = 3) THEN
                    x = drawBlock(curPieceX% + 1, curPieceY%, pieceColor%)
                    x = drawBlock(curPieceX% + 2, curPieceY%, pieceColor%)
                    x = drawBlock(curPieceX%, curPieceY% + 1, pieceColor%)
                    x = drawBlock(curPieceX% + 1, curPieceY% + 1, pieceColor%)
                ELSE
                    x = drawBlock(curPieceX%, curPieceY%, pieceColor%)
                    x = drawBlock(curPieceX%, curPieceY% + 1, pieceColor%)
                    x = drawBlock(curPieceX% + 1, curPieceY% + 1, pieceColor%)
                    x = drawBlock(curPieceX% + 1, curPieceY% + 2, pieceColor%)
                END IF
        ELSEIF (piece$ = "Z") THEN
                IF (pieceAngle% = 1 OR pieceAngle% = 3) THEN
                    x = drawBlock(curPieceX%, curPieceY%, pieceColor%)
                    x = drawBlock(curPieceX% + 1, curPieceY%, pieceColor%)
                    x = drawBlock(curPieceX% + 1, curPieceY% + 1, pieceColor%)
                    x = drawBlock(curPieceX% + 2, curPieceY% + 1, pieceColor%)
                ELSE
                    x = drawBlock(curPieceX% + 1, curPieceY%, pieceColor%)
                    x = drawBlock(curPieceX% + 1, curPieceY% + 1, pieceColor%)
                    x = drawBlock(curPieceX%, curPieceY% + 1, pieceColor%)
                    x = drawBlock(curPieceX%, curPieceY% + 2, pieceColor%)
                END IF
        END IF
END FUNCTION

FUNCTION getPieceSize$ (pieceAngle%, pieceShape$)
        'returns a string, x=3 y=4 then retval is "34"

        IF (pieceShape$ = "O") THEN
                pieceSize$ = "22"
        ELSEIF (pieceShape$ = "I") THEN
                pieceSize$ = "14" '1 wide, 4 tall in angle 1
        ELSEIF (pieceShape$ = "S" OR pieceShape$ = "Z" OR pieceShape$ = "T") THEN
                pieceSize$ = "32"
        ELSEIF (pieceShape$ = "L" OR pieceShape$ = "J") THEN
                pieceSize$ = "23"
        END IF

        IF (pieceAngle% = 2 OR pieceAngle% = 4) THEN
                'Simply swap size params from default position
                swap$ = LEFT$(pieceSize$, 1)
                pieceSize$ = RIGHT$(pieceSize$, 1) + swap$
        END IF

        getPieceSize$ = pieceSize$

END FUNCTION

