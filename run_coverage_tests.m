function run_coverage_tests()
    % Add MOcov to path
    addpath(genpath('/opt/MOcov'));
    
    try
        % Run tests and capture results
        disp('Running tests with coverage...');
        
        % Run tests directly first to capture results
        results = runtests('test/test_myfunction.m');
        passed = all([results.Passed]);
        
        % Now run MOcov with a simpler expression that just runs the tests
        test_expression = 'runtests(''test/test_myfunction.m'')';
        
        % Run MOcov for coverage analysis
        mocov('-cover', '.', ...
              '-cover_xml_file', 'coverage.xml', ...
              '-expression', test_expression);
        
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
