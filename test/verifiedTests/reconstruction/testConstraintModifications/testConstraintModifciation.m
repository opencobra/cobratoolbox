% The COBRAToolbox: testConstraintModifciation.m
%
% Purpose:
%     - Function to test the different functions that manipulate non
%       metabolic constraints in the model. These currently include:
%       addCOBRAConstraint, removeCOBRAConstraint
%       addRatioReaction, constrainRxnListAboveBound, addCouplingConstraint 
%       coupleRxnList2Rxn
%       In addition this test checks, whether models stay consistent when
%       manipulating them e.g. by addReaction/removeReaction, reorderModelFields or similar.
%       
%       NOTE: This Test does NOT test the functionality of these coupling
%       constraints in any way. It only tests, that the model manipulations
%       keep the Constraint fields valid and correct.
% Authors:
%     Thomas Pfau - Nov 2017

currentDir = pwd;

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

%Test Different Function to add a constraint
modelWConst = addCouplingConstraint(model,model.rxns(1:2),[1 1],6,'G');
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
modelTest = removeCOBRAConstraints(model,'invalidID'); % Nothing should happen
assert(isSameCobraModel(model,modelTest));

%and from one with C
modelTest = removeCOBRAConstraints(modelWConst,'invalidID'); % Nothing should happen
assert(isSameCobraModel(modelWConst,modelTest));

modelTest = removeCOBRAConstraints(modelWConst,modelWConst.ctrs(1)); % Remove the first constraint
assert(isSameCobraModel(model,restrictModelsToFields(modelTest,fieldnames(model))));
assert(size(modelTest.C,2) == size(model.S,2));
assert(size(modelTest.C,1) == size(modelTest.d,1));
assert(size(modelTest.C,1) == size(modelTest.ctrs,1));
assert(size(modelTest.C,1) == size(modelTest.dsense,1));
assert(size(modelTest.C,1) == nCtrs+1)
modelTest2 = removeCOBRAConstraints(modelWConst,1); % Remove the constraint at position one
assert(isSameCobraModel(modelTest,modelTest2));
modelTest2 = removeCOBRAConstraints(modelWConst,modelWConst.ctrs{1}); % Remove the constraint at position one
assert(isSameCobraModel(modelTest,modelTest2));

%And Add another Constraint
modelWConst = addCOBRAConstraints(modelWConst,model.rxns(1:3), 6, 'c',[1,1,1],'dsense','L','ConstraintID','NewConstraint');
assert(size(modelWConst.C,2) == size(model.S,2));
assert(size(modelWConst.C,1) == size(modelWConst.d,1));
assert(size(modelWConst.C,1) == size(modelWConst.ctrs,1));
assert(size(modelWConst.C,1) == size(modelWConst.dsense,1));
assert(size(modelWConst.C,1) == nCtrs+3)
assert(verifyCobraFunctionError('addCOBRAConstraint','inputs',{modelWConst,model.rxns(1:3), 6, 'c', [1,1,1],'dsense','L','ConstraintID','NewConstraint'})); %Assert duplication error.
modelWConst2 = addCOBRAConstraints(modelWConst,model.rxns(1:3), 6,'c',[1,1,1],'dsense','L','checkDuplicate',true); 
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

%Also test adding multiple Constraints:
c = [0,1,2,0,0;0,3,0,4,0 ; 5,0,0,0,6];
d = [1;2;3];
rxnList = [1,2,3,4,5];
dsense = ['E';'L';'G'];
modelWMultConst = addCOBRAConstraints(model,rxnList,d,'c',c,'dsense',dsense);
assert(size(modelWMultConst.C,2) == size(model.S,2));
assert(size(modelWMultConst.C,1) == 3); %Three constraints
assert(size(modelWMultConst.C,1) == size(modelWMultConst.d,1));
assert(size(modelWMultConst.C,1) == size(modelWMultConst.ctrs,1));
assert(size(modelWMultConst.C,1) == size(modelWMultConst.dsense,1));
assert(isequal(modelWMultConst.d,d)); %This is not necessarily true if multiple Constraints are added and duplicates are checked.
assert(isequal(modelWMultConst.dsense,dsense));
%Assert that readding a Constraint with the same name fails.
assert(verifyCobraFunctionError('addCOBRAConstraint', 'input',{modelWMultConst,rxnList,d,'c',c,'dsense',dsense,'ConstraintID', {'Constraint1','B','C'}}));

%No Constraint gets added if duplicates are checked.
modelWMultConst2 = addCOBRAConstraints(modelWMultConst,rxnList,d,'c',c,'dsense',dsense,'checkDuplicate',true);
assert(isSameCobraModel(modelWMultConst,modelWMultConst2));

%No duplicates, within the Constraints are added:
modelWMultConst = addCOBRAConstraints(model,rxnList,[d;d],'c',[c;c],'dsense',[dsense;dsense],'checkDuplicate',true);
assert(size(modelWMultConst.C,1) == 3); %Three constraints



% %Also test the RxnList coupling function. Temporarily disabled until
% decision on coupleRxnList2Rxns is made
% %This should add cs of 1000, and us of 0.001;
% %Rxn 8 is irreversible, rxn 9 is reversible.
% modelWithList = coupleRxnList2Rxn(model,model.rxns([8,9]),model.rxns(10),6);
% assert(size(modelWithList.C,2) == size(modelWithList.S,2));
% assert(size(modelWithList.C,1) == 3); %one forward + backward, one forward constraint.
% assert(all(all(modelWithList.C(3,9)==1)));
% assert(all(all(modelWithList.C([1,2],8)==1)));
% assert(nnz(modelWithList.C) == 6); %There are 6 non Zero Elements in this Z (and we check all of their values.
% assert(all(all(modelWithList.C(1,[10])==-6))); %The first was irreversible, so the constraint is added negative.
% assert(all(all(modelWithList.C(2:3,[10])==[6;-6])));%The second was so we add both directions.
% assert(all(modelWithList.d(1)== 0.01));%The first 
% assert(all(modelWithList.d(2:3) == [-0.01;0.01]));%The forward / backwards
% assert(all(modelWithList.dsense(1:3)== ['L';'G';'L']));



cd(currentDir);


