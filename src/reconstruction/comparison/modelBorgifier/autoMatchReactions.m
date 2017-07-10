function [rxnList,metList] = autoMatchReactions(scoreTotal, rxnList, metList, varargin)
% Finds confident matches from CMODEL to TMODEL.
% reactions which can not be confidently assigned are reviewed with
% `reactionCompare`. To make a confident assignment a matched reaction must
% have a score above a supplied cutoff and not have competing matches with
% similar scores. Called by `reactionCompareGUI`, calls `metCompare`.
%
% USAGE:
%
%    rxnList = autoMatchReactions(scoreTotal, rxnList, metList, [rxnHighCutoff, rxnMargin, rxnLowCutoff], [metHighCutoff, metMargin, metLowCutoff])
%
% INPUTS:
%    scoreTotal:       Optimized score matrix between `CMODEL` and `TMODEL` reactions.
%    rxnList:          Only undeclared reactions will be automatched.
%    metList:          Comparison array for metabolites
%
% OPTIONAL INPUTS:
%    rxnHighCutoff:    Score value above which confident assignments can be made.
%    rxnMargin:        Distance a best match has to be above a competitor match.
%    rxnLowCutoff:     Score value below which reactions will be declared new.
%    metHighCutoff:    The following three are the same but for mets.
%    metMargin:
%    metLowCutoff:
%    CMODEL:           global input
%    TMODEL:           global input
%
% OUTPUTS:
%    rxnList:          Array which correlates a reaction from CMODEL to the index
%                      of the best match in `TMODEL`. Rxns with 0 designation are
%                      new, ones with a -1 need manual review.
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

h = waitbar(0, 'Automatching') ; % Declare variables.

global CMODEL TMODEL

% Number of reactions in CMODEL.
nCrxn = size(scoreTotal, 1) ;

% Assign cutoff params if possible.
if nargin >= 6 %8
    rxnHighCutoff = varargin{1} ;
    rxnMargin = varargin{2} ;
    rxnLowCutoff = varargin{3} ;
else
    rxnHighCutoff = 0.99 ;
    rxnMargin = 0.1 ;
    rxnLowCutoff = 0.01 ;
end
% get metabolite automatch cutoffs if possible
if nargin >= 8 %10
    metHighCutoff = varargin{4} ;
    metMargin = varargin{5} ;
    metLowCutoff = varargin{6} ;
else
    metHighCutoff = 0.99 ;
    metMargin = 0.1 ;
    metLowCutoff = 0.01 ;
end
% Save a form of the rxnList before auto matching.
rxnListBefore = rxnList ;

%% Find probable matches based on scoring.
% Find best scoring matches.
[sortMatch, sortMatchIndex] = sort(scoreTotal, 2, 'descend') ;

% Only consider reactions which have not been previously declared.
probMatch = [] ;
pos = 1 ;
for iRxn = 1:nCrxn
    if sortMatch(iRxn, 1) > rxnHighCutoff && ...
            sortMatch(iRxn, 1) - sortMatch(iRxn, 2) > rxnMargin && ...
            rxnList(iRxn) == -1
        rxnList(iRxn) = sortMatchIndex(iRxn, 1) ;
        probMatch(pos, 1) = iRxn ;
        pos = pos + 1 ;
    end
end

%% Double check reactions for hints that they are misses.
% Set the test columns in probMatch to 1. Innocent until proven guilty.
if ~isempty(probMatch)
    probMatch(:, 2:5) = 1 ;
end

for iRxn = 1:size(probMatch, 1)
    % Check if matched reaction has been associated with another reaction.
    nowMatch = rxnList(probMatch(iRxn, 1)) ;
    % The match should only be in rxnList once.
    if length(find(rxnList == nowMatch)) ~= 1
        probMatch(iRxn, 2) = 0 ;
    end

    % Check if paired reactions have KEGG IDs and if they match.
    cKegg = CMODEL.rxnKEGGID{probMatch(iRxn, 1)} ;
    tKegg = TMODEL.rxnKEGGID{rxnList(probMatch(iRxn, 1))} ;
    if ~isempty(cKegg) && ~isempty(tKegg)
        pipePos = [0 strfind(cKegg, '|') length(cKegg) + 1] ;
        for jID = 1:length(pipePos) - 1
            nowID = cKegg(pipePos(jID)+1:pipePos(jID + 1) - 1) ;
            if isempty(strfind(tKegg, nowID))
                probMatch(iRxn, 3) = 0 ;
            end
        end
    end

    % Check if paired reactions have the same stoichiometry.
    if CMODEL.metNums(probMatch(iRxn, 1), 2) ~= ...
            TMODEL.metNums(rxnList(probMatch(iRxn, 1)), 2)
        probMatch(iRxn, 4) = 0 ;
    end

    % Check if paired reactions have the same compartment.
    if ~isempty(CMODEL.rxnComp{probMatch(iRxn, 1)} ) && ~isempty(TMODEL.rxnComp{rxnList(probMatch(iRxn, 1))})
        if ~strcmp(CMODEL.rxnComp{probMatch(iRxn, 1)}, ...
                TMODEL.rxnComp{rxnList(probMatch(iRxn, 1))})
            probMatch(iRxn, 5) = 0 ;
        end
    end

    % If any of the above tests failed, set the match in rxnList backto -1.
    if probMatch(iRxn, 2:end)
    else
        rxnList(probMatch(iRxn, 1)) = -1 ;
    end
end

clear probMatch nowMatch cKegg tKegg

%% Assign new reactions based on cutoff.
for iRxn = 1:nCrxn
    if rxnList(iRxn) == -1 && ...
            sortMatch(iRxn,1) < rxnLowCutoff
        rxnList(iRxn) = 0 ;
    end
end

%% Assign new reactions based on metabolites that have been declared.
% For undeclared reactions in CMODEL, find the indexes of their metabolite
% matches.
for iRxn = 1:length(rxnList)
    if rxnList(iRxn) == -1
        % For the reaction in question from CMODEL.
        metPos = find(CMODEL.S(:, iRxn)) ;
        cMetMatchIndexes = zeros(length(metPos), 1) ;
        for iMet = 1:length(metPos)
            cMetMatchIndexes(iMet) = metList(metPos(iMet)) ;
        end
        % For the best match from TMODEL.
        tMetMatchIndexes = find(TMODEL.S(:, sortMatchIndex(iRxn, 1))) ;
        % If all the mets have been declared in cRxn, and the best match
        % from T does not have exactly those mets, declare a new reaction.
        if isempty(find(cMetMatchIndexes == 0, 1))
            if logical(ismember(cMetMatchIndexes, tMetMatchIndexes)) * ...
                    length(cMetMatchIndexes) == length(tMetMatchIndexes)
            else
                rxnList(iRxn) = 0 ;
            end
        end
        % Also declare reactions as new it they have a new metabolite(s).
        if ~isempty(find(cMetMatchIndexes > length(TMODEL.mets), 1))
            rxnList(iRxn) = 0 ;
        end
    end
end

%% For reactions that have just been matched or declared new, find mets.
% Find newly auto-matched reactions.
autoMatchedRxns = find(rxnList(:) ~= rxnListBefore(:)) ;

% Prepare data structure to be passed.
RxnInfo.rxnList = rxnList ;

for iRxn = 1:length(autoMatchedRxns)
    RxnInfo.rxnIndex = autoMatchedRxns(iRxn) ;
    RxnInfo.rxnMatch = rxnList(autoMatchedRxns(iRxn)) ;
    RxnInfo.metList = metList ;
    RxnInfo.metAutoMatchLimits = [metHighCutoff, metMargin, metLowCutoff] ;

    % Launch comparison script.
    [metList, stopFlag] = metCompare(RxnInfo) ;

    % If metCompare was suspended, don't attempt to find matches for the
    % reamining reactions.
    if stopFlag
        break
    end
    waitbar(iRxn/length(autoMatchedRxns), h)
end

close(h)
