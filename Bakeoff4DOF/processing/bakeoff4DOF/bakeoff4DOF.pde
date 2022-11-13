import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 450;
float logoY = 350;
float logoZ = 50f;
float logoRotation = 0;

//Additional variables
boolean debug = true;
PVector base = new PVector(logoX, logoY);
PVector corner = new PVector(logoX + 100, logoY + 100);
PVector center = new PVector((base.x + corner.x) / 2, (base.y + corner.y) / 2);
float sideLength = base.dist(corner) / sqrt(2);
boolean dragBase = false;
boolean dragCorner = false;
int indicatorSize = 20;
float offSetX = 0;
float offSetY = 0;
String match = "";
boolean closeDist = false;
boolean closeRotation = false;
boolean closeZ = false;
boolean success = false;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    rectMode(CENTER);
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    
    noFill();
    strokeWeight(3f);
    if (trialIndex==i) { // if is target
      // draw square
      stroke(255, 0, 0, 192); //set target square always red
      rotate(radians(d.rotation)); //rotate around the origin of the destination trial
      rect(0, 0, d.z, d.z);
      
      //draw indicators
      stroke(255, 0, 0, 100); //set indicators more transparent
      // draw corner indicators if there is room (draw after rotate)
      if (d.z > indicatorSize) {
        float halfLen = d.z/2;
        circle(halfLen, halfLen, indicatorSize);
        circle(halfLen, -halfLen, indicatorSize);
        circle(-halfLen, halfLen, indicatorSize);
        circle(-halfLen, -halfLen, indicatorSize);
      }
      // draw center cross
      rotate(radians(-d.rotation)); // counter rotate cross to match with logo
      line(0 - indicatorSize/2, 0, 0 + indicatorSize/2, 0);
      line(0, 0 - indicatorSize/2, 0, 0 + indicatorSize/2);
      
    } else { // if not target
      rotate(radians(d.rotation)); //rotate around the origin of the destination trial
      stroke(128, 128, 128, 128); //set color to semi translucent
      rect(0, 0, d.z, d.z);
    }
      popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();

  // controlls for dragging corners, conditions set in mousePressed() and mouseReleased()
  if (dragBase){
    // moves the base and corner equally
    base.set(mouseX - offSetX, mouseY - offSetY);
    corner.set(corner.x + mouseX - pmouseX, corner.y + mouseY - pmouseY);
    // dont let corner go off screen becaues then you can't drag it
    if (base.x < 0) {base.x = 0;}
    if (base.y < 0) {base.y = 0;}
    if (base.x > width) {base.x = width;}
    if (base.y > height) {base.y = height;}
  }
  if (dragCorner) {
    // moves the corner without moving the base to change size and retation
    corner.set(mouseX - offSetX, mouseY - offSetY);
    // dont let corner go off screen becaues then you can't drag it
    if (corner.x < 0) {corner.x = 0;}
    if (corner.y < 0) {corner.y = 0;}
    if (corner.x > width) {corner.x = width;}
    if (corner.y > height) {corner.y = height;}
  }
  
  // set sidelength for drawing logo
  sideLength = 2 * base.dist(corner) / sqrt(2);
  
  // set location of the logo for internal logic
  logoX = base.x;
  logoY = base.y;
  logoZ = sideLength;
  
  // draw logo
  noStroke();
  fill(60, 60, 192, 150);
  //rectMode(CORNER);
  translate(base.x, base.y); //translate draw center to the base corner
  logoRotation = degrees(atan2(corner.y - base.y, corner.x - base.x) - PI/4); // find angle between base and corner corner
  rotate(radians(logoRotation)); //rotate using the base corner as the origin
  rect(0, 0, sideLength, sideLength); // draw square at translated draw center
  //rectMode(CENTER); // reset rectMode
  
  popMatrix();
  
  // draw logo indicators
  stroke(3);
  fill(0,0,0,0);
  if (closeRotation && closeZ) {
    stroke(0, 255, 0, 250);
  } else {
    stroke(255, 255, 0, 250);
  }
  circle(corner.x, corner.y, indicatorSize); //draw corner drag circle
  
  if (closeDist) {
    stroke(0, 255, 0, 250);
  } else {
    stroke(255, 255, 0, 250);
  }
  line(base.x - indicatorSize/2, base.y, base.x + indicatorSize/2, base.y); // draw center drag crosshair
  line(base.x, base.y - indicatorSize/2, base.x, base.y + indicatorSize/2);
  
  //===========TEXT==================
  noStroke();
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
  
  success = checkForSuccess();
  if (debug) {
    textFont(createFont("Arial", inchToPix(.2f)));
    textAlign(LEFT);
    text(match, 0, 100);
    textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
    textAlign(CENTER);
  }

  //===========DRAW SUBMIT BUTTONS=================
  
  rectMode(CORNER);
  if (success) {
    fill(100,200,100,200);
  } else {
    fill(100,100,100,200);
  }
  rect(0,0,100, 60);
  rect(corner.x, corner.y -indicatorSize-30, 70, 35);
  fill(256, 256, 256, 256);
  text("NEXT", 50, 37);
  text("NEXT", corner.x + 34, corner.y -indicatorSize-5);  

}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  
  // test press base corner
  if (dist(corner.x, corner.y, mouseX, mouseY) < indicatorSize) {
    offSetX = mouseX - corner.x;
    offSetY = mouseY - corner.y;    
    dragCorner = true;
  } else if (dist(base.x, base.y, mouseX, mouseY) < indicatorSize) {
    offSetX = mouseX - base.x;
    offSetY = mouseY - base.y;  
    dragBase = true;
  }
}

void mouseReleased()
{
  // stop dragging any corner
  dragBase = false;
  dragCorner = false;
  
  //check if click next
  if (success && ((mouseX < 100 && mouseY < 60) || (mouseX < corner.x + 70 && mouseX > corner.x && mouseY > corner.y -indicatorSize-30 && mouseY < corner.y -indicatorSize+5)) )
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);
  closeDist = closeRotation = closeZ = false;
  closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"	

  match = "";
  match += "Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")\n";
  match += "Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")" + d.rotation + ":" + logoRotation + "\n";
  match += ("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")\n");
  match += ("Close enough all: " + (closeDist && closeRotation && closeZ) + "\n");
  println(match);

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
