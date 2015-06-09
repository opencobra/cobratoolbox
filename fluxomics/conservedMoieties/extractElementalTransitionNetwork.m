function ETN = extractElementalTransitionNetwork(ATN,element)

% Find rows and columns involving element
abool = ismember(ATN.elements,element);
tbool = any(ATN.A(abool,:));

% Generate output structure
ETN.A = ATN.A(abool,tbool);
ETN.mets = ATN.mets(abool);
ETN.rxns = ATN.rxns(tbool);
ETN.elements = ATN.elements(abool);
ETN.inputBool = ATN.inputBool(abool);
ETN.outputBool = ATN.outputBool(abool);
ETN.reverseBool = ATN.reverseBool(tbool);