function [Cmodel, Tmodel, score, Stats] = compareCbModels(Cmodel, Tmodel, varargin)
% Calculate similarity of two Cb models. These models must
% be in a COBRA-like format. Called by `driveModelBorgifier`, calls `addComparisonInfo`, `compareMetInfo`, `optimalScores`, `mapMatch`, `buildRxnEquations`, `fixNames`.
%
% USAGE:
%
%    [Cmodel, Tmodel, score, Stats] = compareCbModels(Cmodel, Tmodel)
%
% INPUTS:
%    Cmodel:       Model to be compared to the template. In COBRA format.
%    Tmodel:       Template model. In COBRA format.
%
% OPTIONAL INPUTS:
%    'Verbose':    Print progress information. Also controls plotting.
%
% OUTPUTS:
%    Cmodel:       Appended Cb comparison model with additional information to
%                  facilitate comparison.
%    Tmodel:       Appended Cb template model with additional information to
%                  facilitate comparision.
%    score:        Every individual score, split by number of comparison factors.
%                  `Size = M x N x F`
%    Stats:        Structure of statistics. Including:
%
%                    * scoreTotal - `M x N` matrix of normalized (0 to 1) scores with `M` equal
%                      to the number of reactions in `Cmodel` and `N` equal to the
%                      number of reactions in `Tmodel`.
%
% NOTE:
%
%    Use `readCbModel` to create a COBRA model from a SBML formatted .xml or an
%    appropriate scipt to create the model from an .xls or other format.
%    Run script through `verifyModel` to make sure that is has all the correct
%    information for `compareCbModels`.
%
% Please cite:
% `Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale
% metabolic reconstructions with modelBorgifier. Bioinformatics
% (Oxford, England), 30(7), 1036?8`. http://doi.org/10.1093/bioinformatics/btt747
%
% ..
%    Edit the above text to modify the response to help addMetInfo
%    Last Modified by GUIDE v2.5 06-Dec-2013 14:19:28
%    This file is published under Creative Commons BY-NC-SA.
%
%    Correspondance:
%    johntsauls@gmail.com
%
%    Developed at:
%    BRAIN Aktiengesellschaft
%    Microbial Production Technologies Unit
%    Quantitative Biology and Sequencing Platform
%    Darmstaeter Str. 34-36
%    64673 Zwingenberg, Germany
%    www.brain-biotech.de

verbose = false ; % Declare oft used variables and set up scoring system and arrays.
if ~isempty(varargin)
    if sum(strcmp('Verbose', varargin))
        verbose = true ;
    end
end

nCrxns = length(Cmodel.rxns);
compCrxns = 1:nCrxns ; % Comparison C reactions
nTrxns = length(Tmodel.rxns) ; % Number of T reactions

% Names of all models currently in Tmodel.
modelNames = fieldnames(Tmodel.Models) ;

% Score values. H = hit, M = miss.
ScoreVal = struct('rxnNameH', [10, 1],  'rxnNameM', [-5, 2], ...
                  'rxnNameLH', [10, 3], 'rxnNameLM', [-5, 4], ...
                  'ecH', [10, 5],       'ecM', [-5, 6], ...
                  'rxnKEGGH', [10, 7],  'rxnKEGGM', [-5, 8], ...
                  'subH', [5, 11],      'subM', [-1, 12], ...
                  'grH', [5, 13],       'grM', [-5, 14], ... % Gene. Not used.
                  'metNumH', [1, 15],   'metNumM', [-5, 16], ...
                  'metStoH', [1, 17],   'metStoM', [-5, 18], ...
                  'metNameH', [10, 19], 'metNameM', [-1, 20], ...
                  'metFormH', [10, 21], 'metFormM', [-1, 22], ...
                  'metKEGGH', [10, 23], 'metKEGGM', [-1, 24], ...
                  'metSEEDH', [10, 25], 'metSEEDM', [-1, 26], ...
                  'reacNumH', [1, 27],  'reacNumM', [-1, 28], ...
                  'reacStoH', [1, 29],  'reacStoM', [-1, 30], ...
                  'prodNumH', [1, 31],  'prodNumM', [-1, 32], ...
                  'prodStoH', [1, 33],  'prodStoM', [-1, 34], ...
                  'rxnCompH', [5, 35],  'rxnCompM', [-5, 36], ...
                  'rxnSEEDH', [10, 37], 'rxnSEEDM', [-3, 38] , ...
                  'metBonus', [10, 39], ...
                  'rxnNet', [10, 40]) ;

% Preallocate score matrix.
score = zeros(nCrxns, nTrxns, length(fieldnames(ScoreVal)), 'int8') ;

%% Add additional comparison information to models.
tic
Cmodel = addComparisonInfo(Cmodel) ;
Tmodel = addComparisonInfo(Tmodel) ;
if verbose
    fprintf('Adding comparison information time = %d.\n', toc)
end

%% Score a reaction from Cmodel vs all reactions in Tmodel
% Name Match
tic
for i = compCrxns
    % Match Cmodel.rxns against Tmodel.rxnIDs.
    matchString = strcat('(:|\<)', Cmodel.rxns(i),'(\||\>)') ;
    match = regexpi(Tmodel.rxnID, matchString) ;
    % Find nonzero entries.
    match = ~cellfun(@isempty, match) ;
    % Allocate scores using logical indexing.
    score(i,match,ScoreVal.rxnNameH(2)) = ...
        score(i,match,ScoreVal.rxnNameH(2)) + ScoreVal.rxnNameH(1) ;
    score(i,~match,ScoreVal.rxnNameM(2)) = ...
        score(i,~match,ScoreVal.rxnNameM(2)) + ScoreVal.rxnNameM(1) ;

    % Long Name Match
    % Concatenate name from .rxns to front of longname.
    Cmodel.rxnNamesFix{i} = [Cmodel.rxns{i} '|' Cmodel.rxnNamesFix{i}] ;
    % For each long name (Cmodel may have multiple entries seperated by
    % '|'), find in Tmodel.rxnNamesFix.
    pipePos = [ 0 strfind(Cmodel.rxnNamesFix{i}, '|') ...
                length(Cmodel.rxnNamesFix{i}) + 1 ] ;
    matchSum = zeros(length(Tmodel.rxns), 1) ;
    for j = 1:length(pipePos) - 1
        nowname = Cmodel.rxnNamesFix{i}(pipePos(j) + 1:pipePos(j +1 ) - 1) ;
        match = regexpi(Tmodel.rxnNamesFix, nowname) ;
        match = ~cellfun('isempty', match(:)) ;
        matchSum = matchSum + match ;
    end
    % Only allocate scores for 1 match per Rxn in Tmodel.
    match = logical(matchSum) ;
    score(i, match, ScoreVal.rxnNameLH(2)) = ...
        score(i, match, ScoreVal.rxnNameLH(2)) + ScoreVal.rxnNameLH(1) ;
    score(i, ~match, ScoreVal.rxnNameLM(2)) = ...
        score(i, ~match, ScoreVal.rxnNameLM(2)) + ScoreVal.rxnNameLM(1) ;
end
if verbose
    fprintf('Name match time = %d.\n', toc)
end

% EC Number match. There is not always an EC Number
tic
for i = compCrxns
    if ~isempty(Cmodel.rxnECNumbers{i}) && ...
            ~isempty(find(~cellfun(@isempty, Tmodel.rxnECNumbers), 1))
        pipePos = [0 strfind(Cmodel.rxnECNumbers{i}, '|') ...
                   length(Cmodel.rxnECNumbers{i}) + 1] ;
        matchSum = zeros(length(Tmodel.rxns), 1) ;
        for j = 1:length(pipePos) - 1
            nowEC = Cmodel.rxnECNumbers{i}(pipePos(j) + 1:pipePos(j + 1) - 1);
            match = regexpi(Tmodel.rxnECNumbers, nowEC) ;
            match = ~cellfun('isempty', match) ;
            matchSum = matchSum + match ;
        end
        match = logical(matchSum) ;
        score(i, match, ScoreVal.ecH(2)) = ...
            score(i, match, ScoreVal.ecH(2)) + ScoreVal.ecH(1) ;
        score(i, ~match, ScoreVal.ecM(2)) = ...
            score(i, ~match, ScoreVal.ecM(2)) + ScoreVal.ecM(1) ;
        % Give points back to reactions in Tmodel that don't have EC.
        noEC = cellfun(@isempty, Tmodel.rxnECNumbers) ;
        score(i, noEC, ScoreVal.ecM(2)) = ...
            score(i, noEC, ScoreVal.ecM(2)) - ScoreVal.ecM(1) ;
    end
end
if verbose
    fprintf('EC match time = %d.\n', toc)
end

% Reaction KEGGID match.
tic
for iRxn = compCrxns
    if ~isempty(Cmodel.rxnKEGGID{iRxn}) && ...
            ~isempty(find(~cellfun(@isempty, Tmodel.rxnKEGGID), 1))
        pipePos = [0 strfind(Cmodel.rxnKEGGID{iRxn}, '|') ...
                   length(Cmodel.rxnKEGGID{iRxn}) + 1] ;
        matchSum = zeros(length(Tmodel.rxns), 1) ;
        for jID = 1:length(pipePos) - 1
            nowID = Cmodel.rxnKEGGID{iRxn}(pipePos(jID) + 1:pipePos(jID + 1) - 1);
            match = regexpi(Tmodel.rxnKEGGID, nowID) ;
            match = ~cellfun('isempty', match) ;
            matchSum = matchSum + match ;
        end
        % Assign points. Once per rxn, even if there are multiple matches.
        match = logical(matchSum) ;
        score(iRxn, match, ScoreVal.rxnKEGGH(2)) = ...
            score(iRxn, match, ScoreVal.rxnKEGGH(2)) + ScoreVal.rxnKEGGH(1) ;
        score(iRxn, ~match, ScoreVal.rxnKEGGM(2)) = ...
            score(iRxn, ~match, ScoreVal.rxnKEGGM(2)) + ScoreVal.rxnKEGGM(1);
        % Give points back to reactions in Tmodel that don't have IDs.
        noKEGGID = cellfun(@isempty, Tmodel.rxnKEGGID) ;
        score(iRxn, noKEGGID, ScoreVal.rxnKEGGM(2)) = ...
            score(iRxn, noKEGGID, ScoreVal.rxnKEGGM(2)) - ...
            ScoreVal.rxnKEGGM(1) ;
    end
end
if verbose
    fprintf('Reaction KEGG ID match time = %d.\n', toc)
end

% Reaction SEED ID match.
tic
for iRxn = compCrxns
    if ~isempty(Cmodel.rxnSEEDID{iRxn}) && ...
            ~isempty(find(~cellfun(@isempty, Tmodel.rxnSEEDID), 1))
        pipePos = [0 strfind(Cmodel.rxnSEEDID{iRxn}, '|') ...
                   length(Cmodel.rxnSEEDID{iRxn}) + 1] ;
        matchSum = zeros(length(Tmodel.rxns), 1) ;
        for jID = 1:length(pipePos) - 1
            nowID = Cmodel.rxnSEEDID{iRxn}(pipePos(jID) + 1:pipePos(jID + 1) - 1) ;
            match = regexpi(Tmodel.rxnSEEDID, nowID) ;
            match = ~cellfun('isempty', match) ;
            matchSum = matchSum + match ;
        end
        % Assign points. Once per rxn, even if there are multiple matches.
        match = logical(matchSum) ;
        score(iRxn, match, ScoreVal.rxnSEEDH(2)) = ...
            score(iRxn, match, ScoreVal.rxnSEEDH(2)) + ScoreVal.rxnSEEDH(1) ;
        score(iRxn, ~match, ScoreVal.rxnSEEDM(2)) = ...
            score(iRxn, ~match, ScoreVal.rxnSEEDM(2)) + ScoreVal.rxnSEEDM(1);
        % Give points back to reactions in Tmodel that don't have IDs.
        noSEEDID = cellfun(@isempty, Tmodel.rxnSEEDID) ;
        score(iRxn, noSEEDID, ScoreVal.rxnSEEDM(2)) = ...
            score(iRxn, noSEEDID, ScoreVal.rxnSEEDM(2)) - ...
            ScoreVal.rxnSEEDM(1) ;
    end
end
if verbose
    fprintf('Reaction SEED ID match time = %d.\n', toc)
end

% Subsystem Match. There may not always be a subsystem, but there should
% never be multiple subsystems in Cmodel.
tic
for i = compCrxns
    if ~isempty(Cmodel.subSystems{i})
        match = regexpi(Tmodel.subSystems, Cmodel.subSystems(i)) ;
        match = ~cellfun(@isempty,match);
        score(i, match, ScoreVal.subH(2)) = ...
            score(i, match, ScoreVal.subH(2)) + ScoreVal.subH(1) ;
        score(i, ~match, ScoreVal.subM(2)) = ...
            score(i, ~match, ScoreVal.subM(2)) + ScoreVal.subM(1) ;
    end
end
if verbose
    fprintf('Subsystem match time = %d.\n', toc)
end

% Number and stoic of metabolites, reactants, products match.
tic
for i = compCrxns
    % Total metabolite number.
    % Hits.
    score(i, Cmodel.metNums(i, 1) == Tmodel.metNums(:, 1), ...
          ScoreVal.metNumH(2)) = ...
        score(i, Cmodel.metNums(i, 1) == Tmodel.metNums(:, 1), ...
              ScoreVal.metNumH(2)) + ScoreVal.metNumH(1) ;
    % Misses.
    score(i, Cmodel.metNums(i, 1) ~= Tmodel.metNums(:, 1), ...
          ScoreVal.metNumM(2)) = ...
        score(i, Cmodel.metNums(i, 1) ~= Tmodel.metNums(:, 1), ...
              ScoreVal.metNumM(2)) + ScoreVal.metNumM(1) ;

    % Total stoich.
    score(i, Cmodel.metNums(i, 2) == Tmodel.metNums(:, 2), ...
          ScoreVal.metStoH(2)) = ...
        score(i, Cmodel.metNums(i, 2) == Tmodel.metNums(:, 2), ...
              ScoreVal.metStoH(2)) + ScoreVal.metStoH(1) ;
    score(i, Cmodel.metNums(i, 2) ~= Tmodel.metNums(:, 2), ...
          ScoreVal.metStoM(2)) = ...
        score(i, Cmodel.metNums(i, 2) ~= Tmodel.metNums(:, 2), ...
              ScoreVal.metStoM(2)) + ScoreVal.metStoM(1) ;

    % Reactant number.
    score(i, Cmodel.metNums(i, 3) == Tmodel.metNums(:, 3), ...
          ScoreVal.reacNumH(2)) = ...
        score(i, Cmodel.metNums(i, 3) == Tmodel.metNums(:, 3), ...
              ScoreVal.reacNumH(2)) + ScoreVal.reacNumH(1) ;
    score(i, Cmodel.metNums(i, 3) ~= Tmodel.metNums(:, 3), ...
          ScoreVal.reacNumM(2)) = ...
        score(i, Cmodel.metNums(i, 3) ~= Tmodel.metNums(:, 3), ...
              ScoreVal.reacNumM(2)) + ScoreVal.reacNumM(1) ;

    % Reactant stoich.
    score(i,Cmodel.metNums(i, 4) == Tmodel.metNums(:, 4), ...
          ScoreVal.reacStoH(2)) = ...
        score(i, Cmodel.metNums(i, 4) == Tmodel.metNums(:, 4), ...
          ScoreVal.reacStoH(2)) + ScoreVal.reacStoH(1) ;
    score(i, Cmodel.metNums(i, 4) ~= Tmodel.metNums(:, 4), ...
          ScoreVal.reacStoM(2)) = ...
        score(i, Cmodel.metNums(i, 4) ~= Tmodel.metNums(:, 4), ...
          ScoreVal.reacStoM(2)) + ScoreVal.reacStoM(1) ;

    % Product number.
    score(i, Cmodel.metNums(i, 5) == Tmodel.metNums(:, 5), ...
          ScoreVal.prodNumH(2)) = ...
        score(i, Cmodel.metNums(i, 5) == Tmodel.metNums(:, 5), ...
              ScoreVal.prodNumH(2)) + ScoreVal.prodNumH(1) ;
    score(i, Cmodel.metNums(i, 5) ~= Tmodel.metNums(:, 5), ...
          ScoreVal.prodNumM(2)) = ...
        score(i, Cmodel.metNums(i, 5) ~= Tmodel.metNums(:, 5), ...
          ScoreVal.prodNumM(2)) + ScoreVal.prodNumM(1) ;

    % Product stoich.
    score(i, Cmodel.metNums(i, 6) == Tmodel.metNums(:, 6), ...
          ScoreVal.prodStoH(2)) = ...
        score(i, Cmodel.metNums(i, 6) == Tmodel.metNums(:, 6), ...
              ScoreVal.prodStoH(2)) + ScoreVal.prodStoH(1) ;
    score(i, Cmodel.metNums(i, 6) ~= Tmodel.metNums(:, 6), ...
          ScoreVal.prodStoM(2)) = ...
        score(i, Cmodel.metNums(i, 6) ~= Tmodel.metNums(:, 6), ...
          ScoreVal.prodStoM(2)) + ScoreVal.prodStoM(1) ;
end
if verbose
    fprintf('Metabolte number and stoich match time = %d.\n', toc)
end

% Match compartments involved in reaction
tic
for i = compCrxns
    matchArray = strcmpi(Cmodel.rxnComp{i}, Tmodel.rxnComp) ;
    score(i, matchArray, ScoreVal.rxnCompH(2)) = ...
        score(i, matchArray, ScoreVal.rxnCompH(2)) + ScoreVal.rxnCompH(1) ;
    score(i, ~matchArray, ScoreVal.rxnCompM(2)) = ...
        score(i, ~matchArray, ScoreVal.rxnCompM(2)) + ScoreVal.rxnCompM(1) ;
end
if verbose
    fprintf('Reaction compartment match time = %d.\n', toc)
end

% local network topology
tic
score(:, :, ScoreVal.rxnNet(2)) = mapMatch(Cmodel, Tmodel, 'noSeed') ;
if verbose
    fprintf('Network topology match time = %d.\n', toc)
end

% Metabolite ID/name/formula/KEGG/SEED match.
tic
% Type of information used for matching arrays (stack).
metType = {'I' 'N' 'F' 'K' 'S'} ;
% Metabolite information category
metCatH = {'metNameH' 'metNameH' 'metFormH' 'metKEGGH' 'metSEEDH'} ;
metCatM = {'metNameM' 'metNameM' 'metFormM' 'metKEGGM' 'metSEEDM'} ;
h = waitbar(0,'Processing metabolites.') ;
for i = compCrxns
    % Allocate scoring arrays in a structure
    for iStack = 1:length(metType)
    matchStack.(metType{iStack}) = zeros(nTrxns, 3) ;
    end
    for j = 1:nTrxns
        for iStack = 1:length(metType)
        metMatch = compareMetInfo(Cmodel.rxnMetNames{i, iStack}, ...
                                  Tmodel.rxnMetNames{j, iStack})  ;
        matchStack.(metType{iStack})(j, 1) = sum(metMatch) ;
        matchStack.(metType{iStack})(j, 2) = length(metMatch) ;
        matchStack.(metType{iStack})(j, 3) = Tmodel.metNums(j,1) ;
        end
    end

    % Allocate points
    for iStack = 1:length(metType)
        % Give bonus when all the metabolite names match.
        score(i,logical((matchStack.(metType{iStack})(:, 1) == ...
                         matchStack.(metType{iStack})(:, 2)) .* ...
                        (matchStack.(metType{iStack})(:, 1) == ...
                         matchStack.(metType{iStack})(:, 3))), ...
              ScoreVal.metBonus(2)) = ...
        score(i,logical((matchStack.(metType{iStack})(:, 1) == ...
                         matchStack.(metType{iStack})(:, 2)) .* ...
                        (matchStack.(metType{iStack})(:, 1) == ...
                         matchStack.(metType{iStack})(:, 3))), ...
        ScoreVal.metBonus(2)) + ScoreVal.metBonus(1);

    % Allocate scores for matches and no matches, divided by number of
    % metabolites in the reaction.
        % Add for matches.
        score(i, :, ScoreVal.(metCatH{iStack})(2)) = ...
            score(i, :, ScoreVal.(metCatH{iStack})(2)) + ...
            int8(((ScoreVal.(metCatH{iStack})(1) .* ...
            matchStack.(metType{iStack})(:, 1))') ./ Cmodel.metNums(i, 1)) ;
        % Substract for misses.
        score(i, :, ScoreVal.(metCatM{iStack})(2)) = ...
            score(i, :, ScoreVal.(metCatM{iStack})(2)) + ...
            int8((ScoreVal.(metCatM{iStack})(1) .* ...
            (matchStack.(metType{iStack})(:, 2) - ...
            matchStack.(metType{iStack})(:, 1))') ./ Cmodel.metNums(i, 1)) ;
    end

    % Count of metabolite.
    try
        waitbar(i / nCrxns, h, ['modelBorgifier: comparing metabolites of reaction ' num2str(i) ...
                                ' of ' num2str(nCrxns)])
    catch
        disp(i)
    end
end
try close(h) ; end
if verbose
    fprintf('Met name match time = %d.\n', toc)
end

%% Colapse the 3D score to scoreTotal and get stats.
% optimalScores takes the models and score as globals.
global CMODEL TMODEL SCORE
CMODEL = Cmodel ;
TMODEL = Tmodel ;
SCORE = score ;
Stats = optimalScores ;


%% Graph data.
if verbose
    hold on
    figure(1)
    subplot(2, 1, 1)
    hist(Stats.scoreTotal(:), 100) % Converting to column matrix is faster.
    title('Normalized score frequency')
    xlabel('Score')
    ylabel('Frequency')
    subplot(2, 2, 3)
    hist(Stats.bestMatch, 100)
    title('Frequency of scores of best match per reaction')
    xlabel('Score')
    ylabel('Frequency');
    subplot(2, 2, 4)
    imagesc(Stats.scoreTotal)
    colormap('bone')
    title('Matching scores')
    xlabel('Template rxn')
    ylabel('Compared rxn')
    hold off
end

end


%% Subfunctions
% Extracts information from the models for comparison.
function Model = addComparisonInfo(Model)
nRxns = length(Model.rxns) ;

Model.rxnNamesFix = fixNames(Model.rxnNames) ;
Model.rxnComp = cell(nRxns, 1) ;
Model.metNums = zeros(nRxns, 6) ;
Model.rxnMetNames = cell(nRxns, 3) ;

% Figure out what compartments are in the model.
compNames = {''} ;
for iMet = 1:length(Model.mets)
    nowComp = Model.mets{iMet}(end - 2:end) ;
    if ~strcmpi(nowComp, compNames)
        if isempty(compNames{1})
            % First compartment found.
            compNames{1} = nowComp ;
        else
            % Additional compartments.
            compNames{length(compNames) + 1, 1} = nowComp ;
        end
    end
end
compNames = sort(compNames) ;

% generate standardized reaction equation strings for comparison of
% compartments.
m2 = buildRxnEquations(Model) ;
rxnEquationsWithComp = m2.rxnEquations ;
clear m2 ;

for iRxn = 1:nRxns
    % Determine involved compartments for each reaction.
    comp = '' ;
    for iC = 1:length(compNames)
        if strfind(rxnEquationsWithComp{iRxn}, compNames{iC})
           comp = [comp compNames{iC}] ;
        end
    end
    Model.rxnComp{iRxn} = comp ;

    % Determine metabolite number, total stoich, reactant number, reactant
    % total stoich, product number, product total stoich.
    Model.metNums(iRxn, 1) = length(find(Model.S(:, iRxn))) ;
    Model.metNums(iRxn, 2) = sum(full(abs(Model.S(:, iRxn)))) ;
    Model.metNums(iRxn, 3) = length(find(Model.S(:, iRxn) < 0)) ;
    Model.metNums(iRxn, 4) = abs(sum(full(Model.S(:, iRxn) < 0))) ;
    Model.metNums(iRxn, 5) = length(find(Model.S(:, iRxn) > 0)) ;
    Model.metNums(iRxn, 6) = sum(full(Model.S(:, iRxn) > 0)) ;

    % Find metabolite IDs, names, formulas, KEGGIDs, and SEEDIDs
    nowMetPos = find(Model.S(:, iRxn)) ;
    metIDs = cell(1) ;
    metNames = cell(1) ;
    metForms = cell(1) ;
    metKEGGs = cell(1) ;
    metSEEDs = cell(1) ;
    for j = 1:length(nowMetPos)
        nowMetID = Model.metID{nowMetPos(j)} ;
        nowMetName = Model.metNames{nowMetPos(j)} ;
        nowMetForm = Model.metFormulas{nowMetPos(j)} ;
        nowMetKEGG = Model.metKEGGID{nowMetPos(j)} ;
        nowMetSEED = Model.metSEEDID{nowMetPos(j)} ;
        metIDs{j, 1} = nowMetID(1:end - 3) ; % Remove compartment.
        metNames{j, 1} = nowMetName ;
        metForms{j, 1} = nowMetForm ;
        metKEGGs{j, 1} = nowMetKEGG ;
        metSEEDs{j, 1} = nowMetSEED ;
    end
    % Put placeholder for lacking information. The 'NONE' indentifier is
    % used by compareMetInfo function. Note, empty strings are carried
    % forward but are also not scored by compareMetInfo.
    if ~iscellstr(metIDs)
        metIDs = {'NONE'};
    end
    if ~iscellstr(metNames)
        metNames = {'NONE'};
    end
    if ~iscellstr(metForms)
        metForms = {'NONE'};
    end
    if ~iscellstr(metKEGGs)
        metKEGGs = {'NONE'};
    end
    if ~iscellstr(metSEEDs)
        metSEEDs = {'NONE'};
    end
    Model.rxnMetNames{iRxn, 1} = metIDs ;
    Model.rxnMetNames{iRxn, 2} = metNames ;
    Model.rxnMetNames{iRxn, 3} = metForms ;
    Model.rxnMetNames{iRxn, 4} = metKEGGs ;
    Model.rxnMetNames{iRxn, 5} = metSEEDs ;
end
end


% Compares the metabolites names (or forumlas, KEGG IDs, etc) contained in
% two reactions. Used as a more robust substitute for ismember.
function metMatch = compareMetInfo(cMets, tMets)
cMetsNo = length(cMets) ;
metMatch = zeros(cMetsNo, 1) ;

for iMet = 1:cMetsNo
    if find(~cellfun(@isempty, regexpi(tMets, ...
            ['(^|:|\|)' cMets{iMet} '($|\|)'], 'ONCE')))
        if ~strcmpi(cMets{iMet}, 'NONE') && ~strcmpi(cMets{iMet}, '')
            metMatch(iMet) = 1 ;
        end
    end
end
end
