function run_coverage_tests
    % Add MOcov to path
    addpath(genpath('/opt/MOcov'));
    
    % Get the current directory
    current_dir = pwd;
    
    try
        % Create test suite from the test file
        suite = matlab.unittest.TestSuite.fromFile('test/test_myfunction.m');
        
        % Create a runner with detailed output
        runner = matlab.unittest.TestRunner.withTextOutput('Verbosity', 3);
        
        % Run the tests
        results = runner.run(suite);
        
        % Display summary
        disp('==========================================');
        disp('Test Summary:');
        disp('==========================================');
        disp(['Number of tests: ' num2str(numel(results))]);
        disp(['Passed: ' num2str(nnz([results.Passed]))]);
        disp(['Failed: ' num2str(nnz([results.Failed]))]);
        disp(['Duration: ' num2str(sum([results.Duration])) ' seconds']);
        disp('==========================================');
        
        % Generate MOcov coverage report
        disp('Generating coverage report...');
        mocov('-cover', current_dir, '-cover_xml_file', 'coverage.xml');
        
        % Check if any tests failed
        if any([results.Failed])
            error('Some tests failed. Check the test report for details.');
        end
        
        disp('Testing completed successfully.');
        exit(0);
    catch e
        % Display error and exit with failure
        disp('Error running tests:');
        disp(getReport(e));
        exit(1);
    end
end
