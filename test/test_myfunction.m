classdef test_myfunction < matlab.unittest.TestCase
    methods(Test)
        function testSimple(testCase)
            % Dummy test for the function myfunction
            result = myfunction(3);  % Call the function defined below
            expected = 9;
            testCase.verifyEqual(result, expected);
        end
    end
end

% The function to be tested
function y = myfunction(x)
    % Simple function that squares the input
    y = x^2;
end
