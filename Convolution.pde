static class Convolution
{
  
  static int[] convolve (int[] buffer)
  {
   //float[] a = {0.1, 0.19, 0.43, 0.19, 0.1};
   
  // float[] a = {0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1};
   int nr = 10;
   float[] a = new float[nr];
   for (int i = 0; i<nr; i++)
   {
    a[i] = (float)1 / (float) nr; 
   }
   
   int shrink = 0;
   int[] output = new int[buffer.length]; 
   
   for (int i = 0; i<buffer.length; i++)
   {
    float sum = 0; 
      if(i > buffer.length - a.length)
      {
       shrink++;
      } 
        
          for (int j=0; j<a.length-shrink; j++)
          {
          sum += a[j]*buffer[i+j]; 
          }
 
    output[i] = (int)sum;  
   } 
    
    return output;
  }
  
}
