;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP3D OpenGL Engine
;// File Title: MP3D_Meshs_with_Addvertex.pb
;// Created On: 25.1.2022
;// Updated On: 05.04.2023
;// Author: Michael Paulwitz
;// Version: 1.01
;//
;// create a mesh with addvertex
;// erzeuge einen Mesh mit addvertex
;//
;////////////////////////////////////////////////////////////////

CompilerIf Not Subsystem("OpenGL") ; If you use Tailbite to create a lib in the opengl Subsystem folder you dont need the pb file 
  XIncludeFile "..\lib\MP3D_OpenGL_Library.pb"
CompilerEndIf

;- program start

Titel.s = "Test how to create a mesh"
MP_Graphics3D (640,480,0,3)  ; Create a Windows with 3D Funktion #Window = 0
SetWindowTitle(0, Titel) ; Name of Windows

Light = MP_CreateLight(0)

Mymesh = MP_CreateMesh ()

MP_AddVertex ( Mymesh ,0,1,0,0,0,$FF00)
MP_AddVertex ( Mymesh ,1,1,0,0,0,$FF)
MP_AddVertex ( Mymesh ,0,0,0,0,0,$FF0000)

MP_AddVertex ( Mymesh ,0,1,0,0,0,$FF00)
MP_AddVertex ( Mymesh ,1,1,0,0,0,$FF)
MP_AddVertex ( Mymesh ,1,2,0,0,0,$FF0000)

x.f = Random(100,0)/20  -2.5
y.f = Random(100,0)/20  -2.5
 
MP_PositionEntity ( Mymesh,x,y,-6-Random(100,0)/40) ; Position des W rfels
MP_TurnEntity ( Mymesh,Random(90,0),Random(90,0),Random(90,0))

While Not MP_KeyDown(#PB_Key_Escape) ;And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
    Repeat ; get all WindowEvents to empty the event buffer; without this the programme does not respond correctly to windows events
       Event = WindowEvent()    ; Animation
       Select Event   
          Case #PB_Event_CloseWindow
          End
       EndSelect 
    Until Event=0 
  
    MP_Windows_Fps(Titel)
    MP_TurnEntity (Mymesh,0,1,1) ; dreh den W rfel
    
    If MP_KeyDown(#PB_Key_1) : mp_Vsync(0) : EndIf
    If MP_KeyDown(#PB_Key_2) : mp_Vsync(1) : EndIf
    
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend


; IDE Options = PureBasic 6.20 Beta 2 (Windows - x64)
; CursorPosition = 29
; EnableAsm
; EnableXP