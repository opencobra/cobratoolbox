% The COBRAToolbox: testConstraintModifciation.m
%
% Purpose:
%     - Function to test the different functions that manipulate non
%       metabolic constraints in the model. These currently include:
%       addNMConstraint, removeNMConstraint
%       addRatioReaction, constrainRxnListAboveBound, 
%
%       In addition this test checks, whether models stay consistent when
%       manipulating them e.g. by addReaction/removeReaction, reorderModelFields or similar.
%       
%       NOTE: This Test does NOT test the functionality of these coupling
%       constraints in any way. IT only tests, that the model manipulations
%       keep the Constraint fields valid and correct.
% Authors:
%     Thomas Pfau - Nov 2017

%Lets start with the E.coli core model
model = getDistributedModel('ecoli_core_model.mat');
%Assert that the model does not yet have these fields.
assert(isempty(intersect(fieldnames(model),{'C','dsense','ctrs','d'})));
nCtrs = 0;

%Add a constraint
modelWConst = constrainRxnListAboveBound(model,model.rxns(1:2),[1 1],6,'G');
%Assert, that all fields were generated.
assert(all(ismember({'C','dsense','ctrs','d'},fieldnames(modelWConst))));
%assert that the other parts of the model were not modified.
assert(isSameCobraModel(model,restrictModelsToFields(modelWConst,fieldnames(model))));
%Check, that the constraint was properly added
assert(size(modelWConst.C,2) == size(model.S,2));
assert(isequal(modelWConst.C(1,1:2), [1,1]));
assert(size(modelWConst.C,1) == size(modelWConst.d,1));
assert(size(modelWConst.C,1) == size(modelWConst.ctrs,1));
assert(size(modelWConst.C,1) == size(modelWConst.dsense,1));
assert(size(modelWConst.C,1) == nCtrs+1);

%Add another constraint via addRatioReaction
modelWConst = addRatioReaction(modelWConst,model.rxns(1:2),[3,2]);
%Again check, that the sizes fit, and that the old model fields were not
%modified.
assert(isSameCobraModel(model,restrictModelsToFields(modelWConst,fieldnames(model))));
assert(size(modelWConst.C,2) == size(model.S,2));
assert(size(modelWConst.C,1) == size(modelWConst.d,1));
assert(size(modelWConst.C,1) == size(modelWConst.ctrs,1));
assert(size(modelWConst.C,1) == size(modelWConst.dsense,1));
assert(size(modelWConst.C,1) == nCtrs+2)

%remove a constraint from a model without C
modelTest = removeNMConstraints(model,'invalidID'); % Nothing should happen
assert(isSameCobraModel(model,modelTest));

%and from one with C
modelTest = removeNMConstraints(modelWConst,'invalidID'); % Nothing should happen
assert(isSameCobraModel(modelWConst,modelTest));

modelTest = removeNMConstraints(modelWConst,modelWConst.ctrs(1)); % Remove the first constraint
assert(isSameCobraModel(model,restrictModelsToFields(modelTest,fieldnames(model))));
assert(size(modelTest.C,2) == size(model.S,2));
assert(size(modelTest.C,1) == size(modelTest.d,1));
assert(size(modelTest.C,1) == size(modelTest.ctrs,1));
assert(size(modelTest.C,1) == size(modelTest.dsense,1));
assert(size(modelTest.C,1) == nCtrs+1)
modelTest2 = removeNMConstraints(modelWConst,1); % Remove the constraint at position one
assert(isSameCobraModel(modelTest,modelTest2));
modelTest2 = removeNMConstraints(modelWConst,modelWConst.ctrs{1}); % Remove the constraint at position one
assert(isSameCobraModel(modelTest,modelTest2));

%And Add another Constraint
modelWConst = addNMConstraint(modelWConst,model.rxns(1:3),'c',[1,1,1],'d',6,'dsense','L','ConstraintID','NewConstraint');
assert(size(modelWConst.C,2) == size(model.S,2));
assert(size(modelWConst.C,1) == size(modelWConst.d,1));
assert(size(modelWConst.C,1) == size(modelWConst.ctrs,1));
assert(size(modelWConst.C,1) == size(modelWConst.dsense,1));
assert(size(modelWConst.C,1) == nCtrs+3)
assert(verifyCobraFunctionError(@() addNMConstraint(modelWConst,model.rxns(1:3),'c',[1,1,1],'d',6,'dsense','L','ConstraintID','NewConstraint'))); %Assert duplication error.
modelWConst2 = addNMConstraint(modelWConst,model.rxns(1:3),'c',[1,1,1],'d',6,'dsense','L','checkDuplicate',true); 
assert(isSameCobraModel(modelWConst2,modelWConst)) % No new constraint was added, as it already exists.

%Finally, test whether modifications in the model correctly update the C
%Matrix
rxnstoDel = 2:4;
modelDel = removeRxns(modelWConst, modelWConst.rxns(rxnstoDel));
assert(size(modelDel.C,2) == size(modelDel.S,2));
temp = modelWConst.C;
temp(:,rxnstoDel) = [];
assert(isequal(modelDel.C,temp));
modelDel = removeRxns(modelWConst, modelWConst.rxns(1:4)); %This removes all elements from the model 
assert(~isfield(modelDel,'C'));

%And test whether addition of reactions correctly updates C
modelAdd = addReaction(modelWConst,'NewReac','A + B -> C');
assert(size(modelAdd.C,2) == size(modelAdd.S,2));
newReacPosition = ismember(modelAdd.rxns,'NewReac');
assert(isequal(modelAdd.C(:,~newReacPosition),modelWConst.C));
assert(all(modelAdd.C(:,newReacPosition)== 0));









