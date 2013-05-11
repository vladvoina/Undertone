class ClipEvent extends ToneEvent
{
  
  /// Can be optimized if converted to a byte
  private String color_name;  
  
  public ClipEvent(Object source, String color_name)
  {
    super(source);
    this.color_name = color_name;
  }
  
  public String getColor()
  { return color_name; } 
 
}
