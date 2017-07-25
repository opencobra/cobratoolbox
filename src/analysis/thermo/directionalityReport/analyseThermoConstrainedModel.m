function [out] = analyseThermoConstrainedModel(model, cumNormProbCutoff, printLevel, resultsBaseFileName)
% USAGE:
%
%    [out] = analyseThermoConstrainedModel(model, cumNormProbCutoff, printLevel, resultsBaseFileName)
%
% INPUTS:
%    model:                  structure with fields:
%
%                              * .DfGt0 - `m x 1` array of estimated standard transformed Gibbs
%                                energies of formation.
%                              * .DrGt0 - `n x 1` array of estimated standard transformed
%                                reaction Gibbs energies.
%                              * .DfGtMin - `m x 1` array of estimated lower bounds on
%                                transformed Gibbs energies of formation.
%                              * .DfGtMax - `m x 1` array of estimated upper bounds on
%                                transformed Gibbs energies of formation.
%                              * .DrGtMin - `n x 1` array of estimated lower bounds on
%                                transformed reaction Gibbs energies.
%                              * .DrGtMax - `n x 1` array of estimated upper bounds on
%                                transformed reaction Gibbs energies.
%                              * .quantDir - `n x 1` array indicating quantitatively assigned
%                                reaction directionality. 1 for reactions that are
%                                irreversible in the forward direction, -1 for
%                                reactions that are irreversible in the reverse
%                                direction, and 0 for reversible reactions.
%    cumNormProbCutoff:      default = 0.2
%    printLevel:             verbose level, default = 1
%    resultsBaseFileName:
%
% OUTPUT:
%    out:

out=[];

if ~exist('printLevel','var')
    printLevel=1;
end
if ~exist('cumNormProbCutoff','var')
    cumNormProbCutoff=0.2;
else
    if cumNormProbCutoff<0
        error('cumNormProbCutoff cannot be less than zero')
    end
end

if 1
    %statistics of directions
    fprintf('%s\n','directionalityStats...');
    model=directionalityStats(model,cumNormProbCutoff,printLevel);
end
%OUTPUT
% model.directions    a structue of boolean vectors with different directionality
%               assignments where some vectors contain subsets of others
%
% qualtiative -> quantiative changed reaction directions
%   .directions.forwardForward
%   .directions.forwardReverse
%   .directions.forwardReversible
%   .directions.reversibleFwd
%   .directions.reversibleRev
%   .directions.reversibleReversible
%   .directions.tightened
%
% subsets of qualtiatively forward  -> quantiatively reversible
%   .directions.forwardReversible_bydGt0
%   .directions.forwardReversible_bydGt0LHS
%   .directions.forwardReversible_bydGt0Mid
%   .directions.forwardReversible_bydGt0RHS
%
%   .directions.forwardReversible_byConc_zero_fixed_DrG0
%   .directions.forwardReversible_byConc_negative_fixed_DrG0
%   .directions.forwardReversible_byConc_positive_fixed_DrG0
%   .directions.forwardReversible_byConc_negative_uncertain_DrG0
%   .directions.forwardReversible_byConc_positive_uncertain_DrG0

if 1
    %report on directionality changes
    fprintf('%s\n','directionalityChangeReport...');
    directionalityChangeReport(model,cumNormProbCutoff,printLevel,resultsBaseFileName)
end

% if 0
%     fprintf('\n%s\n','...standardGibbsFormationEnergyStats');
%     [nKeq,nGC,nNone]=standardGibbsFormationEnergyStats(model,figures);
% end

if 0
    %pie charts with proportions of reaction directionalities and changes in
    %directionality
    fprintf('%s\n','directionalityStatFigures...');
    directionalityStatsFigures(model.directions,resultsBaseFileName)
end

%figures of reaction directionality changes
%qualitatively forward now quantiatiavely reversible
if any(model.directions.forward2Reversible)
    fprintf('%s\n','forwardReversibleFigures...');
    if 0
        forwardReversibleFigures(model)
    else
        thorStandard=0;
        forwardReversibleFiguresCC(model,model.directions,thorStandard)
    end
end

return

%create a vertical errorbar figure of the qualitatively forward transport reactions
%that are quantitatively reversible, whether from group contribution or
%Keq, that then need to be assigned to be forward, to limit the growth rate
% i.e. abc transporters or reactions involving protons
if any(model.directions.forwardReversible & model.transportRxnBool)
     forwardTransportQuantReverseFigures(model)
end

%vertical errorbar of qualitatively forward but quantitatively reverse
%forward, probably reverse
%   .directions.forwardReversible_bydGt0RHS
%   .directions.forwardReversible_byConc_positive_fixed_DrG0
%   .directions.forwardReversible_byConc_positive_uncertain_DrG0
fwdProbReverse=model.directions.forwardReversible_bydGt0RHS | ...
    model.directions.forwardReversible_byConc_positive_uncertain_DrG0| ...
    model.directions.forwardReversible_byConc_positive_fixed_DrG0;
if any(fwdProbReverse) && 0
    forwardProbablyReverseFigures(model,directions)
end
