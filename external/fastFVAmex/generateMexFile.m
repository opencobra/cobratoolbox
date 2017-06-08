function generateMexFastFVA()
%
% Purpose: Compile a MEX file based on the C file of fastFVA
% Author: Laurent Heirendt, LCSB
% Date: April/July 2016
%
% Requirements: Installation of CPLEX 12.6.2 or 12.6.3
%

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

% Set the CPLEX file path
index = strfind(ILOG_CPLEX_PATH, 'cplex') + 4;
CPLEXpath = ILOG_CPLEX_PATH(1:index);

% try to set the ILOG cplex solver
cplexInstalled = changeCobraSolver('ibm_cplex');

% Determine the include path
include       = [CPLEXpath filesep 'include' filesep 'ilcplex'];

libraryExists = false;

if exist(include, 'dir') ~= 7
    error(['The directory ' include ' does not exist. Please install the CPLEX solver as explained here.']);
else
    % set the CPLEX library path
    if isunix == 1 && ismac ~= 1
      lib           = [CPLEXpath '/lib/x86-64_linux/static_pic'];
    elseif ismac == 1
      lib           = [CPLEXpath '/lib/x86-64_osx/static_pic'];
    else
      lib           = [CPLEXpath '\lib\x64_windows_vs2013\stat_mda'];
    end

    % check if the library directory exist
    if exist(lib, 'dir') ~= 7
        error(['The CPLEX library ' lib ' does not exist. Please install the CPLEX solver as explained here.']);
    else
        if isunix == 1 || ismac == 1
            library       = [lib filesep 'libcplex.a'];  % The library file is the same for *nix systems
        else
            library       = [lib filesep 'cplex1263.lib ' lib filesep 'ilocplex.lib'];
        end

        % check if the library file exist
        if exist(library, 'file') ~= 2
            error(['The required CPLEX library file ' library ' does not exist. Please install the CPLEX solver as explained here.']);
        else
            libraryExists = true;
        end
    end
end

if cplexInstalled && libraryExists

    cplexVersion = detectCPLEXversion(1);

    % run the mex setup first in order to make sure that the MEX environment is configured properly
    eval(['mex -setup c']);

    % define the name of the source code
    filename      = [CBTDIR filesep 'external' filesep 'fastFVAmex' filesep 'cplexFVA.c'];

    % Generation of MEX string with compiler options
    CFLAGS        = '-O3 -lstdc++ -xc++ -Wall -Werror -march=native -save-temps -shared-libgcc -v '; %
    cmd           = ['-largeArrayDims CFLAGS="\$CFLAGS" -I' include ' ' filename ' ' library];

    currentDir = pwd;

    binDir = [CBTDIR filesep 'binary' filesep computer('arch') filesep 'bin'];

    cd(binDir)

    % generate the MEX file
    eval(['mex ' cmd]);

    fprintf(['Location of binary MEX file: ' binDir '.\n']);

    % change back to the directory
    cd(currentDir);
else
    error('CPLEX is not yet installed. Please follow the instructions here: ');
end
