% Writes rxnfiles for reactions in the dopamine synthesis network DAS.
% Needed for prediction of atom mappings with DREAM (http://selene.princeton.edu/dream/).

load DAS.mat % The dopamine synthesis network

mets = model.mets;
rxns = model.rxns;
S = model.S;
bool = model.intRxnBool;


% Write rxnfiles for internal reactions
moldir = 'molfiles/';
rxndir = 'rxnfiles/';

for i = find(bool)'
        writeRxnfile(mets,S(:,i),rxns{i},moldir,rxndir);
end

