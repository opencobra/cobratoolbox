%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Purpose: Compile a MEX file based on the C file of fastFVA
% Author: Laurent Heirendt, LCSB
% Date: April/July 2016
%
% Requirements: Installation of CPLEX 12.6.2 or 12.6.3
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename      = 'cplexFVAc.c';

% Set the CPLEX file path
if isunix == 1 && ismac ~= 1
  CPLEXpath     = '/opt/ibm/ILOG/CPLEX_Studio1262/cplex';
elseif ismac == 1
  CPLEXpath = '$HOME/Applications/IBM/ILOG/CPLEX_Studio1263/cplex';
end
include       = [CPLEXpath '/include/ilcplex']; %%sometimes as well without /ilcplex

% Set the CPLEX library path
if isunix == 1 && ismac ~= 1
  lib           = [CPLEXpath '/lib/x86-64_linux/static_pic'];
elseif ismac == 1
  lib           = [CPLEXpath '/lib/x86-64_osx/static_pic'];
end

% The library file is the same for *nix systems
library       = [lib '/libcplex.a'];

% Generation of MEX string with compiler options
CFLAGS        = '-O3 -lstdc++ -xc++ -Wall -Werror -march=native -save-temps -shared-libgcc -v '; %
cmd           = ['-largeArrayDims CFLAGS="\$CFLAGS" -I' include ' ' filename ' ' library];
eval(['mex ' cmd]);
