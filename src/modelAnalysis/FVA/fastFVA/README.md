# fastFVA

## Introduction

fastFVA is an efficient implementation of flux variability analysis written in C++. CPLEX  is called cplexFVAnew.c. The routines are called via the Matlab function fastFVA. This function employs PARFOR for further speedup if the parallel toolbox has been installed. You can either use the MATLABPOOL command directly to specify the number of cores/CPUs or use the `setWorkerCount` helper function.

If you use fastFVA in your work, please cite

*S. Gudmundsson, I. Thiele, Computationally efficient Flux Variability Analysis, BMC Bioinformatics201011:489* available [here](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-489).

IBM has recently made CPLEX available through their Academic Initiative program which allows academic institutions to obtain a full version of the software without charge.

## Compatibility

- Matlab R2014a fully tested on UNIX and DOS Systems
- Matlab R2015b throws compatibility errors with CPLEX 12.6.3 on DOS Systems
- Matlab R2016b and the MinGW64 compiler are not compatible with the CPLEX 12.6.3 library

The version of fastFVA only supports the CPLEX solver. The code has been tested for the CPLEX 12.6.2, 12.6.3, 12.7.0 and 12.7. versions. Download the appropriate version of CPLEX (32-bit or 64-bit) from IBM and make sure the license is valid. A particular interface, such as TOMLAB are not needed in order to run fastFVA. Please note that only 64-bit versions are supported. In order to run the code on 32-bit systems, the appropriate MEX files would need to be generated.

## Running fastFVA

### Basic Usage
```Matlab
[minFlux,maxFlux] = fastFVA(model, optPercentage, objective, solver)
```

 Solves LPs of the form for all v_j:   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; max/min v_j  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; subject to S*v = b  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; lb <= v <= ub  

**Inputs**  

| Argument       | Description              |
| ---------------|--------------------------|
| model          | Model structure          |
| optPercentage  | Only consider solutions that give you at least a certain percentage of the optimal solution (default = 100 or optimal solutions only)  |
| objective      | Objective ('min' or 'max') (default 'max')  |
| solverName     | 'ibm_cplex' (default)  |

*Required fields of the model argument*

| Field       | Description              |
| ------------|--------------------------|
| model.S     | Stoichiometric matrix    |
| model.b     | Right hand side = 0      |
| model.c     | Objective coefficients   |
| model.lb    | Lower bounds             |
| model.ub    | Upper bounds             |

*Optional fields of the model argument*

| Field        | Description              |
| -------------|--------------------------|
| model.A      | General constraint matrix  
| model.csense | Type of constraints, csense is a vector with elements 'E' (equal), 'L' (less than) or 'G' (greater than).       |

If the optional fields are supplied, following LPs are solved  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;max/min v_j  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;subject to Av {'<=' | '=' | '>='} b  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;lb <= v <= ub  


**Outputs**

| Argument        | Description                          |
| ----------------|--------------------------------------|
| minFlux         | Minimum flux for each reaction       |
| maxFlux         | Maximum flux for each reaction       |
| optsol          | Optimal solution (of the initial FBA)|  
| ret             | Zero if success                      |

### Advanced Usage
```
[minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT] = fastFVA(model,optPercentage,objective,solver,rxnsList,matrixAS,cpxControl,cpxAlgorithm, strategy);
```

**Optional Inputs**  

| Argument        | Description                                             |
| ----------------|---------------------------------------------------------|
| matrixAS        | 'A' or 'S' - coupled (A) or uncoupled (S)               |
| cpxControl      | Parameter set of CPLEX loaded externally                |
| cpxAlgorithm    | Choice of the solution algorithm within CPLEX           |
| rxnsList        | List of reactions to analyze (default all rxns, i.e.    |

**Optional Outputs**

| Argument        | Description                                             |
| ----------------|---------------------------------------------------------|
|   optsol        | Optimal solution (of the initial FBA)                   |
|   ret           | Zero if success                                         |
|   fbasol        | Initial FBA in FBASOL                                   |
|   fvamin        | matrix with flux values for the minimization problem    |
|   fvamax        | matrix with flux values for the maximization problem    |
