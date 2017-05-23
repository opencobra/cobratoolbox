# Fields in the model structure

Contents:
1. [Required Fields](#required-fields)
2. [Optional Fields](#optional-fields)3. [Field Support](#field-support)
4. [Model Specific Fields](#model-specific-fields)
5. [Annotation Definitions](#annotation-definitions)

### Required Fields: 
Required fields are necessary to make a model be compliant with the COBRA Toolbox. Missing a required field can lead to errors when using COBRA Toolbox Functions. Verification is an evaluateable statement that the field must conform to.

| Field Name | Field Type | Field Description | Verification | 
|---|---|---|---|
|`S`| Sparse or Full Matrix of Double | The stoichiometric matrix containing the model structure (for large models a sparse format is suggested) | `isnumeric(x) || issparse(x)` | 
|`b`| Column Vector of Doubles | The coefficients of the constraints of the metabolites. | `isnumeric(x)` | 
|`csense`| Column Vector of Chars | The sense of the constraints represented by b, each row is either E (equality), L(less than) or G(greater than) | `ischar(x)` | 
|`lb`| Column Vector of Doubles | The lower bounds for fluxes through the reactions. | `isnumeric(x)` | 
|`ub`| Column Vector of Doubles | The upper bounds for fluxes through the reactions. | `isnumeric(x)` | 
|`c`| Column Vector of Doubles  | The objective coefficient of the reactions. | `isnumeric(x)` | 
|`osense`| Double  | The objective sense either -1 for maximisation or 1 for minimisation | `isnumeric(x)` | 
|`rxns`| Column Cell Array of Strings  | Identifiers for the reactions. | `iscell(x) && ~any(cellfun(@isempty, x)) && all(cellfun(@(y) ischar(y) , x))` | 
|`mets`| Column Cell Array of Strings  | Identifiers of the metabolites | `iscell(x) && ~any(cellfun(@isempty, x)) && all(cellfun(@(y) ischar(y) , x))` | 
|`genes`|  Column Cell Array of Strings | Identifiers of the genes in the model | `iscell(x) && ~any(cellfun(@isempty, x)) && all(cellfun(@(y) ischar(y) , x))` | 
|`rules`| Column Cell Array of Strings | GPR rules in evaluateable format for each reaction ( e.g. "x(1) &#124; x(2) & x(3)", would indicate the first gene or the second and third gene from genes) | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
### Optional Fields
Optional Fields are fields which are required by some functions (if not present, the function will report a corresponding message).

| `Field Name` | Field Type | Field Description | Verification | 
|---|---|---|---|
|`metCharges`| Column Vector of Double | The charge of the respective metabolite (NaN if unknown) | `isnumeric(x)` | 
|`metFormulas`| Column Cell Array of Strings | Elemental formula for each metabolite | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`metSmiles`| Column Cell Array of Strings | Formula for each metabolite in SMILES Format | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`metNames`| Column Cell Array of Strings | Full name of each corresponding metabolite | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`metNotes`| Column Cell Array of Strings | Description of each corresponding metabolite | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`metHMDBID`| Column Cell Array of Strings | HMDBID of each corresponding metabolite | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`metInChIString`| Column Cell Array of Strings | InChI string of each corresponding metabolite | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`metKEGGID`| Column Cell Array of Strings | KEGG id of each corresponding metabolite | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`description`| String or Struct | Name of a file the model is loaded from | `ischar(x) || isstruct(x)` | 
|`modelVersion`|  Struct | Model Version/History | `isstruct(x)` | 
|`geneNames`| Column Cell Array of Strings | Full name of each corresponding gene | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`grRules`| Column Cell Array of Strings | A string representation of the GPR rules defined in rules | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`rxnGeneMat`| Sparse or Full Matrix of Double or Boolean | A matrix that is 1 at position i,j if reaction i is associated with gene j | `issparse(x) || isnumeric(x) || islogical(x)` | 
|`rxnConfidenceScores`| Column Vector of double | Confidence scores for reaction presence (0-4, with 4 being the highest confidence) | `isnumeric(x)` | 
|`rxnNames`| Column Cell Array of Strings | Full name of each corresponding reaction | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`rxnNotes`| Column Cell Array of Strings | Description of each corresponding reaction | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`rxnECNumbers`| Column Cell Array of Strings | EC Number of each corresponding reaction | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`rxnKEGGID`| Column Cell Array of Strings | KEGG ID of each corresponding reaction | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`subSystems`| Column Cell Array of Strings | subSystem assignment for each reaction | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`compNames`|  Column Cell Array of Strings | Full names of the compartments | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`comps`| Column Cell Array of Strings | Identifiers of the compartments used in the metabolite names | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`proteinNames`| Column Cell Array of Strings | Full name of each corresponding protein | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
|`proteins`| Column Cell Array of Strings | ID for each protein | `iscell(x) && all(cellfun(@(y) ischar(y) , x))` | 
### Model Specific Fields
Some models might contain additional model specific fields that are not defined COBRA model fields. These fields will commonly not be considered by COBRA toolbox methods, and using toolbox methods can render these fields inconsistent (e.g. if the number of reactions changes, a model specific field linked to reactions might have the wrong number of entries or the values might no longer correspond to the correct indices). 

### Field Support
All optional and all required fields are supported by all COBRA Toolbox functions. Using COBRA Toolbox Functions will not make a model inconsistent, but manual modifications of fields might lead to an inconsistent model.
Use verifyModel(model) to determine, if the model is a valid COBRA Toolbox model.

### Additional fields (future development)
Fields starting with met, rxn, comp or gene that are not defined above, will be assumed to be annotation fields, and IO methods will try to map them to identifiers.org registered databases.