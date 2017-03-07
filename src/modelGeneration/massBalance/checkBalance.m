function [dE,E,missingFormulaeBool]=checkBalance(model,element,printLevel,fileName)
% [dE,E]=checkBalance(model,element,printLevel)
% Checks whether a set of reactions is elementally balanced.
%
% note that exchange reactions are not elementally balanced
%
% INPUT
% model                 COBRA model structure
%      .S               Stoichiometric matrix
%      .metForumlas     Metabolite formulas
% element               Abbreviation of element e.g. C or Mg
%
%
% OPTIONAL INPUT
% printLevel                    {-1,(0),1} 
%                               -1=print out missing formulae to a file
%                               0=silent
%                               1=print out  missing formulae to screen                             reactions to screen 
%
% OUTPUT
% dE        n x 1 vector of net change in elements per reaction bal = E*S
%           If isnan(dE(n)) then the reaction involves a metabolite without
%           a formula.
%
% E         m x 1 vector with number of elements in each metabolite
% 
% Ronan M.T. Fleming    July 2009

if ~isfield(model,'metFormulas')
    error('model structure must contain model.metForumlas field')
end
if ~exist('printLevel','var')
    printLevel=1;
end
if ~exist('fileName','var')
    fileName='';
end

[nMet,nRxn]=size(model.S);

missingFormulaeBool=false(nMet,1);

E=zeros(nMet,1);
firstMissing=0;
for m=1:nMet
    if isempty(model.metFormulas{m})
        missingFormulaeBool(m,1)=1;
        if printLevel==1
            fprintf('%s\t%s\n',int2str(m),[model.mets{m} ' has no formula'])
        end
        if printLevel==-1
            if ~firstMissing
                fid=fopen([fileName 'metabolites_without_formulae.txt'],'w');
            end
            firstMissing=1;
            fprintf(fid,'%s\t%s\n',int2str(m),model.mets{m});
        end
        if 1
            %NaN will show up in dE for the corresponding reaction
            %inidcating that the mass balance of the reaction is unknown.
            E(m,1)=NaN;
        else
            error('model structure must contain model.metForumlas field for each metabolite');
        end
    else
        try
            E(m,1)=numAtomsOfElementInFormula(model.metFormulas{m},element);
        catch ME
            disp(model.mets{m})
            rethrow(ME)
        end
    end
end

dE=model.S'*E; 
dE(abs(dE) < 1e-12) = 0;

if exist('fid','var')
    fclose(fid);
end