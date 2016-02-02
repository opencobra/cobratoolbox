function x = testAll()
%testAll calls upon all tests in the subfolders of testing
%   returns "X of Y tests completed successfully"
%   X = #tests passed
%   Y = #tests completed
%   Make sure that each test returns a 1 if passed, 0 otherwise.
%
%
% Joseph Kang 04/16/09
tests_completed = 0;
tests_passed = 0;
oriDir = pwd;

mFilePath = mfilename('fullpath');
test_path = (mFilePath(1:end-length(mfilename)));
test_directory = dir(test_path);
f = filesep;

%make sure the solvers are the predefined ones for each test as if a test
%fails it can fail to switch back the solver
global CBTLPSOLVER;
CBTLPSOLVERx=CBTLPSOLVER;
global CBT_MILP_SOLVER;
CBT_MILP_SOLVERx=CBT_MILP_SOLVER;
global CBT_QP_SOLVER;
CBT_QP_SOLVERx=CBT_QP_SOLVER;
global CBT_MIQP_SOLVER;
CBT_MIQP_SOLVERx=CBT_MIQP_SOLVER;
global CBT_NLP_SOLVER;
CBT_NLP_SOLVERx=CBT_NLP_SOLVER;

listPassed = {};
listNotPassed = {};
passedCnt = 0;
notPassedCnt = 0;
%search through the test folders in testing and run the test inside
for i=1:size(dir(test_path))
    test_folder = strcat(test_path, test_directory(i).name, f);
    if(isdir(test_folder) && (strcmp(test_directory(i).name,'.')==0) && (strcmp(test_directory(i).name,'..')==0))
        test_folder_directory = what(test_folder);
        
        %stores all the functions in the test folder in folder_functions
        folder_functions = test_folder_directory.m;
        
        %runs the functions in test_folder
        for j = 1: size(folder_functions)
              cd(test_folder);
              func =folder_functions{j};
              %parse func so that it doesn't include '.m' (stores in p)
              p = strtok(func, '.');
              
              try
                 pass = eval(p);
                 if pass==1||iscellstr(pass)||iscell(pass)
                     fprintf('%s successfully passed\n',p);
                     pass=1;
                     passedCnt = passedCnt +1;
                     listPassed{passedCnt} = p;
                 elseif pass==0
                      fprintf('Error in %s\n', p);
                      pass = 0;
                      notPassedCnt = notPassedCnt +1;
                      listNotPassed{notPassedCnt} = p;                     
                 end                 
              catch
                  fprintf('Error in %s\n', p);
                  pass = 0;
                  notPassedCnt = notPassedCnt +1;
                  listNotPassed{notPassedCnt} = p;
              end
%               try
                  
%               if(pass == 0)
%                     fprintf('%s did not pass\n',p);
%                     notPassedCnt = notPassedCnt +1;
%                     listNotPassed{notPassedCnt} = p;
%               else
%                   
%                     passedCnt = passedCnt +1;
%                     listPassed{passedCnt} = p;
%               end
%               catch
%                   disp('good')
%               end
              
             %if test was passed, would increment tests_passed
             %test_completed is incremented every iteration

             tests_passed = tests_passed + pass;

             tests_completed = tests_completed + 1;
             
             %change back the solvers after each test
             if ~isempty(CBTLPSOLVERx)
                changeCobraSolver(CBTLPSOLVERx,'LP');
             end
             if ~isempty(CBT_MILP_SOLVERx)
                changeCobraSolver(CBT_MILP_SOLVERx,'MILP');
             end
             if ~isempty(CBT_QP_SOLVERx)
                changeCobraSolver(CBT_QP_SOLVERx,'QP');
             end
             if ~isempty(CBT_MIQP_SOLVERx)
                changeCobraSolver(CBT_MIQP_SOLVERx,'MIQP');
             end
             if ~isempty(CBT_NLP_SOLVERx)
                changeCobraSolver(CBT_NLP_SOLVERx,'NLP');
             end             
        end
    end
end
disp('Tests passed: ');
for b = 1: size(listPassed,2)
    disp(listPassed{b});
end
fprintf('\n\n');
disp('Tests not passed: ');
for c = 1: size(listNotPassed,2)
    disp(listNotPassed{c});
end

x = [num2str(tests_passed), ' of ', num2str(tests_completed), ' tests completed successfully.'];
if(tests_passed ~= tests_completed)
    display('IT IS NOT NECESSARY FOR THE COBRA TOOLBOX TO PASS ALL TESTS TO FUNCTION; HOWEVER, IT MUST PASS THE TESTS THAT ARE RELEVANT TO YOUR PARTICULAR PROBLEM!!!');
    display('Tests may not pass for several reasons.  Some of the most common issues:');
    display('1.  The correct solver is not installed.  Certain tests require LP, MILP, QP or NLP solvers.  See changeCobraSolvers.m for a complete list of supported solvers.');
    display('These tests will fail when running testAll unless one has the tomlab suite installed.  If all of the functions that you require for your use function then do not worry about them: testC13Fitting, testGDLS, testMOMA, testOptKnock, testSolvers');
    %Removed because this line confuses people into believing there is a problem
    %display('2.  The SBMLtoolbox and libSBML libraries are not installed correctly.  This will affect reading/writing of models.');
    display('If a particular test fails, you can run that test individually for more information');
end
%return to original directory
cd(oriDir);

end
