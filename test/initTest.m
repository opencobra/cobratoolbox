function initTest(pathToTest)
% initTest function initializes global paths of the
% solvers and changes the directory to the respective test folder

global GUROBI_PATH
global ILOG_CPLEX_PATH
global TOMLAB_PATH

% define the solver paths
GUROBI_PATH = '/opt/gurobi650';
ILOG_CPLEX_PATH = '/opt/ibm/ILOG/CPLEX_Studio127';
TOMLAB_PATH = '/opt/tomlab';

if length(pathToTest) > 0
    cd(pathToTest);
end

end
