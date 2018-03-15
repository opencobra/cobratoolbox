% The COBRAToolbox: testReadWriteCbModel.m
%
% Purpose:
%     - test the readCbModel and writeCbModel functions for different
%       file types.
%
% Authors:
%     - Stefania Magnusdottir

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadWriteCbModel'));
cd(fileDir);

% define tolerance
tol = 1e-6;

% read in mat model
model = getDistributedModel('ecoli_core_model.mat');

% convert an old style model
model = convertOldStyleModel(model);
model = alphabetizeModel(model);

modelMod = model;
modelMod.mets(1:30) = strrep(model.mets(1:30),'[c]','[c+s.i]');
modelMod.comps = {'c','e','c+s.i'}';

models = {model,modelMod};

writeTypes = {'mat', 'sbml', 'xlsx'};

% Note: test is only compatible with Matlab R2015b or later
if ~verLessThan('matlab', '8.6')
    % write out and read in different file types
    for i = 1:length(writeTypes)
        for j = 1:length(models)
            model = models{j};
            % write model
            writeCbModel(model, writeTypes{i}, 'testData');
            
            % read model
            if strcmp(writeTypes{i}, 'sbml')
                modelIn = readCbModel(['testData.', 'xml']);
            else
                modelIn = readCbModel(['testData.', writeTypes{i}]);
            end
            modelIn = alphabetizeModel(modelIn);
            %lets alphabetize the models.
            
            % test            
            assert(isequal(model.lb, modelIn.lb)) 
            assert(isequal(model.b, modelIn.b))
            assert(isequal(model.ub, modelIn.ub))
            assert(isequal(sort(model.mets), sort(modelIn.mets)))
            assert(isequal(model.csense, modelIn.csense))
            assert(isequal(model.osenseStr, modelIn.osenseStr))
            assert(isequal(model.rxns, modelIn.rxns))
            assert(isequal(sort(model.genes), sort(modelIn.genes)))
            assert(isequal(model.c, modelIn.c))
            
            % NOTE: model.rules and model.S can be different from modelIn.S and modelIn.rules
            %       as the metabolites are not always ordered in the same way.
            
            solverOK = changeCobraSolver('glpk');
            
            if solverOK
                % run an LP and compare the solutions
                solModel = optimizeCbModel(model);
                solModelIn = optimizeCbModel(modelIn);
                
                assert(abs(solModel.f - solModelIn.f) < tol)
                assert(solModel.stat == solModelIn.stat)
            end
            
            % clean up
            if strcmp(writeTypes{i}, 'sbml')
                delete(['testData.', 'xml']);
            else
                delete(['testData.', writeTypes{i}]);
            end
        end
    end
else
    fprintf('\ntestWriteCbModel is not compatible with this version of MATLAB. Please upgrade your version of MATLAB.\n\n');
end

% change to old directory
cd(currentDir);
