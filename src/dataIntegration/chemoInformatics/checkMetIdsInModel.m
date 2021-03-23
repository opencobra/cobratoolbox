function metsIdsStatistics = checkMetIdsInModel(model)
% Function to print the statistics of the metabolites id in the a model
%
% USAGE:
%
%    metsIdsStatistics = checkMetIdsInModel(model)
%
% INPUTS:
%    model:              COBRA model with following fields:
%
%                       * .mets - An m x 1 array of metabolite identifiers.
%                                 Should match metabolite identifiers in
%                                 RXN.
% OUTPUTS:
%    metsIdsStatistics:	 Information such as number per database, coverage
%                        or times another ID is shared for the same
%                        metabolite.

fields = fieldnames(model);
sources = {'kegg', 'hmdb', 'chebi', 'pubchem', 'smiles', 'inchi'};
mets = regexprep(model.mets, '(\[\w\])', '');
umets = unique(mets);

for i = 1:length(sources)
    
    fieldInModelBool = ~cellfun(@isempty, regexpi(fields, sources{i}));
    if any(fieldInModelBool)
        
        if sum(fieldInModelBool) == 1
            sourceIdsPerMet = model.(fields{fieldInModelBool});
        else
            dbFields = fields(fieldInModelBool);
            sourceIdsPerMet = model.(dbFields{~cellfun(@isempty, regexpi(dbFields, 'met'))});
        end
        
        
        sourceData.metWithIdBool = ~cellfun(@isempty, sourceIdsPerMet);
        sourceData.metWithIdTotal = sum(sourceData.metWithIdBool);
        sourceData.DBcoverage = (sourceData.metWithIdTotal * 100) / size(mets, 1);
        
        % unique metabolites
        dbMets = sourceIdsPerMet(sourceData.metWithIdBool);
        uDbMets = unique(dbMets);
        uniqueBool = false(size(mets, 1), 1);
        for j = 1:size(uDbMets, 1)
            idx = find(ismember(sourceIdsPerMet, uDbMets{j}));
            uniqueBool(idx(1)) = true;
        end
        
        sourceData.uniqueMetWithIdBool = uniqueBool;
        sourceData.uniqueMetWithIdTotal = sum(sourceData.uniqueMetWithIdBool);
        sourceData.uniqueIdDBcoverage = (sourceData.uniqueMetWithIdTotal * 100) / size(umets, 1);
        
        switch sources{i}
            
            case 'kegg'
                metsIdsStatistics.KEEG = sourceData;
            case 'hmdb'
                metsIdsStatistics.HMDB = sourceData;
            case 'chebi'
                metsIdsStatistics.ChEBi = sourceData;
            case 'pubchem'
                metsIdsStatistics.PubChem = sourceData;
            case 'smiles'
                metsIdsStatistics.SMILES = sourceData;
            case 'inchi'
                metsIdsStatistics.InChI = sourceData;
        end
        
        clear DBdata dbIdsPerMet
    end
end

end

