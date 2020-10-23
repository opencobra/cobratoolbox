% The COBRAToolbox: testMoieties.m
%
% Purpose:
%     - testMoieties tests the functionality of conserved moities tools
%       and compares it to expected data.
%     - testMoieties identifies conserved moieties in metabolic networks by graph
%       theoretical analysis of atom transition networks.
%
% Authors:
%     - Sylvain Arreckx March 2017
%

%Test presence of required toolboxes.

requireOneSolverOf = {'gurobi','ibm_cplex'};
if 0
    requiredToolboxes = {'bioinformatics_toolbox'};
    prepareTest('requireOneSolverOf',requireOneSolverOf,'toolboxes',requiredToolboxes);
else
    prepareTest('requireOneSolverOf',requireOneSolverOf,'requiredToolboxes', {'statistics_toolbox'});
end

% define global paths
global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMoieties'));
cd(fileDir);

% Load reference data
load('refData_moieties.mat')

% Load the dopamine synthesis network
if 0
    model = readCbModel('subDas.mat');
else
    modelDir = getDistributedModelFolder('subDas.mat');
    model = load([modelDir filesep 'subDas.mat']);
    if isfield(model,'model')
        model=model.model;
    end
end
model.rxns{2} = 'alternativeR2';

% Predicted atom mappings from DREAM (http://selene.princeton.edu/dream/)
rxnfileDir = [CBTDIR filesep 'tutorials' filesep 'analysis' filesep 'atomicallyResolveReconstruction' filesep 'data' filesep 'atomMapped'];
R2rxn = regexp(fileread([rxnfileDir filesep 'R2.rxn']), '\n', 'split')';
R2rxn{2} = 'alternativeR2';
R2rxn{135}(62:63) = '18';
R2rxn{151}(62:63) = '19';
fid2 = fopen([rxnfileDir filesep 'alternativeR2.rxn'], 'w');
fprintf(fid2, '%s\n', R2rxn{:});
fclose(fid2);

if 0
    %compare old and new code for building atom transition multigraph
    ATN = buildAtomTransitionNetwork(model, rxnfileDir);

    options.directed=1;
    options.sanityChecks=1;
    
    dATM = buildAtomTransitionMultigraph(model, rxnfileDir, options);
    Edges=dATM.Edges;
    Edges = sortrows(Edges,'TransIndex','ascend');
    bool = strcmp(ATN.atrans,Edges.Trans);
    if ~all(bool)
        warning('Old and new code for building atom transition multigraph do not match')
    end
end

if 0
    %old code
    % Generate atom transition network
    ATN = buildAtomTransitionNetwork(model, rxnfileDir);
    assert(all(all(ATN.A == ATN0.A)), 'Atom transition network does not match reference.')
    if 0
        %TODO, currently this is incompatible with classifyMoieties
        %test addition of fake reaction to model, that is not atom mapped
        model = addReaction(model,'newRxn1','reactionFormula','A -> B + 2 C');
    end
    
    % Identify conserved moieties
    [L, M, moietyFormulas, moieties2mets, moieties2vectors, atoms2moieties, mtrans2rxns, atrans2mtrans] = identifyConservedMoietiesOld(model, ATN);
    L=L';
else
    %2020 code

   
    options.directed=0;
    options.sanityChecks=1;
    
    dATM = buildAtomTransitionMultigraph(model, rxnfileDir, options);
    A = incidence(dATM);
    
    %check that the incidence matrices are the same, taking into account
    %the reordering of edges by the digraph function
    assert(all(all(A == ATN0.A(:,dATM.Edges.OrigTransInstIndex))), 'Atom transition network does not match reference.')
    
    if 0
        %TODO, currently this is incompatible with classifyMoieties
        %test addition of fake reaction to model, that is not atom mapped
        model = addReaction(model,'newRxn1','reactionFormula','A -> B + 2 C');
    end
    
    options.sanityChecks = 1;
    [L, M, moietyFormulae, moieties2mets, moiety2isomorphismClass, atrans2isomorphismClass, arm] = identifyConservedMoieties(model, dATM, options);
end

assert(all(all(L == L0')), 'Moiety matrix does not match reference.')

if 0 %old code
    assert(all(all(M == Lambda0)), 'Moiety graph does not match reference.')
    
    
    % Classify moieties
    types = classifyMoieties(L', model.S);
    assert(all(strcmp(types, types0)), 'Moiety classifications do not match reference.')
    
    % Decompose moiety vectors
    rbool = ismember(model.rxns, ATN.rxns);  % True for reactions included in ATN
    mbool = any(model.S(:, rbool), 2);  % True for metabolites in ATN reactions
    N = model.S(mbool, rbool);
    
    solverOK = changeCobraSolver('gurobi', 'MILP', 0);
    if solverOK
        fprintf(' -- Running testMoieties using the solver interface: gurobi ... ');
        
        D = decomposeMoietyVectors(L', N);
        assert(all(all(D == D0)), 'Decomposed moiety matrix does not match reference.')
        
        % Build elemental matrix for the dopamine network
        [E, elements] = constructElementalMatrix(model.metFormulas, model.metCharges);
        
        % Estimate chemical formulas of decomposed moieties
        [decomposedMoietyFormulas, M] = estimateMoietyFormulas(D, E, elements);
        assert(all(strcmp(decomposedMoietyFormulas, decomposedMoietyFormulas0)), 'Estimated formulas of decomposed moieties do not match reference.')
        
        fprintf('Done\n');
    end
end

cd(currentDir)
