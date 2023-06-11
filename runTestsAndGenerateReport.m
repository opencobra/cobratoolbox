import mlreportgen.report.*
import mlreportgen.dom.*

% Create a Report object and set its output format to PDF
rpt = Report('test_results', 'pdf');

% Add content to the report
append(rpt, TitlePage('Title', 'Test Results'));

% Run your tests and append the results to the report
testResults = runtests('./test/testAll_ghActions.m');
append(rpt, testResults);

% Close the report (this generates the PDF file)
close(rpt);
