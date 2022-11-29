function [molStr,molTable] = getMolFormulaVMH(metabolite,metaboliteTable)
% This function returns the molecular formula of a given vmh metabolite.
%
% USAGE:
%       1) [molStr,molTable] = getMolFormulaVMH(metabolite)
%       2) [molStr,molTable] = getMolFormulaVMH(metabolite,metaboliteTable)
%
% INPUT:
%   metabolite:         a metabolite in the vmh database
%
% OPTIONAL INPUT:
%   metaboliteTable:    a metabolite table containing all vmh metabolites.
%                       This optional input is recommended if the function 
%                       is run repetitively in a loop to eliminate
%                       readtable time.
%
% OUTPUT:
%   molStr:             a string containing the molecular formula of the
%                       metabolite
%   molTable:           a cellular array containing a breakdown of the
%                       frequency of each element in the molecule
%
% AUTHORS:
%       Bronson R. Weston, 2022


if ~exist('metaboliteTable','Var')
    metaboliteTable=readtable('MetaboliteDatabase.txt');
end
%try metabolite abreviation
ind=find(strcmp(metaboliteTable.Var1,metabolite));
if isempty(ind)
    %try metabolite full name
    ind=find(strcmp(metaboliteTable.Var2,metabolite));
    if isempty(ind)
        error('Invalid input metabolite!')
    elseif length(ind)>1
        ind=ind(1);
    end
end

%Get metabolite formula
molStr=metaboliteTable.Var4{ind};
uC=isstrprop(molStr,'upper');
tracker={};
ind=0;

%Break down metabolite by element and create molTable
for i=1:length(uC)
    if uC(i)==1
        ind=ind+1;
        tracker{ind}=molStr(i);
        
    else
        tracker{ind}=[tracker{ind},molStr(i)];
    end
end

molTable={};
for i=1:length(tracker)
    unit=tracker{i};
    num=isstrprop(unit,'digit');
    if ~any(num==1)
        molTable(i,:)={tracker{i} , 1};
    else
        molTable{i,1}=unit(num~=1);
        molTable{i,2}=str2num(unit(num==1));
    end
end
end
