function initTest(pathToTest)
% initTest function initializes global paths of the
% solvers and changes the directory to the respective test folder

global path_GUROBI
global path_ILOG_CPLEX
global path_TOMLAB

% define the solver paths
path_GUROBI = '/opt/gurobi650';
path_ILOG_CPLEX = '/opt/ibm/ILOG/CPLEX_Studio127';
path_TOMLAB = '/opt/tomlab';

if length(pathToTest) > 0
    cd(pathToTest);
end

end
