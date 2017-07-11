function metScores = compareAllMets(Cmodel, Tmodel)
% Compares and scores similarity between all pairwise
% combinations of metabolites between two models. It is not however used
% by the main workflow.
%
% USAGE:
%
%    metScores = compareAllMets(Cmodel,Tmodel
%
% INPUTS:
%    Cmodel:      Comparison model.
%    Tmodel:      Template model.
%
% OUTPUTS:
%    metScore:    Matrix of scores of all pairwise comparisons.
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

nCmets = length(Cmodel.mets) ; % Declare variables and scoring structure.
nTmets = length(Tmodel.mets) ;

% Score values.
ScoreVal = struct('ID', [10,-1], ...
                  'compartment', [0,-100], ...
                  'name', [10,-1], ...
                  'formula', [10,-5], ...
                  'charge', [1,-1], ...
                  'KEGGID', [10,-5], ...
                  'SEEDID', [10,-5], ...
                  'ChEBIID', [10,-5], ...
                  'PubChemID', [10,-5], ...
                  'InChIString', [10,-5]) ;

% Score matrix.
metScores = zeros(nCmets, nTmets) ;

% Compartments of every met in T, used later for comparison.
tComp = cell(nTmets, 1) ;
for iMet = 1:nTmets
    tComp{iMet} = Tmodel.mets{iMet}(end - 2:end) ;
end


%% Compare cMet to tMets
h = waitbar(0, 'Comparing metabolites') ;
for iMet = 1:nCmets
    % metsID Match. There is always one ID.
    % Match name, removing '[.]' and add regular expression info.
    if ~isempty(regexp(Cmodel.mets{iMet}, '\[.\]', 'once'))
        name =  strcat('(\||\<)', Cmodel.mets{iMet}(1:end - 3), '(\>|\[|_|\|)') ;
    else
        name = strcat('(\||\<)', Cmodel.mets{iMet}, '(\>|\[|_|\|)') ;
    end
    % Match against IDs for all models.
    match = regexpi(Tmodel.metID, name) ;
    match = ~cellfun(@isempty, match) ;
    % Give scores.
    metScores(iMet, match) = metScores(iMet, match) + ScoreVal.ID(1) ;
    metScores(iMet, ~match) = metScores(iMet, ~match) + ScoreVal.ID(2) ;

    % Match against compartment for all models.
    match = strcmp(tComp, Cmodel.mets{iMet}(end - 2:end)) ;
    % Give scores.
    metScores(iMet, match) = metScores(iMet, match) + ScoreVal.compartment(1) ;
    metScores(iMet, ~match) = metScores(iMet, ~match) + ScoreVal.compartment(2) ;

    % metNames Match. There can be multiple names.
    fullname = Cmodel.metNames{iMet} ;
    pipePos = [0 strfind(fullname, '|') length(fullname) + 1] ;
    matchSum = zeros(length(Tmodel.mets), 1) ;
    for i = 1:length(pipePos) - 1
        name = fullname(pipePos(i) + 1:pipePos(i + 1) - 1) ;
        name = strcat('(\||\<)', name, '(\>|\|)') ;
        match = regexpi(Tmodel.metNames, name) ;
        match = ~cellfun('isempty', match) ;
        matchSum = matchSum + match ;
    end
    match = logical(matchSum) ;
    % Give scores.
    metScores(iMet, match) = metScores(iMet, match) + ScoreVal.name(1) ;
    metScores(iMet, ~match) = metScores(iMet, ~match) + ScoreVal.name(2) ;

    % metFormula Match. There will always be one Formula.
    name = strcat('(\||\<)', Cmodel.metFormulas{iMet}, '(\>|\|)') ;
    match = regexpi(Tmodel.metFormulas, name) ;
    match = ~cellfun(@isempty, match) ;
    % Give scores.
    metScores(iMet, match) = metScores(iMet, match) + ScoreVal.formula(1) ;
    metScores(iMet, ~match) = metScores(iMet, ~match) + ScoreVal.formula(2) ;

    % metCharge match. There will always be a charge.
    for i = 1:length(Tmodel.mets)
        if Cmodel.metCharge(iMet) == Tmodel.metCharge(i)
            metScores(iMet, i) = metScores(iMet, i) + ScoreVal.charge(1) ;
        else
            metScores(iMet, i) = metScores(iMet, i) + ScoreVal.charge(2) ;
        end
    end

    % metKEGGID Match. There may multiple KEGGIDs or no KEGGID.
    if ~isempty(Cmodel.metKEGGID{iMet})
        fullname = Cmodel.metKEGGID{iMet} ;
        pipePos = [ 0 strfind(fullname, '|') length(fullname) + 1 ] ;
        matchSum = zeros(length(Tmodel.mets), 1) ;
        for i = 1:length(pipePos) - 1
            name = fullname(pipePos(i) + 1:pipePos(i + 1) - 1) ;
            match = regexpi(Tmodel.metKEGGID, name) ;
            match = ~cellfun('isempty', match) ;
            matchSum = matchSum + match ;
        end
        match = logical(matchSum) ;
        % Give scores.
        metScores(iMet, match) = metScores(iMet, match) + ScoreVal.KEGGID(1) ;
        metScores(iMet, ~match) = metScores(iMet, ~match) + ScoreVal.KEGGID(2) ;
    end

    % metSEEDID Match. There may multiple SEEDIDs or no SEEDID.
    if ~isempty(Cmodel.metSEEDID{iMet})
        fullname = Cmodel.metSEEDID{iMet} ;
        pipePos = [ 0 strfind(fullname, '|') length(fullname) + 1] ;
        matchSum = zeros(length(Tmodel.mets), 1) ;
        for i = 1:length(pipePos) - 1
            name = fullname(pipePos(i) + 1:pipePos(i +1 ) - 1) ;
            match = regexpi(Tmodel.metSEEDID,name) ;
            match = ~cellfun('isempty', match) ;
            matchSum = matchSum + match ;
        end
        match = logical(matchSum) ;
        % Give scores.
        metScores(iMet, match) = metScores(iMet, match) + ScoreVal.SEEDID(1) ;
        metScores(iMet, ~match) = metScores(iMet, ~match) + ScoreVal.SEEDID(2) ;
    end
    % Update waitbar.
    waitbar(iMet / nCmets, h)
end
close(h)

%% Normalize scores.
% remove negative scores
metScores(metScores < 0) = 0 ;

if max(max(metScores)) > 0 % Avoid NaN.
    metScores = metScores - min(min(metScores)) ;
    metScores = metScores ./ max(max(metScores)) ;
else
    metScores = zeroes(size(metScores)) ;
end

% Find best matches.
[bestMatch, bestMatchIndex] = max(metScores, [], 2) ;

%% Graph data.
hold on
figure(1)
subplot(2,1,1)
hist(metScores(:), 100) % Converting to column matrix is faster.
title('Normalized score frequency')
xlabel('Score')
ylabel('Frequency')
subplot(2, 2, 3)
hist(bestMatch, 100)
title('Frequency of scores of best match per metabolite')
xlabel('Score')
ylabel('Frequency');
subplot(2, 2, 4)
imagesc(metScores)
colormap('bone')
title('Matching scores')
xlabel('Template met')
ylabel('Compared met')
hold off
