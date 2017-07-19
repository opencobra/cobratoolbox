% The COBRAToolbox: testChangeRxnBounds.m
%
% Purpose:
%     - Tests the changeRxnBounds function
% Author:
%     - Original file: Stefania Magnusdottir

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testChangeRxnBounds'));
cd(fileDir);

% define the test model
toyModel = struct;
toyModel.rxns = {'Rxn1'; 'Rxn2'; 'Rxn3'};
toyModel.lb = [0; 0; 0];
toyModel.ub = [0; 0; 0];

% test default ('b') on one rxn
modelNew = changeRxnBounds(toyModel, 'Rxn1', 10);
assert(isequal(modelNew.lb, [10; 0; 0]))
assert(isequal(modelNew.ub, [10; 0; 0]))

% test different values and multiple bound types, include rxn not in model
modelNew = changeRxnBounds(toyModel, {'Rxn1'; 'Rxn2'; 'Rxn3'; 'Rxn4'}, ...
    [10; 20; 30; 40], {'l'; 'u'; 'b'; 'l'});
assert(isequal(modelNew.lb, [10 ; 0; 30]))
assert(isequal(modelNew.ub, [0; 20; 30]))

%try single and variable boundary value with different bound types
boundType={'l'; 'u'; 'b'};
for i = 1:length(boundType) - 1
    % test different values with single bound type
    modelNew = changeRxnBounds(toyModel, toyModel.rxns, [10; 20; 30], boundType{i});
    switch lower(boundType{i})
        case 'u'
            assert(isequal(modelNew.lb, toyModel.lb))
            assert(isequal(modelNew.ub, [10; 20; 30]))
        case 'l'
            assert(isequal(modelNew.ub, toyModel.ub))
            assert(isequal(modelNew.lb, [10; 20; 30]))
        case 'b'
            assert(isequal(modelNew.ub, [10; 20; 30]))
            assert(isequal(modelNew.lb, [10; 20; 30]))
    end
    % test single value with single bound type
    modelNew = changeRxnBounds(toyModel, toyModel.rxns, 10, boundType{i});
    switch lower(boundType{i})
        case 'u'
            assert(isequal(modelNew.lb, toyModel.lb))
            assert(isequal(modelNew.ub, 10 * ones(3, 1)))
        case 'l'
            assert(isequal(modelNew.ub, toyModel.ub))
            assert(isequal(modelNew.lb, 10 * ones(3, 1)))
        case 'b'
            assert(isequal(modelNew.ub, 10 * ones(3, 1)))
            assert(isequal(modelNew.lb, 10 * ones(3, 1)))
    end
end

% test single rxn input, not in model. Should not affect model bounds.
% Affects a different line in the code than the Rxn4 in test above
modelNew = changeRxnBounds(toyModel, 'Rxn4', 10);
assert(isequal(modelNew.lb, toyModel.lb))
assert(isequal(modelNew.ub, toyModel.ub))

% test that error is thrown if values and rxn list have different lengths
try
    modelNew = changeRxnBounds(toyModel, 'Rxn1', [10; 20], 'l');
catch ME
    assert(length(ME.message) > 0)
end

% change the directory
cd(currentDir)
