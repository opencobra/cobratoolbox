% create a table that lists the resources

fiehnLab = {'keggId' 'kegg'
    'inchiKey'  'inchikey'
    'bindingdb' 'bindingdb'
    'drugbank'  'drugbank'
    'biocyc'    'biocyc'
    'chemspider'    'chemspider'
    'casRegistry'   'cas'
    'pubChemId' 'PubChem%20CID'
    'hmdb'  'Human%20Metabolome%20Database'
    'cheBIId'   'chebi'
    'inchiString'   'inchi%20code'
    'lipidmaps' 'lipidmaps'
    'epa_id'    'epa%20dsstox'
    };

bridgeDB={
    'cheBIId'   'Ce'
    'biocyc'    'bc'
    'casRegistry'   'Ca'
    'cheBIId'   'Ce'
    'chemspider'    'Cs'
    'chembl'    'Cl'
    'drugbank'  'Dr'
    'hmdb'  'Ch'
    'iuphar_id'    'Gpl'%	Guide to Pharmacology Ligand ID (aka IUPHAR)
      'inchiKey'  'Ik'
    'keggId'    'Ck'%	KEGG Compound
    'keggId'    'Kd'    %Kd	KEGG Drug
    'keggId'    'Kl'    %Kl	KEGG Glycan
    'lipidmaps'  'Lm'
    'lipidbank' 'Lb'    %Lb	LipidBank
    'pharmgkb'  'Pgd'%	PharmGKB Drug
    'pubChemId' 'Cpc'
    %Cps	PubChem Substance
    'swisslipids'   'Sl'%	SwissLipids
    %Td	TTD Drug
    'wikidata' 'Wd' %Wd	Wikidata
    'wikipedia' 'Wi'%	Wikipedia
    'VMHId' 'VmhM'
    };

hmdb={
    'chemspider'        'http://www.chemspider.com' 'external'
    'food_db'   'http://foodb.ca/compounds' 'external'
    'wikipedia' 'http://en.wikipedia.org/wiki' 'external'
    'metlin'    'http://metlin.scripps.edu' 'external'
    'pubChemId'   'http://pubchem.ncbi.nlm.nih.gov/' 'external'
    'cheBIId'   'ChEBI ID' 'external'
    'keggId'  'http://www.genome.jp/dbget-bin' 'external'
    'inchiKey'   'InChI Key' 'internal'
    'inchiString' 'InChI=1S'    'internal'
 %   'smile'   'SMILES'  'internal'
    'avgmolweight' 'Average Molecular Weight'   'internal'
    'monoisotopicweight' 'Monoisotopic Molecular Weight'    'internal'
    'iupac'    'IUPAC Name' 'internal'
    'description'  'met-desc'   'internal'
    'biocyc'   'http://biocyc.org/META/' 'external'
    'phenolExplorer'    'http://www.phenol-explorer.eu' 'external'
    'casRegistry'   'CAS Registry Number' 'external'
    'knapsack'     'http://kanaya.naist.jp/knapsack_core' 'external'
    'drugbank'  'http://www.drugbank.ca/drugs/' 'external'
    'rxnav' 'https://mor.nlm.nih.gov/RxNav/' 'external'
    'zinc' 'https://zinc.docking.org/substances/' 'external'
    'pharmgkb'  'http://www.pharmgkb.org/drug' 'external'
    'pdbeLigand'   'http://www.ebi.ac.uk/pdbe-srv/pdbechem/chemicalCompound/' 'external'
    'drugs_com'    'http://www.drugs.com/' 'external'
    'VMHId'
    };

wikipedia ={
    'iuphar_id'   'http://www.guidetopharmacology.org/GRAC/'
    'chemspider'    'http://www.chemspider.com/Chemical-Structure'
    'echa_id'   'https://echa.europa.eu/substance-information/-/substanceinfo/'
    'chembl'    'https://www.ebi.ac.uk/chembldb'
    'casRegistry'   'http://www.commonchemistry.org/ChemicalDetail'
    'pubChemId' 'https://pubchem.ncbi.nlm.nih.gov/'
    'unii' 'https://fdasis.nlm.nih.gov/srs/'
    'epa_id'   'https://comptox.epa.gov/dashboard/'
    'keggId'    'https://www.kegg.jp/entry/'
    'drugbank'  'https://www.drugbank.ca/drugs/'
    };

kegg ={
   'casRegistry'   '<nobr>CAS:'
   'cheBIId' 'https://www.ebi.ac.uk/chebi/'
    'pubchemId' 'https://pubchem.ncbi.nlm.nih.gov/'
    'chembl'    'https://www.ebi.ac.uk/chembldb'
   'knapsack'  'http://kanaya.naist.jp/knapsack_jsp'
    };

chebi = {'wikipedia'
    'knapsack'
    'keggId'
    'biocyc'
    'hmdb'
    'casRegistry'
    'lipidmaps'
    };

drugbank={
    'chemspider'        'http://www.chemspider.com'
    'food_db'   'http://foodb.ca/compounds'
    'wikipedia' 'http://en.wikipedia.org/wiki'
    'metlin'    'http://metlin.scripps.edu'
    'pubChemId'   'http://pubchem.ncbi.nlm.nih.gov/'
    'cheBIId'   'ChEBI ID'
    'keggId'  'http://www.genome.jp/dbget-bin'
    'inchiKey'   'InChI Key'
    'inchiString' 'InChI=1S'
 %   'smile'   'SMILES'
    'avgmolweight' 'Average Molecular Weight'
    'monoisotopicweight' 'Monoisotopic Molecular Weight'
    'iupac'    'IUPAC Name'
    'description'  'met-desc'
    'biocyc'   'http://biocyc.org/META/'
    'phenolExplorer'    'http://www.phenol-explorer.eu'
    'casRegistry'   'CAS Registry Number'
    'knapsack'     'http://kanaya.naist.jp/knapsack_core'
    'rxnav' 'https://mor.nlm.nih.gov/RxNav/'
    'zinc' 'https://zinc.docking.org/substances/'
    'pharmgkb'  'http://www.pharmgkb.org/drug'
    'pdbeLigand'   'http://www.ebi.ac.uk/pdbe-srv/pdbechem/chemicalCompound/'
    'drugs_com'    'http://www.drugs.com/'
    };

unichem = {'cheBIId'
    'VMHId'
    'keggId'
    'pubChemId'
    'drugbank'
    };

metanetx ={
    'cheBIId' 'https://www.ebi.ac.uk/chebi/'
    'keggId'    'https://www.kegg.jp/entry'
    'seed'  'https://modelseed.org/biochem/compounds/'
    'biocyc'   'https://metacyc.org/compound?org'
    'inchiKey'  'InChIKey'
    'inchiString'   '\>InChI\>'
    'lipidmaps' 'https://www.lipidmaps.org/data/'
    'biggId'    'http://bigg.ucsd.edu/universal/metabolites/'
    'hmdb'     'https://hmdb.ca/metabolites/'
    'swisslipids'   'https://www.swisslipids.org/#/entity/'
    };

biggId = {
    'inchiKey'     'https://identifiers.org/inchikey/'
    'hmdb'  'http://identifiers.org/hmdb'
    'metanetx'  'http://identifiers.org/metanetx.chemical'
    'keggId'    'http://identifiers.org/kegg.compound/'
    'biocyc'    'http://identifiers.org/biocyc/'
    'reactome'  'http://identifiers.org/reactome/' % for the moment I greb only the first entry
    'cheBIId'   'http://identifiers.org/chebi/'
    };

epa_id = {
    };

