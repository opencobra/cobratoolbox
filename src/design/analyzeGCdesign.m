function [improvedRxns,intermediateSlns] = analyzeGCdesign(modelRed,selectedRxns,target,deletions,maxKOs,objFunction,delPenalty,intermediateSlns)
% Analyzes results with replacement knockouts
% should get closer to local maxima.  must have num `KOs` > 1
%
% USAGE:
%
%    [improvedRxns, intermediateSlns] = analyzeGCdesign(modelRed, selectedRxns, target, deletions, maxKOs, objFunction, delPenalty, intermediateSlns)
%
% INPUTS:
%    modelRed:          reduced model
%    selectedRxns:      selected reaction list from the reduced model
%    target:            exchange `rxn` to optimize
%    deletions:         initial set of `KO` `rxns` (must have at least 1 rxn)
%
% OPTIONAL INPUTS:
%    maxKOs:            maximum number of `rxn` `KOs` to allow (Default = 10)
%    objFunction:       pick an objective function to use (Default = 1):
%
%                       1.  `obj = maxRate` (yield)
%                       2.  `obj = growth*maxRate` (SSP)
%                       3.  `obj = maxRate*(delPenalty^numDels)` (yield with KO penalty)
%                       4.  `obj = growth*maxRate*(delPenalty^numDels)`  (SSP with KO penalty)
%                       5.  `obj = maxRate*(slope^(-1))`  (GC_yield)
%                       6.  `obj = growth*maxRate*(slope^(-1))`  (GC_SSP)
%                       7.  `obj = maxRate*(delPenalty^numDels)*(slope^(-1))` (GC_yield with KO penalty)
%                       8.  `obj = growth*maxRate*(delPenalty^numDels)*(slope^(-1))`  (GC_SSP with KO penalty)
%    delPenalty:        penalty on extra `rxn` deletions (Default = .99)
%    intermediateSlns:  Previous set of solutions (Default = deletions)
%
% OUTPUTS:
%    improvedRxns:      the `KO` `rxns` for an improved strain
%    intermediateSlns:  all the sets of best `KO` `rxns` that are picked before the
%                       final set is reached
% .. Authors:
%       - Jeff Orth  7/25/07
%       - Richard Que 1/19/10       Replaced try/catch blocks

if (nargin < 5)
    maxKOs = 10;
end
if (nargin < 6)
    objFunction = 1;
end
if (nargin < 7)
    delPenalty = .99;
end
if (nargin < 8)
    intermediateSlns = {deletions};
end

%set the objective function
switch objFunction
    case 1
        objectiveFunction = 'maxRate';
        hasSlope = false;
    case 2
        objectiveFunction = 'growth*maxRate';
        hasSlope = false;
    case 3
        objectiveFunction = 'maxRate*(delPenalty^numDels)';
        hasSlope = false;
    case 4
        objectiveFunction = 'growth*maxRate*(delPenalty^numDels)';
        hasSlope = false;
    case 5
        objectiveFunction = 'maxRate*(slope^(-1))';
        hasSlope = true;
    case 6
        objectiveFunction = 'growth*maxRate*(slope^(-1))';
        hasSlope = true;
    case 7
        objectiveFunction = 'maxRate*(delPenalty^numDels)*(slope^(-1))';
        hasSlope = true;
    case 8
        objectiveFunction = 'growth*maxRate*(delPenalty^numDels)*(slope^(-1))';
        hasSlope = true;
end

if isempty(deletions)
    error('no knockout reactions defined')
end

delArraySize = size(deletions); %make sure deletions list is horizontal
if delArraySize(1) > 1
    rxns = deletions';
else
    rxns = deletions;
end

BOF = modelRed.rxns(modelRed.c==1); %get biomass objective function


modelKO = changeRxnBounds(modelRed,rxns,0,'b');
FBAsol1 = optimizeCbModel(modelKO,'max',true); %find max growth rate of strain
if FBAsol1.stat>0
    modelKOfixed = changeRxnBounds(modelKO,BOF,FBAsol1.f-1e-6,'l'); %fix the growth rate
    modelKOfixed = changeObjective(modelKOfixed,target); %set target as the objective
    FBAsol2 = optimizeCbModel(modelKOfixed,'min',true); %find minimum target rate at this growth rate
    growth = FBAsol1.f;
    maxRate = FBAsol2.f;
    numDels = length(rxns);

    if hasSlope %only calculate these if the obj function includes slope
        modelTarget = changeObjective(modelKO,target); %set target as the objective
        FBAsol4 = optimizeCbModel(modelTarget,'min',true); %find min production rate
        modelTargetFixed = changeRxnBounds(modelKO,target,FBAsol4.f,'b'); %fix production to minimum
        FBAsol5 = optimizeCbModel(modelTargetFixed,'max',true); %find max growth at min production
        minProdRate = FBAsol4.f;
        maxGrowthMinRate = FBAsol5.f;

        if growth ~= maxGrowthMinRate
            slope = (maxRate-minProdRate)/(growth-maxGrowthMinRate);
        else
            slope = 1; %don't consider slope if div by 0
        end
    end

    objective = eval(objectiveFunction);

    bestObjective = objective
    bestRxns = rxns;
    % if the initial reactions are lethal
else
    bestObjective = 0
    bestRxns = rxns;
end

% loop through each KO rxn and replace with every rxn from selectedRxns to
% search for a possible improvement
showprogress(0, 'improving knockout design');
for i = 1:length(rxns)+1
    bestObjective2 = bestObjective;
    bestRxns2 = bestRxns;
    for j = 1:length(selectedRxns)+1
        showprogress((j+(i-1)*length(selectedRxns))/((length(rxns)+1)*(length(selectedRxns)+1)));
        newRxns = rxns;
        if (i==length(rxns)+1)&&(j==length(selectedRxns)+1)
            %don't do anything at the very end
        elseif j ~= length(selectedRxns)+1
            newRxns{i} = selectedRxns{j}; %replace rxn with different one
        elseif i == 1 %or else remove one of the rxns
            newRxns = rxns(2:length(rxns));
        elseif i == length(rxns)
            newRxns = rxns(1:length(rxns)-1);
        else
            newRxns = cat(2,rxns(1:i-1),rxns(i+1:length(rxns)));
        end

        if length(newRxns) <= maxKOs %limit the total number of knockouts

            modelKO = changeRxnBounds(modelRed,newRxns,0,'b');
            FBAsol1 = optimizeCbModel(modelKO,'max',true); %find max growth rate of strain
            if FBAsol1.stat>0
                modelKOfixed = changeRxnBounds(modelKO,BOF,FBAsol1.f-1e-6,'l'); %fix the growth rate
                modelKOfixed = changeObjective(modelKOfixed,target); %set target as the objective
                FBAsol2 = optimizeCbModel(modelKOfixed,'min',true); %find minimum target rate at this growth rate
                FBAsol3 = optimizeCbModel(modelKOfixed,'max',true); %find maximum target rate at this growth rate
                growth = FBAsol1.f;
                maxRate = FBAsol2.f;
                numDels = length(newRxns);

                if hasSlope %only calculate these if the obj function includes slope
                    modelTarget = changeObjective(modelKO,target); %set target as the objective
                    FBAsol4 = optimizeCbModel(modelTarget,'min',true); %find min production rate
                    modelTargetFixed = changeRxnBounds(modelKO,target,FBAsol4.f,'b'); %fix production to minimum
                    FBAsol5 = optimizeCbModel(modelTargetFixed,'max',true); %find max growth at min production
                    minProdRate = FBAsol4.f;
                    maxGrowthMinRate = FBAsol5.f;

                    if growth ~= maxGrowthMinRate
                        slope = (maxRate-minProdRate)/(growth-maxGrowthMinRate);
                    else
                        slope = 1; %don't consider slope if div by 0
                    end
                end

                newObjective = eval(objectiveFunction);

                %see if objective is increased by this new gene
                if newObjective > bestObjective2
                    bestObjective2 = newObjective
                    bestRxns2 = newRxns
                    intermediateSlns{length(intermediateSlns)+1} = bestRxns2; %add new intermediateSln to the list
                end
            end
        end
    end

    if bestObjective2 > bestObjective
        bestObjective = bestObjective2
        bestRxns = bestRxns2
    end
end

bestObjective
bestRxns

% recursively call analyzeGCdesign again until no improvement is found
if length(bestRxns) ~= length(rxns)
    [bestRxns,intermediateSlns] = analyzeGCdesign(modelRed,selectedRxns,target,bestRxns,maxKOs,objFunction,delPenalty,intermediateSlns);
elseif length(find(strcmp(bestRxns,rxns)))~=length(rxns)
    [bestRxns,intermediateSlns] = analyzeGCdesign(modelRed,selectedRxns,target,bestRxns,maxKOs,objFunction,delPenalty,intermediateSlns);
end

% print final results
improvedRxns = sort(bestRxns)
