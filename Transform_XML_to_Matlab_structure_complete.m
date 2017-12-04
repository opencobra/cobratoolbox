function [XML_object, map] = Transform_XML_to_Matlab_structure_complete(Filename_in)

    % Create a matlab structure from a given XML file in using SBML_L2_V4.
    % The XML file is first parsed through the "xml2struct" function and
    % then transformed into a structure containing the following fields:
    %
    %%% Molecules information (specific to each node in the map)
    %
    %   molAlias:               Alias of each molecules (no duplicates)
    %
    %   molID:                  ID of each molecules (duplicates)
    %
    %   molCompartAlias:        Corresponding compartment alias of each
    %                           molecules (EMPTY if no info)
    %
    %   molXPos:                X position of each molecules (stored as
    %                           string but can be changed to double)
    %
    %   molYPos:                Y position of each molecules (stored as
    %                           string but can be changed to double)
    %
    %   molWidth:               Width of each molecules (stored as string
    %                           but can be changed to double)
    %
    %   molHeight:              Height of each molecules (stored as string
    %                           but can be changed to double)
    %
    %   molColor:               Color of each molecules (in "HTML" code
    %                           with lowercases and "ff" in stead of "#' at
    %                           the beginning)
    %
    %%% Complexes info (specific to each entity in the map)
    %
    %   cplxAlias:              Alias of each complex (no duplicates)
    %
    %   cplxID:                 ID of each complex (duplicates)
    %
    %   cplxCompartAlias:       Corresponding compartment alias of each
    %                           complex (EMPTY if no info)
    %
    %   cplxXPos:               X position of each complex (stored as
    %                           string but can be changed to double)
    %
    %   cplxYPos:               Y position of each complex (stored as
    %                           string but can be changed to double)
    %
    %   cplxWidth:              Width of each complex (stored as string
    %                           but can be changed to double)
    %
    %   cplxHeight:             Height of each complex (stored as string
    %                           but can be changed to double)
    %
    %   cplxColor:              Color of each complex (in "HTML" code with
    %                           lowercases and "ff" instead of "#' at
    %                           the beginning)
    %
    %%% Included Species info (specific to each entity in the map)
    %
    %   specIncID:              ID of each included species (no duplicates)
    %
    %   specIncProtID:          Protein ID reference of each included
    %                           species
    %
    %   specIncCplxID:          Complex ID reference of each included
    %                           species
    %
    %   specIncName:            Name of each included species
    %
    %   specIncType:            Type of each species
    %                           (SIMPLE_MOLECULE/ION/PROTEIN...)
    %
    %   specIncNotes:           Notes of each included species
    %                           (EMPTY if no info)
    %
    %%% Species info (specific to each entity in the map)
    %
    %   specID:                 ID of each species (no duplicates)
    %
    %   specMetaID:             MetaID of each species often related to
    %                           ID (no ducplicates)
    %
    %   specName:               Name of each species
    %
    %   specType:               Type of each species
    %                           (SIMPLE_MOLECULE/ION/PROTEIN...)
    %
    %   specNotes:              Notes of reach species (EMPTY if no info)
    %
    %%% Reactions info (with their corresponding modifications)
    %
    %   rxnID:                  ID of each reactions (no duplicates)
    %
    %   rxnMetaID:              MetaID of each reactions
    %
    %   rxnName:                Name of each reactions
    %
    %   rxnType:                Type of each reactions
    %
    %   rxnReversibility:       Reversibility of each reactions (false or
    %                           true)
    %
    %   rxnBaseReactantAlias:   Alias of the base reactant(s)
    %
    %   rxnBaseReactantID:      ID of the base reactant(s)
    %
    %   rxnBaseProductAlias:    Alias of the base product(s)
    %
    %   rxnBaseProductID:       ID of the base product(s)
    %
    %   rxnReactantAlias:       Alias of reactant(s) (EMPTY if not present)
    %
    %   rxnReactantID:          ID of reactant(s) (EMPTY if not present)
    %
    %   rxnReactantLineType:    Type of the reactant's reaction line
    %                           ('Curve' or 'Straight')
    %
    %   rxnReactantLineColor:   Color of the reactant's reaction line
    %                           (in "HTML" code with lowercases and "ff"
    %                           instead of "#' at the beginning)
    %
    %   rxnReactantLineWidth:   Width of the reactant's reaction line
    %
    %   rxnProductAlias:        Alias of product(s) (EMPTY if not present)
    %
    %   rxnProductID:           ID of product(s) (EMPTY if not present)
    %
    %   rxnProductLineType:     Type of the product's reaction line
    %                           ('Curve' or 'Straight')
    %
    %   rxnProductLineColor:    Color of the product's reaction line
    %                           (in "HTML" code with lowercases and "ff"
    %                           instead of "#' at the beginning)
    %
    %   rxnProductLineWidth:    Width of the product's reaction line
    %
    %   rxnModAlias:            Alias of modifiers metabolites of each
    %                           reactions
    %
    %   rxnModID:               ID of modifiers metabolites of each
    %                           reactions
    %
    %   rxnModType:             Type of the modification by the metabolite
    %                           of each reactions
    %
    %   rxnModColor:            Color of the modification line of each
    %                           reactions
    %
    %   rxnModWidth:            Width of the modification line of each
    %                           reactions
    %
    %   rxnColor:               Color of the main reaction (in "HTML" code
    %                           with lowercases and "ff" in stead of "#' at
    %                           the beginning) => later modified for the
    %                           whole reaction's members
    %
    %   rxnWidth:               Width of the main reaction (stored as
    %                           string but can be changed to double)
    %                           => later modified for the whole reaction's
    %                           members
    %
    %   rxnNotes:               Notes of each reactions (in the body of
    %                           HTML format?) (EMPTY if no info)
    %
    %%% Compartment info (if existing in the map)
    %
    %   compartAlias:           Alias of each compartments
    %                           (EMPTY if no info)
    %   compartName:            Name of each compartments
    %                           (EMPTY if no info)
    %
    %%% Matrices (specific for the map and comparable with the model)
    %
    %   Attention: this functionality is disabled for the moment. To be
    %   structued as the model and be comparable, the access to entities
    %   has to be adapted...
    %
    %
    %   S_ID:                   Logical matrix with rows=species_ID and
    %                           columns=reactions_ID
    %   S_alias:                Logical matrix with rows=species_Alias and
    %                           columns=reactions_ID
    %   ID_alias:               Logical matrix widh rows=species_ID and
    %                           columns=species_Alias
    %
    % INPUTS:
    %
    %   Filename_in:    Path to the XML file.
    % 
    % OPTIONAL INPUTS:
    %
    %   No optional inputs.
    %
    % OUTPUTS:
    %
    %   XML_object:     Structure obtained from the "xml2struct" function.
    %                   To be kept for the conversion back to an XML file
    %                   of the structure.
    %
    %   map:            Matlab structure of the map containing all the
    %                   relevant fields usable for checking and correction.
    %
    % .. Author: N.Sompairac - Institut Curie, Paris, 24/07/2017
    
    tic

    %%% Works nicely but has a huge tree structured
    XML_object = xml2struct(Filename_in);

    %%% Loop over molecules to get the needed information and store it in a
    %%% structure. Molecules refer to each individual node.
    for mol = 1:length(XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias)

        map.molAlias{mol,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.Attributes.id;
        map.molID{mol,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.Attributes.species;

        %%% Check if the info on compartment exists
        if any(strcmp('compartmentAlias',fieldnames(XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.Attributes)))
            map.molCompartAlias{mol,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.Attributes.compartmentAlias;
        else
            map.molCompartAlias{mol,1} = '';
        end

        map.molXPos{mol,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.x;
        map.molYPos{mol,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.y;

        map.molWidth{mol,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.w;
        map.molHeight{mol,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.h;

        map.molColor{mol,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_usualView.celldesigner_colon_paint.Attributes.color;

    end
    clearvars mol

    %%% Loop over species to get the needed information and store it in a
    %%% structure. Species refer to each individual name.
    for spec = 1:length(XML_object.sbml.model.listOfSpecies.species)

        map.specID{spec,1} = XML_object.sbml.model.listOfSpecies.species{spec}.Attributes.id;
        map.specMetaID{spec,1} = XML_object.sbml.model.listOfSpecies.species{spec}.Attributes.metaid;
        map.specName{spec,1} = XML_object.sbml.model.listOfSpecies.species{spec}.Attributes.name;

        map.specType{spec,1} = XML_object.sbml.model.listOfSpecies.species{spec}.annotation.celldesigner_colon_extension.celldesigner_colon_speciesIdentity.celldesigner_colon_class.Text;

        %%% Check if the info on notes exists for the species
        if any(strcmp('notes',fieldnames(XML_object.sbml.model.listOfSpecies.species{spec})))
            
            if any(strcmp('Text',fieldnames(XML_object.sbml.model.listOfSpecies.species{spec}.notes.html.body)))
            
                map.specNotes{spec,1} = XML_object.sbml.model.listOfSpecies.species{spec}.notes.html.body.Text;
                
            else

                map.specNotes{spec,1} = '';
                
            end

        else

            map.specNotes{spec,1} = '';

        end

    end
    clearvars spec
        
    %%% Test if complexes exist in the map
    if any(strcmp('celldesigner_colon_complexSpeciesAlias',fieldnames(XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases)))
    
        %%% Loop over complexes to get the need information and store it in a
        %%% structure. Complexes refer to each individual complex name.
        for complex = 1:(length(XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias))
            
            map.cplxAlias{complex,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{complex}.Attributes.id;
            map.cplxID{complex,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{complex}.Attributes.species;
            
            % Test if info on compartment exists
            if any(strcmp('compartmentAlias',fieldnames(XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{complex}.Attributes)))
                
                map.cplxCompartAlias{complex,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{complex}.Attributes.compartmentAlias;
                
            else
                
                map.cplxCompartAlias{complex,1} = '';
                
            end
            
            map.cplxXPos{complex,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{complex}.celldesigner_colon_bounds.Attributes.x;
            map.cplxYPos{complex,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{complex}.celldesigner_colon_bounds.Attributes.y;
            map.cplxWidth{complex,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{complex}.celldesigner_colon_bounds.Attributes.w;
            map.cplxHeight{complex,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{complex}.celldesigner_colon_bounds.Attributes.h;
            
            map.cplxColor{complex,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{complex}.celldesigner_colon_usualView.celldesigner_colon_paint.Attributes.color;
            
        end
        
    else
        
        map.cplxAlias = '';
        map.cplxID = '';
        map.cplxCompartAlias = '';
        map.cplxXPos = '';
        map.cplxYPos = '';
        map.cplxWidth = '';
        map.cplxHeight = '';
        map.cplxColor = '';
        
    end
    
    %%% Test if included species exist in the map
    if any(strcmp('celldesigner_colon_listOfIncludedSpecies',fieldnames(XML_object.sbml.model.annotation.celldesigner_colon_extension)))
        
        %%% Loop over included species to get the need information and
        %%% store it in a structure. Included species refer to each
        %%% individual species included inside a complex.
        for included = 1:length(XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfIncludedSpecies.celldesigner_colon_species)
            
            map.specIncID{included,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfIncludedSpecies.celldesigner_colon_species{included}.Attributes.id;
            map.specIncName{included,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfIncludedSpecies.celldesigner_colon_species{included}.Attributes.name;
            
            map.specIncCplxID{included,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfIncludedSpecies.celldesigner_colon_species{included}.celldesigner_colon_annotation.celldesigner_colon_complexSpecies.Text;
            
            map.specIncType{included,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfIncludedSpecies.celldesigner_colon_species{included}.celldesigner_colon_annotation.celldesigner_colon_speciesIdentity.celldesigner_colon_class.Text;
            
            % Test if there are notes for the included species
            if any(strcmp('celldesigner_colon_notes',fieldnames(XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfIncludedSpecies.celldesigner_colon_species{included})))
            
                map.specIncNotes{included,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfIncludedSpecies.celldesigner_colon_species{included}.celldesigner_colon_notes.html.body.Text;
            
            else
                
                map.specIncNotes{included,1} = '';
                
            end
            
        end
        
    else
        
        map.specIncID = '';
        map.specIncName = '';
        map.specIncCplxID = '';
        map.specIncType = '';
        map.specIncNotes = '';
        
    end
    
    %%% Loop over reactions to get the need information and store it in a
    %%% structure. Reactions refer to each individual reaction name.
    for react = 1:length(XML_object.sbml.model.listOfReactions.reaction)
        
        %%% Test if the reaction has an ID
        if any(strcmp('id',fieldnames(XML_object.sbml.model.listOfReactions.reaction{react}.Attributes)))

            map.rxnID{react,1} = XML_object.sbml.model.listOfReactions.reaction{react}.Attributes.id;

        else

            map.rxnID{react,1} = '';

        end

        map.rxnMetaID{react,1} = XML_object.sbml.model.listOfReactions.reaction{react}.Attributes.metaid;

        %%% Test if the reaction has a Name
        if any(strcmp('name',fieldnames(XML_object.sbml.model.listOfReactions.reaction{react}.Attributes)))

            map.rxnName{react,1} = XML_object.sbml.model.listOfReactions.reaction{react}.Attributes.name;

        else

            map.rxnName{react,1} = '';

        end

        map.rxnType{react,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_reactionType.Text;

        %%% Check if info on reversibility exists
        if any(strcmp('reversible',fieldnames(XML_object.sbml.model.listOfReactions.reaction{react}.Attributes)))

            map.rxnReversibility{react,1} = XML_object.sbml.model.listOfReactions.reaction{react}.Attributes.reversible;

        else

            map.rxnReversibility{react,1} = 'true';

        end


        map.rxnBaseReactantAlias{react,1} = {};
        map.rxnBaseReactantID{react,1} = {};

        %%% Test if there is only 1 base reactant
        if length(XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant) == 1

            map.rxnBaseReactantAlias{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant.Attributes.alias;
            map.rxnBaseReactantID{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant.Attributes.species;

        else

            %%% Looping over the multiple base reactants
            for base = 1:length(XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant)

                map.rxnBaseReactantAlias{react,1}{base,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant{base}.Attributes.alias;
                map.rxnBaseReactantID{react,1}{base,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant{base}.Attributes.species;

            end
            clearvars base

        end

        map.rxnBaseProductAlias{react,1} = {};
        map.rxnBaseProductID{react,1} = {};

        %%% Test if there is only 1 base product
        if length(XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct) == 1

            map.rxnBaseProductAlias{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct.Attributes.alias;
            map.rxnBaseProductID{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct.Attributes.species;

        else

            %%% Looping over the multiple base products
            for base = 1:length(XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct)

                map.rxnBaseProductAlias{react,1}{base,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct{base}.Attributes.alias;
                map.rxnBaseProductID{react,1}{base,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct{base}.Attributes.species;

            end
            clearvars base

        end

        %%% Test if there are some reactants in the reaction
        if any(strcmp('celldesigner_colon_listOfReactantLinks',fieldnames(XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension))) ...
            && any(strcmp('celldesigner_colon_reactantLink',fieldnames(XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks)))

            map.rxnReactantAlias{react,1} = {};
            map.rxnReactantID{react,1} = {};

            %%% Test if there is only 1 reactant
            if length(XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink) == 1

                map.rxnReactantAlias{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink(1).Attributes.alias;
                map.rxnReactantID{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink(1).Attributes.reactant;
                
                map.rxnReactantLineType{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink(1).celldesigner_colon_line.Attributes.type;
                map.rxnReactantLineColor{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink(1).celldesigner_colon_line.Attributes.color;
                map.rxnReactantLineWidth{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink(1).celldesigner_colon_line.Attributes.width;
                
            else

                for x = 1:length(XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink)

                    map.rxnReactantAlias{react,1}{x,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.Attributes.alias;
                    map.rxnReactantID{react,1}{x,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.Attributes.reactant;
                    
                    map.rxnReactantLineType{react,1}{x,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.celldesigner_colon_line.Attributes.type;
                    map.rxnReactantLineColor{react,1}{x,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.celldesigner_colon_line.Attributes.color;
                    map.rxnReactantLineWidth{react,1}{x,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.celldesigner_colon_line.Attributes.width;
                
                end
                clearvars x

            end

        else

            map.rxnReactantAlias{react,1} = '';
            map.rxnReactantID{react,1} = '';
            
            map.rxnReactantLineType{react,1} = '';
            map.rxnReactantLineColor{react,1} = '';
            map.rxnReactantLineWidth{react,1} = '';

        end

        %%% Test if there are some products in the reaction
        if any(strcmp('celldesigner_colon_listOfProductLinks',fieldnames(XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension))) ...
            && any(strcmp('celldesigner_colon_productLink',fieldnames(XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks)))

            map.rxnProductAlias{react,1} = {};
            map.rxnProductID{react,1} = {};

            %%% Test if there is only 1 product
            if length(XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink) == 1

                map.rxnProductAlias{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink(1).Attributes.alias;
                map.rxnProductID{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink(1).Attributes.product;

                map.rxnProductLineType{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink(1).celldesigner_colon_line.Attributes.type;
                map.rxnProductLineColor{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink(1).celldesigner_colon_line.Attributes.color;
                map.rxnProductLineWidth{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink(1).celldesigner_colon_line.Attributes.width;
                
            else

                for x = 1:length(XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink)

                    map.rxnProductAlias{react,1}{x,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.Attributes.alias;
                    map.rxnProductID{react,1}{x,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.Attributes.product;
                    
                    map.rxnProductLineType{react,1}{x,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.celldesigner_colon_line.Attributes.type;
                    map.rxnProductLineColor{react,1}{x,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.celldesigner_colon_line.Attributes.color;
                    map.rxnProductLineWidth{react,1}{x,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.celldesigner_colon_line.Attributes.width;
                    
                end
                clearvars x

            end

        else

            map.rxnProductAlias{react,1} = '';
            map.rxnProductID{react,1} = '';
            
            map.rxnProductLineType{react,1} = '';
            map.rxnProductLineColor{react,1} = '';
            map.rxnProductLineWidth{react,1} = '';

        end

        %%% Check if there are modifications for the reaction
        if any(strcmp('listOfModifiers',fieldnames(XML_object.sbml.model.listOfReactions.reaction{react})))

            % Test if there is only one modification
            if length(XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification) == 1

                map.rxnModAlias{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).Attributes.aliases;
                map.rxnModID{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).Attributes.modifiers;
                map.rxnModType{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).Attributes.type;

                map.rxnModColor{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).celldesigner_colon_line.Attributes.color;
                map.rxnModWidth{react,1}{1,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).celldesigner_colon_line.Attributes.width;


            else
                % Loop over the possible modifications
                for mod = 1:length(XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification)

                    map.rxnModAlias{react,1}{mod,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{mod}.Attributes.aliases;
                    map.rxnModID{react,1}{mod,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{mod}.Attributes.modifiers;
                    map.rxnModType{react,1}{mod,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{mod}.Attributes.type;

                    map.rxnModColor{react,1}{mod,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{mod}.celldesigner_colon_line.Attributes.color;
                    map.rxnModWidth{react,1}{mod,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{mod}.celldesigner_colon_line.Attributes.width;

                end
                clearvars mod

            end

        else

            map.rxnModAlias{react,1} = '';
            map.rxnModID{react,1} = '';
            map.rxnModType{react,1} = '';
            map.rxnModColor{react,1} = '';
            map.rxnModWidth{react,1} = '';

        end

        map.rxnColor{react,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_line.Attributes.color;
        map.rxnWidth{react,1} = XML_object.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_line.Attributes.width;

        %%% Check if the info on notes exists for the reaction
        if any(strcmp('notes',fieldnames(XML_object.sbml.model.listOfReactions.reaction{react})))

            map.rxnNotes{react,1} = XML_object.sbml.model.listOfReactions.reaction{react}.notes.html.body.Text;

        else

            map.rxnNotes{react,1} = '';

        end


    end
    clearvars react


    %%% Check if there is any information on Compartments
    if any(strcmp('celldesigner_colon_compartmentAlias',fieldnames(XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases)))

        %%% Test is there is only 1 compartment
        if length(XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias) == 1

            map.compartAlias{1,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias(1).Attributes.id;
            map.compartName{1,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias(1).Attributes.compartment;

        else

            %%% Loop over compartments to get the need information and store it in a
            %%% structure. Compartments refer to each individual compartment name.
            for compart= 1:length(XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias)

                map.compartAlias{compart,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias{compart}.Attributes.id;
                map.compartName{compart,1} = XML_object.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias{compart}.Attributes.compartment;

            end
            clearvars compart

        end

    else
        
        map.compartAlias = '';
        
    end

    %%% Getting the matrices (stoechiometric and ID/Alias)
    %map = Get_map_matrices(map);

    toc

end