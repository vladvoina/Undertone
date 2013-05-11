public interface ToneEventListener
{
 void eventReceived (ToneEvent event); 
}
                                   // ?? Questionable
public interface ClipEventListener // extends ToneEventListener
{
 void eventReceived (ClipEvent event); 
}
                                   // ?? Questionable
public interface NoteEventListener // extends ToneEventListener
{
 void eventReceived (NoteEvent event); 
}
