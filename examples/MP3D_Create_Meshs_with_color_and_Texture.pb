
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP3D_Create_Meshs_with_color_and_Texture.pb
;// Created On: 25.1.2022
;// Updated On: 05.04.2023
;// Author: Michael Paulwitz
;//
;// Create meshs with color and texture
;// Erzeuge Mesh mit Farben und Texturen
;//
;////////////////////////////////////////////////////////////////

CompilerIf Not Subsystem("OpenGL") ; If you use Tailbite to create a lib in the opengl Subsystem folder you dont need the pb file 
  XIncludeFile "..\lib\MP3D_OpenGL_Library.pb"
CompilerEndIf

;- program start

Titel.s = "MP3D_Create_Meshs_with_color_and_Texture"
MP_Graphics3D (640,480,0,3) ; Create a Windows with 3D Funktion #Window = 0
SetWindowTitle(0, Titel)    ; Name of Windows

Texture = MP_LoadTexture(#PB_Compiler_Home + "examples/3d/Data/Textures/Geebee2.bmp")

NewList Mymesh.i() ; Here comes my Mesh

For m=0 To 1
  
  AddElement(Mymesh())
  Mymesh() = MP_CreateCube()
  x.f = Random(100,0)/20  -2.5
  y.f = Random(100,0)/20  -2.5
  z.f = -6-Random(100,0)/40
  MP_PositionEntity ( Mymesh(),x,y,z) ; position of cube
  MP_RotateEntity( Mymesh(),Random(90,0),Random(90,0),Random(90,0))
  If Random(1)
   MP_EntitySetTexture (Mymesh(), Texture)
  Else
    MP_EntitySetColor (Mymesh(),RGBA(Random(120),Random(120),Random(120),0))
  EndIf

  
  AddElement(Mymesh())
  Mymesh() = MP_CreateRectangle(Random(4,1)/4,Random(4,1)/4,Random(4,1)/4)
  x.f = Random(100,0)/20  -2.5
  y.f = Random(100,0)/20  -2.5
    z.f = -6-Random(100,0)/40
  MP_PositionEntity ( Mymesh(),x,y,z) ; position of Rectangle
  MP_RotateEntity( Mymesh(),Random(90,0),Random(90,0),Random(90,0))
  If Random(1)
   MP_EntitySetTexture (Mymesh(), Texture)
  Else
    MP_EntitySetColor (Mymesh(),RGBA(Random(120),Random(120),Random(120),0))
  EndIf

  
  AddElement(Mymesh())
  Mymesh() = MP_CreatePyramid (2, 1, 2) 
  x.f = Random(100,0)/20  -2.5
  y.f = Random(100,0)/20  -2.5
  z.f = -6-Random(100,0)/40
  MP_PositionEntity ( Mymesh(),x,y,z) ; Position of Pyramid
  MP_RotateEntity( Mymesh(),Random(90,0),Random(90,0),Random(90,0))
  If Random(1)
   MP_EntitySetTexture (Mymesh(), Texture)
  Else
    MP_EntitySetColor (Mymesh(),RGBA(Random(120),Random(120),Random(120),0))
  EndIf

  AddElement(Mymesh())
  Mymesh() =MP_CreateSphere (10) 
  x.f = Random(100,0)/20  -2.5
  y.f = Random(100,0)/20  -2.5
  z.f = -6-Random(100,0)/40
  MP_PositionEntity ( Mymesh(),x,y,z) ; Position of Pyramid
  MP_RotateEntity( Mymesh(),Random(90,0),Random(90,0),Random(90,0))
  If Random(1)
   MP_EntitySetTexture (Mymesh(), Texture)
  Else
    MP_EntitySetColor (Mymesh(),RGBA(Random(120),Random(120),Random(120),0))
  EndIf
 
  AddElement(Mymesh())
  Mymesh() =MP_CreateCylinder (1,2) 
  x.f = Random(100,0)/20  -2.5
  y.f = Random(100,0)/20  -2.5
  z.f = -6-Random(100,0)/40
  MP_PositionEntity ( Mymesh(),x,y,z) ; Position of Pyramid
  MP_RotateEntity( Mymesh(),Random(90,0),Random(90,0),Random(90,0))
  If Random(1)
   MP_EntitySetTexture (Mymesh(), Texture)
  Else
    MP_EntitySetColor (Mymesh(),RGBA(Random(120),Random(120),Random(120),0))
  EndIf

  AddElement(Mymesh())
  Mymesh() =MP_CreateOpenCylinder (1,2) 
  x.f = Random(100,0)/20  -2.5
  y.f = Random(100,0)/20  -2.5
  z.f = -6-Random(100,0)/40
  MP_PositionEntity ( Mymesh(),x,y,z) ; Position of Pyramid
  MP_RotateEntity( Mymesh(),Random(90,0),Random(90,0),Random(90,0))
  If Random(1)
   MP_EntitySetTexture (Mymesh(), Texture)
  Else
    MP_EntitySetColor (Mymesh(),RGBA(Random(120),Random(120),Random(120),0))
  EndIf

Next m  

light1 = MP_CreateLight(a)
MP_PositionEntity (light1,-3,0,0)

MP_AmbientSetLight (RGBA(0,12,66,0))

While Not MP_KeyDown(#PB_Key_Escape)
  
    MP_Windows_Fps(Titel)
    
    Repeat ; get all WindowEvents to empty the event buffer; without this the programme does not respond correctly to windows events
       Event = WindowEvent()    ; Animation
       Select Event   
          Case #PB_Event_CloseWindow
          End
       EndSelect 
    Until Event=0
    
    ForEach Mymesh()
      MP_TurnEntity (Mymesh(),0,1,1) ; dreh den Würfel
    Next

    MP_RenderWorld() ; Create the World
    MP_Flip () ; Flip and Time

Wend

; IDE Options = PureBasic 6.20 Beta 2 (Windows - x64)
; CursorPosition = 29
; EnableAsm
; EnableXP