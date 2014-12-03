function regModel = readBooleanRegModel(metModel,fileName)
%readBooleanRegModel Read Boolean regulatory network model
%
% regModel = readBooleanRegModel(metModel,fileName)
%
%INPUT
% metModel
%
%OPTIONAL INPUT
% fileName
% 
%OUTPUT
% regModel      model containing the following fields:
%
% regModel.mets   Metabolite rules
%            name     Metabolite/pool name (internal to the reg network model)
%            rule     Metabolite 'activation' rule
%            type     Metabolite type (extra/intracellular/pool)
%            excInd   Exchange flux indices corresponding to extracellular
%                     metabolites
%            icmRules Intracellular metabolite 'activation' rules (based on
%                     a flux vector - fluxVector)
%            pool     Pool components
% regModel.regs    Regulator rules
%            name     Regulator name
%            rule     Regulator rule
%            comp     Regulator rule components (i.e. metabolites or other
%                     regulators that affect the state of this regulator)
%            ruleParsed Rule in parsed format (based on metabolite state -
%                      metState, regulator state - regState)
% regModel.tars    Target rules
%            name     Target name
%            rule     Target rule
%            comp     Target rule components (i.e. metabolites or other
%                     regulators that affect the state of this regulator)
%            ruleParsed Rule in parsed format (based on metabolite state -
%                     metState, regulator state - regState)
%
% Markus Herrgard 12/5/07

if (nargin < 2)
    fileName = 'iMHruletest.xls';
end

%% Read xls file
[tmp,textData] = xlsread(fileName);
nameList = textData(2:end,1);
ruleList = textData(2:end,2);
ruleType = textData(2:end,3);

%% Assign metabolite, regulator, and target rules
regModel = [];

metCnt = 0;
regCnt = 0;
tarCnt = 0;
nameList = strrep(nameList,'[','_');
nameList = strrep(nameList,']','');
nameList = deblank(nameList);
ruleList = strrep(ruleList,'[','_');
ruleList = strrep(ruleList,']','');
ruleList = deblank(ruleList);
for i = 1:length(ruleList)
    ruleList{i} = strrep(ruleList{i},'if ','');
    switch ruleType{i}
        case {'xcm','icm','xcp','icp'}
            metCnt = metCnt + 1;
            regModel.mets.name{metCnt} = nameList{i};
            regModel.mets.rule{metCnt} = ruleList{i};
            if (strcmp(ruleType{i},'xcp') | strcmp(ruleType{i},'icp'))
                regModel.mets.rule{metCnt} = splitString(ruleList{i},'+');
            end
            regModel.mets.type{metCnt} = ruleType{i};
        case {'reg','regc'}
            regCnt = regCnt + 1;
            regModel.regs.name{regCnt} = nameList{i};
            regModel.regs.rule{regCnt} = ruleList{i};
            [elements,newRule] = parseBoolean(ruleList{i});
            regModel.regs.comp{regCnt} = elements;
            regModel.regs.ruleParsed{regCnt} = newRule;
        case 'tar'
            tarCnt = tarCnt + 1;
            regModel.tars.name{tarCnt} = nameList{i};
            regModel.tars.rule{tarCnt} = ruleList{i};
            [elements,newRule] = parseBoolean(ruleList{i});
            regModel.tars.comp{tarCnt} = elements;
            regModel.tars.ruleParsed{tarCnt} = newRule;
    end
end

%% Parse metabolite rules

regModel.mets.name = columnVector(regModel.mets.name);
regModel.mets.rule = columnVector(regModel.mets.rule);
regModel.mets.type = columnVector(regModel.mets.type);

% Extracellular
selEcMets = find(strcmp(regModel.mets.type,'xcm'));
xcMets = strrep(regModel.mets.rule(selEcMets),'-','_');
regModel.mets.excInd = findRxnIDs(metModel,xcMets);

notInModel = xcMets(regModel.mets.excInd == 0);
for i = 1:length(notInModel)
    if (~strcmp(notInModel{i},'NA'))
        fprintf([regModel.mets.name{selEcMets(i)} ': exchange rxn for ' notInModel{i} ' not in metabolic model\n']);
    end
end

% Intracellular
selIcMets = find(strcmp(regModel.mets.type,'icm'));

for i = 1:length(selIcMets)
    [elements,newRule] = parseBoolean(regModel.mets.rule{selIcMets(i)});
    rxnInd = findRxnIDs(metModel,elements);
    for j = 1:length(rxnInd)
        if (rxnInd(j) > 0)
            newRule = strrep(newRule,['x(' num2str(j) ')'],['fluxVector(' num2str(rxnInd(j)) '_TMP_)']);
        else
            if (~strcmp(elements{j},'=0'))
                fprintf([regModel.mets.name{selIcMets(i)} ': rxn ' elements{j} ' not found in the metabolic model']);
            end
        end
    end
    regModel.mets.icmRules{i} = strrep(newRule,'_TMP_','');
end
regModel.mets.icmRules = columnVector(regModel.mets.icmRules);

% Pools

selPoolMets = find(strcmp(regModel.mets.type,'xcp') | strcmp(regModel.mets.type,'icp'));

for i = 1:length(selPoolMets)
    poolMets = regModel.mets.rule{selPoolMets(i)};
    [isInModel,metInd] = ismember(poolMets,regModel.mets.name);
    notInModel = poolMets(~isInModel);
    for j = 1:length(notInModel)
        fprintf([regModel.mets.name{selPoolMets(i)} ': metabolite ' notInModel{j} ' not in regulatory network model\n']);
    end
    regModel.mets.pool{i} = metInd(isInModel == 1);
end
regModel.mets.pool = columnVector(regModel.mets.pool);

%% Parse regulator rules

regModel.regs.name = columnVector(regModel.regs.name);
regModel.regs.rule = columnVector(regModel.regs.rule);
regModel.regs.comp = columnVector(regModel.regs.comp);
regModel.regs.ruleParsed = columnVector(regModel.regs.ruleParsed);

for i = 1:length(regModel.regs.name)
    elements = regModel.regs.comp{i};
    [isMet,metInd] = ismember(elements,regModel.mets.name);
    [isReg,regInd] = ismember(elements,regModel.regs.name);
    newRule = regModel.regs.ruleParsed{i};
    for j = 1:length(elements)
        if (metInd(j) > 0)
            newRule = strrep(newRule,['x(' num2str(j) ')'],['metState(' num2str(metInd(j)) '_TMP_)']);
        elseif (regInd(j) > 0)
            newRule = strrep(newRule,['x(' num2str(j) ')'],['regState(' num2str(regInd(j)) '_TMP_)']);
        else
            if (~strcmp(elements{j},'NA'))
                fprintf([regModel.regs.name{i} ': metabolite or regulator ' elements{j} ' not found in the model\n']);
            end
            newRule = '';
        end
    end
    regModel.regs.ruleParsed{i} = strrep(newRule,'_TMP_','');
end

%% Parse target rules

regModel.tars.name = columnVector(regModel.tars.name);
regModel.tars.rule = columnVector(regModel.tars.rule);
regModel.tars.comp = columnVector(regModel.tars.comp);
regModel.tars.ruleParsed = columnVector(regModel.tars.ruleParsed);

for i = 1:length(regModel.tars.name)
    elements = regModel.tars.comp{i};
    [isMet,metInd] = ismember(elements,regModel.mets.name);
    [isReg,regInd] = ismember(elements,regModel.regs.name);
    newRule = regModel.tars.ruleParsed{i};
    for j = 1:length(elements)
        if (metInd(j) > 0)
            newRule = strrep(newRule,['x(' num2str(j) ')'],['metState(' num2str(metInd(j)) '_TMP_)']);
        elseif (regInd(j) > 0)
            newRule = strrep(newRule,['x(' num2str(j) ')'],['regState(' num2str(regInd(j)) '_TMP_)']);
        else
            if (~strcmp(elements{j},'NA'))
                fprintf([regModel.tars.name{i} ': metabolite or regulator ' elements{j} ' not found in the model\n']);
            end
            newRule = '';
        end
    end
    regModel.tars.ruleParsed{i} = strrep(newRule,'_TMP_','');
end