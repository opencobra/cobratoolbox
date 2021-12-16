/* --------------------------------------------------------------------------
 * File: cpxconst.h
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

#ifndef CPX_FEATURES_H
#define CPX_FEATURES_H 1

/* For NAN */
#include <math.h>

/* There is no NAN with Solaris Studio unless __C99FEATURES__ is defined.
   The C compiler does define that, but the C++ compiler does not. Here we
   make sure that NAN is defined. */
#if defined(__sun) && ! defined(NAN)
#   define NAN __builtin_nan
#endif

#if defined(__sun) && ! defined(INFINITY)
#   define INFINITY __builtin_infinity
#endif

#if !defined(CPX_FEATURE_REMOTE_OBJECT)
#   if defined(__MVS__)
#      define CPX_FEATURE_REMOTE_OBJECT 0
#   else
#      define CPX_FEATURE_REMOTE_OBJECT 1
#   endif
#endif

#if !defined(CPX_FEATURE_DISTRIBUTED_MIP)
#   if defined(__MVS__)
#      define CPX_FEATURE_DISTRIBUTED_MIP 0
#   else
#      define CPX_FEATURE_DISTRIBUTED_MIP 1
#   endif
#endif

#endif /* !CPX_FEATURES_H */

#ifndef CPX_CPXAUTOINTTYPES_H_H
#   define CPX_CPXAUTOINTTYPES_H_H 1

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifndef CPXBYTE_DEFINED
#   define CPXBYTE_DEFINED 1
    typedef signed char CPXBYTE;
#endif
    

#ifndef CPXINT_DEFINED
#   define CPXINT_DEFINED 1
    typedef int CPXINT;
#endif
    

#ifndef CPXLONG_DEFINED
#   define CPXLONG_DEFINED 1
#   ifdef _MSC_VER
       typedef __int64 CPXLONG;
#   else
       typedef long long CPXLONG;
#   endif
#endif
    

#ifndef CPXSHORT_DEFINED
#   define CPXSHORT_DEFINED 1
    typedef short CPXSHORT;
#endif
    

#if !defined(CPXSIZE_BITS) && defined(_MSC_VER)
#   if defined(_WIN64)
#      define CPXSIZE_BITS 64
#   else
#      define CPXSIZE_BITS 32
#   endif
#endif

#if !defined(CPXSIZE_BITS) && ( defined(__GNUC__) || defined(__HP_aCC) || defined(__HP_cc) || defined(__SUNPRO_CC) )
    /* This covers gcc, icc, hpcc, acc, and Sun C++ compiler */
#   if defined(_LP64)
#      define CPXSIZE_BITS 64
#   else
#      define CPXSIZE_BITS 32
#   endif
#endif

#if !defined(CPXSIZE_BITS) && defined(__SUNPRO_C)
    /* Sun C compiler */
#   include <stdint.h>
#   if (SIZE_MAX < (1ULL << 32))
#      define CPXSIZE_BITS 32
#   else
#      define CPXSIZE_BITS 64
#   endif
#endif

#if !defined(CPXSIZE_BITS) && ( defined(__xlc__) || defined(__xlC__) || defined(__IBMC__) || defined(__IBMCPP__) )
    /* __64BIT__ works on all platforms (ppc/x86-64, AIX/LINUX, z/OS) */
#   if defined(__64BIT__)
#      define CPXSIZE_BITS 64
#   else
#      define CPXSIZE_BITS 32
#   endif
#endif

#if !defined(CPXSIZE_BITS)
#   error "Could not define CPXSIZE_BITS"
#endif

#ifndef CPXSIZE_DEFINED
#   define CPXSIZE_DEFINED
#   if CPXSIZE_BITS == 32
typedef CPXINT CPXSIZE;
#   elif CPXSIZE_BITS == 64
typedef CPXLONG CPXSIZE;
#   else
#      error "Unsupported value for CPXSIZE_BITS"
#   endif
#endif
    

#ifndef CPXULONG_DEFINED
#   define CPXULONG_DEFINED 1
#   ifdef _MSC_VER
       typedef unsigned __int64 CPXULONG;
#   else
       typedef unsigned long long CPXULONG;
#   endif
#endif
    

#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* !CPX_CPXAUTOINTTYPES_H_H */

#ifndef CPX_INTWIDTH_H
#define CPX_INTWIDTH_H

#include <stdlib.h>
#include <limits.h>


#define CPXINT_MAX          INT_MAX
#define CPXINT_MIN          INT_MIN

/* Make sure that CPXINT and CPXLONG are as wide as expected. The test
 * below is a compile time test.
 */

typedef int CPXBYTE_TEST[sizeof(CPXBYTE) == 1 ? 1 : -1];
typedef int CPXSHORT_TEST[sizeof(CPXSHORT) == 2 ? 1 : -1];
typedef int CPXINT_TEST[sizeof(CPXINT) == 4 ? 1 : -1];
typedef int CPXLONG_TEST[sizeof(CPXLONG) == 8 ? 1 : -1];
typedef int CPXULONG_TEST[sizeof(CPXULONG) == 8 ? 1 : -1];

/* Make sure that CPXSIZE is exactly as wide as size_t. The test
 * below is a compile time test.
 */


#endif /* !CPX_INTWIDTH_H */

#ifndef CPX_PUBCONST_H
#define CPX_PUBCONST_H

/* <stdio.h> is included here so that the 'FILE' type is defined */
#include <stdio.h>


#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef _WIN32
#define CPXPUBLIC      __stdcall
#define CPXPUBVARARGS  __cdecl
#define CPXCDECL       __cdecl
#else
#define CPXPUBLIC
#define CPXPUBVARARGS
#define CPXCDECL
#endif

/* Functions exported from the callable library are tagged with CPXLIBAPI.
 * Functions exported from the callable library that are deprecated are
 * tagged with CPXDEPRECATEDAPI.
 * Macros CPXDEPRECATED and CPXDEPRECATEDAPI have a single argument: The
 * CPLEX version at which the function was deprecated. This version number
 * has the same format as CPX_VERSION.
 */
#ifdef BUILD_CPXLIB
#   if defined(_WIN32) || defined(__HP_cc)
#      define CPXLIBAPI __declspec(dllexport)
#      define CPXDEPRECATEDAPI(version) __declspec(dllexport deprecated)
#      define CPXDEPRECATED(version) __declspec(deprecated)
#   elif defined(__GNUC__) && defined(__linux__)
#      define CPXLIBAPI __attribute__ ((visibility("default")))
#      define CPXDEPRECATEDAPI(version) __attribute__ ((visibility("default"), deprecated))
#      define CPXDEPRECATED(version) __attribute__ ((deprecated))
#   elif defined(__SUNPRO_C)
#      define CPXLIBAPI __global
#      define CPXDEPRECATEDAPI(version) __global
#      define CPXDEPRECATED(version)
#   else
#      define CPXLIBAPI
#      define CPXDEPRECATEDAPI(version)
#      define CPXDEPRECATED(version)
#   endif
#else
#   if defined(_WIN32) && !defined(BUILD_CPXSTATIC)
#      define CPXLIBAPI __declspec(dllimport)
#      define CPXDEPRECATEDAPI(version) __declspec(dllimport deprecated)
#      define CPXDEPRECATED(version) __declspec(deprecated)
#   elif defined(_WIN32)
#      define CPXLIBAPI
#      define CPXDEPRECATEDAPI(version) __declspec(deprecated)
#      define CPXDEPRECATED(version) __declspec(deprecated)
#   elif defined(__GNUC__) && defined(__linux__)
#      define CPXLIBAPI
#      define CPXDEPRECATEDAPI(version) __attribute__ ((deprecated))
#      define CPXDEPRECATED(version) __attribute__ ((deprecated))
#   else
#      define CPXLIBAPI
#      define CPXDEPRECATEDAPI(version)
#      define CPXDEPRECATED(version)
#   endif
#endif

/* Macro CPXEXPORT marks functions that should be exported from DLLs
 * or binaries for runtime linking.
 */
#ifndef CPXEXPORT
#   if defined(_WIN32) || defined(__HP_cc)
#      define CPXEXPORT __declspec(dllexport)
#   elif defined(__GNUC__) && defined(__linux__)
#      define CPXEXPORT __attribute__ ((visibility("default")))
#   elif defined(__SUNPRO_C)
#      define CPXEXPORT __global
#   else
#      define CPXEXPORT
#   endif
#endif

/* structure types */
struct cpxenv;
typedef struct cpxenv *CPXENVptr;
typedef struct cpxenv const *CPXCENVptr;

struct cpxchannel;
typedef struct cpxchannel  *CPXCHANNELptr;

struct paramset;
typedef struct paramset *CPXPARAMSETptr;
typedef struct paramset const *CPXCPARAMSETptr;

struct cpxlp;
typedef struct cpxlp        *CPXLPptr;
#ifndef CPXCLPptr
typedef const struct cpxlp  *CPXCLPptr;
#endif

struct cpxnet;
typedef struct cpxnet       *CPXNETptr;
#ifndef CPXCNETptr
typedef const struct cpxnet *CPXCNETptr;
#endif

typedef char       *CPXCHARptr;  /* to simplify CPXPUBLIC syntax */
typedef const char *CPXCCHARptr; /* to simplify CPXPUBLIC syntax */
typedef void       *CPXVOIDptr;  /* to simplify CPXPUBLIC syntax */


#define CPX_STR_PARAM_MAX    512

#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif


#endif /* CPX_PUBCONST_H */


#ifndef __PUBTYPE_H
#define __PUBTYPE_H

#ifdef _WIN32
#pragma pack(push, 8)
#endif


#ifdef __cplusplus
extern "C" {
#endif

/* CPX_STATIC_INLINE defines a function to be static and inlined.
 * This way it should not cause any runtime overhead and should not
 * trigger a warning when it is defined but not used.
 */
#ifndef CPX_STATIC_INLINE
#   ifdef _MSC_VER
#      define CPX_STATIC_INLINE static __inline
#   elif defined(__HP_cc) && __HP_cc < 62500
       /* old versions of HP's cc does not recognize 'static inline' */
#      define CPX_STATIC_INLINE __inline
#   elif defined(__MVS__)
#      define CPX_STATIC_INLINE static __inline__
#   else
#      define CPX_STATIC_INLINE static inline
#   endif
#endif

/* Argument lists for callbacks */
#define CALLBACK_BRANCH_ARGS  CPXCENVptr xenv, void *cbdata,\
   int wherefrom, void *cbhandle, int brtype, int brset,\
   int nodecnt, int bdcnt, const int *nodebeg,\
   const int *xindex, const char *lu, const double *bd, \
   const double *nodeest, \
   int *useraction_p
#define CALLBACK_NODE_ARGS  CPXCENVptr xenv, void *cbdata,\
   int wherefrom, void *cbhandle, int *nodeindex, int *useraction
#define CALLBACK_HEURISTIC_ARGS  CPXCENVptr xenv, void *cbdata,\
   int wherefrom, void *cbhandle, double *objval_p, double *x,\
   int *checkfeas_p, int *useraction_p
#define CALLBACK_SOLVE_ARGS  CPXCENVptr xenv, void *cbdata,\
   int wherefrom, void *cbhandle, int *useraction
#define CALLBACK_CUT_ARGS  CPXCENVptr xenv, void *cbdata,\
   int wherefrom, void *cbhandle, int *useraction_p
#define CALLBACK_INCUMBENT_ARGS  CPXCENVptr xenv, void *cbdata,\
   int wherefrom, void *cbhandle, double objval, double *x,\
   int *isfeas_p, int *useraction_p
#define CALLBACK_DELETENODE_ARGS  CPXCENVptr xenv,\
   int wherefrom, void *cbhandle, int seqnum, void *handle

struct cpxiodevice {
   int (CPXPUBLIC *cpxiodev_eof)(struct cpxiodevice *dev);
   int (CPXPUBLIC *cpxiodev_error)(struct cpxiodevice *dev);
   int (CPXPUBLIC *cpxiodev_rewind)(struct cpxiodevice *dev);
   int (CPXPUBLIC *cpxiodev_flush)(struct cpxiodevice *dev);
   int (CPXPUBLIC *cpxiodev_close)(struct cpxiodevice *dev);
   int (CPXPUBLIC *cpxiodev_putc)(int c, struct cpxiodevice *dev);
   int (CPXPUBLIC *cpxiodev_puts)(const char *s, struct cpxiodevice *dev);
   size_t (CPXPUBLIC *cpxiodev_read)(void *ptr, size_t size, struct cpxiodevice *dev);
   size_t (CPXPUBLIC *cpxiodev_write)(const void *ptr, size_t size, struct cpxiodevice *dev);
};
typedef struct cpxiodevice CPXIODEVICE, *CPXIODEVICEptr;

#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif


#endif /* __PUBTYPE_H */


#ifndef CPX_CPLEXCONSTANTS_H
#define CPX_CPLEXCONSTANTS_H


#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* The version is an integer, to allow testing in user include
 * files.
 * The template for CPX_VERSION is VVRRMMFF:
 *  VV = version
 *  RR = release
 *  MM = modification
 *  FF = fix
 */

#define CPX_VERSION               12090000
#define CPX_VERSION_VERSION       12
#define CPX_VERSION_RELEASE       9
#define CPX_VERSION_MODIFICATION  0
#define CPX_VERSION_FIX           0

/* CPX_INFBOUND:  Any bound bigger than this is treated as
   infinity */

#define CPX_INFBOUND  1.0E+20

/* CPX_MINBOUND: Any bound smaller than or equal to this
 * can be a potential source of ill-conditioning or
 * numerical instability in a model.
 */

#define CPX_MINBOUND  1.0E-13

/* Types of parameters */
 
#define CPX_PARAMTYPE_NONE   0
#define CPX_PARAMTYPE_INT    1
#define CPX_PARAMTYPE_DOUBLE 2 
#define CPX_PARAMTYPE_STRING 3
#define CPX_PARAMTYPE_LONG   4


/* Solution type return values from CPXsolninfo,
 * or possible values for CPX_PARAM_SOLUTIONTYPE
 */
#define CPX_NO_SOLN        0    /* CPXXsolninfo() */
#define CPX_AUTO_SOLN      0    /* CPX_PARAM_SOLUTIONTYPE */
#define CPX_BASIC_SOLN     1    /* CPX_PARAM_SOLUTIONTYPE & CPXXsolninfo() */
#define CPX_NONBASIC_SOLN  2    /* CPX_PARAM_SOLUTIONTYPE & CPXXsolninfo() */
#define CPX_PRIMAL_SOLN    3    /* CPX_PARAM_SOLUTIONTYPE & CPXXsolninfo() */


/* Values of presolve 'stats' for columns and rows */
#define CPX_PRECOL_LOW     -1  /* fixed to original lb */
#define CPX_PRECOL_UP      -2  /* fixed to original ub */
#define CPX_PRECOL_FIX     -3  /* fixed to some other value */
#define CPX_PRECOL_AGG     -4  /* aggregated y = a*x + b */
#define CPX_PRECOL_OTHER   -5  /* cannot be expressed by a linear combination
                                * of active variables in the presolved model
                                *  -> crushing will fail if it has to touch
                                *     such a variable
                                */
#define CPX_PREROW_RED     -1  /* redundant row removed in presolved model */
#define CPX_PREROW_AGG     -2  /* used to aggregate a variable */
#define CPX_PREROW_OTHER   -3  /* other, for example merge two inequalities
                                * into a single equation */


/* Private errors are 2000-2999 (cpxpriv.h)
   MIP errors are 3000-3999 (mipdefs.h)
   Barrier errors are 4000-4999 (bardefs.h)
   QP errors are 5000-5999 (qpdefs.h) */

/* Licensor errors */



/* Generic constants */

#define CPX_AUTO                        -1
#define CPX_ON                           1
#define CPX_OFF                          0
#define CPX_MAX                         -1
#define CPX_MIN                          1

/* Data checking options */

#define CPX_DATACHECK_OFF                0 /* no data check at all */
#define CPX_DATACHECK_WARN               1 /* check data on input  */
#define CPX_DATACHECK_ASSIST             2 /* modeling assistance  */

/* Pricing options */

#define CPX_PPRIIND_PARTIAL             -1
#define CPX_PPRIIND_AUTO                 0
#define CPX_PPRIIND_DEVEX                1
#define CPX_PPRIIND_STEEP                2
#define CPX_PPRIIND_STEEPQSTART          3
#define CPX_PPRIIND_FULL                 4

#define CPX_DPRIIND_AUTO                 0
#define CPX_DPRIIND_FULL                 1
#define CPX_DPRIIND_STEEP                2
#define CPX_DPRIIND_FULLSTEEP            3
#define CPX_DPRIIND_STEEPQSTART          4
#define CPX_DPRIIND_DEVEX                5

/* PARALLELMODE values  */

#define CPX_PARALLEL_DETERMINISTIC      1
#define CPX_PARALLEL_AUTO               0
#define CPX_PARALLEL_OPPORTUNISTIC     -1

/* Values for CPX_PARAM_WRITELEVEL */

#define CPX_WRITELEVEL_AUTO                 0
#define CPX_WRITELEVEL_ALLVARS              1
#define CPX_WRITELEVEL_DISCRETEVARS         2
#define CPX_WRITELEVEL_NONZEROVARS          3
#define CPX_WRITELEVEL_NONZERODISCRETEVARS  4

/* Values for CPX_PARAM_OPTIMALITYTARGET */

#define CPX_OPTIMALITYTARGET_AUTO          0
#define CPX_OPTIMALITYTARGET_OPTIMALCONVEX 1
#define CPX_OPTIMALITYTARGET_FIRSTORDER    2
#define CPX_OPTIMALITYTARGET_OPTIMALGLOBAL 3

/* LP/QP solution algorithms, used as possible values for
   CPX_PARAM_LPMETHOD/CPX_PARAM_QPMETHOD/CPX_PARAM_BARCROSSALG/
   CPXgetmethod/... */

#define CPX_ALG_NONE                     -1
#define CPX_ALG_AUTOMATIC                 0
#define CPX_ALG_PRIMAL                    1
#define CPX_ALG_DUAL                      2
#define CPX_ALG_NET                       3
#define CPX_ALG_BARRIER                   4
#define CPX_ALG_SIFTING                   5
#define CPX_ALG_CONCURRENT                6
#define CPX_ALG_BAROPT                    7
#define CPX_ALG_PIVOTIN                   8
#define CPX_ALG_PIVOTOUT                  9
#define CPX_ALG_PIVOT                    10
#define CPX_ALG_FEASOPT                  11
#define CPX_ALG_MIP                      12
#define CPX_ALG_BENDERS                  13
#define CPX_ALG_MULTIOBJ                 14
#define CPX_ALG_ROBUST                   15

/* Basis status values */

#define CPX_AT_LOWER                     0
#define CPX_BASIC                        1
#define CPX_AT_UPPER                     2
#define CPX_FREE_SUPER                   3

/* Used in pivoting interface */

#ifndef CPX_NO_VARIABLE
#define CPX_NO_VARIABLE         2100000000
#endif

/* Variable types for ctype array */

#define CPX_CONTINUOUS                   'C'
#define CPX_BINARY                       'B'
#define CPX_INTEGER                      'I'
#define CPX_SEMICONT                     'S'
#define CPX_SEMIINT                      'N'

/* PREREDUCE settings */

#define CPX_PREREDUCE_PRIMALANDDUAL       3
#define CPX_PREREDUCE_DUALONLY            2
#define CPX_PREREDUCE_PRIMALONLY          1
#define CPX_PREREDUCE_NOPRIMALORDUAL      0

/* Conflict status values */

#define CPX_CONFLICT_EXCLUDED          -1
#define CPX_CONFLICT_POSSIBLE_MEMBER    0
#define CPX_CONFLICT_POSSIBLE_LB        1
#define CPX_CONFLICT_POSSIBLE_UB        2
#define CPX_CONFLICT_MEMBER             3
#define CPX_CONFLICT_LB                 4
#define CPX_CONFLICT_UB                 5

/* conflict algorithm parameters */

#define CPX_CONFLICTALG_AUTO       0
#define CPX_CONFLICTALG_FAST       1
#define CPX_CONFLICTALG_PROPAGATE  2
#define CPX_CONFLICTALG_PRESOLVE   3
#define CPX_CONFLICTALG_IIS        4
#define CPX_CONFLICTALG_LIMITSOLVE 5
#define CPX_CONFLICTALG_SOLVE      6

/* Problem Types
   Types 4, 9, and 12 are internal, the others are for users */

#define CPXPROB_LP                       0
#define CPXPROB_MILP                     1
#define CPXPROB_FIXEDMILP                3
#define CPXPROB_NODELP                   4
#define CPXPROB_QP                       5
#define CPXPROB_MIQP                     7
#define CPXPROB_FIXEDMIQP                8
#define CPXPROB_NODEQP                   9
#define CPXPROB_QCP                     10
#define CPXPROB_MIQCP                   11
#define CPXPROB_NODEQCP                 12

/* LP file format reader types */

#define CPX_LPREADER_LEGACY 0
#define CPX_LPREADER_NEW    1

/* CPLEX Parameter range */

#define CPX_PARAM_ALL_MIN              1000
#define CPX_PARAM_ALL_MAX              6000

/* Callback values for wherefrom   */

#define CPX_CALLBACK_PRIMAL               1
#define CPX_CALLBACK_DUAL                 2
#define CPX_CALLBACK_NETWORK              3
#define CPX_CALLBACK_PRIMAL_CROSSOVER     4
#define CPX_CALLBACK_DUAL_CROSSOVER       5
#define CPX_CALLBACK_BARRIER              6
#define CPX_CALLBACK_PRESOLVE             7
#define CPX_CALLBACK_QPBARRIER            8
#define CPX_CALLBACK_QPSIMPLEX            9
#define CPX_CALLBACK_TUNING              10
/* Be sure to check the MIP values */

/* Values for getcallbackinfo function */

#define CPX_CALLBACK_INFO_PRIMAL_OBJ            1
#define CPX_CALLBACK_INFO_DUAL_OBJ              2
#define CPX_CALLBACK_INFO_PRIMAL_INFMEAS        3
#define CPX_CALLBACK_INFO_DUAL_INFMEAS          4
#define CPX_CALLBACK_INFO_PRIMAL_FEAS           5
#define CPX_CALLBACK_INFO_DUAL_FEAS             6
#define CPX_CALLBACK_INFO_ITCOUNT               7
#define CPX_CALLBACK_INFO_CROSSOVER_PPUSH       8
#define CPX_CALLBACK_INFO_CROSSOVER_PEXCH       9
#define CPX_CALLBACK_INFO_CROSSOVER_DPUSH      10
#define CPX_CALLBACK_INFO_CROSSOVER_DEXCH      11
#define CPX_CALLBACK_INFO_CROSSOVER_SBCNT      12
#define CPX_CALLBACK_INFO_PRESOLVE_ROWSGONE    13
#define CPX_CALLBACK_INFO_PRESOLVE_COLSGONE    14
#define CPX_CALLBACK_INFO_PRESOLVE_AGGSUBST    15
#define CPX_CALLBACK_INFO_PRESOLVE_COEFFS      16
#define CPX_CALLBACK_INFO_USER_PROBLEM         17
#define CPX_CALLBACK_INFO_TUNING_PROGRESS      18
#define CPX_CALLBACK_INFO_ENDTIME              19
/* Be sure to check the MIP values */

#define CPX_CALLBACK_INFO_ITCOUNT_LONG           20
#define CPX_CALLBACK_INFO_CROSSOVER_PPUSH_LONG   21
#define CPX_CALLBACK_INFO_CROSSOVER_PEXCH_LONG   22
#define CPX_CALLBACK_INFO_CROSSOVER_DPUSH_LONG   23
#define CPX_CALLBACK_INFO_CROSSOVER_DEXCH_LONG   24
#define CPX_CALLBACK_INFO_PRESOLVE_AGGSUBST_LONG 25
#define CPX_CALLBACK_INFO_PRESOLVE_COEFFS_LONG   26
#define CPX_CALLBACK_INFO_ENDDETTIME             27
#define CPX_CALLBACK_INFO_STARTTIME              28
#define CPX_CALLBACK_INFO_STARTDETTIME           29


/* Values for CPX_PARAM_TUNINGMEASURE */
#define CPX_TUNE_AVERAGE  1
#define CPX_TUNE_MINMAX   2


/* Values for incomplete tuning */
#define CPX_TUNE_ABORT     1
#define CPX_TUNE_TILIM     2
#define CPX_TUNE_DETTILIM  3

/* feasopt options */

#define CPX_FEASOPT_MIN_SUM  0
#define CPX_FEASOPT_OPT_SUM  1
#define CPX_FEASOPT_MIN_INF  2
#define CPX_FEASOPT_OPT_INF  3
#define CPX_FEASOPT_MIN_QUAD 4
#define CPX_FEASOPT_OPT_QUAD 5

typedef const char *CPXPUBLIC CPXNAMEFUNCTION(void *, CPXLONG, char *);

/* Values for defining benders strategy */

#define CPX_BENDERSSTRATEGY_OFF      -1
#define CPX_BENDERSSTRATEGY_AUTO      0
#define CPX_BENDERSSTRATEGY_USER      1
#define CPX_BENDERSSTRATEGY_WORKERS   2
#define CPX_BENDERSSTRATEGY_FULL      3

/* Values for defining annotations */

/* type specifiers for the data associated to modeling primitives via an
 * annotation.
 */
#define CPX_ANNOTATIONDATA_LONG     1
#define CPX_ANNOTATIONDATA_DOUBLE   2

/* Type identifiers for primititve modeling object types */

#define CPX_ANNOTATIONOBJ_OBJ      0
#define CPX_ANNOTATIONOBJ_COL      1
#define CPX_ANNOTATIONOBJ_ROW      2
#define CPX_ANNOTATIONOBJ_SOS      3
#define CPX_ANNOTATIONOBJ_IND      4
#define CPX_ANNOTATIONOBJ_QC       5
#define CPX_ANNOTATIONOBJ_LAST     6

/* Deprecated */

/* IIS errors */


/* Infeasibility Finder return values */

#define CPXIIS_COMPLETE                  1
#define CPXIIS_PARTIAL                   2

/* Infeasibility Finder row and column statuses */

#define CPXIIS_AT_LOWER                   0
#define CPXIIS_FIXED                      1
#define CPXIIS_AT_UPPER                   2

#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* CPX_CPLEXCONSTANTS_H */


#ifndef CPX_BARCONST_H
#define CPX_BARCONST_H

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* Optimizing Problems */

#define CPX_BARORDER_AUTO 0
#define CPX_BARORDER_AMD  1
#define CPX_BARORDER_AMF  2
#define CPX_BARORDER_ND   3

#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif  /* CPX_BARCONST_H */



#ifndef CPX_MIPCONST_H
#define CPX_MIPCONST_H

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif


/* MIP emphasis settings */

#define CPX_MIPEMPHASIS_BALANCED     0
#define CPX_MIPEMPHASIS_FEASIBILITY  1
#define CPX_MIPEMPHASIS_OPTIMALITY   2
#define CPX_MIPEMPHASIS_BESTBOUND    3
#define CPX_MIPEMPHASIS_HIDDENFEAS   4

/* Values for sostype and branch type */

#define CPX_TYPE_VAR                    '0'
#define CPX_TYPE_SOS1                   '1'
#define CPX_TYPE_SOS2                   '2'
#define CPX_TYPE_USER                   'X'
#define CPX_TYPE_ANY                    'A'

/* Variable selection values */

#define CPX_VARSEL_MININFEAS            -1
#define CPX_VARSEL_DEFAULT               0
#define CPX_VARSEL_MAXINFEAS             1
#define CPX_VARSEL_PSEUDO                2
#define CPX_VARSEL_STRONG                3
#define CPX_VARSEL_PSEUDOREDUCED         4

/* Node selection values */

#define CPX_NODESEL_DFS                  0
#define CPX_NODESEL_BESTBOUND            1
#define CPX_NODESEL_BESTEST              2
#define CPX_NODESEL_BESTEST_ALT          3

/* Values for generated priority order */

#define CPX_MIPORDER_COST                1 
#define CPX_MIPORDER_BOUNDS              2 
#define CPX_MIPORDER_SCALEDCOST          3

/* Values for direction array */

#define CPX_BRANCH_GLOBAL                0
#define CPX_BRANCH_DOWN                 -1
#define CPX_BRANCH_UP                    1

/* Values for CPX_PARAM_BRDIR */

#define CPX_BRDIR_DOWN                  -1
#define CPX_BRDIR_AUTO                   0
#define CPX_BRDIR_UP                     1
 
/* Values for cuttype in CPXgetnumcuts */

#define CPX_CUT_COVER          0
#define CPX_CUT_GUBCOVER       1
#define CPX_CUT_FLOWCOVER      2
#define CPX_CUT_CLIQUE         3
#define CPX_CUT_FRAC           4
#define CPX_CUT_MIR            5
#define CPX_CUT_FLOWPATH       6
#define CPX_CUT_DISJ           7
#define CPX_CUT_IMPLBD         8
#define CPX_CUT_ZEROHALF       9
#define CPX_CUT_MCF           10
#define CPX_CUT_LOCALCOVER    11
#define CPX_CUT_TIGHTEN       12
#define CPX_CUT_OBJDISJ       13
#define CPX_CUT_LANDP         14
#define CPX_CUT_USER          15
#define CPX_CUT_TABLE         16
#define CPX_CUT_SOLNPOOL      17
#define CPX_CUT_LOCALIMPLBD   18
#define CPX_CUT_BQP           19
#define CPX_CUT_RLT           20
#define CPX_CUT_BENDERS       21
#define CPX_CUT_NUM_TYPES     22


/* Values for CPX_PARAM_MIPSEARCH */

#define CPX_MIPSEARCH_AUTO               0
#define CPX_MIPSEARCH_TRADITIONAL        1
#define CPX_MIPSEARCH_DYNAMIC            2
 
/* Values for CPX_PARAM_MIPKAPPASTATS */

#define CPX_MIPKAPPA_OFF    -1
#define CPX_MIPKAPPA_AUTO    0
#define CPX_MIPKAPPA_SAMPLE  1
#define CPX_MIPKAPPA_FULL    2

/* Effort levels for MIP starts */

#define CPX_MIPSTART_AUTO         0
#define CPX_MIPSTART_CHECKFEAS    1
#define CPX_MIPSTART_SOLVEFIXED   2
#define CPX_MIPSTART_SOLVEMIP     3
#define CPX_MIPSTART_REPAIR       4
#define CPX_MIPSTART_NOCHECK      5

/* Callback values for wherefrom */

#define CPX_CALLBACK_MIP                      101
#define CPX_CALLBACK_MIP_BRANCH               102
#define CPX_CALLBACK_MIP_NODE                 103
#define CPX_CALLBACK_MIP_HEURISTIC            104
#define CPX_CALLBACK_MIP_SOLVE                105
#define CPX_CALLBACK_MIP_CUT_LOOP             106
#define CPX_CALLBACK_MIP_PROBE                107
#define CPX_CALLBACK_MIP_FRACCUT              108
#define CPX_CALLBACK_MIP_DISJCUT              109
#define CPX_CALLBACK_MIP_FLOWMIR              110
#define CPX_CALLBACK_MIP_INCUMBENT_NODESOLN   111
#define CPX_CALLBACK_MIP_DELETENODE           112
#define CPX_CALLBACK_MIP_BRANCH_NOSOLN        113
#define CPX_CALLBACK_MIP_CUT_LAST             114
#define CPX_CALLBACK_MIP_CUT_FEAS             115
#define CPX_CALLBACK_MIP_CUT_UNBD             116
#define CPX_CALLBACK_MIP_INCUMBENT_HEURSOLN   117
#define CPX_CALLBACK_MIP_INCUMBENT_USERSOLN   118
#define CPX_CALLBACK_MIP_INCUMBENT_MIPSTART   119

/* Be sure to check the LP values */

/* Values for getcallbackinfo function */

#define CPX_CALLBACK_INFO_BEST_INTEGER        101
#define CPX_CALLBACK_INFO_BEST_REMAINING      102
#define CPX_CALLBACK_INFO_NODE_COUNT          103
#define CPX_CALLBACK_INFO_NODES_LEFT          104
#define CPX_CALLBACK_INFO_MIP_ITERATIONS      105
#define CPX_CALLBACK_INFO_CUTOFF              106
#define CPX_CALLBACK_INFO_CLIQUE_COUNT        107
#define CPX_CALLBACK_INFO_COVER_COUNT         108
#define CPX_CALLBACK_INFO_MIP_FEAS            109
#define CPX_CALLBACK_INFO_FLOWCOVER_COUNT     110
#define CPX_CALLBACK_INFO_GUBCOVER_COUNT      111
#define CPX_CALLBACK_INFO_IMPLBD_COUNT        112
#define CPX_CALLBACK_INFO_PROBE_PHASE         113
#define CPX_CALLBACK_INFO_PROBE_PROGRESS      114
#define CPX_CALLBACK_INFO_FRACCUT_COUNT       115
#define CPX_CALLBACK_INFO_FRACCUT_PROGRESS    116
#define CPX_CALLBACK_INFO_DISJCUT_COUNT       117
#define CPX_CALLBACK_INFO_DISJCUT_PROGRESS    118
#define CPX_CALLBACK_INFO_FLOWPATH_COUNT      119
#define CPX_CALLBACK_INFO_MIRCUT_COUNT        120
#define CPX_CALLBACK_INFO_FLOWMIR_PROGRESS    121
#define CPX_CALLBACK_INFO_ZEROHALFCUT_COUNT   122
#define CPX_CALLBACK_INFO_MY_THREAD_NUM       123
#define CPX_CALLBACK_INFO_USER_THREADS        124
#define CPX_CALLBACK_INFO_MIP_REL_GAP         125
#define CPX_CALLBACK_INFO_MCFCUT_COUNT        126
#define CPX_CALLBACK_INFO_KAPPA_STABLE        127
#define CPX_CALLBACK_INFO_KAPPA_SUSPICIOUS    128
#define CPX_CALLBACK_INFO_KAPPA_UNSTABLE      129
#define CPX_CALLBACK_INFO_KAPPA_ILLPOSED      130
#define CPX_CALLBACK_INFO_KAPPA_MAX           131
#define CPX_CALLBACK_INFO_KAPPA_ATTENTION     132
#define CPX_CALLBACK_INFO_LANDPCUT_COUNT      133
#define CPX_CALLBACK_INFO_USERCUT_COUNT       134
#define CPX_CALLBACK_INFO_TABLECUT_COUNT      135
#define CPX_CALLBACK_INFO_SOLNPOOLCUT_COUNT   136
#define CPX_CALLBACK_INFO_BENDERS_COUNT       137

#define CPX_CALLBACK_INFO_NODE_COUNT_LONG       140
#define CPX_CALLBACK_INFO_NODES_LEFT_LONG       141
#define CPX_CALLBACK_INFO_MIP_ITERATIONS_LONG   142

#define CPX_CALLBACK_INFO_LAZY_SOURCE         143

/* Values for getcallbacknodeinfo function */

#define CPX_CALLBACK_INFO_NODE_SIINF          201
#define CPX_CALLBACK_INFO_NODE_NIINF          202
#define CPX_CALLBACK_INFO_NODE_ESTIMATE       203
#define CPX_CALLBACK_INFO_NODE_DEPTH          204
#define CPX_CALLBACK_INFO_NODE_OBJVAL         205
#define CPX_CALLBACK_INFO_NODE_TYPE           206
#define CPX_CALLBACK_INFO_NODE_VAR            207
#define CPX_CALLBACK_INFO_NODE_SOS            208
#define CPX_CALLBACK_INFO_NODE_SEQNUM         209
#define CPX_CALLBACK_INFO_NODE_USERHANDLE     210
#define CPX_CALLBACK_INFO_NODE_NODENUM        211

#define CPX_CALLBACK_INFO_NODE_SEQNUM_LONG      220
#define CPX_CALLBACK_INFO_NODE_NODENUM_LONG     221
#define CPX_CALLBACK_INFO_NODE_DEPTH_LONG       222

/* Values for getcallbacksosinfo function */

#define CPX_CALLBACK_INFO_SOS_TYPE            240
#define CPX_CALLBACK_INFO_SOS_SIZE            241
#define CPX_CALLBACK_INFO_SOS_IS_FEASIBLE     242
#define CPX_CALLBACK_INFO_SOS_MEMBER_INDEX    244
#define CPX_CALLBACK_INFO_SOS_MEMBER_REFVAL   246
#define CPX_CALLBACK_INFO_SOS_NUM             247

/* Values for getcallbackindicatorinfo function */

#define CPX_CALLBACK_INFO_IC_NUM              260
#define CPX_CALLBACK_INFO_IC_IMPLYING_VAR     261
#define CPX_CALLBACK_INFO_IC_IMPLIED_VAR      262
#define CPX_CALLBACK_INFO_IC_SENSE            263
#define CPX_CALLBACK_INFO_IC_COMPL            264
#define CPX_CALLBACK_INFO_IC_RHS              265
#define CPX_CALLBACK_INFO_IC_IS_FEASIBLE      266

/* Value for accessing the incumbent using the solution pool routines */

#define CPX_INCUMBENT_ID  -1

   /* Values for rampup duration */

#define CPX_RAMPUP_DISABLED             -1
#define CPX_RAMPUP_AUTO                  0
#define CPX_RAMPUP_DYNAMIC               1
#define CPX_RAMPUP_INFINITE              2

/* Be sure to check the LP values */

/* Callback return codes */

#define CPX_CALLBACK_DEFAULT             0
#define CPX_CALLBACK_FAIL                1
#define CPX_CALLBACK_SET                 2
#define CPX_CALLBACK_ABORT_CUT_LOOP      3

/* Valid purgeable values for adding usercuts and lazyconstraints */
#define CPX_USECUT_FORCE                 0
#define CPX_USECUT_PURGE                 1
#define CPX_USECUT_FILTER                2

/* For CPXgetnodeintfeas */
#define CPX_INTEGER_FEASIBLE             0
#define CPX_INTEGER_INFEASIBLE           1
#define CPX_IMPLIED_INTEGER_FEASIBLE     2

#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* CPX_MIPCONST_H */



#ifndef CPX_GCCONST_H
#define CPX_GCCONST_H

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* Constraint types */

#define CPX_CON_LOWER_BOUND          1
#define CPX_CON_UPPER_BOUND          2
#define CPX_CON_LINEAR               3
#define CPX_CON_QUADRATIC            4
#define CPX_CON_SOS                  5
#define CPX_CON_INDICATOR            6
#define CPX_CON_PWL                  7

/* internal types */
#define CPX_CON_ABS                  7  /*  same as PWL since using it */
#define CPX_CON_MINEXPR              8
#define CPX_CON_MAXEXPR              9
#define CPX_CON_LAST_CONTYPE        10

/* Indicator types. */
#define CPX_INDICATOR_IF                1
#define CPX_INDICATOR_ONLYIF            2
#define CPX_INDICATOR_IFANDONLYIF       3

#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* CPX_GCCONST_H */



#ifndef CPX_NETCONST_H
#define CPX_NETCONST_H

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* NET/MIN files format errors */

/* NETOPT display values */

#define CPXNET_NO_DISPLAY_OBJECTIVE     0
#define CPXNET_TRUE_OBJECTIVE           1
#define CPXNET_PENALIZED_OBJECTIVE      2

/* NETOPT pricing parameters */

#define CPXNET_PRICE_AUTO               0
#define CPXNET_PRICE_PARTIAL            1
#define CPXNET_PRICE_MULT_PART          2
#define CPXNET_PRICE_SORT_MULT_PART     3

/* NETOPT level of network extraction */

#define CPX_NETFIND_PURE                1
#define CPX_NETFIND_REFLECT             2
#define CPX_NETFIND_SCALE               3

#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* CPX_NETCONST_H */




#ifndef CPX_QPCONST_H
#define CPX_QPCONST_H

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif


/* QCPDUAL options */

#define CPX_QCPDUALS_NO                   0
#define CPX_QCPDUALS_IFPOSSIBLE           1
#define CPX_QCPDUALS_FORCE                2


#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* CPX_QPCONST_H */



#ifndef CPX_SOCPCONST_H
#define CPX_SOCPCONST_H

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* CPX_SOCPCONST_H */



#ifndef CPX_CPXAUTOCONSTANTS_H_H
#   define CPX_CPXAUTOCONSTANTS_H_H 1

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define CPX_BENDERS_ANNOTATION "cpxBendersPartition"

#define CPX_BENDERS_MASTERVALUE 0

#define CPX_BIGINT 2100000000

#define CPX_BIGLONG 9223372036800000000LL

#define CPX_CALLBACKCONTEXT_CANDIDATE 0x0020

#define CPX_CALLBACKCONTEXT_GLOBAL_PROGRESS 0x0010

#define CPX_CALLBACKCONTEXT_LOCAL_PROGRESS 0x0008

#define CPX_CALLBACKCONTEXT_RELAXATION 0x0040

#define CPX_CALLBACKCONTEXT_THREAD_DOWN 0x0004

#define CPX_CALLBACKCONTEXT_THREAD_UP 0x0002

#define CPX_DUAL_OBJ 41

#define CPX_EXACT_KAPPA 51

#define CPX_KAPPA 39

#define CPX_KAPPA_ATTENTION 57

#define CPX_KAPPA_ILLPOSED 55

#define CPX_KAPPA_MAX 56

#define CPX_KAPPA_STABLE 52

#define CPX_KAPPA_SUSPICIOUS 53

#define CPX_KAPPA_UNSTABLE 54

#define CPX_LAZYCONSTRAINTCALLBACK_HEUR CPX_CALLBACK_MIP_INCUMBENT_HEURSOLN

#define CPX_LAZYCONSTRAINTCALLBACK_MIPSTART CPX_CALLBACK_MIP_INCUMBENT_MIPSTART

#define CPX_LAZYCONSTRAINTCALLBACK_NODE CPX_CALLBACK_MIP_INCUMBENT_NODESOLN

#define CPX_MAX_COMP_SLACK 19

#define CPX_MAX_DUAL_INFEAS 5

#define CPX_MAX_DUAL_RESIDUAL 15

#define CPX_MAX_INDSLACK_INFEAS 49

#define CPX_MAX_INT_INFEAS 9

#define CPX_MAX_PI 25

#define CPX_MAX_PRIMAL_INFEAS 1

#define CPX_MAX_PRIMAL_RESIDUAL 11

#define CPX_MAX_PWLSLACK_INFEAS 58

#define CPX_MAX_QCPRIMAL_RESIDUAL 43

#define CPX_MAX_QCSLACK 47

#define CPX_MAX_QCSLACK_INFEAS 45

#define CPX_MAX_RED_COST 29

#define CPX_MAX_SCALED_DUAL_INFEAS 6

#define CPX_MAX_SCALED_DUAL_RESIDUAL 16

#define CPX_MAX_SCALED_PI 26

#define CPX_MAX_SCALED_PRIMAL_INFEAS 2

#define CPX_MAX_SCALED_PRIMAL_RESIDUAL 12

#define CPX_MAX_SCALED_RED_COST 30

#define CPX_MAX_SCALED_SLACK 28

#define CPX_MAX_SCALED_X 24

#define CPX_MAX_SLACK 27

#define CPX_MAX_X 23

#define CPX_MULTIOBJ_BARITCNT 4

#define CPX_MULTIOBJ_BESTOBJVAL 15

#define CPX_MULTIOBJ_BLEND 20

#define CPX_MULTIOBJ_DEGCNT 7

#define CPX_MULTIOBJ_DETTIME 3

#define CPX_MULTIOBJ_DEXCH 13

#define CPX_MULTIOBJ_DPUSH 12

#define CPX_MULTIOBJ_ERROR 0

#define CPX_MULTIOBJ_ITCNT 8

#define CPX_MULTIOBJ_METHOD 18

#define CPX_MULTIOBJ_NODECNT 16

#define CPX_MULTIOBJ_NODELEFTCNT 19

#define CPX_MULTIOBJ_OBJVAL 14

#define CPX_MULTIOBJ_PEXCH 11

#define CPX_MULTIOBJ_PHASE1CNT 9

#define CPX_MULTIOBJ_PPUSH 10

#define CPX_MULTIOBJ_PRIORITY 17

#define CPX_MULTIOBJ_SIFTITCNT 5

#define CPX_MULTIOBJ_SIFTPHASE1CNT 6

#define CPX_MULTIOBJ_STATUS 1

#define CPX_MULTIOBJ_TIME 2

#define CPX_NO_ABSTOL_CHANGE NAN

#define CPX_NO_OFFSET_CHANGE NAN

#define CPX_NO_PRIORITY_CHANGE -1

#define CPX_NO_RELTOL_CHANGE NAN

#define CPX_NO_WEIGHT_CHANGE NAN

#define CPX_OBJ_GAP 40

#define CPX_PRIMAL_OBJ 42

#define CPX_SOLNPOOL_DIV 2

#define CPX_SOLNPOOL_FIFO 0

#define CPX_SOLNPOOL_FILTER_DIVERSITY 1

#define CPX_SOLNPOOL_FILTER_RANGE 2

#define CPX_SOLNPOOL_OBJ 1

#define CPX_STAT_ABORT_DETTIME_LIM 25

#define CPX_STAT_ABORT_DUAL_OBJ_LIM 22

#define CPX_STAT_ABORT_IT_LIM 10

#define CPX_STAT_ABORT_OBJ_LIM 12

#define CPX_STAT_ABORT_PRIM_OBJ_LIM 21

#define CPX_STAT_ABORT_TIME_LIM 11

#define CPX_STAT_ABORT_USER 13

#define CPX_STAT_BENDERS_MASTER_UNBOUNDED 40

#define CPX_STAT_BENDERS_NUM_BEST 41

#define CPX_STAT_CONFLICT_ABORT_CONTRADICTION 32

#define CPX_STAT_CONFLICT_ABORT_DETTIME_LIM 39

#define CPX_STAT_CONFLICT_ABORT_IT_LIM 34

#define CPX_STAT_CONFLICT_ABORT_MEM_LIM 37

#define CPX_STAT_CONFLICT_ABORT_NODE_LIM 35

#define CPX_STAT_CONFLICT_ABORT_OBJ_LIM 36

#define CPX_STAT_CONFLICT_ABORT_TIME_LIM 33

#define CPX_STAT_CONFLICT_ABORT_USER 38

#define CPX_STAT_CONFLICT_FEASIBLE 30

#define CPX_STAT_CONFLICT_MINIMAL 31

#define CPX_STAT_FEASIBLE 23

#define CPX_STAT_FEASIBLE_RELAXED_INF 16

#define CPX_STAT_FEASIBLE_RELAXED_QUAD 18

#define CPX_STAT_FEASIBLE_RELAXED_SUM 14

#define CPX_STAT_FIRSTORDER 24

#define CPX_STAT_INFEASIBLE 3

#define CPX_STAT_INForUNBD 4

#define CPX_STAT_MULTIOBJ_INFEASIBLE 302

#define CPX_STAT_MULTIOBJ_INForUNBD 303

#define CPX_STAT_MULTIOBJ_NON_OPTIMAL 305

#define CPX_STAT_MULTIOBJ_OPTIMAL 301

#define CPX_STAT_MULTIOBJ_STOPPED 306

#define CPX_STAT_MULTIOBJ_UNBOUNDED 304

#define CPX_STAT_NUM_BEST 6

#define CPX_STAT_OPTIMAL 1

#define CPX_STAT_OPTIMAL_FACE_UNBOUNDED 20

#define CPX_STAT_OPTIMAL_INFEAS 5

#define CPX_STAT_OPTIMAL_RELAXED_INF 17

#define CPX_STAT_OPTIMAL_RELAXED_QUAD 19

#define CPX_STAT_OPTIMAL_RELAXED_SUM 15

#define CPX_STAT_UNBOUNDED 2

#define CPX_SUM_COMP_SLACK 21

#define CPX_SUM_DUAL_INFEAS 7

#define CPX_SUM_DUAL_RESIDUAL 17

#define CPX_SUM_INDSLACK_INFEAS 50

#define CPX_SUM_INT_INFEAS 10

#define CPX_SUM_PI 33

#define CPX_SUM_PRIMAL_INFEAS 3

#define CPX_SUM_PRIMAL_RESIDUAL 13

#define CPX_SUM_PWLSLACK_INFEAS 59

#define CPX_SUM_QCPRIMAL_RESIDUAL 44

#define CPX_SUM_QCSLACK 48

#define CPX_SUM_QCSLACK_INFEAS 46

#define CPX_SUM_RED_COST 37

#define CPX_SUM_SCALED_DUAL_INFEAS 8

#define CPX_SUM_SCALED_DUAL_RESIDUAL 18

#define CPX_SUM_SCALED_PI 34

#define CPX_SUM_SCALED_PRIMAL_INFEAS 4

#define CPX_SUM_SCALED_PRIMAL_RESIDUAL 14

#define CPX_SUM_SCALED_RED_COST 38

#define CPX_SUM_SCALED_SLACK 36

#define CPX_SUM_SCALED_X 32

#define CPX_SUM_SLACK 35

#define CPX_SUM_X 31

#define CPXERR_ABORT_STRONGBRANCH 1263

#define CPXERR_ADJ_SIGN_QUAD 1606

#define CPXERR_ADJ_SIGN_SENSE 1604

#define CPXERR_ADJ_SIGNS 1602

#define CPXERR_ARC_INDEX_RANGE 1231

#define CPXERR_ARRAY_BAD_SOS_TYPE 3009

#define CPXERR_ARRAY_NOT_ASCENDING 1226

#define CPXERR_ARRAY_TOO_LONG 1208

#define CPXERR_BAD_ARGUMENT 1003

#define CPXERR_BAD_BOUND_SENSE 1622

#define CPXERR_BAD_BOUND_TYPE 1457

#define CPXERR_BAD_CHAR 1537

#define CPXERR_BAD_CTYPE 3021

#define CPXERR_BAD_DECOMPOSITION 2002

#define CPXERR_BAD_DIRECTION 3012

#define CPXERR_BAD_EXPO_RANGE 1435

#define CPXERR_BAD_EXPONENT 1618

#define CPXERR_BAD_FILETYPE 1424

#define CPXERR_BAD_ID 1617

#define CPXERR_BAD_INDCONSTR 1439

#define CPXERR_BAD_INDICATOR 1551

#define CPXERR_BAD_INDTYPE 1216

#define CPXERR_BAD_LAZY_UCUT 1438

#define CPXERR_BAD_LUB 1229

#define CPXERR_BAD_METHOD 1292

#define CPXERR_BAD_MULTIOBJ_ATTR 1488

#define CPXERR_BAD_NUMBER 1434

#define CPXERR_BAD_OBJ_SENSE 1487

#define CPXERR_BAD_PARAM_NAME 1028

#define CPXERR_BAD_PARAM_NUM 1013

#define CPXERR_BAD_PIVOT 1267

#define CPXERR_BAD_PRIORITY 3006

#define CPXERR_BAD_PROB_TYPE 1022

#define CPXERR_BAD_ROW_ID 1532

#define CPXERR_BAD_SECTION_BOUNDS 1473

#define CPXERR_BAD_SECTION_ENDATA 1462

#define CPXERR_BAD_SECTION_QMATRIX 1475

#define CPXERR_BAD_SENSE 1215

#define CPXERR_BAD_SOS_TYPE 1442

#define CPXERR_BAD_STATUS 1253

#define CPXERR_BAS_FILE_SHORT 1550

#define CPXERR_BAS_FILE_SIZE 1555

#define CPXERR_BENDERS_MASTER_SOLVE 2001

#define CPXERR_CALLBACK 1006

#define CPXERR_CALLBACK_INCONSISTENT 1060

#define CPXERR_CAND_NOT_POINT 3025

#define CPXERR_CAND_NOT_RAY 3026

#define CPXERR_CNTRL_IN_NAME 1236

#define CPXERR_COL_INDEX_RANGE 1201

#define CPXERR_COL_REPEAT_PRINT 1478

#define CPXERR_COL_REPEATS 1446

#define CPXERR_COL_ROW_REPEATS 1443

#define CPXERR_COL_UNKNOWN 1449

#define CPXERR_CONFLICT_UNSTABLE 1720

#define CPXERR_COUNT_OVERLAP 1228

#define CPXERR_COUNT_RANGE 1227

#define CPXERR_CPUBINDING_FAILURE 3700

#define CPXERR_DBL_MAX 1233

#define CPXERR_DECOMPRESSION 1027

#define CPXERR_DETTILIM_STRONGBRANCH 1270

#define CPXERR_DUP_ENTRY 1222

#define CPXERR_DYNFUNC 1815

#define CPXERR_DYNLOAD 1814

#define CPXERR_ENCODING_CONVERSION 1235

#define CPXERR_EXTRA_BV_BOUND 1456

#define CPXERR_EXTRA_FR_BOUND 1455

#define CPXERR_EXTRA_FX_BOUND 1454

#define CPXERR_EXTRA_INTEND 1481

#define CPXERR_EXTRA_INTORG 1480

#define CPXERR_EXTRA_SOSEND 1483

#define CPXERR_EXTRA_SOSORG 1482

#define CPXERR_FAIL_OPEN_READ 1423

#define CPXERR_FAIL_OPEN_WRITE 1422

#define CPXERR_FILE_ENTRIES 1553

#define CPXERR_FILE_FORMAT 1563

#define CPXERR_FILE_IO 1426

#define CPXERR_FILTER_VARIABLE_TYPE 3414

#define CPXERR_ILL_DEFINED_PWL 1213

#define CPXERR_IN_INFOCALLBACK 1804

#define CPXERR_INDEX_NOT_BASIC 1251

#define CPXERR_INDEX_RANGE 1200

#define CPXERR_INDEX_RANGE_HIGH 1206

#define CPXERR_INDEX_RANGE_LOW 1205

#define CPXERR_INT_TOO_BIG 3018

#define CPXERR_INT_TOO_BIG_INPUT 1463

#define CPXERR_INVALID_NUMBER 1650

#define CPXERR_LIMITS_TOO_BIG 1012

#define CPXERR_LINE_TOO_LONG 1465

#define CPXERR_LO_BOUND_REPEATS 1459

#define CPXERR_LOCK_CREATE 1808

#define CPXERR_LP_NOT_IN_ENVIRONMENT 1806

#define CPXERR_LP_PARSE 1427

#define CPXERR_MASTER_SOLVE 2005

#define CPXERR_MIPSEARCH_WITH_CALLBACKS 1805

#define CPXERR_MISS_SOS_TYPE 3301

#define CPXERR_MSG_NO_CHANNEL 1051

#define CPXERR_MSG_NO_FILEPTR 1052

#define CPXERR_MSG_NO_FUNCTION 1053

#define CPXERR_MULTIOBJ_SUBPROB_SOLVE 1300

#define CPXERR_MULTIPLE_PROBS_IN_REMOTE_ENVIRONMENT 1816

#define CPXERR_NAME_CREATION 1209

#define CPXERR_NAME_NOT_FOUND 1210

#define CPXERR_NAME_TOO_LONG 1464

#define CPXERR_NAN 1225

#define CPXERR_NEED_OPT_SOLN 1252

#define CPXERR_NEGATIVE_SURPLUS 1207

#define CPXERR_NET_DATA 1530

#define CPXERR_NET_FILE_SHORT 1538

#define CPXERR_NO_BARRIER_SOLN 1223

#define CPXERR_NO_BASIC_SOLN 1261

#define CPXERR_NO_BASIS 1262

#define CPXERR_NO_BOUND_SENSE 1621

#define CPXERR_NO_BOUND_TYPE 1460

#define CPXERR_NO_COLUMNS_SECTION 1472

#define CPXERR_NO_CONFLICT 1719

#define CPXERR_NO_DECOMPOSITION 2000

#define CPXERR_NO_DUAL_SOLN 1232

#define CPXERR_NO_ENDATA 1552

#define CPXERR_NO_ENVIRONMENT 1002

#define CPXERR_NO_FILENAME 1421

#define CPXERR_NO_ID 1616

#define CPXERR_NO_ID_FIRST 1609

#define CPXERR_NO_INT_X 3023

#define CPXERR_NO_KAPPASTATS 1269

#define CPXERR_NO_LU_FACTOR 1258

#define CPXERR_NO_MEMORY 1001

#define CPXERR_NO_MIPSTART 3020

#define CPXERR_NO_NAME_SECTION 1441

#define CPXERR_NO_NAMES 1219

#define CPXERR_NO_NORMS 1264

#define CPXERR_NO_NUMBER 1615

#define CPXERR_NO_NUMBER_BOUND 1623

#define CPXERR_NO_NUMBER_FIRST 1611

#define CPXERR_NO_OBJ_NAME 1489

#define CPXERR_NO_OBJ_SENSE 1436

#define CPXERR_NO_OBJECTIVE 1476

#define CPXERR_NO_OP_OR_SENSE 1608

#define CPXERR_NO_OPERATOR 1607

#define CPXERR_NO_ORDER 3016

#define CPXERR_NO_PROBLEM 1009

#define CPXERR_NO_QP_OPERATOR 1614

#define CPXERR_NO_QUAD_EXP 1612

#define CPXERR_NO_RHS_COEFF 1610

#define CPXERR_NO_RHS_IN_OBJ 1211

#define CPXERR_NO_ROW_NAME 1486

#define CPXERR_NO_ROW_SENSE 1453

#define CPXERR_NO_ROWS_SECTION 1471

#define CPXERR_NO_SENSIT 1260

#define CPXERR_NO_SOLN 1217

#define CPXERR_NO_SOLNPOOL 3024

#define CPXERR_NO_SOS 3015

#define CPXERR_NO_TREE 3412

#define CPXERR_NO_VECTOR_SOLN 1556

#define CPXERR_NODE_INDEX_RANGE 1230

#define CPXERR_NODE_ON_DISK 3504

#define CPXERR_NOT_DUAL_UNBOUNDED 1265

#define CPXERR_NOT_FIXED 1221

#define CPXERR_NOT_FOR_BENDERS 2004

#define CPXERR_NOT_FOR_MIP 1017

#define CPXERR_NOT_FOR_MULTIOBJ 1070

#define CPXERR_NOT_FOR_QCP 1031

#define CPXERR_NOT_FOR_QP 1018

#define CPXERR_NOT_MILPCLASS 1024

#define CPXERR_NOT_MIN_COST_FLOW 1531

#define CPXERR_NOT_MIP 3003

#define CPXERR_NOT_MIQPCLASS 1029

#define CPXERR_NOT_ONE_PROBLEM 1023

#define CPXERR_NOT_QP 5004

#define CPXERR_NOT_SAV_FILE 1560

#define CPXERR_NOT_UNBOUNDED 1254

#define CPXERR_NULL_POINTER 1004

#define CPXERR_ORDER_BAD_DIRECTION 3007

#define CPXERR_OVERFLOW 1810

#define CPXERR_PARAM_INCOMPATIBLE 1807

#define CPXERR_PARAM_TOO_BIG 1015

#define CPXERR_PARAM_TOO_SMALL 1014

#define CPXERR_PRESLV_ABORT 1106

#define CPXERR_PRESLV_BAD_PARAM 1122

#define CPXERR_PRESLV_BASIS_MEM 1107

#define CPXERR_PRESLV_COPYORDER 1109

#define CPXERR_PRESLV_COPYSOS 1108

#define CPXERR_PRESLV_CRUSHFORM 1121

#define CPXERR_PRESLV_DETTIME_LIM 1124

#define CPXERR_PRESLV_DUAL 1119

#define CPXERR_PRESLV_FAIL_BASIS 1114

#define CPXERR_PRESLV_INF 1117

#define CPXERR_PRESLV_INForUNBD 1101

#define CPXERR_PRESLV_NO_BASIS 1115

#define CPXERR_PRESLV_NO_PROB 1103

#define CPXERR_PRESLV_SOLN_MIP 1110

#define CPXERR_PRESLV_SOLN_QP 1111

#define CPXERR_PRESLV_START_LP 1112

#define CPXERR_PRESLV_TIME_LIM 1123

#define CPXERR_PRESLV_UNBD 1118

#define CPXERR_PRESLV_UNCRUSHFORM 1120

#define CPXERR_PRIIND 1257

#define CPXERR_PRM_DATA 1660

#define CPXERR_PRM_HEADER 1661

#define CPXERR_PROTOCOL 1812

#define CPXERR_Q_DIVISOR 1619

#define CPXERR_Q_DUP_ENTRY 5011

#define CPXERR_Q_NOT_INDEF 5014

#define CPXERR_Q_NOT_POS_DEF 5002

#define CPXERR_Q_NOT_SYMMETRIC 5012

#define CPXERR_QCP_SENSE 6002

#define CPXERR_QCP_SENSE_FILE 1437

#define CPXERR_QUAD_EXP_NOT_2 1613

#define CPXERR_QUAD_IN_ROW 1605

#define CPXERR_RANGE_SECTION_ORDER 1474

#define CPXERR_RESTRICTED_VERSION 1016

#define CPXERR_RHS_IN_OBJ 1603

#define CPXERR_RIM_REPEATS 1447

#define CPXERR_RIM_ROW_REPEATS 1444

#define CPXERR_RIMNZ_REPEATS 1479

#define CPXERR_ROW_INDEX_RANGE 1203

#define CPXERR_ROW_REPEAT_PRINT 1477

#define CPXERR_ROW_REPEATS 1445

#define CPXERR_ROW_UNKNOWN 1448

#define CPXERR_SAV_FILE_DATA 1561

#define CPXERR_SAV_FILE_VALUE 1564

#define CPXERR_SAV_FILE_WRITE 1562

#define CPXERR_SBASE_ILLEGAL 1554

#define CPXERR_SBASE_INCOMPAT 1255

#define CPXERR_SINGULAR 1256

#define CPXERR_STR_PARAM_TOO_LONG 1026

#define CPXERR_SUBPROB_SOLVE 3019

#define CPXERR_SYNCPRIM_CREATE 1809

#define CPXERR_SYSCALL 1813

#define CPXERR_THREAD_FAILED 1234

#define CPXERR_TILIM_CONDITION_NO 1268

#define CPXERR_TILIM_STRONGBRANCH 1266

#define CPXERR_TOO_MANY_COEFFS 1433

#define CPXERR_TOO_MANY_COLS 1432

#define CPXERR_TOO_MANY_RIMNZ 1485

#define CPXERR_TOO_MANY_RIMS 1484

#define CPXERR_TOO_MANY_ROWS 1431

#define CPXERR_TOO_MANY_THREADS 1020

#define CPXERR_TREE_MEMORY_LIMIT 3413

#define CPXERR_TUNE_MIXED 1730

#define CPXERR_UNIQUE_WEIGHTS 3010

#define CPXERR_UNSUPPORTED_CONSTRAINT_TYPE 1212

#define CPXERR_UNSUPPORTED_OPERATION 1811

#define CPXERR_UP_BOUND_REPEATS 1458

#define CPXERR_WORK_FILE_OPEN 1801

#define CPXERR_WORK_FILE_READ 1802

#define CPXERR_WORK_FILE_WRITE 1803

#define CPXERR_XMLPARSE 1425

#define CPXMESSAGEBUFSIZE 1024

#define CPXMI_BIGM_COEF 1040

#define CPXMI_BIGM_TO_IND 1041

#define CPXMI_BIGM_VARBOUND 1042

#define CPXMI_CANCEL_TOL 1045

#define CPXMI_EPGAP_LARGE 1038

#define CPXMI_EPGAP_OBJOFFSET 1037

#define CPXMI_FEAS_TOL 1043

#define CPXMI_FRACTION_SCALING 1047

#define CPXMI_IND_NZ_LARGE_NUM 1019

#define CPXMI_IND_NZ_SMALL_NUM 1020

#define CPXMI_IND_RHS_LARGE_NUM 1021

#define CPXMI_IND_RHS_SMALL_NUM 1022

#define CPXMI_KAPPA_ILLPOSED 1035

#define CPXMI_KAPPA_SUSPICIOUS 1033

#define CPXMI_KAPPA_UNSTABLE 1034

#define CPXMI_LB_LARGE_NUM 1003

#define CPXMI_LB_SMALL_NUM 1004

#define CPXMI_LC_NZ_LARGE_NUM 1023

#define CPXMI_LC_NZ_SMALL_NUM 1024

#define CPXMI_LC_RHS_LARGE_NUM 1025

#define CPXMI_LC_RHS_SMALL_NUM 1026

#define CPXMI_MULTIOBJ_COEFFS 1062

#define CPXMI_MULTIOBJ_LARGE_NUM 1058

#define CPXMI_MULTIOBJ_MIX 1063

#define CPXMI_MULTIOBJ_OPT_TOL 1060

#define CPXMI_MULTIOBJ_SMALL_NUM 1059

#define CPXMI_NZ_LARGE_NUM 1009

#define CPXMI_NZ_SMALL_NUM 1010

#define CPXMI_OBJ_LARGE_NUM 1001

#define CPXMI_OBJ_SMALL_NUM 1002

#define CPXMI_OPT_TOL 1044

#define CPXMI_QC_LINNZ_LARGE_NUM 1015

#define CPXMI_QC_LINNZ_SMALL_NUM 1016

#define CPXMI_QC_QNZ_LARGE_NUM 1017

#define CPXMI_QC_QNZ_SMALL_NUM 1018

#define CPXMI_QC_RHS_LARGE_NUM 1013

#define CPXMI_QC_RHS_SMALL_NUM 1014

#define CPXMI_QOBJ_LARGE_NUM 1011

#define CPXMI_QOBJ_SMALL_NUM 1012

#define CPXMI_QOPT_TOL 1046

#define CPXMI_RHS_LARGE_NUM 1007

#define CPXMI_RHS_SMALL_NUM 1008

#define CPXMI_SAMECOEFF_COL 1050

#define CPXMI_SAMECOEFF_IND 1051

#define CPXMI_SAMECOEFF_LAZY 1054

#define CPXMI_SAMECOEFF_MULTIOBJ 1061

#define CPXMI_SAMECOEFF_OBJ 1057

#define CPXMI_SAMECOEFF_QLIN 1052

#define CPXMI_SAMECOEFF_QUAD 1053

#define CPXMI_SAMECOEFF_RHS 1056

#define CPXMI_SAMECOEFF_ROW 1049

#define CPXMI_SAMECOEFF_UCUT 1055

#define CPXMI_SINGLE_PRECISION 1036

#define CPXMI_SYMMETRY_BREAKING_INEQ 1039

#define CPXMI_UB_LARGE_NUM 1005

#define CPXMI_UB_SMALL_NUM 1006

#define CPXMI_UC_NZ_LARGE_NUM 1027

#define CPXMI_UC_NZ_SMALL_NUM 1028

#define CPXMI_UC_RHS_LARGE_NUM 1029

#define CPXMI_UC_RHS_SMALL_NUM 1030

#define CPXMI_WIDE_COEFF_RANGE 1048

#define CPXMIP_ABORT_FEAS 113

#define CPXMIP_ABORT_INFEAS 114

#define CPXMIP_ABORT_RELAXATION_UNBOUNDED 133

#define CPXMIP_ABORT_RELAXED 126

#define CPXMIP_BENDERS_MASTER_UNBOUNDED 134

#define CPXMIP_DETTIME_LIM_FEAS 131

#define CPXMIP_DETTIME_LIM_INFEAS 132

#define CPXMIP_FAIL_FEAS 109

#define CPXMIP_FAIL_FEAS_NO_TREE 116

#define CPXMIP_FAIL_INFEAS 110

#define CPXMIP_FAIL_INFEAS_NO_TREE 117

#define CPXMIP_FEASIBLE 127

#define CPXMIP_FEASIBLE_RELAXED_INF 122

#define CPXMIP_FEASIBLE_RELAXED_QUAD 124

#define CPXMIP_FEASIBLE_RELAXED_SUM 120

#define CPXMIP_INFEASIBLE 103

#define CPXMIP_INForUNBD 119

#define CPXMIP_MEM_LIM_FEAS 111

#define CPXMIP_MEM_LIM_INFEAS 112

#define CPXMIP_NODE_LIM_FEAS 105

#define CPXMIP_NODE_LIM_INFEAS 106

#define CPXMIP_OPTIMAL 101

#define CPXMIP_OPTIMAL_INFEAS 115

#define CPXMIP_OPTIMAL_POPULATED 129

#define CPXMIP_OPTIMAL_POPULATED_TOL 130

#define CPXMIP_OPTIMAL_RELAXED_INF 123

#define CPXMIP_OPTIMAL_RELAXED_QUAD 125

#define CPXMIP_OPTIMAL_RELAXED_SUM 121

#define CPXMIP_OPTIMAL_TOL 102

#define CPXMIP_POPULATESOL_LIM 128

#define CPXMIP_SOL_LIM 104

#define CPXMIP_TIME_LIM_FEAS 107

#define CPXMIP_TIME_LIM_INFEAS 108

#define CPXMIP_UNBOUNDED 118

#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* !CPX_CPXAUTOCONSTANTS_H_H */

#ifndef CPX_CPXAUTOENUMS_H_H
#   define CPX_CPXAUTOENUMS_H_H 1

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
   CPXCALLBACKINFO_THREADID,
   CPXCALLBACKINFO_NODECOUNT,
   CPXCALLBACKINFO_ITCOUNT,
   CPXCALLBACKINFO_BEST_SOL,
   CPXCALLBACKINFO_BEST_BND,
   CPXCALLBACKINFO_THREADS,
   CPXCALLBACKINFO_FEASIBLE,
   CPXCALLBACKINFO_TIME,
   CPXCALLBACKINFO_DETTIME
} CPXCALLBACKINFO;
    

typedef enum {
   CPXCALLBACKSOLUTION_NOCHECK = -1,
   CPXCALLBACKSOLUTION_CHECKFEAS,
   CPXCALLBACKSOLUTION_PROPAGATE,
   CPXCALLBACKSOLUTION_SOLVE
} CPXCALLBACKSOLUTIONSTRATEGY;
    

typedef enum {
   CPXINFO_BYTE,
   CPXINFO_SHORT,
   CPXINFO_INT,
   CPXINFO_LONG,
   CPXINFO_DOUBLE
} CPXINFOTYPE;
    

#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* !CPX_CPXAUTOENUMS_H_H */
/* --------------------------------------------------------------------------
 * Version 12.9.0
 * --------------------------------------------------------------------------
 * Licensed Materials - Property of IBM
 * 5725-A06 5725-A29 5724-Y48 5724-Y49 5724-Y54 5724-Y55 5655-Y21
 * Copyright IBM Corporation 2000, 2019. All Rights Reserved.
 * 
 * US Government Users Restricted Rights - Use, duplication or
 * disclosure restricted by GSA ADP Schedule Contract with
 * IBM Corp.
 * --------------------------------------------------------------------------
 */

#ifndef CPXPARAM_H
#define CPXPARAM_H 1

#define CPXPARAM_Advance 1001
#define CPXPARAM_Barrier_Algorithm 3007
#define CPXPARAM_Barrier_ColNonzeros 3009
#define CPXPARAM_Barrier_ConvergeTol 3002
#define CPXPARAM_Barrier_Crossover 3018
#define CPXPARAM_Barrier_Display 3010
#define CPXPARAM_Barrier_Limits_Corrections 3013
#define CPXPARAM_Barrier_Limits_Growth 3003
#define CPXPARAM_Barrier_Limits_Iteration 3012
#define CPXPARAM_Barrier_Limits_ObjRange 3004
#define CPXPARAM_Barrier_Ordering 3014
#define CPXPARAM_Barrier_QCPConvergeTol 3020
#define CPXPARAM_Barrier_StartAlg 3017
#define CPXPARAM_Benders_Strategy 1501
#define CPXPARAM_Benders_Tolerances_feasibilitycut 1509
#define CPXPARAM_Benders_Tolerances_optimalitycut 1510
#define CPXPARAM_Benders_WorkerAlgorithm 1500
#define CPXPARAM_ClockType 1006
#define CPXPARAM_Conflict_Algorithm 1073
#define CPXPARAM_Conflict_Display 1074
#define CPXPARAM_CPUmask 1144
#define CPXPARAM_DetTimeLimit 1127
#define CPXPARAM_DistMIP_Rampup_DetTimeLimit 2164
#define CPXPARAM_DistMIP_Rampup_Duration 2163
#define CPXPARAM_DistMIP_Rampup_TimeLimit 2165
#define CPXPARAM_Emphasis_Memory 1082
#define CPXPARAM_Emphasis_MIP 2058
#define CPXPARAM_Emphasis_Numerical 1083
#define CPXPARAM_Feasopt_Mode 1084
#define CPXPARAM_Feasopt_Tolerance 2073
#define CPXPARAM_LPMethod 1062
#define CPXPARAM_MIP_Cuts_BQP 2195
#define CPXPARAM_MIP_Cuts_Cliques 2003
#define CPXPARAM_MIP_Cuts_Covers 2005
#define CPXPARAM_MIP_Cuts_Disjunctive 2053
#define CPXPARAM_MIP_Cuts_FlowCovers 2040
#define CPXPARAM_MIP_Cuts_Gomory 2049
#define CPXPARAM_MIP_Cuts_GUBCovers 2044
#define CPXPARAM_MIP_Cuts_Implied 2041
#define CPXPARAM_MIP_Cuts_LiftProj 2152
#define CPXPARAM_MIP_Cuts_LocalImplied 2181
#define CPXPARAM_MIP_Cuts_MCFCut 2134
#define CPXPARAM_MIP_Cuts_MIRCut 2052
#define CPXPARAM_MIP_Cuts_PathCut 2051
#define CPXPARAM_MIP_Cuts_RLT 2196
#define CPXPARAM_MIP_Cuts_ZeroHalfCut 2111
#define CPXPARAM_MIP_Display 2012
#define CPXPARAM_MIP_Interval 2013
#define CPXPARAM_MIP_Limits_AggForCut 2054
#define CPXPARAM_MIP_Limits_AuxRootThreads 2139
#define CPXPARAM_MIP_Limits_CutPasses 2056
#define CPXPARAM_MIP_Limits_CutsFactor 2033
#define CPXPARAM_MIP_Limits_EachCutLimit 2102
#define CPXPARAM_MIP_Limits_GomoryCand 2048
#define CPXPARAM_MIP_Limits_GomoryPass 2050
#define CPXPARAM_MIP_Limits_Nodes 2017
#define CPXPARAM_MIP_Limits_PolishTime 2066
#define CPXPARAM_MIP_Limits_Populate 2108
#define CPXPARAM_MIP_Limits_ProbeDetTime 2150
#define CPXPARAM_MIP_Limits_ProbeTime 2065
#define CPXPARAM_MIP_Limits_RepairTries 2067
#define CPXPARAM_MIP_Limits_Solutions 2015
#define CPXPARAM_MIP_Limits_StrongCand 2045
#define CPXPARAM_MIP_Limits_StrongIt 2046
#define CPXPARAM_MIP_Limits_TreeMemory 2027
#define CPXPARAM_MIP_OrderType 2032
#define CPXPARAM_MIP_PolishAfter_AbsMIPGap 2126
#define CPXPARAM_MIP_PolishAfter_DetTime 2151
#define CPXPARAM_MIP_PolishAfter_MIPGap 2127
#define CPXPARAM_MIP_PolishAfter_Nodes 2128
#define CPXPARAM_MIP_PolishAfter_Solutions 2129
#define CPXPARAM_MIP_PolishAfter_Time 2130
#define CPXPARAM_MIP_Pool_AbsGap 2106
#define CPXPARAM_MIP_Pool_Capacity 2103
#define CPXPARAM_MIP_Pool_Intensity 2107
#define CPXPARAM_MIP_Pool_RelGap 2105
#define CPXPARAM_MIP_Pool_Replace 2104
#define CPXPARAM_MIP_Strategy_Backtrack 2002
#define CPXPARAM_MIP_Strategy_BBInterval 2039
#define CPXPARAM_MIP_Strategy_Branch 2001
#define CPXPARAM_MIP_Strategy_CallbackReducedLP 2055
#define CPXPARAM_MIP_Strategy_Dive 2060
#define CPXPARAM_MIP_Strategy_File 2016
#define CPXPARAM_MIP_Strategy_FPHeur 2098
#define CPXPARAM_MIP_Strategy_HeuristicFreq 2031
#define CPXPARAM_MIP_Strategy_KappaStats 2137
#define CPXPARAM_MIP_Strategy_LBHeur 2063
#define CPXPARAM_MIP_Strategy_MIQCPStrat 2110
#define CPXPARAM_MIP_Strategy_NodeSelect 2018
#define CPXPARAM_MIP_Strategy_Order 2020
#define CPXPARAM_MIP_Strategy_PresolveNode 2037
#define CPXPARAM_MIP_Strategy_Probe 2042
#define CPXPARAM_MIP_Strategy_RINSHeur 2061
#define CPXPARAM_MIP_Strategy_Search 2109
#define CPXPARAM_MIP_Strategy_StartAlgorithm 2025
#define CPXPARAM_MIP_Strategy_SubAlgorithm 2026
#define CPXPARAM_MIP_Strategy_VariableSelect 2028
#define CPXPARAM_MIP_SubMIP_StartAlg 2205
#define CPXPARAM_MIP_SubMIP_SubAlg 2206
#define CPXPARAM_MIP_SubMIP_NodeLimit 2212
#define CPXPARAM_MIP_SubMIP_Scale 2207
#define CPXPARAM_MIP_Tolerances_AbsMIPGap 2008
#define CPXPARAM_MIP_Tolerances_Linearization 2068
#define CPXPARAM_MIP_Tolerances_Integrality 2010
#define CPXPARAM_MIP_Tolerances_LowerCutoff 2006
#define CPXPARAM_MIP_Tolerances_MIPGap 2009
#define CPXPARAM_MIP_Tolerances_ObjDifference 2019
#define CPXPARAM_MIP_Tolerances_RelObjDifference 2022
#define CPXPARAM_MIP_Tolerances_UpperCutoff 2007
#define CPXPARAM_MultiObjective_Display 1600
#define CPXPARAM_Network_Display 5005
#define CPXPARAM_Network_Iterations 5001
#define CPXPARAM_Network_NetFind 1022
#define CPXPARAM_Network_Pricing 5004
#define CPXPARAM_Network_Tolerances_Feasibility 5003
#define CPXPARAM_Network_Tolerances_Optimality 5002
#define CPXPARAM_OptimalityTarget 1131
#define CPXPARAM_Output_CloneLog 1132
#define CPXPARAM_Output_IntSolFilePrefix 2143
#define CPXPARAM_Output_MPSLong 1081
#define CPXPARAM_Output_WriteLevel 1114
#define CPXPARAM_Parallel 1109
#define CPXPARAM_ParamDisplay 1163
#define CPXPARAM_Preprocessing_Aggregator 1003
#define CPXPARAM_Preprocessing_BoundStrength 2029
#define CPXPARAM_Preprocessing_CoeffReduce 2004
#define CPXPARAM_Preprocessing_Dependency 1008
#define CPXPARAM_Preprocessing_Dual 1044
#define CPXPARAM_Preprocessing_Fill 1002
#define CPXPARAM_Preprocessing_Folding 1164
#define CPXPARAM_Preprocessing_Linear 1058
#define CPXPARAM_Preprocessing_NumPass 1052
#define CPXPARAM_Preprocessing_Presolve 1030
#define CPXPARAM_Preprocessing_QCPDuals 4003
#define CPXPARAM_Preprocessing_QPMakePSD 4010
#define CPXPARAM_Preprocessing_QToLin 4012
#define CPXPARAM_Preprocessing_Reduce 1057
#define CPXPARAM_Preprocessing_Relax 2034
#define CPXPARAM_Preprocessing_RepeatPresolve 2064
#define CPXPARAM_Preprocessing_Symmetry 2059
#define CPXPARAM_QPMethod 1063
#define CPXPARAM_RandomSeed 1124
#define CPXPARAM_Read_APIEncoding 1130
#define CPXPARAM_Read_Constraints 1021
#define CPXPARAM_Read_DataCheck 1056
#define CPXPARAM_Read_FileEncoding 1129
#define CPXPARAM_Read_Nonzeros 1024
#define CPXPARAM_Read_QPNonzeros 4001
#define CPXPARAM_Read_Scale 1034
#define CPXPARAM_Read_Variables 1023
#define CPXPARAM_Read_WarningLimit 1157
#define CPXPARAM_Record 1162
#define CPXPARAM_ScreenOutput 1035
#define CPXPARAM_Sifting_Algorithm 1077
#define CPXPARAM_Sifting_Simplex 1158
#define CPXPARAM_Sifting_Display 1076
#define CPXPARAM_Sifting_Iterations 1078
#define CPXPARAM_Simplex_Crash 1007
#define CPXPARAM_Simplex_DGradient 1009
#define CPXPARAM_Simplex_Display 1019
#define CPXPARAM_Simplex_DynamicRows 1161
#define CPXPARAM_Simplex_Limits_Iterations 1020
#define CPXPARAM_Simplex_Limits_LowerObj 1025
#define CPXPARAM_Simplex_Limits_Perturbation 1028
#define CPXPARAM_Simplex_Limits_Singularity 1037
#define CPXPARAM_Simplex_Limits_UpperObj 1026
#define CPXPARAM_Simplex_Perturbation_Constant 1015
#define CPXPARAM_Simplex_Perturbation_Indicator 1027
#define CPXPARAM_Simplex_PGradient 1029
#define CPXPARAM_Simplex_Pricing 1010
#define CPXPARAM_Simplex_Refactor 1031
#define CPXPARAM_Simplex_Tolerances_Feasibility 1016
#define CPXPARAM_Simplex_Tolerances_Markowitz 1013
#define CPXPARAM_Simplex_Tolerances_Optimality 1014
#define CPXPARAM_SolutionType 1147
#define CPXPARAM_Threads 1067
#define CPXPARAM_TimeLimit 1039
#define CPXPARAM_Tune_DetTimeLimit 1139
#define CPXPARAM_Tune_Display 1113
#define CPXPARAM_Tune_Measure 1110
#define CPXPARAM_Tune_Repeat 1111
#define CPXPARAM_Tune_TimeLimit 1112
#define CPXPARAM_WorkDir 1064
#define CPXPARAM_WorkMem 1065

#endif /* CPXPARAM_H */
/* --------------------------------------------------------------------------
 * Version 12.9.0
 * --------------------------------------------------------------------------
 * Licensed Materials - Property of IBM
 * 5725-A06 5725-A29 5724-Y48 5724-Y49 5724-Y54 5724-Y55 5655-Y21
 * Copyright IBM Corporation 2000, 2019. All Rights Reserved.
 * 
 * US Government Users Restricted Rights - Use, duplication or
 * disclosure restricted by GSA ADP Schedule Contract with
 * IBM Corp.
 * --------------------------------------------------------------------------
 */

#ifndef CPXPUBLICPARAMS_H
#define CPXPUBLICPARAMS_H 1

#define CPX_PARAM_ADVIND 1001
#define CPX_PARAM_AGGFILL 1002
#define CPX_PARAM_AGGIND 1003
#define CPX_PARAM_CLOCKTYPE 1006
#define CPX_PARAM_CRAIND 1007
#define CPX_PARAM_DEPIND 1008
#define CPX_PARAM_DPRIIND 1009
#define CPX_PARAM_PRICELIM 1010
#define CPX_PARAM_EPMRK 1013
#define CPX_PARAM_EPOPT 1014
#define CPX_PARAM_EPPER 1015
#define CPX_PARAM_EPRHS 1016
#define CPX_PARAM_SIMDISPLAY 1019
#define CPX_PARAM_ITLIM 1020
#define CPX_PARAM_ROWREADLIM 1021
#define CPX_PARAM_NETFIND 1022
#define CPX_PARAM_COLREADLIM 1023
#define CPX_PARAM_NZREADLIM 1024
#define CPX_PARAM_OBJLLIM 1025
#define CPX_PARAM_OBJULIM 1026
#define CPX_PARAM_PERIND 1027
#define CPX_PARAM_PERLIM 1028
#define CPX_PARAM_PPRIIND 1029
#define CPX_PARAM_PREIND 1030
#define CPX_PARAM_REINV 1031
#define CPX_PARAM_SCAIND 1034
#define CPX_PARAM_SCRIND 1035
#define CPX_PARAM_SINGLIM 1037
#define CPX_PARAM_TILIM 1039
#define CPX_PARAM_PREDUAL 1044
#define CPX_PARAM_PREPASS 1052
#define CPX_PARAM_DATACHECK 1056
#define CPX_PARAM_REDUCE 1057
#define CPX_PARAM_PRELINEAR 1058
#define CPX_PARAM_LPMETHOD 1062
#define CPX_PARAM_QPMETHOD 1063
#define CPX_PARAM_WORKDIR 1064
#define CPX_PARAM_WORKMEM 1065
#define CPX_PARAM_THREADS 1067
#define CPX_PARAM_CONFLICTALG 1073
#define CPX_PARAM_CONFLICTDISPLAY 1074
#define CPX_PARAM_SIFTDISPLAY 1076
#define CPX_PARAM_SIFTALG 1077
#define CPX_PARAM_SIFTITLIM 1078
#define CPX_PARAM_MPSLONGNUM 1081
#define CPX_PARAM_MEMORYEMPHASIS 1082
#define CPX_PARAM_NUMERICALEMPHASIS 1083
#define CPX_PARAM_FEASOPTMODE 1084
#define CPX_PARAM_PARALLELMODE 1109
#define CPX_PARAM_TUNINGMEASURE 1110
#define CPX_PARAM_TUNINGREPEAT 1111
#define CPX_PARAM_TUNINGTILIM 1112
#define CPX_PARAM_TUNINGDISPLAY 1113
#define CPX_PARAM_WRITELEVEL 1114
#define CPX_PARAM_RANDOMSEED 1124
#define CPX_PARAM_DETTILIM 1127
#define CPX_PARAM_FILEENCODING 1129
#define CPX_PARAM_APIENCODING 1130
#define CPX_PARAM_OPTIMALITYTARGET 1131
#define CPX_PARAM_CLONELOG 1132
#define CPX_PARAM_TUNINGDETTILIM 1139
#define CPX_PARAM_CPUMASK 1144
#define CPX_PARAM_SOLUTIONTYPE 1147
#define CPX_PARAM_WARNLIM 1157
#define CPX_PARAM_SIFTSIM 1158
#define CPX_PARAM_DYNAMICROWS 1161
#define CPX_PARAM_RECORD 1162
#define CPX_PARAM_PARAMDISPLAY 1163
#define CPX_PARAM_FOLDING 1164
#define CPX_PARAM_WORKERALG 1500
#define CPX_PARAM_BENDERSSTRATEGY 1501
#define CPX_PARAM_BENDERSFEASCUTTOL 1509
#define CPX_PARAM_BENDERSOPTCUTTOL 1510
#define CPX_PARAM_MULTIOBJDISPLAY 1600
#define CPX_PARAM_BRDIR 2001
#define CPX_PARAM_BTTOL 2002
#define CPX_PARAM_CLIQUES 2003
#define CPX_PARAM_COEREDIND 2004
#define CPX_PARAM_COVERS 2005
#define CPX_PARAM_CUTLO 2006
#define CPX_PARAM_CUTUP 2007
#define CPX_PARAM_EPAGAP 2008
#define CPX_PARAM_EPGAP 2009
#define CPX_PARAM_EPINT 2010
#define CPX_PARAM_MIPDISPLAY 2012
#define CPX_PARAM_MIPINTERVAL 2013
#define CPX_PARAM_INTSOLLIM 2015
#define CPX_PARAM_NODEFILEIND 2016
#define CPX_PARAM_NODELIM 2017
#define CPX_PARAM_NODESEL 2018
#define CPX_PARAM_OBJDIF 2019
#define CPX_PARAM_MIPORDIND 2020
#define CPX_PARAM_RELOBJDIF 2022
#define CPX_PARAM_STARTALG 2025
#define CPX_PARAM_SUBALG 2026
#define CPX_PARAM_TRELIM 2027
#define CPX_PARAM_VARSEL 2028
#define CPX_PARAM_BNDSTRENIND 2029
#define CPX_PARAM_HEURFREQ 2031
#define CPX_PARAM_MIPORDTYPE 2032
#define CPX_PARAM_CUTSFACTOR 2033
#define CPX_PARAM_RELAXPREIND 2034
#define CPX_PARAM_PRESLVND 2037
#define CPX_PARAM_BBINTERVAL 2039
#define CPX_PARAM_FLOWCOVERS 2040
#define CPX_PARAM_IMPLBD 2041
#define CPX_PARAM_PROBE 2042
#define CPX_PARAM_GUBCOVERS 2044
#define CPX_PARAM_STRONGCANDLIM 2045
#define CPX_PARAM_STRONGITLIM 2046
#define CPX_PARAM_FRACCAND 2048
#define CPX_PARAM_FRACCUTS 2049
#define CPX_PARAM_FRACPASS 2050
#define CPX_PARAM_FLOWPATHS 2051
#define CPX_PARAM_MIRCUTS 2052
#define CPX_PARAM_DISJCUTS 2053
#define CPX_PARAM_AGGCUTLIM 2054
#define CPX_PARAM_MIPCBREDLP 2055
#define CPX_PARAM_CUTPASS 2056
#define CPX_PARAM_MIPEMPHASIS 2058
#define CPX_PARAM_SYMMETRY 2059
#define CPX_PARAM_DIVETYPE 2060
#define CPX_PARAM_RINSHEUR 2061
#define CPX_PARAM_LBHEUR 2063
#define CPX_PARAM_REPEATPRESOLVE 2064
#define CPX_PARAM_PROBETIME 2065
#define CPX_PARAM_POLISHTIME 2066
#define CPX_PARAM_REPAIRTRIES 2067
#define CPX_PARAM_EPLIN 2068
#define CPX_PARAM_EPRELAX 2073
#define CPX_PARAM_FPHEUR 2098
#define CPX_PARAM_EACHCUTLIM 2102
#define CPX_PARAM_SOLNPOOLCAPACITY 2103
#define CPX_PARAM_SOLNPOOLREPLACE 2104
#define CPX_PARAM_SOLNPOOLGAP 2105
#define CPX_PARAM_SOLNPOOLAGAP 2106
#define CPX_PARAM_SOLNPOOLINTENSITY 2107
#define CPX_PARAM_POPULATELIM 2108
#define CPX_PARAM_MIPSEARCH 2109
#define CPX_PARAM_MIQCPSTRAT 2110
#define CPX_PARAM_ZEROHALFCUTS 2111
#define CPX_PARAM_POLISHAFTEREPAGAP 2126
#define CPX_PARAM_POLISHAFTEREPGAP 2127
#define CPX_PARAM_POLISHAFTERNODE 2128
#define CPX_PARAM_POLISHAFTERINTSOL 2129
#define CPX_PARAM_POLISHAFTERTIME 2130
#define CPX_PARAM_MCFCUTS 2134
#define CPX_PARAM_MIPKAPPASTATS 2137
#define CPX_PARAM_AUXROOTTHREADS 2139
#define CPX_PARAM_INTSOLFILEPREFIX 2143
#define CPX_PARAM_PROBEDETTIME 2150
#define CPX_PARAM_POLISHAFTERDETTIME 2151
#define CPX_PARAM_LANDPCUTS 2152
#define CPX_PARAM_RAMPUPDURATION 2163
#define CPX_PARAM_RAMPUPDETTILIM 2164
#define CPX_PARAM_RAMPUPTILIM 2165
#define CPX_PARAM_LOCALIMPLBD 2181
#define CPX_PARAM_BQPCUTS 2195
#define CPX_PARAM_RLTCUTS 2196
#define CPX_PARAM_SUBMIPSTARTALG 2205
#define CPX_PARAM_SUBMIPSUBALG 2206
#define CPX_PARAM_SUBMIPSCAIND 2207
#define CPX_PARAM_SUBMIPNODELIMIT 2212
#define CPX_PARAM_BAREPCOMP 3002
#define CPX_PARAM_BARGROWTH 3003
#define CPX_PARAM_BAROBJRNG 3004
#define CPX_PARAM_BARALG 3007
#define CPX_PARAM_BARCOLNZ 3009
#define CPX_PARAM_BARDISPLAY 3010
#define CPX_PARAM_BARITLIM 3012
#define CPX_PARAM_BARMAXCOR 3013
#define CPX_PARAM_BARORDER 3014
#define CPX_PARAM_BARSTARTALG 3017
#define CPX_PARAM_BARCROSSALG 3018
#define CPX_PARAM_BARQCPEPCOMP 3020
#define CPX_PARAM_QPNZREADLIM 4001
#define CPX_PARAM_CALCQCPDUALS 4003
#define CPX_PARAM_QPMAKEPSDIND 4010
#define CPX_PARAM_QTOLININD 4012
#define CPX_PARAM_NETITLIM 5001
#define CPX_PARAM_NETEPOPT 5002
#define CPX_PARAM_NETEPRHS 5003
#define CPX_PARAM_NETPPRIIND 5004
#define CPX_PARAM_NETDISPLAY 5005

#endif /* CPXPUBLICPARAMS_H */

#ifndef CPX_CPXAUTOTYPES_H_H
#   define CPX_CPXAUTOTYPES_H_H 1

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct cpxasynchandle *CPXASYNCptr;
    

typedef struct cpxcallbackcontext *CPXCALLBACKCONTEXTptr;
    

typedef int CPXPUBLIC CPXCALLBACKFUNC(CPXCALLBACKCONTEXTptr context, CPXLONG contextid, void *userhandle);
    

typedef struct cpxasynchandle const *CPXCASYNCptr;
    

typedef struct cpxdeserializer const *CPXCDESERIALIZERptr;
    

typedef struct cpxenvgroup const *CPXCENVGROUPptr;
    

typedef struct messagehandler const *CPXCMESSAGEHANDLERptr;
    

typedef struct cpxserializer const *CPXCSERIALIZERptr;
    

typedef struct cpxdeserializer *CPXDESERIALIZERptr;
    

typedef struct cpxenvgroup *CPXENVGROUPptr;
    

typedef void (CPXPUBLIC CPXINFOHANDLER) (CPXENVptr env, CPXINFOTYPE type,
                                        int tag, CPXLONG elems,
					void const *data, void *handle);
    

typedef struct messagehandler *CPXMESSAGEHANDLERptr;
    

typedef int CPXPUBLIC CPXMODELASSTCALLBACKFUNC(int issueid, const char *message, void *userhandle);
    

typedef struct cpxserializer *CPXSERIALIZERptr;
    

typedef int (CPXPUBLIC CPXUSERFUNCTION) (CPXENVptr env, int id,
                                         CPXLONG insize, void const *indata,
                                         CPXLONG maxout, CPXLONG *outsize_p,
                                         void *outdata, void *handle);
    

#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* !CPX_CPXAUTOTYPES_H_H */

#ifndef CPX_CPXAUTOSTRUCTS_H_H
#   define CPX_CPXAUTOSTRUCTS_H_H 1

#ifdef _WIN32
#pragma pack(push, 8)
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct cpxasynchandle;
    

struct cpxdeserializer {
   int (CPXPUBLIC *getbyte) (CPXDESERIALIZERptr deser, CPXBYTE *b);
   int (CPXPUBLIC *getshort) (CPXDESERIALIZERptr deser, CPXSHORT *s);
   int (CPXPUBLIC *getint) (CPXDESERIALIZERptr deser, CPXINT *i);
   int (CPXPUBLIC *getlong) (CPXDESERIALIZERptr deser, CPXLONG *l);
   int (CPXPUBLIC *getfloat) (CPXDESERIALIZERptr deser, float *f);
   int (CPXPUBLIC *getdouble) (CPXDESERIALIZERptr deser, double *d);
   int (CPXPUBLIC *getbytes) (CPXDESERIALIZERptr deser, CPXLONG cnt, CPXBYTE *b);
   int (CPXPUBLIC *getshorts) (CPXDESERIALIZERptr deser, CPXLONG cnt, CPXSHORT *s);
   int (CPXPUBLIC *getints) (CPXDESERIALIZERptr deser, CPXLONG cnt, CPXINT *i);
   int (CPXPUBLIC *getlongs) (CPXDESERIALIZERptr deser, CPXLONG cnt, CPXLONG *l);
   int (CPXPUBLIC *getfloats) (CPXDESERIALIZERptr deser, CPXLONG cnt, float *d);
   int (CPXPUBLIC *getdoubles) (CPXDESERIALIZERptr deser, CPXLONG cnt, double *d);
};
    

struct cpxserializer {
   int (CPXPUBLIC *addbyte) (CPXSERIALIZERptr ser, CPXBYTE b);
   int (CPXPUBLIC *addshort) (CPXSERIALIZERptr ser, CPXSHORT s);
   int (CPXPUBLIC *addint) (CPXSERIALIZERptr ser, CPXINT i);
   int (CPXPUBLIC *addlong) (CPXSERIALIZERptr ser, CPXLONG l);
   int (CPXPUBLIC *addfloat) (CPXSERIALIZERptr ser, float f);
   int (CPXPUBLIC *adddouble) (CPXSERIALIZERptr ser, double d);
   int (CPXPUBLIC *addbytes) (CPXSERIALIZERptr ser, CPXLONG cnt, CPXBYTE const *b);
   int (CPXPUBLIC *addshorts) (CPXSERIALIZERptr ser, CPXLONG cnt, CPXSHORT const *s);
   int (CPXPUBLIC *addints) (CPXSERIALIZERptr ser, CPXLONG cnt, CPXINT const *i);
   int (CPXPUBLIC *addlongs) (CPXSERIALIZERptr ser, CPXLONG cnt, CPXLONG const *l);
   int (CPXPUBLIC *addfloats) (CPXSERIALIZERptr ser, CPXLONG cnt, float const *d);
   int (CPXPUBLIC *adddoubles) (CPXSERIALIZERptr ser, CPXLONG cnt, double const *d);
};
    

struct messagehandler;
    

#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#pragma pack(pop)
#endif

#endif /* !CPX_CPXAUTOSTRUCTS_H_H */
