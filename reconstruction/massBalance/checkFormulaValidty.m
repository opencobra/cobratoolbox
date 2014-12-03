function [dbBool, noDocMets]=checkFormulaValidty(model)
% Assesses whether metabolites in model are likely to be documented in
% databases.
% 
% INPUT
% Model structure array
% 
% OUTPUTS
% dbBool    A boolian vector where the number of rows is equal to the number of
%           metabolites in model. Contains a logical 1 in rows for metabolites that
%           are likely to be documented in databases and a logical 0
%           elsewhere.
% 
% noDocMets A cell array containing a list of all metabolites in model that
%           are not likely to be documented in any database.
%
% Ronan Fleming
%

[nMets, nRxns] = size(model.S);

dbBool = ones(nMets,1);

for n = 1:nMets;

    if ~isempty(strfind(model.mets{n},'_hs'))
        dbBool(n)=0;
    end
    if ~isempty(strfind(model.mets{n},'hs_'))
        dbBool(n)=0;
    end
    if ~isempty(strfind(model.mets{n},'retn'))
        dbBool(n)=0;
    end
    if ~isempty(strfind(model.mets{n},'vitd'))
        dbBool(n)=0;
    end
    if ~isempty(strfind(model.mets{n},'rtotal'))
        dbBool(n)=0;
    end
    if ~isempty(strfind(model.mets{n},'deg'))
        dbBool(n)=0;
    end
    if ~isempty(strfind(model.metFormulas{n},'R'))
        dbBool(n)=0;
    end
    if ~isempty(strfind(model.metFormulas{n},'FULLR'))
        dbBool(n)=0;
    end
    if ~isempty(strfind(model.metFormulas{n},'X'))
        dbBool(n)=0;
    end

end

noDocMets = model.mets(~dbBool, 1);