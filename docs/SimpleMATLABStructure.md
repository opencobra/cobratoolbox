Output of the function "transformXML2Map"

To be able to modify metabolic maps created in CellDesigner from MATLAB,
they have to be first parsed using the function "transformXML2Map".
This function will then extract the relevant annotations from the XML file
and create a particular structure containg these annotations, that would
be later modified using various functions from the COBRA Toolbox.
Using this function, the MATLAB structure contains the following fields:

Molecules information (specific to each node in the map)

- molAlias:               Alias of each molecules (no duplicates)

- molID:                  ID of each molecules (duplicates)

- molCompartAlias:        Corresponding compartment alias of each
                          molecules (EMPTY if no info)

- molXPos:                X position of each molecules (stored as
                          string but can be changed to double)

- molYPos:                Y position of each molecules (stored as
                          string but can be changed to double)

- molWidth:               Width of each molecules (stored as string
                          but can be changed to double)

- molHeight:              Height of each molecules (stored as string
                          but can be changed to double)

- molColor:               Color of each molecules (in "HTML" code
                          with lowercases and "ff" in stead of "#' at
                          the beginning)

Species info (specific to each entity in the map)

- specID:                 ID of each species (no duplicates)

- specMetaID:             MetaID of each species often related to
                          ID (no ducplicates)

- specType:               Type of each species
                          (SIMPLE_MOLECULE/ION/PROTEIN...)

- specNotes:              Notes of reach species (in the body of HTML
                          format?) (EMPTY if no info)

Reactions info (with their corresponding modifications)

- rxnID:                  ID of each reactions (no duplicates)

- rxnMetaID:              MetaID of each reactions

- rxnName:                Name of each reactions

- rxnType:                Type of each reactions

- rxnReversibility:       Reversibility of each reactions (false or
                          true)

- rxnBaseReactantAlias:   Alias of the base reactant(s)

- rxnBaseReactantID:      ID of the base reactant(s)

- rxnBaseProductAlias:    Alias of the base product(s)

- rxnBaseProductID:       ID of the base product(s)

- rxnReactantAlias:       Alias of reactant(s) (EMPTY if not present)

- rxnReactantID:          ID of reactant(s) (EMPTY if not present)

- rxnProductAlias:        Alias of product(s) (EMPTY if not present)

- rxnProductID:           ID of product(s) (EMPTY if not present)

- rxnModAlias:            Alias of modifiers metabolites of each
                          reactions

- rxnModID:               ID of modifiers metabolites of each
                          reactions

- rxnModType:             Type of the modification by the metabolite
                          of each reactions

- rxnModColor:            Color of the modification line of each
                          reactions

- rxnModWidth:            Width of the modification line of each
                          reactions

- rxnColor:               Color of the main reaction (in "HTML" code
                          with lowercases and "ff" in stead of "#' at
                          the beginning) => later modified for the
                          whole reaction's members

- rxnWidth:               Width of the main reaction (stored as
                          string but can be changed to double)
                          => later modified for the whole reaction's
                          members

	rxnNotes:               Notes of each reactions (in the body of
	                        HTML format?) (EMPTY if no info)

Compartment info (if existing in the map)

- compartAlias:           Alias of each compartments
                          (EMPTY if no info)
- compartName:            Name of each compartments
                          (EMPTY if no info)

Matrices (specific for the map and comparable with the model)

- S_ID:                   Logical matrix with rows=species_ID and
                          columns=reactions_ID
- S_alias:                Logical matrix with rows=species_Alias and
                          columns=reactions_ID
- ID_alias:               Logical matrix widh rows=species_ID and
                          columns=species_Alias
