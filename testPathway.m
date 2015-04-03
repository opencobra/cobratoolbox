function [Flux FBAsolution model]= testPathway(model, MetIn,MetOut,AdditionalMetsInorOut,ObjectiveOption)
% this gapfiling function allows the user to see if given one metabolite A,
% downstream metabolite B can be made made. Additional sinks can be added
% for co-factors if needed
%           A -->-->-->-->--> B
%INPUTS
% model                 COBRA model structure
% MetIn                 The input metabolite(s) (A)
% MetOut                The output metabolite (B)
%
%OPTIONAL INPUTS
% AdditionalMetsInorOut Additional metabolites for which sinks will be added
% ObjectiveOption       1 = objective will be production of B (default)
%                       0 = use objective in model
% 
%OUTPUTS
% Flux                  The rate of B production
% FBAsolution           
% model                 COBRA model with sinks in it
% 
% Nathan Lewis Feb 16 2009

if ~iscell(MetIn)
    Met = MetIn; clear MetIn; MetIn{1} = Met;
end
if ~iscell(MetOut)
    Met = MetOut; clear MetOut; MetOut{1} = Met;
end
if nargin > 3
    if ~iscell(AdditionalMetsInorOut)
        Met = AdditionalMetsInorOut; clear AdditionalMetsInorOut; AdditionalMetsInorOut{1} = Met;
    end
    % add sink rxns for all AdditionalMetsInorOut
    for i = 1:length(AdditionalMetsInorOut)
        model = addReaction(model,cat(2,'Tempsink_',AdditionalMetsInorOut{i}),{AdditionalMetsInorOut{i} },-1 ,true);
    end
end
if nargin <5,ObjectiveOption=1;end

for i = 1:length(MetIn) % add inputs
    model = addReaction(model,cat(2,'TempInput_',MetIn{i}),{MetIn{i} },1 ,false);
end
[model, rxnExists] = addReaction(model,cat(2,'TempOutput_',MetOut{1}),{MetOut{1} },-1 ,false);
if (ObjectiveOption==1 && isempty(rxnExists))
	model = changeObjective(model,cat(2,'TempOutput_',MetOut{1}));
elseif (ObjectiveOption == 1 && ~isempty(rxnExists))
	model = changeObjective(model,model.rxns(rxnExists));
end
FBAsolution = optimizeCbModel(model,'max');
Flux = FBAsolution.f;
if ~isempty(FBAsolution.x)
%printFluxVector(model,FBAsolution.x);
else display('zero flux in network')
end