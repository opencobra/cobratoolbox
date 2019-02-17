// Required by mtFVA.
//
// Copyright (C) 2019 Axel von Kamp
//

public class SignedTaskCounter {
  int next_task;
  int task_number;
  boolean aborted;
  final int[] task_index;
  
  public SignedTaskCounter(final int[] task_index) {
    next_task= 0;
    task_number= task_index.length;
    aborted= false;
    this.task_index= task_index;
  }

  public synchronized int getNextTask() {
    int return_task= 0;
    if (next_task < task_number)    
      return_task= task_index[next_task++];
    
    return return_task;
  }
  
  public void abort() {
    task_number= 0;
    aborted= true;
  }
  
  public boolean was_aborted() {
    return aborted;
  }
}
