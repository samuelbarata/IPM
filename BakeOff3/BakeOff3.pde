// Bakeoff #3 - Escrita de Texto em Smartwatches
// IPM 2019-20, Semestre 2
// Entrega: exclusivamente no dia 22 de Maio, até às 23h59, via Discord

// Processing reference: https://processing.org/reference/

import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

// Screen resolution vars;
float PPI, PPCM;
float SCALE_FACTOR;

// Finger parameters
PImage fingerOcclusion;
int FINGER_SIZE;
int FINGER_OFFSET;

// Arm/watch parameters
PImage arm;
int ARM_LENGTH;
int ARM_HEIGHT;

// Arrow parameters
PImage leftArrow, rightArrow;
int ARROW_SIZE;

// Study properties
String[] phrases;                   // contains all the phrases that can be tested
int NUM_REPEATS            = 2;     // the total number of phrases to be tested
int currTrialNum           = 0;     // the current trial number (indexes into phrases array above)
String currentPhrase       = "";    // the current target phrase
String currentTyped        = "";    // what the user has typed so far
char currentLetter         = 'a';
String[] typedZZZ = new String[NUM_REPEATS];


// Performance variables
float startTime            = 0;     // time starts when the user clicks for the first time
float finishTime           = 0;     // records the time of when the final trial ends
float lastTime             = 0;     // the timestamp of when the last trial was completed
float lettersEnteredTotal  = 0;     // a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0;     // a running total of the number of letters expected (correct phrases)
float errorsTotal          = 0;     // a running total of the number of errors (when hitting next)


//
int DRAG_OFFSET = 15;
ArrayList<String> dicionario;
float minX, minY, comp, alt;
String topText="NOT INTERACTIVE";
float clickX, clickY;
int row, col;    //linha e coluna clicadas
Sentence frase;
int sugestion = 9; //tecla a sugerir    NOT USED
int estado = 0;
int typed;
String last="";
ArrayList<Key> keys;

public class Key{
    public ArrayList <Character> options;
    public Integer _key;
    
    public Key(int key){
        this(key, '*');
    }
    
    public Key(int key, char c){
      _key=key;
      options = new ArrayList();
      switch(key){
          case 0:
              options.add(c);
              last="   c";
              break;
          case 1:
              options.add('a');
              options.add('b');
              options.add('c');
              last=" abc";
              break;
          case 2:
              options.add('d');
              options.add('e');
              options.add('f');
              last=" def";
              break;
          case 3:
              options.add('g');
              options.add('h');
              options.add('i');
              last=" ghi";
              break;
          case 4:
              options.add('j');
              options.add('k');
              options.add('l');
              last=" jkl";
              break;
          case 5:
              options.add('m');
              options.add('n');
              options.add('o');
              last=" mno";
              break;
          case 6:
              options.add('p');
              options.add('q');
              options.add('r');
              options.add('s');
              last="pqrs";
              break;
          case 7:
              options.add('t');
              options.add('u');
              options.add('v');
              last=" tuv";
              break;
          case 8:
              options.add('w');
              options.add('x');
              options.add('y');
              options.add('z');
              last="wxyz";
              break;
      }
    }
    
    public ArrayList<Character> getChar(){
        return options;
    }
}
public class Word{
   public ArrayList<Key> _keys;
   public String _probable = "";
   private int _passer = 0;
   public int conter = 0;
  
   
   public Word(){
       _keys = new ArrayList();
       typed=0;
   }
   public void addKey(Key key){
       if(key._key==0)
           _passer++;
       else{
           _keys.add(key);
           _passer=0;
       }
       analyse();
   }
   public boolean deleteKey(){
       _passer=0;
       if(_keys.size()==0){
           if (currentTyped.length() > 0){
               try{
                   while(currentTyped.charAt(currentTyped.length() - 1) != ' ')    //apaga a ultima palavra
                       currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
                   //apaga o espaço
                   currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
                   return true;  //esta palavra morre
               } catch(StringIndexOutOfBoundsException e){return false;}//primeira palavra
           }
       }
       if(_keys.size()>0)
           _keys.remove(_keys.size()-1);
       analyse();
       return false;
   }
   public String getWord(){
       return _probable;
   }
   public void analyse(){
       if(_keys.size()==0){
           _probable = dicionario.get(0);
           topText=_probable;
           typed=0;
           System.out.println("empty");
           return;
       }
       boolean aux = false;
       int passer = _passer;

       for(String k:dicionario){                      //percorre dicionario
           if(k.length() < _keys.size()) continue;        //compara tamanho palavras
           aux=true;
           char[] ch = k.toCharArray(); //compara inicio de palavras iguais? nao, faz home -> good -> home | page
           for(int i = 0; i<_keys.size();i++){               //compara os caracteres
               if(!isKey(_keys.get(i), ch[i])){              //verifica se as algumas das teclas primidas encaixa na sugestao
                   aux=false;
                   break;
               }
           }
           if(aux){
               if(passer>0){
                   //System.out.println(passer);
                   passer--;    //Avança para match seguinte
                   continue;
               }
               conter++;
               //System.out.println(k);
               _probable = k;
               
               //topText = _probable.substring(0,_keys.size()) + " | " + _probable.substring(_keys.size(),_probable.length());
               topText=_probable;
               typed=_keys.size();
               return;
           }
       }
       _probable = "?";
       topText=_probable;
       System.out.println("?");
   }
   private boolean isKey(Key key, char c){
       ArrayList<Character> keys = key.getChar();
       for(Character k:keys){
           if(k==c)
               return true;
       }
       return false;
   }
}
public class Sentence{
   public ArrayList<Word> _words;
   public Sentence(){
       _words = new ArrayList();
       addWord();
   }
   public void addWord(Word word){
       _words.add(word);
   }
   public void addWord(){
       addWord(new Word());
   }
   /**
     returns current word
   */
   public Word getWord(){
       return _words.get(_words.size()-1);
   }
   public void deleteChar(){
       if(_words.get(_words.size()-1).deleteKey()){
           if(_words.size() > 1)    //se n for a primeira palavra
               _words.remove(_words.size()-1);
       }
       _words.get(_words.size()-1).analyse();
   }
}


//Setup window and vars - runs once
void setup()
{
  String[] tmp;
  dicionario = new ArrayList();
  keys = new ArrayList();
  for(int k=0; k<9;k++){
    keys.add(new Key(k));
  }
  last="";
  frase = new Sentence();
  tmp = loadStrings("palavras.txt");
  for (int i=0; i<tmp.length; i++) {
      dicionario.add(tmp[i]);
  }
  
  size(900, 900);
  //fullScreen();
  frameRate(60);
  textFont(createFont("Arial", 24));  // set the font to arial 24
  noCursor();                         // hides the cursor to emulate a watch environment
  
  // Load images
  arm = loadImage("arm_watch.png");
  fingerOcclusion = loadImage("finger.png");
  leftArrow = loadImage("left.png");
  rightArrow = loadImage("right.png");
  
  // Load phrases
  phrases = loadStrings("phrases.txt");                       // load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random());  // randomize the order of the phrases with no seed
  
  // Scale targets and imagens to match screen resolution
  SCALE_FACTOR = 1.0 / displayDensity();          // scale factor for high-density displays
  String[] ppi_string = loadStrings("ppi.txt");   // the text from the file is loaded into an array.
  PPI = float(ppi_string[1]);                     // set PPI, we assume the ppi value is in the second line of the .txt
  PPCM = PPI / 2.54 * SCALE_FACTOR;               // do not change this!
  //System.out.println("PPCM: " + PPCM);

  FINGER_SIZE = (int)(11 * PPCM);
  FINGER_OFFSET = (int)(0.8 * PPCM);
  ARM_LENGTH = (int)(19 * PPCM);
  ARM_HEIGHT = (int)(11.2 * PPCM);
  ARROW_SIZE = (int)(2.2 * PPCM);
    
  minX = width/2 - 2.0*PPCM;
  minY = height/2 - 1.0*PPCM;
  comp = 4.0*PPCM;
  alt = 3.0*PPCM;
  
}

void draw()
{ 
  // Check if we have reached the end of the study
  if (finishTime != 0)  return;
 
  background(255);                                                         // clear background
  
  // Draw arm and watch background
  imageMode(CENTER);
  image(arm, width/2, height/2, ARM_LENGTH, ARM_HEIGHT);
  

  // Check if we just started the application
  if (startTime == 0 && !mousePressed)
  {
    fill(0);
    textAlign(CENTER);
    textFont(createFont("Arial", 24));  // set the font to arial 24
    text("Tap to start time!", width/2, height/2);
  }
  else if (startTime == 0 && mousePressed) nextTrial();                    // show next sentence
  
  // Check if we are in the middle of a trial
  else if (startTime != 0)
  {
    textFont(createFont("Arial", 24));
    textAlign(LEFT);
    fill(100);
    text("Phrase " + (currTrialNum + 1) + " of " + NUM_REPEATS, width/2 - 4.0*PPCM, height/2 - 8.1*PPCM);   // write the trial count
    text("Target:    " + currentPhrase, width/2 - 4.0*PPCM, height/2 - 7.1*PPCM);                           // draw the target string
    fill(0);
    text("Entered:  " + currentTyped + "|", width/2 - 4.0*PPCM, height/2 - 6.1*PPCM);                      // draw what the user has entered thus far 
    
    // Draw very basic ACCEPT button - do not change this!
    textAlign(CENTER);
    noStroke();
    fill(0, 250, 0);
    rect(width/2 - 2*PPCM, height/2 - 5.1*PPCM, 4.0*PPCM, 2.0*PPCM);
    fill(0);
    text("ACCEPT >", width/2, height/2 - 4.1*PPCM);
    
    // Draw screen areas
    //TEXT BOX####################################################################################################################################################################################################################################################################################################################################################################
    noStroke();
    fill(0);
    rect(width/2 - 2.0*PPCM, height/2 - 2.0*PPCM, 4.0*PPCM, 1.0*PPCM);
    textAlign(CENTER);
    fill(255);    
    textFont(createFont("DroidSansMono.ttf", PPCM/2.7));
    String ini="";
    String preview=" ";
    
    int i = 0;
    for(char ch: topText.toCharArray()){
        if(i<typed){
            ini+=ch;
            preview+=" ";
        } else{
            ini+=" ";
            preview+=ch;
        }
        i++;
    }    
    fill(255,255,255);
    text(ini, width/2, height/2 - 1.3 * PPCM);
    fill(20,255,20);
    text(preview, width/2, height/2 - 1.3 * PPCM);

    fill(255); 
    textFont(createFont("DroidSansMono.ttf", PPCM/3.2));
    text(last, (width/2)+(1.5*PPCM), (height/2) -1.1 * PPCM);    
    
    
    textFont(createFont("DroidSansMono.ttf", PPCM/2.15));
    
    // THIS IS THE ONLY INTERACTIVE AREA (4cm x 4cm); do not change size
    noStroke();
    fill(0);
    rect(minX, minY, comp, alt);
    //desenha os butões
    int m = 0;
    textAlign(LEFT);
    float x, y;
    int j;
    for(y = minY, i=0; i<3 ;i++,y+=alt/3){
         for(x = minX, j=0; j<3; j++, x+=comp/3, m++){
             fill(90);
             rect(x,y,comp/3, alt/3, 10);
             fill(255);
             String text = "";
             for(Character c:keys.get(m).getChar()){
                 text+=c;
             }
             //if(m==sugestion)    //NOT USED
             //    fill(0,255,0);  //NOT USED
             text(text, x, y+alt/4);
         }
    }
    
    /*
    // Write current letter
    textAlign(CENTER);
    fill(255);
    text("" + currentLetter, width/2, height/2);             // draw current letter
    
    // Draw next and previous arrows
    noFill();
    imageMode(CORNER);
    image(leftArrow, width/2 - ARROW_SIZE, height/2, ARROW_SIZE, ARROW_SIZE);
    image(rightArrow, width/2, height/2, ARROW_SIZE, ARROW_SIZE);  */
  }
  
  // Draw the user finger to illustrate the issues with occlusion (the fat finger problem)
  imageMode(CORNER);
  image(fingerOcclusion, mouseX - FINGER_OFFSET, mouseY - FINGER_OFFSET, FINGER_SIZE, FINGER_SIZE);
}

// Check if mouse click was within certain bounds
boolean didMouseClick(float x, float y, float w, float h)
{
  return (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h);
}

void mouseReleased(){
    if(estado==0){
        estado++;
        return;
    }
    if(dist(clickX, clickY, mouseX, mouseY) > DRAG_OFFSET && clickX != 0){    //começou dentro do ecrã e arrastou para algum lado
        if(mouseX>clickX){//space
            System.out.println("space");
            if(currentTyped.length() > 0)
                currentTyped+=" ";
            currentTyped+=frase.getWord().getWord(); 
            frase.addWord();
            last=" ->";
            return;
        }
        else{//backspace
            System.out.println("delete");
            frase.deleteChar();
            last=" <-";
            return;
        }
    }
    if(didMouseClick(width/2 - 2.0*PPCM, height/2 - 1.0*PPCM, 4.0*PPCM, 3.0*PPCM)){    //largou dentro do retangulo?
        checkGrid(mouseX, mouseY);
        switch(row){
          case 0: 
            switch(col){
              case 0:
              frase.getWord().addKey(new  Key(0));
              break;
              case 1: 
              frase.getWord().addKey(new  Key(1));
              break;
              case 2: 
              frase.getWord().addKey(new  Key(2));
              break;
            }
          break;
          case 1: 
            switch(col){
              case 0:
              frase.getWord().addKey(new  Key(3));
              break;
              case 1: 
              frase.getWord().addKey(new  Key(4));
              break;
              case 2: 
              frase.getWord().addKey(new  Key(5));
              break;
            }
          break;
          case 2: 
            switch(col){
              case 0:
              frase.getWord().addKey(new  Key(6));
              break;
              case 1: 
              frase.getWord().addKey(new  Key(7));
              break;
              case 2:
              frase.getWord().addKey(new  Key(8));
              break;
            }
          break;
        }
    }   
}

void mousePressed()
{
  clickX=0;
  clickY=0; 
  if (didMouseClick(width/2 - 2*PPCM, height/2 - 5.1*PPCM, 4.0*PPCM, 2.0*PPCM)) nextTrial();                         // Test click on 'accept' button - do not change this!
  else if(didMouseClick(width/2 - 2.0*PPCM, height/2 - 1.0*PPCM, 4.0*PPCM, 3.0*PPCM))  // Test click on 'keyboard' area - do not change this condition! 
  {
    // YOUR KEYBOARD IMPLEMENTATION NEEDS TO BE IN HERE! (inside the condition)
    /*
    // Test click on left arrow
    if (didMouseClick(width/2 - ARROW_SIZE, height/2, ARROW_SIZE, ARROW_SIZE))
    {
      currentLetter--;
      if (currentLetter < '_') currentLetter = 'z';                  // wrap around to z
    }
    // Test click on right arrow
    else if (didMouseClick(width/2, height/2, ARROW_SIZE, ARROW_SIZE))
    {
      currentLetter++;
      if (currentLetter > 'z') currentLetter = '_';                  // wrap back to space (aka underscore)
    }
    // Test click on keyboard area (to confirm selection)
    else
    {
      if (currentLetter == '_') currentTyped+=" ";                   // if underscore, consider that a space bar
      else if (currentLetter == '`' && currentTyped.length() > 0)    // if `, treat that as a delete command
        currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
      else if (currentLetter != '`') currentTyped += currentLetter;  // if not any of the above cases, add the current letter to the typed string
    }*/
    clickX=mouseX;
    clickY=mouseY;
  }
  else System.out.println("debug: CLICK NOT ACCEPTED");
}

void checkGrid(float x, float y){
    if(x<minX+comp/3)
      col=0;
    else if(x<minX+2*(comp/3))
      col=1;
    else
      col=2;
    
    if(y<minY+alt/3)
      row=0;
    else if(y<minY+2*(alt/3))
      row=1;
    else
      row=2;
      
    //System.out.println(col + " " + row);
}


void nextTrial()
{
  if (currTrialNum >= NUM_REPEATS) return;                                            // check to see if experiment is done
  
  // Check if we're in the middle of the tests
  else if (startTime != 0 && finishTime == 0)                                         
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + NUM_REPEATS);
    System.out.println("Target phrase: " + currentPhrase);
    System.out.println("Phrase length: " + currentPhrase.length());
    System.out.println("User typed: " + currentTyped);
    System.out.println("User typed length: " + currentTyped.length());
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim()));
    System.out.println("Time taken on this trial: " + (millis() - lastTime));
    System.out.println("Time taken since beginning: " + (millis() - startTime));
    System.out.println("==================");
    lettersExpectedTotal += currentPhrase.trim().length();
    lettersEnteredTotal += currentTyped.trim().length();
    errorsTotal += computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
    typedZZZ[currTrialNum] = currentTyped;
  }
  
  // Check to see if experiment just finished
  if (currTrialNum == NUM_REPEATS - 1)                                           
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime));
    System.out.println("Total letters entered: " + lettersEnteredTotal);
    System.out.println("Total letters expected: " + lettersExpectedTotal);
    System.out.println("Total errors entered: " + errorsTotal);

    float wpm = (lettersEnteredTotal / 5.0f) / ((finishTime - startTime) / 60000f);   // FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal * .05;                                 // no penalty if errors are under 5% of chars
    float penalty = max(0, (errorsTotal - freebieErrors) / ((finishTime - startTime) / 60000f));
    
    System.out.println("Raw WPM: " + wpm);
    System.out.println("Freebie errors: " + freebieErrors);
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm - penalty));                         // yes, minus, because higher WPM is better: NET WPM
    System.out.println("==================");
    
    printResults(wpm, freebieErrors, penalty);
    
    currTrialNum++;                                                                   // increment by one so this mesage only appears once when all trials are done
    return;
  }

  else if (startTime == 0)                                                            // first trial starting now
  {
    System.out.println("Trials beginning! Starting timer...");
    startTime = millis();                                                             // start the timer!
  } 
  else currTrialNum++;                                                                // increment trial number

  lastTime = millis();                                                                // record the time of when this trial ended
  currentTyped = "";                                                                  // clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum];                                              // load the next phrase!
}

// Print results at the end of the study
void printResults(float wpm, float freebieErrors, float penalty)
{
  background(0);       // clears screen
  
  textFont(createFont("Arial", 16));    // sets the font to Arial size 16
  fill(255);    //set text fill color to white
  text(day() + "/" + month() + "/" + year() + "  " + hour() + ":" + minute() + ":" + second(), 100, 20);   // display time on screen
  
  text("Finished!", width / 2, height / 2); 
  
  int h = 20;
  for(int i = 0; i < NUM_REPEATS; i++, h += 40 ) {
    text("Target phrase " + (i+1) + ": " + phrases[i], width / 2, height / 2 + h);
    text("User typed " + (i+1) + ": " + typedZZZ[i], width / 2, height / 2 + h+20);
  }
  
  text("Raw WPM: " + wpm, width / 2, height / 2 + h+20);
  text("Freebie errors: " + freebieErrors, width / 2, height / 2 + h+40);
  text("Penalty: " + penalty, width / 2, height / 2 + h+60);
  text("WPM with penalty: " + max((wpm - penalty), 0), width / 2, height / 2 + h+80);

  saveFrame("######-GX-TX-G4-"+max((wpm - penalty), 0)+".png");    // saves screenshot in current folder    
}

// This computes the error between two strings (i.e., original phrase and user input)
int computeLevenshteinDistance(String phrase1, String phrase2)
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++) distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++) distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
