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
    fp = FormulaParser();
    % fix for Recon2
    if strcmp(modelsToTry{i}, 'Recon2.v04.mat')
        model.rules(2240) = {'(x(2)) | (x(4)) | (x(3))'}; % '(26.1) or (314.1) or (314.2)'
        model.rules(2543) = {'(x(2)) | (x(4)) | (x(1)) | (x(3))'}; % '(26.1) or (314.1) or (8639.1) or (314.2)'
        model.rules(2750) = {'(x(2)) | (x(4)) | (x(1)) | (x(3))'}; % '(26.1) or (314.1) or (8639.1) or (314.2)'
        model.rules(2940) = {'(x(4)) | (x(60)) | (x(2)) | (x(61)) | (x(3))'}; % '(314.1) or (4128.1) or (26.1) or (4129.1) or (314.2)'
        model.rules(3133) = {'(x(2)) | (x(4)) | (x(1)) | (x(3))'}; % '(26.1) or (314.1) or (314.2)'
    end
    for rule = 1:numel(model.rules)
        if isempty(model.rules{rule})
            %assert that both formulas are empty (and thus equal).
            assert(isequal(model.rules{rule},model2.rules{rule}))
            continue;
        end
        head1 = fp.parseFormula(model.rules{rule});
        head2 = fp.parseFormula(model2.rules{rule});
        %Assert that the formulas are equal.
        assert(head1.isequal(head2));
    end
    fprintf('Succesfully completed model %s\n', modelsToTry{i});
end