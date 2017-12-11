function transformFullMap2XML(xmlStruct, map, fileName)
% Creates a new XML file from the information contained in the map
% structure. Uses the function "struct2xml" to transform a matlab
% structure into an XML text format.
%
% USAGE:
%
%   transformFullMap2XML(xmlStruct, map, fileName)
%
% INPUTS:
%   xmlStruct:      XML structure obtained from the function
%                   "xml2struct". Used by the function "struct2xml"
%                   to obtain the XML file.
%   map:            Matlab structure of the map with the relevant
%                   information. This information is then transfered to
%                   the xmlStruct for the conversion.
%   fileName:       Path and name of the new XML file.
%
% .. Author: - N.Sompairac - Institut Curie, Paris, 24/07/2017

    tic

    % Loop over molecules to put the info back to the struct for XML
    % conversion
    for mol = 1:length(map.molAlias)
        xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.Attributes.id = map.molAlias{mol};
        xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.Attributes.species = map.molID{mol};
        % Check if the info on compartment exists
        if ~isempty(map.molCompartAlias{mol})
            xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.Attributes.compartmentAlias = map.molCompartAlias{mol};
        end
        xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.x = map.molXPos{mol};
        xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.y = map.molYPos{mol};
        xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.w = map.molWidth{mol};
        xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.h = map.molHeight{mol};
        xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_usualView.celldesigner_colon_paint.Attributes.color = map.molColor{mol};
    end
    clearvars mol

    % Loop over species to put the info back to the struct for XML
    % conversion
    for spec = 1:length(map.specID)
        xmlStruct.sbml.model.listOfSpecies.species{spec}.Attributes.id = map.specID{spec};
        xmlStruct.sbml.model.listOfSpecies.species{spec}.Attributes.metaid = map.specMetaID{spec};
        xmlStruct.sbml.model.listOfSpecies.species{spec}.Attributes.name = map.specName{spec};
        xmlStruct.sbml.model.listOfSpecies.species{spec}.annotation.celldesigner_colon_extension.celldesigner_colon_speciesIdentity.celldesigner_colon_name.Text = map.specName{spec};
        xmlStruct.sbml.model.listOfSpecies.species{spec}.annotation.celldesigner_colon_extension.celldesigner_colon_speciesIdentity.celldesigner_colon_class.Text = map.specType{spec};
        % Check if there are notes for the species
        if ~isempty(map.specNotes{spec})
            xmlStruct.sbml.model.listOfSpecies.species{spec}.notes.html.body.Text = map.specNotes{spec};
        end
    end
    clearvars spec

    % Check if there is any information on Compartments
    if ~isempty(map.complexAlias)
        % Loop over complexes to put the info back to the struct for XML
        % conversion
        for k = 1:length(map.complexAlias)
            map.complexAlias{k, 1} = xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{k}.Attributes.id;
            map.complexID{k, 1} = xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{k}.Attributes.species;
            % Test if info on compartment exists
            if ~isempty(map.complexCompartAlias{k})
                xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{k}.Attributes.compartmentAlias = map.complexCompartAlias{k};
            end
            xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{k}.celldesigner_colon_bounds.Attributes.x = map.complexXPos{k};
            xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{k}.celldesigner_colon_bounds.Attributes.y = map.complexYPos{k};
            xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{k}.celldesigner_colon_bounds.Attributes.w = map.complexWidth{k};
            xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{k}.celldesigner_colon_bounds.Attributes.h = map.complexHeight{k};
            xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfComplexSpeciesAliases.celldesigner_colon_complexSpeciesAlias{k}.celldesigner_colon_usualView.celldesigner_colon_paint.Attributes.color = map.complexColor{k};
        end
    end

    % Test if included species exist in the map
    if ~isempty(map.specIncID)
        % Loop over included species to get the need information and
        % store it in a structure. Included species refer to each
        % individual species included inside a k.
        for included = 1:length(map.specIncID)
            xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfIncludedSpecies.celldesigner_colon_species{included}.Attributes.id = map.specIncID{included};
            xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfIncludedSpecies.celldesigner_colon_species{included}.Attributes.name = map.specIncName{included};
            xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfIncludedSpecies.celldesigner_colon_species{included}.celldesigner_colon_annotation.celldesigner_colon_complexSpecies.Text = map.specIncCplxID{included};
            xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfIncludedSpecies.celldesigner_colon_species{included}.celldesigner_colon_annotation.celldesigner_colon_speciesIdentity.celldesigner_colon_class.Text = map.specIncType{included};
            % Test if there are notes for the included species
            if ~isempty(map.specIncNotes)
                xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfIncludedSpecies.celldesigner_colon_species{included}.celldesigner_colon_notes.html.body.Text = map.specIncNotes{included};
            end
        end
    end

    % Loop over reactions to put the info back to the struct for XML
    % conversion
    for react = 1:length(map.rxnID)
        % Check if there is a reaction ID
        if ~isempty(map.rxnID{react})
            xmlStruct.sbml.model.listOfReactions.reaction{react}.Attributes.id = map.rxnID{react};
        else
            xmlStruct.sbml.model.listOfReactions.reaction{react}.Attributes.id = 'No_ID';
        end
        xmlStruct.sbml.model.listOfReactions.reaction{react}.Attributes.metaid = map.rxnMetaID{react};
        % Check if the reaction has a Name
        if ~isempty(map.rxnName{react})
            xmlStruct.sbml.model.listOfReactions.reaction{react}.Attributes.name = map.rxnName{react};
            xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_name.Text = map.rxnName{react};
        else
            xmlStruct.sbml.model.listOfReactions.reaction{react}.Attributes.name = 'No_Name';
            xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_name.Text = 'No_Name';
        end
        xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_reactionType.Text = map.rxnType{react};
        xmlStruct.sbml.model.listOfReactions.reaction{react}.Attributes.reversible = map.rxnReversibility{react};
        % Test if there is only 1 base reactant
        if length(map.rxnBaseReactantAlias{react}) == 1
            xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant(1).Attributes.alias = map.rxnBaseReactantAlias{react}{1};
            xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant(1).Attributes.species = map.rxnBaseReactantID{react}{1};
        else
            for x = 1:length(map.rxnBaseReactantAlias{react})
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant{x}.Attributes.alias = map.rxnBaseReactantAlias{react}{x};
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant{x}.Attributes.species = map.rxnBaseReactantID{react}{x};
            end
            clearvars x
        end

        % Test if there is only 1 base product
        if length(map.rxnBaseProductAlias{react}) == 1
            xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct(1).Attributes.alias = map.rxnBaseProductAlias{react}{1};
            xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct(1).Attributes.species = map.rxnBaseProductID{react}{1};
        else
            for x = 1:length(map.rxnBaseProductAlias{react})
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct{x}.Attributes.alias = map.rxnBaseProductAlias{react}{x};
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct{x}.Attributes.species = map.rxnBaseProductID{react}{x};
            end
        end
        % Test if there are some reactants in the reaction
        if ~isempty(map.rxnReactantAlias{react})
            % Test if there is only 1 reactant
            if length(map.rxnReactantAlias{react}) == 1
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink.Attributes.alias = map.rxnReactantAlias{react}{1};
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink.Attributes.reactant = map.rxnReactantID{react}{1};
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink.celldesigner_colon_line.Attributes.type = map.rxnReactantLineType{react}{1};
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink.celldesigner_colon_line.Attributes.color = map.rxnReactantLineColor{react}{1};
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink.celldesigner_colon_line.Attributes.width = map.rxnReactantLineWidth{react}{1};
            else
                for x = 1:length(map.rxnReactantAlias{react})
                    xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.Attributes.alias = map.rxnReactantAlias{react}{x};
                    xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.Attributes.reactant = map.rxnReactantID{react}{x};
                    xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.celldesigner_colon_line.Attributes.type = map.rxnReactantLineType{react}{x};
                    xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.celldesigner_colon_line.Attributes.color = map.rxnReactantLineColor{react}{x};
                    xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.celldesigner_colon_line.Attributes.width = map.rxnReactantLineWidth{react}{x};
                end
                clearvars x
            end
        end

        % Test if there are some products in the reaction
        if ~isempty(map.rxnProductAlias{react})
            % Test if there is only 1 product
            if length(map.rxnProductAlias{react}) == 1
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink.Attributes.alias = map.rxnProductAlias{react}{1};
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink.Attributes.product = map.rxnProductID{react}{1};
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink.celldesigner_colon_line.Attributes.type = map.rxnProductLineType{react}{1};
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink.celldesigner_colon_line.Attributes.color = map.rxnProductLineColor{react}{1};
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink.celldesigner_colon_line.Attributes.width = map.rxnProductLineWidth{react}{1};
            else
                for x = 1:length(map.rxnProductAlias{react})
                    xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.Attributes.alias = map.rxnProductAlias{react}{x};
                    xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.Attributes.product = map.rxnProductID{react}{x};
                    xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.celldesigner_colon_line.Attributes.type = map.rxnProductLineType{react}{x};
                    xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.celldesigner_colon_line.Attributes.color = map.rxnProductLineColor{react}{x};
                    xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.celldesigner_colon_line.Attributes.width = map.rxnProductLineWidth{react}{x};
                end
                clearvars x
            end
        end

        % Check if there are modifications for the reaction
        if ~isempty(map.rxnModAlias{react})
            % Test if there is only one modification
            if length(map.rxnModAlias{react}) == 1
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).Attributes.aliases = map.rxnModAlias{react}{1};
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).Attributes.modifiers = map.rxnModID{react}{1};
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).Attributes.type = map.rxnModType{react}{1};
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).celldesigner_colon_line.Attributes.color = map.rxnModColor{react}{1};
                xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).celldesigner_colon_line.Attributes.width = map.rxnModWidth{react}{1};
            else
                for m = 1:length(map.rxnModAlias{react})
                    xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{m}.Attributes.aliases = map.rxnModAlias{react}{m};
                    xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{m}.Attributes.modifiers = map.rxnModID{react}{m};
                    xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{m}.Attributes.type = map.rxnModType{react}{m};
                    xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{m}.celldesigner_colon_line.Attributes.color = map.rxnModColor{react}{m};
                    xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{m}.celldesigner_colon_line.Attributes.width = map.rxnModWidth{react}{m};
                end
                clearvars m
            end
        end

        xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_line.Attributes.color = map.rxnColor{react};
        xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_line.Attributes.width = map.rxnWidth{react};

        % Check if there are notes for the reaction
        if ~isempty(map.rxnNotes{react})
            xmlStruct.sbml.model.listOfReactions.reaction{react}.notes.html.body.Text = map.rxnNotes{react};
        end
    end
    clearvars react

    % Check if there is any information on Compartments
    if ~isempty(map.compartAlias)
        % Test if there is only 1 compartment
        if length(map.compartAlias) == 1
            xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias(1).Attributes.id = map.compartAlias{1};
            xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias(1).Attributes.compartment = map.compartName{1};
        else
            % Loop over compartments to put the info back to the struct for XML
            % conversion
            for compart = 1:length(map.compartAlias)
                xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias{compart}.Attributes.id = map.compartAlias{compart};
                xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias{compart}.Attributes.compartment = map.compartName{compart};
            end
            clearvars compart
        end
    end

    struct2xml(xmlStruct, fileName);
    toc

end
