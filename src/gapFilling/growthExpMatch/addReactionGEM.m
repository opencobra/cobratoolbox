function [newmodel, HTABLE] = addReactionGEM(model,rxns,rxnNames,rxnFormulas,rev,lb,ub,nRxn,subSystems,grRules,rules,genes, HTABLE)
%addReactionGEM manually adds reactions to a specified model, may add one or more reactions at a time
%
%   [newmodel] = addReactionSmiley(model,rxns,rxnNames,rxnFormulas,rev,lb,ub,subSystems,grRules,rules,genes,HTABLE)
%
% - Manually add reactions to a specified model, can either add one or
%   multiple reactions at a time
% - All syntax standards must comply with the specified model
% - For reaction formulas, use: '-->' for irreversible or '<==>' for
%   reversible
% e.g. [modelLB_NH3] = addReactionSmiley(modelLB,'NH3r','NH3 protonization',cellstr('1 NH3[c] + 1 H[c] <==> 1 NH4[c]'),1,-1000,1000,'Others');
% Inputs
%     model
%     rxns
%     rxnNames
%     rxnFormulas     see note above
%     rev             0 = irrev, 1 = rev
%     lb
%     ub
%     subSystems      default = ''
%     grRules         default = ''
%     rules           default = ''
%     genes           default = ''
%     HTABLE
%
% Output
%     newmodel
%
% based on AddRxn: Aarash Bordbar 11/2/07
% IT 11-19-08

if ~exist('subSystems', 'var') || isempty(subSystems)
    clear subSystems;
    for i = 1:length(rev)
        subSystems(i,1) = {''};
    end
end

if ~exist('grRules', 'var') || isempty(grRules)
    clear grRules;
    for i = 1:length(rev)
        grRules(i,1) = {''};
    end
end

if ~exist('rules', 'var')|| isempty(rules)
    clear rules;
    for i = 1:length(rev)
        rules(i,1) = {''};
    end
end

if ~exist('genes', 'var')|| isempty(genes)
    genes = {''};
end

if ~exist('nRxn', 'var') || isempty(nRxn)
    nRxn = length(model.lb)+1;
end

nMet = length(model.mets)+1;

if (isfield(model,'genes'))
    nGenes = length(model.genes)+1;
end
newmodel = model;

putNecessary = false;
if exist('HTABLE', 'var') || length(rxnNames) > 2
    useHashTable = true;
    if exist('HTABLE', 'var') % no need to initialize HTABLE
        putNecessary = true; % will need it for output as well.
    else %create new hashtable
        HTABLE = java.util.Hashtable; % initialize HTABLE
        for i = 1:length(newmodel.mets)
            HTABLE.put(newmodel.mets{i}, i);
        end
    end
else
    useHashTable = false;
end

showprogress(0, 'Adding Rxns ...');
for i = 1:length(rev)
    %IO indicates whether it is part of the reactants or part of the
    %product (ie. IO = -1 is reactant, IO = 1 products)
    IO = -1;
    %newmodel.rxns{nRxn} = char(rxns(i));
    newmodel.lb(nRxn,1) = lb(i,1);
    newmodel.ub(nRxn,1) = ub(i,1);
    newmodel.rev(nRxn,1) = rev(i,1);
    newmodel.subSystems{nRxn,1} = subSystems(i,1);
    newmodel.grRules(nRxn,1) = grRules(i,1);
    newmodel.rules(nRxn,1) = rules(i,1);
    newmodel.c(nRxn,1) = 0;
    newmodel.rxnNames{nRxn,1} = char(rxnNames(i,1));
    %newmodel.S(:, i) = zeros(length(newmodel.mets), 1);

    %parses reaction formula into components of string
    [parsing{1,1},parsing{2,1}] = strtok(rxnFormulas{i});
    for j = 2:100
        [parsing{j,1},parsing{j+1,1}] = strtok(parsing{j,1});
        if isempty(parsing{j+1,1})==1
            break
        end
    end

    nComponents = length(parsing)-1;
    j = 1;
    while j <= nComponents
        if strcmp(parsing{j},'+') == 1
            j = j+1;
        elseif strcmp(parsing{j},' ') == 1
            j = j+1;

        %if its '-->' or '<==>' then switches IO to 1 which indicates the
        %next compounds are part of the product
        elseif strcmp(parsing{j},'<==>') == 1
            IO = 1;
            j = j+1;
        elseif strcmp(parsing{j},'=>') == 1
            IO = 1;
            j = j+1;
        elseif strcmp(parsing{j},'-->') == 1
            IO = 1;
            j = j+1;
        elseif str2double(parsing{j}) > 0

            j = j+1;
        else
            %if met already exists in newmodel then sets metLoc to
            %corresponding met location

            if useHashTable
                c = HTABLE.get(parsing{j});
            else
                c = strmatch(parsing{j},newmodel.mets,'exact');
                %display('slow method')
            end

            %c = strcmp(parsing{j},newmodel.mets);
            if ~isempty(c)
                metLoc = c;
                parsing(j);

            %if met doesn't exist then metLoc is set at nMet (the end of list)
            else
                metLoc = nMet;
                newmodel.mets{metLoc} = parsing{j};
                newmodel.S(metLoc,:) = 0;
                newmodel.b(metLoc) = 0;
                if putNecessary
                    HTABLE.put(parsing{j}, metLoc);
                end
                nMet = nMet+1;
            end
            %finds reaction coefficient of met
            rxnCoeff = str2double(parsing{j-1});
            if isnan(rxnCoeff)
                rxnCoeff=1;
                rxnNames(i,1);
            end
            s = size(model.S);
            if(metLoc <= s(1))
                origCoeff = newmodel.S(metLoc,nRxn);
                if(origCoeff < 0)
                    newmodel.rxns(nRxn);
                end
            else
                origCoeff = 0;
            end
            newmodel.S(metLoc,nRxn) = rxnCoeff*IO + origCoeff;

            j=j+1;
        end
    end

    clear parsing

    [parsing{1,1},parsing{2,1}] = strtok(grRules{i});
    if ~isempty(parsing{2,1}) %length(parsing{2,1}) ~= 0
        for j = 2:100
            [parsing{j,1},parsing{j+1,1}] = strtok(parsing{j,1});
            if isempty(parsing{j+1,1})==1
                break
            end
        end
    end
    nRxn = nRxn + 1;

    clear parsing

    showprogress(i/length(rev));
end

for i = 1:length(genes)
    if ~isempty(genes{i}) %length(genes{i}) ~= 0
        newmodel.genes(nGenes,1) = genes(i,1);
    end
end
