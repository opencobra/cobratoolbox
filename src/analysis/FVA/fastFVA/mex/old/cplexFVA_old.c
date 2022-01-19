/*
 *    fastFVA - C language implementation for CPLEX.
 *    Optimized fluxVariability (FVA) code for CPLEX.
 *    Author: Steinn Gudmundsson, 3.22.2010
 *    Contributor: Laurent Heirendt, 4.2016
 *
 * Usage:
 *   [minFlux, maxFlux,optsol,ret,details]=cplexFVAc(c,A,b,csense,lb,ub,optPercent,objective,rxns)
 *
 * Example:
 *   load modelRecon1Biomass
 %   [m,n]=size(model.S);
 *   [minFlux, maxFlux,optsol,ret]=cplexFVAc(model.c,model.S,model.b, char('E'*ones(m,1)), model.lb, model.ub,90,'max',(1:n)');
 *
 * Compilation (Win64, Visual Studio Express 2008):
 *   mex -largeArrayDims -IC:\Progra~1\ILOG\CPLEX121\include\ilcplex cplexFVAc.c C:\Progra~1\ILOG\CPLEX121\lib\x64_windows_vs2008\stat_mda\cplex121.lib C:\Progra~1\ILOG\CPLEX121\lib\x64_windows_vs2008\stat_mda\ilocplex.lib
 *
 * The FVA code builds heavily upon CPLEXINT by Mato Baotic.
 *
 *    CPLEXINT      MATLAB MEX INTERFACE FOR CPLEX, ver. 3.0
 *
 *    Copyright (C) 2001-2005  Mato Baotic
 *    Copyright (C) 2006       Michal Kvasnica
 *    Copyright (C) 2016       Laurent Heirendt
 *
 *    This library is free software; you can redistribute it and/or
 *    modify it under the terms of the GNU Lesser General Public
 *    License as published by the Free Software Foundation; either
 *    version 2.1 of the License, or (at your option) any later version.
 *
 *    This library is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *    Lesser General Public License for more details.
 *
 *    You should have received a copy of the GNU Lesser General Public
 *    License along with this library; if not, write to the Free Software
 *    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Notes        This file requires CPLEX (9.0 or higher)
 *              and MATLAB (6.0 or higher) to be compiled
 *
 *
 * CPLEXINT (C) Sep 24 2005 by Mato Baotic
 * Contributor: Dr. Laurent Heirendt, LCSB
 * All rights reserved.
 */

/* MATLAB declarations. */
#include <stdlib.h>
#include <math.h>
#include <matrix.h>
#include <time.h>
#include <cplex.h>
#include "mex.h"
#include <string.h>
#include <time.h>

/* FVA constants */
#define FVA_MIN_OBJECTIVE  1

/* FVA return codes */
#define FVA_SUCCESS        0
#define FVA_INIT_FAIL      1
#define FVA_MODIFIED_FAIL  2

#define CPLEXINT_VERSION "3.0"
#define CPLEXINT_COPYRIGHT "Copyright (C) 2001-2016  Mato Baotic & Dr. Laurent Heirendt"

static CPXENVptr env = NULL;
static CPXFILEptr LogFile = NULL;

static int NUM_CALLS_CPLEXINT = 0;  /* number of calls to CPLEXINT before clearing
                                       environment CPXenv and releasing the license */
static int FIRST_CALL_CPLEXINT = 1; /* is this first call to CPLEXINT */

/* MEX Input Arguments
mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
*/
enum {F_IN_POS,
      A_IN_POS,
      B_IN_POS,
      CSENSE_IN_POS,
      LB_IN_POS,
      UB_IN_POS,
      OPT_PERCENT_IN_POS,
      OBJECTIVE_IN_POS,
      RXNS_IN_POS,
      NUM_THREAD_IN,
      CPLEX_PARAMS,
      VALUES_CPLEX_PARAMS,
      RXNS_OPTMODE_IN,
      LOGFILE_DIR_IN,
      PRINTLEVEL_IN_POS,
      MAX_NUM_IN_ARG
      };

/* Number of input arguments */
#define MIN_NUM_IN_ARG        15

#define F_IN                  prhs[F_IN_POS]
#define A_IN                  prhs[A_IN_POS]
#define B_IN                  prhs[B_IN_POS]
#define CSENSE_IN             prhs[CSENSE_IN_POS]
#define LB_IN                 prhs[LB_IN_POS]
#define UB_IN                 prhs[UB_IN_POS]
#define OPT_PERCENT_IN        prhs[OPT_PERCENT_IN_POS]
#define OBJECTIVE_IN          prhs[OBJECTIVE_IN_POS]
#define RXNS_IN               prhs[RXNS_IN_POS]
#define NUM_THREAD_IN         prhs[NUM_THREAD_IN]
#define CPLEX_PARAMS          prhs[CPLEX_PARAMS]
#define VALUES_CPLEX_PARAMS   prhs[VALUES_CPLEX_PARAMS]
#define RXNS_OPTMODE_IN       prhs[RXNS_OPTMODE_IN]
#define PRINTLEVEL_IN         prhs[PRINTLEVEL_IN_POS]

/* MEX Output Arguments */
enum {MINFLUX_OUT_POS,
      MAXFLUX_OUT_POS,
      OPTSOL_OUT_POS,
      RET_OUT_POS,
      FBA_SOL_OUT_POS,
      FVA_MIN_OUT_POS,
      FVA_MAX_OUT_POS,
      STATUS_MIN_OUT_POS,
      STATUS_MAX_OUT_POS,
      MAX_NUM_OUT_ARG
      };

/* Number of output arguments */
#define MIN_NUM_OUT_ARG       4
#define MAX_NUM_OUT_ARG       9

#define MINFLUX_OUT           plhs[MINFLUX_OUT_POS]
#define MAXFLUX_OUT           plhs[MAXFLUX_OUT_POS]
#define OPTSOL_OUT            plhs[OPTSOL_OUT_POS]
#define RET_OUT               plhs[RET_OUT_POS]
#define FBA_SOL_OUT           plhs[FBA_SOL_OUT_POS]
#define FVA_MIN_OUT           plhs[FVA_MIN_OUT_POS]
#define FVA_MAX_OUT           plhs[FVA_MAX_OUT_POS]
#define STATUS_MIN_OUT        plhs[STATUS_MIN_OUT_POS]
#define STATUS_MAX_OUT        plhs[STATUS_MAX_OUT_POS]

#define MAX_STR_LENGTH        1024
#define OPT_PERCENTAGE        90 /* confidence threshold if not specified */

#define PRINT_WARNING         "Warning:"

#if !defined(MAX)
#define MAX(A, B)   ((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define MIN(A, B)   ((A) < (B) ? (A) : (B))
#endif

/* This hack is because Matlab R14 can crash on Linux due to the call to
   mexErrMsgTxt() */
#define TROUBLE_mexErrMsgTxt(A)    mexPrintf(A); mexPrintf("\n"); return
/* Here is the original version
#define TROUBLE_mexErrMsgTxt(A)    mexErrMsgTxt(A)
*/

/* this is for TRYING to release the CPLEX license when pressing CTRL-C */
#define RELEASE_CPLEX_LIC   1

#define Nmarkers 10

/* Retrieve the vector and return the lengh of the vector */
int get_vector_full(const mxArray *IN, double **outval)
{
  int i;
  int m = mxGetM(IN);
  int n = mxGetN(IN);
  double *matval = NULL;
  double *in = mxGetPr(IN);

  matval = (double *)mxCalloc(m*n, sizeof(double));

  for (i = 0; i < m*n; i++) matval[i] = in[i];

  *outval = matval;
  return(m);
}

/* lenate 2 strings */
const char* concat2(const char *s1, const char *s2)
{
    size_t len1 = strlen(s1);
    size_t len2 = strlen(s2);
    char *result = malloc(len1+len2+1);
    memcpy(result, s1, len1);
    memcpy(result+len1, s2, len2+1);
    return result;
}

/* Concatenate 3 strings */
const char* concat3(const char *s1, const char *s2, const char *s3)
{
    size_t len1 = strlen(s1);
    size_t len2 = strlen(s2);
    size_t len3 = strlen(s3);
    char *result = malloc(len1+len2+len3+1);
    memcpy(result, s1, len1);
    memcpy(result+len1, s2, len2+1);
    memcpy(result+len1+len2, s3, len3+1);
    return result;
}

/* Display CPLEX error code message */
void dispCPLEXerror(CPXENVptr env, int status)
{
    char errmsg[MAX_STR_LENGTH];
    char *errstr;

    errstr = (char *)CPXgeterrorstring (env, status, errmsg);
    if ( errstr != NULL ) {
        mexPrintf("%s",errmsg);
    } else {
        mexPrintf("CPLEX Error %5d:  Unknown error code.\n", status);
    }
}

/* FVA Wrapper */
int _fva(CPXENVptr env, CPXLPptr lp, double* minFlux, double* maxFlux, double* optSol,
         double* FBAsol, double* FVAmin, double* FVAmax, mwSize n_constr, mwSize n_vars,
         double optPercentage, int objective, const double* rxns, int nrxn,
         const mxArray* namesCPLEXparams, const mxArray *valuesCPLEXparams,
         const double* rxnsOptMode, double* statussolmin,  double* statussolmax, int printLevel) {

    int           status;
    int           rmatbeg[2];
    int*          ind = NULL;
    double*       val = NULL;
    int           i, j, k, iRound;
    char          sense;
    double        TargetValue = 0.0, objval = 0;
    const double  tol = 1.0e-6;

    clock_t       markersBegin[Nmarkers], markersEnd[Nmarkers];
    double        markers[Nmarkers];
    bool          monitorPerformance = false;

    const char    *nameParam;
    int           countParam = 0;          /* number of non-zero elements */
    double        *valuesCPLEX = NULL;
    int           numStatus, numParam;
    double        *valueCPLEXdbl = NULL;

    int           statusint = -1, getStatusint = MAX_STR_LENGTH;
    int           statusdbl = -1, getStatusdbl = MAX_STR_LENGTH;
    double        getParamdbl = 0.0;
    int           getParamint = 0;
    bool          flag = true;
    bool          performOptim = true;     /* switch to perform optimizations */

    /*  Setting of the parameters for CPLEX*/
    countParam = get_vector_full(valuesCPLEXparams, &valuesCPLEX);

    if(countParam > 0) {
        if (printLevel > 0) {
            mexPrintf("    -- Setting %i CPLEX parameters ... \n", countParam);
        }
        for(j = 0; j < countParam; j++)
        {
          /* Reinitialisation for each new parameter*/
          statusint     = -1;
          getStatusint  = 10;
          statusdbl     = -1;
          getStatusdbl  = 10;
          getParamdbl   = 0.0;
          getParamint   = 0;
          flag          = true;

          /* Retrieve the name of the parameter as specified in the external parameter file */
          nameParam = mxGetFieldNameByNumber(namesCPLEXparams, j);
          nameParam = concat2("CPX_PARAM_", nameParam);

          /* Retrieve the numeric identifier of the CPLEX parameter */
          numStatus     = CPXgetparamnum (env, nameParam, &numParam);

          /*mexPrintf("_FVA . Parameter: %s; ID: %d, value: %f \n", nameParam, numParam, *(valuesCPLEX+j) );*/

          /* Set the INTEGER parameter, and retrieve the copy for proof of successful setting */
          statusint        = CPXsetintparam  (env, numParam,  (int)*(valuesCPLEX+j));
          getStatusint     = CPXgetintparam  (env, numParam, &getParamint);

          /* Print out a status message */
          if(statusint == 0 && getStatusint == 0 ){   /* set INT parameters */
                /*mexPrintf("        ++ (int)[\e[1;32m%i\e[0m|\e[1;32m%i\e[0m]: %s (%i) = [set> %i] & [%i <get] \n",
                          statusint, getStatusint, nameParam, numParam, (int)*(valuesCPLEX+j), getParamint);*/
                if (printLevel > 0) {
                mexPrintf("        ++ (int)[%i|%i]: %s (%i) = [set> %i] & [%i <get] \n",
                          statusint, getStatusint, nameParam, numParam, (int)*(valuesCPLEX+j), getParamint);
                }
                flag = false;
          } else {   /* set DOUBLE or FLOAT parameters */

              /* Set the DOUBLE parameter, and retrieve the copy for proof of successful setting */
              statusdbl        = CPXsetdblparam  (env, numParam, (double)*(valuesCPLEX+j));
              getStatusdbl     = CPXgetdblparam  (env, numParam, &getParamdbl);

              /* Print out a status message */
              if(statusdbl == 0 && getStatusdbl == 0 ){
                  /*  mexPrintf("        ++ (dbl)[\e[1;32m%i\e[0m|\e[1;32m%i\e[0m]: %s (%i) = [set> %.10e] & [%.10e <get] \n",
                              statusdbl, getStatusdbl, nameParam, numParam, (double)*(valuesCPLEX+j), getParamdbl);*/
                    if (printLevel > 0) {
                        mexPrintf("        ++ (dbl)[%i|%i]: %s (%i) = [set> %.10e] & [%.10e <get] \n",
                                  statusdbl, getStatusdbl, nameParam, numParam, (double)*(valuesCPLEX+j), getParamdbl);
                        flag = false;
                    }
              }
          }
          /* Print warning messages */
          if(flag)
              mexPrintf("        --> %s Impossible to set or get %s (%d).\n\n", PRINT_WARNING, nameParam, numParam);
          }
        if (printLevel > 0) {
            mexPrintf("    -- All %i CPLEX parameters set --\n", countParam);
        }
    }

    if(monitorPerformance) markersBegin[4] = clock();

    /* Print ot a warning message if high optPercentage */
    if(optPercentage > OPT_PERCENTAGE) {
      if (printLevel > 0) {
        mexPrintf("\n -- %s: The optPercentage is higher than 90. The solution process might take longer than you expect.\n\n",PRINT_WARNING);
      }
    }

    if(monitorPerformance) {
        for (j = 0; j < Nmarkers; j++)
        {
          markers[j] = 0.0;
          markersBegin[j] = 0.0;
          markersEnd[j] = 0.0;
        }
      markersBegin[1] = clock();
    }

    /*status = CPXreadcopybase(env, lp, "myprob.bas");*/

    /* Solve the problem */
    status = CPXlpopt(env, lp);

    /*status = CPXmbasewrite(env, lp, "myprob.bas"); */
    if (status) {
       dispCPLEXerror(env, status);
       return FVA_INIT_FAIL;
    }

    if(monitorPerformance) markersEnd[1] = clock();

    /* Get status of the solution. */
    status = (double)CPXgetstat(env, lp);
    if (status != 1) {
        dispCPLEXerror(env, status);
        return FVA_INIT_FAIL;
    }

    status = CPXgetobjval(env, lp, optSol);
    if (status) {
         mexPrintf("No objective value available.\n");
         dispCPLEXerror(env, status);
         return FVA_INIT_FAIL;
    }

    if(monitorPerformance) markersBegin[2] = clock();

    /* Determine the value of objective function bound */
    /*mexPrintf(">> The original optSol = %3.30f\n", *optSol);*/

    if (objective == FVA_MIN_OBJECTIVE) {
       TargetValue = ceil(*optSol/tol)*tol*optPercentage/100.0;
    } else {
       TargetValue = floor(*optSol/tol)*tol*optPercentage/100.0;
    }

    /*mexPrintf(">> The target value = %3.30f\n", TargetValue);*/

    if(monitorPerformance) markersEnd[2] = clock();

    if (FBAsol != NULL)
    {
       status = CPXgetx (env, lp, FBAsol, 0, CPXgetnumcols(env, lp)-1);
       if (status)
       {
          mexPrintf("Unable to get FBAsol. Status=%d\n", status);
          return FVA_INIT_FAIL;
       }
    }

    /* mexPrintf("The FBA solution is %f", TargetValue); */

    /* Add a constraint which bounds the objective, c'v >= objValue in case of max, (<= for min) */
    sense = (objective==FVA_MIN_OBJECTIVE) ? 'L' : 'G';

    /* Slight inefficiency: Assume the new row is dense */
    ind = (int*)malloc( (n_vars)*sizeof(int));
    val = (double*)malloc( (n_vars)*sizeof(double));

    if(monitorPerformance) markersBegin[3] = clock();

    /*mexPrintf(">> n_vars = %i\n", n_vars);*/

    for (j = 0; j < n_vars; j++)
    {
       ind[j] = j;
       /*mexPrintf("ind[j] = %i\n", ind[j]);*/
       status = CPXgetcoef(env, lp, -1, j, &val[j]);
       if (status)
       {
          mexPrintf("Unable to create new row (failed at element %d)\n", j);
       }
       /*mexPrintf("val[%i] = %f\n", j, *(val+j));*/
    }

    if(monitorPerformance) markersEnd[3] = clock();

    rmatbeg[0] = 0;
    rmatbeg[1] = n_vars-1;

    /*mexPrintf("rmatbeg[1] = %f; n_vars-1 = %f\n", rmatbeg[1], n_vars-1);*/

    status = CPXaddrows(env, lp, 0, 1, n_vars, &TargetValue, &sense, rmatbeg, ind, val, NULL, NULL);

    if (status) {
      mexPrintf("Call to CPXaddrows failed\n");
      dispCPLEXerror(env, status);
    }

    free(ind);
    free(val);

    if(monitorPerformance) markersBegin[4] = clock();

    /* Zero all objective function coefficients */
    for (j = 0; j < n_vars; j++)
    {
      status = CPXchgcoef (env, lp, -1, j, 0.0);
      /*mexPrintf("Coefficient %i set to zero\n", j);*/
      if (status != 0)
          mexPrintf("CPXchgcoef failed for %d\n", j);
    }

    if(monitorPerformance) markersEnd[4] = clock();

    /* Solve all the minimization problems first. The difference in the optimal
    *  solution for two minimization problems is probably much smaller on average
    *  than the difference between one min and one max solution, leading to fewer
    *  simplex iterations in each step. */

    if(monitorPerformance) markersBegin[5] = clock();

    for (iRound = 0; iRound < 2; iRound++)
    {

      if (iRound == 0) {
        if (printLevel > 0) {
          mexPrintf("        -- Minimization (iRound = %i). Number of reactions: %i. - printLevel %i\n", iRound, nrxn, printLevel);
        }
      } else {
        if (printLevel > 0) {
          mexPrintf("        -- Maximization (iRound = %i). Number of reactions: %i.\n", iRound, nrxn);
        }
      }

      CPXchgobjsen(env, lp, (iRound == 0) ? CPX_MIN : CPX_MAX);

      for (k = 0; k < nrxn; k++)
      {

        /* Determine if a reaction should be minimized, maximized, or both
           0: only minimization; 1: only maximization; 2: minimization & maximization*/

        if( (rxnsOptMode[k] == 0 && iRound == 0) || (rxnsOptMode[k] == 1 && iRound == 1) || (rxnsOptMode[k] == 2)) {
           performOptim = true;
        } else {
           performOptim = false;
        }

        if (performOptim) {

          /*
          if (iRound == 0) {
             mexPrintf(" >> Rxns %i is minimized\n",k);
          } else{
             mexPrintf(" >> Rxns %i is maximized\n",k);
          }
          */

          int j = rxns[k];

          /* mexPrintf("        -- Loop k = %i with j= %i.\n", k, j);*/

          if(monitorPerformance) markersBegin[6] = clock();

          status = CPXchgcoef (env, lp, -1, j-1, 1000.0); /* linear objective is referenced as -1 */

          if (status != 0) {
             mexPrintf(" -- WARNING: Impossible to set the objective coefficient.\n");
             return FVA_MODIFIED_FAIL;
          }

          if(monitorPerformance) markersEnd[6] = clock();
          if(monitorPerformance) markersBegin[7] = clock();

          /*  status = CPXreadcopybase(env, lp, "myprob.bas");*/

          /* Solve the problem - most time consuming step*/
          status = CPXlpopt(env, lp);

          /*status = CPXmbasewrite(env, lp, "myprob.bas");*/

          if(monitorPerformance) markersEnd[7] = clock();

          /* Retrieving the solution status from CPLEX as given in the group optim.cplex.solutionstatus*/
          /*  mexPrintf(" -- Status: (%i, rxn = %i, index = %i, rxnsOptMode = %1.2f)\n", iRound, j, k, rxnsOptMode[k]);*/
          if(statussolmin != NULL && statussolmax != NULL) {
              if(iRound == 0) {
                statussolmin[j-1] =  CPXgetstat (env, lp);
                /*mexPrintf(" -- Minimization status: (%i, rxn = %i, index = %i, rxnsOptMode = %1.2f) = %1.2f\n", iRound, j, k, rxnsOptMode[k], statussolmin[j-1]);*/
              } else if (iRound == 1) {
                statussolmax[j-1] =  CPXgetstat (env, lp);
                 /*mexPrintf(" -- Maximization status: (%i, rxn = %i, index = %i, rxnsOptMode = %1.2f) = %1.2f\n", iRound, j, k, rxnsOptMode[k], statussolmax[j-1]);*/
              }
          }

          if (status) {
             /* To be done: Try to restart from scratch! */
             mexPrintf(" -- WARNING: The return status for reaction %i in iRound = %i is %i. Numerical difficulties.\n", j, iRound, status);
             return FVA_MODIFIED_FAIL;
          }

          if(monitorPerformance) markersBegin[8] = clock();

          status = CPXgetobjval(env, lp, &objval);

          if(monitorPerformance) markersEnd[8] = clock();

          if (status != 0) {
             mexPrintf(" ERROR: Unable to get objective function value (%d,%d)\n", iRound, j);
             dispCPLEXerror(env, status);
          }

          /* Store flux vectors also */
          if (FVAmin != NULL && FVAmax != NULL)
          {
             double* ptr = (iRound == 0) ? FVAmin : FVAmax;
             status = CPXgetx (env, lp, &ptr[k * n_vars], 0, CPXgetnumcols(env, lp)-1);
             /*mexPrintf(" fvaminsol %f, fvamaxsol %f, objval/1000 = %f\n", FVAmin[j-1], FVAmax[j-1], objval/1000.0);*/
             if (status != 0)
             {
                mexPrintf(" ERROR: Unable to get FVAsol. Status=%d\n", status);
                return FVA_INIT_FAIL;
             }
          }

          /* mexPrintf("Objective value of reaction %i is  %f\n", j, objval);*/

          if(monitorPerformance) markersBegin[9] = clock();

          status = CPXchgcoef (env, lp, -1, j-1, 0.0);

          if(monitorPerformance) markersEnd[9] = clock();

          if (status != 0) {
            mexPrintf("Unable to set coeff to zero\n");
          }
          if (iRound == 0) {
          /*  if (fabs(FVAmin[j-1] - objval/1000.0) > 1e-2){
             mexPrintf("MIN - Solution vector %i: %f, objective value: %f -> result: %f\n", j, FVAmin[j-1], objval/1000.0, (fabs(FVAmin[j-1]) > fabs(objval/1000.0)) ? FVAmin[j-1] : objval/1000.0);
           }*/
            minFlux[j-1] = objval/1000.0;
          } else {
          /* if (fabs(FVAmax[j-1] - objval/1000.0) > 1e-2){
            mexPrintf("MAX - Solution vector %i: %f, objective value: %f -> result: %f\n", j, FVAmax[j-1], objval/1000.0, (fabs(FVAmax[j-1]) > fabs(objval/1000.0)) ? FVAmax[j-1] : objval/1000.0);
          }*/
            maxFlux[j-1] = objval/1000.0;
          }
          /*mexPrintf("iRound = %i, k = %i, j = %i, objval/1000 = %2.8f\n", iRound, k, j,objval/1000.0);*/
       } /* end if performOptim */
      } /* end loop reactions k */
    } /* end iRound */

    if(monitorPerformance) {
      markersEnd[5] = clock();

      for (j = 0; j < Nmarkers; j++)
      {
        markers[j] = (double)(markersEnd[j] - markersBegin[j]) / CLOCKS_PER_SEC;
        if (printLevel > 0) {
          mexPrintf(" >> _fva / Markers(%d) Execution time: %.2f seconds.\n", j, markers[j]);
        }
      }
    }

   return FVA_SUCCESS;
}

/*
    Copy and transform Matlab matrix IN in the representation needed for CPLEX.
    Return number of non zero elements (nnz) and CPLEX matrix description:
    matbeg, matcnt, matind, and matval.
    The arrays matbeg, matcnt, matind, and matval are accessed as follows.
    Suppose that CPLEX wants to access the entries in some column j. These
    are assumed to be given by the array entries:
        matval[matbeg[j]],.., matval[matbeg[j]+matcnt[j]-1]
    The corresponding row indices are:
        matind[matbeg[j]],.., matind[matbeg[j]+matcnt[j]-1]
    Entries in matind are not required to be in row order. Duplicate entries
    in matind within a single column are not allowed. The length of the arrays
    matbeg and matind should be of at least numcols. The length of arrays
    matind and matval should be of at least matbeg[numcols-1]+matcnt[numcols-1].
 */
int get_matrix(const mxArray *IN, int **outbeg, int **outcnt, int **outind,
               double **outval)
{
    int i, j;
    int gcount = 0;
    int pcount = 0;

    int m = mxGetM(IN);
    int n = mxGetN(IN);

    int    *matbeg = NULL;
    int    *matcnt = NULL;
    int    *matind = NULL;
    double *matval = NULL;

    double *in = mxGetPr(IN);

    matbeg = (int *)mxCalloc(n, sizeof(int));
    matcnt = (int *)mxCalloc(n, sizeof(int));

    /* Use different approaches for full and sparse matrix IN. */
    if (!mxIsSparse(IN))
    {

        gcount = 0;
        for (i = 0; i < n; i++) {
            pcount = 0;
            for (j = 0; j < m; j++) {
                if (in[i * m + j] != 0) {
                    gcount++;
                    pcount++;
                }
                matbeg[i] = gcount - pcount;
                matcnt[i] = pcount;
            }
        }
        matind = (int *)mxCalloc(gcount, sizeof(int));
        matval = (double *)mxCalloc(gcount, sizeof(double));

        gcount = 0;
        for (i = 0; i < n; i++) {
            for (j = 0; j < m; j++) {
                if (in[i * m + j] != 0) {
                    matind[gcount] = j;
                    matval[gcount] = in[i * m + j];
                    gcount++;
                }
            }
        }
    } else {
        /* For sparse matrix majority is already defined. */
        gcount = mxGetJc(IN)[n];
        matind = (int *)mxCalloc(gcount, sizeof(int));
        matval = (double *)mxCalloc(gcount, sizeof(double));

        for (i=0; i<n; i++){
            matbeg[i] = mxGetJc(IN)[i];
            matcnt[i] = mxGetJc(IN)[i+1] - mxGetJc(IN)[i];
        }
        for (i=0; i<gcount; i++){
            matind[i] = mxGetIr(IN)[i];
            matval[i] = in[i];
        }
    }
    *outbeg = matbeg;
    *outcnt = matcnt;
    *outind = matind;
    *outval = matval;
    return (gcount);
}

/*
    Copy and transform Matlab matrix IN in the vector representation needed for
    CPLEX. Return number of non zero elements (nnz) and CPLEX vector
    description: matval.
 */
int get_vector(const mxArray *IN, double **outval)
{
    int i;
    int gcount = 0;
    int m = mxGetM(IN);
    int n = mxGetN(IN);
    double *matval = NULL;
    double *in = mxGetPr(IN);

    matval = (double *)mxCalloc(m*n, sizeof(double));

    gcount = 0;
    for (i = 0; i < m*n; i++) {
        matval[i] = in[i];
        /* Handle infinity entries */
        /*
        if (matval[i]==mxGetInf()){
            matval[i]=CPX_INFBOUND;
        } else if (matval[i]==-mxGetInf()) {
            matval[i]=-CPX_INFBOUND;
        }
        */
        if (in[i] != 0)
            gcount++;
    }
    *outval = matval;
    return (gcount);
}



/*
   Here is the exit function, which gets run when the MEX-file is
   cleared and when the user exits MATLAB. The mexAtExit function
   should always be declared as static.
 */
static void freelicence(void)
{
    int             status;
    extern CPXENVptr env;
    extern CPXFILEptr LogFile;
    extern int NUM_CALLS_CPLEXINT;  /* number of calls to CPLEXINT */
    extern int FIRST_CALL_CPLEXINT; /* is this first call to CPLEXINT */

    /* Close log file */
    if (LogFile != NULL){
        mexPrintf("LogFile is not NULL.\n");

        #ifdef HIGHER_THAN_128
            status = fclose(LogFile);
        #endif
        #ifdef LOWER_THAN_128
            status = CPXfclose(LogFile);
        #endif

        if (status) {
            mexPrintf("Could not close log file.\n");
        } else {
            /* Just to be on the safe side we declare that the LogFile after
               closing is NULL. In this way we avoid possible error when trying
               to clear the same mex file more than once. */
            LogFile = NULL;
        }
    } else {
        /* mexPrintf("LogFile is NULL.\n"); */
    }


    /* Close CPLEX environment */
    FIRST_CALL_CPLEXINT = 1;
    NUM_CALLS_CPLEXINT = 0;
    if (env != NULL) {
        /* mexPrintf("env is not NULL.\n"); */
        status = CPXcloseCPLEX(&env);
        /*
           Note that CPXcloseCPLEX produces no output,
           so the only way to see the cause of the error is to use
           CPXgeterrorstring.  For other CPLEX routines, the errors will
           be seen if the CPX_PARAM_SCRIND indicator is set to CPX_ON.
         */
        if (status) {
            mexPrintf("Could not close CPLEX environment.\n");
            dispCPLEXerror(env, status);
        } else {
            /* Just to be on the safe side we declare that the environment after
               closing is NULL. In this way we avoid possible error when trying
               to clear the same mex file more than once. */
            env = NULL;
        }
    } else {
        /* mexPrintf("env is NULL.\n"); */
    }

}

/************************************
 *                                  *
 *   CPLEXINT solver MATLAB side    *
 *                                  *
 ************************************/
void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    char            errmsg[MAX_STR_LENGTH];     /* buffer for error messages */

     /* tmp variables */
    int             i, j, ii, jj, kk, mm;
    char           *tmpc;
    double         *tmpd;
    mxArray        *tmpArr;

    int             n_vars = 0;
    int             n_constr = 0;

    /* A_IN variables */
    int             A_nnz = 0;          /* number of non-zero elements */
    int            *A_matbeg = NULL;
    int            *A_matcnt = NULL;
    int            *A_matind = NULL;
    double         *A_matval = NULL;

    /* B_IN variables */
    int             b_nnz = 0;          /* number of non-zero elements */
    double         *b_matval = NULL;

    /* F_IN variables */
    int             f_nnz = 0;          /* number of non-zero elements */
    double         *f_matval = NULL;

    /* LB_IN variables */
    int             LB_nnz = 0;          /* number of non-zero elements */
    double         *LB_matval = NULL;

    /* UB_IN variables */
    int             UB_nnz = 0;          /* number of non-zero elements */
    double         *UB_matval = NULL;

    /* CSENSE_IN variables */
    char           *sense = NULL;        /* constraints 'L', 'G' or 'E'    */

    /* OPT_PERCENT */
    double          optPercent = 100;   /*100*/

    /* OBJECTIVE */
    int             objective = -1;

    /* RXNS */
    double          *rxns = NULL;
    double          *rxnsOptMode = NULL;

    mwSize          nrxn = 0;

    int             opt_lic_rel = 1;    /* user can specify after how many calls will
                                           CPLEX environment be closed and license released */

    int             opt_logfile = 1;    /* use a CPLEX log file */

    char            *vartype = NULL;
    int             objsense = 1;

    mxArray         *MINFLUX = NULL;
    double          *minFlux = NULL;

    mxArray         *MAXFLUX = NULL;
    double          *maxFlux = NULL;

    mxArray         *OPTSOL = NULL;
    double          *optSol = NULL;

    mxArray         *RET = NULL;
    double          *ret = NULL;

    /* Optional Arguments */
    mxArray         *FBASOL = NULL;
    double          *fbasol = NULL;

    mxArray         *FVAMINSOL = NULL;
    double          *fvaminsol = NULL;

    mxArray         *FVAMAXSOL = NULL;
    double          *fvamaxsol = NULL;

    mxArray         *STATUSSOLMIN = NULL;
    double          *statussolmin = NULL;

    mxArray         *STATUSSOLMAX = NULL;
    double          *statussolmax = NULL;

    /*mxArray         *PRINTLEVEL = NULL;
    int             *printLevel = NULL;
    */
    int             printLevel = 0;

    /* numThread_IN*/
    int             numThread = 0;
    char            numThreadstr[MAX_STR_LENGTH];

    char           *logFileDir = NULL;
    const char     *logFileName = NULL;

    /* CPLEX variables */
    char            probname[] = "cplexint_problem\0";
    extern          CPXENVptr env;
    extern          CPXFILEptr LogFile;
    extern int      NUM_CALLS_CPLEXINT;  /* number of calls to CPLEXINT before clearing
                                       environment CPXenv and releasing the license */
    extern int      FIRST_CALL_CPLEXINT; /* is this first call to CPLEXINT */
    CPXLPptr        lp = NULL;
    int             status;

    int             errors = 1;     /* keep track of errors during initialization */

    /* Variables for monitoring the performance */
    clock_t         begin, end, markersBegin[Nmarkers], markersEnd[Nmarkers];
    double          time_spent, markers[Nmarkers];
    bool            monitorPerformance = false;
    time_t          current_time;
    char*           c_time_string;

    if(monitorPerformance) {
      for (j = 0; j < Nmarkers; j++)
      {
        markers[j] = 0.0;
        markersBegin[j] = 0.0;
        markersEnd[j] = 0.0;
      }

    /* Retrieve the total execution time of the function */
    begin = clock();
    }

    /* If there are no input nor output arguments display version number */
    if ((nrhs == 0) && (nlhs == 0)){
        if (printLevel > 0) {
          mexPrintf("CPLEXINT, Version %s.\n", CPLEXINT_VERSION);
          mexPrintf("MEX interface for using CPLEX in Matlab.\n");
          mexPrintf("%s.\n", CPLEXINT_COPYRIGHT);
        }
        return;
    }

    /* Check for proper number of arguments. */
    if (nrhs < MIN_NUM_IN_ARG) {
        sprintf(errmsg, "At least %d input arguments required.",
                MIN_NUM_IN_ARG);
        TROUBLE_mexErrMsgTxt(errmsg);
    } else if (nrhs > MAX_NUM_IN_ARG) {
        TROUBLE_mexErrMsgTxt("Too many input arguments.");
    } else if (nlhs < MIN_NUM_OUT_ARG) {
        mexPrintf("NOTE: This is a way of forcing people to notice RES output.\n");
        mexPrintf("Always check RES for correct interpretation of the results.\n");
        sprintf(errmsg, "At least %d output arguments required.",
                MIN_NUM_OUT_ARG);
        TROUBLE_mexErrMsgTxt(errmsg);
    } else if (nlhs > MAX_NUM_OUT_ARG) {
        TROUBLE_mexErrMsgTxt("Too many output arguments.");
    }

    /* Is somebody trying to solve an unconstrained problem. */
    if ((mxIsEmpty(A_IN)) || (mxIsEmpty(B_IN))){
        mexPrintf("If you are trying to solve an unconstrained problem one remedy is to\n");
        mexPrintf("artificially introduce some BIG constraints that will never be active.\n");
        TROUBLE_mexErrMsgTxt("CPLEX requires non-empty constraint matrices A and b.");
    }

    /* First get the number of variables and the number of constraints.
       For this purpose check size of a matrix A_IN (required argument). */
    if (   (!mxIsNumeric(A_IN))
        || (mxGetNumberOfDimensions(A_IN) > 2)
        || ((n_constr = mxGetM(A_IN)) < 1)
        || ((n_vars = mxGetN(A_IN)) < 1)
        || (mxIsComplex(A_IN))
        || (mxGetPr(A_IN) == NULL)
        ) {
        TROUBLE_mexErrMsgTxt("Matrix A must be a real valued (m x n) matrix, with m>=1, n>=1.");
    }
    A_nnz = get_matrix(A_IN, &A_matbeg, &A_matcnt, &A_matind, &A_matval);
    if (A_nnz == 0) {
        TROUBLE_mexErrMsgTxt("At least one element of constraint matrix A must be non-zero.");
    }

    if (   (!mxIsNumeric(B_IN))
        || (mxGetNumberOfDimensions(B_IN) > 2)
        || (mxGetM(B_IN) != n_constr)
        || (mxGetN(B_IN) != 1)
        || (mxIsComplex(B_IN))
        || (mxGetPr(B_IN) == NULL)
        ) {
        sprintf(errmsg,
            "Vector b must be a real valued (%d x 1) vector.", n_constr);
        TROUBLE_mexErrMsgTxt(errmsg);
    }
    b_nnz = get_vector(B_IN, &b_matval);

    if (   (!mxIsNumeric(F_IN))
        || (mxGetNumberOfDimensions(F_IN) > 2)
        || (mxGetM(F_IN) != n_vars)
        || (mxGetN(F_IN) != 1)
        || (mxIsComplex(F_IN))
        || (mxGetPr(F_IN) == NULL)
        ) {
        sprintf(errmsg,
            "Objective f must be a real valued (%d x 1) vector.",
            n_vars);
        TROUBLE_mexErrMsgTxt(errmsg);
    }
    f_nnz = get_vector(F_IN, &f_matval);

    if ((nrhs > CSENSE_IN_POS) && (!mxIsEmpty(CSENSE_IN))) {
        if (   (!mxIsChar(CSENSE_IN))
            || (mxGetNumberOfDimensions(CSENSE_IN) > 2)
            || (mxGetM(CSENSE_IN) != n_constr)
            || (mxGetN(CSENSE_IN) != 1)
            ) {
            sprintf(errmsg,
                "CSENSE must be a char valued (%d x 1) column vector.",
                n_constr);
            TROUBLE_mexErrMsgTxt(errmsg);
        } else {
            /* Allocate enough memory to hold the converted string. */
            sense = mxCalloc(n_constr+1, sizeof(char));

            /* Copy the string data from string_array_ptr into buf. */
            if (mxGetString(CSENSE_IN, sense, n_constr+1) != 0) {
                TROUBLE_mexErrMsgTxt("Could not convert string data of CSENSE.");
            }
        }
    }

    if ((nrhs > LB_IN_POS) && (!mxIsEmpty(LB_IN))) {
        if (   (!mxIsNumeric(LB_IN))

            || (mxGetM(LB_IN) != n_vars)
            || (mxGetN(LB_IN) != 1)
            || (mxIsComplex(LB_IN))
            || (mxGetPr(LB_IN) == NULL)
            ) {
            sprintf(errmsg, "LB must be a real valued (%d x 1) column vector.", n_vars);
            TROUBLE_mexErrMsgTxt(errmsg);
        }
        LB_nnz = get_vector(LB_IN, &LB_matval);
    }
    if (LB_matval == NULL){
        LB_matval = mxCalloc(n_vars, sizeof(double));
        for (i=0; i<n_vars; i++){
            LB_matval[i] = -mxGetInf();
        }
        LB_nnz = n_vars;
    }

    if ((nrhs > UB_IN_POS) && (!mxIsEmpty(UB_IN))) {
        if (   (!mxIsNumeric(UB_IN))
            || (mxGetNumberOfDimensions(UB_IN) > 2)
            || (mxGetM(UB_IN) != n_vars)
            || (mxGetN(UB_IN) != 1)
            || (mxIsComplex(UB_IN))
            || (mxGetPr(UB_IN) == NULL)
            ) {
            sprintf(errmsg,
                "UB must be a real valued (%d x 1) column vector.",
                n_vars);
            TROUBLE_mexErrMsgTxt(errmsg);
        }
        UB_nnz = get_vector(UB_IN, &UB_matval);
    }
    if (UB_matval == NULL){
        UB_matval = mxCalloc(n_vars, sizeof(double));
        for (i=0; i<n_vars; i++){
            UB_matval[i] = mxGetInf();
        }
        UB_nnz = n_vars;
    }

    /* All variables are continuous */
    if (vartype == NULL) {
        vartype = mxCalloc(n_vars + 1, sizeof(char));
        for (i = 0; i < n_vars; i++)
            vartype[i] = 'C';
        vartype[n_vars] = 0;
    }

    /* FVA specific arguments */
    optPercent    = mxGetScalar(OPT_PERCENT_IN);
    objective     = mxGetScalar(OBJECTIVE_IN);
    rxns          = mxGetPr(RXNS_IN);
    nrxn          = mxGetM(RXNS_IN);
    rxnsOptMode   = mxGetPr(RXNS_OPTMODE_IN);
    printLevel    = mxGetScalar(PRINTLEVEL_IN);

    if (printLevel > 0) {
      mexPrintf(" >> The number of reactions retrieved is %d\n", nrxn);
    }

    /* Retrieve the number of the thread */
    numThread     = mxGetScalar(NUM_THREAD_IN);

    /* Retrieve the location of log files */
    logFileDir = mxArrayToString(prhs[LOGFILE_DIR_IN]);

    if (printLevel > 0) {
      mexPrintf(" >> Log files will be stored at %s\n", logFileDir);
    }
    logFileName = concat2(logFileDir, "/cplexint_logfile_");

    /* Register safe exit. */
    #ifdef RELEASE_CPLEX_LIC
      mexAtExit(freelicence);
    #endif

    /***********************************
     *                                 *
     *  CPLEXINT solver CPLEX side     *
     *                                 *
     ***********************************/
    if(monitorPerformance) markersBegin[1] = clock();

    /* Initialize the CPLEX environment. */
    if (FIRST_CALL_CPLEXINT){
        env = CPXopenCPLEX(&status);
        FIRST_CALL_CPLEXINT = 0;
        NUM_CALLS_CPLEXINT = opt_lic_rel - 1;
    } else {
    	NUM_CALLS_CPLEXINT--;
    }

    if(monitorPerformance) markersEnd[1] = clock();

    /*
       If an error occurs, the status value indicates the reason for
       failure.  A call to CPXgeterrorstring will produce the text of
       the error message.  Note that CPXopenCPLEXdevelop produces no output,
       so the only way to see the cause of the error is to use
       CPXgeterrorstring.  For other CPLEX routines, the errors will
       be seen if the CPX_PARAM_SCRIND indicator is set to CPX_ON.
     */
    if (env == NULL) {
        mexPrintf("Could not open CPLEX environment.\n");
        dispCPLEXerror(env, status);
        goto TERMINATE;
    }

    /* Print out the time stamp for each worker */

    current_time = time(NULL);

    if (current_time == ((time_t)-1)) {
        TROUBLE_mexErrMsgTxt("Failure to obtain the current time.\n");
    }

    /* Convert to local time format. */
    c_time_string = ctime(&current_time);

    if (c_time_string == NULL) {
        TROUBLE_mexErrMsgTxt("Failure to convert the current time.\n");
    }
    if (printLevel > 0) {
      mexPrintf(" -- Start time:     %s", c_time_string);
    }

    /* Create a log file. */
    if (opt_logfile){
       	/*
    	  Open a LogFile to print out any CPLEX messages in there.
    	  We do this since Matlab does not execute printf commands
    	  in MEX files properly under Windows.
    	  */

        /* Convert numThreads to a string */
        sprintf(numThreadstr, "%d", numThread);

        if (printLevel > 0) {
          mexPrintf(" >> #Task.ID = %s; logfile: %s\n", numThreadstr, concat3("cplexint_logfile_", numThreadstr,".log"));
        }

        #ifdef LOWER_THAN_128
            LogFile = CPXfopen(concat3(logFileName, numThreadstr,".log"), "w");

            if (LogFile == NULL) {
                TROUBLE_mexErrMsgTxt(concat3("Could not open the log file ",logFileName,".log.\n"));
            }
        #endif

        #ifdef HIGHER_THAN_128
            status = CPXsetlogfilename(env, concat3(logFileName, numThreadstr,".log"), "w");
        #endif
        #ifdef LOWER_THAN_128
            status = CPXsetlogfile(env, LogFile);
        #endif

        if (status) {
            dispCPLEXerror(env, status);
            goto TERMINATE;
        }
    }

    if(monitorPerformance) markersBegin[2] = clock();

    /* Create the problem. */
    lp = CPXcreateprob(env, &status, probname);

    if(monitorPerformance) markersEnd[2] = clock();

    /*
       A returned pointer of NULL may mean that not enough memory
       was available or there was some other problem.  In the case of
       failure, an error message will have been written to the error
       channel from inside CPLEX.  In this example, the setting of
       the parameter CPX_PARAM_SCRIND causes the error message to
       appear on stdout.
     */

    if (lp == NULL) {
        mexPrintf("Failed to create LP.\n");
        dispCPLEXerror(env, status);
        goto TERMINATE;
    }

    if(monitorPerformance) markersBegin[3] = clock();

    /* Now copy the problem data into the lp. */
    objsense = (objective==FVA_MIN_OBJECTIVE) ? CPX_MIN : CPX_MAX;
    status = CPXcopylp(env, lp, n_vars, n_constr, objsense, f_matval, b_matval,
               sense, A_matbeg, A_matcnt, A_matind, A_matval,
               LB_matval, UB_matval, NULL);

    if(monitorPerformance) markersEnd[3] = clock();

    if (status) {
        *ret = FVA_INIT_FAIL;
        mexPrintf("Failed to setup problem.\n");
        dispCPLEXerror(env, status);
        goto TERMINATE;
    }

    status = CPXchgprobtype(env,lp,CPXPROB_LP);
    if (status) {
        *ret = FVA_INIT_FAIL;
        mexPrintf("Failed to select LP solver.\n");
        dispCPLEXerror(env, status);
        goto TERMINATE;
    }

    n_vars = CPXgetnumcols(env,lp);
    n_constr = CPXgetnumrows(env,lp); /* THINK: Will have to subtract one after FVA */

    /*
       Create matrices for the main return arguments.
    */
    MINFLUX = mxCreateDoubleMatrix(n_vars,1,mxREAL);
    minFlux = mxGetPr(MINFLUX);

    MAXFLUX = mxCreateDoubleMatrix(n_vars,1,mxREAL);
    maxFlux = mxGetPr(MAXFLUX);

    OPTSOL  = mxCreateDoubleMatrix(1,1,mxREAL);
    optSol  = mxGetPr(OPTSOL);

    RET     = mxCreateDoubleMatrix(1,1,mxREAL); /* global return error from _fva */
    ret     = mxGetPr(RET);

    if (nlhs >= MAX_NUM_OUT_ARG-2)
    {
       /* Optional arguments */
       FBASOL       = mxCreateDoubleMatrix(n_vars,1,mxREAL);
       FVAMINSOL    = mxCreateDoubleMatrix(n_vars,nrxn,mxREAL);
       FVAMAXSOL    = mxCreateDoubleMatrix(n_vars,nrxn,mxREAL);
       fbasol       = mxGetPr(FBASOL);
       fvaminsol    = mxGetPr(FVAMINSOL);
       fvamaxsol    = mxGetPr(FVAMAXSOL);
    }
    if(nlhs == MAX_NUM_OUT_ARG)
    {
      STATUSSOLMIN  = mxCreateDoubleMatrix(n_vars,1,mxREAL);
      STATUSSOLMAX  = mxCreateDoubleMatrix(n_vars,1,mxREAL);
      statussolmin  = mxGetPr(STATUSSOLMIN);
      statussolmax  = mxGetPr(STATUSSOLMAX);
    }

    if(monitorPerformance) markersBegin[4] = clock();

    /* Call FVA properly speaking */
    *ret = _fva(env,lp,minFlux,maxFlux,optSol,
                fbasol, fvaminsol, fvamaxsol,
                n_constr,n_vars,optPercent,objective,rxns,nrxn,
                CPLEX_PARAMS, VALUES_CPLEX_PARAMS,
                rxnsOptMode, statussolmin, statussolmax, printLevel);

    if(monitorPerformance) markersEnd[4] = clock();

    /* The FVA may have been unsuccessful, but there were no errors when
       initializing CPLEX. The success of FVA is determined by RET */
    errors = 0;

    TERMINATE:

    /* Close log file */
    if ((opt_logfile) && (LogFile != NULL)){
        #ifdef HIGHER_THAN_128
            status = fclose(LogFile);
        #endif
        #ifdef LOWER_THAN_128
            status = CPXfclose(LogFile);
        #endif

        if (status) {
            mexPrintf("Could not close log file.\n");
        } else {
            /* Just to be on the safe side we declare that the LogFile after
               closing is NULL. In this way we avoid possible error when trying
               to clear the same mex file afterwards. */
            LogFile = NULL;
        }
    }

    /* Free up the problem as allocated by CPXcreateprob, if necessary. */
    if (lp != NULL) status = CPXfreeprob(env, &lp);

    /* Free up the CPLEX environment, if necessary. */
    if (NUM_CALLS_CPLEXINT <= 0){
        FIRST_CALL_CPLEXINT = 1; /* prepare for the next call to CPLEXINT */
        NUM_CALLS_CPLEXINT = 0;  /* prepare for the next call to CPLEXINT */

        if (env != NULL) {

            if(monitorPerformance) markersBegin[5] = clock();

            status = CPXcloseCPLEX(&env);

            if(monitorPerformance) markersEnd[5] = clock();
            /*
               Note that CPXcloseCPLEX produces no output,
               so the only way to see the cause of the error is to use
               CPXgeterrorstring.  For other CPLEX routines, the errors will
               be seen if the CPX_PARAM_SCRIND indicator is set to CPX_ON.
             */
            if (status) {
                    mexPrintf("Could not close CPLEX environment.\n");
                    dispCPLEXerror(env, status);
            } else {
                /* Just to be on the safe side we declare that the environment after
                   closing is NULL. In this way we avoid possible error when trying
                   to clear the same mex file afterwards. */
                env = NULL;
            }
        }
    }

    if (!errors){
        /* Pass computation to the real outputs and clear not used memory */
        MINFLUX_OUT = MINFLUX;
        MAXFLUX_OUT = MAXFLUX;
        OPTSOL_OUT = OPTSOL;
        RET_OUT = RET;

        if (nlhs >= MAX_NUM_OUT_ARG-2)
        {
           FBA_SOL_OUT = FBASOL;
           FVA_MIN_OUT = FVAMINSOL;
           FVA_MAX_OUT = FVAMAXSOL;

        }
        if(nlhs == MAX_NUM_OUT_ARG)
        {
          STATUS_MIN_OUT = STATUSSOLMIN;
          STATUS_MAX_OUT = STATUSSOLMAX;
        }
    } else {
        if (MINFLUX != NULL)
            mxDestroyArray(MINFLUX);
        if (MAXFLUX != NULL)
            mxDestroyArray(MAXFLUX);
        if (OPTSOL != NULL)
            mxDestroyArray(OPTSOL);
        if (RET != NULL)
            mxDestroyArray(RET);
        if (FBA_SOL_OUT != NULL) {
            mxDestroyArray(FBA_SOL_OUT);
        }
        if (FVA_MIN_OUT != NULL) {
            mxDestroyArray(FVA_MIN_OUT);
        }
        if (FVA_MAX_OUT != NULL) {
            mxDestroyArray(FVA_MAX_OUT);
        }
        if (STATUS_MIN_OUT != NULL) {
            mxDestroyArray(STATUS_MIN_OUT);
        }
        if (STATUS_MAX_OUT != NULL) {
            mxDestroyArray(STATUS_MAX_OUT);
        }

    }

    /* Free allocated memory. */
    if (A_matbeg != NULL)
        mxFree(A_matbeg);
    if (A_matcnt != NULL)
        mxFree(A_matcnt);
    if (A_matind != NULL)
        mxFree(A_matind);
    if (A_matval != NULL)
        mxFree(A_matval);

    if (b_matval != NULL)
        mxFree(b_matval);

    if (f_matval != NULL)
        mxFree(f_matval);

    if (sense != NULL)
        mxFree(sense);

    if (LB_matval != NULL)
        mxFree(LB_matval);

    if (UB_matval != NULL)
        mxFree(UB_matval);

    if (vartype != NULL)
        mxFree(vartype);

    if (errors) {
        TROUBLE_mexErrMsgTxt("There were errors.");
    }

    if(monitorPerformance) {
      /* Finish the total execution time of the function */
      end = clock();
      time_spent = (double)(end - begin) / CLOCKS_PER_SEC;

      for (j = 0; j < Nmarkers; j++)
      {
        markers[j] = (double)(markersEnd[j] - markersBegin[j]) / CLOCKS_PER_SEC;
        if (printLevel > 0) {
          mexPrintf(" >> Markers(%d) Execution time: %.2f seconds.\n", j, markers[j]);
        }
      }

      if (printLevel > 0) {
        mexPrintf("\n >> Total c-Script Execution time: %.2f seconds.\n\n", time_spent);
      }
    }

    /* Print out the time stamp for each worker */

    current_time = time(NULL);

    if (current_time == ((time_t)-1)) {
        TROUBLE_mexErrMsgTxt("Failure to obtain the current time.\n");
    }

    /* Convert to local time format. */
    c_time_string = ctime(&current_time);

    if (c_time_string == NULL) {
        TROUBLE_mexErrMsgTxt("Failure to convert the current time.\n");
    }

    if (printLevel > 0) {
      mexPrintf(" -- End time:     %s", c_time_string);
    }
    return;
}
