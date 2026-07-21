function [DietFormulation] = readInDietFromVMH(fileNameDiet)
% Read in a diet that has been created and downloaded from the VMH nutrition
% tool (https://www.vmh.life/#nutrition) and convert it into the format used
% by the whole-body metabolic model
%
% USAGE:
%
%    [DietFormulation] = readInDietFromVMH(fileNameDiet)
%
% INPUT:
%    fileNameDiet:      cell whose first entry is the name of the diet
%                       spreadsheet to read; the Excel file `fileNameDiet{1}`
%                       provides the flux values (column 1) and the reaction
%                       names (column 6)
%
% OUTPUT:
%    DietFormulation:    `d x 2` cell array defining the diet, with the diet
%                        exchange reaction identifiers (`Diet_EX_...[d]`) in
%                        the first column and their flux values in the second
%
% .. Author: - Ines Thiele, 2016-2019

[Numbers, Strings] = xlsread(fileNameDiet{1});

ColFlux = 1;% assumes that fluxValues are given in 2nd col

DietNames = Strings(2:end,6); % assumes that Rxn names are given in 6th column

DietNames = regexprep(DietNames,'EX_','Diet_EX_');
DietNames = regexprep(DietNames,'\(e\)','\[d\]');
% Diet exchanges for all individuals
Diets = cellstr(num2str((Numbers(:,ColFlux))));

DietFormulation = [DietNames  Diets];