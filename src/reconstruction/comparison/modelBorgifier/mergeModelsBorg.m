function [TmodelC, Cspawn, Stats] = mergeModelsBorg(CmodelIn, TmodelIn, rxnList, metList, Stats, varargin)
% Checks Tmodel for duplicate reactions and other mistakes,
% that may have occured during reaction and metabolite matching. It
% resolves these problems and merges the models, and confirms that Cmodel
% is the same after being removed from the merged model. It also provides
% some statistics on the merging process and resulting combined model.
% Called by `driveModelBorgifier`, calls `addToTmodel`, `compareMatricies`, `reactionCompare`, `cleanTmodel`, organizeModelCool`, `TmodelStats`, `readCbTmodel`.
%
% USAGE:
%
%    [TmodelC, Cspawn, Stats, CMODEL] = mergeModelsBorg(CmodelIn, TmodelIn, rxnList, metList, Stats, score)
%
% INPUTS:
%    CmodelIn:     Comparison model
%    TmodelIn:     Template model
%    rxnList:      Array which designates matched and new reactions.
%    metList:      Array which desginates matched and new metabolites.
%    Stats:        Structure that comes from reactionCompare. Weighting
%                  information can be used and additional information addended.
%    score:        The original scoring matrix, which may be used to correct
%                  problematic reaction upon recomparison.
%
% OPTIONAL INPUTS:
%    'Verbose':    Print statements on progress.
%
% OUTPUTS:
%    TmodelC:      Combined `C` and `Tmodel`.
%    Cspawn:       Cmodel after it has been removed from the `TmodelC`
%    Stats:        Structure of information regarding the merging and also stats
%                  on the combined model.
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

global SCORE CMODEL TMODEL % Declare variables.
CMODEL = CmodelIn ;
TMODEL = TmodelIn ;
% SCORE = score ;
TmodelC = [] ;
Cspawn = [] ;

verbose = false ;
if ~isempty(varargin)
    if sum(strcmp('Verbose', varargin))
        verbose = true ;
    end
end

% Allow pausing for some of the UI.
% pause on

% set flags for the two checks. 
reviewMets = 1 ;
checkSimilarity = 1 ;

%% Check that metList is okay.
% Make sure all mets have been declared and that 2 mets from C aren't
% matched to the same met in T. Continue until everything is a-okay.

while reviewMets
    % Find mets that have not been declared.
    reviewMets = find(metList == 0) ;

    % Find mets in C that have been matched to the same metabolite in T.
    uniqMetIndex = unique(metList) ;
    count = histc(metList, uniqMetIndex) ;
    dups = uniqMetIndex(count > 1) ;
    for iDup = 1:length(dups)
        metIndex = find(metList == dups(iDup)) ;
        reviewMets(end + 1:length(reviewMets) + length(metIndex)) = metIndex ;
    end

    % Review all above mets with GUI.
    if ~isempty(reviewMets)
        fprintf('Problems within metList, resolve with GUI.\n')
        reviewMetsAgain = input('Press c to continue anyways or any other key to re-check metabolite matching.\n', 's') ;
        if ~strcmpi(reviewMetsAgain, 'c')
            RxnInfo.rxnIndex = 0 ; % Tells GUI just look at mets.
            RxnInfo.rxnList = rxnList ;
            RxnInfo.metList = metList ;
            RxnInfo.metIndex = reviewMets ;
            metList = metCompare(RxnInfo) ;
        else
            reviewMets = 0 ; % just go on without dealing with problem.
            checkSimilarity = 0 ; % matricies will be messed up, so do not do checking below
            fprintf('Skipped resolving, will not check fidelity of matricies.\n') ; 
        end
    end
end

% Force good numbering for new metabolites
TmetNum = length(TMODEL.mets) ;
metList(metList > TmetNum) = TmetNum+(1:sum(metList > TmetNum)) ;

% merge and extract C model
CMODELoriginal = CMODEL ;
if verbose
    [TmodelC, CMODEL] = addToTmodel(CMODEL, TMODEL, rxnList, metList, 'NoClean', 'Verbose') ;
else
    [TmodelC, CMODEL] = addToTmodel(CMODEL, TMODEL, rxnList, metList, 'NoClean') ;
end

% Create Cmodel again from the combined model.
if verbose
    Cspawn = readCbTmodel(CMODEL.description, TmodelC, 'y', 'Verbose') ;
else
    Cspawn = readCbTmodel(CMODEL.description, TmodelC, 'y') ;
end

%% Reconsider reactions that don't have the same stoich between Cmodel and Cspawn
try
while checkSimilarity
    % Combine models and create spawn of Cmodel.
    % Combine the models. Problematic mets must have been resolved
    FluxCompare = compareMatricies(CMODELoriginal, Cspawn) ;
    
    % If there are differences pause and let the user know what is up.
    if sum(sum(FluxCompare.diffS)) || (sum(rxnList == -1) > 0)
        % Plots the differences between the S matricies.
        figure
        subplot(2, 2, 1)
        spy(FluxCompare.CmodelS)
        title([CMODEL.description ' before merging.'])
        subplot(2, 2, 2)
        spy(FluxCompare.CspawnS)
        title([CMODEL.description ' after merging.'])
        subplot(2, 1, 2)
        spy(FluxCompare.diffS)
        title('Difference.')

        % Pause and tell the users what is happening.
        fprintf('Difference between the matricies. Reactions from C\n')
        fprintf('that do not have the same stoich before and after\n')
        fprintf('merging need to be reviewed again.\n')
        fprintf('Press the any key to continue.\n')

        % Find the wrong reactions and metabolies,
        % mark them as undeclared, call GUI, and loop.
        diffmets = logical(sum(abs(FluxCompare.diffS), 2)) ;
        metList(FluxCompare.CmetsSorti(diffmets)) = 0 ;
        fprintf('Revisit only [p]roblematic reactions or [a]ll reactions that problematic metabolites are involved in?\n')
        nowans = input('default = p ', 's') ;
        if strcmp(nowans, 'a')
            diffrxns = logical(sum(abs(FluxCompare.diffS), 1) + sum(FluxCompare.CmodelS(diffmets, :)) + sum(FluxCompare.CspawnS(diffmets, :))) ;
        else
            diffrxns = logical(sum(abs(FluxCompare.diffS), 1)) ;
        end
        rxnList(FluxCompare.CrxnsSorti(diffrxns)) = -1 ;

        [rxnList, metList, Stats] = reactionCompare(CMODEL, TMODEL, SCORE, rxnList, metList, Stats) ;
        
        % remerge and extract C model for second round of checking.
        [TmodelC, CMODEL] = addToTmodel(CMODEL, TMODEL, rxnList, metList, 'NoClean') ;
        Cspawn = readCbTmodel(CMODEL.description, TmodelC, 'y') ;

    else
        % Set the flag to not check for differences again.
        fprintf('Matricies are now equal before and after merging.\n')
        % Turn off flag.
        checkSimilarity = 0 ;
        break
    end
end
catch % return safely if re-matching is aborted by user
    return
end

% Add final rxn and metList to Stats.
Stats.rxnList = rxnList ;
Stats.metList = metList ;

%% Organize and Get stats on combined Tmodel.
if verbose
    TmodelC = cleanTmodel(TmodelC, 'Verbose') ;
else
    TmodelC = cleanTmodel(TmodelC) ;
end
try
    TmodelC = organizeModelCool(TmodelC) ;
catch
    disp('TmodelC too large for cool organization of stoichiometric matrix.')
end
if verbose
    Cspawn = readCbTmodel(CMODEL.description, TmodelC, 'y', 'Verbose') ;
else
    Cspawn = readCbTmodel(CMODEL.description, TmodelC, 'y') ;
end
Stats = TmodelStats(TmodelC, Stats) ;
end
