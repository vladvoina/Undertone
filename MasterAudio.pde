// this is necessary so that we can use the File class
// these imports allow us to specify audio file formats


import beads.*;

class MasterAudio implements ClipEventListener, NoteEventListener
{


  AudioContext ac;

  //////////////////////
  // our recording objects
  RecordToSample rts;
  Sample outputSample;


  //////////////////////
  Compressor c;
  Gain finalmastergain;


  //--         Master Gain        --//
  Glide master_glide;
  Gain master_gain;


  //--         Clip Players       --//
  SamplePlayer[] clipPlayers;
  boolean sp_toggle;   //// true for p1, false for p2
  Glide[] clipPlayers_glides;
  Gain[] clipPlayers_gains;

  Glide clipPlayers_busGlide;
  Gain clipPlayers_busGain;

  String[] clip_colors;
  SampleManager clips;

  //--        Note Players      --//
  int voices;
  SamplePlayer[] notePlayers;
  Stepper stepper;
  Glide[] notePlayers_glides;
  Gain[] notePlayers_gains;

  Glide notePlayers_busGlide;
  Gain notePlayers_busGain;

  SampleManager notes;
  String[] notes_filenames;

  File recording_folder;

  public MasterAudio()
  {

    ac = new AudioContext(); // create our AudioContext


      //--         Master Gain        --//
    master_glide = new Glide(ac, 1, 20);
    master_gain = new Gain(ac, 2, master_glide);

    /////////////////////////////////////
    //--         Clip Players       --//
    ////////////////////////////////////
    // SET UP PLAYERS
    clipPlayers = new SamplePlayer[2];
    clipPlayers[0] = new SamplePlayer(ac, 2);
    clipPlayers[0].setKillOnEnd(false);
    clipPlayers[1] = new SamplePlayer(ac, 2);
    clipPlayers[1].setKillOnEnd(false);
    sp_toggle = true;

    // SET UP SAMPLES
    clip_colors = new String[] {
      "black", "blue", "brown", "green", "gray", "orange", "pink", "purple", "red", "yellow", "white"
    };
    float time1 = System.nanoTime();
    loadClips();
    float time2 = System.nanoTime();
    println("Time to load all samples in milliseconds: " + (float)(time2-time1) /pow(10, 6));

    // Set Up individual Glides and Gains
    clipPlayers_glides = new Glide[2];
    clipPlayers_glides[0] = new Glide (ac, 0.9, 200);  //// SET CROSSFADE TIMES HERE
    clipPlayers_glides[1] = new Glide (ac, 0.9, 200);  //// SET CROSSFADE TIMEs HERE

    clipPlayers_gains = new Gain[2];
    clipPlayers_gains[0] = new Gain (ac, 1, clipPlayers_glides[0]);
    clipPlayers_gains[1] = new Gain (ac, 1, clipPlayers_glides[1]);

    // SET UP Bus Glide and Gain
    clipPlayers_busGlide = new Glide(ac, 0.1, 20); // VOLUME 1
    clipPlayers_busGain = new Gain(ac, 2, clipPlayers_busGlide);

    //////////////////////////////
    /// --   Note Players   -- ///
    ///////////////////////////////
    voices = 4;
    stepper = new Stepper(voices);
    notePlayers = new SamplePlayer[voices];
    notePlayers_glides = new Glide[voices];
    notePlayers_gains = new Gain[voices];

    // note players bus gain 
    notePlayers_busGlide = new Glide(ac, 0.8, 20);  //// Note Samplers Bus
    notePlayers_busGain = new Gain(ac, voices, notePlayers_busGlide);

    loadNotesFilenames(interpreter.getInstrument());
    loadNoteSamples();


    //  loadNotes("test_instrument");

    for (int i = 0; i<notePlayers.length; i++)
    {
      notePlayers[i] = new SamplePlayer(ac, 2);
      notePlayers[i].setKillOnEnd(false);
      notePlayers_glides[i] = new Glide(ac, 1, 10); ////////////////////////////NOTE GLIDES
      notePlayers_gains[i] = new Gain(ac, 1, notePlayers_glides[i]);

      notePlayers_gains[i].addInput(notePlayers[i]);
      notePlayers_busGain.addInput(notePlayers_gains[i]);
    }
    
    c = new Compressor(ac, 1);
    c.setAttack(30);
    c.setDecay(200);
    c.setRatio(4.0);
    c.setThreshold(0.4);





    /// ------------------- ///
    /// SET UP SIGNAL CHAIN ///
    /// --------------------///

    /// Clip Players Bus -----
    clipPlayers_gains[0].addInput(clipPlayers[0]);
    clipPlayers_gains[1].addInput(clipPlayers[1]); 
    clipPlayers_busGain.addInput(clipPlayers_gains[0]);
    clipPlayers_busGain.addInput(clipPlayers_gains[1]);
    /// Note Players Bus -----

    master_gain.addInput(clipPlayers_busGain);
    master_gain.addInput(notePlayers_busGain);
    ////////////////////////////////////////////////


    try {
      // specify the recording format
      AudioFormat af = new AudioFormat(44100.0f, 
      16, 
      1, 
      true, 
      true);
      // create a buffer for the recording
      outputSample = new Sample(af, 44100);
      // initialize the RecordToSample object
      rts = new RecordToSample(ac, 

      outputSample, 
      RecordToSample.Mode.INFINITE);
    }
    catch(Exception e) {
      e.printStackTrace();
      exit();
    }
  

    ///////////////////////////////////
    finalmastergain = new Gain(ac, 1, 1);
    c.addInput(master_gain);
    
    finalmastergain.addInput(c);
    
    rts.addInput(finalmastergain);

    ac.out.addDependent(rts);

    ac.out.addInput(finalmastergain);  
    //////////////////////////////////////////////
    ac.start();







    interaction.addClipEventListener(this);
    interaction.addNoteEventListener(this);
  }

  /////////////////////////////////////////////////
  // Note preparation
  /////////////////////////////////////////////////
  void loadNotesFilenames (String instrument)
  {
    // loads all the note names from a the specified instrument folder into an array of Srings
    File folder = new File(sketchPath("") + "data/notes/" + instrument);
    notes_filenames = folder.list();
    println("Notes filenames are:");
    println(notes_filenames);
  } 


  void loadNoteSamples()
  {
    byte[] scale_pattern = interpreter.getScalePattern();
    println("loadNoteSamples: scale_pattern is:");
    println(scale_pattern);
    byte key_index  = interpreter.getKeyIndex();
    println("key index: " + key_index);

    for (int i = 0; i<3; i++) /// ITTERATE OCTAVES
    {  
      String[] samples_to_load = new String[7];

      for (int j = 0; j<scale_pattern.length; j++)
      {
        samples_to_load[j] = sketchPath("") + "data/notes/" + interpreter.getInstrument() + "/" +  notes_filenames[key_index+scale_pattern[j]+i*12]; /// Might be problematic with the path
      }
      println(i + " Octave");
      println(samples_to_load);
      notes.group("" + i, samples_to_load);
    }

    //  notes.printSampleList();
  }

  Sample grabNote (byte oct, byte note)
  {
    return notes.fromGroup("" + oct, note);
  }


  void loadClips()
  {
    for (String s : clip_colors)
    {
      clips.group(s, sketchPath("") + "data/clips/" + s);
    }
  }


  Sample grabClip(String col) /// Grabs random clip from relevant folder
  {
    return clips.randomFromGroup(col);
  }

  //  void loadNotes(String instrument)
  //  {
  //    /*
  //    // Group by octaves
  //    for(int i = 1; i<3; i++)
  //    {
  //     clips.group("" + i, sketchPath("") + "data/notes/" + instrument + "/" + i);  
  //    }
  //    */
  //    
  //    clips.group("1", sketchPath("") + "data/test/"); 
  //    
  //  }
  //  
  //  Sample grabNote()
  //  {
  //   return clips.randomFromGroup("1");  
  //  }




  void eventReceived(ClipEvent e)
  {
    println("Master Audio: Received ClipEvent with ID: " + e.getID() + " and color: " + e.getColor());

    if (sp_toggle)
    {
      clipPlayers[0].setSample(grabClip(e.getColor()));
      clipPlayers_glides[0].setValue(0.9);
      clipPlayers_glides[1].setValue(0.0);
      clipPlayers[0].setToLoopStart();
      clipPlayers[0].start();
    } 
    else
    {
      clipPlayers[1].setSample(grabClip(e.getColor()));
      clipPlayers_glides[1].setValue(0.9);
      clipPlayers_glides[0].setValue(0.0);
      clipPlayers[1].setToLoopStart();
      clipPlayers[1].start();
    }

    sp_toggle = !sp_toggle;
  }



  void eventReceived(NoteEvent e)
  {
    println("Master Audio: Received NoteEvent with ID: " + e.getID() + ", note: " + e.getNote() + ", velocity: " + e.getLoudness() + ", octave: " + e.getOctave());

    notePlayers[stepper.getSwitch()].setSample(grabNote(e.getOctave(), e.getNote()));
    notePlayers_glides[stepper.getSwitch()].setValue(e.getLoudness());
    notePlayers_glides[stepper.getKill()].setValue(0.0);
    notePlayers[stepper.getSwitch()].setToLoopStart();
    notePlayers[stepper.getSwitch()].start();

    stepper.increment();

    clipPlayers_glides[0].setValue(0.0);
    clipPlayers_glides[1].setValue(0.0);
  }
}

