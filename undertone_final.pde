import java.awt.event.*;
import java.util.EventObject;
import java.io.*;
// these imports allow us to specify audio file formats
import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioFileFormat.Type;
import java.util.*;


long time1 = 0;

boolean sw = false;

static int EVENT_ID = 0;

InteractionHandler interaction;
//////////////////////////////
ImageInterpreter interpreter;

//Bubble bubble;
Plotter plotter;



MasterAudio audio;





void setup()
{
  colorMode(HSB, 360, 120, 120);
   
  interaction = new InteractionHandler();
  interpreter = new ImageInterpreter();
  // size(interpreter.img.width*3, interpreter.img.height);
  size(interpreter.img.width, interpreter.img.height);
  //smooth();
  frameRate(20);
  
 // bubble = new Bubble();
  audio = new MasterAudio();
  // plotter = new Plotter(0, 0, width/3, height);
  // plotter.display(interpreter.hue_histogram, interpreter.histogram_threshold);
  //image(interpreter.filtered_img, 0, 0);
  image(interpreter.displayed_img, 0, 0);
  /*
  noStroke();
  fill(0);
  rect(0, 0, 150, 45);
  strokeWeight(1);
  for (int i = 0; i<interpreter.final_hue_gradient.length; i++)
  {
   stroke(color(interpreter.final_hue_gradient[i], 120, 120)); 
   line(i, 40, i, 0); 
  }
  */
 
}

void draw()
{
 // println(frameRate);
  /*
  background(0);
  
  fill(150, 120, 0);
  noStroke();
  rect(width/2, 150, 200, 200);
  fill(10, 170, 40);
  rect(width/2, 350, 200, 200);
  /*
    
  /*
  bubble.display();
  */ 
   interaction.mouseMoveCheck();
   interaction.update();

 
}

void mouseClicked()
{
 //audio.record.kill();
}

// event handler for mouse clicks
void keyPressed()
{
if( key == 's' || key == 'S' )
{
audio.rts.pause(true);
try{
audio.outputSample.write(sketchPath("") +
"outputSample.wav",
javax.sound.sampled.AudioFileFormat.Type.WAVE);
}
catch(Exception e){
e.printStackTrace();
exit();
}
audio.rts.kill();
exit();
}
}
