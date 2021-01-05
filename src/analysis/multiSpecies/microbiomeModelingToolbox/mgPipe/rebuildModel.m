function [rebuiltModel] = rebuildModel(model,database)
%
% Rebuilds a genome-scale reconstruction with Virtual Metabolic Human (VMH) 
% metabolic and reaction nomenclature while ensuring quality control through
% rBioNet.
%
% USAGE
% [rebuiltModel] = rebuildModel(model)
%
% INPUT
%    model         COBRA model structure
%    database      Structure containing rBioNet reaction and metabolite
%                  database
% 
% OUTPUT
%    rebuiltModel  Quality-controlled COBRA model structure
%
% .. Authors
%       - Stefania Magnusdottir, 2016
%       - Almut Heinken, 12/2018: adapted to function.

% to account for older versions of AGORA
toReplace={'EX_4hpro(e)','EX_4hpro_LT(e)';'EX_indprp(e)','EX_ind3ppa(e)';'INDPRPt2r','IND3PPAt2r';'EX_adpcbl(e','EX_adocbl(e';'H202D','H2O2D'};
for i=1:size(toReplace,1)
    model.rxns=strrep(model.rxns,toReplace{i,1},toReplace{i,2});
end

model=convertOldStyleModel(model);

% fix issues of incorrect field lengths
rxnFields={
    'grRules'
    'subSystems'
    'comments'
    'citations'
    'rxnECNumbers'
    'rxnKEGGID'
    'rxnConfidenceScores'
    };

for i=1:length(rxnFields)
if length(model.(rxnFields{i}))<length(model.rxns)
    if iscell(model.(rxnFields{i}))
    model.(rxnFields{i}){length(model.rxns),1}='';
    elseif isnumeric(model.(rxnFields{i}))
        model.(rxnFields{i})(length(model.rxns),1)=0;
    end
end
end
%% sort reactions
rbio=struct;
% get as much data as possible from the rBioNet database to avoid errors carrying over
for i=1:length(model.rxns)
    if ~strncmp('bio',model.rxns{i,1},3)
        % find reaction index
        rInd=find(ismember(database.reactions(:, 1), model.rxns{i,1}));
        model.rxns{i,1}=database.reactions{rInd, 1};
        model.grRules{i,1}=model.grRules{i};
        model.rxnNames{i,1}=database.reactions{rInd, 2};
        model.subSystems{i,1}=database.reactions{rInd, 11};
        if strcmp(database.reactions{rInd, 4},'1')
            model.lb(i,1)=-1000;
            model.ub(i,1)=1000;
        elseif strcmp(database.reactions{rInd, 4},'0')
            model.lb(i,1)=0;
            model.ub(i,1)=1000;
        end
        model.formulas{i,1}=database.reactions{rInd, 3};
    else
        model.rxns{i,1}=model.rxns{i};
        model.grRules{i,1}=model.grRules{i};
        model.rxnNames{i,1}=model.rxnNames{i};
        model.subSystems{i,1}='Biomass';
        model.lb(i,1)=model.lb(i);
        model.ub(i,1)=model.ub(i);
        model.formulas{i,1}=printRxnFormula(model,model.rxns{i,1});
    end
end

[uniqueRxns,oldInd]=unique(model.rxns);
rbio.data=cell(size(uniqueRxns,1),14);
rbio.data(:,1)=num2cell(ones(size(rbio.data,1),1));
rbio.data(:,2)=uniqueRxns;
rbio.data(:,3)=model.rxnNames(oldInd);
rbio.data(:,4)=model.formulas(oldInd);
rbio.data(:,6)=model.grRules(oldInd);
rbio.data(:,7)=num2cell(model.lb(oldInd));
rbio.data(:,8)=num2cell(model.ub(oldInd));
rbio.data(:,10)=model.subSystems(oldInd);
rbio.data(:,11)=model.citations(oldInd);
rbio.data(:,12)=model.comments(oldInd);
rbio.data(:,13)=model.rxnECNumbers(oldInd);
rbio.data(:,14)=model.rxnKEGGID(oldInd);
rbio.description=cell(7,1);

% build model with rBioNet
bInd = find(strncmp('bio',rbio.data(:,2),3));
bAbb = rbio.data{bInd,2};
bForm = rbio.data{bInd,4};
rbio.data(bInd,:) = [];
model = data2model(rbio.data,rbio.description,database);
model = addReaction(model,bAbb,'reactionFormula',bForm{1});%add translated biomass reaction
model.comments{end+1,1} = '';
model.citations{end+1,1} = '';
model.rxnECNumbers{end+1,1} = '';
model.rxnKEGGID{end+1,1} = '';
model.rxnConfidenceScores{end+1,1} = '';
% fix incorrect format of PubChemID, metChEBIID, and metKEGGID
for i=1:length(model.metPubChemID)
model.metPubChemID{i,1}=char(string(model.metPubChemID{i,1}));
model.metChEBIID{i,1}=char(string(model.metChEBIID{i,1}));
model.metKEGGID{i,1}=char(string(model.metKEGGID{i,1}));
end
model.metPubChemID=cellstr(model.metPubChemID);
model.metChEBIID=cellstr(model.metChEBIID);
model.metKEGGID=cellstr(model.metKEGGID);
% fill in descriptions
model.description.author = 'Molecular Systems Physiology group, www.vmh.life';
model.description.date=date;

% set biomass reaction as objective function
model=changeObjective(model,bAbb);

rebuiltModel=convertOldStyleModel(model);
end
    