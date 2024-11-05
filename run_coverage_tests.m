function run_coverage_tests
    % Add MOcov to path
    addpath(genpath('/opt/MOcov'));
    
    try
        % Run tests directly
        disp('Running tests...');
        test_results = test_myfunction;
        
        % Generate coverage report
        disp('Generating coverage report...');
        mocov('-cover', pwd, '-cover_xml_file', 'coverage.xml');
        
        disp('Testing completed successfully.');
        exit(0);
    catch e
        disp('Error running tests:');
        disp(getReport(e));
        exit(1);
    end
end
