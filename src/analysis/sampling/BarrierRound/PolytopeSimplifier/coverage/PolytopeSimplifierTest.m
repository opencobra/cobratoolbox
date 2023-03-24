classdef PolytopeSimplifierTest < matlab.unittest.TestCase
   properties(TestParameter)
      problemName = struct('none', struct('name', 'none'));
      costFactor = {1};
      flopBound = {1e5};
   end
   
   methods(TestMethodSetup)
      function include_folder(testCase)
         addpath('..');
      end
   end
   
   methods (Test)
      function findInterior(testCase, problemName, costFactor, flopBound)
         % load problem
         disp(problemName)
         problem = loadProblem(problemName);
         A = sparse(problem.Aeq); b = problem.beq; c = problem.c; lb = problem.lb; ub = problem.ub;
         lb = max(lb, -1e7);
         ub = min(ub, 1e7);
         
         testCase.assumeTrue(problem.flop < flopBound && isempty(problem.Aineq))
         
         % compute an analytic center
         f = ConvexProgram.LinearProgram(A, b, costFactor * c, lb, ub);
         
         [x, info] = f.findInterior();
         o = '';
         o = [o,  sprintf('size(A) = (%i,%i) (before)\n', size(A,1), size(A,2))];
         o = [o,  sprintf('size(A) = (%i,%i) (new)\n', size(f.A,1), size(f.A,2))];
         if getField(problem, 'feasible', true)
            % check the solution
            z = f.export(x);
            feasibility = double(max(abs(A*z-b)));
            if isempty(feasibility), feasibility = 0; end
            testCase.verifyTrue(all(z >= lb & z <= ub))
            testCase.verifyLessThan(feasibility, 1e-7);
            
            % log the result
            o = [o,  sprintf('Centrality = %e\n', double(info.centrality))];
            o = [o,  sprintf('Feasibility = %e\n', double(info.feasibility))];
            o = [o,  sprintf('||x||_inf = %e\n', double(max(abs(x))))];
         else
            testCase.verifyTrue(isscalar(x) && isnan(x));
            
            o = [o,  'Problem is infeasible\n'];
         end
         o = [o,  sprintf('Iter = %i\n', info.iter)];
         
         log(testCase, o);
         
         if (info.iter > 40)
            fprintf('Takes %i iterations\n', info.iter);
         end
      end
      
      function normalize(testCase, problemName, costFactor, flopBound)
         % load problem
         disp(problemName)
         problem = loadProblem(problemName);
         A = sparse(problem.Aeq); b = problem.beq; c = problem.c; lb = problem.lb; ub = problem.ub;
         lb = max(lb, -1e7);
         ub = min(ub, 1e7);
         
         testCase.assumeTrue(problem.flop < flopBound && isempty(problem.Aineq) && getField(problem, 'feasible', true))
         
         % compute an analytic center
         f = ConvexProgram.LinearProgram(A, b, costFactor * c, lb, ub);
         
         [x, info] = f.normalize();
         
         % check the solution
         z = f.export(x);
         feasibility = double(max(abs(A*z-b)));
         if isempty(feasibility), feasibility = 0; end
         testCase.verifyTrue(all(z >= lb & z <= ub))
         testCase.verifyLessThan(feasibility, 1e-7);
         
         % log the result
         o = '';
         o = [o,  sprintf('size(A) = (%i,%i) (before)\n', size(A,1), size(A,2))];
         o = [o,  sprintf('size(A) = (%i,%i) (new)\n', size(f.A,1), size(f.A,2))];
         o = [o,  sprintf('Centrality = %e\n', double(info.centrality))];
         o = [o,  sprintf('Feasibility = %e\n', double(info.feasibility))];
         o = [o,  sprintf('||x||_inf = %e\n', double(max(abs(x))))];
         
         o = [o,  sprintf('Iter = %i\n', info.iter)];
         
         log(testCase, o);
         
         if (info.iter > 40)
            fprintf('Takes %i iterations\n', info.iter);
         end
      end
   end
end