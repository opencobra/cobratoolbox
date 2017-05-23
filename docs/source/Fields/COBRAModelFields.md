# Current Fields in the model structure

## Official definition from Schellenberger et al 2011 (Supplementary File 1)
<span style="color:red">The following field definitions are those used currently in the COBRA toolbox. 
Except for the required fields, they are subject to changes and should not be relied on</span>.  
### Required: 
* mets: metabolite name abbreviation; metabolite ID; order corresponds to S matrix. S: Stoichiometric matrix in sparse format.
* rev: logical array; true for reversible reactions, otherwise false
* lb: lower flux bound for corresponding reactions
* ub: upper flux bound for corresponding reactions
* c: objective coefficient for corresponding reactions
* metCharge: value of charge for corresponding metabolite
* metFormulas: Elemental formula for each metabolite
* rules: Boolean rule for the corresponding reaction which defines gene-reaction relationship.
* genes: List of all genes within the model.
* rxnGeneMat: matrix with rows corresponding to reactions and columns corresponding to genes
* grRules: cell list of gene-protein-reaction strings for each reaction
* subSystems: subSystem assignment for each reaction
* description: string describing the model (i.e. model name)

### Optional:
* rxnNames: Full name of each corresponding reaction
* rxnReferences: Cell array of strings which can contain optional information on references for
each specific reaction.
* rxnECNumbers: E. C. number for each reaction
* rxnNotes: Cell array of strings which can contain optional information for each specific reaction.
* confidenceScores: Confidence score for each reaction
* proteins: proteins associated with each reaction
* metNames: Full name of each corresponding metabolite
* metChEBIID: ChEBI ID for each corresponding metabolite
* metKeggID: KEGG ID for each corresponding metabolite
* metPubChemID: Pub Chem ID for each corresponding metabolite
* metInChIString: InChI String for each corresponding metabolite

## Recent *required* additions 
* model.modelVersion - the Version of the model
* model.osenseStr - The String representation of the objective sense (either 'min' or 'max')
* model.b - the b matrix 
* model.csense - a Char Array to indicate whether the b vector is supposed to be used as an equality (E), lower then (L) or greater then (G) 


## Recent optional fields
*  model.metInchiString &rarr; model.annotation.metabolite.inchi
*  model.rxnKeggID &rarr; model.annotation.metabolite.kegg\_\_46\_\_reaction
*  model.metHMDB &rarr; model.annotation.metabolite.hmdb
*  model.metEHMNID - Metabolite identifier from the Edinburgh Human Metabolic Network
*  model.rxnConfidenceEcoIDA - I'm not entirely sure what this field (again recon2) is supposed to indicate.
*  model.ExchRxnBool - logic array indicating exchange reactions
*  model.EXRxnBool - see model.ExchRxnBool
*  model.DMRxnBool - logic array indicating Demand Reactions 
*  model.SinkRxnBool - (see model.DMRxnBool)
*  model.SIntRxnBool - (see model.ExchRxnBool) anything thats not an exchange reaction should be internal...


# Possible future changes
The annotation fields linking to databases are currently under discussion, and could be reordered as follows. This includes in particular: metChEBIID, 
metKeggID, metPubChemID, metInChIString

*  model.annotation
*  model.annotation.reaction - contains reaction database annotations (with identifiers.org IDs and dots in these replaced by \_\_46\_\_ )
*  model.annotation.metabolite - contains metabolite database annotations (with identifiers.org IDs and dots in these replaced by \_\_46\_\_ )
*  model.annotation.genes - contains gene database annotations (with identifiers.org IDs and dots in these replaced by \_\_46\_\_ )
*  model.annotation.compartments - contains compartment database annotations (with identifiers.org IDs and dots in these replaced by \_\_46\_\_ )


Each field under annotation can have subfields defined by bioql qualifiers (e.g. is, isDerivedFrom, isDescribedBy, isInstanceOf, hasPart etc...)
These can directly be parsed to SBML Annotations. Would require to add functions that can manage this data during model curation (e.g. addGeneAnnotation(gene,databaseidentifier,database,varargin), 
with varargin providing for example the option to set the relation)

