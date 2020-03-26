// Bakeoff #2 - Seleção de Alvos e Fatores Humanos
// IPM 2019-20, Semestre 2
// Bake-off: durante a aula de lab da semana de 20 de Abril
// Submissão via Twitter: exclusivamente no dia 24 de Abril, até às 23h59

// Processing reference: https://processing.org/reference/

import java.util.Collections;

// Target properties
final float PPI            = 227;            // http://dpi.lv/ (Macbook Pro 13 Retina: 227) - CHANGE TO YOUR DISPLAY PPI!
final float PPCM           = PPI / 2.54;     // do not change this!
final float TARGET_SIZE    = 1.5 * PPCM;     // set the target size in cm; do not change this!
final float TARGET_PADDING   = 0.1 * PPCM;   // set the padding around the targets in cm; do not change this!
final float MARGIN           = 1.5 * PPCM;   // set the margin around the targets in cm; do not change this!

// Study properties
ArrayList<Integer> trials  = new ArrayList<Integer>();    // contains the order of targets that activate in the test
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
  
  Target(int posx, int posy, float twidth) 
  {
    x = posx;
    y = posy;
    w = twidth;
  }
}

// Setup window and vars - runs once
void setup()
{
  size(700, 700);    // window size in px
  noStroke();        // draw shapes without outlines
  frameRate(60);     // set frame rate
  
  // Text and font setup
  textFont(createFont("Arial", 16));    // sets the font to Arial size 16
  textAlign(CENTER);                    // align text
  
  randomizeTrials();    // randomize the trial order for each participant
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

  // Draw targets
  for (int i = 0; i < 16; i++) drawTarget(i);
  drawHelper(trials.get(trialNum), new Target(0,0,0));
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
  
  saveFrame("results-######.png");    // saves screenshot in current folder
}

// Mouse button was release - lets test to see if hit was in the correct target
void mouseReleased() 
{
  if (trialNum >= trials.size()) return;      // if study is over, just return
  if (trialNum == 0) startTime = millis();    // check if first click, if so, start timer
  if (trialNum == trials.size() - 1)          // check if final click
  {
    finishTime = millis();    // save final timestamp
    println("We're done!");
  }
  
  Target target = getTargetBounds(trials.get(trialNum));    // get the location and size for the target in the current trial
  
  // Check to see if mouse cursor is inside the target bounds
  if(dist(target.x, target.y, mouseX, mouseY) < target.w/2)
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
  int x = (int)((i % 4) * (TARGET_SIZE + TARGET_PADDING) + MARGIN);
  int y = (int)((i / 4) * (TARGET_SIZE + TARGET_PADDING) + MARGIN);
  
  return new Target(x, y, TARGET_SIZE/2);
}

// Draw target on-screen
// This method is called in every draw cycle; you can update the target's UI here
void drawTarget(int i)
{
  Target target = getTargetBounds(i);   // get the location and size for the circle with ID:i
  
  fill(30);           // fill dark gray

  // check whether current circle is the intended target
    try{
        //target atual
        if (trials.get(trialNum) == i){ 
            stroke(255, 255, 0);     //contorno amarelo
            strokeWeight(5);         //contorno 5
            fill(255,0,0);            //interior vermelho
            //se igual ao seguinte
            if(trials.get(trialNum+1)==trials.get(trialNum)){
                fill(0,0,255);  //interior azul
            }
        }
        else{
            //target seguinte
            if (trials.get(trialNum+1) == i){ 
                strokeWeight(0);         //sem contorno
                fill(150,150,0);          //interior amarelo claro
            }
        }
    } catch (IndexOutOfBoundsException e){/*ultimo elemento estaria "fora" da lista*/;}
    circle(target.x, target.y, target.w);   // draw target
  
    noStroke();    // next targets won't have stroke (unless it is the intended target)
}

void drawHelper(int i, Target target){
  target.x = (int)((i % 4) * (TARGET_SIZE + TARGET_PADDING) + MARGIN);
  target.y = (int)((i / 4) * (TARGET_SIZE + TARGET_PADDING) + MARGIN);
  target.w = sqrt(pow(target.x-mouseX,2) + pow(target.y-mouseY,2))*2;
  fill(0,255,0, 70);
  circle(target.x, target.y, target.w);
  noStroke();
}
