function [modelNew] = mergeTwoModels(model1,model2,objrxnmodel)
% 
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
%
% OUTPUT:
%
%    modelNew:         merged model
%
% .. Authors: 
%                   - Aarash Bordbar, 07/06/07 based on[model_metE] = CreateMetE(model_E,model_M)) ();
%                   - Ines Thiele 11/10/2007 
%                   - Thomas Pfau June 2017, adapted to merge all fields.

if ~exist('objrxnmodel','var') || isempty(objrxnmodel)
    objrxnmodel = 1;
end
if ~exist('mergeRxnGeneMat','var') || isempty(mergeRxnGeneMat)
    mergeRxnGeneMat = true;
end

%select the choosen objective, and remove the other. 
if objrxnmodel == 2
    model1.c(:) = 0;
else
    model2.c(:) = 0;
end

%First, we have to merge the genes field, to be able to update the rules field.

showprogress(0, 'Combining Genes in Progress ...');


modelNew = struct();

if isfield(model1, 'genes') || isfield(model2, 'genes')
    %if one is missing create it
    if ~isfield(model1, 'genes')
        model1.genes = {};
    end
    if ~isfield(model2, 'genes')
        model2.genes = {};
    end
    %lets build a merged gene field:
    genes = union(model2.genes,model1.genes); % this will be the new gene field.
    %Now, update the rules fields
    model1 = buildRxnGeneMat(model1);
    model2 = buildRxnGeneMat(model2);
    
    geneIndex = 1:numel(genes)';
    
    %Update the rules for model 1
    [model1genePresence,model1genePos] = ismember(genes,model1.genes);
    oldindices1 = model1genePos(model1genePresence);
    newindices1 = geneIndex(model1genePresence);
    for i = 1:numel(model1.rules)
        if ~isempty(model1.rules{i})            
            model1.rules{i} = updateRule(model1.rules{i},oldindices1(model1.rxnGeneMat(i,:)),newindices1(model1.rxnGeneMat(i,:)));       
        end
    end
    
    %Do the same for model 2;
    [model2genePresence,model2genePos] = ismember(genes,model2.genes);
    oldindices2 = model2genePos(model2genePresence);
    newindices2 = geneIndex(model2genePresence);
    for i = 1:numel(model2.rules)
        if ~isempty(model2.rules{i})
            model2.rules{i} = updateRule(model2.rules{i},oldindices2(model2.rxnGeneMat(i,:)),newindices2(model2.rxnGeneMat(i,:)));
        end
    end
    showprogress(0.1, 'Rules updated ...');
    %now, get the remaining gene associated fields.
    fields1 = getRelevantModelFields(model1,'genes');
    fields1 = setdiff(fields1,{'S','rxnGeneMat'}); % we have to handle these sepaerately
    fields2 = getRelevantModelFields(model2,'genes');
    fields2 = setdiff(fields2,{'S','rxnGeneMat'});
    commonfields = intersect(fields1,fields2);
    [model2genePresence,model2genePos] = ismember(genes,setdiff(model2.genes,model1.genes));
    oldadditionalindices = model2genePos(model2genePresence);
    newadditionalindices = geneIndex(model2genePresence);
    for i = 1:numel(commonfields)
        %The first call is just to get the size and type right.
        modelNew.(commonfields{i}) = [model1.(commonfields{i})(oldindices1); model2.(commonfields{i})(oldadditionalindices)];
        modelNew.(commonfields{i})(newindices1) = model1.(commonfields{i})(oldindices1);
        modelNew.(commonfields{i})(newadditionalindices) = model2.(commonfields{i})(oldadditionalindices);
    end    
    fields1 = setdiff(fields1,commonfields);
    for i = 1:numel(fields1)
        if iscell(model1.(fields1{i}))
            modelNew.(fields1{i})(newindices1) = model1.(fields1{i})(oldindices);
            modelNew.(fields1{i})(newadditionalindices) = {''};
        elseif isnumeric(model1.(fields1{i}))
            modelNew.(fields1{i})(newindices1) = model1.(fields1{i})(oldindices);
            modelNew.(fields1{i})(newadditionalindices) = NaN;
        elseif islogical(model1.(fields1{i}))
            modelNew.(fields1{i})(newindices1) = model1.(fields1{i})(oldindices);
            modelNew.(fields1{i})(newadditionalindices) = false;
        end
    end
    
    fields2 = setdiff(fields2,commonfields);
    [model2genePresence,model2genePos] = ismember(genes,model2.genes);
    oldindices = model2genePos(model2genePresence);
    newindices = geneIndex(model2genePresence);
    otherindices = setdiff(geneIndex,newindices);
    for i = 1:numel(fields2)
        if iscell(model1.(fields2{i}))
            modelNew.(fields2{i})(newindices) = model2.(fields2{i})(oldindices);
            modelNew.(fields2{i})(otherindices) = {''};
        elseif isnumeric(model2.(fields2{i}))
            modelNew.(fields2{i})(newindices1) = model1.(fields2{i})(oldindices);
            modelNew.(fields2{i})(otherindices) = NaN;
        elseif islogical(model2.(fields2{i}))
            modelNew.(fields2{i})(newindices1) = model1.(fields2{i})(oldindices);
            modelNew.(fields2{i})(otherindices) = false;
        end
    end    
end
%Thats the genes done...

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
modelNew.S = model1.S;
%For metabolites which are in both models, we will simply merge the rows.
[metpres,metPos] = ismember(model1.mets,model2.mets);
nRxns = numel(modelNew.rxns);
modelNew.S(metpres,end+1:nRxns) = model2.S(metPos(metpres),:);
[metpres2] = ismember(model2.mets,model1.mets);
S_add = model2.S(~metpres2,:);
modelNew.S = [modelNew.S ;sparse(size(S_add,1),numel(model1.rxns)),S_add];
%now, reduce model2s met fields to those not mapping(i.e. remove those
%mapping
model2red = removeRelevantModelFields(model2,metpres2,'mets', numel(model2.mets));
modelNew = mergeFields(modelNew,model1,model2red,'mets');

showprogress(0.9, 'Finishing touches...');

%finish up by A: removing duplicate reactions
%We will lose information here, but we will just remove the duplicates.
[modelNew,rxnToRemove,rxnToKeep]= checkDuplicateRxn(modelNew,'S',1,0,1);

    

%recreating the rxnGeneMat
modelNew = buildRxnGeneMat(modelNew);

%updating grRules
modelNew = creategrRulesField(modelNew);

%Making the comps fields unique
if(isfield(modelNew, 'comps'))
    [ucomps,ia,ic] = unique(modelNew.comps);
    toKeep = true(size(modelNew.comps));
    toKeep(ia) = false;
    modelNew = removeRelevantModelFields(modelNew,~toKeep,'comps',numel(toKeep));
end


function modelNew = mergeFields(modelNew,model1,model2,type)
% USAGE:
%    [modelNew] = mergeTwoModels(modelNew,model1,model2,type)
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

fields1 = getRelevantModelFields(model1,type);
fields1 = setdiff(fields1,{'S','rxnGeneMat'}); % we have to handle these sepaerately
fields2 = getRelevantModelFields(model2,type);
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
modelNew = updateRelevantModelFields(modelNew,type,'originalSize',nType1,'targetSize',nType1+nType2);
%Now, we will add all the data from model2, and save the default value (in the end.
fields2 = setdiff(fields2,commonfields);
for i = 1:numel(fields2)
    modelNew.(fields2{i}) = model2.(fields2{i});   
end
%We assume, that we only have column vectors here...
modelNew = updateRelevantModelFields(modelNew,type,'originalSize',nType2,'targetSize',nType1+nType2);
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
