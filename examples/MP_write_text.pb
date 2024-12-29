;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP3D OpenGL Engine
;// File Title: MP_write_text.pb
;// Created On: 25.1.2022
;// Updated On: 05.04.2023
;// Author: Michael Paulwitz
;// Version: 1.01
;//
;// write text
;// schreibe Text
;//
;////////////////////////////////////////////////////////////////

CompilerIf Not Subsystem("OpenGL") ; If you use Tailbite to create a lib in the opengl Subsystem folder you dont need the pb file 
  XIncludeFile "..\lib\MP3D_OpenGL_Library.pb"
CompilerEndIf

;- program start

MP_Graphics3D (640,480,0,2)

;camera=MP_CreateCamera()

light=MP_CreateLight(1)

Font0 = LoadFont(#PB_Any, "Arial", 25)

d.f = 0

While Not MP_KeyDown(#PB_Key_Escape) 
  
    Repeat ; get all WindowEvents to empty the event buffer; without this the programm 
       Event = WindowEvent()    ; Animation
       Select Event   
          Case #PB_Event_CloseWindow
          End
       EndSelect 
    Until Event=0
  
    MP_ScaleText(150, 100 )
    
    MP_DrawText (320, 240, "my first text with red color", Font0, RGBA(255, 0, 0,d), -d ) ; write on position x,y, Fontcolor = MP_ARGB(a,r,g,b), a text with angle rotation
    
    MP_ScaleText(100, 100 )
    
    MP_DrawText (10, 50, "my second text with green color", 0, RGBA(0, 255,0,155), 0 ) ; write on position x,y, Fontcolor = MP_ARGB(a,r,g,b), a text with angle rotation
    MP_DrawText (50, 90, "my third text with blue color", Font0, RGBA(0, 0,255,255), d ) ; write on position x,y, Fontcolor = MP_ARGB(a,r,g,b), a text with angle rotation
    
    d + 0.1
    
    MP_RenderWorld ()
    MP_Flip ()

Wend


; IDE Options = PureBasic 6.20 Beta 2 (Windows - x64)
; CursorPosition = 29
; EnableAsm
; EnableXP