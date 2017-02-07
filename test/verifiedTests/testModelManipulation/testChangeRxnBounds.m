% The COBRAToolbox: changeRxnBounds.m
%
% Purpose:
%     - Tests the changeRxnBounds function
% Author:
%     - Original file: Stefania Magnusdottir

% define the path to The COBRA Toolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

cd([CBTDIR '/test/verifiedTests/testModelManipulation'])

% define the test model
toyModel=struct;
toyModel.rxns={'Rxn1'; 'Rxn2'; 'Rxn3'};
toyModel.lb=[0 ; 0 ; 0];
toyModel.ub=[0 ; 0 ; 0];

% test default ('b') on one rxn
rxnNameList='Rxn1';
value=10;
modelNew = changeRxnBounds(toyModel,rxnNameList,value);
assert(isequal(modelNew.lb,[10 ; 0 ; 0]))
assert(isequal(modelNew.ub,[10 ; 0 ; 0]))

% test different values and multiple bound types, include rxn not in model
rxnNameList={'Rxn1' ; 'Rxn2'; 'Rxn3' ; 'Rxn4'};
value=[10 ; 20 ; 30 ; 40];
boundType={'l' ; 'u' ; 'b' ; 'l'};
modelNew = changeRxnBounds(toyModel,rxnNameList,value,boundType);
assert(isequal(modelNew.lb,[10 ; 0 ; 30]))
assert(isequal(modelNew.ub,[0 ; 20 ; 30]))

for i=1:length(boundType)-1
    % test different values with single bound type
    modelNew = changeRxnBounds(toyModel,rxnNameList(1:3),value(1:3),boundType{i});
    switch lower(boundType{i})
        case 'u'
            assert(isequal(modelNew.lb,toyModel.lb))
            assert(isequal(modelNew.ub,value(1:3)))
        case 'l'
            assert(isequal(modelNew.ub,toyModel.ub))
            assert(isequal(modelNew.lb,value(1:3)))
        case 'b'
            assert(isequal(modelNew.ub,value(1:3)))
            assert(isequal(modelNew.lb,value(1:3)))
    end
    % test single value with single bound type
    modelNew = changeRxnBounds(toyModel,rxnNameList(1:3),value(1),boundType{i});
    switch lower(boundType{i})
        case 'u'
            assert(isequal(modelNew.lb,toyModel.lb))
            assert(isequal(modelNew.ub,value(1)*ones(3,1)))
        case 'l'
            assert(isequal(modelNew.ub,toyModel.ub))
            assert(isequal(modelNew.lb,value(1)*ones(3,1)))
        case 'b'
            assert(isequal(modelNew.ub,value(1)*ones(3,1)))
            assert(isequal(modelNew.lb,value(1)*ones(3,1)))
    end
end

% test single rxn input, not in model. Should not affect model bounds.
% Affects a different line in the code than the Rxn4 in test above
rxnNameList='Rxn4';
value=10;
modelNew = changeRxnBounds(toyModel,rxnNameList,value);
assert(isequal(modelNew.lb,toyModel.lb))
assert(isequal(modelNew.ub,toyModel.ub))

% test that error is thrown if values and rxn list have different lengths
rxnNameList='Rxn1';
value=[10 ; 20];
try
    modelNew = changeRxnBounds(toyModel,rxnNameList,value,'l');
catch ME
    assert(length(ME.message) > 0)
end

% change the directory
cd(CBTDIR)