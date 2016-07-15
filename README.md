

The following files are supplied

- README.txt		This file
- fastFVA.m		Matlab wrapper for the mex functions
- run_exps.m		Performs the experiments described in the paper
- SetWorkerCount.m	Helper function to configure the number of processes
- cplexFVAc.c		Source code for the CPLEX version of fastFVA
<!--- - glpkInterface/glpkFVAcc.cpp		Source code for the GLPK version of fastFVA --->

The following precompiled Matlab executables are supplied
<!---
win/glpkFVAcc.mexw32	32-bit Windows, built with GLPK-4.42, Matlab 2009b and Windows XP
win/glpkFVAcc.mexw64	64-bit Windows, built with GLPK-4.42, Matlab 2009b and Windows 7
win/cplexFVAc.mexw32  32-bit Windows, built with CPLEX 12.1, Matlab 2009b and Windows XP
win/cplexFVAc.mexw64  64-bit Windows, built with CPLEX 12.1, Matlab 2009b and Windows 7
linux/glpkFVAcc.mexa64	64-Bit Linux, built with GLPK-4.43, Matlab 2009b and Linux Ubuntu 14+
--->

- cplexFVAc.mexa64  64-Bit Linux, built with CPLEX 12.6, Matlab R2014a and Linux Ubuntu 14.04+


Introduction
============

fastFVA is an efficient implementation of flux variability analysis written in C++.
There are two versions of the code. One uses IBM's CPLEX solver and the other
uses the open source GLPK. The CPLEX version is called cplexFVAc. It requires
the cplex121.dll to be present in the same directory and a valid license for CPLEX(*).
The GPLK version is called glpkFVAcc.cpp and requires glpk_4_42.dll (or a later version)
to be present in the same directory.

The routines are called via the Matlab function fastFVA. This function employs
PARFOR for further speedup if the parallel toolbox has been installed. You can
either use the MATLABPOOL command directly to specify the number of cores/CPUs
or use the SetWorkerCount helper function.

If you use fastFVA in your work, please cite
S. Gudmundsson, I. Thiele, Computationally efficient Flux Variability Analysis, ...


(*) IBM has recently made CPLEX available through their Academic Initiative program
which allows academic institutions to obtain a full version of the software without charge.


Compiling
=========

1) Windows

You need to install a C++ compiler if you haven't done so already, e. g.
The Microsoft Visual Studio Express 2008 compiler which is available
free of charge. Depending on your Matlab version, see

http://www.mathworks.com/support/compilers/R2009b/
http://www.mathworks.com/support/compilers/R2010a/

for more details on compiler options.

The instructions below refer to the Visual Studio Express compiler.

----

In order to generate the MEX file on Windows, you must have a compiler installed that is compatible with your MATLAB release.

For R2015b, it is recommended to have the Microsoft Windows SDK for Windows 7 and .NET Framework 4 installed. The compiler can SDK can be downloaded from [here](https://www.microsoft.com/en-us/download/details.aspx?id=8279). Other compilers that are compatible with R2015b can be found [here](http://www.mathworks.com/support/sysreq/files/SystemRequirements-Release2015b_SupportedCompilers.pdf). In order to have the compiler set up properly, you must start MATLAB and run
```
mex -setup
```

1.1 GLPK version
----------------

Download WinGLPK from http://sourceforge.net/projects/winglpk/

In the following it is assumed that GLPK has been installed in C:\glpk-4.42

For Win32
>> mex -IC:\glpk-4.42\include\ glpkFVAcc.cpp C:\glpk-4.42\w32\glpk_4_42.lib

For Win64
>> mex -largeArrayDims -IC:\glpk-4.42\include\ glpkFVAcc.cpp C:\glpk-4.42\w64\glpk_4_42.lib


1.2 CPLEX version
-----------------

Download the appropriate version of CPLEX (32-bit or 64-bit) from IBM and make sure the license is valid.

In the following it is assumed that CPLEX is installed in C:\ILOG\CPLEX

For Win32
>> mex -IC:\ILOG\CPLEX121\include\ilcplex cplexFVAc.c C:\ILOG\CPLEX121\lib\x86_windows_vs2008\stat_mda\cplex121.lib C:\ILOG\CPLEX121\lib\x86_windows_vs2008\stat_mda\ilocplex.lib

For Win64
>> mex -largeArrayDims -IC:\ILOG\CPLEX121\include\ilcplex cplexFVAc.c C:\ILOG\CPLEX121\lib\x64_windows_vs2008\stat_mda\cplex121.lib C:\ILOG\CPLEX121\lib\x64_windows_vs2008\stat_mda\ilocplex.lib

On Server Winx64

>> mex -largeArrayDims -O -D_LP64 -IC:\Progra~1\IBM\ILOG\CPLEX_Studio1251\cplex\include\ilcplex cplexFVAc.c C:\Progra~1\IBM\ILOG\CPLEX_Studio1251\cplex\lib\x64_windows_vs2012\stat_mda\cplex1251.lib C:\Progra~1\IBM\ILOG\CPLEX_Studio1251\cplex\lib\x64_windows_vs2012\stat_mda\ilocplex.lib


2) Linux

2.1 GLPK version
----------------

Download and install GLPK from http://www.gnu.org/software/glpk/

32-bit
>> mex glpkFVAcc.cpp -lglpk -lm

64-bit
>> mex -largeArrayDims glpkFVAcc.cpp -lglpk -lm

2.2 CPLEX version
-----------------

64 - bit
>> use the supplied version of generateMexFile

Usage
=====

 [minFlux,maxFlux] = fastFVA(model,optPercentage,objective, solver)

 Solves LPs of the form for all v_j: max/min v_j
                                     subject to S*v = b
                                     lb <= v <= ub
 Inputs:
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

 Outputs:
   minFlux   Minimum flux for each reaction
   maxFlux   Maximum flux for each reaction
   optsol    Optimal solution (of the initial FBA)
   ret       Zero if success


Please report problems to laurent.heirendt@uni.lu


How may I install gcc on Windows?
=====

http://preshing.com/20141108/how-to-install-the-latest-gcc-on-windows/

Last updated: July 2016.
