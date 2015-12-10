% Writes rxnfiles for reactions in the dopamine synthesis network DAS.
% Needed for prediction of atom mappings with DREAM (http://selene.princeton.edu/dream/).

load DAS.mat % The dopamine synthesis network

mets = model.mets;
rxns = model.rxns;
S = model.S;


% Write rxnfiles for internal reactions
molNames = mets;
molDir = 'molfiles/';
rxnDir = 'rxnfiles/';

for i = 1:4 % Internal (mass and charge balanced) reactions
    writeRxnfile(S(:,i),mets,molNames,molDir,rxns{i},rxnDir);
end

