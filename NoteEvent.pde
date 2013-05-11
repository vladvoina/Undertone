class NoteEvent extends ToneEvent
{
  /// Can be optimized if converted to a byte
  private byte note_name; // C, C#, D, D#, E, E, F, F#, G, ...
  private byte   octave;
  private float  loudness;  
 
  
  public NoteEvent (Object source, byte note, byte oct, float loud)
  {
   super(source);
   
   note_name = note;
   octave = oct;
   loudness = loud;
  } 
  
  public byte getNote()
  { return note_name; }
  
  public byte getOctave()
  { return octave; }
  
  public float getLoudness()
  { return loudness; }
}
