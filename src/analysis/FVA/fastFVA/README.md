# fastFVA

fastFVA is an efficient implementation of flux variability analysis written in C++ that uses the CPLEX solver. The routines are called via the Matlab function `fastFVA`. This function employs `parfor` for further speedup if the parallel toolbox has been installed. You can specify the number of cores or use the `setWorkerCount` helper function.

If you use fastFVA in your work, please cite:

> *S. Gudmundsson, I. Thiele, Computationally efficient Flux Variability Analysis, BMC Bioinformatics201011:489* available [here](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-489).
>

IBM has recently made CPLEX available through their Academic Initiative program which allows academic institutions to obtain a full version of the software without charge.
