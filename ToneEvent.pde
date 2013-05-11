class ToneEvent extends EventObject
{
  
  private int ID;
  
  public ToneEvent(Object source)
  {
    super(source);
    setID(); // Attributes unique ID
  }
  
  private void setID()
  {
   ID = EVENT_ID;
   EVENT_ID++;
  }
  
  public int getID()
  { return ID; }
   
  
}
