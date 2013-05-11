////////////////////////////////////////////
/// EVENTS SOURCE //////////////////////////
////////////////////////////////////////////
/// MAYBE UPDATE mouseX and Y in this thread 
class InteractionHandler implements MouseMotionListener // extends Thread 
{
  ///////////////////////////////////////////////////
  boolean running;
  long rate;
  ///////////////////////////////////////////////////
  byte note;
  byte temp;
  
  byte octave;
  byte temp_b;
  
  long time_t;
  
  /// Timer Functions Vars
  int reaction;
  Timer timer;
  int tX, tY;
  boolean flag;
  boolean timer_flag;
  int mouseMoveSlideRange;
  /////////////////////////////////////////////////////
  int mouse_X, mouse_Y; // Updated mouse X and Y
  
  
  public List<ClipEventListener> clip_listeners;
  public List<NoteEventListener> note_listeners;
  
  ////CONSTRUCTOR////
  public InteractionHandler()
  {
   ////////////////////////////////////////////////// 
   running = false;
   rate = 10;
   
   clip_listeners = new ArrayList<ClipEventListener>();
   note_listeners = new ArrayList<NoteEventListener>();
   ///////////////////////////////////////////////////
   time_t = System.nanoTime();
   note = 0;
   temp = 0;
   
   octave = 0;
   temp_b = 0;
  
   /// Timer Function Vars
   reaction = 1000; // in milliseconds
   timer = new Timer(reaction); 
   mouseMoveSlideRange = 5; 
   tX = mouseX;
   tY = mouseY;
   flag = true;
   timer_flag = true;
  
   addMouseMotionListener(this); 
 
  }
  
  public void mouseDragged (MouseEvent e) {}
  
  public void mouseMoved (MouseEvent e)
  {
   mouse_X = e.getX();
   mouse_Y = e.getY(); 
  }
  
  void addClipEventListener(ClipEventListener e)
  {
   println("Registered listener"); 
   clip_listeners.add(e); 
  }
  
  void addNoteEventListener(NoteEventListener e)
  {
   note_listeners.add(e); 
  }
      
  
  void fireClipEvent()
  {
    String colo = interpreter.getColor(mouseX, mouseY);
    
   
    
    for (ClipEventListener e: clip_listeners)
    {
     e.eventReceived(new ClipEvent(this, colo)); 
    }
  }
  
  void fireNoteEvent()
  {
    ////// INTERPRETATION TAKE PLACE HERE \\\\\\
    for (NoteEventListener e: note_listeners)
    {
     e.eventReceived(new NoteEvent(this, note, interpreter.getOctave(mouse_X, mouse_Y), interpreter.getVelocity(mouse_X, mouse_Y))); 
    }
  }
  
 
  //////////////////////////////////////////////////////////////////////////////
 
 
  
  
  
  //////////////////////////////////////////////////////////////////////////////// 
  
  
  //////////////////////////////////////////////////////////////////////////////
  synchronized void update()
  {
  
   note = interpreter.getNote(mouse_X, mouse_Y); ///COLOR STATE CHECK
   octave = interpreter.getOctave(mouse_X, mouse_Y);
   
   boolean what = false;
   
  // println("Color is: " + col + ", Temp is: " + temp); 
   
     if (note == temp)
     {
     }
      else
      {
        capture();
        fireNoteEvent();
        temp = note;
        what = true;
      }
      
      if (!what)
      {
       if (octave == temp_b)
       {
       }
        else
        {
          capture();
          fireNoteEvent();
          temp_b = octave;
          
        }
      }
   }
   
    
  // Synchronized maybe? \\
  void mouseMoveCheck()
  {
   if (abs(tX - mouseX) > mouseMoveSlideRange ||
       abs(tY - mouseY) > mouseMoveSlideRange)
   {
    tX = mouseX;
    tY = mouseY;
    flag = true;
  //  println(mouseX + ", " + mouseY);
    timer.start(); 
   }
    else if (flag) {
                    // println("START TIMER");
                    timer.start();
                    flag = false;
                    timer_flag = true;
                   } 
   
   if (timer.isFinished() && timer_flag)
   {
    capture();
    fireClipEvent();
    timer_flag = false;
   }  
  }
  
  
  
  /// used to capture the time instant
  void capture()
  {
    time1 = System.nanoTime();
  }
  /*
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  void start ()
  {
    // Set running equal to true
    running = true;
    // Print messages
    println("Starting thread (will execute every " + rate + " milliseconds.)"); 
    // Do whatever start does in Thread, don't forget this!
    super.start();
  }
 
 
  // We must implement run, this gets triggered by start()
  void run ()
  {
    while (running) {
    /////////////////////////////
    
   // interpreter.update();
    //////////////////////////////  
      try {
        sleep((long)(rate));
      } catch (Exception e) {
      }
    }
    System.out.println("Interaction thread is done!");  // The thread is done when we get to the end of run()
  }
 
 
  // Our method that quits the thread
  void quit()
  {
    System.out.println("Interaction: Quitting."); 
    running = false;  // Setting running to false ends the loop in run()
    // IUn case the thread is waiting. . .
    interrupt();
  }
  
  */
  
     
}
