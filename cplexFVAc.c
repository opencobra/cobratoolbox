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
 *    CPLEXINT      MATLAB MEX INTERFACE FOR CPLEX, ver. 2.3
 *
 *    Copyright (C) 2001-2005  Mato Baotic
 *    Copyright (C) 2006       Michal Kvasnica
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
 * All rights reserved.
 */

/* MATLAB declarations. */
#include <stdlib.h>
#include <math.h>
#include <matrix.h>
#include <time.h>
#include <cplex.h>
/*#include <ilcplex/cplex.h>*/
#include "mex.h"
#include <string.h>
#include <time.h>


/* CPLEX declarations.  */

/* FVA constants */
#define FVA_MIN_OBJECTIVE  1

/* FVA return codes */
#define FVA_SUCCESS        0
#define FVA_INIT_FAIL      1
#define FVA_MODIFIED_FAIL  2

#define CPLEXINT_VERSION "2.4"
#define CPLEXINT_COPYRIGHT "Copyright (C) 2001-2016  Mato Baotic & Dr. Laurent Heirendt"

static CPXENVptr env = NULL;
static CPXFILEptr LogFile = NULL;

static int NUM_CALLS_CPLEXINT = 0;  /* number of calls to CPLEXINT before clearing
                                       environment CPXenv and releasing the license */
static int FIRST_CALL_CPLEXINT = 1; /* is this first call to CPLEXINT */

/* MEX Input Arguments
mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
*/
enum {F_IN_POS, A_IN_POS, B_IN_POS, CSENSE_IN_POS,
      LB_IN_POS, UB_IN_POS,
      OPT_PERCENT_IN_POS, OBJECTIVE_IN_POS, RXNS_IN_POS, NUM_THREAD_IN,
      MAX_NUM_IN_ARG};

/* Number of input arguments */
#define MIN_NUM_IN_ARG      10

#define F_IN            prhs[F_IN_POS]
#define A_IN            prhs[A_IN_POS]
#define B_IN            prhs[B_IN_POS]
#define CSENSE_IN       prhs[CSENSE_IN_POS]
#define LB_IN           prhs[LB_IN_POS]
#define UB_IN           prhs[UB_IN_POS]
#define OPT_PERCENT_IN  prhs[OPT_PERCENT_IN_POS]
#define OBJECTIVE_IN    prhs[OBJECTIVE_IN_POS]
#define RXNS_IN         prhs[RXNS_IN_POS]
#define NUM_THREAD_IN   prhs[NUM_THREAD_IN]

/* MEX Output Arguments */

enum {MINFLUX_OUT_POS, MAXFLUX_OUT_POS, OPTSOL_OUT_POS, RET_OUT_POS, MAX_NUM_OUT_ARG};

/* Number of output arguments */
#define MIN_NUM_OUT_ARG    4

#define MINFLUX_OUT     plhs[MINFLUX_OUT_POS]
#define MAXFLUX_OUT     plhs[MAXFLUX_OUT_POS]
#define OPTSOL_OUT      plhs[OPTSOL_OUT_POS]
#define RET_OUT         plhs[RET_OUT_POS]

#define MAX_STR_LENGTH      1024


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

/*
    Concatenate 3 strings
*/
char* concat(char *s1, char *s2, char *s3)
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

/*
    Display CPLEX error code message
*/
void dispCPLEXerror(CPXENVptr env, int status)
{
    char errmsg[MAX_STR_LENGTH];
    char *errstr;

    errstr = (char *)CPXgeterrorstring (env, status, errmsg);
    if ( errstr != NULL ) {
        mexPrintf("%s",errmsg);
    }else {
        mexPrintf("CPLEX Error %5d:  Unknown error code.\n", status);
    }
}

/*
    Set CPLEX parameter
*/
void setCPLEXparam(CPXENVptr env, int numberParam, int valueParam)
{
  int           status, getStatus, nameStatus;
  int           getParam = 0;
  char          nameParam[20] = "";
  /*  int           numberParam = 0; */

  status      = CPXsetintparam  (env, numberParam, valueParam);
  getStatus   = CPXgetintparam  (env, numberParam, &getParam);
  nameStatus  = CPXgetparamname (env, numberParam, nameParam);
  mexPrintf("        ++ (status = %d, getStatus = %d): %s = %d \n", status, getStatus, nameParam, getParam);

}

/* FVA Wrapper */
int _fva(CPXENVptr env, CPXLPptr lp, double* minFlux, double* maxFlux, double* optSol, mwSize n_constr, mwSize n_vars,
         double optPercentage, int objective, const double* rxns, int nrxn)
{
    int           status, getStatus, nameStatus;
    int           rmatbeg[2];
    int*          ind = NULL;
    double*       val = NULL;
    int           j, k, iRound;
    char          sense;
    double        TargetValue = 0.0, objval = 0;
    const double  tol = 1.0e-6;
    int           getParam = 0;
    char          nameParam[20] = "";
    int           numberParam = 0;

    clock_t       markersBegin[Nmarkers], markersEnd[Nmarkers];
    double        markers[Nmarkers];

    bool          monitorPerformance = false;

    /*
      Best performance for running on 4core/2threads server rack:

      CPX_PARAM_PARALLELMODE = 1
      CPX_PARAM_THREADS = 1
      CPX_PARAM_AUXROOTTHREADS = 2
    */

    mexPrintf("    -- Setting CPLEX parameters ... \n");
    setCPLEXparam(env, 1109, 1); /* CPX_PARAM_PARALLELMODE */
    setCPLEXparam(env, 1067, 1); /* CPX_PARAM_THREADS */
    setCPLEXparam(env, 2139, 1); /* CPX_PARAM_AUXROOTTHREADS */
    /*  Setting of the parameters for CPLEX*/
    /*
    numberParam = 1109; CPX_PARAM_PARALLELMODE

    status      = CPXsetintparam  (env, numberParam, 1);
    getStatus   = CPXgetintparam  (env, numberParam, &getParam);
    nameStatus  = CPXgetparamname (env, numberParam, nameParam);
    mexPrintf("        ++ (status = %d, getStatus = %d): %s = %d \n", status, getStatus, nameParam, getParam);

    status    = CPXsetintparam (env, CPX_PARAM_THREADS, 1);
    getStatus = CPXgetintparam (env, CPX_PARAM_THREADS, &getParam);
    mexPrintf("        ++ (status = %d, getStatus = %d): CPX_PARAM_THREADS = %d \n", status, getStatus, getParam);

    status    = CPXsetintparam (env, CPX_PARAM_AUXROOTTHREADS, 2);
    getStatus = CPXgetintparam (env, CPX_PARAM_AUXROOTTHREADS, &getParam);
    mexPrintf("        ++ (status = %d, getStatus = %d): CPX_PARAM_AUXROOTTHREADS = %d \n", status, getStatus, getParam);


    status = CPXsetintparam (env, CPX_PARAM_MEMORYEMPHASIS, 1);
    mexPrintf("Successfully set CPX_PARAM_MEMORYEMPHASIS = 1 and the status is %d \n", status);

    status = CPXsetintparam (env, CPX_PARAM_ADVIND, 2);
    mexPrintf("Successfully set CPX_PARAM_ADVIND = 2 and the status is %d \n", status);

    status = CPXsetintparam (env, CPX_PARAM_REDUCE, 0);
    mexPrintf("Successfully set CPX_PARAM_REDUCE = 0 and the status is %d \n", status);

    status = CPXsetintparam (env, CPX_PARAM_REDUCE, 1);
    mexPrintf("Successfully set CPX_PARAM_AUXROOTTHREADS and the status is %d \n", status);

    status = CPXsetintparam (env, CPXPARAM_MIP_Strategy_PresolveNode, 1);
    mexPrintf("Successfully set CPXPARAM_MIP_Strategy_PresolveNode and the status is %d \n ", status);
    */

    mexPrintf("    -- All CPLEX parameters set --\n");

    /* Print ot a warning message if high optPercentage */
    if(optPercentage > 90) {
      mexPrintf("\n -- Warning: The optPercentage is higher than 90. The solution process might take longer than you might expect.\n\n");
    }

    if(monitorPerformance)
    {
        for (j = 0; j < Nmarkers; j++)
        {
          markers[j] = 0.0;
          markersBegin[j] = 0.0;
          markersEnd[j] = 0.0;
        }
      markersBegin[1] = clock();
    }

    /* Solve the problem */
    status = CPXlpopt(env, lp);
    if (status)
    {
       dispCPLEXerror(env, status);
       return FVA_INIT_FAIL;
    }

    if(monitorPerformance) markersEnd[1] = clock();

    /* Get status of the solution. */
    status = (double)CPXgetstat(env, lp);
    if (status != 1)
    {
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
    if (objective == FVA_MIN_OBJECTIVE)
    {
       TargetValue = floor(*optSol/tol)*tol*optPercentage/100.0;
    }
    else
    {
       TargetValue = ceil(*optSol/tol)*tol*optPercentage/100.0;
    }

    if(monitorPerformance) markersEnd[2] = clock();

    /* Add a constraint which bounds the objective, c'v >= objValue in case of max, (<= for min) */
    sense = (objective==FVA_MIN_OBJECTIVE) ? 'L' : 'G';

    /* Slight inefficiency: Assume the new row is dense */
    ind = (int*)malloc( (n_vars)*sizeof(int));
    val = (double*)malloc( (n_vars)*sizeof(double));

    if(monitorPerformance) markersBegin[3] = clock();

    for (j = 0; j < n_vars; j++)
    {
       ind[j]=j;
       status=CPXgetcoef(env, lp, -1, j, &val[j]);
       if (status)
       {
          mexPrintf("Unable to create new row (failed at element %d)\n", j);
       }
    }

    if(monitorPerformance) markersEnd[3] = clock();

    rmatbeg[0] = 0;
    rmatbeg[1] = n_vars-1;

    status = CPXaddrows(env, lp, 0, 1, n_vars, &TargetValue, &sense, rmatbeg, ind, val, NULL, NULL);

    if (status)
    {
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
      if (status != 0)
      {
         mexPrintf("CPXchgcoef failed for %d\n", j);
      }
    }

    if(monitorPerformance) {
        markersEnd[4] = clock();
    }
    /* Solve all the minimization problems first. The difference in the optimal
    *  solution for two minimization problems is probably much smaller on average
    *  than the difference between one min and one max solution, leading to fewer
    *  simplex iterations in each step. */

    if(monitorPerformance) {
      markersBegin[5] = clock();
    }

    for (iRound = 0; iRound < 2; iRound++)
    {
        CPXchgobjsen(env, lp, (iRound == 0) ? CPX_MIN : CPX_MAX);
      for (k = 0; k < nrxn; k++)
      {
        int j = rxns[k];

        if(monitorPerformance) markersBegin[6] = clock();

        status = CPXchgcoef (env, lp, -1, j-1, 1.0);

        if(monitorPerformance) markersEnd[6] = clock();

        if(monitorPerformance) markersBegin[7] = clock();

        status = CPXlpopt(env, lp); /*this is the most time consuming step*/

        if(monitorPerformance) markersEnd[7] = clock();

        if (status)
        {
           /* To be done: Try to restart from scratch! */
           mexPrintf("Numerical difficulties, round=%d, j=%d\n", iRound, j);
           return FVA_MODIFIED_FAIL;
        }


        if(monitorPerformance) markersBegin[8] = clock();

        status = CPXgetobjval(env, lp, &objval);

        if(monitorPerformance) markersEnd[8] = clock();

        if (status != 0)
        {
           mexPrintf("Unable to get objective function value (%d,%d)\n", iRound, j);
           dispCPLEXerror(env, status);
        }

        if(monitorPerformance) markersBegin[9] = clock();

        status = CPXchgcoef (env, lp, -1, j-1, 0.0);

        if(monitorPerformance) markersEnd[9] = clock();

        if (status != 0)
        {
          mexPrintf("Unable to set coeff to zero\n");
        }
        if (iRound == 0)
        {
          minFlux[j-1] = objval;
        }
        else
        {
          maxFlux[j-1] = objval;
        }
      }
    }

    if(monitorPerformance)
    {
      markersEnd[5] = clock();

      for (j = 0; j < Nmarkers; j++)
      {
        markers[j] = (double)(markersEnd[j] - markersBegin[j]) / CLOCKS_PER_SEC;
        mexPrintf(" >> _fva / Markers(%d) Execution time: %.2f seconds.\n", j, markers[j]);
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
    	status=CPXfclose(LogFile);

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
    double          optPercent = 100; /*100*/;

    /* OBJECTIVE */
    int             objective = -1;

    /* RXNS */
    double          *rxns = NULL;
    mwSize          nrxn = 0;

    int             opt_lic_rel = 1;    /* user can specify after how many calls will
                                           CPLEX environment be closed and license released */

    int             opt_logfile = 1;    /* use a CPLEX log file */

    char           *vartype = NULL;
    int            objsense = 1;

    mxArray         *MINFLUX = NULL;
    double          *minFlux = NULL;

    mxArray         *MAXFLUX = NULL;
    double          *maxFlux = NULL;

    mxArray         *OPTSOL = NULL;
    double          *optSol = NULL;

    mxArray         *RET = NULL;
    double          *ret = NULL;

    /* numThread_IN*/
    int             numThread = 0;
    char            numThreadstr[15];

    /* CPLEX variables */
    char            probname[] = "cplexint_problem\0";
    extern CPXENVptr env;
    extern CPXFILEptr LogFile;
    extern int NUM_CALLS_CPLEXINT;  /* number of calls to CPLEXINT before clearing
                                       environment CPXenv and releasing the license */
    extern int FIRST_CALL_CPLEXINT; /* is this first call to CPLEXINT */
    CPXLPptr        lp = NULL;
    int             status;

    int             errors = 1;     /* keep track of errors during initialization */

    /* Variables for monitoring the performance */
    clock_t         begin, end, markersBegin[Nmarkers], markersEnd[Nmarkers];
    double          time_spent, markers[Nmarkers];
    bool            monitorPerformance = false;

    time_t current_time;
    char* c_time_string;

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
    	mexPrintf("CPLEXINT, Version %s.\n", CPLEXINT_VERSION);
    	mexPrintf("MEX interface for using CPLEX in Matlab.\n");
    	mexPrintf("%s.\n", CPLEXINT_COPYRIGHT);
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
        mexPrintf("Always check RES for correct inpterpretation of the results.\n");
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
            sprintf(errmsg,
                "LB must be a real valued (%d x 1) column vector.",
                n_vars);
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
    optPercent = mxGetScalar(OPT_PERCENT_IN);
    objective = mxGetScalar(OBJECTIVE_IN);
    rxns = mxGetPr(RXNS_IN);
    nrxn = mxGetM(RXNS_IN);
    numThread = mxGetScalar(NUM_THREAD_IN);

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

    mexPrintf(" -- Start time:     %s", c_time_string);

    /* Create a log file. */
    if (opt_logfile){
       	/*
    	  Open a LogFile to print out any CPLEX messages in there.
    	  We do this since Matlab does not execute printf commands
    	  in MEX files properly under Windows.
    	  */

        /* Convert numThreads to a string */
        sprintf(numThreadstr, "%d", numThread);

        mexPrintf(" >> #Task.ID = %s; logfile: %s\n", numThreadstr, concat("cplexint_logfile_", numThreadstr,".log"));

        LogFile = CPXfopen(concat("logFiles/cplexint_logfile_", numThreadstr,".log"), "w");

       if (LogFile == NULL) {
            TROUBLE_mexErrMsgTxt("Could not open the log file logFiles/cplexint_logfile.log.\n");
        }
        status = CPXsetlogfile(env, LogFile);
        if (status) {
            dispCPLEXerror(env, status);
            goto TERMINATE;
        }
    }

    if(monitorPerformance) {
      markersBegin[2] = clock();
    }

    /* Create the problem. */
    lp = CPXcreateprob(env, &status, probname);

    if(monitorPerformance) {
      markersEnd[2] = clock();
    }

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

    if(monitorPerformance) {
      markersBegin[3] = clock();
    }

    /* Now copy the problem data into the lp. */
    objsense = (objective==FVA_MIN_OBJECTIVE) ? CPX_MIN : CPX_MAX;
    status = CPXcopylp(env, lp, n_vars, n_constr, objsense, f_matval, b_matval,
               sense, A_matbeg, A_matcnt, A_matind, A_matval,
               LB_matval, UB_matval, NULL);

    if(monitorPerformance) {
      markersEnd[3] = clock();
    }

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
       Create matrices for the three main return arguments.
    */
    MINFLUX = mxCreateDoubleMatrix(n_vars,1,mxREAL);
    minFlux = mxGetPr(MINFLUX);

    MAXFLUX = mxCreateDoubleMatrix(n_vars,1,mxREAL);
    maxFlux = mxGetPr(MAXFLUX);

    OPTSOL  = mxCreateDoubleMatrix(1,1,mxREAL);
    optSol  = mxGetPr(OPTSOL);

    RET     = mxCreateDoubleMatrix(1,1,mxREAL);
    ret     = mxGetPr(RET);

    if(monitorPerformance) {
      markersBegin[4] = clock();
    }

    /* Call FVA properly speaking */
    *ret = _fva(env,lp,minFlux,maxFlux,optSol,n_constr,n_vars,optPercent,objective,rxns,nrxn);

    if(monitorPerformance) {
      markersEnd[4] = clock();
    }

    /* The FVA may have been unsuccessful, but there were no errors when
       initializing CPLEX. The success of FVA is determined by RET */
    errors = 0;

    TERMINATE:

    /* Close log file */
    if ((opt_logfile) && (LogFile != NULL)){
    	status = CPXfclose(LogFile);

        if (status) {
            mexPrintf("Could not close log file.\n");
        } else {
            /* Just to be on the safe side we declare that the LogFile after
               closing is NULL. In this way we avoid possible error when trying
               to clear the same mex file afterwards. */
            LogFile = NULL;
        }
    }

    /*
       Free up the problem as allocated by CPXcreateprob, if necessary.
     */
    if (lp != NULL) {
        status = CPXfreeprob(env, &lp);
    }

    /* Free up the CPLEX environment, if necessary. */
    if (NUM_CALLS_CPLEXINT <= 0){
        FIRST_CALL_CPLEXINT = 1; /* prepare for the next call to CPLEXINT */
        NUM_CALLS_CPLEXINT = 0;  /* prepare for the next call to CPLEXINT */

        if (env != NULL) {

            if(monitorPerformance)
            {
              markersBegin[5] = clock();
            }

            status = CPXcloseCPLEX(&env);

            if(monitorPerformance)
            {
              markersEnd[5] = clock();
            }

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
    } else {
        if (MINFLUX != NULL)
            mxDestroyArray(MINFLUX);
        if (MAXFLUX != NULL)
            mxDestroyArray(MAXFLUX);
        if (OPTSOL != NULL)
            mxDestroyArray(OPTSOL);
        if (RET != NULL)
            mxDestroyArray(RET);
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
        mexPrintf(" >> Markers(%d) Execution time: %.2f seconds.\n", j, markers[j]);
      }

      mexPrintf("\n >> Total c-Script Execution time: %.2f seconds.\n\n", time_spent);
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

    mexPrintf(" -- End time:     %s", c_time_string);

    return;
}
