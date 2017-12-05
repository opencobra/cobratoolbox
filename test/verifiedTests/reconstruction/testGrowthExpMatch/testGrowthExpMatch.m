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
%   Joseph Kang 11/16/09
%   Adaptions to CI - Thomas Pfau Okt 2017

global CBTDIR

oriFolder = pwd;

%moves to testing folder that contains testGrowthExpMatch
test_folder = fileparts(which('testGrowthExpMatch.m'));
cd(test_folder);

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
    end
end
%perform cleanup 
if exist([test_folder filesep 'GEMLog_solution_1.mat'],'file')
    delete('GEMLog_solution_1.mat')
end
if exist([test_folder filesep 'CobraMILPSolver.log'],'file')
    delete('CobraMILPSolver.log')
end
if exist([test_folder filesep 'GEMLog.txt'],'file')
    delete('GEMLog.txt')
end
close all 

cd(oriFolder);

