# Output description of the function `transformXML2Map`

### Specifics

To be able to modify metabolic maps created in CellDesigner from MATLAB,
they have to be first parsed using the function "transformXML2Map".
A metabolic map contains only Simple molecules, such as Ions, Metabolites...
When manipulating maps with Protein-Protein Interactions, please refer to the
[`transformXML2Map` function's output description](fullMATLABStructure.md).

### Content

This function will extract the relevant annotations from the XML file
and create a particular structure containg these annotations, that would
be later modified using various functions from the COBRA Toolbox.
Using this function, the MATLAB structure contains the following fields:

1.  Molecules information (specific to each node in the map)
2.  Species information (specific to each entity in the map)
3.  Reactions information (with their corresponding modifications)
4.  Compartment information (if existing in the map)
5.  Matrices (specific for the map and comparable with the model)


| **Field name** | **Dimension** | **Data Type** | **Field description** |
|:---:|:---:|:---:|:---:|
| **Molecules information** |
| `map.molAlias` | `a x 1` | cell of char | Alias of each molecules (no duplicates) |
| `map.molID` | `a x 1` | cell of char | ID of each molecules (duplicates) |
| `map.molCompartAlias` | `a x 1` | cell of char | Corresponding compartment alias of each molecules (EMPTY if no info) |
| `map.molXPos` | `a x 1` | cell of char or double | X position of each molecules (stored as string but can be changed to double) |
| `map.molYPos` | `a x 1` | cell of char or double | Y position of each molecules (stored as string but can be changed to double) |
| `map.molWidth` | `a x 1` | cell of char or double | Width of each molecules (stored as string but can be changed to double) |
| `map.molHeight` | `a x 1` | cell of char or double | Height of each molecules (stored as string but can be changed to double) |
| `map.molColor` | `a x 1` | cell of char | Color of each molecules (in "HTML" code with lowercases and "ff" instead of "#' at the beginning) |
| **Species information** |
| `map.specID` | `s x 1` | cell of char | ID of each species (no duplicates) |
| `map.specMetaID` | `s x 1` | cell of char | MetaID of each species often related to ID (no ducplicates) |
| `map.specName` | `s x 1` | cell of char | Name of each species |
| `map.specType` | `s x 1` | cell of char | Type of each species (SIMPLE_MOLECULE/ION/PROTEIN...) |
| `map.specNotes` | `s x 1` | cell of char | Notes of each species (EMPTY if no info) |
| **Reactions information** |
| `map.rxnID` | `r x 1` | cell of char | ID of each reactions (no duplicates) |
| `map.rxnMetaID` | `r x 1` | cell of char | MetaID of each reactions |
| `map.rxnName` | `r x 1` | cell of char | Name of each reactions |
| `map.rxnType` | `r x 1` | cell of char | Type of each reactions |
| `map.rxnReversibility` | `r x 1` | cell of char | Reversibility of each reactions (false or true) |
| `map.rxnBaseReactantAlias` | `r x p x 1` | cell of cell of char | Alias of the base reactant(s) |
| `map.rxnBaseReactantID` | `r x p x 1` | cell of cell of char | ID of the base reactant(s) |
| `map.rxnBaseProductAlias` | `r x p x 1` | cell of cell of char | Alias of the base product(s) |
| `map.rxnBaseProductID` | `r x p x 1` | cell of cell of char | ID of the base product(s) |
| `map.rxnReactantAlias` | `r x p x 1` | cell of cell of char | Alias of reactant(s) (EMPTY if not present) |
| `map.rxnReactantID` | `r x p x 1` | cell of cell of char | ID of reactant(s) (EMPTY if not present) |
| `map.rxnReactantLineType` | `r x p x 1` | cell of cell of char | Type of the reactant's reaction line ('Curve' or 'Straight') |
| `map.rxnReactantLineColor` | `r x p x 1` | cell of cell of char | Color of the reactant's reaction line (in "HTML" code with lowercases and "ff" instead of "#' at the beginning) |
| `map.rxnReactantLineWidth` | `r x p x 1` | cell of cell of char or double | Width of the reactant's reaction line |
| `map.rxnProductAlias` | `r x p x 1` | cell of cell of char | Alias of product(s) (EMPTY if not present) |
| `map.rxnProductID` | `r x p x 1` | cell of cell of char | ID of product(s) (EMPTY if not present) |
| `map.rxnProductLineType` | `r x p x 1` | cell of cell of char | Type of the product's reaction line ('Curve' or 'Straight') |
| `map.rxnProductLineColor` | `r x p x 1` | cell of cell of char | Color of the product's reaction line (in "HTML" code with lowercases and "ff" instead of "#' at the beginning) |
| `map.rxnProductLineWidth` | `r x p x 1` | cell of cell of char or double | Width of the product's reaction line |
| `map.rxnModAlias` | `r x p x 1` | cell of cell of char | Alias of modifiers metabolites of each reactions |
| `map.rxnModID` | `r x p x 1` | cell of cell of char | ID of modifiers metabolites of each reactions |
| `map.rxnModType` | `r x p x 1` | cell of cell of char | Type of the modification by the metabolite of each reactions |
| `map.rxnModColor` | `r x p x 1` | cell of cell of char | Color of the modification line of each reactions |
| `map.rxnModWidth` | `r x p x 1` | cell of cell of char or double | Width of the modification line of each reactions |
| `map.rxnColor` | `r x 1` | cell of char | Color of the main reaction (in "HTML" code with lowercases and "ff" instead of "#' at the beginning) => later modified for the whole reaction's members |
| `map.rxnWidth` | `r x 1` | cell of char | Width of the main reaction (stored as string but can be changed to double) => later modified for the whole reaction's members |
| `map.rxnNotes` | `r x 1` | cell of char | Notes of each reactions (EMPTY if no info) |
| **Compartment information** |
| `map.compartAlias` | `c x 1` | cell of char | Alias of each compartments (EMPTY if no info) |
| `map.compartName` | `c x 1` | cell of char | Name of each compartments (EMPTY if no info) |
| **Matrices** |
| `map.sID` | `s x r` | logical | Logical matrix with rows = speciesID and columns = reactionsID |
| `map.sAlias` | `m x r` | logical | Logical matrix with rows = speciesAlias and columns = reactionsID |
| `map.idAlias` | `s x m` | logical | Logical matrix widh rows = speciesID and columns = speciesAlias |

*** Note:

The dimension `p` is variable between reactions as each reaction can contain one
or more Base Reactants or Products and the same is possible for Reactants,
Products and Modifiers. Therefore, this value is not static and varies in all
reactions.
