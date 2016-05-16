%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Purpose: Compile a MEX file based on the C file of fastFVA
% Author: Laurent Heirendt, LCSB
% Date: April 2001-2016
%
% Requirements: Installation of CPLEX 12.6.2 or 12.6.3
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename      = 'cplexFVAc.c';
CPLEXpath     = '/opt/ibm/ILOG/CPLEX_Studio1262/cplex';
include       = [CPLEXpath '/include/ilcplex']; %%sometimes as well without /ilcplex
lib           = [CPLEXpath '/lib/x86-64_linux/static_pic'];
library       = [lib '/libcplex.a'];
CFLAGS        = '-O3 -lstdc++ -xc++  -Wall -Werror -march=native -save-temps -shared-libgcc -v '; %
cmd           = ['-largeArrayDims CFLAGS="\$CFLAGS" -I' include ' ' filename ' ' library];
eval(['mex ' cmd]);
