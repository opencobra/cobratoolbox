*********** OptForce *******************
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
***********************************************************************************************************
*       The objective of this code is to identify the fluxes that must decrease beyond
*       the flux ranges allowed in the wild-type strain. The wild-type flux ranges are stored as parametric
*       values in basemin(j) and basemax(j).
*
***********************************************************************************************************

**** OptForce code **********************************************
*       Notes:                                                  *
*       This code identifies the set of fluxes that             *
*       MUST be increased beyond its wild-type range            *
*       to cater to the overproduction.                         *
*****************************************************************

*****************************************************************
*       Related Links:                                          *
*       Refer text S2 from the following paper:                 *
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
        solprint = on
        mip = %solverName%;

sets

******************************** SET DEFINITIONS ***************************************
*
*       i               = set of all metabolites
*       j               = set of all reactions
*       constraint_flux = set of reactions (substrate uptake, biomass, product)
*                         included in the inner (primal) problem
*       must(j)         = refers to the set of all reactions that MUST increase / decrease
*                         beyond the wild-type flux ranges for overproduction
*       can(j)          = refers to the set of all reactions that CAN increase / decrease
*                         beyond the wild-type flux ranges for overproduction (i.e. fluxes
*                         of these reactions in wild-type overlap with overproducing ranges
*       dummy(j)        = set of reactions (alias)
*       mustu(j)        = set of reactions in the MustU set
*       mustl(j)        = set of reactions in the MustL set
*       must0(j)        = set of reactions in the Must0 set
*****************************************************************************************



i metabolites
$include "%myroot%Metabolites.txt"

j reactions
$include "%myroot%Reactions.txt"

$ONEMPTY

constraint_flux(j)
$include "%myroot%Constraints.txt"

must(j)
can(j)
dummy(j)
;

******************** List of Parameters *************************
*       s(i,j) = stoichiometric index of metabolite i in rxn j  *
*       LB(j)/UB(j) = Lower / Upper Bounds for fluxes           *
*       basemin(j) = min flux value of reaction j in WT         *
*       basemax(j) = max flux value of reaction j in WT         *                                      *
*       bigM = large number for linearizing                     *
*       vmin(j)/vmax(j) = stores the min / max values of fluxes *
*                         for the overproducing network         *
*****************************************************************

parameter

s(i,j)
basemin(j)
basemax(j)
b(j)
LB(j)
UB(j)

n
bigM
vmin(j), vmax(j)
findMustL
;

$if not set gdxin $set gdxin MtoGL
$GDXIN %myroot%%gdxin%
$LOAD s basemin basemax b lb ub
$GDXIN

must(j)=no;
can(j) = no;
can(j)$(basemin(j) ne 0) = yes;
can(j)$(basemax(j) ne 0) = yes;
findMustL = 1;

******************** List of Variables **************************
*       v(j) = flux value for the reaction j                    *
*       z = objective value                                     *
*       w(j) = linearizing variable for v(j)*y(j)               *
*       y(j) = (0,1) binary variable                            *
*              0, if rxn j is not in Must set                   *
*              1, otherwise                                     *
*       mu(j) = dual variable corr. to stoichiometry            *
*       thetap/thetam(j) = dual variables corr. to bounds       *
*                          for v(j) in the inner problem        *
*       zdual = dual objective value                            *
*       zprimal = primal objective value                        *
*****************************************************************

variables

v(j)
*Flux for reaction j

zprimal, zdual
*Primal and Dual objective values

lambda(i), mu(j)
*Variables in the Dual problem

w(j)
*Dual variable

z
*Objective of the outer problem

positive variables

thetam(j), thetap(j);
*Linearizing variables

binary variables
y(j);

scalar counter /0/;

bigM = 1000;

**************** DEFINITION OF EQUATIONS *********************************************
***** INNER PROBLEM
*****           primal_obj = Refers to the objective of the inner problem
*****                           (Minimize v(j) for MustL / Maximize v(j) for MustL
*****           primal1 =       Refers to the stoichiometric constraints
*****           primal2/3 =     Refers to global upper and lower bounds for fluxes
*****           primal4 =       Refers to the constraints
**************************************************************************************

***** DUAL PROBLEM
*****           dual_obj1 =     Refers to the dual obj. of inner problem (MustL)
*****           dualcon1 = Refers to dual constraints corresponding to all
*****                      reactions except constraint_flux(j)
*****           dualcon2 = Refers to dual constraints corresponding to all
*****                      reactions included as constraints in primal problem
**************************************************************************************

***** OUTER PROBLEM
*****           bilevel_obj_down = Objective of problem to identify MustL
*****           primal_dual_down = Combination of primal / dual obj. to solve MustL
*****           bilevelcon0 = Constraints that accounts for only overlap in the ranges
*****           bilevelcon1-4 = Linearizing constraints for v(j)*y(j)
*****           bilevelcon5 = cutoff value for the non-overlapping range difference
*****           must_bin = Restricts the algorithm to compare one rxn at a time
*****           blocked_bin = Same as must_bin
**************************************************************************************

equations

        dualcon1
        dualcon2
        dual_obj1

        primal1
        primal2
        primal3
        primal4
        primal_obj

        primal_dual_down
        bilevel_obj_down
        bilevelcon0_down
        bilevelcon1
        bilevelcon2
        bilevelcon3
        bilevelcon4
        bilevelcon5
        must_bin
        blocked_bin
;

********************* OUTER PROBLEM **************************************

bilevel_obj_down..              z =e= sum(j$(can(j) and not must(j) and not constraint_flux(j) ), basemin(j)*y(j) - w(j) );

primal_dual_down..              sum(j, w(j)) =e= sum(j$ (constraint_flux(j)), b(j)*mu(j)) + sum(j$ (not constraint_flux(j) ), thetap(j)*UB(j) - thetam(j)*LB(j) );

bilevelcon0_down..              sum(j$(can(j) and not must(j) and not constraint_flux(j) ), basemin(j)*y(j) - w(j) ) =g= 0.0;

bilevelcon1(j)..                w(j) =l= bigM*y(j);
bilevelcon2(j)..                w(j) =g= -bigM*y(j);
bilevelcon3(j)..                w(j) =l= v(j) + bigM*(1-y(j));
bilevelcon4(j)..                w(j) =g= v(j) - bigM*(1-y(j));
bilevelcon5..                   z =g= 0.5;

must_bin..                      sum(j$(can(j) and not must(j) and not constraint_flux(j) ), y(j) ) =e= 1;
blocked_bin..                   sum(j, y(j) ) =e= 1;

******************* INNER PROBLEM ****************************************

                primal_obj..                    zprimal =e= sum(j$(dummy(j) ), v(j));

                        primal1(i)..                            sum(j, (S(i,j)*v(j))) =e= 0;
                        primal2(j)$(not constraint_flux(j) )..  -v(j) =g= -UB(j);
                        primal3(j)$(not constraint_flux(j) )..  v(j) =g= LB(j);
                        primal4(j)$(constraint_flux(j) )..      v(j) =e= b(j);

**************************************************************************

******************* DUAL INNER PROBLEM ***********************************
* dual_obj1 => Refers to the objective for identifying MustL set of reactions

                dual_obj1..                     zdual =e= sum(j$ (constraint_flux(j)), b(j)*mu(j)) + sum(j$ (not constraint_flux(j) ), thetap(j)*UB(j) - thetam(j)*LB(j) );

                        dualcon1(j)$(not constraint_flux(j) )..                 sum(i, lambda(i)*S(i,j)) + thetap(j) - thetam(j) =e= y(j);
                        dualcon2(j)$(constraint_flux(j) )..                     sum(i, lambda(i)*S(i,j)) + mu(j) =e= y(j);

**************************************************************************

model primal
/
primal1
primal2
primal3
primal4
primal_obj
/
;

model dual1
/
dual_obj1
dualcon1
dualcon2
/
;

model bilevel_down
/
primal_dual_down
bilevel_obj_down
bilevelcon0_down
bilevelcon1
bilevelcon2
bilevelcon3
bilevelcon4
bilevelcon5
primal1
primal2
primal3
primal4
dualcon1
dualcon2
must_bin
blocked_bin
/
;

bilevel_down.optfile=1;
primal.optfile = 1;

********** CREATING A FILE TO WRITE THE RESULTS FROM GAMS ***************

************************************************************************

************************************************************************
******** CREATE A CONDITIONAL LOOP SUCH THAT THE OPTIMIZATION **********
******** PROBLEM IS RUN UNTIL WE REACH A POINT WHERE THERE IS **********
******** NO SOLUTION TO THE PROBLEM.                          **********
************************************************************************

counter=0;
while((counter = 0),
solve bilevel_down using mip maximizing z;
         if (bilevel_down.modelstat eq 1,
                must(j)$(y.l(j) = 1) = yes;
                vmax(j)$(y.l(j) = 1) = v.l(j);
                dummy(j) = no;
                dummy(j)$(y.l(j) = 1) = yes;
                solve primal using lp minimizing zprimal;
                vmin(j)$(dummy(j)) = zprimal.l;
         );
        if (bilevel_down.modelstat ne 1,
                counter = 1;
        );
);
***********************************************************************
