/* --------------------------------------------------------------------------
 * File: cplex.h
 * Version 12.9.0
 * --------------------------------------------------------------------------
 * Licensed Materials - Property of IBM
 * 5725-A06 5725-A29 5724-Y48 5724-Y49 5724-Y54 5724-Y55 5655-Y21
 * Copyright IBM Corporation 1988, 2019. All Rights Reserved.
 *
 * US Government Users Restricted Rights - Use, duplication or
 * disclosure restricted by GSA ADP Schedule Contract with
 * IBM Corp.
 *---------------------------------------------------------------------------
 */

#ifndef CPX_H
#   define CPX_H 1
#include "cpxconst.h"

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

CPXLIBAPI
int CPXPUBLIC
   CPXaddcols (CPXCENVptr env, CPXLPptr lp, int ccnt, int nzcnt,
               double const *obj, int const *cmatbeg,
               int const *cmatind, double const *cmatval,
               double const *lb, double const *ub, char **colname);


CPXLIBAPI
int CPXPUBLIC
   CPXaddfuncdest (CPXCENVptr env, CPXCHANNELptr channel, void *handle,
                   void(CPXPUBLIC *msgfunction)(void *, const char *));


CPXLIBAPI
int CPXPUBLIC
   CPXaddpwl (CPXCENVptr env, CPXLPptr lp, int vary, int varx,
              double preslope, double postslope, int nbreaks,
              double const *breakx, double const *breaky,
              char const *pwlname);


CPXLIBAPI
int CPXPUBLIC
   CPXaddrows (CPXCENVptr env, CPXLPptr lp, int ccnt, int rcnt,
               int nzcnt, double const *rhs, char const *sense,
               int const *rmatbeg, int const *rmatind,
               double const *rmatval, char **colname, char **rowname);


CPXLIBAPI
int CPXPUBLIC
   CPXbasicpresolve (CPXCENVptr env, CPXLPptr lp, double *redlb,
                     double *redub, int *rstat);


CPXLIBAPI
int CPXPUBLIC
   CPXbinvacol (CPXCENVptr env, CPXCLPptr lp, int j, double *x);


CPXLIBAPI
int CPXPUBLIC
   CPXbinvarow (CPXCENVptr env, CPXCLPptr lp, int i, double *z);


CPXLIBAPI
int CPXPUBLIC
   CPXbinvcol (CPXCENVptr env, CPXCLPptr lp, int j, double *x);


CPXLIBAPI
int CPXPUBLIC
   CPXbinvrow (CPXCENVptr env, CPXCLPptr lp, int i, double *y);


CPXLIBAPI
int CPXPUBLIC
   CPXboundsa (CPXCENVptr env, CPXCLPptr lp, int begin, int end,
               double *lblower, double *lbupper, double *ublower,
               double *ubupper);


CPXLIBAPI
int CPXPUBLIC
   CPXbtran (CPXCENVptr env, CPXCLPptr lp, double *y);


CPXLIBAPI
void CPXPUBLIC
   CPXcallbackabort (CPXCALLBACKCONTEXTptr context);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackaddusercuts (CPXCALLBACKCONTEXTptr context, int rcnt,
                           int nzcnt, double const *rhs,
                           char const *sense, int const *rmatbeg,
                           int const *rmatind, double const *rmatval,
                           int const *purgeable, int const *local);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackcandidateispoint (CPXCALLBACKCONTEXTptr context,
                                int *ispoint_p);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackcandidateisray (CPXCALLBACKCONTEXTptr context,
                              int *isray_p);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackgetcandidatepoint (CPXCALLBACKCONTEXTptr context,
                                 double *x, int begin, int end,
                                 double *obj_p);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackgetcandidateray (CPXCALLBACKCONTEXTptr context,
                               double *x, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackgetfunc (CPXCENVptr env, CPXCLPptr lp,
                       CPXLONG *contextmask_p,
                       CPXCALLBACKFUNC **callback_p,
                       void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackgetincumbent (CPXCALLBACKCONTEXTptr context, double *x,
                            int begin, int end, double *obj_p);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackgetinfodbl (CPXCALLBACKCONTEXTptr context,
                          CPXCALLBACKINFO what, double *data_p);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackgetinfoint (CPXCALLBACKCONTEXTptr context,
                          CPXCALLBACKINFO what, CPXINT *data_p);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackgetinfolong (CPXCALLBACKCONTEXTptr context,
                           CPXCALLBACKINFO what, CPXLONG *data_p);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackgetrelaxationpoint (CPXCALLBACKCONTEXTptr context,
                                  double *x, int begin, int end,
                                  double *obj_p);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackpostheursoln (CPXCALLBACKCONTEXTptr context, int cnt,
                            int const *ind, double const *val,
                            double obj,
                            CPXCALLBACKSOLUTIONSTRATEGY strat);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackrejectcandidate (CPXCALLBACKCONTEXTptr context, int rcnt,
                               int nzcnt, double const *rhs,
                               char const *sense, int const *rmatbeg,
                               int const *rmatind,
                               double const *rmatval);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbacksetfunc (CPXENVptr env, CPXLPptr lp, CPXLONG contextmask,
                       CPXCALLBACKFUNC callback, void *userhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXcheckdfeas (CPXCENVptr env, CPXLPptr lp, int *infeas_p);


CPXLIBAPI
int CPXPUBLIC
   CPXcheckpfeas (CPXCENVptr env, CPXLPptr lp, int *infeas_p);


CPXLIBAPI
int CPXPUBLIC
   CPXchecksoln (CPXCENVptr env, CPXLPptr lp, int *lpstatus_p);


CPXLIBAPI
int CPXPUBLIC
   CPXchgbds (CPXCENVptr env, CPXLPptr lp, int cnt, int const *indices,
              char const *lu, double const *bd);


CPXLIBAPI
int CPXPUBLIC
   CPXchgcoef (CPXCENVptr env, CPXLPptr lp, int i, int j,
               double newvalue);


CPXLIBAPI
int CPXPUBLIC
   CPXchgcoeflist (CPXCENVptr env, CPXLPptr lp, int numcoefs,
                   int const *rowlist, int const *collist,
                   double const *vallist);


CPXLIBAPI
int CPXPUBLIC
   CPXchgcolname (CPXCENVptr env, CPXLPptr lp, int cnt,
                  int const *indices, char **newname);


CPXLIBAPI
int CPXPUBLIC
   CPXchgname (CPXCENVptr env, CPXLPptr lp, int key, int ij,
               char const *newname_str);


CPXLIBAPI
int CPXPUBLIC
   CPXchgobj (CPXCENVptr env, CPXLPptr lp, int cnt, int const *indices,
              double const *values);


CPXLIBAPI
int CPXPUBLIC
   CPXchgobjoffset (CPXCENVptr env, CPXLPptr lp, double offset);


CPXLIBAPI
int CPXPUBLIC
   CPXchgobjsen (CPXCENVptr env, CPXLPptr lp, int maxormin);


CPXLIBAPI
int CPXPUBLIC
   CPXchgprobname (CPXCENVptr env, CPXLPptr lp, char const *probname);


CPXLIBAPI
int CPXPUBLIC
   CPXchgprobtype (CPXCENVptr env, CPXLPptr lp, int type);


CPXLIBAPI
int CPXPUBLIC
   CPXchgprobtypesolnpool (CPXCENVptr env, CPXLPptr lp, int type,
                           int soln);


CPXLIBAPI
int CPXPUBLIC
   CPXchgrhs (CPXCENVptr env, CPXLPptr lp, int cnt, int const *indices,
              double const *values);


CPXLIBAPI
int CPXPUBLIC
   CPXchgrngval (CPXCENVptr env, CPXLPptr lp, int cnt,
                 int const *indices, double const *values);


CPXLIBAPI
int CPXPUBLIC
   CPXchgrowname (CPXCENVptr env, CPXLPptr lp, int cnt,
                  int const *indices, char **newname);


CPXLIBAPI
int CPXPUBLIC
   CPXchgsense (CPXCENVptr env, CPXLPptr lp, int cnt,
                int const *indices, char const *sense);


CPXLIBAPI
int CPXPUBLIC
   CPXcleanup (CPXCENVptr env, CPXLPptr lp, double eps);


CPXLIBAPI
CPXLPptr CPXPUBLIC
   CPXcloneprob (CPXCENVptr env, CPXCLPptr lp, int *status_p);


CPXLIBAPI
int CPXPUBLIC
   CPXcloseCPLEX (CPXENVptr *env_p);


CPXLIBAPI
int CPXPUBLIC
   CPXclpwrite (CPXCENVptr env, CPXCLPptr lp, char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXcompletelp (CPXCENVptr env, CPXLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXcopybase (CPXCENVptr env, CPXLPptr lp, int const *cstat,
                int const *rstat);


CPXLIBAPI
int CPXPUBLIC
   CPXcopybasednorms (CPXCENVptr env, CPXLPptr lp, int const *cstat,
                      int const *rstat, double const *dnorm);


CPXLIBAPI
int CPXPUBLIC
   CPXcopydnorms (CPXCENVptr env, CPXLPptr lp, double const *norm,
                  int const *head, int len);


CPXLIBAPI
int CPXPUBLIC
   CPXcopylp (CPXCENVptr env, CPXLPptr lp, int numcols, int numrows,
              int objsense, double const *objective, double const *rhs,
              char const *sense, int const *matbeg, int const *matcnt,
              int const *matind, double const *matval,
              double const *lb, double const *ub, double const *rngval);


CPXLIBAPI
int CPXPUBLIC
   CPXcopylpwnames (CPXCENVptr env, CPXLPptr lp, int numcols,
                    int numrows, int objsense, double const *objective,
                    double const *rhs, char const *sense,
                    int const *matbeg, int const *matcnt,
                    int const *matind, double const *matval,
                    double const *lb, double const *ub,
                    double const *rngval, char **colname,
                    char **rowname);


CPXLIBAPI
int CPXPUBLIC
   CPXcopynettolp (CPXCENVptr env, CPXLPptr lp, CPXCNETptr net);


CPXLIBAPI
int CPXPUBLIC
   CPXcopyobjname (CPXCENVptr env, CPXLPptr lp,
                   char const *objname_str);


CPXLIBAPI
int CPXPUBLIC
   CPXcopypartialbase (CPXCENVptr env, CPXLPptr lp, int ccnt,
                       int const *cindices, int const *cstat, int rcnt,
                       int const *rindices, int const *rstat);


CPXLIBAPI
int CPXPUBLIC
   CPXcopypnorms (CPXCENVptr env, CPXLPptr lp, double const *cnorm,
                  double const *rnorm, int len);


CPXLIBAPI
int CPXPUBLIC
   CPXcopyprotected (CPXCENVptr env, CPXLPptr lp, int cnt,
                     int const *indices);


CPXLIBAPI
int CPXPUBLIC
   CPXcopystart (CPXCENVptr env, CPXLPptr lp, int const *cstat,
                 int const *rstat, double const *cprim,
                 double const *rprim, double const *cdual,
                 double const *rdual);


CPXLIBAPI
CPXLPptr CPXPUBLIC
   CPXcreateprob (CPXCENVptr env, int *status_p,
                  char const *probname_str);


CPXLIBAPI
int CPXPUBLIC
   CPXcrushform (CPXCENVptr env, CPXCLPptr lp, int len, int const *ind,
                 double const *val, int *plen_p, double *poffset_p,
                 int *pind, double *pval);


CPXLIBAPI
int CPXPUBLIC
   CPXcrushpi (CPXCENVptr env, CPXCLPptr lp, double const *pi,
               double *prepi);


CPXLIBAPI
int CPXPUBLIC
   CPXcrushx (CPXCENVptr env, CPXCLPptr lp, double const *x,
              double *prex);


CPXLIBAPI
int CPXPUBLIC
   CPXdelcols (CPXCENVptr env, CPXLPptr lp, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXdeldblannotation (CPXCENVptr env, CPXLPptr lp, int idx);


CPXLIBAPI
int CPXPUBLIC
   CPXdeldblannotations (CPXCENVptr env, CPXLPptr lp, int begin,
                         int end);


CPXLIBAPI
int CPXPUBLIC
   CPXdelfuncdest (CPXCENVptr env, CPXCHANNELptr channel, void *handle,
                   void(CPXPUBLIC *msgfunction)(void *, const char *));


CPXLIBAPI
int CPXPUBLIC
   CPXdellongannotation (CPXCENVptr env, CPXLPptr lp, int idx);


CPXLIBAPI
int CPXPUBLIC
   CPXdellongannotations (CPXCENVptr env, CPXLPptr lp, int begin,
                          int end);


CPXLIBAPI
int CPXPUBLIC
   CPXdelnames (CPXCENVptr env, CPXLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXdelpwl (CPXCENVptr env, CPXLPptr lp, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXdelrows (CPXCENVptr env, CPXLPptr lp, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXdelsetcols (CPXCENVptr env, CPXLPptr lp, int *delstat);


CPXLIBAPI
int CPXPUBLIC
   CPXdelsetpwl (CPXCENVptr env, CPXLPptr lp, int *delstat);


CPXLIBAPI
int CPXPUBLIC
   CPXdelsetrows (CPXCENVptr env, CPXLPptr lp, int *delstat);


CPXLIBAPI
int CPXPUBLIC
   CPXdeserializercreate (CPXDESERIALIZERptr *deser_p, CPXLONG size,
                          void const *buffer);


CPXLIBAPI
void CPXPUBLIC
   CPXdeserializerdestroy (CPXDESERIALIZERptr deser);


CPXLIBAPI
CPXLONG CPXPUBLIC
   CPXdeserializerleft (CPXCDESERIALIZERptr deser);


CPXLIBAPI
int CPXPUBLIC
   CPXdisconnectchannel (CPXCENVptr env, CPXCHANNELptr channel);


CPXLIBAPI
int CPXPUBLIC
   CPXdjfrompi (CPXCENVptr env, CPXCLPptr lp, double const *pi,
                double *dj);


CPXLIBAPI
int CPXPUBLIC
   CPXdperwrite (CPXCENVptr env, CPXLPptr lp, char const *filename_str,
                 double epsilon);


CPXLIBAPI
int CPXPUBLIC
   CPXdratio (CPXCENVptr env, CPXLPptr lp, int *indices, int cnt,
              double *downratio, double *upratio, int *downenter,
              int *upenter, int *downstatus, int *upstatus);


CPXLIBAPI
int CPXPUBLIC
   CPXdualfarkas (CPXCENVptr env, CPXCLPptr lp, double *y,
                  double *proof_p);


CPXLIBAPI
int CPXPUBLIC
   CPXdualopt (CPXCENVptr env, CPXLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXdualwrite (CPXCENVptr env, CPXCLPptr lp,
                 char const *filename_str, double *objshift_p);


CPXLIBAPI
int CPXPUBLIC
   CPXembwrite (CPXCENVptr env, CPXLPptr lp, char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXfeasopt (CPXCENVptr env, CPXLPptr lp, double const *rhs,
               double const *rng, double const *lb, double const *ub);


CPXLIBAPI
int CPXPUBLIC
   CPXfeasoptext (CPXCENVptr env, CPXLPptr lp, int grpcnt, int concnt,
                  double const *grppref, int const *grpbeg,
                  int const *grpind, char const *grptype);


CPXLIBAPI
void CPXPUBLIC
   CPXfinalize (void);


CPXLIBAPI
int CPXPUBLIC
   CPXflushchannel (CPXCENVptr env, CPXCHANNELptr channel);


CPXLIBAPI
int CPXPUBLIC
   CPXflushstdchannels (CPXCENVptr env);


CPXLIBAPI
int CPXPUBLIC
   CPXfreepresolve (CPXCENVptr env, CPXLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXfreeprob (CPXCENVptr env, CPXLPptr *lp_p);


CPXLIBAPI
int CPXPUBLIC
   CPXftran (CPXCENVptr env, CPXCLPptr lp, double *x);


CPXLIBAPI
int CPXPUBLIC
   CPXgetax (CPXCENVptr env, CPXCLPptr lp, double *x, int begin,
             int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetbaritcnt (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetbase (CPXCENVptr env, CPXCLPptr lp, int *cstat, int *rstat);


CPXLIBAPI
int CPXPUBLIC
   CPXgetbasednorms (CPXCENVptr env, CPXCLPptr lp, int *cstat,
                     int *rstat, double *dnorm);


CPXLIBAPI
int CPXPUBLIC
   CPXgetbhead (CPXCENVptr env, CPXCLPptr lp, int *head, double *x);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbackinfo (CPXCENVptr env, void *cbdata, int wherefrom,
                       int whichinfo, void *result_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetchannels (CPXCENVptr env, CPXCHANNELptr *cpxresults_p,
                   CPXCHANNELptr *cpxwarning_p,
                   CPXCHANNELptr *cpxerror_p, CPXCHANNELptr *cpxlog_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetchgparam (CPXCENVptr env, int *cnt_p, int *paramnum,
                   int pspace, int *surplus_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcoef (CPXCENVptr env, CPXCLPptr lp, int i, int j,
               double *coef_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcolindex (CPXCENVptr env, CPXCLPptr lp, char const *lname_str,
                   int *index_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcolinfeas (CPXCENVptr env, CPXCLPptr lp, double const *x,
                    double *infeasout, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcolname (CPXCENVptr env, CPXCLPptr lp, char  **name,
                  char *namestore, int storespace, int *surplus_p,
                  int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcols (CPXCENVptr env, CPXCLPptr lp, int *nzcnt_p,
               int *cmatbeg, int *cmatind, double *cmatval,
               int cmatspace, int *surplus_p, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetconflict (CPXCENVptr env, CPXCLPptr lp, int *confstat_p,
                   int *rowind, int *rowbdstat, int *confnumrows_p,
                   int *colind, int *colbdstat, int *confnumcols_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetconflictext (CPXCENVptr env, CPXCLPptr lp, int *grpstat,
                      int beg, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcrossdexchcnt (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcrossdpushcnt (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcrosspexchcnt (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcrossppushcnt (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetdblannotationdefval (CPXCENVptr env, CPXCLPptr lp, int idx,
                              double *defval_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetdblannotationindex (CPXCENVptr env, CPXCLPptr lp,
                             char const *annotationname_str,
                             int *index_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetdblannotationname (CPXCENVptr env, CPXCLPptr lp, int idx,
                            char *buf_str, int bufspace,
                            int *surplus_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetdblannotations (CPXCENVptr env, CPXCLPptr lp, int idx,
                         int objtype, double *annotation, int begin,
                         int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetdblparam (CPXCENVptr env, int whichparam, double *value_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetdblquality (CPXCENVptr env, CPXCLPptr lp, double *quality_p,
                     int what);


CPXLIBAPI
int CPXPUBLIC
   CPXgetdettime (CPXCENVptr env, double *dettimestamp_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetdj (CPXCENVptr env, CPXCLPptr lp, double *dj, int begin,
             int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetdnorms (CPXCENVptr env, CPXCLPptr lp, double *norm, int *head,
                 int *len_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetdsbcnt (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
CPXCCHARptr CPXPUBLIC
   CPXgeterrorstring (CPXCENVptr env, int errcode, char *buffer_str);


CPXLIBAPI
int CPXPUBLIC
   CPXgetgrad (CPXCENVptr env, CPXCLPptr lp, int j, int *head,
               double *y);


CPXLIBAPI
int CPXPUBLIC
   CPXgetijdiv (CPXCENVptr env, CPXCLPptr lp, int *idiv_p, int *jdiv_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetijrow (CPXCENVptr env, CPXCLPptr lp, int i, int j, int *row_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetintparam (CPXCENVptr env, int whichparam, CPXINT *value_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetintquality (CPXCENVptr env, CPXCLPptr lp, int *quality_p,
                     int what);


CPXLIBAPI
int CPXPUBLIC
   CPXgetitcnt (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetlb (CPXCENVptr env, CPXCLPptr lp, double *lb, int begin,
             int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetlogfilename (CPXCENVptr env, char *buf_str, int bufspace,
                      int *surplus_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetlongannotationdefval (CPXCENVptr env, CPXCLPptr lp, int idx,
                               CPXLONG *defval_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetlongannotationindex (CPXCENVptr env, CPXCLPptr lp,
                              char const *annotationname_str,
                              int *index_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetlongannotationname (CPXCENVptr env, CPXCLPptr lp, int idx,
                             char *buf_str, int bufspace,
                             int *surplus_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetlongannotations (CPXCENVptr env, CPXCLPptr lp, int idx,
                          int objtype, CPXLONG *annotation, int begin,
                          int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetlongparam (CPXCENVptr env, int whichparam, CPXLONG *value_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetlpcallbackfunc (CPXCENVptr env,
                         int(CPXPUBLIC **callback_p)(CPXCENVptr, void *, int, void *),
                         void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetmethod (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnetcallbackfunc (CPXCENVptr env,
                          int(CPXPUBLIC **callback_p)(CPXCENVptr, void *, int, void *),
                          void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumcols (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumcores (CPXCENVptr env, int *numcores_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumdblannotations (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumlongannotations (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumnz (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumobjs (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumpwl (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumrows (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetobj (CPXCENVptr env, CPXCLPptr lp, double *obj, int begin,
              int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetobjname (CPXCENVptr env, CPXCLPptr lp, char *buf_str,
                  int bufspace, int *surplus_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetobjoffset (CPXCENVptr env, CPXCLPptr lp, double *objoffset_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetobjsen (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetobjval (CPXCENVptr env, CPXCLPptr lp, double *objval_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetparamhiername (CPXCENVptr env, int whichparam, char *name_str);


CPXLIBAPI
int CPXPUBLIC
   CPXgetparamname (CPXCENVptr env, int whichparam, char *name_str);


CPXLIBAPI
int CPXPUBLIC
   CPXgetparamnum (CPXCENVptr env, char const *name_str,
                   int *whichparam_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetparamtype (CPXCENVptr env, int whichparam, int *paramtype);


CPXLIBAPI
int CPXPUBLIC
   CPXgetphase1cnt (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetpi (CPXCENVptr env, CPXCLPptr lp, double *pi, int begin,
             int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetpnorms (CPXCENVptr env, CPXCLPptr lp, double *cnorm,
                 double *rnorm, int *len_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetprestat (CPXCENVptr env, CPXCLPptr lp, int *prestat_p,
                  int *pcstat, int *prstat, int *ocstat, int *orstat);


CPXLIBAPI
int CPXPUBLIC
   CPXgetprobname (CPXCENVptr env, CPXCLPptr lp, char *buf_str,
                   int bufspace, int *surplus_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetprobtype (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetprotected (CPXCENVptr env, CPXCLPptr lp, int *cnt_p,
                    int *indices, int pspace, int *surplus_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetpsbcnt (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetpwl (CPXCENVptr env, CPXCLPptr lp, int pwlindex, int *vary_p,
              int *varx_p, double *preslope_p, double *postslope_p,
              int *nbreaks_p, double *breakx, double *breaky,
              int breakspace, int *surplus_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetpwlindex (CPXCENVptr env, CPXCLPptr lp, char const *lname_str,
                   int *index_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetpwlname (CPXCENVptr env, CPXCLPptr lp, char *buf_str,
                  int bufspace, int *surplus_p, int which);


CPXLIBAPI
int CPXPUBLIC
   CPXgetray (CPXCENVptr env, CPXCLPptr lp, double *z);


CPXLIBAPI
int CPXPUBLIC
   CPXgetredlp (CPXCENVptr env, CPXCLPptr lp, CPXCLPptr *redlp_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetrhs (CPXCENVptr env, CPXCLPptr lp, double *rhs, int begin,
              int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetrngval (CPXCENVptr env, CPXCLPptr lp, double *rngval,
                 int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetrowindex (CPXCENVptr env, CPXCLPptr lp, char const *lname_str,
                   int *index_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetrowinfeas (CPXCENVptr env, CPXCLPptr lp, double const *x,
                    double *infeasout, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetrowname (CPXCENVptr env, CPXCLPptr lp, char  **name,
                  char *namestore, int storespace, int *surplus_p,
                  int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetrows (CPXCENVptr env, CPXCLPptr lp, int *nzcnt_p,
               int *rmatbeg, int *rmatind, double *rmatval,
               int rmatspace, int *surplus_p, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsense (CPXCENVptr env, CPXCLPptr lp, char *sense, int begin,
                int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsiftitcnt (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsiftphase1cnt (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetslack (CPXCENVptr env, CPXCLPptr lp, double *slack, int begin,
                int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpooldblquality (CPXCENVptr env, CPXCLPptr lp, int soln,
                             double *quality_p, int what);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpoolintquality (CPXCENVptr env, CPXCLPptr lp, int soln,
                             int *quality_p, int what);


CPXLIBAPI
int CPXPUBLIC
   CPXgetstat (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
CPXCHARptr CPXPUBLIC
   CPXgetstatstring (CPXCENVptr env, int statind, char *buffer_str);


CPXLIBAPI
int CPXPUBLIC
   CPXgetstrparam (CPXCENVptr env, int whichparam, char *value_str);


CPXLIBAPI
int CPXPUBLIC
   CPXgettime (CPXCENVptr env, double *timestamp_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgettuningcallbackfunc (CPXCENVptr env,
                             int(CPXPUBLIC **callback_p)(CPXCENVptr, void *, int, void *),
                             void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetub (CPXCENVptr env, CPXCLPptr lp, double *ub, int begin,
             int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetweight (CPXCENVptr env, CPXCLPptr lp, int rcnt,
                 int const *rmatbeg, int const *rmatind,
                 double const *rmatval, double *weight, int dpriind);


CPXLIBAPI
int CPXPUBLIC
   CPXgetx (CPXCENVptr env, CPXCLPptr lp, double *x, int begin,
            int end);


CPXLIBAPI
int CPXPUBLIC
   CPXhybnetopt (CPXCENVptr env, CPXLPptr lp, int method);


CPXLIBAPI
int CPXPUBLIC
   CPXinfodblparam (CPXCENVptr env, int whichparam, double *defvalue_p,
                    double *minvalue_p, double *maxvalue_p);


CPXLIBAPI
int CPXPUBLIC
   CPXinfointparam (CPXCENVptr env, int whichparam, CPXINT *defvalue_p,
                    CPXINT *minvalue_p, CPXINT *maxvalue_p);


CPXLIBAPI
int CPXPUBLIC
   CPXinfolongparam (CPXCENVptr env, int whichparam,
                     CPXLONG *defvalue_p, CPXLONG *minvalue_p,
                     CPXLONG *maxvalue_p);


CPXLIBAPI
int CPXPUBLIC
   CPXinfostrparam (CPXCENVptr env, int whichparam, char *defvalue_str);


CPXLIBAPI
void CPXPUBLIC
   CPXinitialize (void);


CPXLIBAPI
int CPXPUBLIC
   CPXkilldnorms (CPXLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXkillpnorms (CPXLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXlpopt (CPXCENVptr env, CPXLPptr lp);



int CPXPUBLIC
   CPXlprewrite (CPXCENVptr env, CPXCLPptr lp,
                 char const *filename_str);



int CPXPUBLIC
   CPXlpwrite (CPXCENVptr env, CPXCLPptr lp, char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXmbasewrite (CPXCENVptr env, CPXCLPptr lp,
                  char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXmdleave (CPXCENVptr env, CPXLPptr lp, int const *indices,
               int cnt, double *downratio, double *upratio);


CPXLIBAPI
int CPXPUBLIC
   CPXmodelasstcallbackgetfunc (CPXCENVptr env, CPXCLPptr lp,
                                CPXMODELASSTCALLBACKFUNC **callback_p,
                                void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXmodelasstcallbacksetfunc (CPXENVptr env, CPXLPptr lp,
                                CPXMODELASSTCALLBACKFUNC callback,
                                void *userhandle);


int CPXPUBLIC
   CPXmpsrewrite (CPXCENVptr env, CPXCLPptr lp,
                  char const *filename_str);


int CPXPUBLIC
   CPXmpswrite (CPXCENVptr env, CPXCLPptr lp, char const *filename_str);


int CPXPUBVARARGS
   CPXmsg (CPXCHANNELptr channel, char const *format, ...) ;


CPXLIBAPI
int CPXPUBLIC
   CPXmsgstr (CPXCHANNELptr channel, char const *msg_str);


CPXLIBAPI
int CPXPUBLIC
   CPXmultiobjchgattribs (CPXCENVptr env, CPXLPptr lp, int objind,
                          double offset, double weight, int priority,
                          double abstol, double reltol,
                          char const *name);



CPXLIBAPI
int CPXPUBLIC
   CPXmultiobjgetdblinfo (CPXCENVptr env, CPXCLPptr lp, int subprob,
                          double *info_p, int what);



CPXLIBAPI
int CPXPUBLIC
   CPXmultiobjgetindex (CPXCENVptr env, CPXCLPptr lp, char const *name,
                        int *index_p);


CPXLIBAPI
int CPXPUBLIC
   CPXmultiobjgetintinfo (CPXCENVptr env, CPXCLPptr lp, int subprob,
                          int *info_p, int what);


CPXLIBAPI
int CPXPUBLIC
   CPXmultiobjgetlonginfo (CPXCENVptr env, CPXCLPptr lp, int subprob,
                           CPXLONG *info_p, int what);


CPXLIBAPI
int CPXPUBLIC
   CPXmultiobjgetname (CPXCENVptr env, CPXCLPptr lp, int objind,
                       char *buf_str, int bufspace, int *surplus_p);


CPXLIBAPI
int CPXPUBLIC
   CPXmultiobjgetnumsolves (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXmultiobjgetobj (CPXCENVptr env, CPXCLPptr lp, int n,
                      double *coeffs, int begin, int end,
                      double *offset_p, double *weight_p,
                      int *priority_p, double *abstol_p,
                      double *reltol_p);


CPXLIBAPI
int CPXPUBLIC
   CPXmultiobjgetobjval (CPXCENVptr env, CPXCLPptr lp, int n,
                         double *objval_p);


CPXLIBAPI
int CPXPUBLIC
   CPXmultiobjgetobjvalbypriority (CPXCENVptr env, CPXCLPptr lp,
                                   int priority, double *objval_p);


CPXLIBAPI
int CPXPUBLIC
   CPXmultiobjopt (CPXCENVptr env, CPXLPptr lp,
                   CPXCPARAMSETptr const *paramsets);


CPXLIBAPI
int CPXPUBLIC
   CPXmultiobjsetobj (CPXCENVptr env, CPXLPptr lp, int n, int objnz,
                      int const *objind, double const *objval,
                      double offset, double weight, int priority,
                      double abstol, double reltol,
                      char const *objname);


CPXLIBAPI
int CPXPUBLIC
   CPXNETextract (CPXCENVptr env, CPXNETptr net, CPXCLPptr lp,
                  int *colmap, int *rowmap);


CPXLIBAPI
int CPXPUBLIC
   CPXnewcols (CPXCENVptr env, CPXLPptr lp, int ccnt,
               double const *obj, double const *lb, double const *ub,
               char const *xctype, char **colname);


CPXLIBAPI
int CPXPUBLIC
   CPXnewdblannotation (CPXCENVptr env, CPXLPptr lp,
                        char const *annotationname_str, double defval);


CPXLIBAPI
int CPXPUBLIC
   CPXnewlongannotation (CPXCENVptr env, CPXLPptr lp,
                         char const *annotationname_str,
                         CPXLONG defval);


CPXLIBAPI
int CPXPUBLIC
   CPXnewrows (CPXCENVptr env, CPXLPptr lp, int rcnt,
               double const *rhs, char const *sense,
               double const *rngval, char **rowname);


CPXLIBAPI
int CPXPUBLIC
   CPXobjsa (CPXCENVptr env, CPXCLPptr lp, int begin, int end,
             double *lower, double *upper);


CPXLIBAPI
CPXENVptr CPXPUBLIC
   CPXopenCPLEX (int *status_p);


CPXLIBAPI
int CPXPUBLIC
   CPXparamsetadddbl (CPXCENVptr env, CPXPARAMSETptr ps,
                      int whichparam, double newvalue);


CPXLIBAPI
int CPXPUBLIC
   CPXparamsetaddint (CPXCENVptr env, CPXPARAMSETptr ps,
                      int whichparam, CPXINT newvalue);


CPXLIBAPI
int CPXPUBLIC
   CPXparamsetaddlong (CPXCENVptr env, CPXPARAMSETptr ps,
                       int whichparam, CPXLONG newvalue);


CPXLIBAPI
int CPXPUBLIC
   CPXparamsetaddstr (CPXCENVptr env, CPXPARAMSETptr ps,
                      int whichparam, char const *svalue);


CPXLIBAPI
int CPXPUBLIC
   CPXparamsetapply (CPXENVptr env, CPXCPARAMSETptr ps);


CPXLIBAPI
int CPXPUBLIC
   CPXparamsetcopy (CPXCENVptr targetenv, CPXPARAMSETptr targetps,
                    CPXCPARAMSETptr sourceps);


CPXLIBAPI
CPXPARAMSETptr CPXPUBLIC
   CPXparamsetcreate (CPXCENVptr env, int *status_p);


CPXLIBAPI
int CPXPUBLIC
   CPXparamsetdel (CPXCENVptr env, CPXPARAMSETptr ps, int whichparam);


CPXLIBAPI
int CPXPUBLIC
   CPXparamsetfree (CPXCENVptr env, CPXPARAMSETptr *ps_p);


CPXLIBAPI
int CPXPUBLIC
   CPXparamsetgetdbl (CPXCENVptr env, CPXCPARAMSETptr ps,
                      int whichparam, double *dval_p);


CPXLIBAPI
int CPXPUBLIC
   CPXparamsetgetids (CPXCENVptr env, CPXCPARAMSETptr ps, int *cnt_p,
                      int *whichparams, int pspace, int *surplus_p);


CPXLIBAPI
int CPXPUBLIC
   CPXparamsetgetint (CPXCENVptr env, CPXCPARAMSETptr ps,
                      int whichparam, CPXINT *ival_p);


CPXLIBAPI
int CPXPUBLIC
   CPXparamsetgetlong (CPXCENVptr env, CPXCPARAMSETptr ps,
                       int whichparam, CPXLONG *ival_p);


CPXLIBAPI
int CPXPUBLIC
   CPXparamsetgetstr (CPXCENVptr env, CPXCPARAMSETptr ps,
                      int whichparam, char *sval);


CPXLIBAPI
int CPXPUBLIC
   CPXparamsetreadcopy (CPXENVptr env, CPXPARAMSETptr ps,
                        char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXparamsetwrite (CPXCENVptr env, CPXCPARAMSETptr ps,
                     char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXpivot (CPXCENVptr env, CPXLPptr lp, int jenter, int jleave,
             int leavestat);


CPXLIBAPI
int CPXPUBLIC
   CPXpivotin (CPXCENVptr env, CPXLPptr lp, int const *rlist, int rlen);


CPXLIBAPI
int CPXPUBLIC
   CPXpivotout (CPXCENVptr env, CPXLPptr lp, int const *clist,
                int clen);


CPXLIBAPI
int CPXPUBLIC
   CPXpperwrite (CPXCENVptr env, CPXLPptr lp, char const *filename_str,
                 double epsilon);


CPXLIBAPI
int CPXPUBLIC
   CPXpratio (CPXCENVptr env, CPXLPptr lp, int *indices, int cnt,
              double *downratio, double *upratio, int *downleave,
              int *upleave, int *downleavestatus, int *upleavestatus,
              int *downstatus, int *upstatus);


CPXLIBAPI
int CPXPUBLIC
   CPXpreaddrows (CPXCENVptr env, CPXLPptr lp, int rcnt, int nzcnt,
                  double const *rhs, char const *sense,
                  int const *rmatbeg, int const *rmatind,
                  double const *rmatval, char **rowname);


CPXLIBAPI
int CPXPUBLIC
   CPXprechgobj (CPXCENVptr env, CPXLPptr lp, int cnt,
                 int const *indices, double const *values);


CPXLIBAPI
int CPXPUBLIC
   CPXpreslvwrite (CPXCENVptr env, CPXLPptr lp,
                   char const *filename_str, double *objoff_p);


CPXLIBAPI
int CPXPUBLIC
   CPXpresolve (CPXCENVptr env, CPXLPptr lp, int method);


CPXLIBAPI
int CPXPUBLIC
   CPXprimopt (CPXCENVptr env, CPXLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXqpdjfrompi (CPXCENVptr env, CPXCLPptr lp, double const *pi,
                  double const *x, double *dj);


CPXLIBAPI
int CPXPUBLIC
   CPXqpuncrushpi (CPXCENVptr env, CPXCLPptr lp, double *pi,
                   double const *prepi, double const *x);


CPXLIBAPI
int CPXPUBLIC
   CPXreadcopyannotations (CPXCENVptr env, CPXLPptr lp,
                           char const *filename);


CPXLIBAPI
int CPXPUBLIC
   CPXreadcopybase (CPXCENVptr env, CPXLPptr lp,
                    char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXreadcopyparam (CPXENVptr env, char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXreadcopyprob (CPXCENVptr env, CPXLPptr lp,
                    char const *filename_str, char const *filetype);


CPXLIBAPI
int CPXPUBLIC
   CPXreadcopysol (CPXCENVptr env, CPXLPptr lp,
                   char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXrefineconflict (CPXCENVptr env, CPXLPptr lp, int *confnumrows_p,
                      int *confnumcols_p);


CPXLIBAPI
int CPXPUBLIC
   CPXrefineconflictext (CPXCENVptr env, CPXLPptr lp, int grpcnt,
                         int concnt, double const *grppref,
                         int const *grpbeg, int const *grpind,
                         char const *grptype);


CPXLIBAPI
int CPXPUBLIC
   CPXrhssa (CPXCENVptr env, CPXCLPptr lp, int begin, int end,
             double *lower, double *upper);


CPXLIBAPI
int CPXPUBLIC
   CPXrobustopt (CPXCENVptr env, CPXLPptr lp, CPXLPptr lblp,
                 CPXLPptr ublp, double objchg, double const *maxchg);





CPXLIBAPI
int CPXPUBLIC
   CPXserializercreate (CPXSERIALIZERptr *ser_p);


CPXLIBAPI
void CPXPUBLIC
   CPXserializerdestroy (CPXSERIALIZERptr ser);


CPXLIBAPI
CPXLONG CPXPUBLIC
   CPXserializerlength (CPXCSERIALIZERptr ser);


CPXLIBAPI
void const * CPXPUBLIC
   CPXserializerpayload (CPXCSERIALIZERptr ser);


CPXLIBAPI
int CPXPUBLIC
   CPXsetdblannotations (CPXCENVptr env, CPXLPptr lp, int idx,
                         int objtype, int cnt, int const *indices,
                         double const *values);


CPXLIBAPI
int CPXPUBLIC
   CPXsetdblparam (CPXENVptr env, int whichparam, double newvalue);


CPXLIBAPI
int CPXPUBLIC
   CPXsetdefaults (CPXENVptr env);


CPXLIBAPI
int CPXPUBLIC
   CPXsetintparam (CPXENVptr env, int whichparam, CPXINT newvalue);


CPXLIBAPI
int CPXPUBLIC
   CPXsetlogfilename (CPXCENVptr env, char const *filename,
                      char const *mode);


CPXLIBAPI
int CPXPUBLIC
   CPXsetlongannotations (CPXCENVptr env, CPXLPptr lp, int idx,
                          int objtype, int cnt, int const *indices,
                          CPXLONG const *values);


CPXLIBAPI
int CPXPUBLIC
   CPXsetlongparam (CPXENVptr env, int whichparam, CPXLONG newvalue);


CPXLIBAPI
int CPXPUBLIC
   CPXsetlpcallbackfunc (CPXENVptr env,
                         int(CPXPUBLIC *callback)(CPXCENVptr, void *, int, void *),
                         void *cbhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXsetnetcallbackfunc (CPXENVptr env,
                          int(CPXPUBLIC *callback)(CPXCENVptr, void *, int, void *),
                          void *cbhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXsetnumobjs (CPXCENVptr env, CPXCLPptr lp, int n);


CPXLIBAPI
int CPXPUBLIC
   CPXsetphase2 (CPXCENVptr env, CPXLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXsetprofcallbackfunc (CPXENVptr env,
                           int(CPXPUBLIC *callback)(CPXCENVptr, int, void *),
                           void *cbhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXsetstrparam (CPXENVptr env, int whichparam,
                   char const *newvalue_str);


CPXLIBAPI
int CPXPUBLIC
   CPXsetterminate (CPXENVptr env, volatile int *terminate_p);


CPXLIBAPI
int CPXPUBLIC
   CPXsettuningcallbackfunc (CPXENVptr env,
                             int(CPXPUBLIC *callback)(CPXCENVptr, void *, int, void *),
                             void *cbhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXsiftopt (CPXCENVptr env, CPXLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXslackfromx (CPXCENVptr env, CPXCLPptr lp, double const *x,
                  double *slack);


CPXLIBAPI
int CPXPUBLIC
   CPXsolninfo (CPXCENVptr env, CPXCLPptr lp, int *solnmethod_p,
                int *solntype_p, int *pfeasind_p, int *dfeasind_p);


CPXLIBAPI
int CPXPUBLIC
   CPXsolution (CPXCENVptr env, CPXCLPptr lp, int *lpstat_p,
                double *objval_p, double *x, double *pi, double *slack,
                double *dj);


CPXLIBAPI
int CPXPUBLIC
   CPXsolwrite (CPXCENVptr env, CPXCLPptr lp, char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXsolwritesolnpool (CPXCENVptr env, CPXCLPptr lp, int soln,
                        char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXsolwritesolnpoolall (CPXCENVptr env, CPXCLPptr lp,
                           char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXstrongbranch (CPXCENVptr env, CPXLPptr lp, int const *indices,
                    int cnt, double *downobj, double *upobj, int itlim);


CPXLIBAPI
int CPXPUBLIC
   CPXtightenbds (CPXCENVptr env, CPXLPptr lp, int cnt,
                  int const *indices, char const *lu, double const *bd);


CPXLIBAPI
int CPXPUBLIC
   CPXtuneparam (CPXENVptr env, CPXLPptr lp, int intcnt,
                 int const *intnum, int const *intval, int dblcnt,
                 int const *dblnum, double const *dblval, int strcnt,
                 int const *strnum, char **strval, int *tunestat_p);


CPXLIBAPI
int CPXPUBLIC
   CPXtuneparamprobset (CPXENVptr env, int filecnt, char **filename,
                        char **filetype, int intcnt, int const *intnum,
                        int const *intval, int dblcnt,
                        int const *dblnum, double const *dblval,
                        int strcnt, int const *strnum, char **strval,
                        int *tunestat_p);


CPXLIBAPI
int CPXPUBLIC
   CPXuncrushform (CPXCENVptr env, CPXCLPptr lp, int plen,
                   int const *pind, double const *pval, int *len_p,
                   double *offset_p, int *ind, double *val);


CPXLIBAPI
int CPXPUBLIC
   CPXuncrushpi (CPXCENVptr env, CPXCLPptr lp, double *pi,
                 double const *prepi);


CPXLIBAPI
int CPXPUBLIC
   CPXuncrushx (CPXCENVptr env, CPXCLPptr lp, double *x,
                double const *prex);


CPXLIBAPI
int CPXPUBLIC
   CPXunscaleprob (CPXCENVptr env, CPXLPptr lp);


CPXLIBAPI
CPXCCHARptr CPXPUBLIC
   CPXversion (CPXCENVptr env);


CPXLIBAPI
int CPXPUBLIC
   CPXversionnumber (CPXCENVptr env, int *version_p);


CPXLIBAPI
int CPXPUBLIC
   CPXwriteannotations (CPXCENVptr env, CPXCLPptr lp,
                        char const *filename);


CPXLIBAPI
int CPXPUBLIC
   CPXwritebendersannotation (CPXCENVptr env, CPXCLPptr lp,
                              char const *filename);


CPXLIBAPI
int CPXPUBLIC
   CPXwriteparam (CPXCENVptr env, char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXwriteprob (CPXCENVptr env, CPXCLPptr lp,
                 char const *filename_str, char const *filetype);



#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* !CPX_H */

#ifndef CPXBAR_H
#   define CPXBAR_H 1
#include "cpxconst.h"

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

CPXLIBAPI
int CPXPUBLIC
   CPXbaropt (CPXCENVptr env, CPXLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXhybbaropt (CPXCENVptr env, CPXLPptr lp, int method);



#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* !CPXBAR_H */

#ifndef CPXMIP_H
#   define CPXMIP_H 1

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define CPXgetmipobjval(env,lp,objval_p) CPXgetobjval(env, lp, objval_p)

#define CPXgetmipqconstrslack(env,lp,qcslack,begin,end) CPXgetqconstrslack(env, lp, qcslack, begin, end)

#define CPXgetmipslack(env,lp,slack,begin,end) CPXgetslack(env, lp, slack, begin, end)

#define CPXgetmipx(env,lp,x,begin,end) CPXgetx(env, lp, x, begin, end)

CPXLIBAPI
int CPXPUBLIC
   CPXaddindconstraints (CPXCENVptr env, CPXLPptr lp, int indcnt,
                         int const *type, int const *indvar,
                         int const *complemented, int nzcnt,
                         double const *rhs, char const *sense,
                         int const *linbeg, int const *linind,
                         double const *linval, char **indname);


CPXLIBAPI
int CPXPUBLIC
   CPXaddlazyconstraints (CPXCENVptr env, CPXLPptr lp, int rcnt,
                          int nzcnt, double const *rhs,
                          char const *sense, int const *rmatbeg,
                          int const *rmatind, double const *rmatval,
                          char **rowname);


CPXLIBAPI
int CPXPUBLIC
   CPXaddmipstarts (CPXCENVptr env, CPXLPptr lp, int mcnt, int nzcnt,
                    int const *beg, int const *varindices,
                    double const *values, int const *effortlevel,
                    char **mipstartname);


CPXLIBAPI
int CPXPUBLIC
   CPXaddsolnpooldivfilter (CPXCENVptr env, CPXLPptr lp,
                            double lower_bound, double upper_bound,
                            int nzcnt, int const *ind,
                            double const *weight, double const *refval,
                            char const *lname_str);


CPXLIBAPI
int CPXPUBLIC
   CPXaddsolnpoolrngfilter (CPXCENVptr env, CPXLPptr lp, double lb,
                            double ub, int nzcnt, int const *ind,
                            double const *val, char const *lname_str);


CPXLIBAPI
int CPXPUBLIC
   CPXaddsos (CPXCENVptr env, CPXLPptr lp, int numsos, int numsosnz,
              char const *sostype, int const *sosbeg,
              int const *sosind, double const *soswt, char **sosname);


CPXLIBAPI
int CPXPUBLIC
   CPXaddusercuts (CPXCENVptr env, CPXLPptr lp, int rcnt, int nzcnt,
                   double const *rhs, char const *sense,
                   int const *rmatbeg, int const *rmatind,
                   double const *rmatval, char **rowname);


CPXLIBAPI
int CPXPUBLIC
   CPXbendersopt (CPXCENVptr env, CPXLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXbranchcallbackbranchasCPLEX (CPXCENVptr env, void *cbdata,
                                   int wherefrom, int num,
                                   void *userhandle, int *seqnum_p);


CPXLIBAPI
int CPXPUBLIC
   CPXbranchcallbackbranchbds (CPXCENVptr env, void *cbdata,
                               int wherefrom, int cnt,
                               int const *indices, char const *lu,
                               double const *bd, double nodeest,
                               void *userhandle, int *seqnum_p);


CPXLIBAPI
int CPXPUBLIC
   CPXbranchcallbackbranchconstraints (CPXCENVptr env, void *cbdata,
                                       int wherefrom, int rcnt,
                                       int nzcnt, double const *rhs,
                                       char const *sense,
                                       int const *rmatbeg,
                                       int const *rmatind,
                                       double const *rmatval,
                                       double nodeest,
                                       void *userhandle, int *seqnum_p);


CPXLIBAPI
int CPXPUBLIC
   CPXbranchcallbackbranchgeneral (CPXCENVptr env, void *cbdata,
                                   int wherefrom, int varcnt,
                                   int const *varind,
                                   char const *varlu,
                                   double const *varbd, int rcnt,
                                   int nzcnt, double const *rhs,
                                   char const *sense,
                                   int const *rmatbeg,
                                   int const *rmatind,
                                   double const *rmatval,
                                   double nodeest, void *userhandle,
                                   int *seqnum_p);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackgetgloballb (CPXCALLBACKCONTEXTptr context, double *lb,
                           int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackgetglobalub (CPXCALLBACKCONTEXTptr context, double *ub,
                           int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackgetlocallb (CPXCALLBACKCONTEXTptr context, double *lb,
                          int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbackgetlocalub (CPXCALLBACKCONTEXTptr context, double *ub,
                          int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbacksetnodeuserhandle (CPXCENVptr env, void *cbdata,
                                 int wherefrom, int nodeindex,
                                 void *userhandle,
                                 void  **olduserhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXcallbacksetuserhandle (CPXCENVptr env, void *cbdata,
                             int wherefrom, void *userhandle,
                             void  **olduserhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXchgctype (CPXCENVptr env, CPXLPptr lp, int cnt,
                int const *indices, char const *xctype);


CPXLIBAPI
int CPXPUBLIC
   CPXchgmipstarts (CPXCENVptr env, CPXLPptr lp, int mcnt,
                    int const *mipstartindices, int nzcnt,
                    int const *beg, int const *varindices,
                    double const *values, int const *effortlevel);


CPXLIBAPI
int CPXPUBLIC
   CPXcopyctype (CPXCENVptr env, CPXLPptr lp, char const *xctype);


CPXLIBAPI
int CPXPUBLIC
   CPXcopyorder (CPXCENVptr env, CPXLPptr lp, int cnt,
                 int const *indices, int const *priority,
                 int const *direction);


CPXLIBAPI
int CPXPUBLIC
   CPXcopysos (CPXCENVptr env, CPXLPptr lp, int numsos, int numsosnz,
               char const *sostype, int const *sosbeg,
               int const *sosind, double const *soswt, char **sosname);


CPXLIBAPI
int CPXPUBLIC
   CPXcutcallbackadd (CPXCENVptr env, void *cbdata, int wherefrom,
                      int nzcnt, double rhs, int sense,
                      int const *cutind, double const *cutval,
                      int purgeable);


CPXLIBAPI
int CPXPUBLIC
   CPXcutcallbackaddlocal (CPXCENVptr env, void *cbdata, int wherefrom,
                           int nzcnt, double rhs, int sense,
                           int const *cutind, double const *cutval);


CPXLIBAPI
int CPXPUBLIC
   CPXdelindconstrs (CPXCENVptr env, CPXLPptr lp, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXdelmipstarts (CPXCENVptr env, CPXLPptr lp, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXdelsetmipstarts (CPXCENVptr env, CPXLPptr lp, int *delstat);


CPXLIBAPI
int CPXPUBLIC
   CPXdelsetsolnpoolfilters (CPXCENVptr env, CPXLPptr lp, int *delstat);


CPXLIBAPI
int CPXPUBLIC
   CPXdelsetsolnpoolsolns (CPXCENVptr env, CPXLPptr lp, int *delstat);


CPXLIBAPI
int CPXPUBLIC
   CPXdelsetsos (CPXCENVptr env, CPXLPptr lp, int *delset);


CPXLIBAPI
int CPXPUBLIC
   CPXdelsolnpoolfilters (CPXCENVptr env, CPXLPptr lp, int begin,
                          int end);


CPXLIBAPI
int CPXPUBLIC
   CPXdelsolnpoolsolns (CPXCENVptr env, CPXLPptr lp, int begin,
                        int end);


CPXLIBAPI
int CPXPUBLIC
   CPXdelsos (CPXCENVptr env, CPXLPptr lp, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXfltwrite (CPXCENVptr env, CPXCLPptr lp, char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXfreelazyconstraints (CPXCENVptr env, CPXLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXfreeusercuts (CPXCENVptr env, CPXLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetbestobjval (CPXCENVptr env, CPXCLPptr lp, double *objval_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetbranchcallbackfunc (CPXCENVptr env,
                             int(CPXPUBLIC **branchcallback_p)(CALLBACK_BRANCH_ARGS),
                             void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetbranchnosolncallbackfunc (CPXCENVptr env,
                                   int(CPXPUBLIC **branchnosolncallback_p)(CALLBACK_BRANCH_ARGS),
                                   void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbackbranchconstraints (CPXCENVptr env, void *cbdata,
                                    int wherefrom, int which,
                                    int *cuts_p, int *nzcnt_p,
                                    double *rhs, char *sense,
                                    int *rmatbeg, int *rmatind,
                                    double *rmatval, int rmatsz,
                                    int *surplus_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbackctype (CPXCENVptr env, void *cbdata, int wherefrom,
                        char *xctype, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbackgloballb (CPXCENVptr env, void *cbdata, int wherefrom,
                           double *lb, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbackglobalub (CPXCENVptr env, void *cbdata, int wherefrom,
                           double *ub, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbackincumbent (CPXCENVptr env, void *cbdata,
                            int wherefrom, double *x, int begin,
                            int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbackindicatorinfo (CPXCENVptr env, void *cbdata,
                                int wherefrom, int iindex,
                                int whichinfo, void *result_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbacklp (CPXCENVptr env, void *cbdata, int wherefrom,
                     CPXCLPptr *lp_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbacknodeinfo (CPXCENVptr env, void *cbdata, int wherefrom,
                           int nodeindex, int whichinfo,
                           void *result_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbacknodeintfeas (CPXCENVptr env, void *cbdata,
                              int wherefrom, int *feas, int begin,
                              int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbacknodelb (CPXCENVptr env, void *cbdata, int wherefrom,
                         double *lb, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbacknodelp (CPXCENVptr env, void *cbdata, int wherefrom,
                         CPXLPptr *nodelp_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbacknodeobjval (CPXCENVptr env, void *cbdata,
                             int wherefrom, double *objval_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbacknodestat (CPXCENVptr env, void *cbdata, int wherefrom,
                           int *nodestat_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbacknodeub (CPXCENVptr env, void *cbdata, int wherefrom,
                         double *ub, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbacknodex (CPXCENVptr env, void *cbdata, int wherefrom,
                        double *x, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbackorder (CPXCENVptr env, void *cbdata, int wherefrom,
                        int *priority, int *direction, int begin,
                        int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbackpseudocosts (CPXCENVptr env, void *cbdata,
                              int wherefrom, double *uppc,
                              double *downpc, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbackseqinfo (CPXCENVptr env, void *cbdata, int wherefrom,
                          int seqid, int whichinfo, void *result_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcallbacksosinfo (CPXCENVptr env, void *cbdata, int wherefrom,
                          int sosindex, int member, int whichinfo,
                          void *result_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetctype (CPXCENVptr env, CPXCLPptr lp, char *xctype, int begin,
                int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetcutoff (CPXCENVptr env, CPXCLPptr lp, double *cutoff_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetdeletenodecallbackfunc (CPXCENVptr env,
                                 void(CPXPUBLIC **deletecallback_p)(CALLBACK_DELETENODE_ARGS),
                                 void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetheuristiccallbackfunc (CPXCENVptr env,
                                int(CPXPUBLIC **heuristiccallback_p)(CALLBACK_HEURISTIC_ARGS),
                                void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetincumbentcallbackfunc (CPXCENVptr env,
                                int(CPXPUBLIC **incumbentcallback_p)(CALLBACK_INCUMBENT_ARGS),
                                void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetindconstr (CPXCENVptr env, CPXCLPptr lp, int *indvar_p,
                    int *complemented_p, int *nzcnt_p, double *rhs_p,
                    char *sense_p, int *linind, double *linval,
                    int space, int *surplus_p, int which);


CPXLIBAPI
int CPXPUBLIC
   CPXgetindconstraints (CPXCENVptr env, CPXCLPptr lp, int *type,
                         int *indvar, int *complemented, int *nzcnt_p,
                         double *rhs, char *sense, int *linbeg,
                         int *linind, double *linval, int linspace,
                         int *surplus_p, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetindconstrindex (CPXCENVptr env, CPXCLPptr lp,
                         char const *lname_str, int *index_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetindconstrinfeas (CPXCENVptr env, CPXCLPptr lp,
                          double const *x, double *infeasout,
                          int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetindconstrname (CPXCENVptr env, CPXCLPptr lp, char *buf_str,
                        int bufspace, int *surplus_p, int which);


CPXLIBAPI
int CPXPUBLIC
   CPXgetindconstrslack (CPXCENVptr env, CPXCLPptr lp,
                         double *indslack, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetinfocallbackfunc (CPXCENVptr env,
                           int(CPXPUBLIC **callback_p)(CPXCENVptr, void *, int, void *),
                           void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetlazyconstraintcallbackfunc (CPXCENVptr env,
                                     int(CPXPUBLIC **cutcallback_p)(CALLBACK_CUT_ARGS),
                                     void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetmipcallbackfunc (CPXCENVptr env,
                          int(CPXPUBLIC **callback_p)(CPXCENVptr, void *, int, void *),
                          void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetmipitcnt (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetmiprelgap (CPXCENVptr env, CPXCLPptr lp, double *gap_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetmipstartindex (CPXCENVptr env, CPXCLPptr lp,
                        char const *lname_str, int *index_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetmipstartname (CPXCENVptr env, CPXCLPptr lp, char  **name,
                       char *store, int storesz, int *surplus_p,
                       int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetmipstarts (CPXCENVptr env, CPXCLPptr lp, int *nzcnt_p,
                    int *beg, int *varindices, double *values,
                    int *effortlevel, int startspace, int *surplus_p,
                    int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnodecallbackfunc (CPXCENVptr env,
                           int(CPXPUBLIC **nodecallback_p)(CALLBACK_NODE_ARGS),
                           void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnodecnt (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnodeint (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnodeleftcnt (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumbin (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumcuts (CPXCENVptr env, CPXCLPptr lp, int cuttype,
                  int *num_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumindconstrs (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumint (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumlazyconstraints (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnummipstarts (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumsemicont (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumsemiint (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumsos (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumusercuts (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetorder (CPXCENVptr env, CPXCLPptr lp, int *cnt_p, int *indices,
                int *priority, int *direction, int ordspace,
                int *surplus_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpooldivfilter (CPXCENVptr env, CPXCLPptr lp,
                            double *lower_cutoff_p,
                            double *upper_cutoff_p, int *nzcnt_p,
                            int *ind, double *val, double *refval,
                            int space, int *surplus_p, int which);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpoolfilterindex (CPXCENVptr env, CPXCLPptr lp,
                              char const *lname_str, int *index_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpoolfiltername (CPXCENVptr env, CPXCLPptr lp,
                             char *buf_str, int bufspace,
                             int *surplus_p, int which);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpoolfiltertype (CPXCENVptr env, CPXCLPptr lp,
                             int *ftype_p, int which);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpoolmeanobjval (CPXCENVptr env, CPXCLPptr lp,
                             double *meanobjval_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpoolnumfilters (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpoolnumreplaced (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpoolnumsolns (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpoolobjval (CPXCENVptr env, CPXCLPptr lp, int soln,
                         double *objval_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpoolqconstrslack (CPXCENVptr env, CPXCLPptr lp, int soln,
                               double *qcslack, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpoolrngfilter (CPXCENVptr env, CPXCLPptr lp, double *lb_p,
                            double *ub_p, int *nzcnt_p, int *ind,
                            double *val, int space, int *surplus_p,
                            int which);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpoolslack (CPXCENVptr env, CPXCLPptr lp, int soln,
                        double *slack, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpoolsolnindex (CPXCENVptr env, CPXCLPptr lp,
                            char const *lname_str, int *index_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpoolsolnname (CPXCENVptr env, CPXCLPptr lp, char *store,
                           int storesz, int *surplus_p, int which);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolnpoolx (CPXCENVptr env, CPXCLPptr lp, int soln, double *x,
                    int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsolvecallbackfunc (CPXCENVptr env,
                            int(CPXPUBLIC **solvecallback_p)(CALLBACK_SOLVE_ARGS),
                            void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsos (CPXCENVptr env, CPXCLPptr lp, int *numsosnz_p,
              char *sostype, int *sosbeg, int *sosind, double *soswt,
              int sosspace, int *surplus_p, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsosindex (CPXCENVptr env, CPXCLPptr lp, char const *lname_str,
                   int *index_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsosinfeas (CPXCENVptr env, CPXCLPptr lp, double const *x,
                    double *infeasout, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsosname (CPXCENVptr env, CPXCLPptr lp, char  **name,
                  char *namestore, int storespace, int *surplus_p,
                  int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsubmethod (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetsubstat (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetusercutcallbackfunc (CPXCENVptr env,
                              int(CPXPUBLIC **cutcallback_p)(CALLBACK_CUT_ARGS),
                              void  **cbhandle_p);


CPXLIBAPI
int CPXPUBLIC
   CPXindconstrslackfromx (CPXCENVptr env, CPXCLPptr lp,
                           double const *x, double *indslack);


CPXLIBAPI
int CPXPUBLIC
   CPXmipopt (CPXCENVptr env, CPXLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXordread (CPXCENVptr env, char const *filename_str, int numcols,
               char **colname, int *cnt_p, int *indices, int *priority,
               int *direction);


CPXLIBAPI
int CPXPUBLIC
   CPXordwrite (CPXCENVptr env, CPXCLPptr lp, char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXpopulate (CPXCENVptr env, CPXLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXreadcopymipstarts (CPXCENVptr env, CPXLPptr lp,
                         char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXreadcopyorder (CPXCENVptr env, CPXLPptr lp,
                     char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXreadcopysolnpoolfilters (CPXCENVptr env, CPXLPptr lp,
                               char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXrefinemipstartconflict (CPXCENVptr env, CPXLPptr lp,
                              int mipstartindex, int *confnumrows_p,
                              int *confnumcols_p);


CPXLIBAPI
int CPXPUBLIC
   CPXrefinemipstartconflictext (CPXCENVptr env, CPXLPptr lp,
                                 int mipstartindex, int grpcnt,
                                 int concnt, double const *grppref,
                                 int const *grpbeg, int const *grpind,
                                 char const *grptype);


CPXLIBAPI
int CPXPUBLIC
   CPXsetbranchcallbackfunc (CPXENVptr env,
                             int(CPXPUBLIC *branchcallback)(CALLBACK_BRANCH_ARGS),
                             void *cbhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXsetbranchnosolncallbackfunc (CPXENVptr env,
                                   int(CPXPUBLIC *branchnosolncallback)(CALLBACK_BRANCH_ARGS),
                                   void *cbhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXsetdeletenodecallbackfunc (CPXENVptr env,
                                 void(CPXPUBLIC *deletecallback)(CALLBACK_DELETENODE_ARGS),
                                 void *cbhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXsetheuristiccallbackfunc (CPXENVptr env,
                                int(CPXPUBLIC *heuristiccallback)(CALLBACK_HEURISTIC_ARGS),
                                void *cbhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXsetincumbentcallbackfunc (CPXENVptr env,
                                int(CPXPUBLIC *incumbentcallback)(CALLBACK_INCUMBENT_ARGS),
                                void *cbhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXsetinfocallbackfunc (CPXENVptr env,
                           int(CPXPUBLIC *callback)(CPXCENVptr, void *, int, void *),
                           void *cbhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXsetlazyconstraintcallbackfunc (CPXENVptr env,
                                     int(CPXPUBLIC *lazyconcallback)(CALLBACK_CUT_ARGS),
                                     void *cbhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXsetmipcallbackfunc (CPXENVptr env,
                          int(CPXPUBLIC *callback)(CPXCENVptr, void *, int, void *),
                          void *cbhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXsetnodecallbackfunc (CPXENVptr env,
                           int(CPXPUBLIC *nodecallback)(CALLBACK_NODE_ARGS),
                           void *cbhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXsetsolvecallbackfunc (CPXENVptr env,
                            int(CPXPUBLIC *solvecallback)(CALLBACK_SOLVE_ARGS),
                            void *cbhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXsetusercutcallbackfunc (CPXENVptr env,
                              int(CPXPUBLIC *cutcallback)(CALLBACK_CUT_ARGS),
                              void *cbhandle);


CPXLIBAPI
int CPXPUBLIC
   CPXwritemipstarts (CPXCENVptr env, CPXCLPptr lp,
                      char const *filename_str, int begin, int end);



#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* !CPXMIP_H */

#ifndef CPXGC_H
#   define CPXGC_H 1

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

CPXLIBAPI
int CPXPUBLIC
   CPXaddindconstr (CPXCENVptr env, CPXLPptr lp, int indvar,
                    int complemented, int nzcnt, double rhs, int sense,
                    int const *linind, double const *linval,
                    char const *indname_str);



#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* !CPXGC_H */

#ifndef CPXNET_H
#   define CPXNET_H 1

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

CPXLIBAPI
int CPXPUBLIC
   CPXNETaddarcs (CPXCENVptr env, CPXNETptr net, int narcs,
                  int const *fromnode, int const *tonode,
                  double const *low, double const *up,
                  double const *obj, char **anames);


CPXLIBAPI
int CPXPUBLIC
   CPXNETaddnodes (CPXCENVptr env, CPXNETptr net, int nnodes,
                   double const *supply, char **name);


CPXLIBAPI
int CPXPUBLIC
   CPXNETbasewrite (CPXCENVptr env, CPXCNETptr net,
                    char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXNETchgarcname (CPXCENVptr env, CPXNETptr net, int cnt,
                     int const *indices, char **newname);


CPXLIBAPI
int CPXPUBLIC
   CPXNETchgarcnodes (CPXCENVptr env, CPXNETptr net, int cnt,
                      int const *indices, int const *fromnode,
                      int const *tonode);


CPXLIBAPI
int CPXPUBLIC
   CPXNETchgbds (CPXCENVptr env, CPXNETptr net, int cnt,
                 int const *indices, char const *lu, double const *bd);


CPXLIBAPI
int CPXPUBLIC
   CPXNETchgname (CPXCENVptr env, CPXNETptr net, int key, int vindex,
                  char const *name_str);


CPXLIBAPI
int CPXPUBLIC
   CPXNETchgnodename (CPXCENVptr env, CPXNETptr net, int cnt,
                      int const *indices, char **newname);


CPXLIBAPI
int CPXPUBLIC
   CPXNETchgobj (CPXCENVptr env, CPXNETptr net, int cnt,
                 int const *indices, double const *obj);


CPXLIBAPI
int CPXPUBLIC
   CPXNETchgobjsen (CPXCENVptr env, CPXNETptr net, int maxormin);


CPXLIBAPI
int CPXPUBLIC
   CPXNETchgsupply (CPXCENVptr env, CPXNETptr net, int cnt,
                    int const *indices, double const *supply);


CPXLIBAPI
int CPXPUBLIC
   CPXNETcopybase (CPXCENVptr env, CPXNETptr net, int const *astat,
                   int const *nstat);


CPXLIBAPI
int CPXPUBLIC
   CPXNETcopynet (CPXCENVptr env, CPXNETptr net, int objsen,
                  int nnodes, double const *supply, char **nnames,
                  int narcs, int const *fromnode, int const *tonode,
                  double const *low, double const *up,
                  double const *obj, char **anames);


CPXLIBAPI
CPXNETptr CPXPUBLIC
   CPXNETcreateprob (CPXENVptr env, int *status_p,
                     char const *name_str);


CPXLIBAPI
int CPXPUBLIC
   CPXNETdelarcs (CPXCENVptr env, CPXNETptr net, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXNETdelnodes (CPXCENVptr env, CPXNETptr net, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXNETdelset (CPXCENVptr env, CPXNETptr net, int *whichnodes,
                 int *whicharcs);


CPXLIBAPI
int CPXPUBLIC
   CPXNETfreeprob (CPXENVptr env, CPXNETptr *net_p);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetarcindex (CPXCENVptr env, CPXCNETptr net,
                      char const *lname_str, int *index_p);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetarcname (CPXCENVptr env, CPXCNETptr net, char  **nnames,
                     char *namestore, int namespc, int *surplus_p,
                     int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetarcnodes (CPXCENVptr env, CPXCNETptr net, int *fromnode,
                      int *tonode, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetbase (CPXCENVptr env, CPXCNETptr net, int *astat,
                  int *nstat);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetdj (CPXCENVptr env, CPXCNETptr net, double *dj, int begin,
                int end);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetitcnt (CPXCENVptr env, CPXCNETptr net);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetlb (CPXCENVptr env, CPXCNETptr net, double *low, int begin,
                int end);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetnodearcs (CPXCENVptr env, CPXCNETptr net, int *arccnt_p,
                      int *arcbeg, int *arc, int arcspace,
                      int *surplus_p, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetnodeindex (CPXCENVptr env, CPXCNETptr net,
                       char const *lname_str, int *index_p);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetnodename (CPXCENVptr env, CPXCNETptr net, char  **nnames,
                      char *namestore, int namespc, int *surplus_p,
                      int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetnumarcs (CPXCENVptr env, CPXCNETptr net);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetnumnodes (CPXCENVptr env, CPXCNETptr net);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetobj (CPXCENVptr env, CPXCNETptr net, double *obj,
                 int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetobjsen (CPXCENVptr env, CPXCNETptr net);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetobjval (CPXCENVptr env, CPXCNETptr net, double *objval_p);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetphase1cnt (CPXCENVptr env, CPXCNETptr net);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetpi (CPXCENVptr env, CPXCNETptr net, double *pi, int begin,
                int end);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetprobname (CPXCENVptr env, CPXCNETptr net, char *buf_str,
                      int bufspace, int *surplus_p);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetslack (CPXCENVptr env, CPXCNETptr net, double *slack,
                   int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetstat (CPXCENVptr env, CPXCNETptr net);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetsupply (CPXCENVptr env, CPXCNETptr net, double *supply,
                    int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetub (CPXCENVptr env, CPXCNETptr net, double *up, int begin,
                int end);


CPXLIBAPI
int CPXPUBLIC
   CPXNETgetx (CPXCENVptr env, CPXCNETptr net, double *x, int begin,
               int end);


CPXLIBAPI
int CPXPUBLIC
   CPXNETprimopt (CPXCENVptr env, CPXNETptr net);


CPXLIBAPI
int CPXPUBLIC
   CPXNETreadcopybase (CPXCENVptr env, CPXNETptr net,
                       char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXNETreadcopyprob (CPXCENVptr env, CPXNETptr net,
                       char const *filename_str);


CPXLIBAPI
int CPXPUBLIC
   CPXNETsolninfo (CPXCENVptr env, CPXCNETptr net, int *pfeasind_p,
                   int *dfeasind_p);


CPXLIBAPI
int CPXPUBLIC
   CPXNETsolution (CPXCENVptr env, CPXCNETptr net, int *netstat_p,
                   double *objval_p, double *x, double *pi,
                   double *slack, double *dj);


CPXLIBAPI
int CPXPUBLIC
   CPXNETwriteprob (CPXCENVptr env, CPXCNETptr net,
                    char const *filename_str, char const *format_str);



#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* !CPXNET_H */

#ifndef CPXQP_H
#   define CPXQP_H 1

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

CPXLIBAPI
int CPXPUBLIC
   CPXchgqpcoef (CPXCENVptr env, CPXLPptr lp, int i, int j,
                 double newvalue);


CPXLIBAPI
int CPXPUBLIC
   CPXcopyqpsep (CPXCENVptr env, CPXLPptr lp, double const *qsepvec);


CPXLIBAPI
int CPXPUBLIC
   CPXcopyquad (CPXCENVptr env, CPXLPptr lp, int const *qmatbeg,
                int const *qmatcnt, int const *qmatind,
                double const *qmatval);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumqpnz (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumquad (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetqpcoef (CPXCENVptr env, CPXCLPptr lp, int rownum, int colnum,
                 double *coef_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetquad (CPXCENVptr env, CPXCLPptr lp, int *nzcnt_p,
               int *qmatbeg, int *qmatind, double *qmatval,
               int qmatspace, int *surplus_p, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXqpindefcertificate (CPXCENVptr env, CPXCLPptr lp, double *x);


CPXLIBAPI
int CPXPUBLIC
   CPXqpopt (CPXCENVptr env, CPXLPptr lp);



#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* !CPXQP_H */

#ifndef CPXSOCP_H
#   define CPXSOCP_H 1

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

CPXLIBAPI
int CPXPUBLIC
   CPXaddqconstr (CPXCENVptr env, CPXLPptr lp, int linnzcnt,
                  int quadnzcnt, double rhs, int sense,
                  int const *linind, double const *linval,
                  int const *quadrow, int const *quadcol,
                  double const *quadval, char const *lname_str);


CPXLIBAPI
int CPXPUBLIC
   CPXdelqconstrs (CPXCENVptr env, CPXLPptr lp, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetnumqconstrs (CPXCENVptr env, CPXCLPptr lp);


CPXLIBAPI
int CPXPUBLIC
   CPXgetqconstr (CPXCENVptr env, CPXCLPptr lp, int *linnzcnt_p,
                  int *quadnzcnt_p, double *rhs_p, char *sense_p,
                  int *linind, double *linval, int linspace,
                  int *linsurplus_p, int *quadrow, int *quadcol,
                  double *quadval, int quadspace, int *quadsurplus_p,
                  int which);


CPXLIBAPI
int CPXPUBLIC
   CPXgetqconstrdslack (CPXCENVptr env, CPXCLPptr lp, int qind,
                        int *nz_p, int *ind, double *val, int space,
                        int *surplus_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetqconstrindex (CPXCENVptr env, CPXCLPptr lp,
                       char const *lname_str, int *index_p);


CPXLIBAPI
int CPXPUBLIC
   CPXgetqconstrinfeas (CPXCENVptr env, CPXCLPptr lp, double const *x,
                        double *infeasout, int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetqconstrname (CPXCENVptr env, CPXCLPptr lp, char *buf_str,
                      int bufspace, int *surplus_p, int which);


CPXLIBAPI
int CPXPUBLIC
   CPXgetqconstrslack (CPXCENVptr env, CPXCLPptr lp, double *qcslack,
                       int begin, int end);


CPXLIBAPI
int CPXPUBLIC
   CPXgetxqxax (CPXCENVptr env, CPXCLPptr lp, double *xqxax, int begin,
                int end);


CPXLIBAPI
int CPXPUBLIC
   CPXqconstrslackfromx (CPXCENVptr env, CPXCLPptr lp, double const *x,
                         double *qcslack);



#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* !CPXSOCP_H */
