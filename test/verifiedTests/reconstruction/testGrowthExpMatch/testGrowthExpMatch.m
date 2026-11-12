%testGrowthExpMatch tests the functionality of all the components of growthExpMatch
%
%Procedure to run growthExpMatch:
%(1) obtain all input files (ie. model, CompAbr, and KEGGID are from BiGG, KEGGList is from KEGG website)
%(2) remove desired reaction from model with removeRxns, or set the model 
%       on a particular Carbon or Nitrogen source
%(3) create an SUX Matrix by using the function MatricesSUX = 
%       generateSUXMatrix(model,Dictionary, KEGGFilename,Compartment)
%(4) run it through growthExpMatch using [solution,b,solInt]=Smiley(MatricesSUX)
%(5) solution.importedRxns contains the solutions to all iterations (in
%       this particular test, we removed reaction ENO from model and
%       obtained 'R00658_f' which is the KEGGID for ENO
%
%
% Function under test:
%     src/reconstruction/growthExpMatch/growthExpMatch.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation (MILP); ecoli_core_model loaded through getDistributedModel and a toy
%     SUX structure, whose optimum is unique, for the branches that do not need a model.
%
% Coverage exemptions:
%     None besides the defective inputs listed below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A SUX structure without exchange reactions cannot be solved
%       SEVERITY: error
%       TRIGGER: growthExpMatch(MatricesSUX) with no entry equal to 3 in MatricesSUX.MatrixPart
%       OBSERVED: lengthEx is set to 0, but the names of the dummy reactions are taken from
%         startKegg:stopEx, which is empty, so the call stops with Unable to perform assignment
%         because the left and right sides have a different number of elements
%       EXPECTED: the problem is solved with the universal reactions only
%       LINES: 93, 150
%     - DEFECT: An empty objective stops with an undefined variable
%       SEVERITY: error
%       TRIGGER: growthExpMatch(MatricesSUX) with MatricesSUX.c = []
%       OBSERVED: the text No biomass reaction found is printed and the run continues, so it
%         stops with Unrecognized function or variable 'biomass_rxn_loc'
%       EXPECTED: an error that says that no biomass reaction was found
%       LINES: 126, 132
%
% Authors:
%     - Joseph Kang 11/16/09
%     - Adaptions to CI - Thomas Pfau Okt 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

global CBTDIR

oriFolder = pwd;

%moves to testing folder that contains testGrowthExpMatch
test_folder = fileparts(which('testGrowthExpMatch.m'));
cd(test_folder);

% require LP and MILP solvers; skip gracefully if none is available
prepareTest('needsLP', true, 'needsMILP', true);

%load Model
model = getDistributedModel('ecoli_core_model.mat');

%removes reaction ENO
disp('------------------------------------')
disp('Removing reaction, ENO, from test model:')
model = removeRxns(model, 'ENO');

%moves to folder w/ input files
% w = what('testing');
% p = w.path;
% cd(p);
d = load([test_folder filesep 'Dictionary.mat']);
KEGGFilename = 'testTest_KEGG_Reaction_List.lst';

% A toy SUX structure: the model part takes up A (R1) and drains B (BIO) but cannot make B from A;
% the universal reaction K1 (A -> B, cost 1) and the exchange E1 (-> B, cost 2.1) can both close the
% gap, so that the order of the solutions over the iterations is unique.
toySUX = struct();
toySUX.S = sparse([1, 0, -1, 0; 0, -1, 1, 1]);
toySUX.mets = {'A[c]'; 'B[c]'};
toySUX.rxns = {'R1'; 'BIO'; 'K1'; 'E1'};
toySUX.c = [0; 1; 0; 0];
toySUX.lb = zeros(4, 1);
toySUX.ub = [10; 1000; 1000; 1000];
toySUX.MatrixPart = [1; 1; 2; 3];

% the same structure with a model reaction R2 that closes the gap by itself, marked as MatrixPart 4
% like the dummy reactions that growthExpMatch appends
toyGrowingSUX = struct();
toyGrowingSUX.S = sparse([1, 0, -1, -1, 0; 0, -1, 1, 1, 1]);
toyGrowingSUX.mets = toySUX.mets;
toyGrowingSUX.rxns = {'R1'; 'BIO'; 'R2'; 'K1'; 'E1'};
toyGrowingSUX.c = [0; 1; 0; 0; 0];
toyGrowingSUX.lb = zeros(5, 1);
toyGrowingSUX.ub = [10; 1000; 1000; 1000; 1000];
toyGrowingSUX.MatrixPart = [1; 1; 4; 2; 3];

% feasibility tolerance of the solvers, and the default growth threshold of growthExpMatch
tol = 1e-6;
threshold = 0.05;

%Test for the default solvers
solverPkgs = {'gurobi', 'glpk'};

for k = 1:length(solverPkgs)
    fprintf('   Running solveCobraLPCPLEX using %s ... ', solverPkgs{k});

    % change the COBRA solver 
    solverOKLP = changeCobraSolver(solverPkgs{k}, 'LP', 0);
    solverOKMILP = changeCobraSolver(solverPkgs{k}, 'MILP', 0);
    
    if solverOKLP && solverOKMILP
        %runs growthExpMatch and obtains solution
        [solution]=growthExpMatch(model, KEGGFilename,'[c]', 1, d.dictionary);
        
        %if R00658_f is solution result, returns a positive answer, else negative
        assert(isequal(solution.importedRxns, {{'R00658_f'}}))

        % A SUX structure as the only input runs two iterations: first the cheapest reaction, then,
        % as the first solution is cut off, the exchange. The objective is that of the last one.
        toySolution = growthExpMatch(toySUX);
        assert(isequal(toySolution.importedRxns, {{'K1'}; {'E1'}}));
        assert(toySolution.stat == 1);
        assert(abs(toySolution.obj - 2.1) < tol);
        assert(norm(toySUX.S * toySolution.cont) < tol);
        assert(toySolution.cont(2) >= threshold - tol);

        % A problem without a solution stops the iterations: nothing is imported
        toyInfeasibleSUX = toySUX;
        toyInfeasibleSUX.ub(3:4) = 0;
        toySolution = growthExpMatch(toyInfeasibleSUX);
        assert(toySolution.stat ~= 1);
        assert(isempty(toySolution.importedRxns));

        % A model that grows needs nothing imported. The flux through the marked reaction R2 is
        % fixed as its upper bound, so the second iteration stays feasible and within that bound.
        toySolution = growthExpMatch(toyGrowingSUX);
        assert(toySolution.stat == 1);
        assert(abs(toySolution.obj) < tol);
        assert(isempty(toySolution.importedRxns));
        assert(norm(toyGrowingSUX.S * toySolution.cont) < tol);
        assert(toySolution.cont(2) >= threshold - tol);
        assert(abs(toySolution.cont(3) - toySolution.cont(2)) < tol);
    end
end
%perform cleanup 
if exist([test_folder filesep 'GEMLog_solution_1.mat'],'file')
    delete('GEMLog_solution_1.mat')
end
if exist([test_folder filesep 'GEMLog_solution_2.mat'],'file')
    delete('GEMLog_solution_2.mat')
end
if exist([test_folder filesep 'CobraMILPSolver.log'],'file')
    delete('CobraMILPSolver.log')
end
if exist([test_folder filesep 'GEMLog.txt'],'file')
    delete('GEMLog.txt')
end
close all 

cd(oriFolder);

fprintf('Done.\n');

