function [DietFormulation] = readInDietFromVMH(fileNameDiet)
% This function reads in the diet that has been created and downloaded from
% the https://www.vmh.life/#nutrition and converts it into the whole-body
% metabolic model consistent format.
% 
% [DietFormulation] = readInDietFromVMH(fileNameDiet)
% 
% INPUT 
% fileNameDiet      File name
%
% OUTPUT
% DietFormulation   Diet definition
%
% Ines Thiele 2016-2019

[Numbers, Strings] = xlsread(fileNameDiet{1});

ColFlux = 1;% assumes that fluxValues are given in 2nd col

DietNames = Strings(2:end,6); % assumes that Rxn names are given in 6th column

DietNames = regexprep(DietNames,'EX_','Diet_EX_');
DietNames = regexprep(DietNames,'\(e\)','\[d\]');
% Diet exchanges for all individuals
Diets = cellstr(num2str((Numbers(:,ColFlux))));

DietFormulation = [DietNames  Diets];