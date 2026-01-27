function [fList, pList]=matlabDependencies(functionName)
% lists the dependencies of a given function
% INPUT
% functionName  name of a function, e.g., 'yourScript.m'

functionName = which(functionName);

[fList, pList] = matlab.codetools.requiredFilesAndProducts(functionName);

fList = fList';
pList = pList';
