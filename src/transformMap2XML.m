function [] = transformMatStruct2XML(xmlObject, map, fileName)
% Creates a new XML file from the information contained in the map
% structure. Uses the function "struct2xml" to transform a matlab
% structure into an XML text format.
%
% USAGE:
%
%  [] = transformMatStruct2XML(xmlObject, map, fileName)
%
% INPUTS:
%   xmlObject:      XML structure obtained from the function
%                   "xml2struct". Used by the function "struct2xml"
%                   to obtain the XML file.
%   map:            Matlab structure of the map with the relevant
%                   information. This information is then transfered to
%                   the xmlObject for the conversion.
%   fileName:       Path and name of the new XML file.
%
% .. Author: - N.Sompairac - Institut Curie, Paris, 24/07/2017

    tic

    % Loop over molecules to put the info back to the struct for XML
    % conversion
    for mol = 1:length(map.molAlias)
        xmlObject.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.Attributes.id = map.molAlias{mol};
        xmlObject.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.Attributes.species = map.molID{mol};
        % Check if the info on compartment exists
        if ~isempty(map.molCompartAlias{mol})
            xmlObject.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.Attributes.compartmentAlias = map.molCompartAlias{mol};
        end
        xmlObject.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.x = map.molXPos{mol};
        xmlObject.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.y = map.molYPos{mol};
        xmlObject.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.w = map.molWidth{mol};
        xmlObject.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.h = map.molHeight{mol};
        xmlObject.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_usualView.celldesigner_colon_paint.Attributes.color = map.molColor{mol};
    end
    clearvars mol

    % Loop over species to put the info back to the struct for XML
    % conversion
    for spec = 1:length(map.specID)
        xmlObject.sbml.model.listOfSpecies.species{spec}.Attributes.id = map.specID{spec};
        xmlObject.sbml.model.listOfSpecies.species{spec}.Attributes.metaid = map.specMetaID{spec};
        xmlObject.sbml.model.listOfSpecies.species{spec}.Attributes.name = map.specName{spec};
        xmlObject.sbml.model.listOfSpecies.species{spec}.annotation.celldesigner_colon_extension.celldesigner_colon_speciesIdentity.celldesigner_colon_name.Text = map.specName{spec};
        xmlObject.sbml.model.listOfSpecies.species{spec}.annotation.celldesigner_colon_extension.celldesigner_colon_speciesIdentity.celldesigner_colon_class.Text = map.specType{spec};
        % Check if there are notes for the specie
        if ~isempty(map.specNotes{spec})
            xmlObject.sbml.model.listOfSpecies.species{spec}.notes.html.body.Text = map.specNotes{spec};
        end
    end
    clearvars spec

    % Loop over reactions to put the info back to the struct for XML
    % conversion
    for react = 1:length(map.rxnID)
        % Check if there is a reaction ID
        if ~isempty(map.rxnID{react})
            xmlObject.sbml.model.listOfReactions.reaction{react}.Attributes.id = map.rxnID{react};
        else
            xmlObject.sbml.model.listOfReactions.reaction{react}.Attributes.id = 'No_ID';
        end
        xmlObject.sbml.model.listOfReactions.reaction{react}.Attributes.metaid = map.rxnMetaID{react};

        % Check if the reaction has a Name
        if ~isempty(map.rxnName{react})
            xmlObject.sbml.model.listOfReactions.reaction{react}.Attributes.name = map.rxnName{react};
            xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_name.Text = map.rxnName{react};
        else
            xmlObject.sbml.model.listOfReactions.reaction{react}.Attributes.name = 'No_Name';
            xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_name.Text = 'No_Name';
        end
        xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_reactionType.Text = map.rxnType{react};
        xmlObject.sbml.model.listOfReactions.reaction{react}.Attributes.reversible = map.rxnReversibility{react};
        % Test if there is only 1 base reactant
        if length(map.rxnBaseReactantAlias{react}) == 1
            xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant(1).Attributes.alias = map.rxnBaseReactantAlias{react}{1};
            xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant(1).Attributes.species = map.rxnBaseReactantID{react}{1};
        else
            for x = 1:length(map.rxnBaseReactantAlias{react})
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant{x}.Attributes.alias = map.rxnBaseReactantAlias{react}{x};
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant{x}.Attributes.species = map.rxnBaseReactantID{react}{x};
            end
            clearvars x
        end

        % Test if there is only 1 base product
        if length(map.rxnBaseProductAlias{react}) == 1
            xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct(1).Attributes.alias = map.rxnBaseProductAlias{react}{1};
            xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct(1).Attributes.species = map.rxnBaseProductID{react}{1};
        else
            for x = 1:length(map.rxnBaseProductAlias{react})
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct{x}.Attributes.alias = map.rxnBaseProductAlias{react}{x};
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct{x}.Attributes.species = map.rxnBaseProductID{react}{x};
            end
        end

        % Test if there are some reactants in the reaction
        if ~isempty(map.rxnReactantAlias{react})
            % Test if there is only 1 reactant
            if length(map.rxnReactantAlias{react}) == 1
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink(1).Attributes.alias = map.rxnReactantAlias{react}{1};
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink(1).Attributes.reactant = map.rxnReactantID{react}{1};
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink(1).celldesigner_colon_line.Attributes.color = map.rxnColor{react};
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink(1).celldesigner_colon_line.Attributes.width = map.rxnWidth{react};
            else
                for x = 1:length(map.rxnReactantAlias{react})
                    xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.Attributes.alias = map.rxnReactantAlias{react}{x};
                    xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.Attributes.reactant = map.rxnReactantID{react}{x};
                    xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.celldesigner_colon_line.Attributes.color = map.rxnColor{react};
                    xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.celldesigner_colon_line.Attributes.width = map.rxnWidth{react};
                end
                clearvars x
            end
        end

        % Test if there are some products in the reaction
        if ~isempty(map.rxnProductAlias{react})
            % Test if there is only 1 product
            if length(map.rxnProductAlias{react}) == 1
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink(1).Attributes.alias = map.rxnProductAlias{react}{1};
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink(1).Attributes.product = map.rxnProductID{react}{1};
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink(1).celldesigner_colon_line.Attributes.color = map.rxnColor{react};
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink(1).celldesigner_colon_line.Attributes.width = map.rxnWidth{react};
            else
                for x = 1:length(map.rxnProductAlias{react})
                    xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.Attributes.alias = map.rxnProductAlias{react}{x};
                    xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.Attributes.product = map.rxnProductID{react}{x};
                    xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.celldesigner_colon_line.Attributes.color = map.rxnColor{react};
                    xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.celldesigner_colon_line.Attributes.width = map.rxnWidth{react};
                end
                clearvars x
            end
        end

        % Check if there are modifications for the reaction
        if ~isempty(map.rxnModAlias{react})
            % Test if there is only one modification
            if length(map.rxnModAlias{react}) == 1
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).Attributes.aliases = map.rxnModAlias{react}{1};
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).Attributes.modifiers = map.rxnModID{react}{1};
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).Attributes.type = map.rxnModType{react}{1};
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).celldesigner_colon_line.Attributes.color = map.rxnModColor{react}{1};
                xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).celldesigner_colon_line.Attributes.width = map.rxnModWidth{react}{1};
            else
                for mod = 1:length(map.rxnModAlias{react})
                    xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{mod}.Attributes.aliases = map.rxnModAlias{react}{mod};
                    xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{mod}.Attributes.modifiers = map.rxnModID{react}{mod};
                    xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{mod}.Attributes.type = map.rxnModType{react}{mod};
                    xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{mod}.celldesigner_colon_line.Attributes.color = map.rxnModColor{react}{mod};
                    xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{mod}.celldesigner_colon_line.Attributes.width = map.rxnModWidth{react}{mod};
                end
                clearvars mod
            end
        end

        xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_line.Attributes.color = map.rxnColor{react};
        xmlObject.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_line.Attributes.width = map.rxnWidth{react};

        % Check if there are notes for the reaction
        if ~isempty(map.rxnNotes{react})
            xmlObject.sbml.model.listOfReactions.reaction{react}.notes.html.body.Text = map.rxnNotes{react};
        end
    end
    clearvars react

    % Check if there is any information on Compartments
    if ~isempty(map.compartAlias)
        % Test if there is only 1 compartment
        if length(map.compartAlias) == 1
            xmlObject.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias(1).Attributes.id = map.compartAlias{1};
            xmlObject.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias(1).Attributes.compartment = map.compartName{1};
        else
            % Loop over compartments to put the info back to the struct for XML
            % conversion
            for compart = 1:length(map.compartAlias)
                xmlObject.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias{compart}.Attributes.id = map.compartAlias{compart};
                xmlObject.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias{compart}.Attributes.compartment = map.compartName{compart};
            end
            clearvars compart
        end
    end

    struct2xml(xmlObject, fileName);
    toc
    
end