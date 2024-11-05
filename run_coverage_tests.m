function run_coverage_tests
    % Add MOcov to path
    addpath(genpath('/opt/MOcov'));
    
    % Get the current directory
    current_dir = pwd;
    
    try
        % Import necessary components
        import matlab.unittest.TestRunner;
        import matlab.unittest.TestSuite;
        import matlab.unittest.plugins.TestReportPlugin;
        import matlab.unittest.plugins.CodeCoveragePlugin;
        
        % Create test suite from the test file
        suite = TestSuite.fromFile('tests/test_myfunction.m');
        
        % Create a runner
        runner = TestRunner.withTextOutput('Verbosity', 3);
        
        % Add the coverage plugin
        coveragePlugin = CodeCoveragePlugin.forFolder(current_dir, ...
            'IncludingSubfolders', true, ...
            'Producing', matlab.unittest.plugins.codecoverage.CoverageReport('coverage'));
        runner.addPlugin(coveragePlugin);
        
        % Run the tests
        results = runner.run(suite);
        
        % Display summary
        disp('Test Summary:');
        disp(['Number of tests: ' num2str(numel(results))]);
        disp(['Passed: ' num2str(nnz([results.Passed]))]);
        disp(['Failed: ' num2str(nnz([results.Failed]))]);
        disp(['Duration: ' num2str(sum([results.Duration])) ' seconds']);
        
        % Generate MOcov coverage report
        mocov('-cover', current_dir, '-cover_xml_file', 'coverage.xml');
        
        % Check if any tests failed
        if any([results.Failed])
            error('Some tests failed. Check the test report for details.');
        end
        
        % Exit with success
        exit(0);
    catch e
        % Display error and exit with failure
        disp('Error running tests:');
        disp(getReport(e));
        exit(1);
    end
end
