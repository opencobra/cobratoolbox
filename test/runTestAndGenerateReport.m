% Create a test suite from your test file
suite = matlab.unittest.TestSuite.fromFile('./test/testAll_ghActions.m');

% Create a test runner with detailed text output
runner = matlab.unittest.TestRunner.withTextOutput('OutputDetail', matlab.unittest.Verbosity.Detailed);

% Create a CodeCoveragePlugin instance
coverageFolder = fullfile(pwd, 'coverage');
if ~exist(coverageFolder, 'dir')
    mkdir(coverageFolder);
end
coverageFile = fullfile(coverageFolder, 'coverage.xml');

% Create code coverage plugin in Cobertura format
coverageFormat = matlab.unittest.plugins.codecoverage.CoberturaFormat(coverageFile);
coveragePlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder(pwd, 'Producing', coverageFormat, 'IncludingSubfolders', true);

% Add the coverage plugin to the runner
runner.addPlugin(coveragePlugin);

% Open a file for writing test results
fid = fopen('test_results.txt', 'w');

% Create a diagnostics plugin to write test results to file
import matlab.unittest.plugins.ToFile;
diagnosticsPlugin = matlab.unittest.plugins.DiagnosticsRecordingPlugin(ToFile('test_results.txt'));

% Add the diagnostics plugin to the runner
runner.addPlugin(diagnosticsPlugin);

% Run the tests
results = runner.run(suite);

% Write the test results summary to the file
for i = 1:length(results)
    fprintf(fid, 'Test: %s, Result: %s\n', results(i).Name, string(results(i).Passed));
end

% Close the file
fclose(fid);
