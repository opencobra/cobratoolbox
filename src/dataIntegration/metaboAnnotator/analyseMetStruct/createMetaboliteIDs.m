% create metabolite database

metabolite_structure = struct();
if 1
    % this file seems to contain a lot of errors
    % [NUM,TXT,RAW]=xlsread('VMH_Metabolites.xlsx');
    
    % use instead as starting point as it comes from rBioNet
    [NUM,TXT,RAW]=xlsread('MetabolitesAGORA2_1.xlsx');
    for i = 2 : size(RAW,1)
        Ori = RAW{i,1};
        RAW{i,1} = regexprep(RAW{i,1},'-','_minus_');
        RAW{i,1} = regexprep(RAW{i,1},'(','_parentO_');
        RAW{i,1} = regexprep(RAW{i,1},')','_parentC_');
        metabolite_structure.(strcat('VMH_',RAW{i,1})) = struct();
        
        for j = 2:size(RAW,2)
            if j ~= 3
                metabolite_structure.(strcat('VMH_',RAW{i,1})).(RAW{1,j}) = RAW{i,j};
                metabolite_structure.(strcat('VMH_',RAW{i,1})).VMHId = Ori;
            end
        end
    end
    [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure)
    removeErrors = 1;
    [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);
    metabolite_structureStart = metabolite_structure;
    
end
if 1
    % add fields
    field2Add={
        'phenolExplorer'
        'neutralFormula'
        'chembl'
        'miriam'
        'hepatonetId'
        'iupac'
        'echa_id'
        'fda_id'
        'iuphar_id'
        'mesh_id'
        'chodb_id'
        'gtopdb'
        'inchiKey'
        'avgmolweight'
        'monoisotopicweight'
        'keggId'
        'inchiString'
        'pubChemId'
        'cheBIId'
        'hmdb'
        'pdmapName'
        'reconMap'
        'reconMap3'
        'food_db'
        'chemspider'
        'biocyc'
        'biggId'
        'wikipedia'
        'drugbank'
        'seed'
        'metanetx'
        'knapsack'
        'metlin'
        'casRegistry'
        'epa_id'
        'inchiKey'
        'smile'
        'lipidmaps'
        'reactome'
        'GNPS'
        'Recon3D'
        'Agora2'
        'massbank'
        'MoNa'
        'bindingdb'
        'metabolights'
        'rhea'
        'swisslipids'};
  %  field2Add = unique(field2Add);
    Mets = fieldnames(metabolite_structure);
    fields = fieldnames(metabolite_structure.(Mets{1}));
    
    [missingfields,map] = setdiff(field2Add,fields);
    for i = 1 : length(Mets)
        for j = 1 : length(missingfields)
            metabolite_structure.(Mets{i}).(missingfields{j}) = NaN;
        end
    end
end
cd FileDumps/
%[IDs,IDcountA,Table] = getStats(metabolite_structure);
%[metabolite_structure] = getMetIdsFromUniChemOffline(metabolite_structure);
assignMetaboliteIDs;
[IDs,IDcountB,Table] = getStats(metabolite_structure);
[metabolite_structure] = getMetIdsFromUniChemOffline(metabolite_structure);
[metabolite_structure,IDsAdded ] = parseChebiIdWebPage(metabolite_structure);
save vmh_met_anno
%assignMetaboliteIDs;
%[IDs,IDcountC,Table] = getStats(metabolite_structure);
%save vmh_met_anno
inchiKeyCheck = 1;
inchiStringCheck = 1;
inchiKeyAltCheck = 0;
cheBIIdCheck = 0;
drugBankCheck = 0;
pubChemIdCheck = 0;
keggIdCheck = 0;
hmdbCheck = 0;
vmhIdCheck = 0;
[metabolite_structure,IDsAdded] = getMetIdsFromUniChem(metabolite_structure,vmhIdCheck,cheBIIdCheck,drugBankCheck, pubChemIdCheck,keggIdCheck,hmdbCheck, inchiKeyCheck, inchiStringCheck,inchiKeyAltCheck );
[IDs,IDcountD,Table] = getStats(metabolite_structure);
save vmh_met_anno
translation = {'keggId' 'kegg'
    'inchiKey'  'inchikey'
    'hmdb'  'Human%20Metabolome%20Database'
    'cheBIId'   'chebi'
    'pubChemId' 'PubChem%20CID'
    'inchiString'   'inchi%20code'
    'bindingdb' 'bindingdb'
    'drugbank'  'drugbank'
    'biocyc'    'biocyc'
    'chemspider'    'chemspider'
    'casRegistry'   'cas'
    'lipidmaps' 'lipidmaps'
    'epa_id'    'epa%20dsstox'
    };
for i = 1 : 5%size(translation,1)
    for j = 1:size(translation,1)
        if i~=j
            i
            j
            [metabolite_structure,IDsAdded] = getIDsfromFiehnLab(metabolite_structure, translation{i,1},translation{j,1});
            save vmh_met_anno
        end
    end
    done = i
end
save vmh_met_anno
inchiKeyCheck = 1;
inchiStringCheck = 1;
inchiKeyAltCheck = 1;
[metabolite_structure,IDsAdded] = getMetIdsFromInchiKeys(metabolite_structure, inchiKeyCheck, inchiStringCheck,inchiKeyAltCheck);
save vmh_met_anno
assignMetaboliteIDs;
[IDs,IDcountD,Table] = getStats(metabolite_structure);
save vmh_met_anno

writecell(Table);