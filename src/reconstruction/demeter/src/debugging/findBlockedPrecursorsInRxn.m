function [blockedPrecursors,enablingMetsEach,enablingMetsAll]=findBlockedPrecursorsInRxn(model,reactionToTest,osenseStr)
% This function identifies metabolites in a reaction of interest (e.g.,
% biomass objective function) that cannot be produced or consumed and are
% preventing flux through the reaction. Metabolites that could restore flux
% through the reaction if they ould be either consumed or produced are
% provided if they can be identified.
%
%
% USAGE
%   [blockedPrecursors,enablingMets]=findBlockePrecursorsInRxn(model,reactionToTest,osenseStr)
%
% INPUT
% model               COBRA model structure
% reactionToTest      Abbreviation for reaction to test (e.g., biomass
%                     objective function)
%
% OPTIONAL INPUTS
% osenseStr           Maximize ('max')/minimize ('min') (opt, default = 'max')
%
%
% OUTPUTS
% blockedPrecursors   Metabolite in the reaction to test (e.g., the biomass
%                     objective function) that cannot be produced or
%                     consumed and are preventing flux
% enablingMetsEach    Metabolites that each would restore flux through the 
%                     reaction to test if they could be either produced or 
%                     consumed, and associated reactions in the model
% enablingMetsAll     Metabolites that taken together would restore flux 
%                     through the reaction to test if they could be either 
%                     produced or consumed, and associated reactions in the 
%                     model
%
%
%   - AUTHOR
%   Almut Heinken, 07/2020

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end

tol=0.0000001;

if ~exist('osenseStr','var')
    osenseStr='max';
end

blockedPrecursors={};
enablingMetsEach={};
enablingMetsAll={};

model=changeObjective(model,reactionToTest);
FBA = optimizeCbModel(model,osenseStr);
if FBA.f > tol
    fprintf('Reaction %s can carry flux. Exiting function.\n',reactionToTest)
else
    % Find out which biomass precursors cannot be synthesized
    [missingMets, ~] = biomassPrecursorCheck(model);
    % remove cycling metabolites that are always an output
    [C,IA]=intersect(missingMets,{'ACP[c]','apoACP[c]','PGP[c]','PGPm1[c]'});
    missingMets(IA)=[];
    blockedPrecursors=missingMets;
    
    % find out which metabolites can enable growth
    addedSinkReactions=[];
    for i=1:length(model.mets)
        modelSink=addSinkReactions(model,{model.mets{i}});
        modelSink=changeRxnBounds(modelSink,['sink_' model.mets{i}],-1,'l');
        FBA = optimizeCbModel(modelSink,osenseStr);
        findTestRxn=find(strcmp(modelSink.rxns,['sink_' model.mets{i}]));
        addedSinkReactions(i,1) = FBA.f;
        addedSinkReactions(i,2) = FBA.x(findTestRxn);
    end
    findInd=find(addedSinkReactions(:,1)>tol);
    if ~isempty(findInd)
        for i=1:length(findInd)
            enablingMetsEach{i,1}=model.mets{findInd(i)};
            if addedSinkReactions(findInd,2)>0
                enablingMetsEach{i,2}='Consumed';
            elseif addedSinkReactions(findInd,2)<0
                enablingMetsEach{i,2}='Taken up';
            end
        end
        
        % print out the reaction formulas for metabolites enabling growth
        for i=1:size(enablingMetsEach,1)
            rxns=findRxnsFromMets(model,enablingMetsEach{i,1});
            cnt=3;
            for j=1:length(rxns)
                form=printRxnFormula(model,rxns{j});
                enablingMetsEach{i,cnt}=rxns{j};
                enablingMetsEach{i,cnt+1}=form;
                cnt=cnt+2;
            end
        end
        
    else
        % try adding sink reactions for multiple metabolites
        enablingMetsAll={};
        cnt=1;
        % run loop multiple times
        for t=1:10
            model_old=model;
            addedSinkReactions=[];
            for i=1:length(model.mets)
                model=addSinkReactions(model,{model.mets{i}});
                model=changeRxnBounds(model,['sink_' model.mets{i}],-1,'l');
                FBA = optimizeCbModel(model,osenseStr);
                findTestRxn=find(strcmp(model.rxns,['sink_' model.mets{i}]));
                addedSinkReactions(i,1) = FBA.f;
                addedSinkReactions(i,2) = FBA.x(findTestRxn);
                if FBA.f > tol
                    break
                end
            end
            enablingMetsAll{cnt,1}=model.mets{size(addedSinkReactions,1),1};
            if addedSinkReactions(size(addedSinkReactions,1),2)>0
                enablingMetsAll{cnt,2}='Consumed';
            elseif addedSinkReactions(size(addedSinkReactions,1),2)<0
                enablingMetsAll{cnt,2}='Taken up';
            end
            model=model_old;
            model=addSinkReactions(model,{enablingMetsAll{cnt,1}});
            cnt=cnt+1;
            FBA = optimizeCbModel(model,osenseStr);
            if FBA.f > tol
                break
            end
        end
        if ~isempty(enablingMetsAll)
            for i=1:length(enablingMetsAll)
                rxns=findRxnsFromMets(model,enablingMetsAll{i,1});
                cnt=3;
                for j=1:length(rxns)
                    form=printRxnFormula(model,rxns{j});
                    enablingMetsAll{i,cnt}=rxns{j};
                    enablingMetsAll{i,cnt+1}=form;
                    cnt=cnt+2;
                end
            end
        else
            warning('No metabolites that can restore flux through reaction %s could be found!\n',reactionToTest)
        end
    end
end

end
