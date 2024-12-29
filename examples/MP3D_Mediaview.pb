
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP3D_Mediaview.pb
;// Created On: 25.1.2022
;// Updated On: 05.04.2023
;// Author: Michael Paulwitz
;//
;// first test try to create a media view
;// versuch ein mediaview programm zu erzeugen
;//
;////////////////////////////////////////////////////////////////

CompilerIf Not Subsystem("OpenGL") ; If you use Tailbite to create a lib in the opengl Subsystem folder you dont need the pb file 
  XIncludeFile "..\lib\MP3D_OpenGL_Library.pb"
CompilerEndIf

;- program start

MP_Graphics3D (640,480,0,3)
SetWindowTitle(0, "MediaView, Return load Mesh, Space load Textur, Cursor,a,y/z Bewegt den Mesh") ; Setzt einen Fensternamen

;camera=MP_CreateCamera()
light=MP_CreateLight(1)
MP_PositionEntity (light,-3,0,0)

n=CountProgramParameters() 

For i=1 To n 
  File.s + " " + ProgramParameter() ; Get filename with space too, example = "c:\my space\test.3ds" 
  File = LTrim (File)
Next 


If n = 0  ; test ,odel if no ProgramParameter () activ
  ;File.s = "..\assets\models\Suzanne.x"
  ;File.s = "..\assets\models\cube.x"
  ;File.s = "..\assets\models\wispwind.x"
  ;File.s = "..\assets\models\rabbit.x"
  ;File.s = "..\assets\models\usb.stl"
  ;File.s = "..\assets\models\Sphericon.stl"
  File.s = "..\assets\models\2 sternchen.x"
EndIf  



If File.s

  SetWindowTitle(0, File.s) 
   
  mesh = MP_LoadMesh (File.s)
  max.f = MP_MeshGetHeight(mesh) ; find Maximum of Mesh
             
  If MP_MeshGetWidth(mesh) > max
     max = MP_MeshGetWidth(mesh) 
  EndIf

  If MP_MeshGetDepth(mesh) > max
    max = MP_MeshGetDepth(mesh) 
  EndIf
  
  If max 
        scale.f = 2 / max ; 
  EndIf      
  
  MP_ScaleEntity (mesh,scale,scale,scale) ; Auf Bildschirm maximieren / maximum to Screen
  ;x.f=0 : y.f=0 : z.f=4 ; Mesh Koordinaten 
  x.f=0 : y.f=0 : z.f=-6 ; Mesh Koordinaten 
EndIf

While Not MP_KeyDown(#PB_Key_Escape) 
  
    Repeat ; get all WindowEvents to empty the event buffer; without this the programme does not respond correctly to windows events
       Event = WindowEvent()    ; Animation
       Select Event   
          Case #PB_Event_CloseWindow
          End
       EndSelect 
    Until Event=0
  
  If MP_KeyDown(#PB_Key_Left) : x=x-1 : EndIf 
  If MP_KeyDown(#PB_Key_Right) : x=x+1 :EndIf
  If MP_KeyDown(#PB_Key_Down) : y=y-1 : EndIf
  If MP_KeyDown(#PB_Key_Up) : y=y+1 :  EndIf 
  If MP_KeyDown(#PB_Key_Z)  : z=z+1 :  EndIf ;y ist mit z getauscht
  If MP_KeyDown(#PB_Key_A)  : z=z-1 :  EndIf 

  If MP_KeyDown(#PB_Key_Return)

    Pattern$ = "3D Mesh files|*.x;*.3ds;*.b3d|.x Dateien (*.x)|*.x|3DS Dateien (*.3ds)|*.3ds|B3D Dateien (*.b3d)|*.b3d"
    directory$ = "C:\Programme\PureBasic\media\"
    File.s = OpenFileRequester("Choose entity", directory$, Pattern$, 0)
    If File.s

      
      MP_FreeEntity (mesh) 
      mesh = MP_LoadMesh (File.s)
      max.f = MP_MeshGetHeight(mesh) ; find Maximum of Mesh
             
      If MP_MeshGetWidth(mesh) > max
        max = MP_MeshGetWidth(mesh) 
      EndIf

      If MP_MeshGetDepth(mesh) > max
        max = MP_MeshGetDepth(mesh) 
      EndIf

      If max : scale.f = 3 / max : EndIf
      MP_ScaleEntity (mesh,scale,scale,scale) ; Auf Bildschirm maximieren / maximum to Screen
      x.f=0 : y.f=0 : z.f=-6 ; Mesh Koordinaten 
      
      
     
    EndIf
  EndIf ;#Space

 ; MP_DrawText (2,2,"Triangles: "+Str(MP_CountTriangles(Mesh))+"  Vertices: "+Str(MP_CountVertices(Mesh))) ; comming soon

  MP_PositionEntity (mesh,0,0,z)
  MP_RotateEntity (mesh,x,0,y)

  MP_RenderWorld()

    MP_Flip ()

Wend

; IDE Options = PureBasic 6.20 Beta 2 (Windows - x64)
; CursorPosition = 35
; FirstLine = 24
; EnableAsm
; EnableXP
; Compiler = PureBasic 6.01 LTS - C Backend (Windows - x64)