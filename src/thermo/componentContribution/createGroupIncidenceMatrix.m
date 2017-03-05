function training_data = createGroupIncidenceMatrix(model, training_data)
% Initialize G matrix, and then use the python script "inchi2gv.py" to decompose each of the 
% compounds that has an InChI and save the decomposition as a row in the G matrix.
%
% INPUTS
%
% OUTPUTS
%

% get the scores for the mappings of compounds (reflecting the certainty in the mapping)
mappingScore = getMappingScores(model, training_data);

fprintf('Creating group incidence matrix\n');

% first just run the script to get the list of group names
fullpath = which('getGroupVectorFromInchi.m');
fullpath = regexprep(fullpath,'getGroupVectorFromInchi.m','');
[status,groupsTemp] = system(['python2 ' fullpath 'inchi2gv.py -l']);%seems to only work with python 2, poor coding to not check the status here!
if status~=0
    error('createGroupIncidenceMatrix: call to inchi2gv.py failed')
end
groups = regexp(groupsTemp,'\n','split');
clear groupsTemp;
training_data.groups = groups(~cellfun(@isempty, groups));
training_data.G =sparse(length(training_data.cids), length(training_data.groups));
training_data.has_gv = true(size(training_data.cids));

for i = 1:length(training_data.cids)
    [score, modelRow] = max(full(mappingScore(:,i)));
    if score == 0 % if there is a match to the model, use the InChI from there to be consistent with later transforms
        inchi = training_data.nstd_inchi{i};
    else
        inchi = model.inchi.nonstandard{modelRow};
    end

    % There might be compounds in iAF1260 but not in the training data that also cannot be
    % decomposed, we need to take care of them too (e.g. DMSO - C11143)
    if isempty(inchi) || ismember(training_data.cids(i), training_data.cids_that_dont_decompose)
        training_data.G(:, end+1) = 0; % add a unique 1 in a new column for this undecomposable compound
        training_data.G(i, end) = 1;
        training_data.has_gv(i) = false;
    else            
        group_def = getGroupVectorFromInchi(inchi);
        if length(group_def) == length(training_data.groups)
            training_data.G(i, 1:length(group_def)) = group_def;
            training_data.has_gv(i) = true;
        elseif isempty(group_def)
            warning(['createGroupIncidenceMatrix: undecomposable inchi: ' inchi])
            training_data.G(:, end+1) = 0; % add a unique 1 in a new column for this undecomposable compound
            training_data.G(i, end) = 1;
            training_data.has_gv(i) = false;
            training_data.cids_that_dont_decompose = [training_data.cids_that_dont_decompose; training_data.cids(i)];
        else
            fprintf('InChI = %s\n', inchi);
            fprintf('*************\n%s\n', getGroupVectorFromInchi(inchi, false));
            error(sprintf('ERROR: while trying to decompose compound C%05d', training_data.cids(i)));
        end
    end
end
training_data.G = sparse(training_data.G);

training_data.Model2TrainingMap = zeros(size(model.mets));
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
        trainingRow = size(training_data.G, 1) + 1;
        training_data.S(trainingRow, :) = 0; % Add an empty row to S

        % Add a row in G for this compound, either with its group vector,
        % or with a unique 1 in a new column dedicate to this compound        
        training_data.G(trainingRow, :) = 0;
        group_def = getGroupVectorFromInchi(inchi);
        if length(group_def) == length(training_data.groups)
            training_data.G(trainingRow, 1:length(group_def)) = group_def;
            training_data.has_gv(trainingRow) = true;
        elseif isempty(group_def)
            training_data.G(:, end+1) = 0; % add a unique 1 in a new column for this undecomposable compound
            training_data.G(trainingRow, end) = 1;
            training_data.has_gv(trainingRow) = false;
        else
            error('The length of the group vector is different than the number of groups');
        end
    end
    training_data.Model2TrainingMap(metIdx) = trainingRow; % map the model met to this NIST compound
end
