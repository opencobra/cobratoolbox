function x = testGrowthExpMatch()
%testGrowthExpMatch tests the functionality of all the components of growthExpMatch
%
%[solution,b,solInt,m ]=testGrowthExpMatch()
%
%Inputs:        
%model                      model to be examined, which is obtained from BiGG Database (ie. 'core.xml')
%Dictionary                  n x 2 cell array of metabolites names for
%                               conversion from KEGG ID's to the compound
%                               abbreviations from BiGG database (1st
%                               column is compound abb. and 2nd column is
%                               KEGG ID)
%Kegg_reaction_list.lst      universal data from KEGG website
%Compartment                 [c] --> transport from cytoplasm [c] to extracellulat space
%                               [e] (default), [p] creates transport from [c] to [p] 
%                               and from [p] to [c]
%Outputs:
%solution  MILP solution that consists of the continuous solution, integer
%               solution, objective value, stat, full solution, and
%               imported reactions
%
%Procedure to run growthExpMatch:
%(1) obtain all input files (ie. model, CompAbr, and KEGGID are from BiGG, KEGGList is from KEGG website)
%(2) remove desired reaction from model with removeRxns, or set the model 
%       on a particular Carbon or Nitrogen source
%(3) create an SUX Matrix by using the function MatricesSUX = 
%       generateSUXMatrix(model,Dictionary, KEGGFilename,Compartment)
%(4) run it through growthExpMatch using [solution,b,solInt]=Smiley(MatricesSUX)
%(5) solution.importedRxns contains the solutions to all iterations (in
%       this particular test, we removed reaction ENO from model and
%       obtained 'R00658_f' which is the KEGGID for ENO
%
%   Joseph Kang 11/16/09

oriFolder = pwd;

%moves to testing folder that contains testGrowthExpMatch
test_folder = what('testGrowthExpMatch');
cd(test_folder(1).path);

%load Model
load('ecoli_core_model.mat');

%removes reaction ENO
disp('------------------------------------')
disp('Removing reaction, ENO, from test model:')
model = removeRxns(model, 'ENO');

%moves to folder w/ input files
% w = what('testing');
% p = w.path;
% cd(p);
d = load('Dictionary.mat');
KEGGFilename = 'Test_KEGG_Reaction_List.lst';

%runs growthExpMatch and obtains solution
cd(test_folder(1).path);
[solution]=growthExpMatch(model, KEGGFilename,'[c]', 1, d.dictionary);

%if R00658_f is solution result, returns a positive answer, else negative
if strcmp(solution.importedRxns{1}, 'R00658_f')
    disp('growthExpMatch has imported the correct reaction from Universal data');
    x=1;
else
    disp('growthExpMatch has not imported the correct reaction from Universal data');
    x=0;
end

close;
cd(oriFolder);

end

