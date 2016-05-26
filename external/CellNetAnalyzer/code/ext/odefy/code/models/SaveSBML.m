% SAVESBML  Convert Odefy model to ODE and store in SBML format
%
%   SAVESBML(MODEL,FILE,TYPE)  Convert MODEL to an ODE system of type TYPE
%   and write SBML to FILE.
%
%   The resulting SBML file is e.g. compatible with the COPASI toolbox.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function SaveSBML(model, file, type)

type=ValidateType(type);

% cube calls
[calls dummy paramnames paramdefs] = CreateCubeCalls(model,type,2);

% open file
h=fopen(file,'w');

% write XML header, SBML version and model opener
fprintf(h,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(h,'<sbml xmlns="http://www.sbml.org/sbml/level1" level="1" version="2">\n');
fprintf(h,'<model name="%s">\n', model.name);

% default compartments
fprintf(h,'<listOfCompartments>\n');
fprintf(h,'<compartment name="comp1"/>\n');
fprintf(h,'</listOfCompartments>\n');

% write out species
fprintf(h,'<listOfSpecies>\n');
for i=1:numel(model.species)
    fprintf(h,'<species name="%s" compartment="comp1"/>\n',model.species{i});
end
fprintf(h,'</listOfSpecies>\n');

% write out reactions, one per species
fprintf(h,'<listOfReactions>\n');
for i=1:numel(model.species)
    fprintf(h,'<reaction name="reaction_%s" reversible="false">\n',model.species{i});
    % no reactants
    fprintf(h,'<listOfReactants></listOfReactants>\n');
    % product = species itsself
    fprintf(h,'<listOfProducts><speciesReference species="%s"/></listOfProducts>\n',model.species{i});
    % modifiers -> all in-species
    fprintf(h,'<listOfModifiers>\n');
    for j=1:numel(model.tables(i).inspecies)
        in = model.tables(i).inspecies(j);
        fprintf(h,'<speciesReference species="%s"/>\n',model.species{in});
    end
    fprintf(h,'</listOfModifiers>\n');
    % kinetic + parameters
    fprintf(h,'<kineticLaw formula="%s">\n', calls{i});
    fprintf(h,'<listOfParameters>\n');
    for j=1:numel(paramnames{i})
        fprintf(h,'<parameter name="%s" value="%f"/>\n', paramnames{i}{j}, paramdefs{i}(j));
    end
    fprintf(h,'</listOfParameters>\n');
    fprintf(h,'</kineticLaw>\n');
    
    fprintf(h,'</reaction>\n');
    
end
fprintf(h,'</listOfReactions>\n');

% footer
fprintf(h,'</model>\n');
fprintf(h,'</sbml>\n');

fclose(h);