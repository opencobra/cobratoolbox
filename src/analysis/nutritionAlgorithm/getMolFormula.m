function [molStr,molTable] = getMolFormula(model,metabolite)
% getMolFormula takes a metabolite in a specified model and returns the 
% molecular formula. 

% USAGE:
%
%    [molStr,molTable] = getMolFormula(model,'glu[c]')
%
% INPUTS:
%    model:          COBRA model structure with minimal fields:
%                      * .mets 
%                      * .metFormulas
%   metabolite:       a specified metabolite with in the model 
%
% OUTPUT:
%   molStr:  the molecular formula for the specified metabolite
%
%   molTable: A cellular array containing the breakdown of the metabolite
%             by element
%
% .. Authors: - Bronson R. Weston   2022


%Get the molStr from metFormulas
ind=find(strcmp(model.mets,metabolite));
if isempty(ind)
    error('Invalid input metabolite!')
end

try
    molStr=model.metFormulas{ind};
catch
    error('A "metFormulas" field is necessary in the input model to use getMolFormula.')
end

%Keep track of each element in the molStr
uC=isstrprop(molStr,'upper');
tracker={};
ind=0;
for i=1:length(uC)
    if uC(i)==1
        ind=ind+1;
        tracker{ind}=molStr(i);
        
    else
        tracker{ind}=[tracker{ind},molStr(i)];
    end
end


%Create the molTable
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
