# Format of Excel Models readable by the COBRA Toolbox

Excel sheets accepted by the COBRA Toolbox contains exactly two sheets with the following names: 
- Reaction List
- Metabolite List


The first line of those sheets defines the headers for each column. 
The order of these headers is free, but they will be used to determine the respective column.
There are required and optional headers for a model in excel format as detailed below, and 
an example File with the full format is provided in [ExcelExample.xlsx](../examples/ExcelExample.xlsx)

### The `Reaction List` Sheet
#### Required Headers:

| Header Name | Description | Example | 
| --- | --- | --- | 
| `Abbreviation` | An abbreviation of the reaction (will be used as ID) | HEX1 | 
| `Reaction` | The written out reaction | 1 atp[c] + 1 glc-D[c] -> 1 adp[c] + 1 g6p[c] + 1 h[c] |

#### Optional Headers:
| Header Name | Description | Example | 
| --- | --- | --- | 
| `GPR` | The Gene Protein Reaction association in String format with Gene Names, parenthesis will be stripped | (3098.3) or (80201.1) and (2645.3) |
| `Lower bound` | The lower bound of a reaction, will be used to determine reversibility. If not present a default of -1000 is assumed | `0` |
| `Upper bound` | The upper bound of a reaction. If not present a default of 1000 is assumed | `1000` |
| `Objective` | The objective coefficient, if not at least providing one non zero entry, a call to `changeObjective()` will be required before the model can be optimized. assumed default value: 0 | `1`|
| `Confidence Score` | The confidence score (from 0 to 4 with 4 being the highest confidence), assumed default for empty cells: 0 | `One of 0,1,2,3,4`
| `Subsystem` | The subsystem the reaction belongs to | `Glycolysis`
| `Description` | A description of the reaction (will be stored in rxnNames) | `Hexokinase`
| `Notes` | Additional notes for the reaction | `Reaction also associated with EC 2.7.1.2` 
| `EC Number` | The EC number of the reaction | `2.7.1.1,2.7.1.2`
| `References` | Pubmed References in PMID:12345679 format, if multiple PMIDs are provided, they have to be separated by ; | `PMID:2043117,PMID:7150652`
| `KEGG ID` | KEGG ID of the Reaction | `R00001`

### The `Metabolite List` Sheet
#### Required Fields
| Header Name | Description | Example | 
| --- | --- | --- | 
|`Abbreviation` | The Identifier which will be stored in model.mets. A compartment can be added by []. If the optional compartment header is not provided, the following assumption is made: `c: cytosol; e: extracellular; m: mitochondria; n: nucleus; r: endoplasmatic reticulum; x: peroxisome; l: lysosome; g: golgi aparatus`. If no Compartment header is provided and the identifier is not matched, the compound is assumed to be in the cytosol. Metabolites present in multiple compartments must be provided multiple times, each time with the corresponding compartment identifier. | `glc-D` or `glc-D[c]` |

### Optional Fields
| Header Name | Description | Example | 
| --- | --- | --- | 
| `Charged formula` or `Formula` | The Formula with the correct protonation state as indicated by the given charge, if both `Charged formula` and `Formula` are present `Formula` takes precedence. | `C6H12O6`
| `Charge` | The charge of the metabolite | `0`
| `Description` | A human readable name for the metabolite | `D-glucose`
| `Compartment` | The compartment the metabolite is located in. If this is not provided, or empty, the above assumptions are made with respect to localisation. | `cytosol`
| `KEGG ID` | The KEGG id of the compound| `C00031`
| `PubChem ID` | The PubChem ID of the compound | `5793`
| `ChEBI ID` | The CHEBI (IDs) of the compound, multiple IDs are to be separated by ; | `4167` |
| `InChI string` | The Inchi String identifying the metabolite | `InChI=1S/p+1/i/hH` |
| `SMILES` | The SMILES string representing the metabolite formula | `OC[C@H]1OC(O)[C@H](O)[C@@H](O)[C@@H]1O` |
| `HMDB ID` | The HMDB ID of the metabolite | `HMDB00122` |
