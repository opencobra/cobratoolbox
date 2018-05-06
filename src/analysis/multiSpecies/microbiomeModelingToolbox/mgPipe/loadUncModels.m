function models = loadUncModels(modPath, organisms, objre)
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
%
% OUTPUT:
%   models:              double indicating if object was found in the result folder
%
% .. Author: Federico Baldini 2017-2018

models = {[]};  % empty cell array to be filled with models
    parfor i = 1:length(organisms)
    % reading the models
        pn = strcat(modPath, organisms(i, 1), {'.mat'});  % complete path from which to read the models
        cpn = char(pn);  % conversion of the path in character
        ldm = readCbModel(cpn)
        % removing possible constraints of the bacs
        [selExc, selUpt] = findExcRxns(ldm);
        Reactions2 = ldm.rxns(find(selExc));
        allex = Reactions2(strmatch('EX', Reactions2));
        biomass = allex(strmatch(objre, allex));
        finrex = setdiff(allex, biomass);
        ldm = changeRxnBounds(ldm, finrex, -1000, 'l');
        ldm = changeRxnBounds(ldm, finrex, 1000, 'u');
        % removing blocked reactions from the bacs
        [BlockedRxns] = identifyFastBlockedRxns(ldm,ldm.rxns);
        ldm= removeRxns(ldm,BlockedRxns);
        % creating array with models as required as input from the following functions
        models(i, 1) = {ldm};
    end

end
