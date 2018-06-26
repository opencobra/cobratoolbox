% The COBRAToolbox: testGenerateRules.m
%
% Purpose:
%     - testGenerateRules tests generateRules
%
% Authors:
%     - Initial Version: Uri David Akavia - August 2017

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateRules'));
cd(fileDir);

modelsToTry = {'Acidaminococcus_intestini_RyC_MR95.mat', 'Acidaminococcus_sp_D21.mat', 'Recon1.0model.mat', 'Recon2.v04.mat', 'ecoli_core_model.mat', 'modelReg.mat'};

for i=1:length(modelsToTry)
    model = getDistributedModel(modelsToTry{i});
    fprintf('Beginning model %s\n', modelsToTry{i});
    
    model2 = generateRules(model);
    model.rules = strrep(model.rules, '  ', ' ');
    model3 = model;
    model3.genes = []; % Empty genes field
    model3 = generateRules(model3, 0);
    model4 = model;
    model4 = rmfield(model4, 'genes');
    model4 = generateRules(model4, 0);
    
    fp = FormulaParser();
    % fix for Recon2
    if strcmp(modelsToTry{i}, 'Recon2.v04.mat')
        model.rules(2240) = {'(x(2)) | (x(4)) | (x(3))'}; % '(26.1) or (314.1) or (314.2)'
        model.rules(2543) = {'(x(2)) | (x(4)) | (x(1)) | (x(3))'}; % '(26.1) or (314.1) or (8639.1) or (314.2)'
        model.rules(2750) = {'(x(2)) | (x(4)) | (x(1)) | (x(3))'}; % '(26.1) or (314.1) or (8639.1) or (314.2)'
        model.rules(2940) = {'(x(4)) | (x(60)) | (x(2)) | (x(61)) | (x(3))'}; % '(314.1) or (4128.1) or (26.1) or (4129.1) or (314.2)'
        model.rules(3133) = {'(x(2)) | (x(4)) | (x(1)) | (x(3))'}; % '(26.1) or (314.1) or (314.2)'
    end
    %also, introduce spaces around the individual genes:    
    model.rules = regexprep(model.rules,'([^\s])(x\([0-9]+\))','$1 $2');
    model.rules = regexprep(model.rules,'(x\([0-9]+\))([^\s])','$1 $2');
    
    % Create a model with sorted genes
    sortedModel = model;
    sortedRules = sortedModel.rules;
    [sortedModel.genes, newInd] = sort(model.genes);
    [~, newInd] = sort(newInd);
    for j=1:length(newInd)
        sortedRules = strrep(sortedRules, ['x(', num2str(j), ')'], ['x(New', num2str(newInd(j)), ')']);
    end
    sortedRules = strrep(sortedRules, 'New', '');
    sortedModel.rules = sortedRules;
    
    for rule = 1:numel(model.rules)        
        if isempty(model.rules{rule})
            %assert that both formulas are empty (and thus equal).
            assert(isequal(model.rules{rule},model2.rules{rule}))
            assert(isequal(sortedModel.rules{rule},model3.rules{rule}))
            assert(isequal(sortedModel.rules{rule},model4.rules{rule}))
            continue;
        elseif strcmp(model.rules{rule},model2.rules{rule})
            %If the strings are identical than we don't need to check
            %equivalence.
            assert(isequal(model.rules{rule},model2.rules{rule}))
            assert(isequal(sortedModel.rules{rule},model3.rules{rule}))
            assert(isequal(sortedModel.rules{rule},model4.rules{rule}))
            continue
        end
        
        head1 = fp.parseFormula(model.rules{rule});
        head2 = fp.parseFormula(model2.rules{rule});
        headSort = fp.parseFormula(sortedModel.rules{rule});
        head3 = fp.parseFormula(model3.rules{rule});
        head4 = fp.parseFormula(model4.rules{rule});
        
        %Assert that the formulas are equal.
        assert(head1.isequal(head2));
        assert(headSort.isequal(head3));
        assert(headSort.isequal(head4));
    end
    fprintf('Succesfully completed model %s\n', modelsToTry{i});
end