function [dE ,E, missingFormulaeBool] = checkBalance(model, element, printLevel, fileName, missingFormulaeBool)
% Checks whether a set of reactions is elementally balanced.
% Note that exchange reactions are not elementally balanced.
%
% USAGE:
%
%    [dE ,E, missingFormulaeBool] = checkBalance(model, element, printLevel, fileName, missingFormulaeBool)
%
% INPUTS:
%    model:                  COBRA model structure:
%
%                              * .S - Stoichiometric matrix
%                              * .metForumlas - Metabolite formulas
%    element:                Abbreviation of element e.g. C or Mg
%
% OPTIONAL INPUTS:
%    printLevel:             {-1, (0), 1} where:
%
%                            -1 = print out missing formulae to a file;
%                            0 = silent;
%                            1 = print out  missing formulae to screen reactions to screen
%    fileName:               name of the file
%    missingFormulaeBool:    boolean variable for missing formulae
%
% OUTPUTS:
%    dE:                     `n` x 1 vector of net change in elements per reaction `bal = E*S`
%                            If `isnan(dE(n))` then the reaction involves a metabolite without a formula.
%    E:                      `m` x 1 vector with number of elements in each metabolite
%    missingFormulaeBool:    boolean variable for missing formulae
%
% .. Author: - Ronan M.T. Fleming, July 2009
%            - Uri David Akavia, May 2019

if ~isfield(model,'metFormulas')
    error('model structure must contain model.metFormulas field')
end
if ~exist('printLevel','var')
    printLevel=1;
end
if ~exist('fileName','var')
    fileName='';
end
nMet=size(model.S, 1);
if ~exist('missingFormulaeBool','var')
    missingFormulaeBool=cellfun(@isempty, model.metFormulas);
end

for m=1:nMet
    %cannot handle metabolites with non-standard formulae like
    %(Gal)3(Glc)1(GlcNAc)2(LFuc)1(Cer)1
    if missingFormulaeBool(m,1) || strcmp(model.metFormulas{m}(1),'(')
        missingFormulaeBool(m,1)=1;
    end
end

E=zeros(nMet,1);
firstMissing=0;
for m=1:nMet
    if isempty(model.metFormulas{m}) || missingFormulaeBool(m,1)
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
    else
        try
            E(m,1)=numAtomsOfElementInFormula(model.metFormulas{m},element,printLevel);
        catch ME
            missingFormulaeBool(m,1)=1;
            %disp(model.mets{m})
            rethrow(ME)
        end
    end
end

dE=model.S'*E;
dE(abs(dE) < 1e-12) = 0;
% setting reactions with unknown metabolites to NaN
% inidcating that the mass balance of the reaction is unknown.
dE(any(model.S(missingFormulaeBool, :))) = NaN;
% Setting E for unknown metaoblties to NaN
E(missingFormulaeBool) = NaN;

if exist('fid','var')
    fclose(fid);
end
