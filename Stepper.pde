class Stepper
{
 
 int switch_, kill;
 int steps;
 
 public Stepper(int steps)
 {
  this.steps = steps;
   
  switch_ = 0;
  kill = 1;
 }

 void increment()
 {
  switch_ = (switch_ + 1) % steps;
  kill = (switch_ + 1) % steps; 
 }
 
 int getSwitch()
 {
   return switch_;
 }
 
 int getKill()
 {
   return kill;
 }
 
 void reset()
 {
   switch_ = 0;
   kill = switch_ + 1;
   
 }
   
}
