classdef test_myfunction < matlab.unittest.TestCase
    % Test class for myfunction
    % This test suite demonstrates various aspects of the function's behavior
    
    properties
        % Define any test properties here
        TestPrecision = 1e-10;
    end
    
    methods (Test)
        function testPositiveInteger(testCase)
            % Test with a positive integer
            result = myfunction(3);
            expected = 9;
            testCase.verifyEqual(result, expected, ...
                'Failed to square positive integer correctly')
        end
        
        function testNegativeInteger(testCase)
            % Test with a negative integer
            result = myfunction(-4);
            expected = 16;
            testCase.verifyEqual(result, expected, ...
                'Failed to square negative integer correctly')
        end
        
        function testZero(testCase)
            % Test with zero
            result = myfunction(0);
            expected = 0;
            testCase.verifyEqual(result, expected, ...
                'Failed to handle zero input correctly')
        end
        
        function testDecimal(testCase)
            % Test with decimal number
            result = myfunction(1.5);
            expected = 2.25;
            testCase.verifyEqual(result, expected, ...
                'AbsTol', testCase.TestPrecision, ...
                'Failed to square decimal number correctly')
        end
        
        function testLargeNumber(testCase)
            % Test with a large number
            result = myfunction(1e3);
            expected = 1e6;
            testCase.verifyEqual(result, expected, ...
                'Failed to handle large numbers correctly')
        end
    end
    
    methods (TestClassSetup)
        function setupPath(testCase)
            % Add the directory containing myfunction to the path
            currentDir = fileparts(mfilename('fullpath'));
            addpath(currentDir);
        end
    end
end

% The function to be tested
function y = myfunction(x)
    % MYFUNCTION Squares the input value
    %   y = MYFUNCTION(x) returns the square of x
    %
    % Inputs:
    %   x - A numeric value
    %
    % Outputs:
    %   y - The square of the input value
    %
    % Example:
    %   y = myfunction(3)
    %   y = 9
    
    y = x^2;
end
