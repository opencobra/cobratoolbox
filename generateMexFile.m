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
  CPLEXpath     = '$HOME/Applications/IBM/ILOG/CPLEX_Studio1263/cplex';
else
  CPLEXpath     = 'C:\Progra~1\IBM\ILOG\CPLEX_Studio1263\cplex';
end

% Determine the include path
if isunix == 1 || ismac == 1
  include       = [CPLEXpath '/include/ilcplex'];
else
  include       = [CPLEXpath '\include\ilcplex'];
end

% Set the CPLEX library path
if isunix == 1 && ismac ~= 1
  lib           = [CPLEXpath '/lib/x86-64_linux/static_pic'];
elseif ismac == 1
  lib           = [CPLEXpath '/lib/x86-64_osx/static_pic'];
else
  lib           = [CPLEXpath '\lib\x64_windows_vs2013\stat_mda'];
end

% The library file is the same for *nix systems
if isunix == 1 || ismac == 1
  library       = [lib '/libcplex.a'];
else
  library       = [lib '\cplex1263.lib ' lib '\ilocplex.lib'];
end

% Generation of MEX string with compiler options
CFLAGS        = '-O3 -lstdc++ -xc++ -Wall -Werror -march=native -save-temps -shared-libgcc -v '; %
cmd           = ['-largeArrayDims CFLAGS="\$CFLAGS" -I' include ' ' filename ' ' library];

% Generation of the MEX file
eval(['mex ' cmd]);
