;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP3D OpenGL Engine
;// File Title: MP3D_VsyncOn_Off.pb
;// Created On: 25.1.2022
;// Updated On: 05.04.2023
;// Author: Michael Paulwitz
;// Version: 1.01
;//
;// activate Vsync
;// Aktiviere Vsync
;//
;////////////////////////////////////////////////////////////////


CompilerIf Not Subsystem("OpenGL") ; If you use Tailbite to create a lib in the opengl Subsystem folder you dont need the pb file 
  XIncludeFile "..\lib\MP3D_OpenGL_Library.pb"
CompilerEndIf

;- program start

Titel.s = "VSync on/off, Key 1 for Vsync off, Key 2 Vsync on"
MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, Titel) ; Setzt einen Fensternamen

Light = MP_CreateLight(0)

Mymesh = MP_Createcube ()
;Mymesh = MP_CreateMesh ()
x.f = Random(100,0)/20  -2.5
y.f = Random(100,0)/20  -2.5
 
MP_PositionEntity ( Mymesh,x,y,-6-Random(100,0)/40) ; Position des Würfels
MP_TurnEntity ( Mymesh,Random(90,0),Random(90,0),Random(90,0))

While Not MP_KeyDown(#PB_Key_Escape)
  
    Repeat ; get all WindowEvents to empty the event buffer; without this the programme does not respond correctly to windows events
       Event = WindowEvent()    ; Animation
       Select Event   
          Case #PB_Event_CloseWindow
          End
       EndSelect 
    Until Event=0
  
    MP_Windows_Fps(Titel)
    MP_TurnEntity (Mymesh,0,1,1) ; dreh den Würfel
    MP_MoveEntity (Mymesh,0,0.003,0.003)
    
    If MP_KeyDown(#PB_Key_1) : mp_Vsync(0) : EndIf
    If MP_KeyDown(#PB_Key_2) : mp_Vsync(1) : EndIf

    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend


; IDE Options = PureBasic 6.20 Beta 2 (Windows - x64)
; CursorPosition = 29
; EnableAsm
; EnableXP