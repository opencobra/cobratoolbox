******* OptForce code *******************************************
*       Notes:                                                  *
*       This GAMS code identifies "K" number of metabolic       *
*       interventions that must be actively performed in the    *
*       wild-type strain to FORCE the organism to produce       *
*       the target biochemical at the desired yield.            *
*                                                               *
*       Author: Sridhar Ranganathan
*       Date: August 16th, 2011
*       Contribution: Creator
*
*       Author: Sebastian Mendoza
*       Date: May 23th, 2017
*       Contribution:
*                   1) The function was modificated to make it general in order
*                      to recibe external inputs such as reactions and metabolites IDs,
*                      stoichiometrix matrix S, reactions with contraints, lower
*                      and upper bounds and results from FVA.
*                   2) Insertion of the package GDXMRW to read inputs from MATLAB
*                   3) Innecesary lines were removed
*****************************************************************

******************** List of Variables **************************
*       v(j) = flux value for the reaction j                    *
*       z = objective value                                     *
*       yu(j) = binary variable that pinpoint upregulations     *
*       yl(j) = binary variable that pinpoint downregulations   *
*       y0(j) = binary variable that pinpoint knockouts         *
*       ** Note **                                              *
*               The following code does not consider any        *
*       reaction knockouts. But it can be custom-made to        *
*       identify knockouts as well.                             *
*                                                               *
*       Other variables are used for linearizing purposes       *
*****************************************************************

******************** List of Parameters *************************
*       s(i,j) = stoichiometric index of metabolite i in rxn j  *
*       LB(j)/UB(j) = Lower / Upper Bounds for fluxes           *
*       basemin(j) = min flux value of reaction j in WT         *
*       basemax(j) = max flux value of reaction j in WT         *
*****************************************************************

options
        limrow = 10000
        limcol = 10000
        optCR = 1E-9
        optCA = 0.0
        iterlim = 100000
        decimals = 8
        reslim = 100000
        work = 50000000
        sysout = off
        solprint = on;

sets

******************************** SET DEFINITIONS ***************************************
*
*       i               = set of all metabolites
*       j               = set of all reactions
*       constraint(j) = set of reactions in the constraints of inner problem
*       must1(j)        = set of reactions from MustU + MustL sets
*       mustu(j), mustl(j) = set of reactions in the MustU and MustL sets, resp., identified using the previous steps
*****************************************************************************************

i metabolites
$include "%myroot%Metabolites.txt"

j reactions
$include "%myroot%Reactions.txt"

$ONEMPTY

constraint(j)
$include "%myroot%Constraints.txt"

excluded_U(j)
$include "%myroot%Excluded_U.txt"

excluded_L(j)
$include "%myroot%Excluded_L.txt"

excluded_K(j)
$include "%myroot%Excluded_K.txt"


index /1*500/

$ONEMPTY

mustl(j)
$include "%myroot%MustL.txt"

mustu(j)
$include "%myroot%MustU.txt"

target(j)
$include "%myroot%TargetRxn.txt"

;

****************************** PARAMETRIC CONSTANTS USED ********************************
*
*       s(i,j)          = Stoichiometry of metabolite i in reaction j
*       rxntype(j)      = Specified whether a reaction is irreversible (0), reversible
*                         (1 - forward, 2 - backward reaction), pseudo reactions (3), or
*                         exchange reactions (4)
*       basemin(j)      = Stores the value for the minimum flux of reaction j in WT strain
*       basemax(j)      = Stores the value for the maximum flux of reaction j in WT strain
*       phenomin(j)     = Stored the value for the minimum flux of reaction j in overproducing strain
*       phenomax(j)     = Stores the value for the maximum flux of reaction j in overproducing strain
*       LB(j)/UB(j)     = Stores the lower and upper bounds for each reaction j
*       n               = counter
*       epsilon         = error value
*       LB(j)/UB(j)     = Global lower and upper bounds for reaction j
*       k               = Number of Interventions allowed in the metabolism
*       bigM            = Large real number used for linearizing constraints
*
*****************************************************************************************

parameter

s(i,j)
basemin(j)
basemax(j)
b(j)
LB(j)
UB(j)
phenomin(j)
phenomax(j)

matrix1(index, j)
matrix2(index, j)
matrix3(index, j)

matrix1_flux(index, j)
matrix2_flux(index, j)
matrix3_flux(index, j)

objective(index)

epsilon
k
nMax
bigM
LB(j)
UB(j)
optforce
;

$if not set gdxin $set gdxin MtoGOF
$GDXIN %myroot%%gdxin%
$LOAD k nMax s basemin basemax b lb ub phenomin phenomax
$GDXIN

matrix1(index, j) = 0;
matrix2(index, j) = 0;
matrix3(index, j) = 0;

matrix1_flux(index, j) = 0;
matrix2_flux(index, j) = 0;
matrix3_flux(index, j) = 0;

objective(index) = 0;
optforce = 1;

***************************** VARIABLE DEFINITIONS **************************************
*
*       v(j)            = Flux of a reaction j (+/-)
*       zdual           = Objective value for the dual problem (+/-)
*       zprimal         = Objective value for the primal problem (+/-)
*       lambda, mu      = Dual variables (+/-)
*       w               = Linearizing variable (Outer Problem) (+/-)
*       z               = Objective value of the outer problem (+/-)
*       glc             = Dual variable for glucose uptake constraint (+/-)
*       deltam/deltap
*       thetam/thetap   = Dual variables for binding constraints (+)
*       wdeltap/wdeltam
*       wtheta / wphi   = Linearing variables (Outer Problem) (+/-)
*
*       yu(j), yl(j)    = Binary variables pertaining to up-regulations and down-regulations
*                         If yu(j) = 1, then reaction must be actively upregulated
*                                  = 0, Otherwise
*       theta, phi      = Dual variables (Inner Problem)
*
*****************************************************************************************

variables
v(j)
mu(j)
lambda(i)
z
wtheta(j), wphi(j), wdeltap(j), wdeltam(j)
;

positive variables
theta(j), phi(j), deltam(j), deltap(j)
;

binary variables
yu(j), yl(j), y0(j)
;

**************** INITIALIZING PARAMETRIC VARIABLES AND SETS ****************************

bigM = 1000;
epsilon = 0.0001;

scalar counter /0/;

****************************************************************************************

******************* DEFINITION OF EQUATIONS *********************************************
*** OUTER PROBLEM                                                                       *
***     outer = Outer objective - Maximize V(product)                                   *
***     outer1 = Sum of all interventions should not exceed k                           *
***     outer2 = Each reaction can be considered for only one of Up Regulation          *
***              Down regulation or Knockout                                            *
***     outer3 = Equating the Inner Primal and Dual objective functions                 *
***     outer4 -                                                                        *
***     outer19 = Linearinzing constraints (using bigM method)                          *
*************************************************************************************************
*********** INNER PROBLEM (PRIMAL)                                                              *
***********     primal = Primal objective function (Minimize V(product))                        *
***********     primal1 = Stoichiometric Constraint                                             *
***********     primal2 = Constraint that imparts the up-regulations                            *
***********     primal3 = Constraint that imparts the down-regulations                          *
***********     primal4 = Global upper bound for the fluxes                                     *
***********     primal5 = Global lower bound for the fluxes                                     *
***********     primal6 = Contrained reactions                                                  *
*************************************************************************************************
*********** INNER PROBLEM (DUAL)                                                                *
***********     dual = Dual objective function                                                  *
***********     dual1 = Dual constraint corr. to not constrained variables in primal problem    *
***********     dual2 = Dual constraint corr. to constrained variable in primal problem         *
***********     dual1 = Dual constraint corr. to V(target) variable in primal problem           *
*************************************************************************************************

equations

primal1
primal2
primal3
primal4
primal5
primal6
primal

dual
dual1
dual2
dual3

outer
outer1
outer2
outer3
outer4
outer5
outer6
outer7
outer8
outer9
outer10
outer11
outer12
outer13
outer14
outer15
outer16
outer17
outer18
outer19
outer20
outer21
outer22
outer23
;

************************ OUTER PROBLEM **********************************************

outer..                                 z - sum(j$(target(j)), v(j)) =e= 0;

outer1..                                sum(j, yu(j) + yl(j) + y0(j) ) =e= k;
outer2(j)..                             yu(j) + yl(j) + y0(j) =l= 1;
outer3..                                sum(j$(target(j)), v(j)) =e= sum(j$(constraint(j) and not target(j)),b(j)*mu(j)) + sum(j, wtheta(j)*phenomin(j) + theta(j)*LB(j) - wtheta(j)*LB(j) )
                                        - sum(j, wphi(j)*phenomax(j) + phi(j)*UB(j) - wphi(j)*UB(j) ) + sum(j, deltap(j)*LB(j) - wdeltap(j)*LB(j) - deltam(j)*UB(j) + wdeltam(j)*UB(j) );

outer4(j)..                             wtheta(j) =l= bigM*yu(j);
outer5(j)..                             wtheta(j) =g= -bigM*yu(j);
outer6(j)..                             wtheta(j) =l= theta(j) + bigM*(1-yu(j) );
outer7(j)..                             wtheta(j) =g= theta(j) - bigM*(1-yu(j) );

outer8(j)..                             wphi(j) =l= bigM*yl(j);
outer9(j)..                             wphi(j) =g= -bigM*yl(j);
outer10(j)..                            wphi(j) =l= phi(j) + bigM*(1-yl(j) );
outer11(j)..                            wphi(j) =g= phi(j) - bigM*(1-yl(j) );

outer12(j)..                            wdeltap(j) =l= bigM*y0(j);
outer13(j)..                            wdeltap(j) =g= -bigM*y0(j);
outer14(j)..                            wdeltap(j) =l= deltap(j) + bigM*(1-y0(j) );
outer15(j)..                            wdeltap(j) =g= deltap(j) - bigM*(1-y0(j) );

outer16(j)..                            wdeltam(j) =l= bigM*y0(j);
outer17(j)..                            wdeltam(j) =g= -bigM*y0(j);
outer18(j)..                            wdeltam(j) =l= deltam(j) + bigM*(1-y0(j) );
outer19(j)..                            wdeltam(j) =g= deltam(j) - bigM*(1-y0(j) );

outer20(index)..                        sum(j, matrix1(index, j)*yu(j)) + sum(j, matrix2(index, j)*yl(j)) + sum(j, matrix3(index, j)*y0(j)) =l= k - 1;
outer21(j)$(excluded_U(j))..            yu(j) =e= 0;
outer22(j)$(excluded_L(j))..            yl(j) =e= 0;
outer23(j)$(excluded_K(j))..            y0(j) =e= 0;

*************************************************************************************
********************* PRIMAL PROBLEM (INNER) ****************************************

        primal1(i)..                                     sum(j, (S(i,j)*v(j))) =e= 0;
        primal2(j)..                                     v(j) =g= phenomin(j)*yu(j) + LB(j)*(1-yu(j) );
        primal3(j)..                                     v(j) =l= phenomax(j)*yl(j) + UB(j)*(1-yl(j) );
        primal4(j)..                                     v(j) =g= LB(j)*(1-y0(j) );
        primal5(j)..                                     v(j) =l= UB(j)*(1-y0(j) );
        primal6(j)$(constraint(j) and not target(j))..   v(j) =e= b(j);

*************************************************************************************
********************* DUAL PROBLEM (INNER) ******************************************

        dual1(j)$(not constraint(j) and not target(j))..                          sum(i, lambda(i)*S(i,j) ) + theta(j) - phi(j) + deltap(j) - deltam(j) =e= 0;
        dual2(j)$(constraint(j) and not target(j))..             sum(i, lambda(i)*S(i, j)) + mu(j) + theta(j) - phi(j) + deltap(j) - deltam(j) =e= 0;
        dual3(j)$(target(j))..                                   sum(i, lambda(i)*S(i, j)) + theta(j) - phi(j) + deltap(j) - deltam(j) =e= 1;
*************************************************************************************

************ GLOBAL UPPER AND LOWER BOUNDS ******************************************


v.lo(j) = LB(j);
v.up(j) = UB(j);

********************************
yu.fx(j)$(not mustu(j) ) = 0;
yl.fx(j)$(not mustl(j) ) = 0;
*************************************************************************************

model bilevel
/
primal1
primal2
primal3
primal4
primal5
primal6

dual1
dual2
dual3

outer
outer1
outer2
outer3
outer4
outer5
outer6
outer7
outer8
outer9
outer10
outer11
outer12
outer13
outer14
outer15
outer16
outer17
outer18
outer19
outer20
outer21
outer22
outer23
/
;


*solve primalproblem using lp minimizing zprimal;

*solve dualproblem using lp maximizing zdual;

options iterlim = 1000000;
bilevel.optfile = 1;
z.l = 0;

counter = 0;
while((counter lt nMax),

solve bilevel using mip maximizing z;
         if (bilevel.modelstat eq 1,
                 counter = counter + 1;
                 matrix1(index, j)$(ord(index) = counter and yu.l(j) gt 0.99) = 1;
                 matrix2(index, j)$(ord(index) = counter and yl.l(j) gt 0.99) = 1;
                 matrix3(index, j)$(ord(index) = counter and y0.l(j) gt 0.99) = 1;

                 matrix1_flux(index, j)$(ord(index) = counter and yu.l(j) gt 0.99) = v.l(j);
                 matrix2_flux(index, j)$(ord(index) = counter and yl.l(j) gt 0.99) = v.l(j);
                 matrix3_flux(index, j)$(ord(index) = counter and y0.l(j) gt 0.99) = v.l(j);

                 objective(index)$(ord(index) = counter) = z.l;

         );
        if (bilevel.modelstat ne 1,
                counter = nMax;
        );
);
