function generateMexFastFVA(rootPathCPLEX, printLevel)
%
% Purpose: Compile a MEX file based on the C file of fastFVA
% Author: Laurent Heirendt, LCSB
% Date: April/July 2016
%
% Requirements: Installation of CPLEX 12.6.2+
%

%printLevel: 0: mute
%            1: minimal output
%            2: all compilation info

global CBTDIR
global ILOG_CPLEX_PATH
global ENV_VARS
global SOLVERS

if nargin < 2
    printLevel = 1;
end

% run initCobraToolbox when not yet initialised
if isempty(SOLVERS)
    ENV_VARS.printLevel = false;
    initCobraToolbox;
    ENV_VARS.printLevel = true;
end

if nargin < 1 || isempty(rootPathCPLEX)
    % Set the CPLEX file path
    index = strfind(ILOG_CPLEX_PATH, 'cplex') + 4;
    rootPathCPLEX = ILOG_CPLEX_PATH(1:index);
end

cplexVersion = getCobraSolverVersion('ibm_cplex', printLevel, rootPathCPLEX);

% save the userpath
originalUserPath = path;

% try to set the ILOG cplex solver
addpath(rootPathCPLEX);

if exist(rootPathCPLEX, 'dir') == 7
    cplexInstalled = true;
else
    cplexInstalled = false;
end

% Determine the include path
include       = [rootPathCPLEX filesep 'include' filesep 'ilcplex'];

libraryExists = false;

if exist(include, 'dir') ~= 7
    error(['The directory ' include ' does not exist. Please install the CPLEX solver as explained here.']);
else
    % set the CPLEX library path
    if isunix == 1 && ismac ~= 1
        lib           = [rootPathCPLEX filesep 'lib/x86-64_linux/static_pic'];
    elseif ismac == 1
        lib           = [rootPathCPLEX filesep 'lib/x86-64_osx/static_pic'];
    else
        lib           = [rootPathCPLEX filesep 'lib\x64_windows_vs2013\stat_mda'];
    end

    % check if the library directory exist
    if exist(lib, 'dir') ~= 7
        error(['The CPLEX library ' lib ' does not exist. Please install the CPLEX solver as explained here.']);
    else
        if isunix == 1 || ismac == 1
            library       = [lib filesep 'libcplex.a'];  % The library file is the same for *nix systems
        else
            library       = ['"' lib filesep 'cplex' cplexVersion '.lib" "' lib filesep 'ilocplex.lib"'];
        end

        % check if the library file exist
        if exist(lib, 'dir') ~= 7
            error(['The required CPLEX library file ' library ' does not exist. Please install the CPLEX solver as explained here: https://opencobra.github.io/cobratoolbox/docs/solvers.html.']);
        else
            libraryExists = true;
        end
    end
end

if cplexInstalled && libraryExists

    % run the mex setup first in order to make sure that the MEX environment is configured properly
    compVerboseMode = '';
    if printLevel > 1
        compVerboseMode = ' -v'
    end
    eval(['mex -setup c' compVerboseMode]);

    % define the name of the source code
    filename      = [CBTDIR filesep 'external' filesep 'fastFVAmex' filesep 'cplexFVA.c'];

    % Generation of MEX string with compiler options
    CFLAGS        = '-O3 -lstdc++ -xc++ -Wall -Werror -march=native -save-temps -shared-libgcc -v ';
    cmd           = ['-output cplexFVA' cplexVersion ' -largeArrayDims CFLAGS="\$CFLAGS" -I"' include '" "' filename '" ' library];

    if printLevel > 1
        fprintf('The compilation command is:\n');
        cmd
        fprintf('\n');
    end

    % define the current directory
    currentDir = pwd;

    tmpDir = [CBTDIR filesep '.tmp'];

    if ~exist(tmpDir, 'dir')
        mkdir(tmpDir);
    end

    cd(tmpDir)

    % generate the MEX file
    eval(['mex ' cmd]);

    % print a status message
    fprintf(['Location of binary MEX file: ' strrep(tmpDir, '\', '\\') '\n']);

    % restore the original path
    path(originalUserPath);
    addpath(originalUserPath);

    % add the temporary file
    addpath(genpath(tmpDir));

    % change back to the directory
    cd(currentDir);
else
    % restore the original path
    path(originalUserPath);
    addpath(originalUserPath);

    error('CPLEX is not installed. Please follow the instructions here: https://opencobra.github.io/cobratoolbox/docs/solvers.html');
end
