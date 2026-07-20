****************************** OptForce for Succinate synthesis in E. coli ********************************
*       Author: Sridhar Ranganathan
*       Date: August 16th, 2011
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
***********************************************************************************************************
*       The objective of this code (MustUL.gms) is used to identify the pair of fluxes, say j1 and j2, such
*       that one increases y the other decreases in value. The wild-type flux ranges are stored as parametric
*       values in basemin(j) and basemax(j). In addition, the set of reactions from MustU, MustL and MustZ
*       sets have to be pruned away from consideration in the pairs.
***********************************************************************************************************

**** OptForce code **********************************************
*       Notes:                                                  *
*       This code identifies the pair of reactions              *
*       one of whose flux values MUST be increased              *
*       to cater to the overproduction.                         *
****************************************************************

*****************************************************************
*       Related Links:                                          *
*       Refer text S2 and S3 from the following paper:          *
*       OptForce: An Optimization Procedure for Identifying All *
*       Genetic Manipulations Leading to Targeted               *
*       Overproductions, 2010, PLoS Comp. Biol.                 *
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

******************************** SET DEFINITIONS ***************************************
*
*       i               = set of all metabolites
*       j               = set of all reactions
*       constraint_flux = set of reactions (substrate uptake, biomass, product)
*                         included in the inner (primal) problem
*       must1(j)        = refers to the set of all reactions that MUST increase / decrease
*                         beyond the wild-type flux ranges for overproduction
*       can(j)          = refers to the set of all reactions that CAN increase / decrease
*                         beyond the wild-type flux ranges for overproduction (i.e. fluxes
*                         of these reactions in wild-type overlap with overproducing ranges
*       index           = to count the number of pairs for display purposes
*****************************************************************************************

sets

i metabolites
$include "%myroot%Metabolites.txt"

j reactions
$include "%myroot%Reactions.txt"

$ONEMPTY

constraint_flux(j)
$include "%myroot%Constraints.txt"

must1(j)
$include "%myroot%MustSetFirstOrder.txt"

excluded(j)
$include "%myroot%Excluded.txt"

can(j)
index /1*500/
;

******************** List of Parameters *************************
*       s(i,j) = stoichiometric index of metabolite i in rxn j  *
*       LB(j)/UB(j) = Lower / Upper Bounds for fluxes           *
*       basemin(j) = min flux value of reaction j in WT         *
*       basemax(j) = max flux value of reaction j in WT         *
*       M = large number for linearizing                        *
*       vmin(j)/vmax(j) = stores the min / max values of fluxes *
*                         for the overproducing network         *
*       matrix1/matrix2 = indexing matrices to store the        *
*               information about the pairs identified          *
*       n = counter for identifying the no. of pairs identified *
*****************************************************************

parameter

s(i,j)
basemin(j)
basemax(j)
b(j)
LB(j)
UB(j)

matrix1(index, j)
matrix2(index, j)
M
n
vmin(j), vmax(j)
findMustUL
;

$if not set gdxin $set gdxin MtoGUL
$GDXIN %myroot%%gdxin%
$LOAD s basemin basemax b lb ub
$GDXIN

can(j) = no;
can(j)$(basemin(j) ne 0) = yes;
can(j)$(basemax(j) ne 0) = yes;
M=2000;

matrix1(index, j) = 0;
matrix2(index, j) = 0;
findMustUL = 1;

******************** List of Variables **************************
*       v(j) = flux value for the reaction j                    *
*       z = objective value                                     *
*              if it is present in MustU set                    *
*       w1, w2(j) = linearizing variable for v(j)*y1(j)         *
*       y(j) = (0,1) binary variable                            *
*              0, if rxn j is not in Must set                   *
*              1, otherwise                                     *
*       Note: y1(j), y2(j) corresponds to the first and second  *
*       rxn in pair                                             *
*       mu(j) = dual variable corr. to stoichiometry            *
*       deltap/deltam(j)                                        *
*       thetap/thetam(j) = dual variables corr. to bounds       *
*                          for v(j) in the inner problem        *
*       zdual = dual objective value                            *
*       zprimal = primal objective value                        *
*       lambda(i) = Dual variable corr. to stoichiometry        *
*****************************************************************

variables
v(j), w1(j), w2(j), mu(j), lambda(i)
z, zprimal, zdual
;

positive variables
deltam(j), deltap(j)
thetam(j), thetap(j);

binary variables
y1(j), y2(j);

************** LIST OF SCALARS **********************************
*       counter = solution counter                              *
*****************************************************************

scalar counter /0/;

matrix1(index, j) = 0;
matrix2(index, j) = 0;

equations

        primal1
        primal2
        primal3
        primal4
        primal_obj

        dual1
        dual2
        dual3
        dual_obj

        outer_obj
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

        primal_dual
        must_set1
        must_set2
        con1
        con2
;

********************************************************************************************************************************
*****************************************       OUTER PROBLEM   ****************************************************************
*       MAXIMIZE [ ( V1 - V2) in overproducing network ] - [ (V1 - V2) in wild-type network ]
*       s.t.:   Identify one pair per run
*               Fluxes identified must not be in the MustU, MustL, MustX sets
*               Linearizing constraints
*               INNER PRIMAL PROBLEM <==> INNER DUAL PROBLEM
********************************************************************************************************************************

con1..                                                  sum(j$ (constraint_flux(j) ), y1(j) ) =e= 0;
con2..                                                  sum(j$ (constraint_flux(j) ), y2(j) ) =e= 0;
must_set1..                                             sum(j$ (must1(j) ), y1(j) ) =e= 0;
must_set2..                                             sum(j$ (must1(j) ), y2(j) ) =e= 0;
outer_obj..                                             z =e= sum(j$(can(j) and not constraint_flux(j) ), (w1(j)-w2(j) ) - (basemax(j)*y1(j)-basemin(j)*y2(j) ) );
outer1..                                                sum(j$(can(j) and not constraint_flux(j) ), y1(j) ) =e= 1;
outer2..                                                sum(j$(can(j) and not constraint_flux(j) ), y2(j) ) =e= 1;
outer3(index)..                                         sum(j, matrix1(index, j)*y1(j) ) + sum(j, matrix2(index, j)*y2(j) ) =l= 1;
outer14(index)..                                        sum(j, matrix1(index, j)*y2(j) ) + sum(j, matrix2(index, j)*y1(j) ) =l= 1;
outer4..                                                z =g= 0.1;
outer5(j)$(can(j))..                                    w1(j) =l= v(j) + M*(1-y1(j) );
outer6(j)$(can(j))..                                    w1(j) =g= v(j) - M*(1-y1(j) );
outer7(j)$(can(j))..                                    w1(j) =l= M*y1(j);
outer8(j)$(can(j))..                                    w1(j) =g= -M*y1(j);
outer9(j)$(can(j))..                                    w2(j) =l= v(j) + M*(1-y2(j) );
outer10(j)$(can(j))..                                   w2(j) =g= v(j) - M*(1-y2(j) );
outer11(j)$(can(j))..                                   w2(j) =l= M*y2(j);
outer12(j)$(can(j))..                                   w2(j) =g= -M*y2(j);
outer13(j)$(can(j))..                                   y1(j) + y2(j) =l= 1;
outer15(j)$(excluded(j))..                              y1(j) + y2(j) =e= 0;
*********************************************************************************************************************************

primal_dual..                                           sum(j$(can(j) and not constraint_flux(j) ), (w1(j)-w2(j) ) ) =e= sum(j$ (constraint_flux(j)), b(j)*mu(j)) + sum(j$ (can(j) ), deltam(j)*LB(j)-deltap(j)*UB(j) )+sum(j$ (not can(j) ), deltam(j)*LB(j)-deltap(j)*UB(j) );

*********************************************************************************************************************************
********************************       PRIMAL PROBLEM (INNER PROBLEM) ***********************************************************
*       MINIMIZE V1 - V2
*       s.t.:   Stoichiometry
*               Bounds on fluxes
*********************************************************************************************************************************

primal_obj..                                            zprimal =e= sum(j$(can(j) and not constraint_flux(j)), w1(j) - w2(j) );

        primal1(i)..                                            sum(j, (S(i,j)*v(j))) =e= 0;
        primal2(j)$(not constraint_flux(j) )..                  -v(j) =g= -UB(j);
        primal3(j)$(not constraint_flux(j) )..                  v(j) =g= LB(j);
        primal4(j)$(constraint_flux(j) )..                      v(j) =e= b(j);
*********************************************************************************************************************************

*********************************************************************************************************************************
********************************        DUAL PROBLEM (INNER PROBLEM) ************************************************************

dual_obj..                                              zdual =e= sum(j$ (constraint_flux(j)), b(j)*mu(j)) + sum(j$ (can(j) ), deltam(j)*LB(j)-deltap(j)*UB(j) )+sum(j$ (not can(j) ), deltam(j)*LB(j)-deltap(j)*UB(j) );

        dual1(j)$(constraint_flux(j) )..                        sum(i, lambda(i)*S(i,j) )+mu(j) =e= 0;
        dual2(j)$(can(j) and not constraint_flux(j) )..         sum(i, lambda(i)*S(i,j) )+deltam(j)-deltap(j) =e= y1(j)-y2(j);
        dual3(j)$(not can(j) )..                                sum(i, lambda(i)*S(i,j) )+deltam(j)-deltap(j) =e= 0;
*********************************************************************************************************************************

model primal
/
primal1
primal2
primal3
primal4
primal_obj
/
;

model dual
/
dual_obj
dual1
dual2
dual3
/
;

model bilevel
/
all
/
;

bilevel.optfile=1;

n=0;
while ((counter = 0),
solve bilevel using mip maximizing z;
        if (bilevel.modelstat eq 1,
                n = n + 1;
                matrix1(index, j)$(ord(index) = n and y1.l(j) = 1 and can(j)) = 1;
                matrix2(index, j)$(ord(index) = n and y2.l(j) = 1 and can(j)) = 1;
        );
        if (bilevel.modelstat ne 1,
                counter = 1;
        );
);

