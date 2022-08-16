% allowed COBRA fields can be found here
%        fileName = which('COBRA_structure_fields.tab');
%        [raw] = descFileRead(fileName);
% raw.Model_Field
% this table translates metabolite structure fields and COBRA model fields
translation = {
    % metabolites
    'metNames'  'metNames'
    'chargedFormula'   'metFormulas'
    'charge'    'metCharges'
    'keggId'    'metKEGGID'
    'inchiKey'   'metInchiKey'
    'hmdb'  'metHMDBID'
    'cheBIId'   'metChEBIID'
    'metanetx'  'metMetaNetXID'
    'seed'  'metSEEDID'
    'biggId'    'metBiGGID'
    'biocyc'    'metBioCycID'
    'reactome'  'metReactomeID'
    'lipidmaps' 'metLIPIDMAPSID'
    
    %    metEnviPathID %https://envipath.org/
    %    metSLMID %https://www.smid-db.org/
    'sboTerms'     'metSBOTerms'
    'drugbank'     'metDrugbank'
    'sabiorkID'    'metSABIORKID' %http://sabiork.h-its.org/newSearch/index
    'inchiString' 'metInchiString'
    'pubChemId' 'metPubChemID'
    'smile' 'metSmile'
    
    };