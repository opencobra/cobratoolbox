% Run the CMatrixTest suite with text output and code-coverage reporting
% for the ddouble and AdaptiveChol sources
import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.TestReportPlugin

clc;
suite = TestSuite.fromFile('coverage/CMatrixTest.m');
runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forFile({'include/ddouble.m', 'include/AdaptiveChol.m'}))
result = runner.run(suite);

