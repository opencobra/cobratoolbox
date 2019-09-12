// Required by mtFVA.
//
// Copyright (C) 2019 Axel von Kamp
//

import java.util.*;
import java.util.concurrent.*;
import ilog.concert.*;
import ilog.cplex.*;
import ilog.cplex.IloCplex.*;

public class CplexFVARunnable extends IloCplex implements Runnable {
  static final String[] opt_type= {"minimizing", "maximizing"};
  static final double[] coeff= {1, -1};
  
  SignedTaskCounter tc;
  double[][] fva_res;
  boolean qc_messages; // use 'false' to suppress messages related to solution quality
  
  public CplexFVARunnable(SignedTaskCounter tc, final double[] fvalb, final double[] fvaub,
                          boolean qc_messages_in) throws IloException {
    super();
    this.tc= tc;
    fva_res= new double[2][];
    fva_res[0]= fvalb;
    fva_res[1]= fvaub;
    addMinimize(); // set sense to 'minimze'
    qc_messages= qc_messages_in;
  }
  
  public void run() {
    IloLPMatrix lpmat= (IloLPMatrix)LPMatrixIterator().next();
    IloNumVar nv= null;
    while (true) {
      int current_reac= tc.getNextTask(); // run maximization and minimization for this reaction
      if (current_reac == 0) // no more tasks available
        break;
      int sense; // 0: minimze, 1: maximize
      if (current_reac < 0) {
        sense= 0;
        current_reac= -current_reac;
      }
      else
        sense= 1;
      current_reac--; // reactions are counted from 1 to use the sign to represent the sense
      try {
        nv= lpmat.getNumVar(current_reac);
      }
      catch (ilog.concert.IloException ex) {
        System.out.println("Illegal reaction " + current_reac + " selected for FVA!");
        tc.abort();
      }
//       System.out.println(String.format("%d ", current_reac));
      if (tc.was_aborted())
        break;
      try {
        boolean resolve= false;
        String message= null;
        double objValue1= Double.NaN, kappa1= Double.POSITIVE_INFINITY;
        
        getObjective().setExpr(prod(coeff[sense], nv));
        solve();
        
        if (getStatus().equals(Status.Optimal)) {
          if (getParam(IloCplex.BooleanParam.NumericalEmphasis)) { // only assess solution quality if NumericalEmphasis in on
            IloCplex.Quality solq= getQuality(IloCplex.QualityType.Kappa);
            if (solq.getValue() > 1e9) { // perhaps set this threshold via some appropriate CPLEX parameter
              kappa1= solq.getValue();
              if (qc_messages)
                message= String.format("While %s reaction %d the kappa value %1.1e occured (staus: optimal);",
                opt_type[sense], current_reac, kappa1);
              objValue1= getObjValue();
              resolve= true;
            }
            else
              fva_res[sense][current_reac]= coeff[sense]*getObjValue();
          }
          else
            fva_res[sense][current_reac]= coeff[sense]*getObjValue();
        }
        else {
          // when unbounded there is no need to store the result as it must be the same
          // as the flux limit that was used to set up the FVA
          if (getStatus().equals(Status.Unbounded)) {
            if (getParam(IloCplex.BooleanParam.NumericalEmphasis)) { // only assess solution quality if NumericalEmphasis in on
              IloCplex.Quality solq= getQuality(IloCplex.QualityType.Kappa);
              if (solq.getValue() > 1e8) { // 1e8 selected as suggested by CPLEX documentation
                kappa1= solq.getValue();
                if (qc_messages)
                  message= String.format("While %s reaction %d the kappa value %1.1e occured (staus: unbounded);",
                  opt_type[sense], current_reac, kappa1);
              }
            }
          }
          else {
            message= String.format("While %s reaction %d the status %s occured;",
            opt_type[sense], current_reac, getStatus().toString());
            resolve= true;
          }
        }
        
        if (resolve && !tc.was_aborted()) {
          int advInd= getParam(IloCplex.IntParam.AdvInd);
          boolean preInd= getParam(IloCplex.BooleanParam.PreInd);
          setParam(IloCplex.IntParam.AdvInd, 0); // advanced start off
          setParam(IloCplex.BooleanParam.PreInd, false); // presolve off
          solve(); // try again without warm start information and presolve disabled
          setParam(IloCplex.IntParam.AdvInd, advInd);
          setParam(BooleanParam.PreInd, preInd);
          IloCplex.Quality solq= getQuality(IloCplex.QualityType.Kappa);
          if (getStatus().equals(Status.Optimal)) {
            if (message != null)
              System.out.println(message + " solution with kappa " + String.format("%1.1e", solq.getValue())
              + " found after retry; difference between objective values: " + String.format("%1.1e", Math.abs(objValue1 - getObjValue())));
            if (solq.getValue() <= kappa1)
              fva_res[sense][current_reac]= coeff[sense]*getObjValue();
            else
              fva_res[sense][current_reac]= coeff[sense]*objValue1;
          }
          else
            if (getStatus().equals(Status.Unbounded))
              System.out.println(message + " status is unbounded after retry with kappa "  + String.format("%1.1e", solq.getValue()));
            else {
              fva_res[sense][current_reac]= Double.NaN;
              System.out.println(message + " no solution after retry with status " + getStatus().toString() + ", aborting FVA!");
              tc.abort();
            }
        }
      } catch (ilog.concert.IloException ex) {
        fva_res[sense][current_reac]= Double.NaN;
        System.out.println("An exception occured while " + opt_type[sense] + " reaction " + current_reac + " , aborting FVA!");
        ex.printStackTrace(System.err);
        tc.abort();
      }
    } // while (true)
    end(); // frees memory allocated by the CPLEX C library
  }
}
