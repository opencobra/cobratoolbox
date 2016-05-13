% Construct the elemental matrix and electron vector for DAS

load DAS.mat

[E,elements] = constructElementalMatrix(model.metFormulas,model.metCharges);

save elementalMatrix.mat E elements