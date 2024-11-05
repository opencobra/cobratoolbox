function run_coverage_tests
    % Add MOcov to path
    addpath(genpath('/opt/MOcov'));
    
    % Get the current directory
    current_dir = pwd;
    
    try
        % Configure MOcov
        cover_method = '-cover';
        covered_dir = current_dir;
        report_file = fullfile(current_dir, 'coverage.xml');
        
        % Run tests and generate coverage
        test_suite = testsuite('tests/test_myfunction.m');
        results = run(test_suite);
        
        % Check if all tests passed
        num_failed = nnz([results.Failed]);
        if num_failed > 0
            error('Some tests failed');
        end
        
        % Generate coverage report
        mocov(cover_method, covered_dir, '-cover_xml_file', report_file);
        
        % Exit with success
        exit(0);
    catch e
        % Display error and exit with failure
        disp('Error running tests:');
        disp(getReport(e));
        exit(1);
    end
end
