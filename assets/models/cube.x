xof 0303txt 0032

Frame Root {
  FrameTransformMatrix {
     1.000000, 0.000000, 0.000000, 0.000000,
     0.000000,-0.000000, 1.000000, 0.000000,
     0.000000, 1.000000, 0.000000, 0.000000,
     0.000000, 0.000000, 0.000000, 1.000000;;
  }
  Frame Cube {
    FrameTransformMatrix {
       1.000000, 0.000000, 0.000000, 0.000000,
       0.000000, 1.000000, 0.000000, 0.000000,
       0.000000, 0.000000, 1.000000, 0.000000,
       0.000000, 0.000000, 0.000000, 1.000000;;
    }
    Mesh { // Cube mesh
      8;
       1.000000; 1.000000;-1.000000;,
       1.000000;-1.000000;-1.000000;,
      -1.000000;-1.000000;-1.000000;,
      -1.000000; 1.000000;-1.000000;,
       1.000000; 0.999999; 1.000000;,
       0.999999;-1.000001; 1.000000;,
      -1.000000;-1.000000; 1.000000;,
      -1.000000; 1.000000; 1.000000;;
      12;
      3;2,1,0;,
      3;6,7,4;,
      3;5,4,0;,
      3;6,5,1;,
      3;7,6,2;,
      3;3,0,4;,
      3;2,0,3;,
      3;6,4,5;,
      3;5,0,1;,
      3;6,1,2;,
      3;7,2,3;,
      3;3,4,7;;
      MeshNormals { // Cube normals
        12;
         0.000000; 0.000000;-1.000000;,
        -0.000000; 0.000000; 1.000000;,
         1.000000;-0.000001;-0.000000;,
        -0.000000;-1.000000;-0.000000;,
        -1.000000; 0.000000;-0.000000;,
         0.000000; 1.000000; 0.000000;,
         0.000000; 0.000000;-1.000000;,
        -0.000000; 0.000000; 1.000000;,
         1.000000; 0.000000; 0.000000;,
        -0.000000;-1.000000; 0.000000;,
        -1.000000; 0.000000;-0.000000;,
         0.000000; 1.000000; 0.000000;;
        12;
        3;0,0,0;,
        3;1,1,1;,
        3;2,2,2;,
        3;3,3,3;,
        3;4,4,4;,
        3;5,5,5;,
        3;6,6,6;,
        3;7,7,7;,
        3;8,8,8;,
        3;9,9,9;,
        3;10,10,10;,
        3;11,11,11;;
      } // End of Cube normals
      MeshMaterialList { // Cube material list
        1;
        12;
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0;;
        Material Material {
           0.640000; 0.640000; 0.640000; 1.000000;;
           96.078431;
           0.500000; 0.500000; 0.500000;;
           0.000000; 0.000000; 0.000000;;
        }
      } // End of Cube material list
    } // End of Cube mesh
  } // End of Cube
} // End of Root
