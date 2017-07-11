% This file is published under Creative Commons BY-NC-SA.
%
% Please cite:
% Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale 
% metabolic reconstructions with modelBorgifier. Bioinformatics 
% (Oxford, England), 30(7), 1036?8. http://doi.org/10.1093/bioinformatics/btt747
%
% Correspondance:
% johntsauls@gmail.com
%
% Developed at:
% BRAIN Aktiengesellschaft
% Microbial Production Technologies Unit
% Quantitative Biology and Sequencing Platform
% Darmstaeter Str. 34-36
% 64673 Zwingenberg, Germany
% www.brain-biotech.de
%
function [rxnList, metList, Stats] = reactionCompare(CmodelIn, TmodelIn, ...
                                                     scoreIn, varargin) 
% reactionCompare is the function front end for autoMatchReactions and 
% the reactionCompareGUI. Loads CMODEL, TMODEL, Score and ScoreTotal from
% globals if they are not provided. If rxnList is not provided then it is
% generated with autoMatchReactions. If you are continuing comparison, 
% include the optional inputs. 
%
% USAGE:
%    [rxnList, metList, Stats] = reactionCompare(CmodelIn, TmodelIn, scoreIn, ...
%                                                [rxnList, metList, Stats])
%
% INPUTS:
%    CmodelIn
%    TmodelIn
%    scoreIn
%
% OPTIONAL INPUTS:
%    rxnList:    Array pairs reactions in CMODEL with matches from TMODEL or
%                declares them as new.
%    metList:    Array pairs metabolites in CMODEL with matches from TMODEL,
%                new metabolites are given their new met number in TMODEL.
%    Stats:      Stats array that contains weighting information from previous
%                scoring work. 
%
% OUTPUTS:
%    rxnList
%    metList
%    Stats
%
% CALLS:
%    optimalScores
%    autoMatchReactions
%    reactionCompareGUI
%
% CALLED BY:
%    mergeModels
%    driveModelBorgifier


%% Declare variables
% Make the inputs variables so they can be easily accessed by downstream
% scripts. None of these variables are edited by any of these scripts. 
global CMODEL TMODEL SCORE
CMODEL = CmodelIn ;
TMODEL = TmodelIn ; 
SCORE = scoreIn ;

% Need scoreTotal now to create rxnList if Stats is not provided.
if nargin <= 5
%     Stats = optimalScores(CMODEL,TMODEL,SCORE) ;
    Stats = optimalScores ;
else
    Stats = varargin{3} ;
end

% Was metList supplied?
if nargin >= 5
    metList = varargin{2} ;
else
    metList = zeros(length(CMODEL.mets),1) ;
end

% How 'bout rxnList?
if nargin > 3
    rxnList = varargin{1} ;
else
    rxnList = ones(length(CMODEL.rxns),1)*-1 ;
end

%% Manual reaction comparison.

% Create information structure to pass to reactionCompareGUI
InfoBall.rxnList = rxnList ;
InfoBall.metList = metList ; 
InfoBall.CmodelName = CMODEL.description ;
InfoBall.Stats = Stats ;
InfoBall.S = CMODEL.S ;

% Launch GUI.
[rxnList, metList, Stats] = reactionCompareGUI(InfoBall) ; 


