function configEnvVars(printLevel)

    global GUROBI_PATH;
    global ILOG_CPLEX_PATH;
    global TOMLAB_PATH;
    global MOSEK_PATH;
    global ENV_VARS;

    if nargin < 1
        printLevel = 0;
    end

    if ENV_VARS.STATUS == 0
        solverPaths = {};
        solverPaths{1,1} = 'ILOG_CPLEX_PATH';
        solverPaths{1,2} = {'/Applications/IBM/ILOG/CPLEX_Studio1262', '/Applications/IBM/ILOG/CPLEX_Studio1263', '/Applications/IBM/ILOG/CPLEX_Studio127', ...
                            '/opt/ibm/ILOG/CPLEX_Studio1262', '/opt/ibm/ILOG/CPLEX_Studio1263', '/opt/ibm/ILOG/CPLEX_Studio127', ...
                            'C:\Program Files\IBM\ILOG\CPLEX_Studio1262', 'C:\Program Files\IBM\ILOG\CPLEX_Studio1263', 'C:\Program Files\IBM\ILOG\CPLEX_Studio127'};
        solverPaths{2,1} = 'GUROBI_PATH';
        solverPaths{2,2} = {'/Library/gurobi600', '/Library/gurobi650', '/Library/gurobi702', '/opt/gurobi650', '/opt/gurobi70', 'C:\gurobi600', 'C:\gurobi650', 'C:\gurobi70'};
        solverPaths{3,1} = 'TOMLAB_PATH';
        solverPaths{3,2} = {'/opt/tomlab', 'C:\tomlab', '/Applications/tomlab'};
        solverPaths{4,1} = 'MOSEK_PATH';
        solverPaths{4,2} = {'/opt/mosek/7/', '/opt/mosek/8/', '/Applications/mosek/7', '/Applications/mosek/8', 'C:\Program Files\Mosek\7', 'C:\Program Files\Mosek\8'};

        for k = 1:length(solverPaths)
            eval([solverPaths{k, 1}, ' = getenv(''', solverPaths{k, 1} , ''');'])
            possibleDir = '';
            if isempty(eval(solverPaths{k, 1}))
                tmpSolverPath = solverPaths{k, 2};
                for i = 1:length(solverPaths{k, 2})
                    if exist(tmpSolverPath{i}, 'dir') == 7
                        possibleDir = tmpSolverPath{i};
                    end;
                end
                if ~isempty(possibleDir)
                    setenv(solverPaths{k, 1}, strrep(possibleDir, '\', '\\'));
                    eval([solverPaths{k, 1}, ' = getenv(''', solverPaths{k, 1}, ''');']);
                else
                    if printLevel > 0
                        fprintf(['   - ', solverPaths{k, 1}, ':  --> set this path manually after installing the solver\n' ]);
                    end
                end
            end

            % add the solver path
            if ~isempty(eval(solverPaths{k, 1}))
                addpath(genpath(eval(solverPaths{k, 1})));
                if printLevel > 0
                    fprintf(['   - ', solverPaths{k, 1}, ': ', eval(['getenv(''', solverPaths{k, 1} , ''');']) , '\n']);
                end
                ENV_VARS.STATUS = 1;
            end
        end
    end
end
