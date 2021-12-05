// VertexAnimation Project - Student Version
import java.io.*;
import java.util.*;
import controlP5.*;
/*========== Monsters ==========*/
Animation monsterAnim;
ShapeInterpolator monsterForward = new ShapeInterpolator();
ShapeInterpolator monsterReverse = new ShapeInterpolator();
ShapeInterpolator monsterSnap = new ShapeInterpolator();

/*========== Sphere ==========*/
Animation sphereAnim; // Load from file
Animation spherePos; // Create manually
ShapeInterpolator sphereForward = new ShapeInterpolator();
PositionInterpolator spherePosition = new PositionInterpolator();

// TODO: Create animations for interpolators
ArrayList<PositionInterpolator> cubes = new ArrayList<PositionInterpolator>();
ControlP5 cp5;
CameraController controller = new CameraController();

class CameraController {
   PVector position; 
   PVector target = new PVector(0,0,0);
   float FOV = 110;
   float theta = 90;
   float phi =0;
   float radius;
   int xClickedStart = -1;
   int yClickedStart = -1;
   int currPos = 0;
   
   int movementType;
   
   CameraController(){
     this.position = new PVector(width/2, -height, (height/2.0) / tan(PI*30.0 / 180.0));
     this.radius = abs(target.dist(position));
     this.theta = (acos(position.y/radius)*180)/PI;
     this.phi = (acos(position.x/(radius*sin(radians(theta))))*180)/PI;
   }
   
   void Update(){
       if(mousePressed == true && !cp5.isMouseOver()){
         if(xClickedStart != -1 && yClickedStart != -1){
           phi += map(mouseX, xClickedStart, width-1, 0, 360);
           theta += map(mouseY, yClickedStart, height-1, 0, 179);
           position.x = target.x + radius*cos(radians(phi))*sin(radians(theta));
           position.y = target.y + radius*cos(radians(theta));
           position.z = target.z + radius*sin(radians(theta))*sin(radians(phi));
           xClickedStart = mouseX;
           yClickedStart = mouseY;
         }
         else {
           xClickedStart = mouseX;
           yClickedStart = mouseY;
         }
       }
       else {
         xClickedStart = -1;
         yClickedStart = -1;
       }
     
    perspective(radians(FOV), width/(float)height, 0.1, 1000);
     
    camera(position.x, position.y, position.z, 
            target.x, target.y,target.z, 
            0, sin(radians(theta)),0);
   }
  
   
   void Zoom(float FOV){
     this.FOV += FOV*3;
   }
   
}

void setup()
{
  pixelDensity(2);
  size(1200, 800, P3D);
   cp5 = new ControlP5(this);
  /*====== Load Animations ======*/
  monsterAnim = ReadAnimationFromFile("monster.txt");
  sphereAnim = ReadAnimationFromFile("sphere.txt");
  

  monsterForward.SetAnimation(monsterAnim);
  monsterReverse.SetAnimation(monsterAnim);
  monsterSnap.SetAnimation(monsterAnim);  
  monsterSnap.SetFrameSnapping(true);

  sphereForward.SetAnimation(sphereAnim);

  /*====== Create Animations For Cubes ======*/
  // When initializing animations, to offset them
  // you can "initialize" them by calling Update()
  // with a time value update. Each is 0.1 seconds
  // ahead of the previous one
  
  /*====== Create Animations For Spheroid ======*/
  Animation spherePos = new Animation();
  
  for(int i =0; i < 4; i++){
    KeyFrame kf = new KeyFrame();
    switch(i){
      case 0:
         kf.time = 1.0f;
         kf.points.add(new PVector(-100,0,100));
         break;
      case 1:
         kf.time = 2.0f;
         kf.points.add(new PVector(-100,0,-100));
         break;
      case 2:
         kf.time = 3.0f;
         kf.points.add(new PVector(100,0,-100));
         break;
      case 3:
         kf.time = 4.0f;
         kf.points.add(new PVector(100,0,100));
         break;
    }
    spherePos.keyFrames.add(kf);
  }
  spherePosition.SetAnimation(spherePos);
  
  int cf = 0;
  float ct = 0;
  for(int i =0; i< 11; i++){
    float zPos = -100;
    Animation boxPos = new Animation();
    for(int j = 0; j< 4; j++){
      if(j < 2)
        zPos += 100;
      else 
        zPos -= 100;
      KeyFrame kf = new KeyFrame();
      kf.time = float((j+1))/2.0f;
      //println(kf.time);
      kf.points.add(new PVector(-100 + i*20, 0, zPos));
      boxPos.keyFrames.add(kf);
    }
    cubes.add(new PositionInterpolator());
    cubes.get(i).SetAnimation(boxPos);
   
    cubes.get(i).currentTime = ct*0.25;
    
    if(cf > 3){
        cf = 0;
        ct = 0;
      }
      cubes.get(i).currentFrame = cf;
      cubes.get(i).nextFrame = cf+1;
      if(cf == 3){
        cubes.get(i).nextFrame = 0;
      }
    if(i%2 == 0){
       cf++;
    }
    
       ct++;
    if((i % 2) > 0) {
      cubes.get(i).snapping = true;
    }
  }

}

void draw()
{
  lights();
  background(0);
  DrawGrid();
  controller.Update();
  float playbackSpeed = 0.005f;


  /*====== Draw Forward Monster ======*/
  pushMatrix();
  translate(-40, 0, 0);
  noStroke();
  monsterForward.fillColor = color(128, 200, 54);
  monsterForward.Update(playbackSpeed);
  shape(monsterForward.currentShape);
  popMatrix();
  
  /*====== Draw Reverse Monster ======*/
  pushMatrix();
  translate(40, 0, 0);
  noStroke();
  monsterReverse.fillColor = color(220, 80, 45);
  monsterReverse.Update(-playbackSpeed);
  shape(monsterReverse.currentShape);
  popMatrix();
  
  /*====== Draw Snapped Monster ======*/
  pushMatrix();
  translate(0, 0, -60);
  noStroke();
  monsterSnap.fillColor = color(160, 120, 85);
  monsterSnap.Update(playbackSpeed);
  shape(monsterSnap.currentShape);
  popMatrix();
  
  /*====== Draw Spheroid ======*/
  spherePosition.Update(playbackSpeed);
  sphereForward.fillColor = color(39, 110, 190);
  sphereForward.Update(playbackSpeed);
  PVector pos = spherePosition.currentPosition;
  //println(pos);
  pushMatrix();
  translate(pos.x, pos.y, pos.z);
  shape(sphereForward.currentShape);
  popMatrix();
  
  /*====== TODO: Update and draw cubes ======*/
  // For each interpolator, update/draw
  for(int i =0; i < cubes.size(); i++){
    cubes.get(i).Update(playbackSpeed);
    pos = cubes.get(i).currentPosition;
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    if(i%2 == 0){
      fill(color(255,0,0));
    }
    else {
      fill(color(255,255,0));
    }
    box(20,20,20);
    popMatrix();
  }
}

void mouseWheel(MouseEvent event)
{
  float e = event.getCount();
  controller.Zoom(e);
  // Zoom the camera
  // SomeCameraClass.zoom(e);
}

// Create and return an animation object
Animation ReadAnimationFromFile(String fileName)
{
  Animation animation = new Animation();
  BufferedReader reader = createReader(fileName);
  try {
    String line = reader.readLine();
    int counter = Integer.parseInt(line);
    line = reader.readLine();
    int numVertices = Integer.parseInt(line);
    for(int i = 0; i < counter; i++){
      line = reader.readLine();
      float time = Float.parseFloat(line);
      KeyFrame kf = new KeyFrame();
      for(int j = 0; j < numVertices; j++){
        line = reader.readLine();
        String[] pieces = split(line, ' ');
        PVector position = new PVector(Float.parseFloat(pieces[0]), Float.parseFloat(pieces[1]),Float.parseFloat(pieces[2]));
        kf.points.add(position);
      }
      kf.time = time;
      animation.keyFrames.add(kf);
    } 
  }
   catch (IOException e){
     e.printStackTrace();
   }
  return animation;
}

void DrawGrid()
{
  for(int i = -10; i < 11; i ++){
    stroke(255);
    if(i==0)
      stroke(0,0,255);
    line(i*10,0,100, i*10,0,-100);
    if(i==0)
      stroke(255,0,0);
    line(100,0,i*10, -100,0,i*10);
  }
  // TODO: Draw the grid
  // Dimensions: 200x200 (-100 to +100 on X and Z)
}
