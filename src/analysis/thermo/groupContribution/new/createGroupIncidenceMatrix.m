function combinedModel = createGroupIncidenceMatrix(model, trainingModel, param)
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
% trainingModel.mets                        p x 1 metabolite abbreviations
% trainingModel.rxns                        n x 1 reaction abbreviations
% trainingModel.metKEGGID:                  p x 1 cell array of metabolite KEGGID
% trainingModel.inchi.nonstandard:          p x 1 cell array of nonstandard InChI
% trainingModel.mappingScore
%
% OPTIONAL INPUT:
% trainingModel.cids_that_dont_decompose    cid of kegg compounds that are not decomposable with param.fragmentationMethod='manual';
% 
% OUTPUT:
% combinedModel:
% combinedModel.S:                          k x n stoichiometric matrix of training padded with zero rows for metabolites exclusive to test data
% combinedModel.drG0:                       n x 1 experimental standard reaction Gibbs energy
% combinedModel.drG0_prime:                 n x 1 experimental standard transformed reaction Gibbs energy
% combinedModel.T:                          n x 1 temperature
% combinedModel.I:                          n x 1 ionic strength
% combinedModel.pH:                         n x 1 pH
% combinedModel.pMg:                        n x 1 pMg
% combinedModel.G:                          k x g group incidence matrix
% combinedModel.groups:                     g x 1 cell array of group definitions
% combinedModel.trainingMetBool             k x 1 boolean indicating training metabolites in G
% combinedModel.testMetBool                 k x 1 boolean indicating test metabolites in G
% combinedModel.groupDecomposableBool:      k x 1 boolean indicating metabolites with group decomposition
% combinedModel.inchiBool                   k x 1 boolean indicating metabolites with inchi
% combinedModel.test2CombinedModelMap:      m x 1 mapping of model.mets to combinedModel.mets

% combinedModel.cids_that_dont_decompose:   z x 1 ids of compounds that do not decomopose

%

if isempty(model)
    model.inchi.nonstandard=[];
end
if isempty(trainingModel)
    trainingModel.inchi.nonstandard=[];
end

if ~exist('param','var')
    param=struct();
end
if ~isfield(param,'printLevel')
    param.printLevel=0;
end

%parameters for auto fragmentation
if ~isfield(param,'fragmentationMethod')
    param.fragmentationMethod='abinito';
end
if ~isfield(param,'modelCache')
    param.modelCache=[];
end
if ~isfield(param,'printLevel')
    param.printLevel=0;
end
if ~isfield(param,'radius')
    param.radius=1;
end
if ~isfield(param,'dGPredictorPath')
    param.dGPredictorPath='/home/rfleming/work/sbgCloud/code/dGPredictor';
end
if ~isfield(param,'canonicalise')
    param.canonicalise=0;
end
        
fprintf('Creating group incidence matrix\n');

switch param.fragmentationMethod
    case 'abinito'
        %function model = createFragmentIncidenceMatrix(inchi,radius,dGPredictorPath,canonicalise)
        % model.G:    k x g  fragment incidence matrix
        
        %function [fragmentedMol,decomposableBool,inchiExistBool] = autoFragment(inchi,radius,dGPredictorPath,canonicalise,cacheName,printLevel)
        %given one or more inchi, automatically fragment it into a set of smiles
        %each centered around an atom with radius specifying the number of bonds to
        %neighbouring atoms
        %
        % INPUT
        % inchi             n x 1 cell array of molecules each specified by InChI strings
        %                   or a single InChI string as a char
        % OPTIONAL INPUT
        % radius            number of bonds around each central smiles atom
        % dGPredictorPath   path to the folder containg a git clone of https://github.com/maranasgroup/dGPredictor
        %                   path must be the full absolute path without ~/
        % cacheName         fileName of cache to load (if it exists) or save to (if it does not exist)
        %
        % OUTPUT
        % fragmentedMol      n x 1 structure with the following fields for each inchi:
        % *.inchi            inchi string
        % *.smilesCount      Map structure
        %                    Each Key is a canonical smiles string (not canonical smiles if canonicalise==0)
        %                    Each value is the incidence of each smiles string in a molecule

        %fragment each of the trainingModel inchi
        if param.printLevel>0
            fprintf('%s\n','Ab inito fragmentation of each of the trainingModel inchi...')
        end

        %decide which inchi to use for fragmentation
        trainingModelInchi = trainingModel.inchi.nonstandard;
        modelInchi = model.inchi.nonstandard;
        
        nTrainingModelMets=length(trainingModelInchi);
        for i=1:nTrainingModelMets
            trainingModelFragmentedMol(i).inchi = trainingModelInchi{i};
            trainingModelFragmentedMol(i).smilesCounts = containers.Map();
        end
        trainingModelDecomposableBool=false(nTrainingModelMets,1);
        trainingModelInchiExistBool=false(nTrainingModelMets,1);
        for r=1:param.radius
            [trainingModelFragmentedMolr,trainingModelDecomposableBoolr,trainingModelInchiExistBoolr] = autoFragment(trainingModelInchi,r,param.dGPredictorPath,param.canonicalise,['autoFragment_trainingModel_' int2str(r)],param.printLevel-1);
            for i=1:nTrainingModelMets
                %disp(i)
%                 if i==55
%                     pause(0.1)
%                 end
                if ~isempty(trainingModelFragmentedMolr(i).smilesCounts)
                    trainingModelFragmentedMol(i).smilesCounts = [trainingModelFragmentedMol(i).smilesCounts;trainingModelFragmentedMolr(i).smilesCounts];
                end
            end
            trainingModelDecomposableBool = trainingModelDecomposableBool | trainingModelDecomposableBoolr;
            trainingModelInchiExistBool = trainingModelInchiExistBool | trainingModelInchiExistBoolr;
        end
        if param.printLevel>0
            fprintf('%s\n','...done.')
        end
        
        %fragment each of the model inchi
        if param.printLevel>0
            fprintf('%s\n','Ab inito fragmentation of each of the model inchi...')
        end
        
        nModelMets=length(modelInchi);
        for i=1:nModelMets
            modelFragmentedMol(i).inchi = modelInchi{i};
            modelFragmentedMol(i).smilesCounts = containers.Map();
        end
        modelDecomposableBool=false(nModelMets,1);
        modelInchiExistBool=false(nModelMets,1);
        for r=1:param.radius
            [modelFragmentedMolr,modelDecomposableBoolr,modelInchiExistBoolr] = autoFragment(modelInchi,r,param.dGPredictorPath,param.canonicalise,[param.modelCache '_' int2str(r)],param.printLevel-1);
            for i=1:nModelMets
                %disp(i)
                if ~isempty(modelFragmentedMolr(i).smilesCounts)
                    modelFragmentedMol(i).smilesCounts = [modelFragmentedMol(i).smilesCounts;modelFragmentedMolr(i).smilesCounts];
                end
            end
            modelDecomposableBool = modelDecomposableBool | modelDecomposableBoolr;
            modelInchiExistBool = modelInchiExistBool | modelInchiExistBoolr;
        end
        %modelInchi=model.inchi.nonstandard;
        %[modelFragmentedMol,modelDecomposableBool,modelInchiExistBool] = autoFragment(modelInchi,param.radius,param.dGPredictorPath,param.canonicalise,param.modelCache,param.printLevel-1);
        if param.printLevel>0
            fprintf('%s\n','...done.')
        end

        trainingFragmentSmiles = cell(0); 
        %collate the fragments in the training model
        for i = 1:nTrainingModelMets
            if trainingModelDecomposableBool(i)
                if param.printLevel>1
                    disp(trainingModelFragmentedMol(i).inchi)
                    trainingModelFragmentedMol(i).smilesCounts
                end
                if trainingModelInchiExistBool(i)
                    if isempty(trainingModelFragmentedMol(i).inchi)
                        trainingModelDecomposableBool(i)=0;
                        trainingModelInchiExistBool(i)=0;
                    else
                        trainingFragmentSmiles = [trainingFragmentSmiles;trainingModelFragmentedMol(i).smilesCounts.keys'];
                    end
                else
                    trainingModelDecomposableBool(i)=0;
                end
            end
        end
        %set of unique fragments in the training model
        uniqueTrainingFragmentSmiles = unique(trainingFragmentSmiles);
        
        testFragmentSmiles = cell(0); 
        %now the model mol
        for i = 1:nModelMets
            if modelDecomposableBool(i)
                if param.printLevel>1
                    disp(modelFragmentedMol(i).inchi)
                    modelFragmentedMol(i).smilesCounts
                end
                if modelInchiExistBool(i)
                    if isempty(modelFragmentedMol(i).inchi)
                        modelDecomposableBool(i)=0;
                        modelInchiExistBool(i)=0;
                    else
                        testFragmentSmiles = [testFragmentSmiles;modelFragmentedMol(i).smilesCounts.keys'];
                    end
                else
                    modelDecomposableBool(i)=0;
                end
            end
        end
        %set of unique fragments in the test model
        uniqueTestFragmentSmiles = unique(testFragmentSmiles);
        
        fragmentSmilesUniqueToTraining = setdiff(uniqueTrainingFragmentSmiles,uniqueTestFragmentSmiles);
        if ~isempty(fragmentSmilesUniqueToTraining)
            fprintf('%s\n',['There are ' int2str(length(fragmentSmilesUniqueToTraining)) ' fragments unique to the training model.'])
        end
        fragmentSmilesInCommon = intersect(uniqueTestFragmentSmiles,uniqueTrainingFragmentSmiles);
        if ~isempty(fragmentSmilesInCommon)
            fprintf('%s\n',['There are ' int2str(length(fragmentSmilesInCommon)) ' fragments in common between the training and test models.'])
        end
        fragmentSmilesUniqueToTest = setdiff(uniqueTestFragmentSmiles,uniqueTrainingFragmentSmiles);
        if ~isempty(fragmentSmilesUniqueToTest)
            fprintf('%s\n',['There are ' int2str(length(fragmentSmilesUniqueToTest)) ' fragments unique to the test model.'])
        end
        
        %start based on training model
        combinedModel = trainingModel;
        
        % combinedModel.groupDecomposableBool:      k x 1 boolean indicating metabolites with group decomposition
        combinedModel.groupDecomposableBool=[trainingModelDecomposableBool;modelDecomposableBool];
        combinedModel.inchiBool = [trainingModelInchiExistBool;modelInchiExistBool];
        % combinedModel.trainingMetBool             k x 1 boolean indicating training metabolites in G
        combinedModel.trainingMetBool = [true(nTrainingModelMets,1);false(nModelMets,1)];
        % combinedModel.testMetBool                 k x 1 boolean indicating test metabolites in G
        combinedModel.testMetBool = [false(nTrainingModelMets,1);true(nModelMets,1)];
        
        %fragments unique to the combined model
        uniqueFragmentSmiles = unique([uniqueTrainingFragmentSmiles;uniqueTestFragmentSmiles]);
        nFrag=length(uniqueFragmentSmiles);
        nNonDecomposable=nnz(combinedModel.groupDecomposableBool==0);
        
        combinedModel.inchi.nonstandard = [trainingModelInchi;modelInchi];
        
        nMets = nTrainingModelMets + nModelMets;
        %preallocate the group incidence matrix
        combinedModel.G = sparse(nMets,nFrag+nNonDecomposable);
        
        %use the keys to define the groups
        combinedModel.groups = [uniqueFragmentSmiles;trainingModelInchi(~trainingModelDecomposableBool);modelInchi(~modelDecomposableBool)];
        
        %map each of the training model fragments to the consolidated list of fragments
        d=1;
        for i = 1:nTrainingModelMets
            if trainingModelDecomposableBool(i)
                %disp(i)
                bool = isKey(trainingModelFragmentedMol(i).smilesCounts,uniqueFragmentSmiles);
                combinedModel.G(i,bool)=cell2mat(values(trainingModelFragmentedMol(i).smilesCounts));
            else
                %non decomposable training molecule
                combinedModel.G(i,nFrag+d) = 1;
                d=d+1;
            end
        end
        %map each of the test model fragments to the consolidated list of fragments
        for i = 1:nModelMets
            if modelDecomposableBool(i)
                bool = isKey(modelFragmentedMol(i).smilesCounts,uniqueFragmentSmiles);
                combinedModel.G(nTrainingModelMets+i,bool)=cell2mat(values(modelFragmentedMol(i).smilesCounts));
            else
                if d>nNonDecomposable
                    error('inconsistent number of non-decomposable metabolites')
                end
                %non decomposable training molecule
                combinedModel.G(nTrainingModelMets+i,nFrag+d) = 1;
                d=d+1;
            end
        end
        if d~=nNonDecomposable+1
            error('inconsistent number of non-decomposable metabolites')
        end
        
        nExclusivelyTestMets = nnz(~combinedModel.trainingMetBool & combinedModel.testMetBool);
        combinedModel.S = [trainingModel.S; sparse(nExclusivelyTestMets,size(trainingModel.S,2))]; % Add an empty row to S for each metabolite in the test model
        combinedModel.mets=[trainingModel.mets;model.mets];
        combinedModel.rxns=trainingModel.rxns;
        
        uniqueMets = unique(combinedModel.mets);
        if length(uniqueMets)~=length(combinedModel.mets)
            error('combinedModel.mets is not a primary key')
        end
        if any(cellfun(@isempty,combinedModel.mets))
            error('combinedModel.mets is not a primary key')
        end
        
        if 1
            save('debug_prior_to_regulariseGroupIncidenceMatrix')
            %%
            %analyse similar and duplicate metabolites
            [groupM,inchiM] = regulariseGroupIncidenceMatrix(combinedModel,param.printLevel);
            
            %assume that metabolites with the same group decomposition are identical
            test2CombinedModelM = groupM;
            
            %ignore duplicates within the training metabolite set
            test2CombinedModelM(:,combinedModel.trainingMetBool)=0;
            
            %boolean identifier of duplicates
            duplicatesBool = any(test2CombinedModelM,1);
            
            %add the test metabolites on the diagonal to preserve mapping to unique metabolites in test model
            test2CombinedModelM = test2CombinedModelM + diag(combinedModel.testMetBool);
            
            %remove all duplicate metabolites from the arguments to the map
            test2CombinedModelM = test2CombinedModelM(~duplicatesBool,:);
            
            combinedModel.test2CombinedModelMap=zeros(nModelMets,1);
            for i=1:size(test2CombinedModelM,1)
                if any(test2CombinedModelM(i,:))
                    combinedModel.test2CombinedModelMap(test2CombinedModelM(i,combinedModel.testMetBool)~=0)=i;
                end
            end
            if any(combinedModel.test2CombinedModelMap==0)
                error('Mismatch in combinedModel.test2CombinedModelMap')
            end
            
            %                            S: [6507×4149 double]
            %                         rxns: {4149×1 cell}
            %                           lb: [4149×1 double]
            %                         cids: {672×1 cell}
            %                    dG0_prime: [4149×1 double]
            %                            T: [4149×1 double]
            %                            I: [4149×1 double]
            %                           pH: [4149×1 double]
            %                          pMg: [4149×1 double]
            %                      weights: [4149×1 double]
            %                      balance: [4149×1 double]
            %     cids_that_dont_decompose: [43×1 double]
            %                         mets: {6507×1 cell}
            %                    metKEGGID: {672×1 cell}
            %                        inchi: [1×1 struct]
            %                      molBool: [672×1 logical]
            %                    inchiBool: [6507×1 logical]
            %           compositeInchiBool: [672×1 logical]
            %                  metFormulas: {672×1 cell}
            %                   metCharges: [672×1 double]
            %                pseudoisomers: [672×1 struct]
            %                           ub: [4149×1 double]
            %                          dG0: [4149×1 double]
            %        groupDecomposableBool: [6507×1 logical]
            %              trainingMetBool: [6507×1 logical]
            %                  testMetBool: [6507×1 logical]
            %                            G: [6507×1536 double]
            %                       groups: {1536×1 cell}
            %        test2CombinedModelMap: [5835×1 double]
            
            %save the original combined model
            combinedModelOld = combinedModel;
            clear combinedModel;
            %%
            %each row of the group incidence matrix should correspond to a unique metabolite
            %account for any metabolites in the test dataset that are duplicated in the training dataset
            combinedModel.S = combinedModelOld.S(~duplicatesBool,:);
            combinedModel.mets = combinedModelOld.mets(~duplicatesBool);
            combinedModel.inchi.nonstandard = combinedModelOld.inchi.nonstandard(~duplicatesBool);
            combinedModel.inchiBool = combinedModelOld.inchiBool(~duplicatesBool);
            combinedModel.groupDecomposableBool = combinedModelOld.groupDecomposableBool(~duplicatesBool);
            combinedModel.trainingMetBool = combinedModelOld.trainingMetBool(~duplicatesBool);
            combinedModel.testMetBool = combinedModelOld.testMetBool(~duplicatesBool);
            combinedModel.rxns = combinedModelOld.rxns;
            combinedModel.DrG0 = combinedModelOld.DrG0;
            combinedModel.T = combinedModelOld.T;
            combinedModel.pH = combinedModelOld.pH;
            combinedModel.pMg = combinedModelOld.pMg;
            combinedModel.I = combinedModelOld.I;
            combinedModel.G = combinedModelOld.G(~duplicatesBool,:);
            combinedModel.groups = combinedModelOld.groups;
            combinedModel.test2CombinedModelMap = combinedModelOld.test2CombinedModelMap;

        else
            combinedModel.test2CombinedModelMap = nTrainingModelMets + (1:nModelMets)';
        end
    case 'manual'
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
%            test2CombinedModelMap: mlt x 1 mapping of model.mets to training data metabolites

        % Initialize `G` matrix, and then use the python script "inchi2gv.py" to decompose each of the
        % compounds that has an 'InChI' and save the decomposition as a row in the `G` matrix.

        %Match between the metabolites in the model and the metabolites in the training model
        mappingScore = getMappingScores(model, trainingModel);

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
        trainingModel.trainingMetBool = false(size(trainingModel.metKEGGID));
        for i = 1:length(trainingModel.metKEGGID)
            trainingModel.trainingMetBool(i)=1;
            [score, modelRow] = max(full(mappingScore(:,i)));
            if score == 0
                inchi = trainingModelInchi{i};
                trainingModel.testMetBool(i)=0;
                
            else
                % if there is a match to the model, use the InChI from there to be consistent with later transforms
                inchi = modelInchi{modelRow};
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
                    fprintf('*************\n%s\n', getGroupVectorFromInchi(inchi, param.printLevel));
                    error(sprintf('ERROR: while trying to decompose compound C%05d', trainingModel.metKEGGID{i}));
                end
            end
        end
        trainingModel.G = sparse(trainingModel.G);
        
        
        trainingModel.test2CombinedModelMap = zeros(size(model.mets));
        done = {};
        for n = 1:length(model.mets)
            % first find all metabolites with the same name (can be in different compartments)
            met = model.mets{n}(1:end-3);
            if any(strcmp(met, done)) % this compound was already mapped
                continue;
            end
            done = [done; {met}];
            
            inchi = modelInchi{n};
            
            [score, trainingRow] = max(full(mappingScore(n,:)));
            if score == 0 % this compound is not in the training data
                trainingRow = size(trainingModel.G, 1) + 1;
                trainingModel.trainingMetBool(trainingRow)=1;
                trainingModel.S(trainingRow, :) = 0; % Add an empty row to S
                
                % Add a row in G for this compound, either with its group vector,
                % or with a unique 1 in a new column dedicate to this compound
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
                    error('The length of the group vector is different from the number of groups');
                end
            end
            
            metIdx = contains(model.mets,[met '[']);
            trainingModel.test2CombinedModelMap(metIdx) = trainingRow; % map the model met to this NIST compound
        end
        %new variable name for combined model
        combinedModel = trainingModel;
    otherwise
        error(['Unrecognised param.fragmentationMethod =' param.fragmentationMethod])
end

boolGroup=~any(combinedModel.G,1);
if any(boolGroup)
    error([int2str(nnz(boolGroup)) ' groups without any corresponding metabolite'])
end
boolMet=~any(combinedModel.G,2);
if any(boolMet)
    error([int2str(nnz(boolMet)) ' metabolites without any corresponding group'])
end


