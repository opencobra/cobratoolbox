# Fields in the model structure

Contents:
1. [Required Fields](#required-fields)
2. [Optional Fields](#optional-fields)
3. [Field Support](#field-support)
4. [Model Specific Fields](#model-specific-fields)
5. [Annotation Definitions](#annotation-definitions)

### Required Fields: 
Required fields are necessary to make a model be compliant with the COBRA Toolbox. Missing a required field can lead to errors when using COBRA Toolbox Functions.

| Field Name | Field Type | Field Description | Properties | 
|---|---|---|---|
| `S`| Sparse or Full Matrix of Double| The stoichiometric matrix containing the model structure (for large models a sparse format is suggested) | ` ` | 
| `rxns`| Column Cell Array of Strings  | Identifiers for the reactions. | ` size(rxns,1) == size(S,2) ` | 
| `lb`| Column Vector of Doubles  | The lower bounds for fluxes through the reactions.   | ` size(lb,1) == size(S,2) ` | 
| `ub`| Column Vector of Doubles  | The upper bounds for fluxes through the reactions.   | ` size(ub,1) == size(S,2) ` | 
| `c `| Column Vector of Doubles  | The objective coefficient of the reactions.   | ` size(c,1) == size(S,2) ` | 
| `osense `| Double  | The objective sense either -1 for maximisation or 1 for minimisation | ` osense == 1` &#124; `osense == -1 ` | 
| `mets `| Column Cell Array of Strings  | Identifiers of the metabolites | ` size(mets,1) == size(S,1) ` | 
| `b`| Column Vector of Doubles  | The coefficients of the constraints of the metabolites. | ` size(b,1) == size(S,1) ` | 
| ``csense``| Column Vector of Chars  | The sense of the constraints represented by b, each row is either E (equality), L(less than) or G(greater than) | ` size(csense,1) == size(S,1) ` | 
| `genes`| Column Cell Array of Strings | Identifiers of the genes in the model | ` size(genes,2) == 1 ` | 
| `rules`| Column Cell Array of Strings | GPR rules in evaluateable format for each reaction ( e.g. 'x(1) &#124; x(2) & x(3)', would indicate the first gene or the seond and third gene from genes) | ` size(rules,1) = size(S,2) ` | 

### Optional Fields
Optional Fields are fields which are required by some functions (if not present, the function will report a corresponding message).

| `Field Name` | Field Type | Field Description | Properties | 
|---|---|---|---|
| `metCharges`| Column Vector of Double | The charge of the respective metabolite (NaN if unknown) | ` size(metCharges,1) == size(mets,1)` | 
| `metFormulas`| Column Cell Array of Strings | Elemental formula for each metabolite | ` size(metFormulas,1) == size(mets,1)` | 
| `metSMILES`| Column Cell Array of Strings | Formula for each metabolite in SMILES Format | ` size(metFormulas,1) == size(mets,1)` | 
| `metNames`| Column Cell Array of Strings |Full name of each corresponding metabolite | ` size(rxnNames,1) == size(mets,1)` | 
| `metNotes`| Column Cell Array of Strings | Description of each corresponding metabolite | ` size(rxnNames,1) == size(mets,1)` | 
| `rxnGeneMat`| Sparse or Full Matrix of Double or Boolean | A matrix that is 1 at position i,j if reaction i is associated with gene j | ` all(size(rxnGeneMat) == [size(S,2), size(genes,1)])` | 
| `grRules`| Column Cell Array of Strings | A string representation of the GPR rules defined in rules | ` size(grRules,1) == size(S,2)` | 
| `subSystems`| Column Cell Array of Strings | subSystem assignment for each reaction | ` size(grRules,1) == size(rxns,1)` | 
| `confidenceScores`| Column Vector of double | Confidence scores for reaction presence (0-5, with 5 being the highest confidence) | `  size(confidenceScores,1) == size(rxns,1)` | 
| `rxnNames`| Column Cell Array of Strings | Full name of each corresponding reaction | ` size(rxnNames,1) == size(rxns,1)` | 
| `rxnNotes`| Column Cell Array of Strings | Description of each corresponding reaction | ` size(rxnNotes,1) == size(rxns,1)` | 
| `geneNames`| Column Cell Array of Strings | Full names of genes | `size(geneNames,1) == size(genes,1)`  | 
| `comps`| Column Cell Array of Strings | Identifiers of the compartments used in the metabolite names |  | 
| `compNames`| Column Cell Array of Strings | Full names of the compartments | `size(compNames,1) == size(comp,1)`  | 
| `modelVersion`| Struct | Model Version/History | ` ` | 
| `description`| String | Name of a file the model is loaded from | ` ` | 
| `annotations` | struct() | Annotations for the model (see below for a detailed structure) | ` ` | 

### Model Specific Fields
Some models might contain additional model specific fields that are not defined COBRA model fields. These fields will commonly not be considered by COBRA toolbox methods, and using toolbox methods can render these fields inconsistent (e.g. if the number of reactions changes, a model specific field linked to reactions might have the wrong number of entries or the values might no longer correspond to the correct indices). 

### Field Support
All optional and all required fields are supported by all COBRA Toolbox functions. Using COBRA Toolbox Functions will not make a model inconsistent, but manual modifications of fields might lead to an inconsistent model.
Use verifyModel(model) to determine, if the model is a valid COBRA Toolbox model.

### Additional fields (future development)
Fields starting with met, rxn, comp or gene that are not defined above, will be assumed to be annotation fields, and IO methods will try to map them to identifiers.org registered databases.
