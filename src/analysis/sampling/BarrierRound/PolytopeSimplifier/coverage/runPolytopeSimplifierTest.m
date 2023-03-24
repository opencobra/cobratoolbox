import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.TestReportPlugin
import matlab.unittest.parameters.Parameter

% data
loadModular('Problem');
param = Parameter.fromData('problemName', loadProblemAsStruct({'LPnetlib*'}), 'costFactor', {1}, 'flopBound', {1e7});

% problem
suite = TestSuite.fromFile('coverage/PolytopeSimplifierTest.m', 'ExternalParameters', param);

runner = TestRunner.withTextOutput;
runner.addPlugin(TestReportPlugin.producingHTML('coverage/TestReport', 'LoggingLevel', 2, 'IncludingCommandWindowText', true))
result = runner.runInParallel(suite);
%result = runner.run(suite);
