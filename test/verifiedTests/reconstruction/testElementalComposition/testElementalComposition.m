% The COBRAToolbox: getElementalComposition.m
%
% Purpose:
%     - testElementalCompositions compares the getElementalComposition and atomic functions.
%
% Authors:
%     - Original file: Ronan Fleming 02/10/2020
%     - Enhancement:   Farid Zare    03/06/2025
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testElementalComposition'));
cd(fileDir);

fprintf('   Testing getElementalComposition function ... ')

formulae = {'C7H13A2N3O2';'C4H5A2N2O3';'CHA2NO';'C9H17A2N3O2';'C47H68O5';'C41H83NO8P';'C48H93NO8';'C13H24NO10P';...
          'C31H54NO4';'C28H44N2NaO23';'C5H10O3';'C6H11NO4';'C4H9N3O5P';'C55H95AN3O30';'C9H20ANO7P';'C39H44N4O12';'H';'Na';'C19H28O2'};
      
      

[A, elements, species] = atomic(formulae);

%faster
[Ematrix, elements] = getElementalComposition(formulae,elements);

%should be the same
assert(all(all(A' == Ematrix)))

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)


