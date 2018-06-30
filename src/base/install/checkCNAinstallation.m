function status = checkCNAinstallation(printLevel)
% checks the installation of CellNetAnalyzer
%
% USAGE:
%    status = checkCNAinstallation(printLevel)
%
% INPUT:
%
%    printLevel:    verbose level (default: 1)
%
% OUTPUT:
%
%   status:         Boolean if CellNetAnalyzer is installed properly
%

    global CBTDIR

    % set default printLevel
    if nargin < 1
        printLevel = 1;
    end

    % make sure that the interface functions from the submodule are used
    fullPath = which('CNAcobra2cna');
    if isempty(strfind(fullPath, 'external'))
        addpath(genpath([CBTDIR filesep 'external' filesep 'analysis' filesep 'CnaCobraInterface']));
    end

    % check if CNA is available and convert the model
    if ~isempty(which('startcna'))
        cnaPath = fileparts(which('startcna'));

        % remove the external libSBML folder from CNA and use COBRA.binary
        cnaLibSBMLdir = [cnaPath filesep 'code' filesep 'ext' filesep 'libSBML'];
        if ~isempty(strfind(path, [cnaLibSBMLdir, pathsep]))
            rmpath(genpath(cnaLibSBMLdir));
        end

        % remove the external efmtool folder from CNA
        cnaEFMtoolDir = [cnaPath filesep 'code' filesep 'ext' filesep 'efmtool'];
        if ~isempty(strfind(path, [cnaEFMtoolDir, pathsep]))
            rmpath(genpath(cnaEFMtoolDir));
        end

        % print a sucess message
        if printLevel > 0
            fprintf(' > CellNetAnalyzer is installed properly.\n');
        end
        status = true;
    else
        if printLevel > 0
            fprintf(' > CellNetAnalyzer is not properly installed or not added to the MATLAB path.\n');
        end
        status = false;
    end
end