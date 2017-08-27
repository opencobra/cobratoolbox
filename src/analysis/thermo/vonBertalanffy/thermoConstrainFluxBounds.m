function [modelThermo, directions] = thermoConstrainFluxBounds(model, confidenceLevel, DrGt0_Uncertainty_Cutoff, printLevel)
% Thermodynamically constrain reaction bounds.
%
% USAGE:
%
%    [modelThermo, directions] = thermoConstrainFluxBounds(model, confidenceLevel, DrGt0_Uncertainty_Cutoff, printLevel)
%
% INPUTS:
%    model:                       Model structure with following additional fields:
%
%                                   * .DrGtMin - `n x 1` array of estimated lower bounds on
%                                     transformed reaction Gibbs energies.
%                                   * .DrGtMax - `n x 1` array of estimated upper bounds on
%                                     transformed reaction Gibbs energies.
%    confidenceLevel:
%    DrGt0_Uncertainty_Cutoff:    Thermodynamic data not used if uncertainty is
%                                 high in estimates
%
% OPTIONAL INPUT:
%    printLevel:                  -1 - print out to file, 0 - silent, 1 - print out to command window
%
% OUTPUTS:
%    modelThermo:                 Model structure with following additional fields:
%
%                                   * modelThermo.lb_reconThermo - lower bound based on thermodynamic estimates,
%                                     where uncertainty is below a threshold
%                                   * modelThermo.ub_reconThermo - upper bound based on thermodynamic estimates,
%                                     where uncertainty is below a threshold
%
%    directions:                  a structue of boolean vectors with different directionality
%                                 assignments where some vectors contain subsets of others
%
% Qualitatively assigned direction:
%
%    * directions.forwardRecon
%    * directions.reverseRecon
%    * directions.reversibleRecon
%
% Qualitatively assigned directions using thermo in preference to
% qualitative assignments but using qualitative assignments where
% thermodynamic data is lacking:
%
%    * directions.forwardThermo
%    * directions.reverseThermo
%    * directions.reversibleThermo
%    * directions.uncertainThermo
%
% .. Author: -  Ronan M.T. Fleming

if ~exist('printLevel','var')
    printLevel=0;
end

% Map confidence level to t-value
tValueMat = [0.50, 0;...
             0.70, 1.036;...
             0.95, 1.960;...
             0.99, 2.576];

tValue = tValueMat(tValueMat(:,1) == confidenceLevel,2);

DrGtMin=model.DrGtMin;
DrGtMax=model.DrGtMax;
if any(DrGtMin>DrGtMax)
    error('DrGtMin greater than DrGtMax');
end

DrGtNaNBool=(isnan(model.DrGtMax) | isnan(model.DrGtMin)) & model.SIntRxnBool;
if any(DrGtNaNBool)
    warning([int2str(nnz(DrGtNaNBool)) ' DrGt are NaN']);
end

nEqualDrGt=nnz(DrGtMin==DrGtMax & DrGtMin~=0);
if any(nEqualDrGt)
    fprintf('%s\n',[num2str(nEqualDrGt) '/' num2str(length(DrGtMin)) ' reactions with DrGtMin=DrGtMax~=0' ]);
end

nZeroDrGt=nnz(DrGtMin==0 & DrGtMax==0);
if any(nZeroDrGt)
    fprintf('%s\n',[num2str(nZeroDrGt) '/' num2str(length(DrGtMin)) ' reactions with DrGtMin=DrGtMax=0' ]);
end

[~,nRxn]=size(model.S);

%Reconstruction directions
%only consider internal reactions
fwdRecon=model.lb>=0 & model.ub>0 & model.SIntRxnBool;
revRecon=model.lb<0 & model.ub<=0 & model.SIntRxnBool;
reversibleRecon=model.lb<0 & model.ub>0 & model.SIntRxnBool;
equilibriumRecon=model.lb==0 & model.ub==0 & model.SIntRxnBool;

if any(equilibriumRecon)
    if printLevel>0
        fprintf('%u%s\n',nnz(equilibriumRecon),' inactive reactions (lb = ub = 0)');
    end
end

%sanity check
if nnz(model.SIntRxnBool)~=(nnz(fwdRecon)+nnz(revRecon)+nnz(reversibleRecon))+nnz(equilibriumRecon)
    error('Some reactions directions are not set.');
end

if 0
    hist(model.DrGt0_Uncertainty(model.DrGt0_Uncertainty<100),100)
end
%Thermodynamic data unreliable if estimation uncertainty is high
lowUncertaintyDrGt0=model.DrGt0_Uncertainty <= DrGt0_Uncertainty_Cutoff;
model.directions.lowUncertaintyDrGt0=lowUncertaintyDrGt0;

%Thermo and recon where thermo not available
%only consider internal reactions
forwardThermo=model.DrGtMax<0 & model.SIntRxnBool & lowUncertaintyDrGt0;
reverseThermo=model.DrGtMin>0 & model.SIntRxnBool & lowUncertaintyDrGt0;
reversibleThermo=model.DrGtMin<0 & model.DrGtMax>0 & model.SIntRxnBool & lowUncertaintyDrGt0;
uncertainThermo= ~lowUncertaintyDrGt0 & model.SIntRxnBool;
equilibriumThermo=model.DrGtMax==0 & model.DrGtMin==0 & model.SIntRxnBool & lowUncertaintyDrGt0;

if any(isnan(model.DrGtMax(model.SIntRxnBool)))
    error([int2str(nnz(isnan(model.DrGtMax(model.SIntRxnBool)))) ' DrGtMax are NaN.']);
end

if printLevel>0
    fprintf('%s\n','The following reactions have DrGtMax=DrGtMin=0:')
    printRxnFormula(model,model.rxns(equilibriumThermo));
end
%sanity check
if nnz(model.SIntRxnBool)~=nnz(forwardThermo)+nnz(reverseThermo)+nnz(reversibleThermo)+nnz(uncertainThermo)+nnz(equilibriumThermo)
    disp(model.DrGtMax(model.SIntRxnBool & ~(forwardThermo | reverseThermo | reversibleThermo | uncertainThermo)))
    disp(model.DrGtMin(model.SIntRxnBool & ~(forwardThermo | reverseThermo | reversibleThermo | uncertainThermo)))
    error('Some thermo reactions direction categories are not assigned.');
end

%thermodynamically assigned reaction directionality, where thermodynamic
%data is available, otherwise use the reconstruction bounds
%e.g. we keep exchange bounds the same as for the recostruction
model.lb_reconThermo=model.lb;
model.ub_reconThermo=model.ub;

%use the maximum default bound for internal reactions
if 1
    maxFlux=max([abs(model.lb(model.SIntRxnBool));abs(model.ub(model.SIntRxnBool))]);
else
    maxFlux=Inf;
end
%Thermo and recon where thermo not available
%only consider internal reactions
model.lb_reconThermo(forwardThermo)=0;
model.ub_reconThermo(forwardThermo)=maxFlux;
model.lb_reconThermo(reverseThermo)=-maxFlux;
model.ub_reconThermo(reverseThermo)=0;
model.lb_reconThermo(reversibleThermo)=-maxFlux;
model.ub_reconThermo(reversibleThermo)=maxFlux;

modelThermo=model;

forwardProbability=NaN*ones(nRxn,1);
for n=1:nRxn
    if model.SIntRxnBool(n)
        forwardProbability(n)= normcdf(0,model.DrGt0(n),tValue*model.DrGt0_Uncertainty(n),tValue*model.DrGt0_Uncertainty(n));
        if strcmp(model.rxns{n},'ACYP')
            fprintf('%s\n',model.rxns{n})
        end
    end
end

forwardProbabilityNaN=isnan(forwardProbability) & model.SIntRxnBool;
if any(forwardProbabilityNaN)
    warning([int2str(nnz(forwardProbabilityNaN)) ' forwardProbability are NaN']);
end

if 0
    figure
    plot(model.DrGt0_Uncertainty,model.directions.forwardProbability,'*')
    figure
    hist(forwardProbability(model.SIntRxnBool),100)
end

forwardProbabilityNaN=isnan(forwardProbability) & model.SIntRxnBool;
if any(forwardProbabilityNaN)
    warning([int2str(nnz(forwardProbabilityNaN)) ' forwardProbability are NaN']);
end

directions.forwardProbability=forwardProbability;

%make structue out of directions
directions.forwardRecon=fwdRecon;
directions.reverseRecon=revRecon;
directions.reversibleRecon=reversibleRecon;
directions.equilibriumRecon=equilibriumRecon;

directions.forwardThermo=forwardThermo;
directions.reverseThermo=reverseThermo;
directions.reversibleThermo=reversibleThermo;
directions.uncertainThermo=uncertainThermo;
directions.equilibriumThermo=equilibriumThermo;
end
