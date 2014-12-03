%finds the reactions that are imbalanced

model=findSExRxnInd(model);
[massImbalance,imBalancedMass,imBalancedCharge,imBalancedRxnBool,Elements,missingFormulaeBool,balancedMetBool]...
    = checkMassChargeBalance(model,model.SIntRxnBool,printLevel);
model.balancedRxnBool=~imBalancedRxnBool;
model.balancedMetBool=balancedMetBool;
model.Elements=Elements;
model.missingFormulaeBool=missingFormulaeBool;

%assumes that all mass imbalanced reations are exchange reactions
model.SIntRxnBool = model.SIntRxnBool & model.balancedRxnBool;
model.SIntMetBool = model.SIntMetBool & model.balancedMetBool;

% checkStoichiometricConsistency from openCOBRA
%double check that the designated internal reactions are indeed stoichiometrically
%consistent, which should follow if they are all mass balanced.
[inform,m,model]=checkStoichiometricConsistency(model,printLevel);