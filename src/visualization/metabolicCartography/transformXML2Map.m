function [xmlStruct, map] = transformXML2Map(fileName)
% Create a MATLAB structure from a given XML file.
% The XML file is first parsed through the "xml2struct" function and
% then transformed into a structure. The content of this structure can be
% found in the [description document](https://opencobra.github.io/cobratoolbox/docs/simpleMATLABStructure.html)
%
% USAGE:
%
%   [xmlStruct, map] = transformXML2Map(fileName)
%
% INPUT:
%   fileName:       Path to the XML file.
%
% OUTPUTS:
%   xmlStruct:      Structure obtained from the "xml2struct" function.
%                   To be kept for the conversion back to an XML file
%                   of the structure.
%   map:            Matlab structure of the map containing all the
%                   relevant fields usable for checking and correction.
%
% .. Author: - N.Sompairac - Institut Curie, Paris, 24/07/2017

    tic

    % Works nicely but has a huge tree structured
    xmlStruct = xml2struct(fileName);

    % Loop over molecules to get the needed information and store it in a
    % structure. Molecules refer to each individual node.
    for mol = 1:length(xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias)
        map.molAlias{mol, 1} = xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.Attributes.id;
        map.molID{mol, 1} = xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.Attributes.species;
        % Check if the info on compartment exists
        if any(strcmp('compartmentAlias', fieldnames(xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.Attributes)))
            map.molCompartAlias{mol, 1} = xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.Attributes.compartmentAlias;
        else
            map.molCompartAlias{mol, 1} = '';
        end
        map.molXPos{mol, 1} = xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.x;
        map.molYPos{mol, 1} = xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.y;
        map.molWidth{mol, 1} = xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.w;
        map.molHeight{mol, 1} = xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_bounds.Attributes.h;
        map.molColor{mol, 1} = xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias{mol}.celldesigner_colon_usualView.celldesigner_colon_paint.Attributes.color;
    end
    clearvars mol

    % Loop over species to get the needed information and store it in a
    % structure. Species refer to each individual name.
    for spec = 1:length(xmlStruct.sbml.model.listOfSpecies.species)
        map.specID{spec, 1} = xmlStruct.sbml.model.listOfSpecies.species{spec}.Attributes.id;
        map.specMetaID{spec, 1} = xmlStruct.sbml.model.listOfSpecies.species{spec}.Attributes.metaid;
        map.specName{spec, 1} = xmlStruct.sbml.model.listOfSpecies.species{spec}.Attributes.name;
        map.specType{spec, 1} = xmlStruct.sbml.model.listOfSpecies.species{spec}.annotation.celldesigner_colon_extension.celldesigner_colon_speciesIdentity.celldesigner_colon_class.Text;
        % Check if the info on notes exists for the specie
        if any(strcmp('notes', fieldnames(xmlStruct.sbml.model.listOfSpecies.species{spec})))
            map.specNotes{spec, 1} = xmlStruct.sbml.model.listOfSpecies.species{spec}.notes.html.body.Text;
        else
            map.specNotes{spec, 1} = '';
        end
    end
    clearvars spec

    % Loop over reactions to get the need information and store it in a
    % structure. Reactions refer to each individual reaction name.
    for react = 1:length(xmlStruct.sbml.model.listOfReactions.reaction)
        % Test if the reaction has an ID
        if any(strcmp('id', fieldnames(xmlStruct.sbml.model.listOfReactions.reaction{react}.Attributes)))
            map.rxnID{react, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.Attributes.id;
        else
            map.rxnID{react, 1} = '';
        end
        map.rxnMetaID{react, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.Attributes.metaid;
        % Test if the reaction has a Name
        if any(strcmp('name', fieldnames(xmlStruct.sbml.model.listOfReactions.reaction{react}.Attributes)))
            map.rxnName{react, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.Attributes.name;
        else
            map.rxnName{react, 1} = '';
        end
        map.rxnType{react, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_reactionType.Text;
        % Check if info on reversibility exists
        if any(strcmp('reversible', fieldnames(xmlStruct.sbml.model.listOfReactions.reaction{react}.Attributes)))
            map.rxnReversibility{react, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.Attributes.reversible;
        else
            map.rxnReversibility{react, 1} = 'true';
        end
        map.rxnBaseReactantAlias{react, 1} = {};
        map.rxnBaseReactantID{react, 1} = {};
        % Test if there is only 1 base reactant
        if length(xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant) == 1
            map.rxnBaseReactantAlias{react, 1}{1, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant.Attributes.alias;
            map.rxnBaseReactantID{react, 1}{1, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant.Attributes.species;
        else
            % Looping over the multiple base reactants
            for base = 1:length(xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant)
                map.rxnBaseReactantAlias{react, 1}{base, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant{base}.Attributes.alias;
                map.rxnBaseReactantID{react, 1}{base, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseReactants.celldesigner_colon_baseReactant{base}.Attributes.species;
            end
            clearvars base
        end
        map.rxnBaseProductAlias{react, 1} = {};
        map.rxnBaseProductID{react, 1} = {};
        % Test if there is only 1 base product
        if length(xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct) == 1
            map.rxnBaseProductAlias{react, 1}{1, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct.Attributes.alias;
            map.rxnBaseProductID{react, 1}{1, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct.Attributes.species;
        else
            % Looping over the multiple base products
            for base = 1:length(xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct)
                map.rxnBaseProductAlias{react, 1}{base, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct{base}.Attributes.alias;
                map.rxnBaseProductID{react, 1}{base, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_baseProducts.celldesigner_colon_baseProduct{base}.Attributes.species;
            end
            clearvars base
        end
        % Test if there are some reactants in the reaction
        if any(strcmp('celldesigner_colon_listOfReactantLinks', fieldnames(xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension)))
            map.rxnReactantAlias{react, 1} = {};
            map.rxnReactantID{react, 1} = {};
            % Test if there is only 1 reactant
            if length(xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink) == 1
                map.rxnReactantAlias{react, 1}{1, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink(1).Attributes.alias;
                map.rxnReactantID{react, 1}{1, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink(1).Attributes.reactant;
            else
                for x = 1:length(xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink)
                    map.rxnReactantAlias{react, 1}{x, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.Attributes.alias;
                    map.rxnReactantID{react, 1}{x, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfReactantLinks.celldesigner_colon_reactantLink{x}.Attributes.reactant;
                end
                clearvars x
            end
        else
            map.rxnReactantAlias{react, 1} = '';
            map.rxnReactantID{react, 1} = '';
        end
        % Test if there are some products in the reaction
        if any(strcmp('celldesigner_colon_listOfProductLinks', fieldnames(xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension)))
            map.rxnProductAlias{react, 1} = {};
            map.rxnProductID{react, 1} = {};
            % Test if there is only 1 product
            if length(xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink) == 1
                map.rxnProductAlias{react, 1}{1, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink(1).Attributes.alias;
                map.rxnProductID{react, 1}{1, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink(1).Attributes.product;
            else
                for x = 1:length(xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink)
                    map.rxnProductAlias{react, 1}{x, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.Attributes.alias;
                    map.rxnProductID{react, 1}{x, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfProductLinks.celldesigner_colon_productLink{x}.Attributes.product;
                end
                clearvars x
            end
        else
            map.rxnProductAlias{react, 1} = '';
            map.rxnProductID{react, 1} = '';
        end
        % Check if there are modifications for the reaction
        if any(strcmp('listOfModifiers', fieldnames(xmlStruct.sbml.model.listOfReactions.reaction{react})))
            % Test if there is only one modification
            if length(xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification) == 1
                map.rxnModAlias{react, 1}{1, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).Attributes.aliases;
                map.rxnModID{react, 1}{1, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).Attributes.modifiers;
                map.rxnModType{react, 1}{1, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).Attributes.type;
                map.rxnModColor{react, 1}{1, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).celldesigner_colon_line.Attributes.color;
                map.rxnModWidth{react, 1}{1, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification(1).celldesigner_colon_line.Attributes.width;
            else
                % Loop over the possible modifications
                for mod = 1:length(xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification)
                    map.rxnModAlias{react, 1}{mod, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{mod}.Attributes.aliases;
                    map.rxnModID{react, 1}{mod, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{mod}.Attributes.modifiers;
                    map.rxnModType{react, 1}{mod, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{mod}.Attributes.type;
                    map.rxnModColor{react, 1}{mod, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{mod}.celldesigner_colon_line.Attributes.color;
                    map.rxnModWidth{react, 1}{mod, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_listOfModification.celldesigner_colon_modification{mod}.celldesigner_colon_line.Attributes.width;
                end
                clearvars mod
            end
        else
            map.rxnModAlias{react, 1} = '';
            map.rxnModID{react, 1} = '';
            map.rxnModType{react, 1} = '';
            map.rxnModColor{react, 1} = '';
            map.rxnModWidth{react, 1} = '';
        end
        map.rxnColor{react, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_line.Attributes.color;
        map.rxnWidth{react, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.annotation.celldesigner_colon_extension.celldesigner_colon_line.Attributes.width;

        % Check if the info on notes exists for the reaction
        if any(strcmp('notes', fieldnames(xmlStruct.sbml.model.listOfReactions.reaction{react})))
            map.rxnNotes{react, 1} = xmlStruct.sbml.model.listOfReactions.reaction{react}.notes.html.body.Text;
        else
            map.rxnNotes{react, 1} = '';
        end
    end
    clearvars react

    % Check if there is any information on Compartments
    if any(strcmp('celldesigner_colon_compartmentAlias', fieldnames(xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases)))
        % Test is there is only 1 compartment
        if length(xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias) == 1
            map.compartAlias{1, 1} = xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias(1).Attributes.id;
            map.compartName{1, 1} = xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias(1).Attributes.compartment;
        else
            % Loop over compartments to get the need information and store it in a
            % structure. Compartments refer to each individual compartment name.
            for compart = 1:length(xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias)
                map.compartAlias{compart, 1} = xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias{compart}.Attributes.id;
                map.compartName{compart, 1} = xmlStruct.sbml.model.annotation.celldesigner_colon_extension.celldesigner_colon_listOfCompartmentAliases.celldesigner_colon_compartmentAlias{compart}.Attributes.compartment;
            end
            clearvars compart
        end
    else
        map.compartAlias = '';
        map.compartName = '';
    end
    map = getMapMatrices(map);
    toc

end
