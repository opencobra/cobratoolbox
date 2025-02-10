function [outputArg1,outputArg2] = test()
%
% The COBRAToolbox; test.m
% 
% Purpose:
%   to check TrimGdel appropriately works for all target metabolites in e_coli_core. 
%
% Feb. 10, 2025  Takeyuki TAMURA

initCobraToolbox;
solvers = prepareTest('needsLP', true, 'needsMILP', true, 'useSolversIFAvailable', {'gurobi'});

try
assert(strcmp(solvers.LP, 'gurobi'))
catch
    display('The MILP solver mulst be gurobi in this version.')
    display('The CPLEX version is available on https://github.com/MetNetComp/TrimGdel')
    return;
end
try
assert(strcmp(solvers.MILP, 'gurobi'))
catch
    display('The MILP solver mulst be gurobi in this version.')
    display('The CPLEX version is available on https://github.com/MetNetComp/TrimGdel')
    return;
end



load('e_coli_core.mat');
model = e_coli_core;


m = size(model.mets, 1);
for i=1:m
    [gvalue, GR, PR, size1, size2, size3, success] = TrimGdel(model, model.mets{i} ,3, 0.1, 0.1);
    if success == 1
        try
            assert(GR >= 0.001);
        catch
            display('The GR value is not appropriate.')
            return;
        end
         try
            assert(PR >= 0.001);
        catch
            display('The PR value is not appropriate.')
            return;
         end
         table(i, 1) = success;
         table(i, 2) = GR;
         table(i, 3) = PR;
         table(i, 4) = size1;
         table(i, 5) = size2;
         table(i, 6) = size3;

    end
end
try 
    assert(sum(table(:,1)) > 30)
catch
     display('It seems that TrimGdel cannot perform optimally in this environment.')
     return;
end

display('The test was successful.')

end

