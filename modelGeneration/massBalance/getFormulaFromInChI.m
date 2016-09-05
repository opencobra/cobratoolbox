function formula=getFormulaFromInChI(InChI)
% extract formula from InChI
[token,rem] = strtok(InChI, '/');
formula=strtok(rem, '/');