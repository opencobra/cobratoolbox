%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Purpose: Compile a MEX file based on the C file of fastFVA
% Author: Laurent Heirendt, LCSB
% Date: April/July 2016
%
% Requirements: Installation of CPLEX 12.6.2 or 12.6.3
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global CBTDIR
global ILOG_CPLEX_PATH
global ENV_VARS
global SOLVERS

% run initCobraToolbox when not yet initialised
if isempty(SOLVERS)
    ENV_VARS.printLevel = false;
    initCobraToolbox;
    ENV_VARS.printLevel = true;
end

cplexInstalled = changeCobraSolver('ibm_cplex');

if ~cplexInstalled
    error('CPLEX is not yet installed. Please follow the instructions here: ');
else
    % detect the version of CPLEX

    % define the name of the source code
    filename      = [CBTDIR filesep 'external' filesep 'fastFVAmex' filesep 'cplexFVA.c'];

    % Set the CPLEX file path
    index = strfind(ILOG_CPLEX_PATH, 'cplex') + 5;
    CPLEXpath = ILOG_CPLEX_PATH(1:index);

    % Determine the include path
    include       = [CPLEXpath filesep 'include' filesep 'ilcplex'];

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
      library       = [lib filesep 'libcplex.a'];
    else
      library       = [lib filesep 'cplex1263.lib ' lib filesep 'ilocplex.lib'];
    end

    % Generation of MEX string with compiler options
    CFLAGS        = '-O3 -lstdc++ -xc++ -Wall -Werror -march=native -save-temps -shared-libgcc -v '; %
    cmd           = ['-largeArrayDims CFLAGS="\$CFLAGS" -I' include ' ' filename ' ' library];

    % Generation of the MEX file
    eval(['mex ' cmd]);
end
