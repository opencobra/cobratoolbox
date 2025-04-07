# Fields in the model structure

Contents:
1. [Model Fields](#model-fields)
2. [Field Support](#field-support)
3. [Model Specific Fields](#model-specific-fields)
4. [Annotation Definitions](#annotation-definitions)

### Model Fields:
The following fields are defined in the COBRA toolbox. IF the field is present in a model, it should have the properties defined here and should be of the mentioned dimensions.
 The dimensions refer to m (the number of metabolites), n (the number of reactions), g (the number of genes) and c (the number of compartments).

| Field Name | Dimension | Field Type | Field Description | COBRA Core Field |
|---|---|---|---|---|
|`model.S`| `m x n` | Sparse or Full Matrix of Double | The stoichiometric matrix containing the model structure (for large models a sparse format is suggested) | Yes |
|`model.mets`| `m x 1` | Column Cell Array of Strings | Identifiers of the metabolites | Yes |
|`model.b`| `m x 1` | Column Vector of Doubles | The coefficients of the constraints of the metabolites. | Yes |
|`model.csense`| `m x 1` | Column Vector of Chars | The sense of the constraints represented by b, each row is either E (equality), L(less than) or G(greater than) | Yes |
|`model.rxns`| `n x 1` | Column Cell Array of Strings | Identifiers for the reactions. | Yes |
|`model.lb`| `n x 1` | Column Vector of Doubles | The lower bounds for fluxes through the reactions. | Yes |
|`model.ub`| `n x 1` | Column Vector of Doubles | The upper bounds for fluxes through the reactions. | Yes |
|`model.c`| `n x 1` | Column Vector of Doubles | The objective coefficient of the reactions. | Yes |
|`model.osenseStr`| `` | String | The objective sense either `'max'` for maximisation or `'min'` for minimisation | Yes |
|`model.genes`| `g x 1` | Column Cell Array of Strings | Identifiers of the genes in the model | Yes |
|`model.rules`| `n x 1` | Column Cell Array of Strings | GPR rules in evaluateable format for each reaction ( e.g. "x(1) &#124; x(2) & x(3)", would indicate the first gene or both the second and third gene are necessary for the respective reaction to carry flux | No |
|`model.geneNames`| `g x 1` | Column Cell Array of Strings | Full names of each corresponding genes. | No |
|`model.compNames`| `c x 1` | Column Cell Array of Strings | Descriptions of the Compartments (compNames(m) is associated with comps(m)) | No |
|`model.comps`| `c x 1` | Column Cell Array of Strings | Symbols for compartments, can include Tissue information |  No |
|`model.proteinNames`| `g x 1` | Column Cell Array of Strings | Full Name for each Protein | No |
|`model.proteins`| `g x 1` | Column Cell Array of Strings | Proteins associated with each gene. | No |
|`model.metCharges`| `m x 1` | Column Vector of Double | The charge of the respective metabolite (NaN if unknown) | No |
|`model.metFormulas`| `m x 1` | Column Cell Array of Strings | Elemental formula for each metabolite. | No |
|`model.metSmiles`| `m x 1` | Column Cell Array of Strings | Formula for each metabolite in SMILES Format | No |
|`model.metNames`| `m x 1` | Column Cell Array of Strings | Full name of each corresponding metabolite. | Yes |
|`model.metNotes`| `m x 1` | Column Cell Array of Strings | Additional Notes for the respective metabolite. | No |
|`model.metHMDBID`| `m x 1` | Column Cell Array of Strings | HMDB identifier of the metabolite. | No |
|`model.metInChIString`| `m x 1` | Column Cell Array of Strings | Formula for each metabolite in the InCHI strings format. | No |
|`model.metKEGGID`| `m x 1` | Column Cell Array of Strings | KEGG identifier of the metabolite. | No |
|`model.metChEBIID`| `m x 1` | Column Cell Array of Strings | ChEBI identifier of the metabolite. | No |
|`model.metPubChemID`| `m x 1` | Column Cell Array of Strings | PubChem identifier of each metabolite | No |
|`model.metMetaNetXID`| `m x 1` | Column Cell Array of Strings | MetaNetX identifier of the metabolite | No |
|`model.metSEEDID`| `m x 1` | Column Cell Array of Strings | SEED identifier of the metabolite | No |
|`model.metBiGGID`| `m x 1` | Column Cell Array of Strings | BiGG identifier of the metabolite | No |
|`model.metBioCycID`| `m x 1` | Column Cell Array of Strings | BioCyc identifier of the metabolite | No |
|`model.metEnviPathID`| `m x 1` | Column Cell Array of Strings | enviPath identifier of the metabolite. | No |
|`model.metLIPIDMAPSID`| `m x 1` | Column Cell Array of Strings | LIPID MAPS identifier of the lipid. | No |
|`model.metReactomeID`| `m x 1` | Column Cell Array of Strings | Reactome identifier of the metabolite | No |
|`model.metSABIORKID`| `m x 1` | Column Cell Array of Strings | SABIO-RK identifier of the metabolite. | No |
|`model.metSLMID`| `m x 1` | Column Cell Array of Strings | SwissLipids identifier of the lipid. | No |
|`model.metSBOTerms`| `m x 1` | Column Cell Array of Strings | The SBO Identifier associated with the metabolite | No |
|`model.geneEntrezID`| `g x 1` | Column Cell Array of Strings | Entrez identifier of the gene | No |
|`model.geneRefSeqID`| `g x 1` | Column Cell Array of Strings | RefSeq identifier of the gene | No |
|`model.geneUniprotID`| `g x 1` | Column Cell Array of Strings | Uniprot identifier of the gene | No |
|`model.geneEcoGeneID`| `g x 1` | Column Cell Array of Strings | EcoGene identifier of the gene | No |
|`model.geneKEGGID`| `g x 1` | Column Cell Array of Strings | KEGG identifier of the gene | No |
|`model.geneHPRDID`| `g x 1` | Column Cell Array of Strings | Human Protein Reference Database identifier of the gene | No |
|`model.geneASAPID`| `g x 1` | Column Cell Array of Strings | A systematic annotation package for community analysis of genomes identifier of the gene | No |
|`model.geneCCDSID`| `g x 1` | Column Cell Array of Strings | Concensus CDS identifier of the gene | No |
|`model.geneNCBIProteinID`| `g x 1` | Column Cell Array of Strings | NCBI Protein identifier of the gene | No |
|`model.grRules`| `n x 1` | Column Cell Array of Strings | A string representation of the GPR rules defined in a readable format. | Yes |
|`model.rxnGeneMat`| `n x g` | Sparse or Full Matrix of Double or Boolean | Matrix with rows corresponding to reactions and columns corresponding to genes. | No |
|`model.rxnConfidenceScores`| `n x 1` | Column Vector of double | Confidence scores for reaction presence (0-5, with 5 being the highest confidence) | No |
|`model.rxnNames`| `n x 1` | Column Cell Array of Strings | Full name of each corresponding reaction. | Yes |
|`model.rxnNotes`| `n x 1` | Column Cell Array of Strings | Description of each corresponding reaction. | No | 
|`model.rxnECNumbers`| `n x 1` | Column Cell Array of Strings | E.C. number for each reaction. | No |
|`model.rxnReferences`| `n x 1` | Column Cell Array of Strings | Description of references for each corresponding reaction. | No |
|`model.rxnKEGGID`| `n x 1` | Column Cell Array of Strings | Formula for each reaction in the KEGG format. | No |
|`model.rxnKEGGPathways`| `n x 1` | Column Cell Array of Strings | KEGG identifier for a manually drawn pathway map the reaction belongs to. | No |
|`model.rxnMetaNetXID`| `n x 1` | Column Cell Array of Strings | MetaNetX identifier of the reaction | No |
|`model.rxnBRENDAID`| `n x 1` | Column Cell Array of Strings | BRENDA identifier of the reaction | No |
|`model.rxnBioCycID`| `n x 1` | Column Cell Array of Strings | BioCyc identifier of the reaction | No |
|`model.rxnReactomeID`| `n x 1` | Column Cell Array of Strings | Reactome identifier of the reaction | No |
|`model.rxnSABIORKID`| `n x 1` | Column Cell Array of Strings | SABIO-RK identifier of the reaction. | No |
|`model.rxnSEEDID`| `n x 1` | Column Cell Array of Strings | SEED identifier of the reaction | No |
|`model.rxnRheaID`| `n x 1` | Column Cell Array of Strings | Rhea identifier of the reaction | No |
|`model.rxnBiGGID`| `n x 1` | Column Cell Array of Strings | BiGG identifier of the reaction | No |
|`model.rxnSBOTerms`| `n x 1` | Column Cell Array of Strings | The SBO Identifier associated with the reaction | No |
|`model.subSystems`| `n x 1` | Column Cell Array of Cell Arrays of Strings | subSystem assignment for each reaction | No |
|`model.description`| `` | String or Struct | Name of a file the model is loaded from. | No |
|`model.modelVersion`| `` | Struct | Information on the model version | No |
|`model.modelName`| `` | String | A Descriptive Name of the model | No |
|`model.modelID`| `` | String | The ID of the model | No |
|`model.E`| `m x evars` | Sparse or Full Matrix of Double | Matrix of additional, non metabolic variables (e.g. Enzyme capacity variables) | No |
|`model.evarlb`| `evars x 1` | Column Vector of Doubles | Lower bounds of the additional variables | No |
|`model.evarub`| `evars x 1` | Column Vector of Doubles | Upper bounds of the additional variables | No |
|`model.evarc`| `evars x 1` | Column Vector of Doubles | Objective coefficient of the additional variables | No |
|`model.evars`| `evars x 1` | Column Cell Array of Strings | IDs of the additional variables | No |
|`model.evarNames`| `evars x 1` | Column Cell Array of Strings | Names of the additional variables | No |
|`model.C`| `ctrs x n` | Sparse or Full Matrix of Double | Matrix of additional Constraints (e.g. Coupling Constraints) | No |
|`model.ctrs`| `ctrs x 1` | Column Cell Array of Strings | IDs of the additional Constraints | No |
|`model.ctrNames`| `ctrs x 1` | Column Cell Array of Strings | Names of the of the additional Constraints | No |
|`model.d`| `ctrs x 1` | Column Vector of Doubles | Right hand side values of the additional Constraints | No |
|`model.dsense`| `ctrs x 1` | Column Vector of Chars | Senses of the additional Constraints | No |
|`model.D`| `ctrs x evars` | Sparse or Full Matrix of Double | Matrix to store elements that contain interactions between additional Constraints and additional Variables | No |
### Model Specific Fields
Some models might contain additional model specific fields that are not defined COBRA model fields. These fields will commonly not be considered by COBRA toolbox methods, and using toolbox methods can render these fields inconsistent (e.g. if the number of reactions changes, a model specific field linked to reactions might have the wrong number of entries or the values might no longer correspond to the correct indices).

### Field Support
All fields mentioned above are supported by COBRA Toolbox functions.Using COBRA Toolbox Functions will not make a model inconsistent, but manual modifications of fields might lead to an inconsistent model.
Use verifyModel(model) to determine, if the model is a valid COBRA Toolbox model.

### Additional fields
Fields starting with met, rxn, comp, protein or gene that are not defined above, will be assumed to be annotation fields, and IO methods will try to map them to identifiers.org registered databases.
