% This m file contains the list of allowable fields in the
% metabolite_structure
%
% Ines Thiele, 2020/2021

field2Add={
    'VMHId'
    'metNames'
    'charge'
    'neutralFormula'
    'chargedFormula'
    'phenolExplorer'
    'neutralFormula'
    'description'
    'chembl'
    'miriam'
    'hepatonetId'
    'iupac'
    'echa_id' % use https://echa.europa.eu/information-on-chemicals/cl-inventory-database/-/discli/substance/external/echa_id AND https://echa.europa.eu/substance-information/-/substanceinfo/echa_id
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
    'swisslipids'
    'actor'%https://actor.epa.gov/actor/chemical.xhtml?casrn=32981-86-5
    'unii'% https://fdasis.nlm.nih.gov/srs/unii/9G2MP84A8W AND https://druginfo.nlm.nih.gov/drugportal/unii/WDT5SLP0HQ AND https://chem.nlm.nih.gov/chemidplus/unii/WDT5SLP0HQ
    'rxnav' %https://mor.nlm.nih.gov/RxNav/search?searchBy=RXCUI&searchTerm=7052
    'zinc'  %http://zinc.docking.org/substances/ZINC000003812983/
    'pdbeLigand' %https://www.ebi.ac.uk/pdbe-srv/pdbechem/chemicalCompound/show/MOI
    'drugs_com' %https://www.drugs.com/morphine.html
    'chemidplus' %https://chem.nlm.nih.gov/chemidplus/rn/32981-86-5
    'clinicaltrials'    %https://clinicaltrials.gov/search/intervention=Oxypurinol
    'ctd'   %http://ctdbase.org/detail.go?type=chem&acc=D010117 % are they using keggId's? AND http://ctdbase.org/detail.go?type=chem&acc=D010117&view=disease
    'hasmolfile'
    'wikidata'
    'lipidbank'
    'classyFire_Kingdom'
    'classyFire_Superclass'
    'classyFire_Class'
    'classyFire_Subclass'
    'classyFire_Level5'
    'metabolon' % as provided in their input file, currently metabolon_crossmatch_IT_withUpdatedInchiKey
    'exposomeExplorer'%http://exposome-explorer.iarc.fr/search?utf8=%E2%9C%93&query=2-aminophenol+sulfate&button=
    };
