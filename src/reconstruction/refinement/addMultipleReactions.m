function newmodel = addMultipleReactions(model,rxnIDs,metList,Stoichiometries,varargin)
% Add multiple Reactions to the model. In contrast to addReaction, this
% function allows the addition of multiple reactions at once but requires
% all used metabolites to be already present in the model. 
% USAGE:
%
%    newmodel = addMultipleReactions(model,rxnIDs,metList,Stoichiometries,varargin)
%
% INPUTS:
%    model:             The model to add the Metabolite batch to.
%    rxnIDs:            The IDs of the reactions that shall be added.
%    metList:           A list of metabolites for which stoichiometric coefficients are given
%    Stoichiometries:   A Stoichiometric matrix of dimension
%                       numel(metList) x numel(rxnID).
% OPTIONAL INPUTS:
%    varargin:          fieldName, Value pairs. The given fields will be set
%                       according to the values. Only defined COBRA fields may be
%                       used. The following fields will be ignored (as they
%                       are dependent on the existing model structure):
%                       S - this is being resolved by the
%                       metList/Stoichiometries combination
%                       rxnGeneMat - This depends on the original model structure, and is thus nor considered.
%                       You can provide GPR rules in different ways to
%                       this function:
%                       1. By providing a grRules array in the varargin
%                       2. By providing a genes field in the varargin and a
%                       corresponding rules field
%                       3. By providing a rules field, that directly refers
%                       to the genes in the model.
%                       Examples of parameters are:
%                       'rxnNames',{'RuBisCo','Transketloase'}
%                       'rxnKEGGID,{'R00024','R01641'}
%                       'lb',[0,-1000]
%                       or any field name associated with reactions (except
%                       for S and rxnGeneMat) as defined in the COBRA
%                       Model field definitions.
%                       
%                       
%
% OUTPUTS:
%
%    newmodel:     The model structure with the additional reactions.
%
% EXAMPLE:
%
%    To add the following reactions, with lower and upper bounds:
%    ExA: A <-> ; ATob: A <-> B ; BToC: B <-> C
%    model = addMultipleReactions(model,{'ExA','ATob','BToC'},{'A','b','c'},[1 -1 0; 0,1,-1;0,0,1],...
%                                   'lb',[-50,30,1],'ub',[0,60,15])
%    To add them with GPRs in text form:
%    ExA: A <-> ; ATob: A <-> B ; BToC: B <-> C
%    model = addMultipleReactions(model,{'ExA','ATob','BToC'},{'A','b','c'},[1 -1 0; 0,1,-1;0,0,1],...
%                                   'grRules',{'G1 or G2', 'G3 and G4',''})
%
%
%    To add them with the same GPRs in logical format assuming that model.genes is {'G1';'G2';'G3';'G4'}:
%    ExA: A <-> ; ATob: A <-> B ; BToC: B <-> C
%    model = addMultipleReactions(model,{'ExA','ATob','BToC'},{'A','b','c'},[1 -1 0; 0,1,-1;0,0,1],...
%                                   'rules',{'x(1) | x(2)', 'x(3) and x(4)',''})
%    To add them with the same GPRs in logical format without assuming anything for the model:
%    ExA: A <-> ; ATob: A <-> B ; BToC: B <-> C
%    model = addMultipleReactions(model,{'ExA','ATob','BToC'},{'A','b','c'},[1 -1 0; 0,1,-1;0,0,1],...
%                                   'rules',{'x(3) | x(2)', 'x(4) & x(1)',''}, 'genes', {'G4';'G2';'G1';'G3'})
%

[metPres,metPos] = ismember(metList,model.mets);
if any(metPos == 0)
    error('The following Metabolites are not part of the model:\n%s',strjoin(metList(metPos==0)));
end

if any(ismember(model.rxns,rxnIDs)) || numel(unique(rxnIDs)) < numel(rxnIDs)
    error('Duplicate Reaction ID detected.');
end

if numel(unique(metList)) < numel(metList)
    error('Duplicate Metabolite ID detected.');
end

nRxns = numel(model.rxns);

%We have make sure, that the new fields are in sync, so we create those
%first.
fieldDefs = getDefinedFieldProperties();
fieldDefs = fieldDefs(cellfun(@(x) strcmp(x,'rxns'), fieldDefs(:,2)) | cellfun(@(x) strcmp(x,'rxns'), fieldDefs(:,3)));
modelRxnFields = getModelFieldsForType(model,'rxns');

for field = 1:2:numel(varargin)
    cfield = varargin{field};
    if any(ismember({'S','rxnGeneMat','rules','genes'},cfield)) || (~any(ismember(fieldDefs(:,1),cfield)) && ~any(ismember(modelRxnFields,cfield)))
        warning('Field %s is excluded.',cfield);
        continue;
    end
    if ~isfield(model,cfield)
        model = createEmptyFields(model,cfield);
    end    
    if ~any(size(varargin{field+1}) == numel(rxnIDs)) %something must fit
        error('Size of field %s does not fit to the rxnList size', varargin{field});
    end
    model.(cfield) = [model.(cfield);columnVector(varargin{field+1})];
end
model.rxns= [model.rxns;columnVector(rxnIDs)];
newmodel = extendModelFieldsForType(model,'rxns','originalSize',nRxns);
%Now, we have extended the S matrix. So lets fill it.
newmodel.S(metPos,(nRxns+1):end) = Stoichiometries;


if isfield(model,'grRules') && ~any(ismember(varargin(1:2:end),'rules')) %There is a grRules field, and no Rules are provided.
    rulesToUpdate = ~cellfun(@isempty, model.grRules(nRxns+1:end));
    if any(rulesToUpdate)
        %We have non Empty grRules in the input. Parse them.
        newgrRules = nRxns + find(rulesToUpdate);
        for i = 1:numel(newgrRules)
            newmodel = changeGeneAssociation(newmodel,newmodel.rxns{newgrRules(i)},newmodel.grRules{newgrRules(i)});
        end
    end
end

if any(ismember(varargin(1:2:end),'rules'))
    %We have a rules field. First, reset any grRules
    if isfield(model,'grRules')
        newmodel.grRules(nRxns+1:end) = {''};
    end
    %Now, we have to check, if there is a gene list provided:
    if any(ismember(varargin(1:2:end),'genes'))
        %If genes are provided, we have to A: find the overlap, be
        %merge the genes and C adjust the rules.
        nGenes = length(newmodel.genes);
        genePos = 2 * find(ismember(varargin(1:2:end),'genes'));
        rulesPos = 2 * find(ismember(varargin(1:2:end),'rules'));
        genes = varargin{genePos};
        rules = varargin{rulesPos};
        if ~any(size(rules) == numel(rxnIDs)) %something must fit
            error('Size of field rules does not fit to the rxnList size');
        end
        %Find all genes (and their positions) which are already in the model.
        [genePres,genePos] = ismember(genes,newmodel.genes);
        additionalGenes = sum(~genePres);
        newmodel = addGenes(model,genes(~genePres));
        genePos(~genePres) = nGenes+(1:additionalGenes);
        %now, replace the ids.
        genePos = cellfun(@(x) strcat('x(', num2str(x),')'), num2cell(genePos),'Uniformoutput',false);
        rules = regexprep(rules,'x\(([0-9]+)\)','${genePos{str2num($1)}}');
        newmodel.rules(nRxns+1:length(model.rxns)) = rules;
    else
        rulesPos = 2 * find(ismember(varargin(1:2:end),'rules'));
        if ~isfield(newmodel,'rules') %If rules does not exist, create it.
            newmodel = generateRules(newmodel);
        end
        if ~any(size(varargin{rulesPos}) == numel(rxnIDs)) %something must fit
            error('Size of field rules does not fit to the rxnList size');
        end
        newmodel.rules((nRxns+1):end) = columnVector(varargin{rulesPos});
    end
    
    %Update the corresponding grRules fields and rxnGeneMat fields.
    %create the grRules
    rulesToUpdate = nRxns + find(~cellfun(@isempty, model.rules(nRxns+1:end)));
    if ~isempty(rulesToUpdate)
        if isfield(newmodel,'grRules')
            cGrRules = newmodel.grRules(nRxns+1:end);
            cGrRules = strrep(cGrRules,'|','or');
            cGrRules = strrep(cGrRules,'&','and');
            cGrRules = regexprep(cGrRules,'x\(([0-9]+)\)','${model.genes{str2num($1)}}');
            newmodel.grRules(nRxns+1:end) = cGrRules;
        end
        %Also update the rxnGeneMat, if present
        if isfield(model,'rxnGeneMat')
            nGenes = length(newmodel.genes);
            for i = 1:numel(rulesToUpdate)
                assoc = false(1,nGenes);
                %get all gene positions
                pos = regexp(newmodel.rules{rulesToUpdate(i)},'x\((?<pos>[0-9]+)\)','names');
                genePos = cellfun(@str2num, {pos.pos});
                assoc(genePos) = true;
                newmodel.rxnGeneMat(rulesToUpdate(i),:) = assoc;
            end
        end
    end

end