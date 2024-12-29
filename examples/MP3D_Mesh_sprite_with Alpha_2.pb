;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP3D OpenGL Engine
;// File Title: MP3D_Mesh_sprite_with Alpha_2.pb
;// Created On: 25.1.2022
;// Updated On: 05.04.2023
;// Author: Michael Paulwitz
;// Version: 1.01
;//
;// create mesh and sprite with alpha channel
;// erzeuge einen mesh und Sprite mit alpha Kanal
;//
;////////////////////////////////////////////////////////////////

CompilerIf Not Subsystem("OpenGL") ; If you use Tailbite to create a lib in the opengl Subsystem folder you dont need the pb file 
  XIncludeFile "..\lib\MP3D_OpenGL_Library.pb"
CompilerEndIf

;- program start

Titel.s = "Print of a Cube and Sprite with Alphamode"
MP_Graphics3D (640,480,0,3) ; Create a Windows with 3D Funktion #Window = 0
SetWindowTitle(0, Titel)    ; Name of Windows

Light = MP_CreateLight(0)

NewList Mymesh.i()



;Texture1 = MP_LoadTexture("Image1.bmp")
Texture1 = MP_LoadTexture(#PB_Compiler_Home + "examples/3d/Data/Textures/Geebee2.bmp")
Texture2 = MP_LoadTexture(#PB_Compiler_Home + "examples/3d/Data/Textures/Grass1.png")
Texture3 = MP_LoadTexture(#PB_Compiler_Home + "examples/3d/Data/Textures/Caisse.png")

Sprite = MP_LoadSprite(#PB_Compiler_Home + "examples/3d/Data/Textures/Grass1.png")
;Sprite = MP_LoadSprite(#PB_Compiler_Home + "examples/3d/Data/Textures/Grass1.png")

For m = 0 To 3
  
  AddElement(Mymesh())

  Mymesh() = MP_CreateCube()
  x.f = Random(100,0)/20  -2.5
  y.f = Random(100,0)/20  -2.5
  
  MP_PositionEntity ( Mymesh(),x,y,-6-Random(100,0)/40) ; Position des W rfels
  MP_TurnEntity ( Mymesh(),Random(90,0),Random(90,0),Random(90,0))
  
  If m =  0 Or m = 1
    MP_MeshSetAlpha (Mymesh(), 1)
    MP_EntitySetTexture (Mymesh(),Texture1)
  EndIf  
  If m = 2 Or m = 3
    MP_MeshSetAlpha (Mymesh(), 2) 
    MP_EntitySetTexture (Mymesh(),Texture3)
  EndIf  
  
Next m  

MP_AmbientSetLight (RGBA(0,55,65,0))


MP_TexturSetAlphaColor (Texture1, $FF00FF)
;MP_VSync(0)

While Not MP_KeyDown(#PB_Key_Escape) 
    
    SetWindowTitle(0, Titel+" - FPS: "+Str(MP_FPS ())+"    ") ; name of Windows
    
    Repeat ; get all WindowEvents to empty the event buffer; without this the programme does not respond correctly to windows events
       Event = WindowEvent()    ; Animation
       Select Event   
          Case #PB_Event_CloseWindow
          End
       EndSelect 
    Until Event=0
    
    If MP_KeyDown(#PB_Key_W)
      If wireFrame=0
      MP_Wireframe (1)
      wireFrame ! 1
         ElseIf wireFrame=1
           MP_Wireframe (0)
           wireFrame ! 1
      EndIf  
    EndIf  
    
    ForEach Mymesh()
      MP_TurnEntity (Mymesh(),0,1,1) ; Turn the cube
    Next
    
    a.f + 1
    MP_SpriteSetAlpha (Sprite, 1)
    MP_ScaleSprite(Sprite, 100, 100 )
    ;MP_TurnSprite(Sprite, 1)
    MP_RotateSprite(Sprite,  a)
    MP_DrawSprite (Sprite, 400, 200)
   
    MP_SpriteSetAlpha (Sprite, 2)
    MP_ScaleSprite(Sprite, 50, 200 )
    MP_RotateSprite(Sprite, -a)
    MP_DrawSprite (Sprite, 200, 200 )
    
    
    MP_RenderWorld() ; Create the World
    MP_Flip () ; Show all

Wend


; IDE Options = PureBasic 6.20 Beta 2 (Windows - x64)
; CursorPosition = 29
; EnableAsm
; EnableXP