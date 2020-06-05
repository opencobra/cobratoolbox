function [modelNew] = mergeTwoModels(model1,model2,objrxnmodel, mergeGenes)
% Merge two models. If fields conflict, the data from fields in model1 will be
% used.
% USAGE:
%    [modelNew] = mergeTwoModels(model1,model2,objrxnmodel)
%
% INPUTS:
%
%    model1:          model 1
%    model2:          model 2
%
% OPTIONAL INPUTS:
%    objrxnmodel:     Set as 1 or 2 to set objective reaction from
%                     desired model
%    mergeGenes:      Do merge the gene associated data, if false the genes 
%                     field and the rules field will be cleared and other fields 
%                     associated with genes will not be merged. GPR rules can be 
%                     reconstructed using the grRules field.(Default = true)
%
% OUTPUT:
%
%    modelNew:         merged model
%
% .. Authors:
%                   - Aarash Bordbar, 07/06/07 based on[model_metE] = CreateMetE(model_E,model_M)) ();
%                   - Ines Thiele 11/10/2007
%                   - Thomas Pfau June 2017, adapted to merge all fields.
%

if ~exist('objrxnmodel','var') || isempty(objrxnmodel)
    objrxnmodel = 1;
end
if ~exist('mergeGenes','var') || isempty(mergeGenes)
    mergeGenes = true;
end

modelNew = struct();

%select the choosen objective, and remove the other.
if objrxnmodel == 2
    model1.c(:) = 0;    
    if isfield(model2,'osenseStr')
        modelNew.osenseStr = model2.osenseStr;
    end
else
    model2.c(:) = 0;
    if isfield(model1,'osenseStr')
        modelNew.osenseStr = model1.osenseStr;
    end
end

%First, we have to merge the genes field, to be able to update the rules field.
if mergeGenes
    showprogress(0, 'Combining Genes in Progress ...');
    
    if isfield(model1, 'genes') || isfield(model2, 'genes')
        %if one is missing create it
        if ~isfield(model1, 'genes')
            model1.genes = {};
        end
        if ~isfield(model2, 'genes')
            model2.genes = {};
        end
        model2genes = model2.genes;
        model1genes = model1.genes;
        %lets build a merged gene field:
        genes = union(model2.genes,model1.genes); % this will be the new gene field.
        
        %Add missing genes to both models
        model2 = addGenes(model2,setdiff(genes,model2.genes));
        model1 = addGenes(model1,setdiff(genes,model1.genes));
        
        %Determine positions unique to model2
        uniqueModel2Pos = ismember(genes,model2genes) & ~ismember(genes,model1genes);
        
        %Update the order of the genes in both models to match "genes"
        [model2Pres,model2Pos] = ismember(genes,model2.genes);
        model2 = updateFieldOrderForType(model2,'genes',model2Pos(model2Pres));
        [model1Pres,model1Pos] = ismember(genes,model1.genes);
        model1 = updateFieldOrderForType(model1,'genes',model1Pos(model1Pres));
        
        %Now, add all gene fields to the new model.       
        fields1 = getModelFieldsForType(model1,'genes');
        fields1 = setdiff(fields1,{'S','rxnGeneMat'}); % we have to handle these sepaerately
        fields2 = getModelFieldsForType(model2,'genes');
        fields2 = setdiff(fields2,{'S','rxnGeneMat'}); % we have to handle these sepaerately
        commonFields = intersect(fields1,fields2);
        model1Fields = setdiff(fields1,fields2);
        model2Fields = setdiff(fields2,fields1);
        for i = 1 : numel(commonFields)
            modelNew.(commonFields{i}) = model1.(commonFields{i});
            modelNew.(commonFields{i})(uniqueModel2Pos) = model2.(commonFields{i})(uniqueModel2Pos);
        end
        for i = 1 : numel(model1Fields)
            modelNew.(model1Fields{i}) = model1.(model1Fields{i});
        end
        for i = 1 : numel(model2Fields)
            modelNew.(model2Fields{i}) = model2.(model2Fields{i});            
        end
        
    end
    %Thats the genes done...
end
% Combining Reaction List
showprogress(0.25, 'Combining reaction lists ...');
modelNew = mergeFields(modelNew,model1,model2,'rxns');

% Combining Metabolite List
fprintf('Combining metabolite lists: ');


%And Compartments
if isfield(model1,'comps') || isfield(model2, 'comps')
    showprogress(0.5, 'Combining comp fields lists ...');
    
    if ~isfield(model1, 'comps')
        model1.comps = {};
    end
    if ~isfield(model2, 'comps')
        model2.comps = {};
    end
    modelNew = mergeFields(modelNew,model1,model2,'comps');
end

%For metabolites, this is slightly different.
%Set the stoichiometric matrix to that of model1
showprogress(0.7, 'Combining mets and setting up S ...');
%For metabolites which are in both models, we will simply merge the rows.
[metpres,metPos] = ismember(model1.mets,model2.mets);
nRxns = numel(modelNew.rxns);
%For some reason, R2014b does not extend the spare matrix in this
%instance.
[nMetsM1,nRxnsM1] = size(model1.S);
modelNew.S = sparse(numel(model1.mets),nRxns);
modelNew.S(1:nMetsM1,1:nRxnsM1) = model1.S;
modelNew.S(metpres,nRxnsM1+1:nRxns) = model2.S(metPos(metpres),:);
[metpres2] = ismember(model2.mets,model1.mets);
S_add = model2.S(~metpres2,:);
modelNew.S = [modelNew.S ;sparse(size(S_add,1),numel(model1.rxns)),S_add];
%now, reduce model2s met fields to those not mapping(i.e. remove those
%mapping
model2red = removeFieldEntriesForType(model2,metpres2,'mets', numel(model2.mets));
modelNew = mergeFields(modelNew,model1,model2red,'mets');

showprogress(0.9, 'Finishing touches...');

%finish up by A: removing duplicate reactions
%We will lose information here, but we will just remove the duplicates.
%[modelNew,rxnToRemove,rxnToKeep]= checkDuplicateRxn(modelNew,'S',1,0,1);

%Check, that there are no duplicated IDs in the primary key fields.
ureacs = unique(modelNew.rxns);
if ~(numel(modelNew.rxns) == numel(ureacs))
    error(['The following reactions were present in both models but had distinct stoichiometries:\n',...
    strjoin(ureacs(cellfun(@(x) sum(ismember(modelNew.rxns,x)) > 1,ureacs)),', ')]);
end

if mergeGenes && (isfield(model1,'rxnGeneMat') || isfield(model2, 'rxnGeneMat'))
    %recreating the rxnGeneMat
    modelNew = buildRxnGeneMat(modelNew);    
end
if ~mergeGenes
    % clear all gene information
    modelNew.rules = repmat({''},size(modelNew.rxns));
    modelNew.genes = cell(0,1);    
end

%Making the comps fields unique
if(isfield(modelNew, 'comps'))
    [ucomps,ia,ic] = unique(modelNew.comps);
    toKeep = false(size(modelNew.comps));
    toKeep(ia) = true;
    modelNew = removeFieldEntriesForType(modelNew,~toKeep,'comps',numel(toKeep));
end
showprogress(1.0, 'Finished merging models ...');
fprintf('\n');



function modelNew = mergeFields(modelNew,model1,model2,type)
% USAGE:
%    [modelNew] = mergeFields(modelNew,model1,model2,type)
%
% INPUTS:
%    modelNew:        The new Structure with all fields created till now
%    model1:          model 1 to merge
%    model2:          model 2 to merge
%    type:            the field type to merge ( rxns, mets, comps or genes)
%
%
% OUTPUT:
%
%    modelNew:         merged model with all fields of the given type
%                      merged (i.e. added. the resulting fields will have
%                      elements of model1 if any followed by elements of
%                      model2 if any (missing values replaced by defaults).
%                      Char arrays are currenty not merged, default
%                      unclear.
%
% .. Authors:
%                   - Thomas Pfau June 2017

fields1 = getModelFieldsForType(model1,type);
fields1 = setdiff(fields1,{'S','rxnGeneMat'}); % we have to handle these sepaerately
fields2 = getModelFieldsForType(model2,type);
fields2 = setdiff(fields2,{'S','rxnGeneMat'}); % we have to handle these sepaerately
commonfields = intersect(fields1,fields2);
nType1 = numel(model1.(type));
nType2 = numel(model2.(type));
for i = 1:numel(commonfields)
    try
        modelNew.(commonfields{i}) = [model1.(commonfields{i}); model2.(commonfields{i})];
    catch
        disp('test')
    end
end
fields1 = setdiff(fields1,commonfields);
for i = 1:numel(fields1)
    modelNew.(fields1{i}) = [model1.(fields1{i})];
end
modelNew = extendModelFieldsForType(modelNew,type,'originalSize',nType1,'targetSize',nType1+nType2);
%Now, we will add all the data from model2, and save the default value (in the end.
fields2 = setdiff(fields2,commonfields);
for i = 1:numel(fields2)
    modelNew.(fields2{i}) = model2.(fields2{i});
end
%We assume, that we only have column vectors here...
modelNew = extendModelFieldsForType(modelNew,type,'originalSize',nType2,'targetSize',nType1+nType2);
for i = 1:numel(fields2)
    default = modelNew.(fields2{i})(end);
    modelNew.(fields2{i})(nType1+1:end) = model2.(fields2{i});
    modelNew.(fields2{i})(1:nType1) = default;
end
%These are all non stoichiometry fields done.


function rule = updateRule(rule,oldpos,newpos)
for i = 1:numel(oldpos)
    rule = strrep(rule,['x(' num2str(oldpos(i)) ')'],['x(' num2str(newpos(i)) ')']);
end
