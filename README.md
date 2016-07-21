<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [Introduction](#introduction)   
- [Compatibility](#compatibility)   
- [Folder Structure and Files](#folder-structure-and-files)   
- [Installation](#installation)   
   - [Linux](#linux)   
   - [Windows](#windows)   
   - [Generation of MEX files](#generation-of-mex-files)   
- [Test and Example](#test-and-example)   
- [Usage](#usage)   

<!-- /MDTOC -->

Introduction
============

fastFVA is an efficient implementation of flux variability analysis written in C++.
CPLEX  is called cplexFVAnew.c. The routines are called via the Matlab function fastFVA. This function employs PARFOR for further speedup if the parallel toolbox has been installed. You can either use the MATLABPOOL command directly to specify the number of cores/CPUs
or use the SetWorkerCount helper function.

If you use fastFVA in your work, please cite

*S. Gudmundsson, I. Thiele, Computationally efficient Flux Variability Analysis, ...*

IBM has recently made CPLEX available through their Academic Initiative program
which allows academic institutions to obtain a full version of the software without charge.

Compatibility
============

- Matlab R2014a fully tested on UNIX and DOS Systems
- Matalb R2015b throws compatibility errors with CPLEX 12.6.3 on DOS Systems

The version of fastFVA only supports the CPLEX solver. The code has been tested for the CPLEX 12.6.2 and 12.6.3 versions. Download the appropriate version of CPLEX (32-bit or 64-bit) from IBM and make sure the license is valid. A particular interface, such as TOMLAB are not needed in order to run fastFVA. Please note that only 64-bit versions are supported. In order to run the code on 32-bit systems, the appopropriate MEX files would need to be generated.

Folder Structure and Files
==========================

The following files are supplied

| Filename               | Purpose                                                 |
| -----------------------|---------------------------------------------------------|
| cleanFiles.m           | *Removes files in ./logFiles and ./results*             |
| cplexFVAnew.c          | *Source code for the CPLEX version of fastFVA*          |
| cplexFVAnew.mexa64     | *Linux MEX file; CPLEX 12.6.2, 64-bit Matlab R2014a*    |
| cplexFVAnew.mexmaci64  | *macOS MEX file; CPLEX 12.6.2, 64-bit Matlab R2014a*    |
| cplexFVAnew.mexw64     | *Windows MEX file; CPLEX 12.6.2, 64-bit Matlab R2014a*  |
| CPLEXParamSetFVA.m     | *Parameter set for CPLEX*                               |
| fastFVA.m              | *Matlab wrapper for the MEX function*                   |
| generateMexFile.m      | *Generate the MEX file of the .c file*                  |
| **logFiles**           | *Folder for storing log files*                          |
| README.md              | *this file*                                             |
| **results**            | *Results folder, empty in the original folder*          |
| SetWorkerCount.m       | *Helper function to configure the number of processes*  |

Installation
============

In order to generate the MEX file, you must have a compiler installed that is compatible with your MATLAB release. You need to install a C++ compiler if you haven't done so already, e. g. The Microsoft Visual Studio Express 2008 compiler which is available free of charge. Depending on your Matlab version, you must verify the supported compiler [here](http://www.mathworks.com/support/compilers).

## Linux

Make sure to have `gcc` installed. You  can download it from [here](https://gcc.gnu.org/wiki/InstallingGCC).

## Windows

You may find information on how to install `gcc` [here](http://preshing.com/20141108/how-to-install-the-latest-gcc-on-windows/). For R2015b, it is recommended to have the Microsoft Windows SDK for Windows 7 and .NET Framework 4 installed. The compiler and SDK can be downloaded from [here](https://www.microsoft.com/en-us/download/details.aspx?id=8279). Other compilers that are compatible with R2015b can be found [here](http://www.mathworks.com/support/sysreq/files/SystemRequirements-Release2015b_SupportedCompilers.pdf). In order to have the compiler set up properly, you must start MATLAB and run
```
mex -setup
```
## Generation of MEX files

In order to generate the MEX file, please run_exps
```
>> generateMexFile
```

Test and Example
================

In order to test your installation and whether your MEX file is properly compiled, you may run
```
exampleFVA.m
```
in the folder `pCOBRA/drivers/exampleFVA`.

Usage
=====

 [minFlux,maxFlux] = fastFVA(model, optPercentage, objective, solver)

 Solves LPs of the form for all v_j:   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; max/min v_j  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; subject to S*v = b  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; lb <= v <= ub  

 **Inputs:**  
   model             Model structure  

     Required fields  

       S            Stoichiometric matrix  
       b            Right hand side = 0  
       c            Objective coefficients  
       lb           Lower bounds  
       ub           Upper bounds  

     Optional fields  

       A            General constraint matrix  
       csense       Type of constraints, csense is a vector with elements  
                    'E' (equal), 'L' (less than) or 'G' (greater than).  

     If the optional fields are supplied, following LPs are solved  
                    max/min v_j  
                    subject to Av {'<=' | '=' | '>='} b  
                                lb <= v <= ub  

   optPercentage    Only consider solutions that give you at least a certain  
                    percentage of the optimal solution (default = 100  
                    or optimal solutions only)  
                    
   objective        Objective ('min' or 'max') (default 'max')  

   solver           'cplex' or 'glpk' (default 'glpk')  

 **Outputs:  **
- minFlux   Minimum flux for each reaction  
- maxFlux   Maximum flux for each reaction  
- optsol    Optimal solution (of the initial FBA)  
- ret       Zero if success  


Please report problems to laurent.heirendt@uni.lu

---
Last updated: July 2016.
