% The COBRAToolbox: testoutputNetworkCytoscape.m
%
% Purpose:
%     - testtestoutputNetworkCytoscape tests the testoutputNetworkCytoscape function
%       that transforms a hypergraph into a graph (cytoscape format)
% 
%
% Author:
%     - Marouen BEN GUEBILA 09/02/2017

% define global paths
global path_TOMLAB

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testoutputNetworkCytoscape']);

load('ecoli_core_model', 'model');

%test solver packages
solverPkgs = {'tomlab_cplex'};%,'ILOGcomplex'};

for k = 1:length(solverPkgs)
    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(path_TOMLAB));
    end
    
    %call function
    notShownMets = outputNetworkCytoscape(model,'data',model.rxns,[],model.mets,[],100);
    
    %call test
    for j={'test.sif','test_edgeType.noa','test_nodeComp.noa',...
            'test_nodeType.noa','test_subSys.noa'}
        testIO(j{1});
    end
    
    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(path_TOMLAB));
    end
end

% change the directory
cd(CBTDIR)


