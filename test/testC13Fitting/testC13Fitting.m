function x = testC13Fitting()
%testC13Fitting tests the basic functionality of
%fitC13Data
%   Jan Schellenberger

oriFolder = pwd; % save working directory

test_folder = what('testC13Fitting');
cd(test_folder.path);

majorIterationLimit = 30; % fitting length
load('model.mat', 'model'); % loads modelWT
load('expdata.mat', 'expdata'); % load data
load('point.mat', 'v0'); % load initial point

generateIsotopomerSolver(model, 'xglcDe', expdata, 'true');
expdata.inputfrag = convertCarbonInput(expdata.input); % generate inputFragments (required for EMU solver)

output = scoreC13Fit(v0,expdata,model);

initial_score = output.error;


display('the fluxomics toolbox requires a Non Linear Programming (NLP) solver.  Currently the only supported solver is Tomlab/SNOPT.  This test will not complete if this solver is not installed');
% matlabpool local 3 % starts 3 local workers.  This task can be
% parallelized.  See Parallel toolbox for description
[vout, rout] = fitC13Data(v0,expdata,model, majorIterationLimit);
% matlabpool close % end parallel task.


output = scoreC13Fit(vout,expdata,model);
final_score = output.error;

if final_score < initial_score
    x = 1;
else
    x = 0;
end

cd(oriFolder); % restore working directory

return;
