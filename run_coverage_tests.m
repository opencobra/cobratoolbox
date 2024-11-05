function run_coverage_tests()
    % Add MOcov to path
    addpath(genpath('/opt/MOcov'));
    
    try
        % Run tests and capture results
        disp('Running tests with coverage...');
        
        % Create the expression to run tests with proper variable assignment
        test_expression = ['results = runtests(''test/test_myfunction.m'');', ...
                          'passed = all([results.Passed]);'];
        
        % Run MOcov with the test expression
        mocov('-cover', '.', ...  % Use '.' instead of pwd for current directory
              '-cover_xml_file', 'coverage.xml', ...
              '-expression', test_expression);
        
        % Load results from workspace
        results = evalin('base', 'results');
        passed = evalin('base', 'passed');
        
        % Check results
        if ~passed
            error('Some tests failed. Check the test results for details.');
        end
        
        disp('All tests passed successfully!');
        disp(['Number of passed tests: ' num2str(sum([results.Passed]))]);
        
        exit(0);
    catch e
        disp('Error running tests:');
        disp(getReport(e));
        exit(1);
    end
end
