classdef testJSON < matlab.unittest.TestCase
    % Tests the JSON parser
    
    methods (Test)
        
        function testStatesData(testCase)
            
            f = urlread(['file:///' which('data01.json')]);
            states = JSON.parse(f);
            
            actSolution = states{1}.name;
            expSolution = 'Alabama';
            testCase.verifyEqual(actSolution,expSolution);
            
            actSolution = states{4}.name;
            expSolution = 'Missouri';
            testCase.verifyEqual(actSolution,expSolution);
            
        end
        
        
        function testCompanyData(testCase)
            
            f = urlread(['file:///' which('data02.json')]);
            comp = JSON.parse(f);
            
            actSolution = comp.result{3}.city;
            expSolution = 'Beaumont';
            testCase.verifyEqual(actSolution,expSolution);
            
        end
        
        function testTrendyData(testCase)
            
            f = urlread(['file:///' which('data03.json')]);
            vals = JSON.parse(f);
            
            t = zeros(size(vals));
            d = zeros(size(vals));
            
            for i = 1:length(vals)
                t(i) = vals{i}{1};
                d(i) = str2num(vals{i}{2}{1});
            end
            
            actSolution = d(1);
            expSolution = 62198;
            testCase.verifyEqual(actSolution,expSolution);
            
        end
        
        function testTrendyDataWithNull(testCase)
            
            f = urlread(['file:///' which('data04.json')]);
            vals = JSON.parse(f);
            
            actSolution = datestr(vals{3}{1},1);
            expSolution = '20-May-2013';
            testCase.verifyEqual(actSolution,expSolution);
            
            % Line 3 has a NULL value.
            % I expect the JSON parser to return [] for vals{3}{2}
            actSolution = vals{3}{2};
            expSolution = [];
            testCase.verifyEqual(actSolution,expSolution);
            
        end
        
        function testScientificNotation(testCase)
            
            f = urlread(['file:///' which('data05.json')]);
            vals = JSON.parse(f);
            
            actSolution = str2num(vals{1}.velocity);
            expSolution = -957170;
            testCase.verifyEqual(actSolution,expSolution);
            
        end
        
        function testAsciiNumbers(testCase)
            % robust to ascii values or strings that match control
            % characters:  []{}:,
            f = urlread(['file:///' which('data06.json')]);
            vals = JSON.parse(f);
        end
        
        function testForFieldsThatStartWithNumbers(testCase)
            % robust to ascii values or strings that match control
            % characters:  []{}:,
            f = urlread(['file:///' which('data07.json')]);
            vals = JSON.parse(f);
            actSolution = vals.s2StartsWithNumber;
            expSolution = '3ValueWithNumber';
            testCase.verifyEqual(actSolution,expSolution);
        end
        
    end
    
end