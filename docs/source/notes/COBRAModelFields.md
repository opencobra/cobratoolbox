# Fields in the model structure

Contents:
1. [Model Fields](#model-fields)
2. [Field Support](#field-support)
3. [Model Specific Fields](#model-specific-fields)
4. [Annotation Definitions](#annotation-definitions)

### Model Fields:
The following fields are defined in the COBRA toolbox. IF the field is present in a model, it should have the properties defined here and should be of the mentioned dimensions.
 The dimensions refer to m (the number of metabolites), n (the number of reactions), g (the number of genes) and c (the number of compartments).

| Field Name | Dimension | Field Type | Field Description |
|---|---|---|---|
|`model.S`| `m x n` | Sparse or Full Matrix of Double | The stoichiometric matrix containing the model structure (for large models a sparse format is suggested) | 
|`model.mets`| `m x 1` | Column Cell Array of Strings | Identifiers of the metabolites | 
|`model.b`| `m x 1` | Column Vector of Doubles | The coefficients of the constraints of the metabolites. | 
|`model.csense`| `m x 1` | Column Vector of Chars | The sense of the constraints represented by b, each row is either E (equality), L(less than) or G(greater than) | 
|`model.rxns`| `n x 1` | Column Cell Array of Strings | Identifiers for the reactions. | 
|`model.lb`| `n x 1` | Column Vector of Doubles | The lower bounds for fluxes through the reactions. | 
|`model.ub`| `n x 1` | Column Vector of Doubles | The upper bounds for fluxes through the reactions. | 
|`model.c`| `n x 1` | Column Vector of Doubles | The objective coefficient of the reactions. | 
|`model.osenseStr`| `` | String | The objective sense either `'max'` for maximisation or `'min'` for minimisation | 
|`model.genes`| `g x 1` | Column Cell Array of Strings | Identifiers of the genes in the model | 
|`model.rules`| `n x 1` | Column Cell Array of Strings | "GPR rules in evaluateable format for each reaction ( e.g. ""x(1) &#124; x(2) & x(3)"", would indicate the first gene or both the second and third gene are necessary for the respective reaction to carry flux" | 
|`model.geneNames`| `g x 1` | Column Cell Array of Strings | Full names of each corresponding genes. | 
|`model.compNames`| `c x 1` | Column Cell Array of Strings | Descriptions of the Compartments (compNames(m) is associated with comps(m)) | 
|`model.comps`| `c x 1` | Column Cell Array of Strings | Symbols for compartments, can include Tissue information | 
|`model.proteinNames`| `g x 1` | Column Cell Array of Strings | Full Name for each Protein | 
|`model.proteins`| `g x 1` | Column Cell Array of Strings | Proteins associated with each gene. | 
|`model.metCharges`| `m x 1` | Column Vector of Double | The charge of the respective metabolite (NaN if unknown) | 
|`model.metFormulas`| `m x 1` | Column Cell Array of Strings | Elemental formula for each metabolite. | 
|`model.metSmiles`| `m x 1` | Column Cell Array of Strings | Formula for each metabolite in SMILES Format | 
|`model.metNames`| `m x 1` | Column Cell Array of Strings | Full name of each corresponding metabolite. | 
|`model.metNotes`| `m x 1` | Column Cell Array of Strings | Additional Notes for the respective metabolite. | 
|`model.metHMDBID`| `m x 1` | Column Cell Array of Strings | HMDB ID of the metabolite. | 
|`model.metInChIString`| `m x 1` | Column Cell Array of Strings | Formula for each metabolite in the InCHI strings format. | 
|`model.metKEGGID`| `m x 1` | Column Cell Array of Strings | KEGG ID of the metabolite. | 
|`model.metChEBIID`| `m x 1` | Column Cell Array of Strings | ChEBI ID of the metabolite. | 
|`model.metPubChemID`| `m x 1` | Column Cell Array of Strings | PubChem ID of each metabolite | 
|`model.metMetaNetXID`| `m x 1` | Column Cell Array of Strings | MetaNetX identifier of the metabolite | 
|`model.metSBOTerms`| `m x 1` | Column Cell Array of Strings | The SBO Identifier associated with the metabolite | 
|`model.geneEntrezID`| `g x 1` | Column Cell Array of Strings | Entrez IDs of genes | 
|`model.grRules`| `n x 1` | Column Cell Array of Strings | A string representation of the GPR rules defined in a readable format. | 
|`model.rxnGeneMat`| `n x g` | Sparse or Full Matrix of Double or Boolean | Matrix with rows corresponding to reactions and columns corresponding to genes. | 
|`model.rxnConfidenceScores`| `n x 1` | Column Vector of double | Confidence scores for reaction presence (0-5, with 5 being the highest confidence) | 
|`model.rxnNames`| `n x 1` | Column Cell Array of Strings | Full name of each corresponding reaction. | 
|`model.rxnNotes`| `n x 1` | Column Cell Array of Strings | Description of each corresponding reaction. | 
|`model.rxnECNumbers`| `n x 1` | Column Cell Array of Strings | E.C. number for each reaction. | 
|`model.rxnReferences`| `n x 1` | Column Cell Array of Strings | Description of references for each corresponding reaction. | 
|`model.rxnKEGGID`| `n x 1` | Column Cell Array of Strings | Formula for each reaction in the KEGG format. | 
|`model.rxnMetaNetXID`| `n x 1` | Column Cell Array of Strings | MetaNetX identifier of the reaction | 
|`model.rxnSBOTerms`| `n x 1` | Column Cell Array of Strings | The SBO Identifier associated with the reaction | 
|`model.subSystems`| `n x 1` | Column Cell Array of Cell Arrays of Strings | subSystem assignment for each reaction | 
|`model.description`| `` | String or Struct | Name of a file the model is loaded from. | 
|`model.modelVersion`| `` | Struct | Information on the model version | 
|`model.modelName`| `` | String | A Descriptive Name of the model | 
|`model.modelID`| `` | String | The ID of the model | 
|`model.E`| `m x evars` | Sparse or Full Matrix of Double | Matrix of additional, non metabolic variables (e.g. Enzyme capacity variables) | 
|`model.evarlb`| `evars x 1` | Column Vector of Doubles | Lower bounds of the additional variables | 
|`model.evarub`| `evars x 1` | Column Vector of Doubles | Upper bounds of the additional variables | 
|`model.evarc`| `evars x 1` | Column Vector of Doubles | Objective coefficient of the additional variables | 
|`model.evars`| `evars x 1` | Column Cell Array of Strings | IDs of the additional variables | 
|`model.evarNames`| `evars x 1` | Column Cell Array of Strings | Names of the additional variables | 
|`model.C`| `ctrs x n` | Sparse or Full Matrix of Double | Matrix of additional Constraints (e.g. Coupling Constraints) | 
|`model.ctrs`| `ctrs x 1` | Column Cell Array of Strings | IDs of the additional Constraints | 
|`model.ctrNames`| `ctrs x 1` | Column Cell Array of Strings | Names of the of the additional Constraints | 
|`model.d`| `ctrs x 1` | Column Vector of Doubles | Right hand side values of the additional Constraints | 
|`model.dsense`| `ctrs x 1` | Column Vector of Chars | Senses of the additional Constraints | 
|`model.D`| `ctrs x evars` | Sparse or Full Matrix of Double | Matrix to store elements that contain interactions between additional Constraints and additional Variables | 
### Model Specific Fields
Some models might contain additional model specific fields that are not defined COBRA model fields. These fields will commonly not be considered by COBRA toolbox methods, and using toolbox methods can render these fields inconsistent (e.g. if the number of reactions changes, a model specific field linked to reactions might have the wrong number of entries or the values might no longer correspond to the correct indices).

### Field Support
All fields mentioned above are supported by COBRA Toolbox functions.Using COBRA Toolbox Functions will not make a model inconsistent, but manual modifications of fields might lead to an inconsistent model.
Use verifyModel(model) to determine, if the model is a valid COBRA Toolbox model.

### Additional fields
Fields starting with met, rxn, comp, protein or gene that are not defined above, will be assumed to be annotation fields, and IO methods will try to map them to identifiers.org registered databases.