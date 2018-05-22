function models = loadUncModels(modPath, organisms, objre, printLevel)
% This function loads and unconstrains metabolic models from a specific folder
%
% USAGE:
%
%   models = loadUncModels(modPath, organisms, objre)
%
% INPUTS:
%   organisms:           nx1 cell array cell array with names of organisms in the study
%   modPath:             char with path of directory where models are stored
%   objre:               char with reaction name of objective function of organisms
%   printLevel:          Verbose level (default: printLevel = 1)
%
% OUTPUT:
%   models:              nx1 cell array cell array with models of organisms in the study
%
% .. Author: Federico Baldini 2017-2018

    if ~exist('modPath', 'var') || ~exist(modPath, 'dir')  % check if the modPath is set
        error('modPath is not defined. Please set the path of the model directory.');
    else
        if ~exist(modPath, 'dir')
            error(['modPath (' modPath ') does not exist.']);
        end
    end

    % check if the organisms are defined
    if ~exist('organisms', 'var') || isempty(organisms)
        error('organisms are not defined. Please check your input file.');
    end

    if ~exist('objre', 'var')
        objre = {'EX_biomass(e)'};
        warning(['The default objective (objre) has been set to ' objre{1}]);
    end

    % check if a printLevel is present
    if ~exist('printLevel', 'var')
        printLevel = 0;
    end

    % add an extra file separator if missing
    if strcmpi(modPath(end), filesep)
        modPath = modPath(1:end-1);
    end

    environment = getEnvironment();

    models = {[]};  % empty cell array to be filled with models
    for i = 1:length(organisms)

        restoreEnvironment(environment);

        % adding the file extension
        fileEnding = '';
        tmpOrganism = organisms(i, 1);
        tmpOrganism = tmpOrganism{1};
        if ~strcmpi(tmpOrganism(end-4:end), '.mat')
            fileEnding = '.mat';
        end

        ldm = readCbModel([modPath filesep tmpOrganism fileEnding]);

        % removing possible constraints of the bacs
        selExc = findExcRxns(ldm);
        Reactions2 = ldm.rxns(find(selExc));
        allex = Reactions2(strmatch('EX', Reactions2));
        biomass = allex(strmatch(objre, allex));
        finrex = setdiff(allex, biomass);
        ldm = changeRxnBounds(ldm, finrex, -1000, 'l');
        ldm = changeRxnBounds(ldm, finrex, 1000, 'u');

        % removing blocked reactions from the bacs
        %BlockedRxns = identifyFastBlockedRxns(ldm,ldm.rxns, printLevel);
        %ldm= removeRxns(ldm, BlockedRxns);
        %BlockedReaction = findBlockedReaction(ldm,'L2')
        
        
        % creating array with models as required as input from the following functions
        models(i, 1) = {ldm};
    end

end
