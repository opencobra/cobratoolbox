function [metList, stopFlag] = metCompare(RxnInfo)
% Launches the `metCompareGUI`, first preparing information for the
% GUI and automatching some metabolites. If all metabolites are matched,
% based on certain criteria, then the GUI is bypassed. `metCompare` then
% adjusts `metList` to reflect the new pairings.
% Called by `reactionCompareGUI`, `autoMatchReactions`, calls `findMetMatch`, `metCompareGUI`, `fillRxnInfo`, `autoMatchMets`.
%
% USAGE:
%    [metList, stopFlag] = metCompare(RxnInfo)
%
% INPUTS:
%    RxnInfo:       Structure which contains relevent info, including.
%    rxnIndex:      Index of reaction being compared. If `metCompare` is being
%                   run to compare mets irregardless of reactions, this is 0.
%    rxnMatch:      The index of that reaction's match, if any.
%    rxnList:       list of reactions
%    metList:       list of metabolites
%    CMODEL:        global input
%    TMODEL:        globl input
%
% OUTPUTS:
%    metList:       list of metabolites
%    stopFlag:      Flag indicates that metabolite matching has been aborted.
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

global TMODEL % Declare variables.
metList = RxnInfo.metList ;
stopFlag = 0 ;
if ~isfield(RxnInfo, 'rxnMatch')
    RxnInfo.rxnMatch = 0 ;
end

%% Prepare data and launch GUI
% Get information about reaction and metabolites (or just metabolites if we
% are not comparing from a reaction.
RxnInfo = fillRxnInfo(RxnInfo) ;

% Check initial met matches, bypass GUI if possible. Only do this when
% metabolites are being compared from a reaction.
if RxnInfo.rxnIndex
    if isfield(TMODEL, 'forceMetReview')
        if TMODEL.forceMetReview
            RxnInfo.flagGUI = 1 ;
            RxnInfo.goodMatch = zeros(RxnInfo.nMets, 1) ;
        else
            RxnInfo = autoMatchMets(RxnInfo) ;
        end
    else
        RxnInfo = autoMatchMets(RxnInfo) ;
    end

else
    RxnInfo.flagGUI = 1 ;
    RxnInfo.goodMatch = zeros(RxnInfo.nMets, 1) ;
end

% force review in GUI
if isfield(TMODEL, 'forceMetReview')
    if TMODEL.forceMetReview
        RxnInfo.flagGUI = 1 ;
    end
end

% Launch GUI
if (RxnInfo.flagGUI)
    [RxnInfo, stopFlag] = metCompareGUI(RxnInfo) ;
end

% Update metList for matches found in TMODEL.
if ~stopFlag
    for iMet = 1:RxnInfo.nMets
        % If the metabolite is new, give it a new index.
        if RxnInfo.matches(iMet) == 0
            if max(metList) <= length(TMODEL.mets)
                % The first new met index.
                tIndex = length(TMODEL.mets) + 1 ;
            else
                tIndex = max(metList) + 1 ;
            end
            metList(RxnInfo.metIndex(iMet)) = tIndex ;
        else % Give it the index of its match from T.
            metList(RxnInfo.metIndex(iMet)) = RxnInfo.matches(iMet) ;
        end
    end
end

%% Subfunctions
% Fills in RxnInfo to be passed to metCompare GUI.
function RxnInfo = fillRxnInfo(RxnInfo)
cRxn = RxnInfo.rxnIndex ;
global CMODEL

% Find metabolites in reaction (from CMODEL) if applicable
if cRxn
    RxnInfo.metIndex = find(CMODEL.S(:, cRxn)) ;
    RxnInfo.nMets = length(RxnInfo.metIndex) ;
    RxnInfo.rev = CMODEL.ub(cRxn) & CMODEL.lb(cRxn);
    RxnInfo.metStoichs = CMODEL.S(RxnInfo.metIndex, cRxn) ;
    RxnInfo.rxnName = strcat(CMODEL.rxns{cRxn}, '; ', CMODEL.rxnNames{cRxn});
    RxnInfo.matchRxnEquation = CMODEL.rxnEquations{cRxn} ;
else
    % Otherwise we are just looking at mets irregardless of reaction, the
    % met number should have already been supplied.
    RxnInfo.nMets = length(RxnInfo.metIndex) ;
    RxnInfo.rxnName = 'N/A' ;
    RxnInfo.matchRxnEquation = 'N/A' ;
end

% Populate metabolite info, including best matches.
RxnInfo.metData = cell(7, RxnInfo.nMets) ;
RxnInfo.matches = [] ;
for iMet = 1:RxnInfo.nMets
   RxnInfo.metData(1, iMet) = strcat(CMODEL.mets(RxnInfo.metIndex(iMet)), ...
                                    ', ', ...
                                    num2str(RxnInfo.metIndex(iMet))) ;
   RxnInfo.metData(2, iMet) = CMODEL.metNames(RxnInfo.metIndex(iMet)) ;
   RxnInfo.metData(3, iMet) = CMODEL.metFormulas(RxnInfo.metIndex(iMet)) ;
   RxnInfo.metData{4, iMet} = num2str(CMODEL.metCharge(RxnInfo.metIndex(iMet))) ;
   RxnInfo.metData(5, iMet) = CMODEL.metKEGGID(RxnInfo.metIndex(iMet)) ;
   RxnInfo.metData(6, iMet) = CMODEL.metSEEDID(RxnInfo.metIndex(iMet)) ;
   RxnInfo.metData(7, iMet) = CMODEL.metID(RxnInfo.metIndex(iMet)) ;
   [RxnInfo.matchScores{iMet}, RxnInfo.matchIndex{iMet}, hit] = findMetMatch(RxnInfo.metIndex(iMet),...
                                       RxnInfo.rxnMatch) ;
   RxnInfo.metDataInfo = {'ID' ; 'Name'; 'Formula'; 'Charge'; 'KEGGid'; 'SEEDid'; 'oldID'} ;
   % Assign best match, but if no hit was found change it to zero.
   RxnInfo.matches(iMet) = RxnInfo.matchIndex{iMet}(1) ;
   if ~hit
       RxnInfo.matches(iMet) = 0 ;
   end
end

function RxnInfo = autoMatchMets(RxnInfo)
global CMODEL TMODEL

% Array declares if met is confident match. If all are confident, skip GUI.
goodMatch = zeros(RxnInfo.nMets, 1) ;
% Array declares if met is confidently new.
defNew = zeros(RxnInfo.nMets, 1) ;

for iMet = 1:RxnInfo.nMets

    % Check for predeclared mets, if they have, ensure that is the choice
    % in metMatch, declare good and move on.
    if RxnInfo.metList(RxnInfo.metIndex(iMet)) ~= 0
        RxnInfo.matches(iMet) ...
            = RxnInfo.metList(RxnInfo.metIndex(iMet)) ;
        goodMatch(iMet) = 1 ;
        continue
    end

    % Implement automatch values.
    [matchScores, matchIndex] = findMetMatch(RxnInfo.metIndex(iMet), ...
                               RxnInfo.rxnMatch) ;
    % Normalize matchScores to sum of first 5 Scores. 5 is the default
    % number of displayed matches.
    nowMatchScores = matchScores(1:5) / sum(matchScores(1:5)) ;
    if (nowMatchScores(1) >= RxnInfo.metAutoMatchLimits(1)) ...
            && (nowMatchScores(1) - nowMatchScores(2) > ...
            RxnInfo.metAutoMatchLimits(2))
        % If the SCORE is good enough, accept it even if it is not
        % perfect
        goodMatch(iMet) = 1 ;
    elseif nowMatchScores(1) < RxnInfo.metAutoMatchLimits(3)
        goodMatch(iMet) = 0 ;
        defNew(iMet) = 1 ;
        RxnInfo.matches(iMet) = 0 ;
        continue
    end

    % Check if there are KEGG IDs and if they match
    cKegg = CMODEL.metKEGGID{RxnInfo.metIndex(iMet)} ;
    tKegg = TMODEL.metKEGGID{RxnInfo.matches(iMet)} ;
    if ~isempty(cKegg) && ~isempty(tKegg)
        pipePos = [0 strfind(cKegg, '|') length(cKegg) + 1] ;
        if iscell(pipePos)
            pipePos = cell2mat(pipePos) ;
        end
        for jID = 1:length(pipePos) - 1
            nowID = cKegg(pipePos(jID) + 1:pipePos(jID + 1) - 1) ;
            if iscell(nowID)
                nowID = [nowID{:}] ;
            end
            if ~isempty(strfind(tKegg, nowID))
                goodMatch(iMet) = 1 ;
            end
        end
    end

    % Check if there are SEEDIDs and if they match
    cSeed = CMODEL.metSEEDID{RxnInfo.metIndex(iMet)} ;
    tSeed = TMODEL.metSEEDID{RxnInfo.matches(iMet)} ;
    if ~isempty(cSeed) && ~isempty(tSeed)
        pipePos = [0 strfind(cSeed, '|') length(cSeed) + 1] ;
        if iscell(pipePos)
            pipePos = cell2mat(pipePos) ;
        end
        for jID = 1:length(pipePos) - 1
            nowID = cSeed(pipePos(jID) + 1:pipePos(jID + 1) - 1) ;
            if iscell(nowID)
                nowID = [nowID{:}] ;
            end
            if ~isempty(strfind(tSeed, nowID))
                goodMatch(iMet) = 1 ;
            end
        end
    end

    % Check if compartment matches. If not, declare not good and move on.
    cComp = CMODEL.mets{RxnInfo.metIndex(iMet)}(end - 1) ;
    tComp = TMODEL.mets{RxnInfo.matches(iMet)}(end - 1) ;
    if ~strcmp(cComp, tComp)
        goodMatch(iMet) = 0 ;
        continue
    end

    % Check if the formulas match in everything but hydrogen. If not,
    % declare not good and move on.
    cForm = regexprep(CMODEL.metFormulas{RxnInfo.metIndex(iMet)}, ...
                                         'H\d*', '') ;
    tForm = regexprep(TMODEL.metFormulas{RxnInfo.matches(iMet)}, ...
                                         'H\d*', '') ;
    if isempty(strfind(tForm,cForm)) && ~isempty(cForm) && ~isempty(tForm)
        goodMatch(iMet) = 0 ;
        continue
    end

    % Check to make sure that a match for a given met doesn't already have
    % a match in CMODEL
    if ~RxnInfo.metList(RxnInfo.metIndex(iMet)) ...
                && ~isempty(find(RxnInfo.metList ...
                                 == RxnInfo.matches(iMet), 1)) ...
                && RxnInfo.matches(iMet) ~= 0
        goodMatch(iMet) = 0 ;
        continue
    end

    clear cComp tComp cKegg tKegg cName tName cID tID
end

% If all the matches are good, no need to look at GUI.
if sum([goodMatch defNew], 2)
    RxnInfo.flagGUI = 0 ;
else
    RxnInfo.flagGUI = 1 ;
end
RxnInfo.goodMatch = goodMatch ;
RxnInfo.defNew = defNew ;
