function trainingModel = createGroupIncidenceMatrix(model, trainingModel, mappingScore, printLevel)
% Initialize `G` matrix, and then use the python script "inchi2gv.py" to decompose each of the
% compounds that has an 'InChI' and save the decomposition as a row in the `G` matrix.
%
% USAGE:
%
%    trainingModel = createGroupIncidenceMatrix(model, trainingModel)
%
% INPUTS:
% model:
% model.mets                                m x 1 metabolite ids
% model.inchi.nonstandard                   m x 1 cell array of nonstandard InChI
%
% trainingModel:
% trainingModel.S:                          p x n stoichiometric matrix of training data
% trainingModel.metKEGGID:                  p x 1 cell array of metabolite KEGGID
% trainingModel.inchi.nonstandard:          p x 1 cell array of nonstandard InChI
% trainingModel.Model2TrainingMap:          m x 1 mapping of model.mets to training data metabolites
% trainingModel.mappingScore                
%
% OUTPUT:
% trainingModel:
% trainingModel.S:                          k x n stoichiometric matrix of training + test data
% trainingModel.G:                          k x g group incicence matrix
% trainingModel.groups:                     g x 1 cell array of group definitions
% trainingModel.trainingMetBool             k x 1 boolean indicating training metabolites in G
% trainingModel.testMetBool                 k x 1 boolean indicating test metabolites in G
% trainingModel.groupDecomposableBool:      k x 1 boolean indicating metabolites with group decomposition
% trainingModel.cids_that_dont_decompose:   z x 1 ids of compounds that do not decomopose    
% 

%                          dG0: n x 1 standard Gibbs energy
%                    dG0_prime: n x 1 standard transformed Gibbs energy
%                            T: n x 1 temperature
%                            I: n x 1 ionic strength
%                           pH: n x 1 pH
%                          pMg: n x 1 pMg
%                      weights: n x 1 weights
%                      balance: n x 1 boolean indicating balanced reactions
%
%        groupDecomposableBool: m x 1 boolean indicating metabolites with group decomposition
%                         cids: m x 1 compound ids

%                    std_inchi: m x 1 standard InChI
%             std_inchi_stereo: m x 1 standard InChI
%      std_inchi_stereo_charge: m x 1 standard InChI

%                      Ematrix: m x e elemental matrix
%                     kegg_pKa: [628×1 struct]
%
%                            G: m x g group incicence matrix
%                       groups: g x 1 cell array of group definitions
%
%            Model2TrainingMap: mlt x 1 mapping of model.mets to training data metabolites
%

if ~exist('printLevel','var')
    printLevel=0;
end


fprintf('Creating group incidence matrix\n');

% first just run the script to get the list of group names
fullpath = which('getGroupVectorFromInchi.m');
fullpath = regexprep(fullpath,'getGroupVectorFromInchi.m','');


[status,result] = system('python2 --version');
if status~=0
    % https://github.com/bdu91/group-contribution/blob/master/compound_groups.py
    % Bin Du et al. Temperature-Dependent Estimation of Gibbs Energies Using an Updated Group-Contribution Method     
    [status,groupsTemp] = system(['python ' fullpath 'compound_groups.py -l']);
    if status~=0
        error('createGroupIncidenceMatrix: call to compound_groups.py failed')
    end
else
    if 1
        inchi2gv = 'inchi2gv';
    else
        inchi2gv = 'compound_groups';
    end
    [status,groupsTemp] = system(['python2 ' fullpath  inchi2gv '.py -l']);%seems to only work with python 2, poor coding to not check the status here!
    if status~=0
        fprintf('%s\n','If you get a python error like: undefined symbol: PyFPE_jbuf, then see the following:')
        fprintf('%s\n','https://stackoverflow.com/questions/36190757/numpy-undefined-symbol-pyfpe-jbuf/47703373')
        error('createGroupIncidenceMatrix: call to inchi2gv.py failed')
    end
end

if isnumeric(trainingModel.cids_that_dont_decompose)
    eval(['trainingModel.cids_that_dont_decompose = {' regexprep(sprintf('''C%05d''; ',trainingModel.cids_that_dont_decompose),'(;\s)$','') '};']);
end

groups = regexp(groupsTemp,'\n','split')';
clear groupsTemp;
trainingModel.groups = groups(~cellfun(@isempty, groups));
trainingModel.G = sparse(length(trainingModel.metKEGGID), length(trainingModel.groups));
trainingModel.groupDecomposableBool = false(size(trainingModel.metKEGGID));
trainingModel.testMetBool = false(size(trainingModel.metKEGGID));
for i = 1:length(trainingModel.metKEGGID)
    [score, modelRow] = max(full(mappingScore(:,i)));
    if score == 0 
        inchi = trainingModel.inchi.nonstandard{i};
    else
        % if there is a match to the model, use the InChI from there to be consistent with later transforms
        inchi = model.inchi.nonstandard{modelRow};
        trainingModel.testMetBool(i)=1;
    end

    % There might be compounds in the model but not in the training data that also cannot be
    % decomposed, we need to take care of them too (e.g. DMSO - C11143)
    if isempty(inchi) || any(ismember(trainingModel.metKEGGID{i}, trainingModel.cids_that_dont_decompose))
        trainingModel.G(:, end+1) = 0; % add a unique 1 in a new column for this undecomposable compound
        trainingModel.G(i, end) = 1;
        trainingModel.groupDecomposableBool(i) = false;
    else
        group_def = getGroupVectorFromInchi(inchi);
        if length(group_def) == length(trainingModel.groups)
            trainingModel.G(i, 1:length(group_def)) = group_def;
            trainingModel.groupDecomposableBool(i) = true;
        elseif isempty(group_def)
            warning(['createGroupIncidenceMatrix: undecomposable inchi: ' inchi])
            trainingModel.G(:, end+1) = 0; % add a unique 1 in a new column for this undecomposable compound
            trainingModel.G(i, end) = 1;
            trainingModel.groupDecomposableBool(i) = false;
            trainingModel.cids_that_dont_decompose = [trainingModel.cids_that_dont_decompose; trainingModel.metKEGGID{i}];
        else
            fprintf('InChI = %s\n', inchi);
            fprintf('*************\n%s\n', getGroupVectorFromInchi(inchi, printLevel));
            error(sprintf('ERROR: while trying to decompose compound C%05d', trainingModel.metKEGGID{i}));
        end
    end
end
trainingModel.G = sparse(trainingModel.G);

trainingModel.Model2TrainingMap = zeros(size(model.mets));
done = {};

for n = 1:length(model.mets)
    % first find all metabolites with the same name (can be in different compartments)
    met = model.mets{n}(1:end-3);
    if any(strcmp(met, done)) % this compound was already mapped
        continue;
    end
    done = [done; {met}];
    metIdx = strmatch([met '['], model.mets);
    inchi = model.inchi.nonstandard{n};

    [score, trainingRow] = max(full(mappingScore(n,:)));
    if score == 0 % this compound is not in the training data
        trainingRow = size(trainingModel.G, 1) + 1;
        trainingModel.S(trainingRow, :) = 0; % Add an empty row to S
        trainingModel.testMetBool(i)=1;
        % Add a row in G for this compound, either with its group vector,
        % or with a unique 1 in a new column dedicated to this compound
        trainingModel.G(trainingRow, :) = 0;
        group_def = getGroupVectorFromInchi(inchi);
        if length(group_def) == length(trainingModel.groups)
            trainingModel.G(trainingRow, 1:length(group_def)) = group_def;
            trainingModel.groupDecomposableBool(trainingRow) = true;
            
        elseif isempty(group_def)
            trainingModel.G(:, end+1) = 0; % add a unique 1 in a new column for this undecomposable compound
            trainingModel.G(trainingRow, end) = 1;
            trainingModel.groupDecomposableBool(trainingRow) = false;
        else
            error('The length of the group vector is different than the number of groups');
        end
    end
    trainingModel.Model2TrainingMap(metIdx) = trainingRow; % map the model met to this NIST compound
end

[m,g]=size(trainingModel.G);
trainingModel.trainingMetBool=false(m,1);
trainingModel.trainingMetBool(1:length(trainingModel.metKEGGID),1)=1;