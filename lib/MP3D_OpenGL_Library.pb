;///////////////////////////////////////////////////////////////
;//
;// Project Title: MP3D_OpenGL_Libray for PureBasic
;// Created On: 11.12.2021
;// Updated On: 
;// Author: 3D Engine Michael Paulwitz
;//
;// 1458 Lines
;//
;// Version - 0.00.08 - MP3D feasibility study
;// tested with PB 5.73 for WIN10 x86/x64, Ubuntu 20.04.4/X64 and macOS Catalina 10.15.5/X64 
;//
;// CoAuthor; Your place for the future :)
;//
;// Changes: Add Rectangle, Pyramid, Sphere, Cylinder and Open Cylinder, Textur, Hide Entity, Color functions, 5 times faster, 
;// AddVertex, Move, Normalize Load x And Load stl funktion, Add Alpha and Blendmode, First sprites added
;//
;////////////////////////////////////////////////////////////////

EnableExplicit

;- Import functions

CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  
  ImportC "-lGL"
  ;ImportC "/usr/lib/x86_64-linux-gnu/libGL.so"
    glXGetProcAddress(name.i)
  EndImport

CompilerEndIf

;- Constantes

;#Create_ASCII_Dll   = 0
;#GL_BGR             = $80E0
;#GL_BGRA            = $80E1
;#GL_CLAMP_TO_BORDER = $812D
;#GL_MULTISAMPLE_ARB = $809D

;- Structures

Structure Scale
    Sx.f         ; virtuelle size Sx
    Sy.f         ; virtuelle size Sy
    Sz.f         ; virtuelle size Sz
EndStructure

Structure Grad
    XGrad.f 
    YGrad.f 
    ZGrad.f 
EndStructure

Structure MyVertex 
    x.f : y.f : z.f    ; vertices coordinates 
    nx.f : ny.f : nz.f ; normal coordinates
    Color.l            ; color 
    u.f : v.f          ; texture coordinates 
;    u1.f : v1.f          ; texture coordinates 2 
EndStructure 

Structure FTriangle 
    f1.w 
    f2.w 
    f3.w 
EndStructure 

Structure PosXY
    X_Pos.f 
    Y_Pos.f 
EndStructure

Structure PosXYZ
    X_Pos.f 
    Y_Pos.f 
    Z_Pos.f 
EndStructure

Structure PosXYZW
    X_Pos.f 
    Y_Pos.f 
    Z_Pos.f 
    W_Pos.f 
EndStructure

Structure Rectangle ; Texturecoords
    left.f 
    right.f 
    top.f 
    bottom.f 
EndStructure

Structure RGBA
    R.f 
    G.f 
    B.f 
    A.f 
EndStructure

CompilerIf Defined(D3DMATRIX, #PB_Constant) = #False
      Structure D3DMATRIX
          _11.f : _12.f : _13.f : _14.f
          _21.f : _22.f : _23.f : _24.f
          _31.f : _32.f : _33.f : _34.f
          _41.f : _42.f : _43.f : _44.f
      EndStructure
CompilerEndIf

Structure MeshDim
  *Vertices.PosXYZ
  *Color.long
  *Indices.FTriangle
  *Normals.PosXYZ
  *Texcoords
EndStructure

; Lightstructure

Structure LightStruct
    kind.i
    LightAmbient.RGBA         
    LightDiffuse.RGBA         
    LightSpecular.RGBA         
    LightPosition.PosXYZW
    LightGrad.Grad          ; Position in Grad
    Name.s
    Lightnumber.i
    active.i
EndStructure 

Structure MaterialStruct
    ambient.RGBA
    diffuse.RGBA
    specular.RGBA
    shininess.f
EndStructure 

; Meshstructure

Structure MeshStruct
    kind.i
    Mesh.MeshDim         
    MeshPosition.PosXYZ
    Meshscale.Scale        ; size of entity
    MeshGrad.Grad          ; 
    MeshGrad2.Grad 
    Name.s                 ; Name 
    Parent.i               ; parent kid funtion will come
    free.i                 ; Frei drehen
    Newton.i               ; Newton Physik
    m_Hide.b               ; unsign
    ZEnable.b              ; Zmode
    List Texture.i()       ; Zeiger auf Textur 1 bis 10
    Alphamode.b
    Blendmode1.l
    Blendmode2.l
EndStructure 

; Spritestructure

Structure Sprite
    kind.i
    pTextureManager.i    ;
    m_vScale.PosXYZ       ;
    m_fRotation.f
    Name.s                 ; Name 
    m_height.l
    m_width.l
    ;Parent.i               ; parent kid funtion will come
    
    ;m_bAnimated.b;
    ;fAnimationTimer.f
    ;m_MaxFrames.l
 
    Alphamode.b
    Blendmode1.l
    Blendmode2.l
    
    ;m_Rect.RECT;
    ;m_iWidth.l
    ;m_iHeight.l
    ;m_Framedirection.l

EndStructure

Structure SpriteDraw
        ;//bn_Sprite class
        Sprite.i
        Pos.PosXY
        fRotation.f
        m_vScale.PosXYZ
        ;SETZ.f 
        m_iAlpha.l;
        Blendmode1.l
        Blendmode2.l
        nFrame.l
        ;m_Rect.l
        ;m_Draw.RECT
EndStructure

; Texture

Structure Texture
    OpenGLTexture.i[3]   ; pointer to textureinterface
    MatD3D.MaterialStruct                 ; pointer to material 
    pTextureFilename.s                 ; name of texture
    Alphamode.b                     ; alphamode for texture 
    ;OldD3DTexture.IDirect3DTexture9 ; copy of texture, needed for turned textures
    Subset.i                        ; Subset Texure
    ;Rendertarget.i                  ; needed for texture rendering
    Format.l                        ; Bits
    height.l                        ; height of texture
    width.l                         ; width of texture
    ;Rendestat.i                     ; needed for texture rendering
EndStructure

; Textprint

Structure Textprint
    x.l
    y.l
    iw.l
    ih.l
  ;  m.l
    ScaleX.f   
    ScaleY.f   
    Rotation.f
  ;  FontSetZ.f
  ;  Format.l
    Fontcolor.l
    Text.s
    MyFont.i
EndStructure

Structure Particle
    ;*PartikelEmitter.SParticleSystem
    m_vCurPos.PosXYZ
    m_vCurVel.PosXYZ
    m_Size.f
    m_VarSize.f
    ;mp_32	  m_sColor.D3DCOLOR
    ;mp_32	  m_vColor.D3DCOLOR
	  m_sColor.l
	  m_vColor.l
	  m_fInitTime.d
	  m_fLifeCycle.d
	  nFrame.i
	  fAnimationTimer.d
    ;m_FrameTime.f
    
EndStructure 

; Particle

Structure SParticleSystem
  kind.i
  count.i
  ParticlePosition.D3DMATRIX ; Position im 3D Raum
  Particle.Scale        
  ParticleGrad.Grad          ; Position in Grad -> Absoluter Grad
  ParticleGrad2.Grad         ; Position in Grad -> Relativer Grad
  Name.s                     ; Names des Partikelsystem
  ZEnable.b
  
  List Partikel.Particle ()
  Maxcount.i
  
  m_fCurrentTime.f 
  m_fLastUpdate.f 
  m_fStartTime.f 
  
  m_fMaxPointSize.f
  
  m_bDevicSupportsPSIZE.l 
  
  m_pVB.IDIRECT3DVERTEXBUFFER9 
  
  m_pTexture.i[32]             ; Zeiger auf Textur   
  m_FrameTime.f
  
  ;Anmimation
  m_bAnimated.b;
;  fAnimationTimer.f
  m_MaxFrames.l
  
  m_D3DRS_SRCBLEND.l
  m_D3DRS_DESTBLEND.l 
  
  ;Particle Attributes 
  m_dwMaxParticles.l 
  m_dwNumToRelease.l 
  m_fReleaseInterval.f 
  
  m_MinLifeCycle.f 
  m_MaxLifeCycle.f 
  m_fSize.f
  m_fSize2.f
  
  m_NewSize.f
  
  m_fadeout.l
  
  m_ColorMinR.c
  m_ColorMinG.c
  m_ColorMinB.c
  m_ColorMaxR.c
  m_ColorMaxG.c
  m_ColorMaxB.c
  
  m_ColorNewrange.l
  
  m_vPosition.PosXYZ 
  m_vVelocity.PosXYZ 
  m_vGravity.PosXYZ 
  m_vWind.PosXYZ 
  m_bAirResistence.b  
  m_bGravityResistence.b 
  m_fVelocityVar.f 

  
EndStructure

;- On the fly init routines and internal functions

Procedure init_all() ; All variables you need in the lib
  ;- Constantes

  #Create_ASCII_Dll   = 0
  #GL_BGR             = $80E0
  #GL_BGRA            = $80E1
  #GL_CLAMP_TO_BORDER = $812D
  #GL_MULTISAMPLE_ARB = $809D

  Define count
  ; Here comes all we need for initialisation
  Global NewList Mesh.MeshStruct()
  Global NewList TextureM.Texture()
  Global NewList Light.LightStruct()
  Global NewList Sprite.sprite()
  Global NewList SpriteDraw.SpriteDraw()
  Global NewList Textprint.Textprint()
  Global FontScaleXGlobal.f = 1
  Global FontScaleYGlobal.f = 1
  Global GlobalFont = LoadFont(#PB_Any, "Arial", 18)
  
  Global hWnd
  Global Gadget = 0
  
  For count = 0 To 7 ; Create 8 Lights
    If ListSize(Light()) < 8
       AddElement(Light())
       Light()\kind = 5
       Light()\Lightnumber = $4000 + count
       Light()\LightAmbient\R = 1
       Light()\LightAmbient\G = 1
       Light()\LightAmbient\B = 1
       Light()\LightAmbient\A = 1
       Light()\LightDiffuse\R = 1
       Light()\LightDiffuse\G = 1
       Light()\LightDiffuse\B = 1
       Light()\LightDiffuse\A = 1
      EndIf
  Next
  Global numberoflights 
  Global fElpasedAppTime.q = 16
  Global dStartAppTime.q =  ElapsedMilliseconds()
  Global VSync_Rendertime = 1
  Global AmbientColor.RGBA 
  Global Joystickcount = InitJoystick()
  UseJPEGImageDecoder()
  UseTGAImageDecoder()
  UsePNGImageDecoder()
  UseTIFFImageDecoder()
  UseGIFImageDecoder()

EndProcedure

Procedure ReSizeGLScene(width.l,height.l) ;Resize And Initialize The GL Window

 If height=0 : height=1 : EndIf ;Prevent A Divide By Zero Error
 
 ResizeGadget(0, 0, 0, width, height)
 glViewport_(0,0,width,height) ;Reset The Current Viewport
 glMatrixMode_(#GL_PROJECTION) ;Select The Projection Matrix
 glLoadIdentity_() ;Reset The Projection Matrix
 gluPerspective_(45.0,Abs(width/height),0.1,100.0) ;Calculate The Aspect Ratio Of The Window
 glMatrixMode_(#GL_MODELVIEW) ;Select The Modelview Matrix
 glLoadIdentity_() ;Reset The Modelview Matrix
 glShadeModel_(#GL_SMOOTH) 
 glEnable_(#GL_DEPTH_TEST)
 
EndProcedure

Procedure CreateGLWindow(title.s,WindowWidth.l,WindowHeight.l,bits.l=16,fullscreenflag.b=0,Vsync.b=0)
  
  Define OpenGlFlags
  
  If InitKeyboard() = 0 Or InitSprite() = 0 Or InitMouse() = 0    ; Old
    MessageRequester("Error", "Can't initialize Keyboards or Mouse", 0)
  EndIf
  If fullscreenflag
    hWnd = OpenWindow(0, 0, 0, WindowWidth, WindowHeight, title, #PB_Window_BorderLess|#PB_Window_Maximize )
    OpenWindowedScreen(WindowID(0), 0, 0,WindowWidth(0),WindowHeight(0)) 
  Else  
    hWnd = OpenWindow(0, 1, 1, WindowWidth, WindowHeight, title,#PB_Window_MinimizeGadget |  #PB_Window_MaximizeGadget | #PB_Window_SizeGadget ) 
    OpenWindowedScreen(WindowID(0), 1, 1, WindowWidth,WindowHeight) 
  EndIf
  
  ExamineKeyboard() 
  
  If bits.l = 24
    OpenGlFlags + #PB_OpenGL_24BitDepthBuffer
  EndIf
  
  If Vsync.b = 0
    OpenGlFlags + #PB_OpenGL_NoFlipSynchronization
  EndIf
  
  OpenGLGadget(Gadget, 0, 0, WindowWidth(0),WindowHeight(0),OpenGlFlags)
  
  SetActiveGadget(0)

  ReSizeGLScene(WindowWidth(0),WindowHeight(0))
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows  ; You get the information only after start of Opengl
    Global wglSwapIntervalEXT = wglGetProcAddress_("wglSwapIntervalEXT")
  CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
    Global wglSwapIntervalEXT = glXGetProcAddress("glXSwapIntervalEXT")
  CompilerEndIf
  
EndProcedure

Procedure Begin2D()
  
   glMatrixMode_(#GL_PROJECTION)    
   glPushMatrix_()
   glLoadIdentity_()
   glOrtho_(0, WindowWidth(0),WindowHeight(0),0,0, -1)
   glViewport_(0,0,WindowWidth(0),WindowHeight(0))
   glMatrixMode_(#GL_MODELVIEW)
   ;glPushMatrix_()
   ;glLoadIdentity_()
    
EndProcedure

Procedure End2D()  
    glMatrixMode_(#GL_PROJECTION)
    glPopMatrix_()
    glMatrixMode_(#GL_MODELVIEW)
    glPopMatrix_()
EndProcedure

Procedure Max(a, b) ; maximum of two integer
  If a > b
    ProcedureReturn a
  Else
    ProcedureReturn b
  EndIf
EndProcedure

Procedure Min(a, b) ; minimum of two integer
  If a < b
    ProcedureReturn a
  Else
    ProcedureReturn b
  EndIf
EndProcedure


;- Engine Values (10x)

ProcedureDLL MP_Graphics3D ( Width, Height, Depth, Modus) ; First example
  
  ;MessageRequester("Information", "1-", #PB_MessageRequester_Ok | #PB_MessageRequester_Info)
  Init_all()
  ;MessageRequester("Information", "2-", #PB_MessageRequester_Ok | #PB_MessageRequester_Info)
  CreateGLWindow("",Width,Height,16,0,1)
  ;MessageRequester("Information", "3-", #PB_MessageRequester_Ok | #PB_MessageRequester_Info)
  ;ExamineKeyboard() 
  ;MessageRequester("Information", "4-", #PB_MessageRequester_Ok | #PB_MessageRequester_Info)
  ReSizeGLScene(Width,Height)
  ;MessageRequester("Information", "5-", #PB_MessageRequester_Ok | #PB_MessageRequester_Info)
  
EndProcedure

ProcedureDLL MP_CloseWindow() 
  
  CloseScreen()
  CloseWindow(hWnd)
  
EndProcedure

ProcedureDLL MP_WindowEvent () 
  
  ProcedureReturn WindowEvent()

EndProcedure

ProcedureDLL MP_VSync(Var) ;  VSync on (Var = 1), VSync off (Var = 0) 
  
  If var = 0 Or Var = 1
    If wglSwapIntervalEXT ; Vsync switch
      If Var = 0
        CallFunctionFast(wglSwapIntervalEXT,0)
        VSync_Rendertime = 0
      ElseIf Var = 1
        CallFunctionFast(wglSwapIntervalEXT,1)
        VSync_Rendertime = 1
      EndIf  
    Else
      If Var = 0
        FreeGadget(0)
        OpenGLGadget(0, 0, 0, WindowWidth(0),WindowHeight(0),#PB_OpenGL_NoFlipSynchronization)
        VSync_Rendertime = 0
      ElseIf Var = 1
        FreeGadget(0)
        OpenGLGadget(0, 0, 0, WindowWidth(0),WindowHeight(0),#PB_OpenGL_FlipSynchronization)
        VSync_Rendertime = 1
      EndIf
      ForEach Light()
        If Light()\active = 1
           glLightfv_(Light()\Lightnumber, #GL_AMBIENT, Light()\LightAmbient)
           glLightfv_(Light()\Lightnumber, #GL_DIFFUSE, Light()\LightDiffuse)
           glEnable_(Light()\Lightnumber)
           glEnable_(#GL_LIGHTING)
        EndIf
      Next
    EndIf  
    ProcedureReturn #True
   EndIf   
    
  ProcedureReturn  #False
    
EndProcedure

ProcedureDLL.f MP_VSyncTime() ; Time of Rendersloop
  
  Define SyncTime.f
  
  SyncTime = fElpasedAppTime / 1000
  ProcedureReturn SyncTime
   
EndProcedure

ProcedureDLL MP_FPS () ; Count the FPS Rate
  
  
  
  Global StartTimer.q , FrameCounter, fps
 
  starttimer + fElpasedAppTime
  FrameCounter + 1
  
  If starttimer > 500
     FPS = FrameCounter * 2
     starttimer = 0
     FrameCounter = 0
  EndIf
   
  ProcedureReturn fps    

EndProcedure

ProcedureDLL MP_AmbientSetLight (RGB) ; Background color with RGB (r,g,b)
  
  AmbientColor\b =  Blue(RGB)/255 
  AmbientColor\g =  Green(RGB)/255 
  AmbientColor\r =  Red(RGB)/255 
  
EndProcedure

ProcedureDLL MP_Wireframe (a) ; wireframe mode on/off , a = 0 solid mode, a = o wireframe mode

 If a = 1 
    glPolygonMode_( #GL_FRONT_AND_BACK, #GL_LINE )
 Else  
    glPolygonMode_( #GL_FRONT_AND_BACK, #GL_FILL )
 EndIf

EndProcedure

ProcedureDLL MP_KeyDown(key) ; Taste (key.w) gedrückt? key = PureBasic Keys
  
  ProcedureReturn KeyboardPushed(key) 

EndProcedure

ProcedureDLL MP_Windows_Fps(Title.s)
  CompilerIf #Create_ASCII_Dll
     Title = PeekS (@Title,-1,#PB_Ascii) ; ASCII Input
  CompilerEndIf
  Global Now = ElapsedMilliseconds()
  Global Ticks , FrameCounter
  If (Now-Ticks) > 999
     Ticks = Now
     SetWindowTitle(0,Title+" FPS:"+ Str( FrameCounter )) 
     FrameCounter = 0
  EndIf
  FrameCounter + 1
      
EndProcedure

;- Entity Values (7x)

ProcedureDLL MP_PositionEntity (Entity, x.f, y.f, z.f ) ; Change Position of Entity
  
    ForEach Mesh()
      If Mesh() = Entity

        Mesh()\MeshPosition\X_Pos = x.f
        Mesh()\MeshPosition\Y_Pos = y.f
        Mesh()\MeshPosition\Z_Pos = z.f
        ProcedureReturn #True

      EndIf
    Next
    
    ForEach light()
      If light() = Entity

        light()\LightPosition\X_Pos = x.f
        light()\LightPosition\Y_Pos = y.f
        light()\LightPosition\Z_Pos = z.f
        glLightfv_(Light()\Lightnumber, #GL_POSITION, @Light()\LightPosition)
        ProcedureReturn #True

      EndIf
    Next
  ProcedureReturn #False        
    
EndProcedure

Procedure MP_RotateEntity_all (Entity, pitch.f, yaw.f, roll.f,flag) ; Dreht ein Entity auf einen bestimmten absoluten Winkel in Grad (Entity ist Mesh, Primitives, Partikelemmiter oder Light)
  
  ForEach Mesh()
    If Mesh() = Entity
      If flag = 0
          Mesh()\MeshGrad\XGrad = yaw
          Mesh()\MeshGrad\YGrad = pitch
          Mesh()\MeshGrad\ZGrad = roll
      ElseIf flag = 1 
          Mesh()\MeshGrad2\XGrad = yaw
          Mesh()\MeshGrad2\YGrad = pitch
          Mesh()\MeshGrad2\ZGrad = roll
      EndIf    
      ProcedureReturn #True        

    EndIf
  Next
  ProcedureReturn #False        
  
EndProcedure

ProcedureDLL MP_RotateEntity (Entity, pitch.f, yaw.f, roll.f) ; Turn an Entity to an absolute degree (Entity is Mesh)
  
  ProcedureReturn  MP_RotateEntity_all (Entity, pitch.f, yaw.f, roll.f,0) 
  
EndProcedure

ProcedureDLL MP_RotateEntity2 (Entity, pitch.f, yaw.f, roll.f,flag) ; Turn an Entity to an absolute degree (Entity is Mesh)
  
  ProcedureReturn  MP_RotateEntity_all (Entity, pitch.f, yaw.f, roll.f,flag)
  
EndProcedure

Procedure MP_TurnEntity_All (Entity, pitch.f, yaw.f, roll.f,flag) ; Turn an Entity (Entity is mesh ) 

  If VSync_Rendertime = 0 ; Vsync on 
    If fElpasedAppTime > 0
       pitch = pitch * 60 * fElpasedAppTime / 1000
       yaw = yaw * 60 * fElpasedAppTime / 1000
       roll = roll * 60 * fElpasedAppTime / 1000
    Else
       pitch = 0: yaw = 0: roll = 0
    EndIf  
  EndIf
  
  ForEach Mesh()
    If Mesh() = Entity
      If flag = 0
        Mesh()\MeshGrad\XGrad + yaw
        Mesh()\MeshGrad\YGrad + pitch
        Mesh()\MeshGrad\ZGrad + roll
      Else
        Mesh()\MeshGrad2\XGrad + yaw
        Mesh()\MeshGrad2\YGrad + pitch
        Mesh()\MeshGrad2\ZGrad + roll
      EndIf  
      ProcedureReturn #True

    EndIf
  Next
  ProcedureReturn #False
    
EndProcedure

ProcedureDLL MP_TurnEntity (Entity, pitch.f, yaw.f, roll.f) ; Turn an Entity (Entity is mesh, Light ) 
  
  ProcedureReturn MP_TurnEntity_All (Entity, pitch.f, yaw.f, roll.f,0)
  
EndProcedure

ProcedureDLL MP_TurnEntity2 (Entity, pitch.f, yaw.f, roll.f,flag) ; Tailbite function for "flag = 0"
  
  ProcedureReturn MP_TurnEntity_All (Entity, pitch.f, yaw.f, roll.f,flag)
  
EndProcedure

ProcedureDLL MP_MoveEntity (Entity, x.f, y.f, z.f) ; verschiebt ein Entity um einen bestimmten x,y,z Abstand.  (Entity ist Mesh, Primitives, AnimMesh, Partikelemmiter, Licht)

  If  VSync_Rendertime = 0 ; Vsync on 
   If fElpasedAppTime > 0
     x = x * 60 * fElpasedAppTime / 1000
     y = y * 60 * fElpasedAppTime / 1000
     z = z * 60 * fElpasedAppTime / 1000
   Else
     x = 0 : y = 0: z = 0
   EndIf
   
  EndIf   

  ForEach Mesh()
    If Mesh() = Entity
      
      Mesh()\MeshPosition\X_Pos + x
      Mesh()\MeshPosition\Y_Pos + y
      Mesh()\MeshPosition\Z_Pos + z
             
      ProcedureReturn #True
    EndIf
  Next

EndProcedure

ProcedureDLL MP_HideEntity (Entity, Bool) ; the entity becomes invisible by 1 and visible by 0
  
  ForEach Mesh()
    If Mesh() = Entity
       Mesh()\m_Hide = Bool
       ProcedureReturn #True
    EndIf
  Next
  
EndProcedure

ProcedureDLL MP_FreeEntity (Entity) ; delete an Entity,  (Entity is Mesh, Light)

  ForEach Mesh()
    If Mesh() = Entity
       ;FreeList(Mesh()\Tri())  ; Futurefunction
       ;FreeList(Mesh()\Vert()) ; Futurefunction
       If Mesh()\Mesh\Vertices  : FreeMemory(Mesh()\Mesh\Vertices) : EndIf
       If Mesh()\Mesh\Color     : FreeMemory(Mesh()\Mesh\Color) : EndIf
       If Mesh()\Mesh\Indices   : FreeMemory(Mesh()\Mesh\Indices) : EndIf
       If Mesh()\Mesh\Normals   : FreeMemory(Mesh()\Mesh\Normals) : EndIf
       If Mesh()\Mesh\Texcoords : FreeMemory(Mesh()\Mesh\Texcoords) : EndIf
       DeleteElement (Mesh())
       ProcedureReturn #True
    EndIf
  Next
  
  ForEach Light()
    If Light() = Entity
      Light()\active = 0
      numberoflights - 1
      glDisable_(Light()\Lightnumber) 
      If numberoflights = 0 : glDisable_(#GL_LIGHTING) : EndIf
      ProcedureReturn #True
    EndIf
  Next
  
  ProcedureReturn #False ; Found no entity
  
EndProcedure

ProcedureDLL MP_EntitySetColor (Entity, Color.l) ; Colors all vertexes of an entity with Color = RGBA (a,r,g,b) (Entity is a mesh)
  
  Define Color_count
  
  ForEach Mesh()
    If Mesh() = Entity
      If Mesh()\Mesh\Color
         Color_count = MemorySize(Mesh()\Mesh\Color)
         FillMemory(Mesh()\Mesh\Color, Color_count,Color,#PB_Long )
         ProcedureReturn #True
     EndIf
    EndIf
  Next

EndProcedure

;- Color Values (6x)

ProcedureDLL MP_ARGB(A.b,R.b,G.b,B.b) ; Berechnet den Wert aus den 8 bit Alpha, Rot, Grün und Blau Werten 
 ProcedureReturn ((a & $FF) << 24) | ((r & $FF) << 16) | ((g & $FF) << 8) | (b & $FF)
EndProcedure
   
ProcedureDLL MP_BGR(B.b,G.b,R.b) ; Berechnet den Wert aus den 8 bit Alpha, Rot, Grün und Blau Werten 
   ProcedureReturn ((r & $FF) << 16) | ((g & $FF) << 8) | (b & $FF)
EndProcedure
   
ProcedureDLL MP_Blue (Color.l) ; Berechnet den Alpha Wert aus einem 8 bit Alpha, Rot, Grün und Blau Wert
   ProcedureReturn Color & $FF
EndProcedure
   
ProcedureDLL MP_Green (Color.l) ; Berechnet den Grün Wert aus einem 8 bit Alpha, Rot, Grün und Blau Wert
   ProcedureReturn (Color >> 8 ) & $FF 
EndProcedure
   
ProcedureDLL MP_Red (Color.l) ; Berechnet den Rot Wert aus einem 8 bit Alpha, Rot, Grün und Blau Wert 
   ProcedureReturn (Color >> 16 ) & $FF 
EndProcedure   
   
ProcedureDLL MP_Alpha (Color.l) ; Berechnet den Blau Wert aus einem 8 bit Alpha, Rot, Grün und Blau Wert 
   ProcedureReturn (Color >> 24) & $FF
EndProcedure

;- Texture Values (7x)

ProcedureDLL MP_LoadTexture(FileName.s) ; Load a picture as grafic
  
  Define ImageId, ImageWidth, ImageHeight, noconvert, *pointer, *newpointer.byte, Color.l, TransparentColor.l, y, x, File.s, iBytes
  Define iFormat, *Pos, *Buffer, LastY
 
  ImageId = LoadImage(#PB_Any, FileName)
  
  If IsImage(ImageId)
    ImageWidth  = ImageWidth(ImageId)
    ImageHeight = ImageHeight(ImageId)
    LastY = ImageHeight(ImageId)-1
  Else
    MessageRequester("ERROR!", "Failed to load the specified file: "+FileName + ". Please double check your file path.", #PB_MessageRequester_Ok)
    ProcedureReturn #False
  EndIf
  
  If StartDrawing(ImageOutput(ImageId))
		If DrawingBufferPixelFormat() & #PB_PixelFormat_24Bits_RGB
			iBytes = 3 : iFormat = #GL_RGB : Debug "#GL_RGB"
		EndIf
		If DrawingBufferPixelFormat() & #PB_PixelFormat_24Bits_BGR
			iBytes = 3 : iFormat = #GL_BGR : Debug "#GL_BGR"
		EndIf
		If DrawingBufferPixelFormat() & #PB_PixelFormat_32Bits_RGB
			iBytes = 4 : iFormat = #GL_RGBA : Debug "#GL_RGBA"
		EndIf
		If DrawingBufferPixelFormat() & #PB_PixelFormat_32Bits_BGR
			iBytes = 4 : iFormat = #GL_BGRA : Debug "#GL_BGRA"
		EndIf

		*Buffer = AllocateMemory(ImageWidth * ImageHeight * iBytes) : *Pos = *Buffer
		If DrawingBufferPixelFormat() & #PB_PixelFormat_ReversedY
			For Y = LastY To 0 Step -1
				CopyMemory(DrawingBuffer()+DrawingBufferPitch()*Y, *Pos, ImageWidth * iBytes)
				*Pos + ImageWidth * iBytes
			Next
		Else
			For Y = 0 To LastY Step 1
				CopyMemory(DrawingBuffer()+DrawingBufferPitch()*Y, *Pos, ImageWidth * iBytes)
				*Pos + ImageWidth * iBytes
			Next
		EndIf
		StopDrawing()
    
    AddElement (TextureM())
  	glGenTextures_(3, @TextureM()\OpenGLTexture[0]);                  // Create Three Textures
    ;AddElement (TextureM())
    ;// Create Nearest Filtered Texture
    glBindTexture_(#GL_TEXTURE_2D, @TextureM()\OpenGLTexture[0] );
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_NEAREST); // ( NEW )
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_NEAREST); // ( NEW )
    glTexImage2D_(#GL_TEXTURE_2D, 0, #GL_RGBA, ImageWidth,ImageHeight, 0, iFormat, #GL_UNSIGNED_BYTE, *Buffer);
    
    ;// Create Linear Filtered Texture
    glBindTexture_(#GL_TEXTURE_2D, @TextureM()\OpenGLTexture[1]);
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR);
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR);
    glTexImage2D_(#GL_TEXTURE_2D, 0, #GL_RGBA, ImageWidth,ImageHeight, 0, iFormat, #GL_UNSIGNED_BYTE,  *Buffer);
    ;// Create MipMapped Texture
    glBindTexture_(#GL_TEXTURE_2D, @TextureM()\OpenGLTexture[2]);
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR);
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR_MIPMAP_NEAREST); // ( NEW )
    gluBuild2DMipmaps_(#GL_TEXTURE_2D, #GL_RGBA, ImageWidth,ImageHeight, iFormat, #GL_UNSIGNED_BYTE, *Buffer); // ( NEW )
    FreeMemory(*Buffer)
     
    TextureM()\MatD3D\ambient\r = 1
    TextureM()\MatD3D\ambient\g = 1
    TextureM()\MatD3D\ambient\b = 1
    TextureM()\MatD3D\ambient\a = 1
    TextureM()\MatD3D\Diffuse\r = 1
    TextureM()\MatD3D\Diffuse\g = 1
    TextureM()\MatD3D\Diffuse\b = 1
    TextureM()\MatD3D\Diffuse\a = 1
    TextureM()\MatD3D\shininess = 0 
    TextureM()\pTextureFilename = GetFilePart(File.s)
    TextureM()\Format = 32
    TextureM()\width  = ImageWidth
    TextureM()\height = ImageHeight
    Debug "addiert: "+Str(TextureM())

    
    ProcedureReturn TextureM()
  EndIf
   
  ProcedureReturn #False
  
EndProcedure

ProcedureDLL MP_CatchTexture (Adresse, Laenge); Creates a Texture from Memory
  
  Define ImageId, ImageWidth, ImageHeight, noconvert, *pointer, *newpointer.byte, Color.l, TransparentColor.l, y, x, File.s, iBytes
  Define iFormat, *Pos, *Buffer, LastY
  
  ImageId = CatchImage(#PB_Any, Adresse, Laenge)
  
  If IsImage(ImageId)
    ImageWidth  = ImageWidth(ImageId)
    ImageHeight = ImageHeight(ImageId)
    LastY = ImageHeight(ImageId)-1
  Else
    MessageRequester("ERROR!", "Failed to load the specified file on Adress: "+Hex(Adresse)+". Please double check your file path.", #PB_MessageRequester_Ok)
    ProcedureReturn #False
  EndIf
  
 If StartDrawing(ImageOutput(ImageId))
		If DrawingBufferPixelFormat() & #PB_PixelFormat_24Bits_RGB
			iBytes = 3 : iFormat = #GL_RGB : Debug "#GL_RGB"
		EndIf
		If DrawingBufferPixelFormat() & #PB_PixelFormat_24Bits_BGR
			iBytes = 3 : iFormat = #GL_BGR : Debug "#GL_BGR"
		EndIf
		If DrawingBufferPixelFormat() & #PB_PixelFormat_32Bits_RGB
			iBytes = 4 : iFormat = #GL_RGBA : Debug "#GL_RGBA"
		EndIf
		If DrawingBufferPixelFormat() & #PB_PixelFormat_32Bits_BGR
			iBytes = 4 : iFormat = #GL_BGRA : Debug "#GL_BGRA"
		EndIf

		*Buffer = AllocateMemory(ImageWidth * ImageHeight * iBytes) : *Pos = *Buffer
		If DrawingBufferPixelFormat() & #PB_PixelFormat_ReversedY
			For Y = LastY To 0 Step -1
				CopyMemory(DrawingBuffer()+DrawingBufferPitch()*Y, *Pos, ImageWidth * iBytes)
				*Pos + ImageWidth * iBytes
			Next
		Else
			For Y = 0 To LastY Step 1
				CopyMemory(DrawingBuffer()+DrawingBufferPitch()*Y, *Pos, ImageWidth * iBytes)
				*Pos + ImageWidth * iBytes
			Next
		EndIf
		StopDrawing()
    
    AddElement (TextureM())
  	glGenTextures_(3, @TextureM()\OpenGLTexture[0]);                  // Create Three Textures
    ;AddElement (TextureM())
    ;// Create Nearest Filtered Texture
    glBindTexture_(#GL_TEXTURE_2D, @TextureM()\OpenGLTexture[0] );
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_NEAREST); // ( NEW )
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_NEAREST); // ( NEW )
    glTexImage2D_(#GL_TEXTURE_2D, 0, #GL_RGBA, ImageWidth,ImageHeight, 0, iFormat, #GL_UNSIGNED_BYTE, *Buffer);
    
    ;// Create Linear Filtered Texture
    glBindTexture_(#GL_TEXTURE_2D, @TextureM()\OpenGLTexture[1]);
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR);
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR);
    glTexImage2D_(#GL_TEXTURE_2D, 0, #GL_RGBA, ImageWidth,ImageHeight, 0, iFormat, #GL_UNSIGNED_BYTE,  *Buffer);
    ;// Create MipMapped Texture
    glBindTexture_(#GL_TEXTURE_2D, @TextureM()\OpenGLTexture[2]);
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_LINEAR);
    glTexParameteri_(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_LINEAR_MIPMAP_NEAREST); // ( NEW )
    gluBuild2DMipmaps_(#GL_TEXTURE_2D, #GL_RGBA, ImageWidth,ImageHeight, iFormat, #GL_UNSIGNED_BYTE, *Buffer); // ( NEW )
    FreeMemory(*Buffer)
     
    TextureM()\MatD3D\ambient\r = 1
    TextureM()\MatD3D\ambient\g = 1
    TextureM()\MatD3D\ambient\b = 1
    TextureM()\MatD3D\ambient\a = 1
    TextureM()\MatD3D\Diffuse\r = 1
    TextureM()\MatD3D\Diffuse\g = 1
    TextureM()\MatD3D\Diffuse\b = 1
    TextureM()\MatD3D\Diffuse\a = 1
    TextureM()\MatD3D\shininess = 0 
    TextureM()\pTextureFilename = GetFilePart(File.s)
    TextureM()\Format = 32
    TextureM()\width  = ImageWidth
    TextureM()\height = ImageHeight
    Debug "addiert: "+Str(TextureM())

    
    ProcedureReturn TextureM()
  EndIf
   
  ProcedureReturn #False
  
EndProcedure

ProcedureDLL MP_Load2DTexture (FileName.s) ; Load a picture as spritegrafic
  
  Define ImageId, ImageWidth, ImageHeight, noconvert, *pointer, *newpointer.byte, Color.l, TransparentColor.l, y, x, File.s, iBytes
  Define iFormat, *Pos, *Buffer, LastY
 
  ImageId = LoadImage(#PB_Any, FileName)
  
  If IsImage(ImageId)
    ImageWidth  = ImageWidth(ImageId)
    ImageHeight = ImageHeight(ImageId)
    LastY = ImageHeight(ImageId)-1
  Else
    MessageRequester("ERROR!", "Failed to load the specified file: "+FileName + ". Please double check your file path.", #PB_MessageRequester_Ok)
    ProcedureReturn #False
  EndIf
  
  If StartDrawing(ImageOutput(ImageId))
		If DrawingBufferPixelFormat() & #PB_PixelFormat_24Bits_RGB
			iBytes = 3 : iFormat = #GL_RGB : Debug "#GL_RGB"
		EndIf
		If DrawingBufferPixelFormat() & #PB_PixelFormat_24Bits_BGR
			iBytes = 3 : iFormat = #GL_BGR : Debug "#GL_BGR"
		EndIf
		If DrawingBufferPixelFormat() & #PB_PixelFormat_32Bits_RGB
			iBytes = 4 : iFormat = #GL_RGBA : Debug "#GL_RGBA"
		EndIf
		If DrawingBufferPixelFormat() & #PB_PixelFormat_32Bits_BGR
			iBytes = 4 : iFormat = #GL_BGRA : Debug "#GL_BGRA"
		EndIf

		*Buffer = AllocateMemory(ImageWidth * ImageHeight * iBytes) : *Pos = *Buffer
		If DrawingBufferPixelFormat() & #PB_PixelFormat_ReversedY
			For Y = LastY To 0 Step -1
				CopyMemory(DrawingBuffer()+DrawingBufferPitch()*Y, *Pos, ImageWidth * iBytes)
				*Pos + ImageWidth * iBytes
			Next
		Else
			For Y = 0 To LastY Step 1
				CopyMemory(DrawingBuffer()+DrawingBufferPitch()*Y, *Pos, ImageWidth * iBytes)
				*Pos + ImageWidth * iBytes
			Next
		EndIf
		StopDrawing()

    ;ShowMemoryViewer(*Buffer, MemorySize(*Buffer))           ; Imageload Alphachannel Problem with linux
    
    AddElement (TextureM())
    glGenTextures_(1, @TextureM()\OpenGLTexture[0])
    ;// Create Nearest Filtered Texture
    glBindTexture_(#GL_TEXTURE_2D, @TextureM()\OpenGLTexture[0]) 
    glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
    glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
    glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, #GL_CLAMP_TO_BORDER)
    glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, #GL_CLAMP_TO_BORDER)
    glTexImage2D_(#GL_TEXTURE_2D, 0, #GL_RGBA,ImageWidth, ImageHeight, 0, iFormat, #GL_UNSIGNED_BYTE,  *Buffer)

    FreeMemory(*Buffer)

    TextureM()\MatD3D\ambient\r = 1
    TextureM()\MatD3D\ambient\g = 1
    TextureM()\MatD3D\ambient\b = 1
    TextureM()\MatD3D\ambient\a = 1
    TextureM()\MatD3D\Diffuse\r = 1
    TextureM()\MatD3D\Diffuse\g = 1
    TextureM()\MatD3D\Diffuse\b = 1
    TextureM()\MatD3D\Diffuse\a = 1
    TextureM()\MatD3D\shininess = 0 
    TextureM()\pTextureFilename = GetFilePart(FileName.s)
    TextureM()\Format = 32
    TextureM()\width  = ImageWidth
    TextureM()\height = ImageHeight
    
    ProcedureReturn TextureM()
  EndIf
   
  ProcedureReturn #False
  
EndProcedure

ProcedureDLL MP_TexturSetAlphaColor (Texture, RGB.l) ; set a transparent color of a Texture
  
    Define n, *MemoryID, *newpointer.byte, y, x, Color.l
  
    Debug "set"
    RGB = RGB & $FFFFFF ; minus Alpha channnel
    
    ForEach TextureM()
      If TextureM() = Texture
        
        For n = 0 To 2
          If TextureM()\OpenGLTexture[n]
              
              glEnable_(#GL_TEXTURE_2D) :  glBindTexture_(#GL_TEXTURE_2D,@TextureM()\OpenGLTexture[n])
              Protected ImageWidth.l,ImageHeight.l
              glGetTexLevelParameteriv_(#GL_TEXTURE_2D,0,#GL_TEXTURE_WIDTH, @ImageWidth)
              glGetTexLevelParameteriv_(#GL_TEXTURE_2D,0,#GL_TEXTURE_HEIGHT, @ImageHeight)
              Debug "loadtxt"
              Debug ImageWidth
              Debug ImageHeight
              
              ImageHeight = TextureM()\height
              ImageWidth = TextureM()\width
              Debug ImageWidth
              Debug ImageHeight

              *MemoryID = AllocateMemory(ImageWidth * ImageHeight * 4 )
              glGetTexImage_(#GL_TEXTURE_2D, 0, #GL_RGBA, #GL_UNSIGNED_BYTE, *MemoryID)
        
              *newpointer.byte = *MemoryID
              For y = 0 To ImageHeight-1 
                For x = 0 To ImageWidth-1 
                  Color.l = PeekL(*newpointer) & $FFFFFF ; minus Alpha channnel, we want to set a new Alpha channnel
                  *newpointer+3
                  If Color = RGB
                    *newpointer\b = 0
                  Else
                    *newpointer\b = 255
                  EndIf
                  *newpointer+1 
                Next x
              Next y
              glTexImage2D_(#GL_TEXTURE_2D, 0, 4,ImageWidth, ImageHeight, 0, #GL_RGBA, #GL_UNSIGNED_BYTE, *MemoryID)
              FreeMemory(*MemoryID)
              glDisable_(#GL_TEXTURE_2D) 
          EndIf    
          Next n
          ProcedureReturn #True
      EndIf
   Next
         
EndProcedure

ProcedureDLL MP_TextureGetHeight (Texture) ; Get the Height of a Texture
  
  ForEach TextureM()
    If TextureM() = Texture

    EndIf
  Next
 
EndProcedure 

ProcedureDLL MP_TextureGetWidth (Texture) ; Get the Width of a Texture
  
  ForEach TextureM()
    If TextureM() = Texture
       ProcedureReturn TextureM()\width
    EndIf
  Next
 
EndProcedure 

ProcedureDLL MP_EntitySetTexture (Entity, Texture) ; Set a texture to a entity
  
  If Texture = 0
        ForEach Mesh()
          If Mesh() = Entity
            If ListSize(Mesh()\Texture()) > 0
               If SelectElement(Mesh()\Texture(), 1) 
                 DeleteElement(Mesh()\Texture(),1)
               Else  
                 SelectElement(Mesh()\Texture(), 0) 
               EndIf
               Mesh()\Texture() = 0
            EndIf   
            ProcedureReturn #True
          EndIf
        Next
  Else
    ForEach TextureM()
      If TextureM() = Texture 
        ForEach Mesh()
          If Mesh() = Entity
            If ListSize(Mesh()\Texture()) > 1
              AddElement(Mesh()\Texture())
              Mesh()\Texture() = Texture
            Else
              Mesh()\Texture() = Texture
            EndIf  
            ProcedureReturn #True
          EndIf
        Next

      EndIf
    
    Next
    
  EndIf
    
EndProcedure


;- Light Values (2x)

ProcedureDLL MP_CreateLight(a) ; Create Light, Typ (a=1) Direction light, (a=2) Point light und (a=3) Spotlight

  ;If a = 2                     ; TODO
  ;   Type = #D3DLIGHT_POINT  
  ;ElseIf a = 3
  ;   Type = #D3DLIGHT_SPOT
  ;Else
  ;   Type = #D3DLIGHT_DIRECTIONAL
  ;EndIf
  ;1=Directional light (Standard)
  ;2=Point light
  ;3=Spotlight  
  
  ForEach Light()
    If Light()\active = 0
       Light()\active = 1
       glLightfv_(Light()\Lightnumber, #GL_AMBIENT, Light()\LightAmbient)
       glLightfv_(Light()\Lightnumber, #GL_DIFFUSE, Light()\LightDiffuse)
       glEnable_(Light()\Lightnumber)
       glEnable_(#GL_LIGHTING)
       numberoflights + 1
       ProcedureReturn Light()
    EndIf
  Next 
  
  ProcedureReturn #False
  
EndProcedure

ProcedureDLL MP_LightSetColor(Light,RGBA) ; Light with RGBA (r,g,b,a)

  ForEach Light()
    If Light() = Light
       Light()\LightDiffuse\r = Red(RGBA)/255 
       Light()\LightDiffuse\g = Green(RGBA)/255 
       Light()\LightDiffuse\b = Blue(RGBA)/255
       Light()\LightDiffuse\a = Alpha(RGBA)/255
       glLightfv_(Light()\Lightnumber, #GL_DIFFUSE, Light()\LightDiffuse) 
       ProcedureReturn #True
    EndIf
  Next 

EndProcedure

;- Mesh Values (21x)

ProcedureDLL.f MP_MeshGetWidth (Entity) ; maximum Mesh width 
  
  Define count_of_vertices, n,  x.f ,MaxX.f, MinX.f, Float.f
  
  ForEach Mesh()
    If Mesh() = Entity
      
        count_of_vertices = MemorySize(Mesh()\Mesh\Vertices)
        For n = 0 To (count_of_vertices)-1 Step SizeOf(float)*3
        
           x.f = PeekF(Mesh()\Mesh\Vertices+n)
           If x.f > MaxX.f
              MaxX.f = x.f
           EndIf   
           If x.f < MinX.f
              MinX.f = x.f
           EndIf   
         
       Next n
       
       Float.f = MaxX - MinX
       ProcedureReturn Float
 
   EndIf
 Next
 ProcedureReturn #False
  
EndProcedure

ProcedureDLL.f MP_MeshGetHeight (Entity) ;maximum Mesh height
  
  Define count_of_vertices, n,  x.f ,MaxY.f, MinY.f, Float.f,  y.f
  
  ForEach Mesh()
    If Mesh() = Entity
      
        count_of_vertices = MemorySize(Mesh()\Mesh\Vertices)
        For n = 0 To (count_of_vertices)-1 Step SizeOf(float)*3
        
           y.f = PeekF(Mesh()\Mesh\Vertices+n+4)
         
           If y.f > MaxY.f
              MaxY.f = y.f
           EndIf   
              
           If y.f < MinY.f
              MinY.f = y.f
           EndIf   
         
       Next n
       
       Float.f = MaxY - MinY
       
       ProcedureReturn Float
 
   EndIf
 Next
 ProcedureReturn #False
  
EndProcedure

ProcedureDLL.f MP_MeshGetDepth (Entity) ; maximum Mesh depth
  
  Define count_of_vertices, n, z.f, MaxZ.f, MinZ.f, Float.f 
  
  ForEach Mesh()
    If Mesh() = Entity
      
        count_of_vertices = MemorySize(Mesh()\Mesh\Vertices)
        For n = 0 To (count_of_vertices)-1 Step SizeOf(float)*3
        
           z.f = PeekF(Mesh()\Mesh\Vertices+n+8)

           If z.f > MaxZ.f
              MaxZ.f = z.f
           EndIf   
              
           If z.f < MinZ.f
              MinZ.f = z.f
           EndIf   
         
       Next n
       
       Float.f = MaxZ - MinZ 
       
       ProcedureReturn Float
 
   EndIf
 Next
 ProcedureReturn #False
  
EndProcedure

Procedure MP_Normalize(*V.PosXYZ)
    Define.f magSq, oneOverMag
     
    magSq = *V\X_Pos * *V\X_Pos + *V\Y_Pos * *V\Y_Pos + *V\Z_Pos * *V\Z_Pos
    If magsq > 0
      oneOverMag = 1.0 / Sqr(magSq)
      *V\X_Pos * oneOverMag
      *V\Y_Pos * oneOverMag
      *V\Z_Pos * oneOverMag
    EndIf
  EndProcedure

Procedure MP_SubCrossVector(*Pos1.PosXYZ, *Pos2.PosXYZ, *Pos3.PosXYZ, *vNormal1.PosXYZ);
  
  Define vVector1.PosXYZ,  vVector2.PosXYZ, magSq.f, oneOverMag.f
  
  ;vVector1.PosXYZ   ; Vec3sub
  vVector1\X_Pos = *Pos1\X_Pos - *Pos2\X_Pos
  vVector1\Y_Pos = *Pos1\Y_Pos - *Pos2\Y_Pos
  vVector1\Z_Pos = *Pos1\Z_Pos - *Pos2\Z_Pos

  ;vVector2.PosXYZ   ; Vec3sub
  vVector2\X_Pos = *Pos1\X_Pos - *Pos3\X_Pos
  vVector2\Y_Pos = *Pos1\Y_Pos - *Pos3\Y_Pos
  vVector2\Z_Pos = *Pos1\Z_Pos - *Pos3\Z_Pos

  *vNormal1\X_Pos = ((vVector1\Y_Pos * vVector2\Z_Pos) - (vVector1\Z_Pos * vVector2\Y_Pos)) ; Vec3cross
  *vNormal1\Y_Pos = ((vVector1\Z_Pos * vVector2\X_Pos) - (vVector1\X_Pos * vVector2\Z_Pos))
  *vNormal1\Z_Pos = ((vVector1\X_Pos * vVector2\Y_Pos) - (vVector1\Y_Pos * vVector2\X_Pos))
  
  ; Vec3Normalize
  magSq = *vNormal1\X_Pos * *vNormal1\X_Pos + *vNormal1\Y_Pos * *vNormal1\Y_Pos + *vNormal1\Z_Pos * *vNormal1\Z_Pos
  If magsq > 0
     oneOverMag = 1.0 / Sqr(magSq)
     *vNormal1\X_Pos * oneOverMag
     *vNormal1\Y_Pos * oneOverMag
     *vNormal1\Z_Pos * oneOverMag
  EndIf
  
EndProcedure

ProcedureDLL MP_NormalizeEntity (Entity) ; First test of a Normalize function (Entity ist Mesh)
  
  Define count_of_vertices, n
  
  ForEach Mesh()
    If Mesh() = Entity
       count_of_vertices = MemorySize(Mesh()\Mesh\Vertices)
       For n = 0 To (count_of_vertices)-1 Step SizeOf(float)*3
          PokeF(Mesh()\Mesh\Normals+n, PeekF(Mesh()\Mesh\Vertices+n))
          PokeF(Mesh()\Mesh\Normals+n+4, PeekF(Mesh()\Mesh\Vertices+n+4) )
          PokeF(Mesh()\Mesh\Normals+n+8, PeekF(Mesh()\Mesh\Vertices+n+8) )
          MP_Normalize(Mesh()\Mesh\Normals)
       Next n
       ProcedureReturn #True

    EndIf
  Next
  ProcedureReturn #False
EndProcedure

ProcedureDLL MP_ScaleEntity (Entity, Sx.f, Sy.f, Sz.f ) ; Ändert die Skalierung eines Entity (Entity ist Mesh, Primitives oder AnimMesh)
  
  Define count_of_vertices, n
  
  ForEach Mesh()
    If Mesh() = Entity
    
      If Sx > 0 And Sy > 0 And Sz > 0 
        
       count_of_vertices = MemorySize(Mesh()\Mesh\Vertices)
       For n = 0 To (count_of_vertices)-1 Step SizeOf(float)*3
         PokeF(Mesh()\Mesh\Vertices+n, PeekF(Mesh()\Mesh\Vertices+n) * Sx)
         PokeF(Mesh()\Mesh\Vertices+n+4, PeekF(Mesh()\Mesh\Vertices+n+4) * Sx)
         PokeF(Mesh()\Mesh\Vertices+n+8, PeekF(Mesh()\Mesh\Vertices+n+8) * Sx)
       Next n
       
       ProcedureReturn #True
     Else
       ProcedureReturn #False
     EndIf 

    EndIf
  Next
  
EndProcedure

ProcedureDLL MP_ResizeMesh(Entity,x_Size.f,y_Size.f,z_Size.f) ; Changes a mesh to a specific size
  
  Define count_of_vertices, MaxX.f, MaxY.f, MaxZ.f,  MinX.f,  MinY.f,  MinZ.f , x.f, y.f , z.f, n
  
  ForEach Mesh()
    If Mesh() = Entity
      
      If x_Size > 0 And y_Size > 0 And z_Size > 0 
        
        count_of_vertices = MemorySize(Mesh()\Mesh\Vertices)
        For n = 0 To (count_of_vertices)-1 Step SizeOf(float)*3
        
           x.f = PeekF(Mesh()\Mesh\Vertices+n)
           y.f = PeekF(Mesh()\Mesh\Vertices+n+4)
           z.f = PeekF(Mesh()\Mesh\Vertices+n+8)
         
           If x.f > MaxX.f : MaxX.f = x.f : EndIf   
              
           If x.f < MinX.f : MinX.f = x.f : EndIf   
         
           If y.f > MaxY.f : MaxY.f = y.f : EndIf   
              
           If y.f < MinY.f : MinY.f = y.f : EndIf   

           If z.f > MaxZ.f : MaxZ.f = z.f : EndIf   
              
           If z.f < MinZ.f : MinZ.f = z.f : EndIf   
         
       Next n
       
       x.f = x_Size / (MaxX - MinX) 
       y.f = y_Size / (MaxY - MinY)
       z.f = z_Size / (MaxZ - MinZ)
       
       For n = 0 To (count_of_vertices)-1 Step SizeOf(float)*3
         PokeF(Mesh()\Mesh\Vertices+n, PeekF(Mesh()\Mesh\Vertices+n) * x)
         PokeF(Mesh()\Mesh\Vertices+n+4, PeekF(Mesh()\Mesh\Vertices+n+4) * y)
         PokeF(Mesh()\Mesh\Vertices+n+8, PeekF(Mesh()\Mesh\Vertices+n+8) * z)
       Next n
       
       ProcedureReturn #True
     Else
       ProcedureReturn #False
     EndIf  
  
   EndIf
 Next
 ProcedureReturn #False
 
EndProcedure

ProcedureDLL MP_PositionMesh(Entity,x.f,y.f,z.f) ; Move all vertices of a mesh
  
  Define count_of_vertices, n
  
  ForEach Mesh()
    If Mesh() = Entity
      
      count_of_vertices = MemorySize(Mesh()\Mesh\Vertices)
      For n = 0 To (count_of_vertices)-1 Step SizeOf(float)*3
         PokeF(Mesh()\Mesh\Vertices+n, PeekF(Mesh()\Mesh\Vertices+n)+x)
         PokeF(Mesh()\Mesh\Vertices+n+4, PeekF(Mesh()\Mesh\Vertices+n+4)+y)
         PokeF(Mesh()\Mesh\Vertices+n+8, PeekF(Mesh()\Mesh\Vertices+n+8)+z)
      Next n   
      
      ProcedureReturn #True
    EndIf
  Next
   
EndProcedure

ProcedureDLL MP_MeshSetAlpha (Mesh, mode) ; Mesh use Texture as Alphatexture

    If mode < 0 Or mode > 2
      mode = 0
      ProcedureReturn #False
    EndIf   

    ForEach Mesh()
      If Mesh() = Mesh 
         Mesh()\Alphamode = mode
         ProcedureReturn #True
      EndIf
    Next
         
EndProcedure

Procedure MP_LoadStl( FileName.s ) ; 3DS Dateien laden
  
  Define qty_Triangle, qty_Vertex, Color.l, *pointer_Vertices.PosXYZ,  *pointer_Normals.PosXYZ, found, Normal.s, normal_nx.f, normal_ny.f, normal_nz.f, Vertex.s
  
  If FileName.s 
    If ReadFile(0, FileName)
      NewList lstlist.s()
      qty_Triangle = 0
      
      While Eof(0) = 0              
        AddElement(lstlist())
        lstlist() = ReadString(0)    
        If FindString(lstlist(), "outer loop") ; count of triangles 
          qty_Triangle + 1
        EndIf  
      Wend
      CloseFile(0)

      qty_Vertex = qty_Triangle * 3
      
      AddElement(Mesh.MeshStruct())
      Mesh()\Meshscale\Sx = 1
      Mesh()\Meshscale\Sy = 1
      Mesh()\Meshscale\Sz = 1
      Mesh()\kind = 1         ; i am a mesh 
  
      Mesh()\ZEnable = 1

      AddElement(Mesh()\Texture())
      
      Mesh()\Mesh\Vertices = AllocateMemory(qty_Vertex * 3 * SizeOf(float))
      Mesh()\Mesh\Normals = AllocateMemory(qty_Vertex * 3 * SizeOf(float))
        
      Mesh()\Mesh\Color = AllocateMemory(qty_Vertex * SizeOf(long))
      Color.l = $646464
      FillMemory(Mesh()\Mesh\Color, qty_Vertex * SizeOf(long),Color,#PB_Long )
      
      *pointer_Vertices.PosXYZ = Mesh()\Mesh\Vertices
      *pointer_Normals.PosXYZ = Mesh()\Mesh\Normals
         
      ForEach lstlist()
        
        found = FindString(lstlist(), "solid") ; find triangle
        If found : Mesh()\Name =  Right(lstlist(), Len(lstlist()) - found - 1) : NextElement(lstlist()) : EndIf
        
        found = FindString(lstlist(), "facet normal") ; read normals
        If found
          Normal.s =  Right(lstlist(), Len(lstlist()) - found - 12)
          While FindString(Normal, "  ", 1) 
             Normal = ReplaceString(Normal, "  ", " ", 1, 1) 
          Wend
          normal_nx.f = ValF(StringField(Normal , 1, " "))
          normal_ny.f = ValF(StringField(Normal , 2, " "))
          normal_nz.f = ValF(StringField(Normal , 3, " "))
         EndIf
         
         NextElement(lstlist()) 
         found = FindString(lstlist(), "outer loop") 
         If found
            NextElement(lstlist()) 
            found = FindString(lstlist(), "vertex") ; Vertex 1 of Triangle
            If found
               Vertex.s =  Right(lstlist(), Len(lstlist()) - found - 8)
               While FindString(Vertex, "  ", 1) 
                 Vertex = ReplaceString(Vertex, "  ", " ", 1, 1) 
               Wend 
            EndIf 
          
            *pointer_Vertices\X_Pos = ValF(StringField(Vertex , 1, " "))
            *pointer_Vertices\Y_Pos = ValF(StringField(Vertex , 2, " "))
            *pointer_Vertices\Z_Pos = ValF(StringField(Vertex , 3, " "))
          
            *pointer_Normals\X_Pos = normal_nx.f
            *pointer_Normals\Y_Pos = normal_ny.f
            *pointer_Normals\Z_Pos = normal_nz.f

            *pointer_Vertices + 12
            *pointer_Normals + 12
          
            NextElement(lstlist()) 
            found = FindString(lstlist(), "vertex")
            If found
               While FindString(Vertex, "  ", 1) 
                  Vertex = ReplaceString(Vertex, "  ", " ", 1, 1) 
               Wend 
               Vertex.s =  Right(lstlist(), Len(lstlist()) - found - 8)
            EndIf
          
            *pointer_Vertices\X_Pos = ValF(StringField(Vertex , 1, " "))
            *pointer_Vertices\Y_Pos = ValF(StringField(Vertex , 2, " "))
            *pointer_Vertices\Z_Pos = ValF(StringField(Vertex , 3, " "))
          
            *pointer_Normals\X_Pos = normal_nx.f
            *pointer_Normals\Y_Pos = normal_ny.f
            *pointer_Normals\Z_Pos = normal_nz.f

            *pointer_Vertices + 12
            *pointer_Normals + 12

          
            NextElement(lstlist()) 
            found = FindString(lstlist(), "vertex") 
          
            If found
               While FindString(Vertex, "  ", 1) 
                  Vertex = ReplaceString(Vertex, "  ", " ", 1, 1) 
               Wend 
               Vertex.s =  Right(lstlist(), Len(lstlist()) - found - 8) 
            EndIf
          
            *pointer_Vertices\X_Pos = ValF(StringField(Vertex , 1, " "))
            *pointer_Vertices\Y_Pos = ValF(StringField(Vertex , 2, " "))
            *pointer_Vertices\Z_Pos = ValF(StringField(Vertex , 3, " "))
          
            *pointer_Normals\X_Pos = normal_nx.f
            *pointer_Normals\Y_Pos = normal_ny.f
            *pointer_Normals\Z_Pos = normal_nz.f

            *pointer_Vertices + 12
            *pointer_Normals + 12

          NextElement(lstlist()) 
          
        EndIf
        
        NextElement(lstlist()) 
      Next
      ProcedureReturn Mesh()
    Else
      MessageRequester("ERROR!", "Failed to load the specified file. Please double check your file path.", #PB_MessageRequester_Ok)
      ProcedureReturn #False
    EndIf
  EndIf

  ProcedureReturn #False

EndProcedure

Procedure MP_LoadX(FilePath.s)
  
  Define Result.s,Vertices, CTR, EndPos, StartPos, Color.l, Vert.s, *pointer_Vertices.PosXYZ, *pointer_Normals.PosXYZ, Faces, *pointer_Indices.FTriangle, Face.s
  
  ;x.d, y.d, z.d
  OpenFile(0, FilePath.s)
  If IsFile(0) = 0
    MessageRequester("ERROR!", "Failed to load the specified file. Please double check your file path.", #PB_MessageRequester_Ok)
    ProcedureReturn #False
  EndIf
  
  AddElement(Mesh.MeshStruct())
  Mesh()\Meshscale\Sx = 1
  Mesh()\Meshscale\Sy = 1
  Mesh()\Meshscale\Sz = 1
  Mesh()\kind = 1         ; i am a mesh 
  
  Mesh()\ZEnable = 1

  AddElement(Mesh()\Texture())

  If ReadFile(0, FilePath.s)
    While Eof(0) = 0
      
      Result.s = ReadString(0)
      
      If Left(Trim(Result.s), 5) = "Mesh "

        Result.s = ReadString(0)
        
        Result.s = Trim(Result.s)
        Result.s = Trim(Result.s, ";")
        
        Vertices = Val(Result.s)
        
        Mesh()\Mesh\Vertices = AllocateMemory(Vertices * 3 * SizeOf(float))
        Mesh()\Mesh\Normals = AllocateMemory(Vertices * 3 * SizeOf(float))
        
        Mesh()\Mesh\Color = AllocateMemory(Vertices * SizeOf(long))
        Color.l = $646464
        FillMemory(Mesh()\Mesh\Color, Vertices * SizeOf(long),Color,#PB_Long )

        *pointer_Vertices.PosXYZ = Mesh()\Mesh\Vertices
        *pointer_Normals.PosXYZ = Mesh()\Mesh\Normals

        ;Collect vertex data
        For CTR = 1 To Vertices
            
          Result.s = Trim(ReadString(0))
            
          EndPos  = FindString(Result.s, ";", 0)
          Vert.s = Mid(Result.s, 0, EndPos - 1)
          *pointer_Vertices\X_Pos = ValF(Vert.s)
          *pointer_Normals\X_Pos = ValF(Vert.s) ; Only testing
          
          StartPos = EndPos
          EndPos   = FindString(Result.s, ";", StartPos + 1)
          Vert.s = Mid(Result.s, StartPos + 1, EndPos - StartPos - 1)
          *pointer_Vertices\Y_Pos = ValF(Vert.s)
          *pointer_Normals\Y_Pos = ValF(Vert.s) ; Only testing
 
          StartPos = EndPos
          EndPos   = FindString(Result.s, ";", StartPos + 1)
          Vert.s = Mid(Result.s, StartPos + 1, EndPos - StartPos - 1)
          *pointer_Vertices\Z_Pos = ValF(Vert.s)
           *pointer_Normals\Z_Pos = ValF(Vert.s) ; Only testing

          *pointer_Vertices + 12
          *pointer_Normals + 12
            
        Next
          
        Result.s = ReadString(0)
        
        Result.s = Trim(Result.s)
        Result.s = Trim(Result.s, ";")
        
        Faces = Val(Result.s)
        Mesh()\Mesh\Indices = AllocateMemory(Faces  * 3 * SizeOf(word))
        
        *pointer_Indices.FTriangle = Mesh()\Mesh\Indices
        
        ;Collect face data
        For CTR = 1 To Faces
            
          Result.s = Trim(ReadString(0))
          
          StartPos = FindString(Result.s, ";", 0)
          EndPos   = FindString(Result.s, ",", StartPos)
          Face.s = Mid(Result.s, StartPos + 1, EndPos - StartPos - 1)
          *pointer_Indices\f1 = Val(Face.s)

          StartPos = EndPos
          EndPos   = FindString(Result.s, ",", StartPos + 1)
          Face.s = Mid(Result.s, StartPos + 1, EndPos - StartPos - 1)
          *pointer_Indices\f2 = Val(Face.s)
          
          StartPos = EndPos
          EndPos   = FindString(Result.s, ";", StartPos + 1)
          Face.s = Mid(Result.s, StartPos + 1, EndPos - StartPos - 1)
          
          *pointer_Indices\f3 = Val(Face.s)
          *pointer_Indices + 6
          
        Next
        
        Continue
      EndIf
      
    Wend
    CloseFile(0)
  Else
    DeleteElement(Mesh())
    MessageRequester("ERROR!", "Failed to read the specified file.", #PB_MessageRequester_Ok)
     ProcedureReturn #False
  EndIf

  If Vertices < 3
    If Mesh()\Mesh\Vertices : FreeMemory(Mesh()\Mesh\Vertices) : EndIf
    If Mesh()\Mesh\Indices : FreeMemory(Mesh()\Mesh\Indices)   : EndIf
    DeleteElement(Mesh())
    MessageRequester("ERROR!", "There needs to be at least three vertices in order to create the mesh.", #PB_MessageRequester_Ok)
    ProcedureReturn #False
  EndIf
  
  If Faces < 1
    If Mesh()\Mesh\Vertices : FreeMemory(Mesh()\Mesh\Vertices) : EndIf
    If Mesh()\Mesh\Indices : FreeMemory(Mesh()\Mesh\Indices)   : EndIf
    DeleteElement(Mesh())
    MessageRequester("ERROR!", "There needs te ba at least one face in order to create the mesh.", #PB_MessageRequester_Ok)
    ProcedureReturn #False
  EndIf

  ProcedureReturn Mesh()
  
EndProcedure

ProcedureDLL MP_LoadMesh(File.s) ; ; Load mesh as Directx, 3ds, B3d or stl file
  
    Define Part.s
  
    Part.s = UCase(GetExtensionPart(File.s))
    If Part = "X"
        ProcedureReturn MP_LoadX( File.s )
    ;ElseIf Part = "3DS"
    ;    ProcedureReturn MP_Load3ds( File.s )
    ;ElseIf Part = "B3D"
    ;    ProcedureReturn MP_LoadB3D( File.s )
    ElseIf Part = "STL"
       ProcedureReturn MP_Loadstl( File.s)
    ;Else   
       ;ProcedureReturn #False
    EndIf

EndProcedure 

ProcedureDLL MP_CreateMesh () ; Leeres Entity erzeugt
 
  AddElement(Mesh.MeshStruct())
  Mesh()\Meshscale\Sx = 1
  Mesh()\Meshscale\Sy = 1
  Mesh()\Meshscale\Sz = 1
  Mesh()\kind = 1         ; i am a mesh 
  Mesh()\ZEnable = 1
  Mesh()\Blendmode1 = #GL_ONE
  Mesh()\Blendmode2 = #GL_ONE
       
  AddElement(Mesh()\Texture())

  ProcedureReturn Mesh()

EndProcedure

Procedure MP_AddVertex_all ( Entity ,x.f,y.f,z.f,u.f,v.f,Color.l,nx.f,ny.f,nz.f, key) ; Add a vertex To an entity 
  
    Define Vertices, Normals, Colormem, Texcoords, *Vertices.PosXYZ, *Texcoords.PosXY, *Color.long, *Normals.PosXYZ
  
    ForEach Mesh()
      If Mesh() = Entity
        If Mesh()\Mesh\Vertices
          Vertices = MemorySize(Mesh()\Mesh\Vertices)
          Mesh()\Mesh\Vertices = ReAllocateMemory(Mesh()\Mesh\Vertices,Vertices + 3 * SizeOf(float))
          If key
             Normals = MemorySize(Mesh()\Mesh\Normals)
             Mesh()\Mesh\Normals = ReAllocateMemory(Mesh()\Mesh\Normals, Normals + 3 * SizeOf(float))
          EndIf   
          Colormem = MemorySize(Mesh()\Mesh\Color)
          Mesh()\Mesh\Color = ReAllocateMemory(Mesh()\Mesh\Color, Colormem + SizeOf(long))
          Texcoords = MemorySize(Mesh()\Mesh\Texcoords)
          Mesh()\Mesh\Texcoords = ReAllocateMemory(Mesh()\Mesh\Texcoords, Texcoords +2 * SizeOf(float))
        Else  
          Mesh()\Mesh\Vertices = AllocateMemory(3 * SizeOf(float))
          If key : Mesh()\Mesh\Normals = AllocateMemory(3 * SizeOf(float)) : EndIf
          Mesh()\Mesh\Color = AllocateMemory(SizeOf(long))
          Mesh()\Mesh\Texcoords = AllocateMemory( 2 * SizeOf(float))
        EndIf  
        
        *Vertices.PosXYZ = (Mesh()\Mesh\Vertices + MemorySize(Mesh()\Mesh\Vertices)) - (3 * SizeOf(float))
        *Vertices\X_Pos = x :  *Vertices\Y_Pos = y : *Vertices\Z_Pos = z
        
        *Texcoords.PosXY = Mesh()\Mesh\Texcoords + MemorySize(Mesh()\Mesh\Texcoords) - 2 * SizeOf(float)
        *Texcoords\X_Pos = u : *Texcoords\Y_Pos = v
        
        *Color.long = Mesh()\Mesh\Color + MemorySize(Mesh()\Mesh\Color) - SizeOf(long)
        *Color\l =  Color
        
        If key
          *Normals.PosXYZ = Mesh()\Mesh\Normals + MemorySize(Mesh()\Mesh\Normals) - 3 * SizeOf(float)
          *Normals\X_Pos = nx :  *Normals\Y_Pos = ny : *Normals\Z_Pos = nz
        EndIf 
      
        ProcedureReturn #True
    EndIf
  Next
  ProcedureReturn #False
  
EndProcedure

ProcedureDLL MP_AddVertex ( Entity ,x.f,y.f,z.f,u.f,v.f,Color.l) ; Add a vertex To an entity 
  
  ProcedureReturn  MP_AddVertex_all ( Entity ,x.f,y.f,z.f,u.f,v.f,Color.l,0,0,0,0)
  
EndProcedure

ProcedureDLL MP_AddVertex2 ( Entity ,x.f,y.f,z.f,u.f,v.f,Color.l,nx.f,ny.f,nz.f) ; Add a vertex To an entity 
  
  ProcedureReturn  MP_AddVertex_all  ( Entity ,x.f,y.f,z.f,u.f,v.f,Color.l,nx.f,ny.f,nz.f, 1) 
  
EndProcedure

ProcedureDLL MP_AddTriangle ( Entity,f1,f2,f3) ; Add a triangle to an entity  
  
  Define Indices, *Indices.FTriangle
  
  ForEach Mesh()
    If Mesh() = Entity
      If Mesh()\Mesh\Indices
        Indices = MemorySize(Mesh()\Mesh\Indices)
        Mesh()\Mesh\Indices = ReAllocateMemory(Mesh()\Mesh\Indices, Indices + 3 * SizeOf(word))
      Else  
        Mesh()\Mesh\Vertices = AllocateMemory(3 * SizeOf(word))
      EndIf  
       *Indices.FTriangle = Mesh()\Mesh\Indices + MemorySize(Mesh()\Mesh\Indices) -  3 * SizeOf(word)
       *Indices\f1 = f1 : *Indices\f2 = f2 : *Indices\f3 = f3
      
       ProcedureReturn #True
    EndIf
  Next
  ProcedureReturn #False    
          
EndProcedure

ProcedureDLL MP_CreateCube()
  
  Define Color.l 
  
  AddElement(Mesh.MeshStruct())
  Mesh()\Meshscale\Sx = 1
  Mesh()\Meshscale\Sy = 1
  Mesh()\Meshscale\Sz = 1
  Mesh()\kind = 1         ; i am a mesh 
  Mesh()\Blendmode1 = #GL_SRC_ALPHA
  Mesh()\Blendmode2 = #GL_ONE_MINUS_SRC_ALPHA

  Mesh()\ZEnable = 1

  AddElement(Mesh()\Texture())
  
  Mesh()\Mesh\Vertices = AllocateMemory(6 * 4 * 3 * SizeOf(float))
  CopyMemory(?VerticesData, Mesh()\Mesh\Vertices, 6 * 4 * 3 * SizeOf(float))
  
  Color.l = $646464 
  Mesh()\Mesh\Color = AllocateMemory(6  * 4 * SizeOf(long))
  FillMemory(Mesh()\Mesh\Color, 6 * 4 * SizeOf(long),Color,#PB_Long )
  
  Mesh()\Mesh\Indices = AllocateMemory(12  * 3 * SizeOf(word))
  CopyMemory(?IndicesData, Mesh()\Mesh\Indices, 12  * 3 * SizeOf(word))

  Mesh()\Mesh\Normals = AllocateMemory( 6 * 4 * 3 * SizeOf(float))
  CopyMemory(?NormalsData, Mesh()\Mesh\Normals, 6 * 4 * 3 * SizeOf(float))
  
  Mesh()\Mesh\Texcoords = AllocateMemory(6 * 4 * 2 * SizeOf(float))
  CopyMemory(?TexcoordsData, Mesh()\Mesh\Texcoords, 6 * 4 * 2 * SizeOf(float))
  
  ProcedureReturn Mesh()
  
  DataSection
    VerticesData: 
      Data.f -0.5,-0.5,-0.5,   -0.5,-0.5,0.5,   -0.5,0.5,0.5,   -0.5,0.5,-0.5
      Data.f -0.5,0.5,-0.5,    -0.5,0.5,0.5,    0.5,0.5,0.5,    0.5,0.5,-0.5
      Data.f 0.5,0.5,-0.5,     0.5,0.5,0.5,     0.5,-0.5,0.5,   0.5,-0.5,-0.5
      Data.f -0.5,-0.5,0.5,    -0.5,-0.5,-0.5,  0.5,-0.5,-0.5,  0.5,-0.5,0.5
      Data.f -0.5,-0.5,0.5,    0.5,-0.5,0.5,    0.5,0.5,0.5,    -0.5,0.5,0.5
      Data.f -0.5,-0.5,-0.5,   -0.5,0.5,-0.5,   0.5,0.5,-0.5,   0.5,-0.5,-0.5      
    IndicesData: 
      Data.w  0,1,2,         2,3,0,          4,5,6,         6,7,4
      Data.w  8,9,10,        10,11,8,        12,13,14,      14,15,12
      Data.w  16,17,18,      18,19,16,       20,21,22,      22,23,20
    NormalsData:
      Data.f -1,0,0,  -1,0,0,  -1,0,0,  -1,0,0
      Data.f 0,1,0,  0,1,0,  0,1,0,  0,1,0
      Data.f 1,0,0,  1,0,0,  1,0,0,  1,0,0
      Data.f 0,-1,0, 0,-1,0, 0,-1,0, 0,-1,0
      Data.f 0,0,1, 0,0,1, 0,0,1, 0,0,1
      Data.f 0,0,-1, 0,0,-1, 0,0,-1, 0,0,-1
    TexcoordsData:
      Data.f 1, 1,  0, 1,  0, 0,  1, 0 
      Data.f 0, 1,  0, 0,  1, 0,  1, 1
      Data.f 0, 0,  1, 0,  1, 1,  0, 1
      Data.f 0, 1,  0, 0,  1, 0,  1, 1
      Data.f 1, 1,  0, 1,  0, 0,  1, 0
      Data.f 0, 1,  0, 0,  1, 0,  1, 1
  EndDataSection
  
EndProcedure

ProcedureDLL MP_CreateRectangle (Width.f,Height.f,Depth.f)
  
  Define *mesh.MeshStruct, n
  
  *mesh.MeshStruct = MP_CreateCube()
  
  For n = 0 To (6 * 4 * 3 * SizeOf(float))-1 Step SizeOf(float)*3
    PokeF(*mesh\Mesh\Vertices+n, PeekF(*Mesh\Mesh\Vertices+n)*Width)
    PokeF(*Mesh\Mesh\Vertices+n+4, PeekF(*Mesh\Mesh\Vertices+n+4)*Height)
    PokeF(*Mesh\Mesh\Vertices+n+8, PeekF(*Mesh\Mesh\Vertices+n+8)*Depth)
  Next n   
  
  ProcedureReturn *Mesh
  
EndProcedure

ProcedureDLL MP_CreatePyramid (Width.f, Height.f, Depth.f) 
  
  Define n, Color.l
  
  AddElement(Mesh.MeshStruct())
  Mesh()\Meshscale\Sx = 1
  Mesh()\Meshscale\Sy = 1
  Mesh()\Meshscale\Sz = 1
  Mesh()\kind = 1         ; i am a mesh 
  Mesh()\Blendmode1 = #GL_SRC_ALPHA
  Mesh()\Blendmode2 = #GL_ONE_MINUS_SRC_ALPHA
  Mesh()\Blendmode1 = #GL_SRC_ALPHA
  Mesh()\Blendmode2 = #GL_ONE_MINUS_SRC_ALPHA

  Mesh()\ZEnable = 1

  AddElement(Mesh()\Texture())
  
  Width = Width / 2
  Depth = Depth / 2
  
  Mesh()\Mesh\Vertices = AllocateMemory(18 * 3 * SizeOf(float))
  CopyMemory(?VerticesData, Mesh()\Mesh\Vertices, 18 * 3 * SizeOf(float))
  
  For n = 0 To (18 * 3 * SizeOf(float))-1 Step SizeOf(float)*3 ; Change Width.f, Height.f, Depth.f of Pyramid
    PokeF(Mesh()\Mesh\Vertices+n, PeekF(Mesh()\Mesh\Vertices+n)*Width)
    PokeF(Mesh()\Mesh\Vertices+n+4, PeekF(Mesh()\Mesh\Vertices+n+4)*Height)
    PokeF(Mesh()\Mesh\Vertices+n+8, PeekF(Mesh()\Mesh\Vertices+n+8)*Depth)
  Next n  
  
  Color.l = $646464
  Mesh()\Mesh\Color = AllocateMemory(18 * SizeOf(long))
  FillMemory(Mesh()\Mesh\Color,18 * SizeOf(long),Color,#PB_Long )
  
  Mesh()\Mesh\Indices = AllocateMemory(6 * 3 * SizeOf(word))
  CopyMemory(?IndicesData, Mesh()\Mesh\Indices, 6 * 3 * SizeOf(word))
  
  Mesh()\Mesh\Normals = AllocateMemory(18 * 3 * SizeOf(float))
  CopyMemory(?VerticesData, Mesh()\Mesh\Normals ,18 * 3  * SizeOf(float))

  Mesh()\Mesh\Texcoords = AllocateMemory(18 * 2 * SizeOf(float))
  CopyMemory(?TexcoordsData, Mesh()\Mesh\Texcoords, 18 * 2 * SizeOf(float))
  
  ProcedureReturn Mesh()
  
DataSection
    VerticesData: 
      Data.f  -0.5, 0, -0.5
      Data.f  0.5, 0, -0.5
      Data.f  0.5, 0, 0.5
      Data.f  -0.5, 0, -0.5
      Data.f  0.5, 0, 0.5
      Data.f  -0.5, 0, 0.5
      Data.f  -0.5, 0, -0.5
      Data.f  0.5, 0, -0.5
      Data.f  0, 1, 0 
      Data.f  0.5, 0, -0.5
      Data.f  0.5, 0, 0.5 
      Data.f  0, 1, 0 
      Data.f  0.5, 0, 0.5 
      Data.f  -0.5, 0, 0.5 
      Data.f  0, 1, 0 
      Data.f  -0.5, 0, 0.5
      Data.f  -0.5, 0, -0.5
      Data.f  0, 1, 0 
    IndicesData: 
      Data.w  0,1,2,     3,4,5,     6,7,8
      Data.w  9,10,11,  12,13,14,  15,16,17
    NormalsData:
     ;Data.f  
    TexcoordsData:
      Data.f 0, 0 
      Data.f 1, 0
      Data.f 1, 1
      
      Data.f 0, 0
      Data.f 1, 1
      Data.f 0, 1 
      
      Data.f 0, 0
      Data.f 1, 0
      Data.f 0.5, 1
      
      Data.f 0, 0 
      Data.f 1, 0
      Data.f 0.5, 1
      
      Data.f 0, 0
      Data.f 1, 0
      Data.f 0.5, 1 
      
      Data.f 0, 0
      Data.f 1, 0
      Data.f 0.5, 1
    EndDataSection
  
EndProcedure

ProcedureDLL MP_CreateSphere (Slices)    
  
  Define ndiv, nvert, nfac, ph.f, th.f, da.f, r.f, Vnd, Tnd, ind, Color.l, i, j, x.f, y.f, z.f, n, d 
  
  AddElement(Mesh.MeshStruct())
  Mesh()\Meshscale\Sx = 1
  Mesh()\Meshscale\Sy = 1
  Mesh()\Meshscale\Sz = 1
  Mesh()\kind = 1         ; i am a mesh 
  Mesh()\Blendmode1 = #GL_SRC_ALPHA
  Mesh()\Blendmode2 = #GL_ONE_MINUS_SRC_ALPHA

  Mesh()\ZEnable = 1

  AddElement(Mesh()\Texture())
  
  ; Thanks to Comtois for the code i got this some years ago
  ndiv = Slices; // nombre de decoupage pour un demi-cercle
	nvert = (ndiv+1)*((2*ndiv)+1);
	nfac = (ndiv-2)*(4*ndiv)  + (4 * ndiv);
  
	ph.f=-#PI/2 : da.f = #PI/ndiv : r.f =0.7 : Vnd = 0 : Tnd = 0 : ind = 0 
	
	Mesh()\Mesh\Vertices = AllocateMemory(nvert * 3 * SizeOf(float))
	
	Color.l = $646464
	Mesh()\Mesh\Color = AllocateMemory(nvert * SizeOf(long))
	FillMemory(Mesh()\Mesh\Color,nvert * SizeOf(long),Color,#PB_Long )  
	
	Mesh()\Mesh\Normals = AllocateMemory(nvert * 3 * SizeOf(float))
	Mesh()\Mesh\Texcoords = AllocateMemory(nvert * 2 * SizeOf(float))
   
  Color.l = $646464
  For i = 0 To ndiv
	  th=0
		For j=0 To 2*ndiv
		  
		  x.f = r*Cos(th)*Cos(ph)
		  y.f = r*Sin(th)*Cos(ph)
		  z.f = r*Sin(ph)
		  
      PokeF(Mesh()\Mesh\Vertices + Vnd, r*x)
      PokeF(Mesh()\Mesh\Vertices + Vnd+4, r*y)
      PokeF(Mesh()\Mesh\Vertices + Vnd+8, r*z)
      PokeF(Mesh()\Mesh\Normals + Vnd, x)
      PokeF(Mesh()\Mesh\Normals + Vnd+4, y)
      PokeF(Mesh()\Mesh\Normals + Vnd+8, z)
      PokeF(Mesh()\Mesh\Texcoords + Tnd, j/(2*ndiv))
      PokeF(Mesh()\Mesh\Texcoords + Tnd + 4, (ndiv-i/ndiv)-ndiv+1)
      Tnd + 8
      Vnd + 12
      th+da
		  
		Next
	  ph+da
  Next
  
  Mesh()\Mesh\Indices = AllocateMemory(nfac * 3 * SizeOf(word))
  
  n=2*ndiv;
  ind.i=0
  
  For j=0 To n-1
    	PokeW(Mesh()\Mesh\Indices+ind, d+n+1+j)
     	PokeW(Mesh()\Mesh\Indices+ind+2, d+j)
     	PokeW(Mesh()\Mesh\Indices+ind+4, d+n+1+j+1)
     	ind + 6
  Next
  d+n+1;
  For i=0 To ndiv-3
    For j=0 To n-1
       PokeW(Mesh()\Mesh\Indices+ind, d+n+1+j)
     	 PokeW(Mesh()\Mesh\Indices+ind+2, d+j)
     	 PokeW(Mesh()\Mesh\Indices+ind+4, d+n+1+j+1)
     	 ind + 6
 			 PokeW(Mesh()\Mesh\Indices+ind, d+n+1+j+1)
   		 PokeW(Mesh()\Mesh\Indices+ind+2, d+j)
  		 PokeW(Mesh()\Mesh\Indices+ind+4, d+j+1)
  		 ind + 6
    Next
	  d+n+1
	Next   	
 		
	For j=0 To n-1
	    PokeW(Mesh()\Mesh\Indices+ind, d+n+1+j+1)
	    PokeW(Mesh()\Mesh\Indices+ind+2, d+j)
	    PokeW(Mesh()\Mesh\Indices+ind+4, d+j+1)
	    ind + 6
	Next
	  
  ProcedureReturn Mesh()

EndProcedure
  
ProcedureDLL MP_CreateCylinder (radius.f, height.f)
  
   Define m, radius2.f, Color.l, i, h2.f, NbSommet, *pointer_Vertices.PosXYZ, *pointer_Normals.PosXYZ, *pointer_Texcoords.PosXY, theta.f, NbTriangle, *pointer_Indices.FTriangle 
  
   AddElement(Mesh.MeshStruct())
   Mesh()\Meshscale\Sx = 1
   Mesh()\Meshscale\Sy = 1
   Mesh()\Meshscale\Sz = 1
   Mesh()\kind = 1         ; i am a mesh 
   Mesh()\Blendmode1 = #GL_SRC_ALPHA
   Mesh()\Blendmode2 = #GL_ONE_MINUS_SRC_ALPHA

   Mesh()\ZEnable = 1

   AddElement(Mesh()\Texture())
   
   m = 16
   radius2.f = radius / 2.0
   h2.f = height / 2.0
   NbSommet = 4*(m+1)+2
   
   Mesh()\Mesh\Vertices = AllocateMemory(NbSommet * 3 * SizeOf(float))
   
   Color.l = $646464
   Mesh()\Mesh\Color = AllocateMemory(NbSommet * SizeOf(long))
   FillMemory(Mesh()\Mesh\Color,NbSommet * SizeOf(long),Color,#PB_Long )  
   
   Mesh()\Mesh\Normals = AllocateMemory(NbSommet * 3 * SizeOf(float))
   Mesh()\Mesh\Texcoords = AllocateMemory(NbSommet * 2 * SizeOf(float))
   
   *pointer_Vertices.PosXYZ = Mesh()\Mesh\Vertices
   *pointer_Normals.PosXYZ = Mesh()\Mesh\Normals
   *pointer_Texcoords.PosXY = Mesh()\Mesh\Texcoords
   
   ;Gipfel am unteren Ende des Zylinders

   For i = 0 To m
      theta.f =2*#PI*i/m
      *pointer_Vertices\X_Pos = Cos(theta) * radius2
      *pointer_Vertices\Y_Pos = -h2
      *pointer_Vertices\Z_Pos = Sin(theta) * radius2
      *pointer_Normals\X_Pos = Cos(theta)
      *pointer_Normals\Y_Pos = 0
      *pointer_Normals\Z_Pos =  Sin(theta)
      *pointer_Texcoords\X_Pos = Theta / (2.0*#PI)
      *pointer_Texcoords\Y_Pos = 0
      *pointer_Vertices + 12
      *pointer_Normals + 12
      *pointer_Texcoords + 8
   Next i   

   ;Gipfel am oberen Ende des Zylinders
   For i = 0 To m
      theta.f =2*#PI*i/m
      *pointer_Vertices\X_Pos = Cos(theta) * radius2
      *pointer_Vertices\Y_Pos = h2
      *pointer_Vertices\Z_Pos = Sin(theta) * radius2
      *pointer_Normals\X_Pos =  Cos(theta)
      *pointer_Normals\Y_Pos = 0
      *pointer_Normals\Z_Pos = Sin(theta)
      *pointer_Texcoords\X_Pos = Theta / (2.0*#PI)
      *pointer_Texcoords\Y_Pos = 1
      *pointer_Vertices + 12
      *pointer_Normals + 12
      *pointer_Texcoords + 8
   Next i
      
   ;Scheitelpunkt untere Seite des Zylinders
   For i = 0 To m
      theta.f =2*#PI*i/m
       
      *pointer_Vertices\X_Pos = Cos(theta) * radius2
      *pointer_Vertices\Y_Pos = -h2
      *pointer_Vertices\Z_Pos = Sin(theta) * radius2
      *pointer_Normals\X_Pos = 0
      *pointer_Normals\Y_Pos = -1
      *pointer_Normals\Z_Pos = 0
      *pointer_Texcoords\X_Pos = Theta / (2.0*#PI)
      *pointer_Texcoords\Y_Pos = 1
      *pointer_Vertices + 12
      *pointer_Normals + 12
      *pointer_Texcoords + 8
   Next i
             
   ;Gipfel obere Seite des Zylinders
   For i = 0 To m
      theta.f =2*#PI*i/m
       
      *pointer_Vertices\X_Pos = Cos(theta) * radius2
      *pointer_Vertices\Y_Pos = h2
      *pointer_Vertices\Z_Pos = Sin(theta) * radius2
      *pointer_Normals\X_Pos = 0
      *pointer_Normals\Y_Pos = 1
      *pointer_Normals\Z_Pos = 0
      *pointer_Texcoords\X_Pos = Theta / (2.0*#PI)
      *pointer_Texcoords\Y_Pos = 1
      *pointer_Vertices + 12
      *pointer_Normals + 12
      *pointer_Texcoords + 8
   Next i
   
   ;Untere Mitte
   *pointer_Vertices\X_Pos = 0
   *pointer_Vertices\Y_Pos = -h2
   *pointer_Vertices\Z_Pos = 0
   *pointer_Normals\X_Pos = 0
   *pointer_Normals\Y_Pos = -1
   *pointer_Normals\Z_Pos = 0
   *pointer_Texcoords\X_Pos = 0.5
   *pointer_Texcoords\Y_Pos = 0.5
   *pointer_Vertices + 12
   *pointer_Normals + 12
   *pointer_Texcoords + 8
   ;Obere Mitte
   *pointer_Vertices\X_Pos = 0
   *pointer_Vertices\Y_Pos = h2
   *pointer_Vertices\Z_Pos = 0
   *pointer_Normals\X_Pos = 0
   *pointer_Normals\y_Pos = 1
   *pointer_Normals\z_Pos = 0
   *pointer_Texcoords\X_Pos = 0.5
   *pointer_Texcoords\X_Pos = 0.5
   
   ;Die Facetten
   NbTriangle = 4*m
   Mesh()\Mesh\Indices = AllocateMemory(NbTriangle * 3 * SizeOf(word))
   
   *pointer_Indices.FTriangle = Mesh()\Mesh\Indices

   For i=0 To m-1
      *pointer_Indices\f3=i
      *pointer_Indices\f2=i + 1
      *pointer_Indices\f1=m + i + 2
      *pointer_Indices+6
      *pointer_Indices\f1=i 
      *pointer_Indices\f3=m + i + 2
      *pointer_Indices\f2=m + i + 1
      *pointer_Indices+6
   Next i
   
   ;Niedrige Seite
   For i=0 To m-1
      *pointer_Indices\f1= 4 * m + 4
      *pointer_Indices\f2= 2 * m + 2 + i
      *pointer_Indices\f3= 2 * m + 3 + i
      *pointer_Indices+6
   Next i      
   
   ;Seite Hoch 
   For i=0 To m-1
      *pointer_Indices\f1= 4 * m + 5
      *pointer_Indices\f3= 3 * m + 3 + i
      *pointer_Indices\f2= 3 * m + 4 + i
      *pointer_Indices+6
   Next i   
   
   ProcedureReturn Mesh()
        
EndProcedure

ProcedureDLL MP_CreateOpenCylinder (radius.f, height.f)
  
  Define m, radius2.f, Color.l, i, h2.f, NbSommet, *pointer_Vertices.PosXYZ, *pointer_Normals.PosXYZ, *pointer_Texcoords.PosXY, Vnd.l, Tnd.l, theta.f, NbTriangle, *pointer_Indices.FTriangle 
   
   AddElement(Mesh.MeshStruct())
   Mesh()\Meshscale\Sx = 1
   Mesh()\Meshscale\Sy = 1
   Mesh()\Meshscale\Sz = 1
   Mesh()\kind = 1         ; i am a mesh 
   Mesh()\Blendmode1 = #GL_SRC_ALPHA
   Mesh()\Blendmode2 = #GL_ONE_MINUS_SRC_ALPHA
 
   Mesh()\ZEnable = 1

   AddElement(Mesh()\Texture())
   
   m = 16
   radius2.f = radius / 2.0
   h2.f = height / 2.0
   NbSommet = 4*(m+1)+2
   
   Mesh()\Mesh\Vertices = AllocateMemory(NbSommet * 3 * SizeOf(float))
   
   Color.l = $646464
   Mesh()\Mesh\Color = AllocateMemory(NbSommet * SizeOf(long))
   FillMemory(Mesh()\Mesh\Color,NbSommet * SizeOf(long),Color,#PB_Long )  

   Mesh()\Mesh\Normals = AllocateMemory(NbSommet * 3 * SizeOf(float))
   Mesh()\Mesh\Texcoords = AllocateMemory(NbSommet * 2 * SizeOf(float))
   
   *pointer_Vertices.PosXYZ = Mesh()\Mesh\Vertices
   *pointer_Normals.PosXYZ = Mesh()\Mesh\Normals
   *pointer_Texcoords.PosXY = Mesh()\Mesh\Texcoords
   
   ;Gipfel am unteren Ende des Zylinders
   
   
   Vnd.l = 0
   Tnd.l = 0

   For i = 0 To m
      theta.f =2*#PI*i/m
      *pointer_Vertices\X_Pos = Cos(theta) * radius2
      *pointer_Vertices\Y_Pos = -h2
      *pointer_Vertices\Z_Pos = Sin(theta) * radius2
      *pointer_Normals\X_Pos = Cos(theta)
      *pointer_Normals\Y_Pos = 0
      *pointer_Normals\Z_Pos =  Sin(theta)
      *pointer_Texcoords\X_Pos = Theta / (2.0*#PI)
      *pointer_Texcoords\Y_Pos = 0
      *pointer_Vertices + 12
      *pointer_Normals + 12
      *pointer_Texcoords + 8
   Next i   
   
   ;Gipfel am oberen Ende des Zylinders
   For i = 0 To m
      theta.f =2*#PI*i/m
  ;     
      *pointer_Vertices\X_Pos = Cos(theta) * radius2
      *pointer_Vertices\Y_Pos = h2
      *pointer_Vertices\Z_Pos = Sin(theta) * radius2
      *pointer_Normals\X_Pos =  Cos(theta)
      *pointer_Normals\Y_Pos = 0
      *pointer_Normals\Z_Pos = Sin(theta)
      *pointer_Texcoords\X_Pos = Theta / (2.0*#PI)
      *pointer_Texcoords\Y_Pos = 1
      *pointer_Vertices + 12
      *pointer_Normals + 12
      *pointer_Texcoords + 8
   Next i
      
   ;Scheitelpunkt untere Seite des Zylinders
   For i = 0 To m
      theta.f =2*#PI*i/m
       
      *pointer_Vertices\X_Pos = Cos(theta) * radius2
      *pointer_Vertices\Y_Pos = -h2
      *pointer_Vertices\Z_Pos = Sin(theta) * radius2
      *pointer_Normals\X_Pos = 0
      *pointer_Normals\Y_Pos = -1
      *pointer_Normals\Z_Pos = 0
      *pointer_Texcoords\X_Pos = Theta / (2.0*#PI)
      *pointer_Texcoords\Y_Pos = 1
      *pointer_Vertices + 12
      *pointer_Normals + 12
      *pointer_Texcoords + 8
   Next i
             
   ;Gipfel obere Seite des Zylinders
   For i = 0 To m
      theta.f =2*#PI*i/m
       
      *pointer_Vertices\X_Pos = Cos(theta) * radius2
      *pointer_Vertices\Y_Pos = h2
      *pointer_Vertices\Z_Pos = Sin(theta) * radius2
      *pointer_Normals\X_Pos = 0
      *pointer_Normals\Y_Pos = 1
      *pointer_Normals\Z_Pos = 0
      *pointer_Texcoords\X_Pos = Theta / (2.0*#PI)
      *pointer_Texcoords\Y_Pos = 1
      *pointer_Vertices + 12
      *pointer_Normals + 12
      *pointer_Texcoords + 8
   Next i
   
   ;Untere Mitte
   *pointer_Vertices\X_Pos = 0
   *pointer_Vertices\Y_Pos = -h2
   *pointer_Vertices\Z_Pos = 0
   *pointer_Normals\X_Pos = 0
   *pointer_Normals\Y_Pos = -1
   *pointer_Normals\Z_Pos = 0
   *pointer_Texcoords\X_Pos = 0.5
   *pointer_Texcoords\Y_Pos = 0.5
   *pointer_Vertices + 12
   *pointer_Normals + 12
   *pointer_Texcoords + 8
   ;Obere Mitte
   *pointer_Vertices\X_Pos = 0
   *pointer_Vertices\Y_Pos = h2
   *pointer_Vertices\Z_Pos = 0
   *pointer_Normals\X_Pos = 0
   *pointer_Normals\y_Pos = 1
   *pointer_Normals\z_Pos = 0
   *pointer_Texcoords\X_Pos = 0.5
   *pointer_Texcoords\X_Pos = 0.5
   
   ;Die Facetten
   NbTriangle = 2*m
   Mesh()\Mesh\Indices = AllocateMemory(NbTriangle * 3 * SizeOf(word))
   
   *pointer_Indices.FTriangle = Mesh()\Mesh\Indices
   
   For i=0 To m-1
      *pointer_Indices\f3=i
      *pointer_Indices\f2=i + 1
      *pointer_Indices\f1=m + i + 2
      *pointer_Indices+6
      *pointer_Indices\f1=i 
      *pointer_Indices\f3=m + i + 2
      *pointer_Indices\f2=m + i + 1
      *pointer_Indices+6
   Next i
   
   ProcedureReturn Mesh()
        
EndProcedure

ProcedureDLL MP_CountTriangles(Entity) ; Number of triangles of an entity
        
  ForEach Mesh()
     If Mesh() = Entity
       ProcedureReturn  MemorySize(Mesh()\Mesh\Indices)/2
     EndIf
  Next
   
EndProcedure

ProcedureDLL MP_CountVertices(Entity) ; Number of vertexes of an entity
        
  ForEach Mesh()
    If Mesh() = Entity
      ProcedureReturn MemorySize(Mesh()\Mesh\Vertices)/12
    EndIf
  Next
   
EndProcedure

Procedure MP_RenderMeshSingle (Mesh) ; Render only one mesh
  
    Define *pointer.MeshStruct, Indices_count
  
    ;Debug mesh
    *pointer.MeshStruct = Mesh
    
     If *pointer\Mesh

       If *pointer\m_Hide = 1
          ProcedureReturn #False
       EndIf
       
       glLoadIdentity_();
       ;Position
       glTranslatef_(*pointer\MeshPosition\X_Pos, *pointer\MeshPosition\Y_Pos, *pointer\MeshPosition\Z_Pos)
       
       ;Rotation
       glRotatef_ (*pointer\MeshGrad\XGrad , 1.0, 0.0, 0.0);
       glRotatef_ (*pointer\MeshGrad\YGrad , 0.0, 1.0, 0.0);
       glRotatef_ (*pointer\MeshGrad\ZGrad , 0.0, 1.0, 1.0);
       
       glRotatef_ (*pointer\MeshGrad2\XGrad, 1.0, 0.0, 0.0);
       glRotatef_ (*pointer\MeshGrad2\YGrad, 0.0, 1.0, 0.0);
       glRotatef_ (*pointer\MeshGrad2\ZGrad, 0.0, 1.0, 1.0);
       
       If *pointer\Texture() = 0 ; Keine Textur vorhanden
         
         If *pointer\Mesh\Vertices : glEnableClientState_(#GL_VERTEX_ARRAY) : glVertexPointer_(3, #GL_FLOAT, 0, *pointer\Mesh\Vertices) : EndIf
         If *pointer\Mesh\Normals  : glEnableClientState_(#GL_NORMAL_ARRAY) : glNormalPointer_(#GL_FLOAT, 0,  *pointer\Mesh\Normals) : EndIf
         If *pointer\Mesh\Color    : glEnableClientState_(#GL_COLOR_ARRAY)  : glColorPointer_(4, #GL_UNSIGNED_BYTE, 0,  *pointer\Mesh\Color) : EndIf
         
         glDisable_(#GL_TEXTURE_2D)    ; Disable texture mapping 
         glColorMaterial_(#GL_FRONT,#GL_AMBIENT) 
         glEnable_(#GL_COLOR_MATERIAL) ;Enable Material Coloring 
         
         If *pointer\Alphamode = 1
            glAlphaFunc_(#GL_GREATER, 0.1)
            glEnable_(#GL_ALPHA_TEST )
         ElseIf  *pointer\Alphamode = 2   
            ;glBlendFunc_(*pointer\Blendmode1, *pointer\Blendmode2);          // Enable Alpha Blending (disable alpha testing)
            glBlendFunc_(#GL_ONE,#GL_ONE);       // Blending Function For Translucency Based On Source allcolour
            glEnable_(#GL_BLEND)
         EndIf
          
         
         If *pointer\Mesh\Indices
            Indices_count = MemorySize(*pointer\Mesh\Indices)/2 ; word
            glDrawElements_(#GL_TRIANGLES,Indices_count,#GL_UNSIGNED_SHORT, *pointer\Mesh\Indices);
         ElseIf *pointer\Mesh\Vertices
            glDrawArrays_(#GL_TRIANGLES, 0, MemorySize(*pointer\Mesh\Vertices)/SizeOf(float)/3)
         EndIf  
            
         glDisableClientState_(#GL_VERTEX_ARRAY);
         glDisableClientState_(#GL_COLOR_ARRAY);
         glDisableClientState_(#GL_NORMAL_ARRAY);
   
                 
     Else ; Textur vorhanden
        ; ForEach *pointer\Texture() : isTexture.i = PeekI(*pointer\Texture()) : Next ; Multitexture TODO

        If *pointer\Mesh\Vertices : glEnableClientState_(#GL_VERTEX_ARRAY) : glVertexPointer_(3, #GL_FLOAT, 0, *pointer\Mesh\Vertices) : EndIf
        If *pointer\Mesh\Normals  : glEnableClientState_(#GL_NORMAL_ARRAY) : glNormalPointer_(#GL_FLOAT, 0, *pointer\Mesh\Normals) : EndIf
        If *pointer\Mesh\Color    : glEnableClientState_(#GL_COLOR_ARRAY)  : glColorPointer_(4, #GL_UNSIGNED_BYTE, 0, *pointer\Mesh\Color) : EndIf
        If *pointer\Mesh\Texcoords: glEnableClientState_(#GL_TEXTURE_COORD_ARRAY)  : glTexCoordPointer_(2, #GL_FLOAT, 0, *pointer\Mesh\Texcoords) : EndIf
        
        glDisable_(#GL_COLOR_MATERIAL) ; Disable Material Coloring 
        glEnable_(#GL_TEXTURE_2D)      ; Enable texture mapping 
        glBindTexture_(#GL_TEXTURE_2D, *pointer\Texture())
        
        If *pointer\Alphamode = 1
            glAlphaFunc_(#GL_GREATER, 0.5)
            glEnable_(#GL_ALPHA_TEST )
          ElseIf  *pointer\Alphamode = 2   
            ;glBlendFunc_(*pointer\Blendmode1, *pointer\Blendmode2);          // Enable Alpha Blending (disable alpha testing)
            glBlendFunc_(#GL_ONE,#GL_ONE);       // Blending Function For Translucency Based On Source allcolour
            glEnable_(#GL_BLEND)
        EndIf
        
        If *pointer\Mesh\Indices
           Indices_count = MemorySize(*pointer\Mesh\Indices)/2 ; word
           glDrawElements_(#GL_TRIANGLES,Indices_count,#GL_UNSIGNED_SHORT, *pointer\Mesh\Indices);
        ElseIf *pointer\Mesh\Vertices
           glDrawArrays_(#GL_TRIANGLES, 0, MemorySize(*pointer\Mesh\Vertices)/SizeOf(float)/3)
        EndIf  
        
        glDisable_(#GL_ALPHA_TEST )
        glDisable_(#GL_BLEND)
        glDisableClientState_(#GL_VERTEX_ARRAY);
        glDisableClientState_(#GL_COLOR_ARRAY);
        glDisableClientState_(#GL_NORMAL_ARRAY);
        glDisableClientState_(#GL_TEXTURE_COORD_ARRAY); 
                  
    EndIf           
    
  EndIf
   
EndProcedure

ProcedureDLL MP_RenderMesh() ; Render alle Meshs
  
  ForEach Mesh()
    MP_RenderMeshSingle(Mesh())
  Next
  
EndProcedure 

;- Sprite Values (7x)

ProcedureDLL MP_LoadSprite(FileName.s) ; Lade eine Grafikdatei und erzeugen daraus ein Sprite
  
   Define *Texture.Texture 
  
   *Texture.Texture =  MP_Load2DTexture(FileName.s)
   
   If *Texture
       AddElement(Sprite.Sprite())
       Sprite()\kind = 7
       Sprite()\pTextureManager = *Texture
       Sprite()\m_height =  *Texture\height
       Sprite()\m_width = *Texture\Width
       Sprite()\Name = *Texture\pTextureFilename
       Sprite()\Alphamode = 1
       Sprite()\Blendmode1 = #GL_SRC_ALPHA
       Sprite()\Blendmode2 = #GL_ONE_MINUS_SRC_ALPHA
       ;Sprite()\m_vPosition\x = 1
       ;Sprite()\m_vRotationCenter\x = Sprite()\m_width/2
       ;Sprite()\m_vPosition\y = 1
       ;Sprite()\m_vRotationCenter\y = Sprite()\m_height/2
       ;Sprite()\m_Framedirection = 1
       Sprite()\m_vScale\X_Pos = 1
       Sprite()\m_vScale\Y_Pos = 1
       Sprite()\m_vScale\Z_Pos = 1
              
       ProcedureReturn Sprite()

   EndIf

EndProcedure   

ProcedureDLL MP_SpriteGetTexture (Sprite) ; Ermittelt die Texture eines Sprites

  ForEach Sprite()
    If Sprite() = Sprite
       ProcedureReturn Sprite()\pTextureManager
    EndIf
  Next

EndProcedure

ProcedureDLL MP_SpriteSetTexture (Sprite, Texture) ; Ersetzt die Texture eines Sprites

  ForEach Sprite()
    If Sprite() = Sprite
        
        ForEach TextureM()
   
         If TextureM() = Texture 
             Sprite()\pTextureManager = Texture
             ;Sprite()\m_vPosition\x = 1
             ;Sprite()\m_vRotationCenter\x = MP_TextureGetWidth (Texture)/2
             ;Sprite()\m_vPosition\y = 1
             ;Sprite()\m_vRotationCenter\y = MP_TextureGetHeight (Texture)/2
             ProcedureReturn #True
        EndIf
      Next
    
    EndIf
  Next  

EndProcedure

Procedure MP_RenderSpriteSingle (Sprite)
  
  Define *pointer.Sprite , cx1.f, cx2.f, cy1.f, cy2.f, x1.f, x2.f, y1.f, y2.f, text.s, i
  
  *pointer.Sprite = Sprite
  
  ForEach SpriteDraw()
    
       If SpriteDraw()\Sprite = *pointer
          glEnable_(#GL_TEXTURE_2D) :  glBindTexture_(#GL_TEXTURE_2D,*pointer\pTextureManager)
          glPushMatrix_()
          glLoadIdentity_()
          glTranslatef_(SpriteDraw()\Pos\X_Pos,SpriteDraw()\Pos\Y_Pos,0)
          glRotatef_(SpriteDraw()\fRotation,0,0,1)
          glScalef_(SpriteDraw()\m_vScale\X_Pos,SpriteDraw()\m_vScale\Y_Pos,1)
          cx1.f=0
          cx2.f=1
          cy1.f=1
          cy2.f=0
          x1.f=-*pointer\m_width/2;/*pointer\m_vScale\X_Pos
          x2.f=*pointer\m_width/2;/*pointer\m_vScale\X_Pos
          y2.f=-*pointer\m_height/2;/*pointer\m_vScale\Y_Pos  
          y1.f=*pointer\m_height/2;/*pointer\m_vScale\Y_Pos
          
          If SpriteDraw()\m_iAlpha = 1
             glAlphaFunc_(#GL_GREATER, 0.1)
             glEnable_(#GL_ALPHA_TEST )
          ElseIf SpriteDraw()\m_iAlpha = 2 
             ;glClearDepth_(1.0);                         // Depth Buffer Setup
             ;glDepthFunc_(#GL_LEQUAL);                         // Type Of Depth Testing
             ;glEnable_(#GL_DEPTH_TEST);                        // Enable Depth Testing
             glBlendFunc_(SpriteDraw()\Blendmode1, SpriteDraw()\Blendmode2);          // Enable Alpha Blending (disable alpha testing)
             ;glBlendFunc_(#GL_ONE,#GL_ONE);       // Blending Function For Translucency Based On Source allcolour
             glEnable_(#GL_BLEND)
          EndIf
  
          ;glColor4ub_(Red(col),Green(col),Blue(col),Alpha(col))
          glBegin_(#GL_QUADS)
          glTexCoord2f_(cx1,cy2);
          glVertex2i_(x1,y1)    ;
          glTexCoord2f_(cx1,cy1);
          glVertex2i_(x1,y2)    ;
          glTexCoord2f_(cx2,cy1);
          glVertex2i_(x2,y2)    ;
          glTexCoord2f_(cx2,cy2);
          glVertex2i_(x2,y1)    ;  ;
          glEnd_()
          

          ;text.s = "mein test"
          ;glRasterPos2i_(10, 10);
          ;For i = 1 To Len(text)
          ;     glutBitmapCharacter_(3,"!")
               ;glutBitmapCharacter_(3,Asc(Mid(text,i,1)))
          ;Next i
          
          
          glPopMatrix_()
          glDisable_(#GL_TEXTURE_2D)
          glDisable_(#GL_ALPHA_TEST )
          glDisable_(#GL_BLEND)
          DeleteElement(SpriteDraw())
      EndIf

  Next

EndProcedure

ProcedureDLL MP_RenderSprite () ; Render alle vorhandenen Sprites

  ForEach Sprite()
    
    MP_RenderSpriteSingle (Sprite())
    
  Next

EndProcedure

ProcedureDLL MP_DrawSprite (Sprite, x, y ); Draw a Sprite
  
  ; , Tranzparenz,Frame) coming
  
  ForEach Sprite()
    If Sprite() = Sprite
    
       AddElement(SpriteDraw())
       SpriteDraw()\Sprite = Sprite
       SpriteDraw()\fRotation = Sprite()\m_fRotation
       ;SpriteDraw()\SETZ = Sprite()\SETZ
       SpriteDraw()\Pos\X_Pos = x
       SpriteDraw()\Pos\Y_Pos = y
       SpriteDraw()\m_iAlpha = Sprite()\Alphamode
       SpriteDraw()\Blendmode1 = Sprite()\Blendmode1
       SpriteDraw()\Blendmode2 = Sprite()\Blendmode2
       SpriteDraw()\m_vScale\X_Pos = Sprite()\m_vScale\X_Pos
       SpriteDraw()\m_vScale\Y_Pos = Sprite()\m_vScale\Y_Pos
       SpriteDraw()\m_vScale\Z_Pos = Sprite()\m_vScale\Z_Pos
       ;SpriteDraw()\nFrame = Frame
       ProcedureReturn #True

    EndIf
  Next  

EndProcedure

ProcedureDLL MP_ScaleSprite(Sprite, Sx.f, Sy.f ) ; Verändere die Grösse eines Sprites in x,y Richtung, Standard Sx = 100, Sy = 100  

  ForEach Sprite()
    If Sprite() = Sprite
       
       Sprite()\m_vScale\X_Pos = Sx / 100
       Sprite()\m_vScale\Y_Pos = Sy / 100
       
       ProcedureReturn #True
    EndIf
  Next  

EndProcedure

ProcedureDLL MP_RotateSprite(Sprite, Rotation.f) ; Drehe ein Sprite in einen Winkel Rotation

  ForEach Sprite()
    If Sprite() = Sprite

       Sprite()\m_fRotation = Rotation

       ProcedureReturn #True
    EndIf
  Next  

EndProcedure

ProcedureDLL MP_SpriteSetAlpha (Sprite, mode) ; Mesh use Texture as Alphatexture

    If mode < 0 Or mode > 2
      mode = 0
      ProcedureReturn #False
    EndIf   

    ForEach Sprite()
      If Sprite() = Sprite 
         Sprite()\Alphamode = mode
         ProcedureReturn #True
      EndIf
    Next
         
EndProcedure

ProcedureDLL MP_SpriteBlendingMode(Sprite, Source, Destination) ;  Changes the type of Blend mode for a sprite
  
  ForEach Sprite()
    If Sprite() = Sprite
          Sprite()\Blendmode1 = Source
          Sprite()\Blendmode2 = Destination        
       ProcedureReturn #True
    EndIf
  Next  

EndProcedure

ProcedureDLL MP_TurnSprite(Sprite, Rotation.f) ; Rotate a sprite further into an angle Rotation

  ForEach Sprite()
    If Sprite() = Sprite
       If VSync_Rendertime = 0
          Rotation = Rotation * 60 * fElpasedAppTime / 1000
       EndIf  
       Sprite()\m_fRotation + Rotation
       ProcedureReturn #True
    EndIf
  Next  

EndProcedure

;- Text Values

ProcedureDLL MP_ScaleText(Sx.f, Sy.f ) ; Change the size of the text in the x,y direction, default is sx = 100, sy = 100

  FontScaleXGlobal = sx / 100
  FontScaleYGlobal = sy / 100
  
EndProcedure

Procedure MP_DrawText (x, y, text.s, font, fontcolor, rotation.f ) ; write on position x,y, Fontcolor = RGBA(r,g,b,a), a text with angle rotation
    
   If Text
     If font = 0 
       font = GlobalFont
     EndIf
     
     AddElement(Textprint())      
     Textprint()\ScaleX   = FontScaleXGlobal
     Textprint()\ScaleY   = FontScaleYGlobal
     ;Textprint()\FontSetZ = FontSetZGlobal
     Textprint()\Text = text
     Textprint()\x = x
     Textprint()\y = y
     Textprint()\Rotation = rotation
     Textprint()\Fontcolor = Fontcolor 
     Textprint()\Text = text
     Textprint()\MyFont=FontID(font)
     ProcedureReturn #True
      
   EndIf
   
EndProcedure


Procedure MP_RenderText ()
  ;MP_RenderGlDrawtext(x.f, y.f, Text.s, Font, angle.f, Color = $FFEEF5FF)
  
  Protected Tmp, text.s, i
  Protected iw, ih, x1.f,x2.f,y1.f,y2.f ; image size
  Protected DrawingBuffer               ; Image data pointer
  Protected TextureID = 0               ; It will be unique
  
  glPushMatrix_()

  ForEach Textprint()
  
     Tmp = CreateImage(#PB_Any, 1, 1, 32, #PB_Image_Transparent) 
  
     ; Preparing the image in RGBA format to the size of the text
     ; Determine the dimensions of the text to be displayed (iw & ih)
     StartDrawing(ImageOutput(tmp))
     DrawingFont(Textprint()\MyFont)
     iw = TextWidth(Textprint()\Text)
     ih = TextHeight(Textprint()\Text)  
     StopDrawing()
  
     ; We now know the dimensions of the text (iw & ih)
     ; Creation of the image 
     ResizeImage(tmp, iw, ih)
  
     StartDrawing(ImageOutput(tmp))
     DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
     DrawingFont(Textprint()\MyFont) 
     DrawText(0, 0, Textprint()\Text, Textprint()\Fontcolor, RGBA(0, 0, 0, 0))
     DrawingBuffer = DrawingBuffer() ;Image memory address retrieval
     StopDrawing()
  
     ; Preparation of the OpenGL texture
     glEnable_(#GL_TEXTURE_2D)
  
     ; Texture selection
     glBindTexture_(#GL_TEXTURE_2D, TextureID)

     ; Plating methods
     glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
     glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
  
     ; Creating the texture
     glTexImage2D_(#GL_TEXTURE_2D, 0, 4, iw, ih, 0, #GL_BGRA_EXT, #GL_UNSIGNED_BYTE, DrawingBuffer)
  
     ; The texture is ready. We don't need the image anymore
     FreeImage(tmp)
     
     ;glEnable_(#GL_BLEND)
     ;glBlendFunc_(#GL_SRC_ALPHA, #GL_ONE_MINUS_SRC_ALPHA)
  
     glAlphaFunc_(#GL_GREATER, 0.1)
     glEnable_(#GL_ALPHA_TEST )
  
     ; Modelisation texture  
     ;glMatrixMode_(#GL_TEXTURE)
     ;glLoadIdentity_()
     ;glPushMatrix_()
  
     ; The 0,0 corner is at the bottom right of the image, vertical flip of the texture
     ;   glScalef_(1, -1, 0)       
     
     ; Modelisation de la texture   
     ;glMatrixMode_(#GL_MODELVIEW)
     glLoadIdentity_()
     ;glPushMatrix_()
   
     ; Reset couleur
     glColor4f_(255, 255, 255, 255)
     
     x1.f=-iw/2 
     x2.f=iw/2  
     y1.f=-ih/2 
     y2.f=ih/2  
     
     glTranslatef_(Textprint()\x + iw/2 * Textprint()\ScaleX,Textprint()\y+ih/2 * Textprint()\ScaleY,0)
     glRotatef_(Textprint()\Rotation,0,0,1)
     
     
     glScalef_(Textprint()\ScaleX,Textprint()\ScaleY,1)
     

     
     ; Dessin 
     glBegin_(#GL_QUADS)
     CompilerIf #PB_Compiler_OS = #PB_OS_Windows
       glTexCoord2f_(0, 1) : glVertex2i_(x1, y1)
       glTexCoord2f_(1, 1) : glVertex2i_(x2, y1)
       glTexCoord2f_(1, 0) : glVertex2i_(x2, y2)
       glTexCoord2f_(0, 0) : glVertex2i_(x1, y2) 
     CompilerElse  
       glTexCoord2f_(0, 0) : glVertex2i_(x1, y1)
       glTexCoord2f_(1, 0) : glVertex2i_(x2, y1)
       glTexCoord2f_(1, 1) : glVertex2i_(x2, y2)
       glTexCoord2f_(0, 1) : glVertex2i_(x1, y2) 
     CompilerEndIf
    
     glEnd_()
     
     DeleteElement(Textprint() )
  Next
  
  glPopMatrix_()

  glDisable_(#GL_BLEND)
  glDisable_(#GL_TEXTURE_2D)
EndProcedure

;- Render Values (2x)

ProcedureDLL MP_RenderWorld () ; Create the 3D landscape with all entities, sprites, particles, skys etc.
  
  ;Define Font0
  
  ReSizeGLScene(WindowWidth(0),WindowHeight(0)) 
  glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)
  glClearColor_(AmbientColor\r,  AmbientColor\g, AmbientColor\b, AmbientColor\a)
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  
  ;MP_RenderBegin()   ; place holder
  ;MP_RenderCamera () ; place holder
  
   MP_RenderMesh()  
  
   Begin2D()
   
   MP_RenderSprite()
   
   MP_RenderText ()
   
   End2D()
   
  ;MP_RenderEnd()    ; place holder
     
EndProcedure

ProcedureDLL MP_Flip () ; Screeninhalt wird dargestellt
  
  Define n
  
  ExamineKeyboard()
  
  If Joystickcount 
    For n = 1 To Joystickcount
      ExamineJoystick(n-1)
    Next  
  EndIf
  
  fElpasedAppTime = ElapsedMilliseconds() - dStartAppTime 
  dStartAppTime = ElapsedMilliseconds()                                                
 
  SetGadgetAttribute(Gadget, #PB_OpenGL_FlipBuffers, #True)

EndProcedure


DisableExplicit

;- Testcode here you can test the lib with these files


CompilerIf #PB_Compiler_IsMainFile 

Procedure DrawScene(Gadget)												; Draw The Scene
  
  Define i,j
  Global angle.f
 
  SetGadgetAttribute(Gadget, #PB_OpenGL_SetContext, #True)
  glClearColor_(0.0, 0.0, 0.0, 0.5)						          	; Set The Clear Color To Black
	glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)			; Clear Screen And Depth Buffer
	glLoadIdentity_()        	
	
	multi = 1
	
	If multi
	   glEnable_(#GL_MULTISAMPLE_ARB);	//Enable our multisampleing
	EndIf   
	
	For i = -10 To 9
		For j = -10 To 9
		  glPushMatrix_();
			glTranslatef_(i*2,j*2,-5);
			glRotatef_(angle,0,0,1);
			  glBegin_(#GL_QUADS);
				glColor3f_(1,0,0) : glVertex3f_(i,j,0);
				glColor3f_(0,1,0) : glVertex3f_(i + 2,j,0);
				glColor3f_(0,0,1) : glVertex3f_(i + 2,j + 2,0);
				glColor3f_(1,1,1) : glVertex3f_(i,j + 2,0);
				glEnd_();
			glPopMatrix_();
		Next
	Next	
	
	;If turn
		angle + 0.05
	;EndIf 
  glFlush_()
  
  ;If domulti
	 ;  glDisable_(#GL_MULTISAMPLE_ARB);
	;EndIf   
	
	SetGadgetAttribute(Gadget, #PB_OpenGL_FlipBuffers, #True)
	
EndProcedure






  
MP_Graphics3D (640,480,0,2)

;camera=MP_CreateCamera()

light=MP_CreateLight(1)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder schliessen
  ;event = WindowEvent()
  ;Debug event
  ;
;While Not MP_KeyDown(#PB_Key_Escape) And Not Quit

;  Repeat 
;    Event = WindowEvent()
;    Debug event
    
;    Select Event
;      Case #PB_Event_CloseWindow
;        Quit = 1
;      Case #PB_Event_SizeWindow  
;        ReSizeGLScene(WindowWidth(0),WindowHeight(0)) ;LoWord=Width, HiWord=Height
;   EndSelect
  
; Until Event = 0
  
  
  
    MP_Windows_Fps("")
    DrawScene(0)
  
    ;MP_RenderWorld ()
    ;MP_Flip ()

Wend

  
CompilerEndIf  
; IDE Options = PureBasic 6.20 Beta 2 (Windows - x64)
; CursorPosition = 3084
; FirstLine = 3064
; Folding = ---------------
; EnableAsm
; EnableThread
; EnableXP
; DPIAware
; Executable = D:\temp\dll\MP3D_x32.dll
; CommandLine = c:\temp\OpenGL\Wichtig\models\wispwind.x