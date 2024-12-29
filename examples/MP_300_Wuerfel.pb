;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_300_Wuerfel.pb
;// Created On: 25.1.2022
;// Updated On: 05.04.2023
;// Author: Michael Paulwitz
;//
;// Create 300 cubes
;// Erzeuge 300 Würfel
;//
;////////////////////////////////////////////////////////////////

CompilerIf Not Subsystem("OpenGL") ; If you use Tailbite to create a lib in the opengl Subsystem folder you dont need the pb file 
  XIncludeFile "..\lib\MP3D_OpenGL_Library.pb"
CompilerEndIf

;- program start

MP_Graphics3D (640,480,0,2)

;camera=MP_CreateCamera()

light=MP_CreateLight(1)

#Max = 100
Dim wuerfel(#Max) 
Dim x(#Max)
Dim y(#Max)
Dim z(#Max)


For n = 0 To #Max

    wuerfel (n) = MP_CreateCube()

    MP_EntitySetColor (wuerfel (n),RGBA(Random(120),Random(120),Random(120),Random(120)))

    MP_PositionEntity (wuerfel(n),10-Random(20),10-Random(20),10+Random(40)-60)
    
    x(n) = Random (20)/10
    y(n) = Random (20)/10
    z(n) = Random (20)/10
    
 ;   MP_MeshSetAlpha (wuerfel(n),1)
 ;   MP_MeshSetAlpha (wuerfel(n),2)
    
        
Next n

While Not MP_KeyDown(#PB_Key_Escape) 
  
    Repeat ; get all WindowEvents to empty the event buffer; without this the programm 
       Event = WindowEvent()    ; Animation
       Select Event   
          Case #PB_Event_CloseWindow
          End
       EndSelect 
    Until Event=0
  
  
  MP_Windows_Fps("")
  
    For n = 0 To #Max
       MP_TurnEntity (wuerfel (n),x(n),y(n),z(n))
    Next n
    
        If MP_KeyDown(#PB_Key_1) : mp_Vsync(0) : EndIf
    If MP_KeyDown(#PB_Key_2) : mp_Vsync(1) : EndIf
    
;    MP_MeshAlphaSort()

    MP_RenderWorld ()
    MP_Flip ()

Wend


; IDE Options = PureBasic 6.20 Beta 2 (Windows - x64)
; CursorPosition = 38
; EnableXP
; DPIAware
; EnableCustomSubSystem
; Manual Parameter S=DX9