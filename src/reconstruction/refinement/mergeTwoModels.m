function [modelNew] = mergeTwoModels(model1, model2, objrxnmodel, mergeRxnGeneMat)
% Merges two models
%
% USAGE:
%
%    [modelNew] = mergeTwoModels(model1, model2, objrxnmodel, mergeRxnGeneMat)
%
% INPUTS:
%    model1:             model 1
%    model2:             model 2
%    objrxnmodel:        Set as 1 or 2 to set objective reaction from
%                        desired model
%    mergeRxnGeneMat:    if false, do not merge `rxnGeneMat`
%
% OUTPUT:
%    modelNew:           merged model
%
% .. Author:
%       - based on[model_metE] = CreateMetE(model_E,model_M)) (Aarash Bordbar, 07/06/07);
%       - IT 11/10/2007 

if ~exist('objrxnmodel','var') || isempty(objrxnmodel)
    objrxnmodel = 1;
end
if ~exist('mergeRxnGeneMat','var') || isempty(mergeRxnGeneMat)
    mergeRxnGeneMat = true;
end

% Creating Universal Metabolite Names
%First, we have to merge the genes field, to update the rules field.

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
            model1.rules{i} = updateRule(model1.rules{i},oldindices1(model1.rxnGeneMat(:,i)),newindices1(model1.rxnGeneMat(:,i)));       
        end
    end
    %Do the same for model 2;
    [model2genePresence,model2genePos] = ismember(genes,model2.genes);
    oldindices2 = model2genePos(model2genePresence);
    newindices2 = geneIndex(model2genePresence);
    for i = 1:numel(model2.rules)
        if ~isempty(model2.rules{i})
            model2.rules{i} = updateRule(model2.rules{i},oldindices2(model2.rxnGeneMat(:,i)),newindices2(model2.rxnGeneMat(:,i)));
        end
    end
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
    modelNew = removeRelevantModelFields(modelNew,~toKeep,'comps');
end
% 
% 
% 
% 
% sizemets = size(modelNew.mets,1)+1;
% HTABLE = java.util.Hashtable;
% for i = 1:length(model1.mets)
%     HTABLE.put(model1.mets{i}, i);
% end
% 
% for i = 1:size(model2.mets,1)
%     %tmp2 = strmatch(model2.mets(i,1),model1.mets,'exact')
%     tmp = HTABLE.get(model2.mets{i,1});
% %     if ~isempty(tmp) || ~isempty(tmp2)
% %         if any(tmp2 ~= tmp)
% %             pause;
% %         end
% %     end
%     if isempty(tmp) == 1
%         modelNew.mets(sizemets,1) = model2.mets(i,1);
%         if isfield(model1,'metNames') && isfield(model2,'metNames') && length(model2.metNames)>0
%             modelNew.metNames(sizemets,1) = model2.metNames(i,1);
%         end
%         if isfield(model1,'metFormulas') && isfield(model2,'metFormulas')&& length(model2.metFormulas)>0
%             modelNew.metFormulas(sizemets,1) = model2.metFormulas(i,1);
%         end
%         % causes errors when joining with enterocyte model
%          if isfield(model1,'metCharges')&& isfield(model2,'metCharges')&& length(model2.metCharges)>0
%              modelNew.metCharges(sizemets,1) = model2.metCharges(i,1);
%          end
%         sizemets = sizemets+1;
%     end
%     showprogress(i/size(model2.mets,1));
% end
% 
% lengthmet = size(modelNew.mets,1);
% fprintf('Finished, %i Distinct Metabolites\n',lengthmet);
% 
% 
% % Combining lb List
% fprintf('Combining LB list: ');
% modelNew.lb = model1.lb;
% floatingmodel = model2.lb;
% modelNew.lb(size(model1.lb,1)+1:size(model1.lb,1)+size(model2.lb,1),1) = floatingmodel;
% fprintf('Finished\n');
% 
% % Combining ub List
% fprintf('Combining UB list: ');
% modelNew.ub = model1.ub;
% modelNew2.ub = model2.ub;
% modelNew.ub(size(model1.ub,1)+1:size(model1.ub,1)+size(model2.ub,1),1) = modelNew2.ub;
% fprintf('Finished\n');
% 
% % Combining subsystem List
% fprintf('Combining Subsystem List: ');
% modelNew.subSystems = model1.subSystems;
% modelNew.subSystems(size(model1.subSystems,1)+1:size(model1.subSystems,1)+size(model2.subSystems)) = model2.subSystems;
% modelNew.rxnNames = model1.rxnNames;
% modelNew.rxnNames(size(model1.rxnNames,1)+1:size(model1.rxnNames,1)+size(model2.rxnNames)) = model2.rxnNames;
% if isfield(model1,'rxnKEGGID') && isfield(model2,'rxnKEGGID')
%     modelNew.rxnKEGGID = model1.rxnKEGGID;
%     modelNew.rxnKEGGID(size(model1.rxnKEGGID,1)+1:size(model1.rxnKEGGID,1)+size(model2.rxnKEGGID)) = model2.rxnKEGGID;
% end
% if isfield(model1,'rxnConfidenceEcoIDA') && isfield(model2,'rxnConfidenceEcoIDA')
%     modelNew.rxnConfidenceEcoIDA = model1.rxnConfidenceEcoIDA;
%     modelNew.rxnConfidenceEcoIDA(size(model1.rxnConfidenceEcoIDA,1)+1:size(model1.rxnConfidenceEcoIDA,1)+size(model2.rxnConfidenceEcoIDA)) = model2.rxnConfidenceEcoIDA;
% end
% if isfield(model1,'rxnConfidenceScores') && isfield(model2,'rxnConfidenceScores')
%     modelNew.rxnConfidenceScores = model1.rxnConfidenceScores;
%     modelNew.rxnConfidenceScores(size(model1.rxnConfidenceScores,1)+1:size(model1.rxnConfidenceScores,1)+size(model2.rxnConfidenceScores)) = model2.rxnConfidenceScores;
% end
% if isfield(model1,'rxnsboTerm') && isfield(model2,'rxnsboTerm')
%     modelNew.rxnsboTerm = model1.rxnsboTerm;
%     modelNew.rxnsboTerm(size(model1.rxnsboTerm,1)+1:size(model1.rxnsboTerm,1)+size(model2.rxnsboTerm)) = model2.rxnsboTerm;
% end
% if isfield(model1,'rxnReferences') && isfield(model2,'rxnReferences')
%     modelNew.rxnReferences = model1.rxnReferences;
%     modelNew.rxnReferences(size(model1.rxnReferences,1)+1:size(model1.rxnReferences,1)+size(model2.rxnReferences)) = model2.rxnReferences;
% end
% if isfield(model1,'rxnECNumbers') && isfield(model2,'rxnECNumbers')
%     modelNew.rxnECNumbers = model1.rxnECNumbers;
%     modelNew.rxnECNumbers(size(model1.rxnECNumbers,1)+1:size(model1.rxnECNumbers,1)+size(model2.rxnECNumbers)) = model2.rxnECNumbers;
% end
% if isfield(model1,'rxnNotes') && isfield(model2,'rxnNotes')
%     modelNew.rxnNotes = model1.rxnNotes;
%     modelNew.rxnNotes(size(model1.rxnNotes,1)+1:size(model1.rxnNotes,1)+size(model2.rxnNotes)) = model2.rxnNotes;
% end
% 
% fprintf('Finished\n');
% 
% % Combining S Matrices (using sparse allocation)
% fprintf('Combining S matrices: ');
% [a1,b1] = find(model1.S);
% [a2,b2] = find(model2.S);
% model1_num = length(a1);
% model2_num = length(a2);
% modelNew.S = spalloc(size(modelNew.mets,1),size(modelNew.rxns,1),model1_num+model2_num);
% 
% showprogress(0, 'Adding Matrix 1 in Progress ...');
% for i = 1:size(a1,1)
%     modelNew.S(a1(i),b1(i)) = model1.S(a1(i),b1(i));
%     showprogress(i/size(a1,1));
% end
% 
% HTABLE = java.util.Hashtable;
% for i = 1:length(modelNew.mets)
%     HTABLE.put(modelNew.mets{i}, i);
% end
% 
% showprogress(0, 'Adding Matrix 2 in Progress ...');
% for i = 1:size(model2.S,2)
%     compounds = find(model2.S(:,i));
%     for j = 1:size(compounds,1)
%         metnames(j,1) = model2.mets(compounds(j));
%         tmp = HTABLE.get(metnames{j,1});
%         modelNew.S(tmp,i+size(model1.S,2)) = model2.S(compounds(j),i);
%     end
%     showprogress(i/size(model2.S,2));
% end
% 
% 
% fprintf('Finished\n');
% 
% % Creating b
% fprintf('Combining b lists: ');
% modelNew.b = zeros(size(modelNew.mets,1),1);
% fprintf('Finished\n');
% 
% % Creating c (no objective function optimization)
% fprintf('Combining c lists: ');
% modelNew.c = zeros(size(modelNew.rxns,1),1);
% fprintf('Finished\n');
% 
% % Optimization Parameters in modelNew.c
% fprintf('Setting up optimization parameters: ');
% switch objrxnmodel
%     case 1
%         modelNew.c(find(model1.c),1) = 1;
%     case 2
%         modelNew.c(find(model2.c)+size(model1.c,1),1) = 1;
% end
% fprintf('Finished\n');
% 
% 
% % % Creating GPR Rules
% fprintf('Combining Genes: ');
% modelNew.genes = model1.genes;
% a=1;
% for i = 1:length(model2.genes)
%     if isempty(strmatch(model2.genes{i},modelNew.genes,'exact')) == 1
%         modelNew.genes(size(model1.genes,1)+a) = model2.genes(i);
%         a=a+1;
%     end
% end
% fprintf('Finished\n');
% 
% if mergeRxnGeneMat
% fprintf('Combining Remaining Genetic Information: ');
% showprogress(0, 'Combining Genetic Info ...');
% end
% 
% modelNew.rxnGeneMat = model1.rxnGeneMat;
% 
% for i = 1:size(model2.rxnGeneMat,1)
%     R = find(model2.rxnGeneMat(i,:));
%     if ~isempty(R)
%         for j = 1:length(R)
%             geneLoc = find(ismember(modelNew.genes,model2.genes(R(j))));
%             T = find(ismember(modelNew.rxns,model2.rxns(i)));
%             modelNew.rxnGeneMat(T,geneLoc) = 1;
%         end
%     else
%         T = find(ismember(modelNew.rxns,model2.rxns(i)));
%         modelNew.rxnGeneMat(T,:) = 0;
%     end
%     showprogress(i/size(model2.rxnGeneMat,1));
% end
% 
% modelNew.grRules = model1.grRules;
% modelNew.grRules(size(model1.grRules,1)+1:size(model1.grRules,1)+size(model2.grRules,1)) = model2.grRules;
% if isfield(model1,'rules')
%     modelNew.rules = model1.rules;
%     modelNew.rules(size(model1.rules,1)+1:size(model1.rules,1)+size(model2.rules,1)) = model2.rules;
% end
fprintf('Finished\n');


function modelNew = mergeFields(modelNew,model1,model2,type)
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
