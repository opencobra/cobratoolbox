# FastSL
Fast-SL is an efficient algorithm to identify synthetic lethal gene/reaction sets in  genome-scale metabolic models.

### Requirements
To perform synthetic lethality analysis using Fast-SL the following tools are needed:

1. [COBRA Toolbox](http://opencobra.github.io/cobratoolbox/)
2. A linear programming (LP) solver such as [Gurobi](http://www.gurobi.com/), [GLPK](https://www.gnu.org/software/glpk/) etc.
3. CPLEX v12.0 or higher for the parallel version of Fast-SL. For the serial version of Fast-SL, any COBRA-supported solver can be used. [CPLEX is available free for academics from IBM](https://ibm.onthehub.com/WebStore/ProductSearchOfferingList.aspx?srch=cplex)

### Citing Fast-SL
If you use Fast-SL in your work, please cite
>Aditya Pratapa, Shankar Balachandran and Karthik Raman (2015) "Fast-SL: An efficient algorithm to identify synthetic lethal sets in metabolic networks" _Bioinformatics_ **31**:3299–3305 [doi:10.1093/bioinformatics/btv352](https://academic.oup.com/bioinformatics/article/31/20/3299/195638/Fast-SL-an-efficient-algorithm-to-identify)

__________________________________________________________________________

### Description of Available files

##### `Models/`
'Eco_iAF1260.mat' :: SBML model of *Escherichia coli* - *i*AF1260 used for analysis 

'eliList_eco_iAF1260.mat' :: List of reactions eliminated for lethality analysis- Exchange, ATPM etc

'Mtu_iNJ661.mat' :: SBML model of *Mycobacterium Tuberculosis* used for analysis 

'eliList_mtu_iNJ661.mat' :: List of reactions eliminated for lethality analysis

'STM_v1.0.mat' :: SBML model of *Salmonella* Typhimurium used for analysis 

'eliList_sty_STM_v1.0.mat' :: List of reactions eliminated for lethality analysis

##### `Sample Results/`
Reaction and Gene lethals for the models used

__________________________________________________________________________
### Documentation (MATLAB)

```Matlab
>>help fastSL

fastSL(model,cutoff,order,eliList,atpm) 

  

  INPUT

  model (the following fields are required - others can be supplied)       

    S            Stoichiometric matrix

    b            Right hand side = dx/dt

    c            Objective coefficients

    lb           Lower bounds

    ub           Upper bounds

    rxns         Reaction Names

  OPTIONAL

  cutoff         cutoff percentage value for lethality.Default is 0.01.

  order          Order of SLs required.Default order is 2. Max value 3.

  eliList        List of reactions to be ignored for lethality

  analysis:Exchange Reactions, ATPM etc.

  atpm           ATPM Reaction Id in model.rxns if other than 'ATPM'

  OUTPUT

  A 'modelname_Rxn_Lethals.mat' file containing all the lethal reaction sets of the order specified



>>example_fastSL

>>example_fastSLgenes
```
### Acknowledgements
* High Performance Computing Environment, P G Senapathy Centre for Computing Resources, IIT Madras
* Grant BT/PR4949/BRB/10/1048/2012 from the [Department of Biotechnology, Government of India](https://www.dbtindia.nic.in/).
* [Initiative for Biological Systems Engineering](https://ibse.iitm.ac.in/)
* [Robert Bosch Centre for Data Science and Artificial Intelligence (RBCDSAI)](https://rbcdsai.iitm.ac.in/)

<img title="IBSE logo" src="https://github.com/RBC-DSAI-IITM/rbc-dsai-iitm.github.io/blob/master/images/IBSE_logo.png" height="200" width="200"><img title="RBC-DSAI logo" src="https://github.com/RBC-DSAI-IITM/rbc-dsai-iitm.github.io/blob/master/images/logo.jpg" height="200" width="351">
