function x = testSBML()
%testSBML checks if readCbModel and writeCbModel is working
%   reads all the sbml files in this folder
%   checks if all the parameters are correctly written
%   returns 1 for correct, else 0
%
%   Joseph Kang 04/07/09

oriFolder = pwd;

%Testing readCbModel
%
find = what('testSBML');
test_directory = find.path;
cd(test_directory);

testModel = readCbModel('Ec_iJR904.xml');
load('Ec_iJR904.mat', 'model');
x=1;


        if(size(model.rxns) ~= size(testModel.rxns))
              disp('Incorrect rxns size');
              x=0;
        end
        if(size(model.mets) ~= size(testModel.mets)) 
              disp('Incorrect mets size');
              x=0;
        end
        if(size(model.S) ~= size(testModel.S)) 
              disp('Incorrect S size');
              x=0;
        end
        if(size(model.rev)~= size(testModel.rev)) 
            disp('Incorrect rev size');
              x=0;
        end
        if(size(model.lb) ~= size(testModel.lb))
            disp('Incorrect lb size');
              x=0;
        end
        if(size(model.ub)~= size(testModel.ub)) 
            disp('Incorrect ub size');
              x=0;
        end
        if(size(model.c)~= size(testModel.c)) 
            disp('Incorrect c size');
              x=0;
        end
        if(size(model.rules)~= size(testModel.rules))
            disp('Incorrect rules size');
              x=0;
        end
        if(size(model.genes)~= size(testModel.genes)) 
            disp('Incorrect genes size');
              x=0;
        end
        if(size(model.rxnGeneMat) ~= size(testModel.rxnGeneMat))
            disp('Incorrect rxnGeneMat size');
              x=0;
        end
        if(size(model.grRules)~= size(testModel.grRules))
            disp('Incorrect grRules size');
              x=0;
        end
        if(size(model.subSystems) ~= size(testModel.subSystems))
            disp('Incorrect subSystems size');
              x=0;
        end
        if(size(model.rxnNames) ~= size(testModel.rxnNames))
            disp('Incorrect rxnNames size');
              x=0;
        end
        if(size(model.metNames) ~= size(testModel.metNames))
            disp('Incorrect metNames size');
              x=0;
        end
        if(size(model.metFormulas) ~= size(testModel.metFormulas))
            disp('Incorrect metFormulas size');
              x=0;
        end
        if(size(model.b) ~= size(testModel.b))
            disp('Incorrect b size');
              x=0;
        end
        if(x==1)
            disp('Test for readCbModel succeeded');
        end

%test writeCbModel
%
writeCbModel( testModel, 'sbml', 'test_model.sbml');
test_model = readCbModel('test_model.sbml');
%testModel = alphabetizeModel(testModel);
%test_model = alphabetizeModel(test_model);
[isSame numDiff fieldNames] = isSameCobraModel(testModel,test_model);

if any(numDiff)
  fprintf('\nTest for writeCbModel in sbml failed\n');
  x = 0;
else
    fprintf('\nTest for writeCbModel in sbml succeeded\n');
end
cd(oriFolder);
end
