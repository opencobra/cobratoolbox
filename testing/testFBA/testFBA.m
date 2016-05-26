function x = testFBA()
%testFBA tests the basic functionality of FBA
%   Tests four basic solution: Optimal minimum 1-norm solution, Optimal
%   solution on fructose, Optimal anaerobic solution, Optimal ethanol
%   secretion rate solution
%   returns 1 if all tests were completed succesfully, 0 if not
%
%   Joseph Kang 04/27/09

oriFolder = pwd;

test_folder = what('testFBA');
cd(test_folder.path);

%tolerance
tol = 0.00000001;

load('testFBAData.mat');
fprintf('\n*** Test basic FBA calculations ***\n\n');
fprintf('\n** Optimal solution\n');


% printFluxVector(test_model, solution1.x, true, true);
% printFluxVector(model, solution.x, true, true);




fprintf('\n** Optimal minimum 1-norm solution **\n');
model = changeObjective(model,{'BiomassEcoli'},1);
solution = optimizeCbModel(model);
f_values = solution.f;

%testing if f values are within range
x = 1;
for i =1:size(f_values)
    if(abs(solution.f-solutionStd.f)>tol)
        x=0;
    end
end
if(x==0)
    disp('Test failed for Optimal minimum 1-norm solution for f values');
else
    disp('Test succeeded for Optimal minimum 1-norm solution for f values');
end

%testing if c*x == f
y = 1;
for i =1:size(f_values)
    if abs(model.c'*solution.x - solution.f)>tol
        y=0;
    end
end
if(y==0)
    disp('Test failed for Optimal minimum 1-norm solution for c*x values');
else
    disp('Test succeeded for Optimal minimum 1-norm solution for c*x values');
end

%printFluxVector(model, [solution.x solution2.x], true, false);




fprintf('\n** Optimal solution on fructose **\n');
model2 = changeRxnBounds(model, {'EX_glc(e)','EX_fru(e)'}, [0 -9], 'l');
solution2 = optimizeCbModel(model2);
f_values = solution.f;


x = 1;
for i =1:size(f_values)
    if(abs(solution2.f-solution2Std.f)>tol)
        x=0;
    end
end
if(x==0)
    disp('Test failed for Optimal solution on Fructose for f values');
else
    disp('Test succeeded for Optimal solution on Fructose for f values');
end

%testing if c*x == f
y = 1;
for i =1:size(f_values)
    if abs(model2.c'*solution2.x - solution2.f)>tol
        y=0;
    end
end
if(y==0)
    disp('Test failed for Optimal solution on Fructose for c*x values');
else
    disp('Test succeeded for Optimal solution on Fructose for c*x values');
end

%printFluxVector(model2, solution.x, true, true);




fprintf('\n** Optimal anaerobic solution **\n');
model3 = changeRxnBounds(model, 'EX_o2(e)', 0, 'l');
solution3 = optimizeCbModel(model3);
f_values = solution.f;

x = 1;
for i =1:size(f_values)
    if(abs(solution3.f-solution3Std.f)>tol)
        x=0;
    end
end
if(x==0)
    disp('Test failed for Optimal anaerobic solution for f values');
else
    disp('Test succeeded for Optimal anaerobic solution for f values');
end

%testing if c*x == f
y = 1;
for i =1:size(f_values)
    if abs(model3.c'*solution3.x - solution3.f)>tol
        y=0;
    end
end
if(y==0)
    disp('Test failed for Optimal anaerobic solution for c*x values');
else
    disp('Test succeeded for Optimal anaerobic solution for c*x values');
end


fprintf('\n** Optimal ethanol secretion rate solution **\n');
model4 = changeObjective(model, 'EX_etoh(e)',1);
solution4 = optimizeCbModel(model4);
f_values = solution.f;

x = 1;
for i =1:size(f_values)
    if(abs(solution4.f-solution4Std.f)>tol)
        x=0;
    end
end
if(x==0)
    disp('Test failed for Optimal ethanol secretion rate solution for f values');
else
    disp('Test succeeded for Optimal ethanol secretion rate solution for f values');
end

%testing if c*x == f
y = 1;
for i =1:size(f_values)
    if abs(model4.c'*solution4.x - solution4.f)>tol
        y=0;
    end
end
if(y==0)
    disp('Test failed for Optimal ethanol secretion rate solution for c*x values');
else
    disp('Test succeeded for Optimal ethanol secretion rate solution for c*x values');
end

cd(oriFolder);

end

