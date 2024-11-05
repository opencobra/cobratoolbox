% Run your tests
% testResults = runtests('./test/testAll_ghActions.m');
testResults = runtests('./test/testAll.m');
% Open a file for writing
fid = fopen('test_results.txt', 'w');

% Write the test results to the file
for i = 1:length(testResults)
    fprintf(fid, 'Test: %s, Result: %s\n', testResults(i).Name, string(testResults(i).Passed));
end

% Close the file
fclose(fid);
