// Required by mtFVA.
//
// Copyright (C) 2019 Axel von Kamp
//

import java.util.*;
import java.util.concurrent.*;
import java.lang.*;
import ilog.concert.*;
import ilog.cplex.*;
import ilog.cplex.IloCplex.*;

public class CplexFVA {
  public static boolean sav_fva(final String sav_file_name, final String par_file_name,
                                  final int[] task_index) throws IloException, InterruptedException {
    IloCplex model= new IloCplex();
    model.importModel(sav_file_name);
    IloLPMatrix lpmat= (IloLPMatrix)model.LPMatrixIterator().next();
    int num_reac= lpmat.getNcols();
    double fvalb[]= new double[num_reac];
    double fvaub[]= new double[num_reac];
    for (int i= 0; i < num_reac; i++) {
      IloNumVar var= lpmat.getNumVar(i);
      fvalb[i]= var.getLB();
      if (fvalb[i] <= -1e20) // CPX_INFBOUND currently is 1e20
        fvalb[i]= Double.NEGATIVE_INFINITY;
      fvaub[i]= var.getUB();
      if (fvaub[i] >= 1e20) // CPX_INFBOUND currently is 1e20
        fvaub[i]= Double.POSITIVE_INFINITY;
    }
    model.clearModel();
    
    SignedTaskCounter tc= new SignedTaskCounter(task_index);
    int num_th= java.lang.Runtime.getRuntime().availableProcessors();   
    if (num_reac < num_th)
      num_th= num_reac;
    Thread th[]= new Thread[num_th];
    
    for (int i= 0; i < num_th; i++) {
      CplexFVARunnable cpx= new CplexFVARunnable(tc, fvalb, fvaub, true); // fvalb and fvaub collect the results
      cpx.importModel(sav_file_name);
      if (par_file_name != null)
        cpx.readParam(par_file_name);
      cpx.setParam(IloCplex.IntParam.Threads, 1); // within each thread CPLEX runs single-threaded
      cpx.setOut(null);
      th[i]= new Thread(cpx);
      th[i].start();
    }
    
    for (int i= 0; i < num_th; i++) {
      try {
        th[i].join();
      } catch (InterruptedException iexp) {
        System.err.println("A FVA thread was interrupted unexpectedly.");
        iexp.printStackTrace(System.err);
        tc.abort();
      }
    }
    
    if (!tc.was_aborted()) {
      lpmat= model.addLPMatrix();
      lpmat.addCols(model.numVarArray(num_reac, fvalb, fvaub));
    }
    model.exportModel(sav_file_name);
    model.end();
    
    return tc.was_aborted();
  }
  
  public static void main(String[] args) throws IloException, NumberFormatException, InterruptedException {
    try {
      int[] task_index= new int[args.length - 2];
      for (int i= 2; i < args.length; i++)
        task_index[i-2]= Integer.parseInt(args[i]);
      if (sav_fva(args[0], args[1], task_index))
        System.exit(1);
    }
    catch (Exception ex) {
      ex.printStackTrace(System.err);
      System.exit(-1);
    }
  }
}
