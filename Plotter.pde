class Plotter
{
 
  int x, y, width_, height_;
  
  Plotter (int x, int y, int w, int h)
  {
   this.x = x;
   this.y = y;
   width_ = w;
   height_ = h;
    
  }
  
  void display(int[] data, int thresh)
  {
    noStroke();
    fill(0);
    rect(x, y, width_, height_);
    int max_of_data = max(data);
    strokeWeight(1);
    for (int i = 0; i<data.length; i++)
    {
     float x1 = map(i, 0, data.length, x, x+width_);
     float y1 = map(data[i] , 0, max_of_data, y+height_, y);
     stroke(i, 120, 120);
     line(x1, y+height_,x+x1, y1);  
      
    }
     
     int mapped = (int)map(thresh, 0, max(data), y+height_, y);
     
     strokeWeight(2);
     stroke(255);
     line(x, mapped, x+width_, mapped); 
    
    
  }
  
  
}
