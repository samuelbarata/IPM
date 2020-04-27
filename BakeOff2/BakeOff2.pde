// Bakeoff #2 - Seleção de Alvos e Fatores Humanos
// IPM 2019-20, Semestre 2
// Bake-off: durante a aula de lab da semana de 20 de Abril
// Submissão via Twitter: exclusivamente no dia 24 de Abril, até às 23h59

// Processing reference: https://processing.org/reference/

import java.util.Collections;


 // Target properties
float PPI, PPCM;
float SCALE_FACTOR;
float TARGET_SIZE;
float TARGET_PADDING, MARGIN, LEFT_PADDING, TOP_PADDING;

// Study properties
ArrayList<Integer> trials  = new ArrayList<Integer>();      // contains the order of targets that activate in the test
ArrayList<Integer> x  = new ArrayList<Integer>();          //x position of targets
ArrayList<Integer> y  = new ArrayList<Integer>();          //y position of targets
ArrayList<Target> targets = new ArrayList<Target>();        // cursor
Target cursor;

int trialNum               = 0;                           // the current trial number (indexes into trials array above)
final int NUM_REPEATS      = 3;                           // sets the number of times each target repeats in the test - FOR THE BAKEOFF NEEDS TO BE 3!
boolean ended              = false;

// Performance variables
int startTime              = 0;      // time starts when the first click is captured
int finishTime             = 0;      // records the time of the final click
int hits                   = 0;      // number of successful clicks
int misses                 = 0;      // number of missed clicks

// Class used to store properties of a target
class Target
{
  public int x, y;
  public float w;
  public int strokeR, strokeG, strokeB, r,g,b, strokeWeight=0;
  
  Target(int posx, int posy, float twidth) 
  {
    x = posx;
    y = posy;
    w = twidth;
  }
  public void draw(){
    noStroke();
    noFill();
    if(strokeWeight>0){
      stroke(strokeR,strokeG,strokeB);
      strokeWeight(strokeWeight);
    }
    if(r>=0){
        fill(r,g,b);
    }
    circle(x,y,w);
  }
  public void imTarget(){
      r=255;
      g=0;
      b=0;
      strokeWeight=5;
      strokeR=255;
      strokeG=255;
      strokeB=0;
  }
  public void imNext(){
      r=150;
      g=150;
      b=0;
      strokeWeight=0;
  }
  public void imNormal(){
      r=119;
      g=119;
      b=119;
      strokeWeight=0;
  }
  public void imDouble(){
      r=0;
      g=0;
      b=255;
      strokeWeight=5;
      strokeR=255;
      strokeG=255;
      strokeB=0;
  }
  public void mouseOn(){
      strokeWeight=20;
      strokeR=0;
      strokeG=255;
      strokeB=0;
      
      this.draw();
  }
  public void imCursor(){
      r=0;
      g=255;
      b=0;
      strokeWeight=0;
  }
}

// Setup window and vars - runs once
void setup()
{
  fullScreen();                // USE THIS DURING THE BAKEOFF!
  cursor = new Target(mouseX, mouseY,0);
  cursor.imCursor();
  SCALE_FACTOR    = 1.0 / displayDensity();            // scale factor for high-density displays
  String[] ppi_string = loadStrings("ppi.txt");        // The text from the file is loaded into an array.
  PPI            = float(ppi_string[1]);               // set PPI, we assume the ppi value is in the second line of the .txt
  PPCM           = PPI / 2.54 * SCALE_FACTOR;          // do not change this!
  TARGET_SIZE    = 1.5 * PPCM;                         // set the target size in cm; do not change this!
  TARGET_PADDING = 1.5 * PPCM;                         // set the padding around the targets in cm; do not change this!
  MARGIN         = 1.5 * PPCM;                         // set the margin around the targets in cm; do not change this!
  LEFT_PADDING   = width/2 - TARGET_SIZE - 1.5*TARGET_PADDING - 1.5*MARGIN;        // set the margin of the grid of targets to the left of the canvas; do not change this!
  TOP_PADDING    = height/2 - TARGET_SIZE - 1.5*TARGET_PADDING - 1.5*MARGIN;       // set the margin of the grid of targets to the top of the canvas; do not change this!
  
  noStroke();        // draw shapes without outlines
  frameRate(60);     // set frame rate

  // Text and font setup
  textFont(createFont("Arial", 16));    // sets the font to Arial size 16
  textAlign(CENTER);                    // align text
  
  randomizeTrials();    // randomize the trial order for each participant
  
  for(int i = 0; i<=16; i++){
      targets.add(new Target(getX(i), getY(i), TARGET_SIZE));
      x.add(getX(i));
      y.add(getY(i));
  }
  
}

// Updates UI - this method is constantly being called and drawing targets
void draw()
{
  if(hasEnded()) 
    return;            // nothing else to do; study is over
    
  background(0);       // set background to black

  // Print trial count
  fill(255);          // set text fill color to white
  text("Trial " + (trialNum + 1) + " of " + trials.size(), 50, 20);    // display what trial the participant is on (the top-left corner)
  
  int atual = trials.get(trialNum);
  int next;
  try{
      next = trials.get(trialNum+1);
  } catch(IndexOutOfBoundsException e){
      next=-1;
  }
  drawHelper(atual, next); 
}

boolean hasEnded() {
   if(ended) return true;    // returns if test has ended before
   
   // Check if the study is over
  if (trialNum >= trials.size())
  {
    float timeTaken = (finishTime-startTime) / 1000f;     // convert to seconds - DO NOT CHANGE!
    float penalty = constrain(((95f-((float)hits*100f/(float)(hits+misses)))*.2f),0,100);    // calculate penalty - DO NOT CHANGE!
    
    printResults(timeTaken, penalty);    // prints study results on-screen
    ended = true;
  }
  
  return ended;
}

// Randomize the order in the targets to be selected
// DO NOT CHANGE THIS METHOD!
void randomizeTrials()
{
  for (int i = 0; i < 16; i++)             // 4 rows times 4 columns = 16 target
    for (int k = 0; k < NUM_REPEATS; k++)  // each target will repeat 'NUM_REPEATS' times
      trials.add(i);

  Collections.shuffle(trials);             // randomize the trial order
  
  System.out.println("trial order: " + trials);    // prints trial order - for debug purposes
}

// Print results at the end of the study
void printResults(float timeTaken, float penalty)
{
  background(0);       // clears screen
  
  fill(255);    //set text fill color to white
  text(day() + "/" + month() + "/" + year() + "  " + hour() + ":" + minute() + ":" + second() , 100, 20);   // display time on screen
  
  text("Finished!", width / 2, height / 2); 
  text("Hits: " + hits, width / 2, height / 2 + 20);
  text("Misses: " + misses, width / 2, height / 2 + 40);
  text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, height / 2 + 60);
  text("Total time taken: " + timeTaken + " sec", width / 2, height / 2 + 80);
  text("Average time for each target: " + nf((timeTaken)/(float)(hits+misses),0,3) + " sec", width / 2, height / 2 + 100);
  text("Average time for each target + penalty: " + nf(((timeTaken)/(float)(hits+misses) + penalty),0,3) + " sec", width / 2, height / 2 + 140);
  
  saveFrame("ist19XXXX_G04_<tentativa######>.png");    // saves screenshot in current folder
}

int findCloser(){
    float tamanho;
    int bola=0;
    float min=69696969.0;
    for(int contador=0; contador<16; contador++){
      tamanho = sqrt(pow(x.get(contador)-mouseX,2) + pow(y.get(contador)-mouseY,2))*2;
      if (tamanho < min){
        min = tamanho;
        bola = contador;
      }
    }
    return bola;
}

// Mouse button was release - lets test to see if hit was in the correct target
void mousePressed() 
{
  if (trialNum >= trials.size()) return;      // if study is over, just return
  if (trialNum == 0) startTime = millis();    // check if first click, if so, start timer
  if (trialNum == trials.size() - 1)          // check if final click
  {
    finishTime = millis();    // save final timestamp
    println("We're done!");
  }
  
  Target target = getTargetBounds(trials.get(trialNum));    // get the location and size for the target in the current trial
  int i = findCloser();
  
  // Check to see if mouse cursor is inside the target bounds
  if(dist(target.x, target.y, x.get(i), y.get(i)) < target.w/2)
  {
    System.out.println("HIT! " + trialNum + " " + (millis() - startTime));     // success - hit!
    hits++; // increases hits counter 
  }
  else
  {
    System.out.println("MISSED! " + trialNum + " " + (millis() - startTime));  // fail
    misses++;   // increases misses counter
  }

  trialNum++;   // move on to the next trial; UI will be updated on the next draw() cycle
}  

// For a given target ID, returns its location and size
Target getTargetBounds(int i)
{
  int x = getX(i);
  int y = getY(i);

  return new Target(x, y, TARGET_SIZE);
}
// Draw target on-screen
// This method is called in every draw cycle; you can update the target's UI here
void drawTarget(int i)
{
    Target target = targets.get(i);   // get the location and size for the circle with ID:i
    target.imNormal();
    
    //target atual
    if (trials.get(trialNum) == i){ 
        target.imTarget();
        //se igual ao seguinte
        try{
          if(trials.get(trialNum+1)==trials.get(trialNum)){
            target.imDouble();
          }
        }catch(IndexOutOfBoundsException e){}
    }
    else{
        //target seguinte
        try{
          if (trials.get(trialNum+1)==i){ 
              target.imNext();
          }
        }catch(IndexOutOfBoundsException e){}
    }
    target.draw();
}
int getX(int i){
    return (int)LEFT_PADDING +(int)((i % 4) * (TARGET_SIZE + TARGET_PADDING) + MARGIN);
}
int getY(int i){
    return (int)TOP_PADDING + (int)((i / 4) * (TARGET_SIZE + TARGET_PADDING) + MARGIN);
}
void drawHelper(int i, int k){  
  //desenha rato
  drawMouse();
  //desenha targets
  for (int u = 0; u < 16; u++) drawTarget(u);
  //desenha linha
  stroke(255,255,0);
  strokeWeight(1);
  if(k!=-1)
    line(getX(i), getY(i), getX(k), getY(k));
  noStroke();
  
}


void drawMouse(){
    int i = findCloser();
    cursor.x = mouseX;
    cursor.y = mouseY;
    cursor.w = (sqrt(pow(getX(i)-mouseX,2) + pow(getY(i)-mouseY,2))*2)-(TARGET_SIZE+1);    

    cursor.draw();
    
    //target mais proximo
    targets.get(i).mouseOn();
}
