/* glpkFVAcc.cpp */

#include <stdio.h>
#include <stdlib.h>
#include <glpk.h>
#include <math.h>
#include "mex.h"

// Return codes
#define FVA_SUCCESS        0
#define FVA_INIT_FAIL      1
#define FVA_MODIFIED_FAIL  2

// Maximum time (seconds) allowed for solving each subproblem
// If the time is exceeded the problem is solved from scratch.
#define TIME_RESTART_LIM   60

void _setup_problem(glp_prob* P, const double* c, const size_t nz, mwIndex* jc, mwIndex* ir, const double* pr, const double* b,
                    const char* sense, const double* lb, const double* ub, mwSize m, mwSize n);

int _fva(glp_prob* P, double* minFlux, double* maxFlux, double* dOptSol,
         mwSize  m, mwSize n, double optPercentage, int objective, const double* reactions, int nrxn, int verbose);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   /*
    A MEX C++ function for performing flux variability analysis with the GLPK solver.

    Usage: [minFlux, maxFlux,optsol,ret]=glpkFVAcc(c,A,b,csense,lb,ub,optPercent,objective,rxns)

      Input:
         c,A,b,csense,lb,ub  The model (max/min c'v, subject to Av {'=', '<', '>' b, lb<=v<=ub)
         optPercentage       Only consider solutions that give you at least a certain
                             percentage of the optimal solution
         objective           Objective (+1 for min and -1 for max)
         rxns                A list of reactions to analyze (column vector, integers, e.g. [1;2;...;n])

      Output:
         minFlux   Minimum flux for each reaction
         maxFlux   Maximum flux for each reaction
         optsol    Optimal solution (of the initial FBA)
         retval    return code (0 if success).

    Assuming that WINGLPK has been installed in C:\glpk-4.42 and the user has Win64
    >> mex -largeArrayDims -IC:\matlab\tools\glpkmex\glpk-4.42\include\ glpkFVAcc.cpp C:\matlab\tools\glpkmex\glpk-4.42\w64\glpk_4_42.lib

    For Win32, the following *should* work
    >> mex -IC:\glpk-4.42\include\ glpkFVAcc.cpp C:\glpk-4.42\w32\glpk_4_42.lib

    Test
    >> load modelRecon1Biomass.mat
    >> [m,n]=size(model.S);
    >> [minFlux, maxFlux,optsol,ret]=glpkFVAcc(model.c,model.S,model.b, char('E'*ones(m,1)), model.lb, model.ub,90,'max',(1:n)');
    >> plot(maxFlow-minFlow)

   Author: Steinn Gudmundsson.
   Last updated: 3.26.2010.

   Warning: No sanity checks are made to see if the function is called with valid arguments.
            Use glpkFVA.m to call this function. All bounds are assumed to be fixed
            (+/- Inf not allowed).
   */

   if (nrhs != 9)
   {
    mexErrMsgTxt("Nine input arguments required.");
   } 
   if (nlhs != 4)
   {
    mexErrMsgTxt("Four output arguments required.");
   }
   if (!mxIsSparse(prhs[1]))
   {
      mexErrMsgTxt("The matrix A must be sparse.");
   }
   if (mxIsEmpty(prhs[3]) || !mxIsChar(prhs[3]))
   {
      mexErrMsgTxt("csense must be a character array with N_CONSTR columns");
   }

   // Obtain pointers to model and other input parameters
   double* c = mxGetPr(prhs[0]);
   mwSize m  = mxGetM(prhs[1]);
   mwSize n  = mxGetN(prhs[1]);
   size_t nz = *(mxGetJc(prhs[1]) + n);
   mwIndex *jc = mxGetJc(prhs[1]);
   mwIndex *ir = mxGetIr(prhs[1]);
   double *pr = mxGetPr(prhs[1]);

   double* b = mxGetPr(prhs[2]);
   char* sense = (char*)mxCalloc(m+1, sizeof(char));
   int iret = mxGetString(prhs[3], sense, n);
   if (iret != 0)
   {
      mexErrMsgTxt("error copying csense string\n");
   }

   double* lb = mxGetPr(prhs[4]);
   double* ub = mxGetPr(prhs[5]);
   double optPercentage = mxGetScalar(prhs[6]);
   int objective = (int)mxGetScalar(prhs[7]);
   double* rxns = mxGetPr(prhs[8]);
   mwSize nrxn = mxGetM(prhs[8]);
   int verbose = 0;

   // Create matrices for the return arguments
   plhs[0] = mxCreateDoubleMatrix(n,1,mxREAL);
   plhs[1] = mxCreateDoubleMatrix(n,1,mxREAL);
   plhs[2] = mxCreateDoubleMatrix(1,1,mxREAL);
   plhs[3] = mxCreateDoubleMatrix(1,1,mxREAL);
   double* minFlux = mxGetPr(plhs[0]);
   double* maxFlux = mxGetPr(plhs[1]);
   double* dOptSol  = mxGetPr(plhs[2]);
   double* dRetValue= mxGetPr(plhs[3]);

   glp_prob* P;
   P = glp_create_prob();
   _setup_problem(P,c,nz,jc,ir,pr,b,sense,lb,ub,m,n);
   int iRet = _fva(P,minFlux,maxFlux,dOptSol,m,n,optPercentage,objective,rxns,nrxn,verbose);
   *dRetValue=iRet;

   glp_delete_prob(P);
   mxFree(sense);
}

void _setup_problem(glp_prob* P, const double* c, const size_t nz, mwIndex* jc, mwIndex* ir, const double* pr, const double* b,
                    const char* sense, const double* lb, const double* ub, mwSize m, mwSize n)
{
   glp_add_cols(P, (int)n);
   glp_add_rows(P, (int)m);

   // Objective function coefficients
   for (int j = 1; j <= n; j++)
   {
      glp_set_obj_coef(P, j, c[j-1]);
   }

   // Bounds: lb<=x<=ub
   for (int j = 0; j < n; j++)
   {
      if (lb[j] == ub[j])
      {
         glp_set_col_bnds (P, j + 1, GLP_FX, lb[j], ub[j]);
      }
      else
      {
         glp_set_col_bnds (P, j + 1, GLP_DB, lb[j], ub[j]);
      }
   }

   // Setup the constraint matrix: Ax=b
   // The code for sparse-matrix handling comes from GLPKMEX
   int* rn=(int *)mxCalloc(nz+1,sizeof(int));
   int* cn=(int *)mxCalloc(nz+1,sizeof(int));
   double* A=(double *)mxCalloc(nz+1,sizeof(double));
   size_t nelc,count,row;
   count=0; row=0;
   for(int i=1;i<=n;i++)
   {
      nelc=jc[i]-jc[i-1];
      for(int j=0;j<nelc;j++)
      {
         count++;
         rn[count]=ir[row]+1;
         cn[count]=i;
         A[count]=pr[row];
         row++;
      }
   }

   glp_load_matrix (P, nz, rn, cn, A);

   // Right hand sides ("constraint bounds")
   for (int i = 1; i <= m; i++)
   {
      if (sense[i-1] == 'E')
      {
         glp_set_row_bnds(P, i, GLP_FX, b[i-1], b[i-1]);
      }
      else if (sense[i-1] == 'G')
      {
         glp_set_row_bnds(P, i, GLP_LO, b[i-1], b[i-1]);
      }
      else
      {
         glp_set_row_bnds(P, i, GLP_UP, b[i-1], b[i-1]);
      }
   }

   mxFree(rn);
   mxFree(cn);
   mxFree(A);
}

int _fva(glp_prob* P, double* minFlux, double* maxFlux, double* optSol, mwSize m, mwSize n, double optPercentage,
         int objective, const double* rxns, int nrxn, int verbose)
{
   // Parameters for the glpk optimizer, use mostly default settings
	glp_smcp param;
	glp_init_smcp(&param);
	param.presolve = GLP_ON;

   // Objective (min or max)
   glp_set_obj_dir(P, (objective==1) ? GLP_MIN : GLP_MAX);

   const double tol = 1.0e-6;

   // Solve the initial problem
   glp_adv_basis(P, 0);
   int ret = glp_simplex(P, &param);
   if (ret != 0)
   {
      if (verbose)
      {
   	   mexPrintf("Unable to solve initial problem. Exiting.\n");
      }
      return FVA_INIT_FAIL;
   }
   double z = glp_get_obj_val(P);
   *optSol = z;
   n = glp_get_num_cols(P);

   // Determine the value of objective function bound
   double TargetValue = 0;
   if (glp_get_obj_dir(P) == GLP_MAX)
   {
      TargetValue = floor(z/tol)*tol*optPercentage/100.0;
   }
   else
   {
      TargetValue = ceil(z/tol)*tol*optPercentage/100.0;
   }
   if (verbose)
   {
      mexPrintf("Objective value for initial problem=%1.8f\n", z);
      mexPrintf("Number of columns=%d\n", n);
      mexPrintf("Target objective value=%.6g (%1.0f percent)\n", TargetValue, optPercentage);
      mexPrintf("Processing %d reactions\n", nrxn);
   }

   // Add a constraint which bounds the objective, c'v >= objValue in case of max, (<= for min)
   m = glp_add_rows(P, 1);

   if (glp_get_obj_dir(P) == GLP_MAX)
   {
      glp_set_row_bnds(P, m, GLP_LO, TargetValue, 0.0);
   }
   else
   {
      glp_set_row_bnds(P, m, GLP_UP, 0, TargetValue);
   }

   int* ind = (int*)malloc( (n+1)*sizeof(int));
   double* val = (double*)malloc( (n+1)*sizeof(double));
   for (int j = 1; j <= n; j++)
   {
      ind[j]=j;
      val[j]=glp_get_obj_coef(P, j);
   }
   glp_set_mat_row(P, m, n, ind, val);
   free(ind);
   free(val);

   // Zero all objective function coefficients
   for (int j = 1; j <= n; j++)
   {
      glp_set_obj_coef(P, j, 0.0);
   }

   // Solve all the minimization problems first. The difference in the optimal
   // solution for two minimization problems is probably much smaller on average
   // than the difference between one min and one max solutions, leading to fewer
   // simplex iterations in each step.
 	param.presolve = GLP_OFF;
   param.msg_lev = GLP_MSG_OFF;
   param.tm_lim = 1000*TIME_RESTART_LIM;

   for (int iRound = 0; iRound < 2; iRound++)
   {
      glp_set_obj_dir(P, (iRound==0) ? GLP_MIN : GLP_MAX);
      for (int k = 0; k < nrxn; k++)
      {
         int j = rxns[k]; // GLPK indices start at 1
         glp_set_obj_coef(P, j, 1.0);
         ret = glp_simplex(P, &param);
         glp_set_obj_coef(P, j, 0.0);
         if (ret != 0)
         {
            // Numerical difficulties or timeout
            param.tm_lim = INT_MAX;
            if (verbose)
            {
               mexPrintf("Unable to use warm-start on modified problem (or timeout) %d. Resolving it from scratch instead\n", j);
            }
            param.presolve = GLP_ON;
            glp_adv_basis(P, 0);
            ret = glp_simplex(P, &param);
            if (ret != 0)
            {
               if (verbose)
               {
   	            mexPrintf("Unable to solve modified problem. Exiting.\n");
               }
               return FVA_MODIFIED_FAIL;
            }
            param.presolve = GLP_OFF;
            param.tm_lim = 1000*TIME_RESTART_LIM;
         }

         if (glp_get_obj_dir(P) == GLP_MIN)
         {
            minFlux[j-1]= glp_get_obj_val(P);
         }
         else
         {
            maxFlux[j-1]=glp_get_obj_val(P);
         }
      }
   }

   return FVA_SUCCESS;
}
