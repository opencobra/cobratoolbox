Output of the function "transformFullXML2Map"

To be able to modify maps containg Protein-Protein Interactions (PPI)
created in CellDesigner from MATLAB, they have to be first parsed using the
function "transformFullXML2Map".
This function will then extract the relevant annotations from the XML file
and create a particular structure containg these annotations, that would
be later modified using various functions from the COBRA Toolbox.
Using this function, the MATLAB structure contains the following fields:

1. Molecules information (specific to each node in the map)
   - molAlias:                Alias of each molecules (no duplicates)
   - molID:                   ID of each molecules (duplicates)
   - molCompartAlias:         Corresponding compartment alias of each
                              molecules (EMPTY if no info)
   - molXPos:                 X position of each molecules (stored as
                              string but can be changed to double)
   - molYPos:                 Y position of each molecules (stored as
                              string but can be changed to double)
   - molWidth:                Width of each molecules (stored as string
                              but can be changed to double)
   - molHeight:               Height of each molecules (stored as string
                              but can be changed to double)
   - molColor:                Color of each molecules (in "HTML" code
                              with lowercases and "ff" in stead of "#' at
                              the beginning)

2. Complexes info (specific to each entity in the map)
   - cplxAlias:               Alias of each complex (no duplicates)
   - cplxID:                  ID of each complex (duplicates)
   - cplxCompartAlias:        Corresponding compartment alias of each
                              complex (EMPTY if no info)
   - cplxXPos:                X position of each complex (stored as
                              string but can be changed to double)
   - cplxYPos:                Y position of each complex (stored as
                              string but can be changed to double)
   - cplxWidth:               Width of each complex (stored as string
                              but can be changed to double)
   - cplxHeight:              Height of each complex (stored as string
                              but can be changed to double)
   - cplxColor:               Color of each complex (in "HTML" code with
                              lowercases and "ff" instead of "#' at
                              the beginning)

3. Included Species info (specific to each entity in the map)
   - specIncID:               ID of each included species (no duplicates)
   - specIncProtID:           Protein ID reference of each included
                              species
   - specIncCplxID:           Complex ID reference of each included
                              species
   - specIncName:             Name of each included species
   - specIncType:             Type of each species
                              (SIMPLE_MOLECULE/ION/PROTEIN...)
   - specIncNotes:            Notes of each included species
                              (EMPTY if no info)

4. Species info (specific to each entity in the map)
   - specID:                  ID of each species (no duplicates)
   - specMetaID:              MetaID of each species often related to
                              ID (no ducplicates)
   - specName:                Name of each species
   - specType:                Type of each species
                              (SIMPLE_MOLECULE/ION/PROTEIN...)
   - specNotes:               Notes of reach species (EMPTY if no info)

5. Reactions info (with their corresponding modifications)
   - rxnID:                   ID of each reactions (no duplicates)
   - rxnMetaID:               MetaID of each reactions
   - rxnName:                 Name of each reactions
   - rxnType:                 Type of each reactions
   - rxnReversibility:        Reversibility of each reactions (false or
                              true)
   - rxnBaseReactantAlias:    Alias of the base reactant(s)
   - rxnBaseReactantID:       ID of the base reactant(s)
   - rxnBaseProductAlias:     Alias of the base product(s)
   - rxnBaseProductID:        ID of the base product(s)
   - rxnReactantAlias:        Alias of reactant(s) (EMPTY if not present)
   - rxnReactantID:           ID of reactant(s) (EMPTY if not present)
   - rxnReactantLineType:     Type of the reactant's reaction line
                              ('Curve' or 'Straight')
   - rxnReactantLineColor:    Color of the reactant's reaction line
                              (in "HTML" code with lowercases and "ff"
                              instead of "#' at the beginning)
   - rxnReactantLineWidth:    Width of the reactant's reaction line
   - rxnProductAlias:         Alias of product(s) (EMPTY if not present)
   - rxnProductID:            ID of product(s) (EMPTY if not present)
   - rxnProductLineType:      Type of the product's reaction line
                              ('Curve' or 'Straight')
   - rxnProductLineColor:     Color of the product's reaction line
                              (in "HTML" code with lowercases and "ff"
                              instead of "#' at the beginning)
   - rxnProductLineWidth:     Width of the product's reaction line
   - rxnModAlias:             Alias of modifiers metabolites of each
                              reactions
   - rxnModID:                ID of modifiers metabolites of each
                              reactions
   - rxnModType:              Type of the modification by the metabolite
                              of each reactions
   - rxnModColor:             Color of the modification line of each
                              reactions
   - rxnModWidth:             Width of the modification line of each
                              reactions
   - rxnColor:                Color of the main reaction (in "HTML" code
                              with lowercases and "ff" in stead of "#' at
                              the beginning) => later modified for the
                              whole reaction's members
   - rxnWidth:                Width of the main reaction (stored as
                              string but can be changed to double)
                              => later modified for the whole reaction's
                              members
   - rxnNotes:                Notes of each reactions (in the body of
                              HTML format?) (EMPTY if no info)

6. Compartment info (if existing in the map)
   - compartAlias:            Alias of each compartments
                              (EMPTY if no info)
   - compartName:             Name of each compartments
                              (EMPTY if no info)

7. Matrices (specific for the map and comparable with the model)

    Attention: this functionality is disabled for the moment. To be
    structured as the model and be comparable, the access to entities
    has to be adapted...


   - sID:                     Logical matrix with rows=speciesID and
                              columns=reactionsID
   - sAlias:                  Logical matrix with rows=speciesAlias and
                              columns=reactionsID
   - isAlias:                 Logical matrix widh rows=speciesID and
                              columns=speciesAlias
