abstract class Interpolator
{
  Animation animation;
  
  // Where we at in the animation?
 
  int currentFrame = 0;
  int nextFrame = 1;
  float currentTime = 0;
  
  // To interpolate, or not to interpolate... that is the question
  boolean snapping = false;
  
  void SetAnimation(Animation anim)
  {
    animation = anim;
    currentFrame = anim.keyFrames.size()-1;
    nextFrame = 0;
  }
  
  void SetFrameSnapping(boolean snap)
  {
    snapping = snap;
  }
  
  
  void UpdateTime(float time)
  {
    // TODO: Update the current time
    // Check to see if the time is out of bounds (0 / Animation_Duration)
    // If so, adjust by an appropriate amount to loop correctly
   float prevTime = currentTime;
   currentTime += time;
   //handle reverse animation
   if(currentTime < prevTime){
       
     if( currentTime <= animation.keyFrames.get(nextFrame).time){
        
       //edge case, wrap around
       if(currentTime <= 0){
          currentFrame =  animation.keyFrames.size()-1;
          nextFrame = animation.keyFrames.size()-2;
          currentTime = animation.GetDuration();
       }
       else if(currentTime <= animation.keyFrames.get(0).time){
          //println(animation.GetDuration());
          currentFrame = 0;
          nextFrame = animation.keyFrames.size()-1;
       }
       else {
        currentFrame--;
        nextFrame--;
       }
      }
   }
   else {
     if( currentTime >= animation.keyFrames.get(nextFrame).time ){
       //edge case, wrap around
       if(currentTime >= animation.GetDuration()){
          currentTime = 0;
          currentFrame++;
          nextFrame = 0;
       }
       else if(currentFrame > nextFrame){
         nextFrame++;
         currentFrame = 0;
       }
       else {
        currentFrame++;
        nextFrame++;
       }
      }
   }
  
  
  }
  // Implement this in derived classes
  // Each of those should call UpdateTime() and pass the time parameter
  // Call that function FIRST to ensure proper synching of animations
  abstract void Update(float time);
}

class ShapeInterpolator extends Interpolator
{
  // The result of the data calculations - either snapping or interpolating
  PShape currentShape; 
  
  // Changing mesh colors
  color fillColor;
  
  PShape GetShape()
  {
    return currentShape;
  }
  
  void Update(float time)
  {
     KeyFrame currAnimFrame = animation.keyFrames.get(currentFrame);
     KeyFrame nextAnimFrame = animation.keyFrames.get(nextFrame);
     float timeRatio = 0;
     UpdateTime(time);
     if(time > 0){
       if(currentTime >= currAnimFrame.time ){
         timeRatio = (currentTime-currAnimFrame.time)/(nextAnimFrame.time-currAnimFrame.time);
       } 
       else {
           timeRatio = (currentTime/nextAnimFrame.time);
       }
     
     }
     else {
       timeRatio = (currAnimFrame.time - currentTime)/currAnimFrame.time;
       if(timeRatio < 0)
         timeRatio = 1;
     }
    
     
     currentShape = createShape();
     currentShape.setFill(fillColor);
       currentShape.beginShape(TRIANGLE);
       
       for(int i = 0; i < currAnimFrame.points.size(); i++){
         
         float x = 0;
         float y = 0;
         float z = 0;
         if(!snapping){
           x = lerp(currAnimFrame.points.get(i).x,nextAnimFrame.points.get(i).x, timeRatio);
           y = lerp(currAnimFrame.points.get(i).y,nextAnimFrame.points.get(i).y, timeRatio);
           z = lerp(currAnimFrame.points.get(i).z,nextAnimFrame.points.get(i).z, timeRatio);
         }
         else {
           x = currAnimFrame.points.get(i).x;
           y = currAnimFrame.points.get(i).y;
           z = currAnimFrame.points.get(i).z;
         }
         
         //println(x,y,z);
         currentShape.vertex(x,y,z); 
       }
       currentShape.endShape();
     
    // TODO: Create a new PShape by interpolating between two existing key frames
    // using linear interpolation
  }
}

class PositionInterpolator extends Interpolator
{
  PVector currentPosition;
  
  void Update(float time)
  {
       UpdateTime(time);
       
       KeyFrame currAnimFrame = animation.keyFrames.get(currentFrame);
       KeyFrame nextAnimFrame = animation.keyFrames.get(nextFrame);
       float timeRatio = 0;
       if(time > 0){
           if(currentTime > currAnimFrame.time)
             timeRatio = (currentTime-currAnimFrame.time)/(nextAnimFrame.time-currAnimFrame.time);
           else 
             timeRatio = (currentTime/nextAnimFrame.time);
       }
       else {
         timeRatio = (currAnimFrame.time - currentTime)/currAnimFrame.time;
       }
       float x = 0;
         float y = 0;
         float z = 0;
         //println(timeRatio);
       if(!snapping){
          
          x = lerp(currAnimFrame.points.get(0).x,nextAnimFrame.points.get(0).x, timeRatio);
          y = lerp(currAnimFrame.points.get(0).y,nextAnimFrame.points.get(0).y, timeRatio);
           z = lerp(currAnimFrame.points.get(0).z,nextAnimFrame.points.get(0).z, timeRatio);
           currentPosition = new PVector(x,y,z);
       }
       else {
         currentPosition = new PVector(currAnimFrame.points.get(0).x, currAnimFrame.points.get(0).y, currAnimFrame.points.get(0).z);
       }
  }
}
