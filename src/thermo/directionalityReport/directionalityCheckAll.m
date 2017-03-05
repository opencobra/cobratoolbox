function directions=directionalityCheckAll(model,cumNormProbCutoff,thorStandard,printToFile,printToTable,figures)
% Analysis of differences between qualitative and quantiative directionality assignments.
%
% assess reaction directionality, perhaps also print changed directions, and
% optionally generate figures
%
%INPUT
% model
% cumNormProbCutoff     {0.1} positive real number between 0 and 0.5 that
%                       specifies to tolerance when there is uncertainty in group
%                       contribution estimates.
%OPTIONAL INPUT
% thorStandard          {0,(1)} use new standard reactant concentration
%                       half way between upper and lower concentration bounds
% printToFile           {0,(1)} Boolean. 1=print out to log file
% printToTable          {0,(1)} Boolean. 1=print changes to a table (for publication)
% figures               {(0),1} Boolean. 1=create figures illustrating
%                       changed directions
%
%OUTPUT
% directions    a structue of boolean vectors with different directionality 
%               assignments where some vectors contain subsets of others
%
% qualitatively assigned directions 
%   directions.fwdReconBool
%   directions.revReconBool
%   directions.reversibleReconBool
%
% qualitatively assigned directions using thermo in preference to
% qualitative assignments but using qualitative assignments where
% thermodynamic data is lacking
%   directions.fwdReconThermoBool
%   directions.revReconThermoBool
%   directions.reversibleReconThermoBool
%
% reactions that are qualitatively assigned by thermodynamics
% directions.fwdThermoOnlyBool
% directions.revThermoOnlyBool
% directions.reversibleThermoOnlyBool
%
% qualtiative -> quantiative changed reaction directions 
% directions.ChangeReversibleFwd
% directions.ChangeReversibleRev
% directions.ChangeForwardReverse
% directions.ChangeForwardReversible
%
% subsets of forward qualtiative -> reversible quantiative change
%   directions.ChangeForwardReversibleBool_dGfGC
%   directions.ChangeForwardReversibleBool_dGfGC_byConcLHS
%   directions.ChangeForwardReversibleBool_dGfGC_byConcRHS
%   directions.ChangeForwardReversibleBool_dGfGC_bydGt0
%   directions.ChangeForwardReversibleBool_dGfGC_bydGt0LHS
%   directions.ChangeForwardReversibleBool_dGfGC_bydGt0Mid
%   directions.ChangeForwardReversibleBool_dGfGC_bydGt0RHS
%   directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorLHS
%   directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorRHS
%
%   directions.cumNormProbCutoff
%   directions.ChangeForwardForwardBool_dGfGC
%
%
% Ronan M.T. Fleming

if ~exist('cumNormProbCutoff','var')
    cumNormProbCutoff=0.1;
else
    if cumNormProbCutoff<0
        error('cumNormProbCutoff cannot be less than zero')
    end
end
if ~exist('thorStandard','var')
    thorStandard=1;
end
    
%statistics of directions
directions=directionalityStats(model,cumNormProbCutoff,thorStandard,printToFile);

%print out problematic reactions in structured format
if ~exist('printToFile','var')
    printToFile=1;
end
%print out problematic reactions in summary table format for paper
if ~exist('printToTable','var')
    printToTable=1;
end

directionalityCheck(model,directions,printToFile,printToTable)

if ~exist('figures','var')
    figures=0;
end
if figures
    %pie charts with proportions of reaction directionalities and changes in
    %directionality
    fprintf('\n%s\n','...directionalityStatFigures');
    directionalityStatFigures(directions,figures)

    %figures of reaction directionality changes
    %qualitatively forward now quantiatiavely reversible
    if any(directions.ChangeForwardReversibleBool_dGfGC)
        forwardReversibleFiguresGC(model,directions,thorStandard)
    end
    
    %make figure of  reactions that have changed from qualitatively forward
    %to quantitatively reversible, where all metabolites dGt0 were back
    %calculated from Keq.
    %omit those reactions that are transport reactions
    if any(directions.ChangeForwardReversible_dGfKeq)
        forwardReversibleFiguresKeq(model,directions,thorStandard)
    end
    
    %create a vertical errorbar figure of the qualitatively forward transport reactions
    %that are quantitatively reverseible, whether from group contribution or
    %Keq, that then need to be assigned to be forward, to limit the growth rate
    % i.e. abc transporters or reactions involving protons
    if any(directions.ChangeForwardReversible & model.transportRxnBool)
        forwardTransportQuantReverseFigures(model,directions,thorStandard)
    end
    
    %vertical errorbar of qualitatively forward but quantitatively reverse
    %forward, probably reverse
    fwdProbReverse=directions.ChangeForwardReversibleBool_dGfGC_byConcRHS | ...
    directions.ChangeForwardReversibleBool_dGfGC_bydGt0RHS | ...
    directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorRHS;
    if any(fwdProbReverse)  
        forwardProbablyReverseFigures(model,directions,thorStandard)
    end
end