function [matchScores, matchIndex, varargout] = findMetMatch(cMet, varargin)
% Finds find possible matches for a given metabolite.
% Called by `metCompare`, `metCompareGUI`, calls `stringSimilarityForward`.
%
% USAGE:
%
%    [matchScores, matchIndex, [hit]] = findMetMatch(cMet, [tRxn])
%
% INPUTS:
%    cMet:           Metabolite number (relative to CMODEL) metabolite to be compared.
%
% OPTIONAL INPUTS:
%    tRxn:           The reaction from `TMODEL` that this metabolite's reaction is matched.
%    CMODEL:         global input
%    TMODEL:         global input
%
% OUTPUTS:
%    matchScores:    Array of sorted, normalized scores for each met in `TMODEL`.
%    matchIndex:     Index of match in `TMODEL.mets`.
%
% OPTIONAL OUTPUTS:
%    hit:            Flag for if a match was found.
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

global CMODEL TMODEL  % Declare variables and scoring structure.

% Declare matched reaction, if any.
if ~isempty(varargin)
    tRxn = cell2mat(varargin(1)) ;
else
    tRxn = 0 ;
end

% Score values.
ScoreVal = struct('ID', [1, -0.1], ...
    'compartment', [0.01, -5], ... % wrong compartment will be down-weighted again further down
    'name', [1, -0.01], ...
    'formula', [1, -0.0], ...
    'charge', [.1, -.1], ...
    'KEGGID', [1, -0.01], ...
    'SEEDID', [1, -.01], ...
    'ChEBIID', [1, -0.01], ...
    'PubChemID', [1, -0.01], ...
    'InChIString', [1, -0.01]) ;

% Score array.
metScores = zeros(1, length(TMODEL.mets));

% Variable indicate if any significant matching information was found,
% ie name, formula, ID. If not, this flag indicates a new met should be
% declared.
hit = 0 ;

% Compartments of every met in T, used later for comparison.
tComp = cell(length(TMODEL.mets), 1) ;
for iMet = 1:length(TMODEL.mets)
    tComp{iMet} = TMODEL.mets{iMet}(end - 2:end) ;
end

%% Compare cMet to TMODEL
% metsID Match. There is always one ID.
% Match name, removing '[.]' and add regular expression info.
if ~isempty(regexp(CMODEL.mets{cMet}, '\[.\]', 'once'))
    name =  strcat('(\||\<)', CMODEL.mets{cMet}(1:end - 3), '(\>|\[|_|\|)') ;
else
    name = strcat('(\||\<)', CMODEL.mets{cMet}, '(\>|\[|_|\|)') ;
end
% Match against IDs for all models.
match = regexpi(TMODEL.metID,name) ;
match = ~cellfun(@isempty, match) ;
% give exptra points for exact matches
matchExact = regexpi(TMODEL.metID, [':' name '[']) ;
matchExact = ~cellfun(@isempty, matchExact) ;
% If at least one match was found, change flag and give scores.
if ~isempty(find(match, 1))
    hit = 1 ;
    metScores(match) = metScores(match) + ScoreVal.ID(1) ;
    metScores(matchExact) = metScores(matchExact) + ScoreVal.ID(1) ;
end

% Match against compartment for all models.
match = strcmp(tComp, CMODEL.mets{cMet}(end - 2:end)) ;
metScores(match) = metScores(match) + ScoreVal.compartment(1) ;
metScores(~match) = metScores(~match) + ScoreVal.compartment(2) ;

% metNames Match. There can be multiple names.
fullname = CMODEL.metNames{cMet} ;
if ~isempty(fullname)
    pipePos = [0 strfind(fullname, '|') length(fullname) + 1] ;
    matchSum = zeros(length(TMODEL.mets), 1) ;
    for i = 1:length(pipePos) - 1
        name = fullname(pipePos(i) + 1:pipePos(i + 1) - 1) ;
        name = strcat('(\||\<)', name, '(\>|\|)') ;
        match = regexpi(TMODEL.metNames, name) ;
        match = ~cellfun('isempty', match) ;
        matchSum = matchSum + match ;
    end
    match = logical(matchSum) ;
    if ~isempty(find(match, 1))
        hit = 1 ;
        metScores(match) = metScores(match) + ScoreVal.name(1) ;
    end
end

% metFormula Match. There will always be one Formula.
name = strcat('(\||\<)', CMODEL.metFormulas{cMet}, '(\>|\|)') ;
match = regexpi(TMODEL.metFormulas, name) ;
match = ~cellfun(@isempty, match) ;
if ~isempty(find(match, 1))
    hit = 1 ;
    metScores(match) = metScores(match) + ScoreVal.formula(1) ;
end

% metCharge match. There will always be a charge.
for i = 1:length(TMODEL.mets)
    if CMODEL.metCharge(cMet) == TMODEL.metCharge(i)
        metScores(i) = metScores(i) + ScoreVal.charge(1) ;
    end
end

% metKEGGID Match. There may multiple KEGGIDs or no KEGGID.
if ~isempty(CMODEL.metKEGGID{cMet})
    fullname = CMODEL.metKEGGID{cMet} ;
    pipePos = [ 0 strfind(fullname, '|') length(fullname) + 1] ;
    if iscell(pipePos)
        pipePos = cell2mat(pipePos) ;
    end
    matchSum = zeros(length(TMODEL.mets), 1) ;
    for i = 1:length(pipePos) - 1
        name = fullname(pipePos(i) + 1:pipePos(i + 1) - 1) ;
        match = regexpi(TMODEL.metKEGGID, name) ;
        match = ~cellfun('isempty', match) ;
        matchSum = matchSum + match ;
    end
    match = logical(matchSum) ;
    if ~isempty(find(match, 1))
        hit = 1 ;
        metScores(match) = metScores(match) + ScoreVal.KEGGID(1) ;
    end
end

% metSEEDID Match. There may multiple SEEDIDs or no SEEDID.
if ~isempty(CMODEL.metSEEDID{cMet})
    fullname = CMODEL.metSEEDID{cMet} ;
    pipePos = [ 0 strfind(fullname, '|') length(fullname) + 1] ;
    matchSum = zeros(length(TMODEL.mets), 1) ;
    for i = 1:length(pipePos) - 1
        name = fullname(pipePos(i) + 1:pipePos(i + 1) - 1) ;
        match = regexpi(TMODEL.metSEEDID, name) ;
        match = ~cellfun('isempty', match) ;
        matchSum = matchSum + match ;
    end
    match = logical(matchSum) ;
    if ~isempty(find(match, 1))
        hit = 1 ;
        metScores(match) = metScores(match) + ScoreVal.SEEDID(1) ;
    end
end

%% Normalize scores.
% remove negative scores
metScores(metScores < 0) = 0 ;

% if nothing was found yet, try to find anything remotely similar in name
% or ID
if hit == 0
    for itmets = find(metScores > 0)
        metScores(itmets) = metScores(itmets) + stringSimilarityForward(TMODEL.metNames{itmets}, CMODEL.metNames{cMet}, 3) ;
        waitbar(itmets / sum(metScores > 0)) ;
    end
    hit = 1 ;
end

if max(metScores) > 0 % Avoid NaN.
    metScores = metScores - min(metScores) ;
    metScores = metScores ./ max(metScores) ;
else
    metScores = 0.01 * ones(size(metScores)) ;
end

%% Take some metabolites out of the running.
% If tRxn is provided, then reduce all scores for noninvolved mets to 0.
if tRxn > 0
    metScores(TMODEL.S(:, tRxn) == 0) ...
        = metScores(TMODEL.S(:, tRxn) == 0) * 0;
end

% Reduce scores of metabolites that don't have the right compartment.
if ~isempty(regexp(CMODEL.mets{cMet}, '\[.\]$', 'once', 'match'))
    nowCom = regexp(CMODEL.mets{cMet}, '\[.\]$', 'once', 'match') ;
    % Match against .mets, which should contain the comparment designator.
    metScores(~strcmp(nowCom, tComp)) ...
        = metScores(~strcmp(nowCom, tComp)) * 0.1 ;
end


%% Output
[matchScores, matchIndex] = sort(metScores, 'descend') ;

varargout = cell(1) ;
varargout{1} = hit ;

function score = stringSimilarityForward(input1, input2, wordsize)
% compares the similarity of two strings and returns a score between 0 (not
% similar and 1 (identical)

% shortcut if input 1 and input 2 are identical
if strcmp(input1, input2)
    score = 1 ;
    return
end

score = zeros(length(input1) - wordsize, 1) ;
for i1 = 1:length(input1) - wordsize
    for i2 = 1:length(input2) - wordsize
        score(i1) = score(i1) + strcmpi(input1(i1:i1 + wordsize), input2(i2:i2 + wordsize)) ;
    end
end
score = mean(score ./ max(score)) ;

score(isnan(score)) = 0 ;
