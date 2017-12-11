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

modelsToTry = {'Recon1.0model.mat', 'ecoli_core_model.mat'};

for i=1:length(modelsToTry)
    model = getDistributedModel(modelsToTry{i});
    fprintf('Beginning model %s\n', modelsToTry{i});

    model2 = generateRules(model);
    model.rules = strrep(model.rules, '  ', ' ');
    fp = FormulaParser();
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