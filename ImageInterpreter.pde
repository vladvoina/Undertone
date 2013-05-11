class ImageInterpreter
{
  
  PImage img;
  PImage displayed_img;
  PImage filtered_img;
  
  String imgName;
  
  File folder;
  String[] instrument_list;
 
  byte key_index;  int nr_of_keys;
  byte scale_pattern; byte nr_of_scales;
  byte instrument; byte nr_of_instr;
  
  byte white_slide_percentage, black_slide_percentage, gray_slide_percentage;
  byte white_slide, black_slide, gray_slide;
  
  final byte[] major_pattern = {0, 2, 4, 5, 7, 9, 11};
  final byte[] minor_pattern = {0, 2, 3, 5, 7, 8, 10};
  
  int avgHUE, avgSAT, avgBRI, hueRange, satRange, briRange;
  int[] hueSlices;
  int[] hue_histogram;
  int histogram_threshold;
  
  int hue_gradient_size;
  int[] final_hue_gradient;
  byte[] note_values; byte nr_of_notes;
  byte[] octave_values; byte nr_of_octaves;
  
  float velocity_low, velocity_high;
   
  ImageInterpreter()
  { // --- DONT FORGET TO CAST VARIABLES TO INTS or BYTE (whole numbers)
   
    imgName = "colors2.jpg";
    try
    {
    img = loadImage(sketchPath("") + "data/image/" + imgName);
    img.loadPixels();
    
    filtered_img = loadImage(sketchPath("") + "data/image/" + imgName);
    filtered_img.loadPixels();
   
    displayed_img = loadImage(sketchPath("") + "data/image/" + imgName);
    displayed_img.loadPixels();  
    } catch (Exception e) { println("ImageInterpreter: No such file: " + imgName + " in data/image/."); }
    
    ///////////// call instrument load here     <-------------------------
    loadInstruments();
    
    avgHUE = 0; hueRange = 360; nr_of_keys = 12;
    avgSAT = 0; satRange = 120; nr_of_instr = (byte)instrument_list.length; 
    avgBRI = 0; briRange = 120; nr_of_scales = 2; 
    
    white_slide_percentage = 10; // in percentage // 
    gray_slide_percentage = 10;
    black_slide_percentage = 15;
    white_slide = (byte) map (white_slide_percentage, 0, 100, 0, briRange);
    gray_slide =  (byte) map (gray_slide_percentage, 0, 100, 0, briRange);
    black_slide = (byte) map (black_slide_percentage, 0, 100, 0, briRange);
    
    hueSlices = new int[] {15, 47, 64, 148, 264, 345};  
    
    hue_histogram = new int[hueRange+1];
    histogram_threshold = 0;
    hue_gradient_size = 0;
    
    ///////////////////
    velocity_low = 0.1;
    velocity_high = 0.4;
    //////////////////////
    nr_of_notes = 7;
    nr_of_octaves = 3;
   
    ///////////////
    /// ROUTINES //
    ///////////////
    averageHueSatBri();
    calcKey();
    calcScale();
    calcInstr();
  
    calcHistogram();
    filterImage();
    blurImage();
    
    calcGradientSize();
    calcFinalGradient();
    calcNotes();
    calcOctaves();
  }
  
  
  void averageHueSatBri()
  {
   for (int i = 0; i<img.pixels.length; i++)
   {
    avgHUE += (hue(img.pixels[i]));
    avgSAT += (saturation(img.pixels[i]));
    avgBRI += (brightness(img.pixels[i]));   
   } 
    avgHUE = int(float(avgHUE) / float(img.pixels.length)); println("avgHue is: " + avgHUE);
    avgSAT = int(float(avgSAT) / float(img.pixels.length)); println("avgSat is: " + avgSAT);
    avgBRI = int(float(avgBRI) / float(img.pixels.length)); println("avgBri is: " + avgBRI); 
  }
  
  void calcKey()
  {
    int segmentSize = (int)hueRange/nr_of_keys; 
    for (int i = 0; i<nr_of_keys; i++)
    {
      if (avgHUE >= i*segmentSize && avgHUE < (i+1)*segmentSize)
      {
       key_index = (byte)i;  
      }
    }
    
    println("key index is: " + key_index);  
  }
  
  void loadInstruments()
  {
    
   folder = new File(sketchPath("") + "data/notes/");
   instrument_list = folder.list();
   println("Instruments are:");
   println(instrument_list);
  }
  
  void calcInstr()
  {
    int segmentSize = (int)satRange/nr_of_instr;
    for (int i = 0; i<nr_of_instr; i++)
    {
      if (avgSAT >= i*segmentSize && avgSAT < (i+1)*segmentSize)
      {
       instrument = (byte)i;  
      }
    }
    println("instrument index is: " + instrument); 
  }
  
  void calcScale()
  {
    int segmentSize = (int)briRange/nr_of_scales;
    for (int i = 0; i<nr_of_scales; i++)
    {
      if (avgBRI >= i*segmentSize && avgBRI < (i+1)*segmentSize) ///problem with values inbetween the intervals
      {
       scale_pattern = (byte)i;  
      }
    }
    println("scale pattern index is: " + scale_pattern); 
    
  }
  
  byte[] getScalePattern()
  {
    if (scale_pattern == 0)
    { return minor_pattern; }
      else return major_pattern;
  }
  
  byte getKeyIndex()
  {
   return key_index; 
  }
  
  String getInstrument()
  {
   return instrument_list[instrument]; 
  }
  
  String getColor(int mouse_x, int mouse_y)
  {
   String col;
   color c = img.pixels[mouse_y*img.width+mouse_x];
   int hue_ = (int)hue(c);
   int sat_ = (int)saturation(c);
   int bri_ = (int)brightness(c);
   println ("hue, sat, bri: " + hue_ + ", " + sat_ + ", " + bri_ + ". Slides are (black, white) " + black_slide + ", " + white_slide);
     ////////////////////////// hard coded ////
     if (sat_ >= 0 && sat_ <= 18 &&
         bri_ <= briRange && bri_ >= (briRange - white_slide))/// Check if White
     { col = "white"; }
     else if (bri_ >= 0 && bri_ <= black_slide)              /// Check if Black
          { col = "black";  }     
          else if (sat_ >= 0 && sat_ <= gray_slide)          //// Check if Gray 
               { col = "gray"; } 
                 else 
                 {   
                     if (hue_ >= 0 && hue_ <= hueSlices[0]) /// First RED
                     {
                      if (sat_ < 84)  /// check if Pink
                      { col = "pink"; }
                       else { col = "red"; }
                     }
                     else if (hue_ > hueSlices[0] && hue_ <= hueSlices[1])
                     {
                      if (bri_ < 75) // check if brown
                      { col = "brown"; }
                       else
                       { col = "orange"; }
                     }
                     else if (hue_ > hueSlices[1] && hue_ <= hueSlices[2])
                     {col = "yellow";}
                     else if (hue_ > hueSlices[2] && hue_ <= hueSlices[3])
                     {col = "green";}
                     else if (hue_ > hueSlices[3] && hue_ <= hueSlices[4])
                     {col = "blue";}
                     else if (hue_ > hueSlices[4] && hue_ <= hueSlices[5])
                     {col = "purple";}
                     else if (hue_ > hueSlices[5] && hue_ <= hueRange) /// Second Red
                     {/// check if pink
                      col = "red";
                     } else {col = "who da fuck knows";}
                  }
  
   return col;   
    
  }
  
  void calcHistogram()
  {
   for (int i=0; i<img.pixels.length; i++)
   {
    hue_histogram[(int)hue(img.pixels[i])] += 1;
   }
   
   hue_histogram = Convolution.convolve(hue_histogram); 
   histogram_threshold = int (avg(hue_histogram) * 0.7);  //////////// threshold
   
  }
  
  int nearestValidHue(int h)
  {
    int forward = 0, backwards = 0;
    int f_step = h; 
    int b_step = h;
    
    boolean f_found = false;
    boolean b_found = false;
  
    // forward search 
    while(!f_found && f_step < hueRange)
    {
      if(hue_histogram[f_step] <= histogram_threshold)
      { f_step++;
        forward++;
      } else
        {
         f_found = true;
        }
    }
   
    // backwards search
    while(!b_found && b_step >= 2)
    {
      if(hue_histogram[b_step] <= histogram_threshold)
      { b_step--;
        backwards++;
      } else
        {
         b_found = true;
        }
    }  
  
    
     
    if (b_found && f_found)
    {
     int winner = min(backwards, forward);
     if(winner == backwards)
     { return b_step; }
         else return f_step; 
    } else if (b_found)
           { return b_step; }
             else return f_step;
     
    
  }
  
  
  void filterImage()
  {
    for(int i = 0; i<img.pixels.length; i++)
    {
      if (hue_histogram[(int)hue(img.pixels[i])] > histogram_threshold)
      {
       int c = (int)hue(img.pixels[i]);
       filtered_img.pixels[i] = color (c, 120, 120);
         
      }
      else
      {
       int h = nearestValidHue((int) hue(img.pixels[i])); // println("Nearest Valid Hue of: " + (int)hue(img.pixels[i]) " is: " + h);
       filtered_img.pixels[i] = color(h, 120, 120); //// tricky bit 
      }
      
    }
    
    filtered_img.updatePixels();
    
  }
  
  void calcGradientSize()
  {
   for(int i = 0; i<hue_histogram.length; i++)
   {
    if (hue_histogram[i] > histogram_threshold)
    {
     hue_gradient_size++; 
    }
    
   }
   println("final gradient size is: " + hue_gradient_size); 
  }
  
  void calcFinalGradient()
  {
   final_hue_gradient = new int[hue_gradient_size];
   int step = 0; 
   for(int i = 0; i<hue_histogram.length; i++)
   {
     if (hue_histogram[i] > histogram_threshold)
     {
      final_hue_gradient[step] = i;
      step++;
     }
   }
    colorMode(HSB, 360, 120, 120); 
    
  }
  
  void calcNotes()
  {
    note_values = new byte[final_hue_gradient.length];
    int slice_size = int((float)note_values.length/(float)nr_of_notes);
    
    for (int i = 0; i<note_values.length; i++)
    {
       for (int j = 0; j<nr_of_notes-1; j++)
       {
        if (i >= j*slice_size && i < (j+1)*slice_size)
        {
          note_values[i] = (byte) j;
        }
       }
       
       if (i >= (nr_of_notes-1)*slice_size && i < note_values.length)
       {
         note_values[i] = (byte) (nr_of_notes-1);
       }
    }
    
   }
   
   byte getNote(int mouse_x, int mouse_y)
   {
     int h = (int) hue(filtered_img.pixels[mouse_y*filtered_img.width + mouse_x]);
     byte note = 0;
     for (int i = 0; i<final_hue_gradient.length; i++)
     {
      if (h == final_hue_gradient[i])
      {
       note = note_values[i];
      }  
       
     }
     return note;
     
   }
  
    
    float getVelocity (int mouse_x, int mouse_y)
    {
      println("getVelocity of color: " + hue(img.pixels[mouse_y*img.width+mouse_x]) + ", " +
      saturation(img.pixels[mouse_y*img.width+mouse_x]) + ", " + brightness(img.pixels[mouse_y*img.width+mouse_x]));
      
      float vel = map (saturation(img.pixels[mouse_y*img.width+mouse_x]), 0, 120, velocity_low, velocity_high);
          
      return vel;
    }
    
    void calcOctaves()
    {
      octave_values = new byte[briRange+1];
      int oct_slice = (int) briRange/nr_of_octaves;
      
      for(int i = 0; i<octave_values.length; i++)
      {
        if (i >= 0 && i < oct_slice)
        {
          octave_values[i] = 0;
        }
        if (i >= oct_slice && i < oct_slice*2)
        {
          octave_values[i] = 1; 
        }
        if (i >= oct_slice*2 && i<= oct_slice*3)
        {
          octave_values[i] = 2; 
        }
      }
    }
    
    byte getOctave(int mouse_x, int mouse_y)
    {
      return  octave_values[int(brightness(img.pixels[mouse_y*img.width + mouse_x]))];
    }
    
    
   
  
  
  
   int avg(int[] data)
   {
   int average = 0;
   for (int i = 0; i<data.length; i++)
   {
    average += data[i];
   }
   
   return (int) (average/ (float)data.length); 
    
  }
  
   color convolution(int x, int y, float[][] matrix, int matrixsize, PImage img)
   {
      float htotal = 0.0;
      float stotal = 0.0;
      float btotal = 0.0;
      int offset = matrixsize / 2;
      // Loop through convolution matrix
      for (int i = 0; i < matrixsize; i++){
        for (int j= 0; j < matrixsize; j++){
          // What pixel are we testing
          int xloc = x+i-offset;
          int yloc = y+j-offset;
          int loc = xloc + img.width*yloc;
          // Make sure we have not walked off the edge of the pixel array
          loc = constrain(loc,0,img.pixels.length-1);
          // Calculate the convolution
          // We sum all the neighboring pixels multiplied by the values in the convolution matrix.
          htotal += (red(img.pixels[loc]) * matrix[i][j]);
          stotal += (green(img.pixels[loc]) * matrix[i][j]);
          btotal += (blue(img.pixels[loc]) * matrix[i][j]);
        }
      }
      // Make sure RGB is within range
      htotal = constrain(htotal,0,255);
      stotal = constrain(stotal,0,255);
      btotal = constrain(btotal,0,255);
      // Return the resulting color
      return color(htotal,stotal,btotal);
    }
    
    void blurImage()
    {
      colorMode(RGB, 255);
      int matrixsize = 3;                     

      float[][] matrix;   
    
      matrix = new float[matrixsize][matrixsize];

      for(int i = 0; i<matrixsize; i++)
      {
       for (int j = 0; j<matrixsize; j++)
       {
        matrix[i][j] = 1.f/float(matrixsize*matrixsize);
       } 
      }
      
      
     
         // Begin our loop for every pixel
      for (int x = 0; x < img.width; x++) {
        for (int y = 0; y < img.height; y++ ) {
          // Each pixel location (x,y) gets passed into a function called convolution() 
          // which returns a new color value to be displayed.
          color c = convolution(x,y,matrix,matrixsize,img);
          int loc = x + y*img.width;
          img.pixels[loc] = c;
        }
      }
      img.updatePixels();
     
      
      
    }
  
  
  
  
  
  
  
  
  
}
