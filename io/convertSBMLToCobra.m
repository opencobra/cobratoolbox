function model = convertSBMLToCobra(modelSBML, defaultBound, ...
        compSymbolList, compNameList)
    % convertSBMLToCobra Convert SBML format model (created using SBML
    % Toolbox) to Cobra format
    %
    %  model = convertSBMLToCobra(modelSBML,defaultBound)
    %
    % INPUTS
    %  modelSBML         SBML model structure
    %
    % OPTIONAL INPUTS
    %  defaultBound      Maximum bound for model (Default = 1000)
    %  compSymbolList    List of compartment symbols
    %  compNameList      List of compartment names corresponding to 
    %                    compSymbolList
    %
    % OUTPUT
    %  model             COBRA model structure

    % Markus Herrgard 1/25/08
    %
    % Ines Thiele 01/27/2010 - I added new field to be read-in from SBML
    %                          file if provided in file (e.g., references,
    %                          comments, metabolite IDs, etc.)
    %
    % Richard Que 02/08/10 - Properly format reaction and metabolite fields
    %                        from SBML.
    %
    % Ben Heavner 2 July 2013 - modify parseSBMLNotesField call
    %

    %% References 
    %
    % Hucka, M., A. Finney, H. M. Sauro, H. Bolouri, J.C. Doyle, H. Kitano,
    % A. P. Arkin, et al. “The Systems Biology Markup Language (SBML): a
    % Medium for Representation and Exchange of Biochemical Network
    % Models.” Bioinformatics 19, no. 4 (March 2003): 524–531.
    % doi:10.1093/bioinformatics/btg015.
    %
    % Keating, S. M, B. J Bornstein, A. Finney, and M. Hucka. “SBMLToolbox:
    % An SBML Toolbox for MATLAB Users.” Bioinformatics 22, no. 10 (2006):
    % 1275.
    %
    % Becker, Scott A, Adam M Feist, Monica L Mo, Gregory Hannum, Bernhard
    % Ø Palsson, and Markus J Herrgard. “Quantitative Prediction of
    % Cellular Metabolism with Constraint-based Models: The COBRA Toolbox.”
    % Nature Protocols 2, no. 3 (March 2007): 727–738.
    % doi:10.1038/nprot.2007.99.
    %
    % Thiele, I., and B. O. Palsson. “A Protocol for Generating a
    % High-quality Genome-scale Metabolic Reconstruction.” Nature Protocols
    % 5, no. 1 (January 2010): 93–121. doi:10.1038/nprot.2009.203.
    %
    % Schellenberger, Jan, Richard Que, Ronan M T Fleming, Ines Thiele,
    % Jeffrey D Orth, Adam M Feist, Daniel C Zielinski, et al.
    % “Quantitative Prediction of Cellular Metabolism with Constraint-based
    % Models: The COBRA Toolbox V2.0.” Nature Protocols 6, no. 9 (August
    % 2011): 1290–1307. doi:10.1038/nprot.2011.308.
    
    %% TODO 
    % add case switches for SBML level/version/package support? Test on
    % lots of models

    if (nargin < 2)
        defaultBound = 1000;
    end

    if nargin < 3
        compSymbolList = {};
        compNameList = {};
    end

    rxns = {modelSBML.reaction.id}';
    rxnNames = {modelSBML.reaction.name}';
    rev = logical([modelSBML.reaction.reversible]');
    
    % need to ignore boundary mets 
    %
    % first, check for the Palsson lab _b$ boundary condition indicator for
    % legacy SBML support set (is this still needed?)
    
    boundaryMetIndexes = [modelSBML.species.boundaryCondition]';
    
    % build a logical for mets not annotated as boundary mets that end with
    % _b
    b_boundaryMets = ~cellfun('isempty', ...
        (regexp(...
        {modelSBML.species(~boundaryMetIndexes).id}, ...
        '_b$')));
    
    % if the logical has any, set the boundaryCondition to 1
    if sum(b_boundaryMets)
        modelSBML.species(b_boundaryMets).boundaryCondition = 1;
    end 
    
    % then ignore those mets for which modelSBML.species.boundaryCondition
    % == 1
    boundaryMetIndexes = [modelSBML.species.boundaryCondition]';
    mets = {modelSBML.species(~boundaryMetIndexes).id}';
    metNames = {modelSBML.species(~boundaryMetIndexes).name}';
    compartments = {modelSBML.species(~boundaryMetIndexes).compartment}';
    
    % get the metabolite notes, and parse to get formula and charge (legacy
    % support - should move to annotation in the future)
    
    unparsedMetNotes = {modelSBML.species(~boundaryMetIndexes).notes};
    
    [~, ~, ~, ~, metFormulas, ~, ~, ~, ~, chargeList, ~] = ...
                  parseSBMLNotesField(unparsedMetNotes);
              
    % get the metabolite annotation, and parse to get CHEBI, KEGG, PubChem,
    % and InChI info (expect to modify in the future as SBML evolves)
    
    unparsedMetAnnotation = ...
        {modelSBML.species(~boundaryMetIndexes).annotation};
    
    [metCHEBI,metKEGG,metPubChem,metInChI] = ...
        parseSBMLAnnotationField(unparsedMetAnnotation);

    %% Construct stoichiometric matrix and reaction list
    rxns = {modelSBML.reaction.id}';
    rxnNames = {modelSBML.reaction.name}';
    rev = logical([modelSBML.reaction.reversible]');

    S = zeros(length(mets),length(rxns));
    
    reactants = {modelSBML.reaction.reactant}';
    products = {modelSBML.reaction.product}';
    
    for reactants_index=1:length(reactants) % This is a bottleneck. Is there a Non-loopy way to do this?
        [~,~,IB] = intersect({reactants{reactants_index}.species}', ...
            mets, 'stable');

        % stoichiometric coefficient is negative for reactants
        S(IB,reactants_index) = ...
            -sum([reactants{reactants_index}.stoichiometry]); 
        
    end
    
    for products_index=1:length(products) % This is a bottleneck. Is there a Non-loopy way to do this?
        [~,~,IB] = intersect({products{products_index}.species}', mets, ...
            'stable');
        
        % stoichiometric coefficient is positive for products
        S(IB,products_index) = ...
            sum([products{products_index}.stoichiometry]); 
    end
    
    S = sparse(S);

    % get reaction notes fields, parse to get info and build genes, rules,
    % and grRules (legacy support - should move to annotation in the
    % future)
    
    unparsedRxnNotes = {modelSBML.reaction.notes}';
    
    [genes, rule, subSystem, grRule, ~, confidenceScore, ...
        citation, comment, ecNumber, ~, rxnGeneMat] = ...
        parseSBMLNotesField(unparsedRxnNotes);
        
    % get parameters for reactions to set lb, ub, and c
    
    % if the parameter.ids are LOWER_BOUND, UPPER_BOUND,
    % OBJECTIVE_COEFFICIENT, and FLUX_VALUE, this works as I'd like
    
    % note that iFF708 and iIN800 use paramaeter.name instead of
    % parameter.id. This code doesn't support this noncompliant SBML at the
    % moment.
    
    parameter_values = cell2mat(arrayfun(@(x) ...
        [x.kineticLaw.parameter.value],modelSBML.reaction,'uni',0)');
    
    lb_column = strcmpi(...
        {modelSBML.reaction(1).kineticLaw.parameter.id}, 'LOWER_BOUND');
    
    ub_column = strcmpi(...
        {modelSBML.reaction(1).kineticLaw.parameter.id}, 'UPPER_BOUND');
    
    objective_column = strcmpi(...
        {modelSBML.reaction(1).kineticLaw.parameter.id}, ...
        'OBJECTIVE_COEFFICIENT');
    
    lb = parameter_values(:,lb_column);
    ub = parameter_values(:,ub_column);
    c = parameter_values(:,objective_column);

    lb(lb < -defaultBound) = -defaultBound;
    ub(ub > defaultBound) = defaultBound;
    
    % I AM HERE!!!
    
    %TODO: clean up strings for compartments, mets and rxn ids. Should I
    %parse reaction names and met names for formulas, etc? Or depreciate
    %that?
    
    
    %% Collect everything into a structure
    model.rxns = rxns;
    model.mets = mets;
    model.S = S;
    model.rev = rev;
    model.lb = lb;
    model.ub = ub;
    model.c = c;
    model.metCharge = transpose(chargeList);
    model.rules = rule;
    model.genes = genes;
    model.rxnGeneMat = rxnGeneMat;
    model.grRules = grRule;
    model.subSystems = subSystem;
    model.confidenceScores = confidenceScore;
    model.rxnReferences = citation;
    model.rxnECNumbers = ecNumber; % currently a problem, this is 714 long, not 1266
    model.rxnNotes = comment;
    model.rxnNames = rxnNames;
    model.metNames = metNames;
    model.metFormulas = metFormulas;
    model.metChEBIID = metCHEBI;
    model.metKEGGID = metKEGG;
    model.metPubChemID = metPubChem;
    model.metInChIString = metInChI;
    model.unparsedMetNotes = unparsedMetNotes;
    model.unparsedMetAnnotations = unparsedMetAnnotation;
    model.unparsedRxnNotes = unparsedRxnNotes;
    % model.unparedRxnAnnotations = unparsedRxnAnnotation; % to come
end
    
    %To consider: clean up reaction names
        rxnNameTmp = regexprep(modelSBML.reaction(i).name,'^R_','');
        rxnNames{i} = regexprep(rxnNameTmp,'_+',' ');
        rxnsTmp = regexprep(modelSBML.reaction(i).id,'^R_','');
        rxns{i} = cleanUpFormatting(rxnsTmp);

    %to consider: clean up met names
            % Parse metabolite id's
        % Get rid of the M_ in the beginning of metabolite id's
        metID = regexprep(speciesList{i},'^M_','');
        metID = regexprep(metID,'^_','');
    
        
        try
            parameters = modelSBML.reaction(i).kineticLaw.parameter;
        catch
            parameters =[];
        end
        if (~isempty(parameters))
            for j = 1:length(parameters)
                paramStruct = parameters(j);
                switch paramStruct.id
                    case 'LOWER_BOUND'
                        lb(i) = paramStruct.value;
                        if (lb(i) < -defaultBound)
                            lb(i) = -defaultBound;
                        end
                    case 'UPPER_BOUND'
                        ub(i) = paramStruct.value;
                        if (ub(i) > defaultBound)
                            ub(i) = defaultBound;
                        end
                    case 'OBJECTIVE_COEFFICIENT'
                        c(i) = paramStruct.value;
                end
            end
        else
            ub(i) = defaultBound;
            if (rev(i) == 1)
                lb(i) = -defaultBound;
            else
                lb(i) = 0;
            end
        end
    end
    %close the waitbar if this is matlab
    if (regexp(version, 'R20'))
        close(h);
    end

    
    
    
    %% Construct metabolite list
    mets = cell(nMets,1);
    compartmentList = cell(length(modelSBML.compartment),1);
    if isempty(compSymbolList), 
        useCompList = true; 
    else
        useCompList = false;
    end

    for i=1:length(modelSBML.compartment)
        compartmentList{i} = modelSBML.compartment(i).id;
    end

    h = waitbar(0,'Constructing metabolite lists ...');
    hasAnnotationField = 0;
    for i = 1:nMets
        if mod(i,10) == 0
            waitbar(i/nMets,h);
        end
        % Parse metabolite id's
        % Get rid of the M_ in the beginning of metabolite id's
        metID = regexprep(speciesList{i},'^M_','');
        metID = regexprep(metID,'^_','');
        % Find compartment id
        tmpCell = {};
        if useCompList
            for j=1:length(compartmentList)
                tmpCell = regexp(metID,['_(' compartmentList{j} ')$'], ...
                    'tokens');
                if ~isempty(tmpCell), break; end
            end
            if isempty(tmpCell), useCompList = false; end
        elseif ~isempty(compSymbolList)
            for j = 1: length(compSymbolList)
                tmpCell = regexp(metID,['_(' compSymbolList{j} ')$'], ...
                    'tokens');
                if ~isempty(tmpCell), break; end
            end
        end
        if isempty(tmpCell), tmpCell = regexp(metID,'_(.)$','tokens'); end
        if ~isempty(tmpCell)
            compID = tmpCell{1};
            metTmp = [regexprep(metID,['_' compID{1} '$'], ...
                '') '[' compID{1} ']'];
        else
            metTmp = metID;
        end
        %Clean up met ID
        mets{i} = cleanUpFormatting(metTmp);
        % Parse metabolite names
        % Clean up some of the weird stuff in the sbml files
        metNamesTmp = regexprep(tmpSpecies(i).name,'^M_','');
        metNamesTmp = cleanUpFormatting(metNamesTmp);
        metNamesTmp = regexprep(metNamesTmp,'^_','');
    %     metNamesTmp = strrep(metNamesTmp,'_','-');
        metNamesTmp = regexprep(metNamesTmp,'-+','-');
        metNamesTmp = regexprep(metNamesTmp,'-$','');
        metNamesAlt{i} = metNamesTmp;
        % Separate formulas from names
        %[tmp,tmp,tmp,tmp,tokens] = regexp(metNamesTmp,'(.*)-((([A(Ag)(As)C(Ca)(Cd)(Cl)(Co)(Cu)F(Fe)H(Hg)IKLM(Mg)(Mn)N(Na)(Ni)OPRS(Se)UWXY(Zn)]?)(\d*)))*$');
        if (~haveFormulasFlag)
            [~, ~, ~, ~,tokens] = regexp(metNamesTmp, ...
                '(.*)_((((A|Ag|As|C|Ca|Cd|Cl|Co|Cu|F|Fe|H|Hg|I|K|L|M|Mg|Mn|Mo|N|Na|Ni|O|P|R|S|Se|U|W|X|Y|Zn)?)(\d*)))*$');
            if (isempty(tokens))
                if length(metFormulas)<i||(metFormulas{i}=='')
                    metFormulas{i} = '';
                end
                metNames{i} = metNamesTmp;
            else
                formulaCount = formulaCount + 1;
                metFormulas{i} = tokens{1}{2};
                metNames{i} = tokens{1}{1};
            end
        else
            metNames{i} = metNamesTmp;
        end
        if isfield(modelSBML.species(i),'annotation')
            hasAnnotationField = 1;
            [metCHEBI,metKEGG,metPubChem,metInChI] = ...
                parseSBMLAnnotationField(modelSBML.species(i).annotation);
            metCHEBIID{i} = metCHEBI;
            metKEGGID{i} = metKEGG;
            metPubChemID{i} = metPubChem;
            metInChIString{i} = metInChI;
        end
    end
    if ( regexp( version, 'R20') )
        close(h);
    end

    %% Collect everything into a structure
    model.rxns = rxns;
    model.mets = mets;
    model.S = S;
    model.rev = rev;
    model.lb = lb;
    model.ub = ub;
    model.c = c;
    model.metCharge = transpose(chargeList);
    if (hasNotesField)
        model.rules = rules;
        model.genes = columnVector(allGenes);
        model.rxnGeneMat = rxnGeneMat;
        model.grRules = columnVector(grRules);
        model.subSystems = columnVector(subSystems);
        model.confidenceScores = columnVector(confidenceScores);
        model.rxnReferences = columnVector(citations);
        model.rxnECNumbers = columnVector(ecNumbers);
        model.rxnNotes = columnVector(comments);
    end
    model.rxnNames = columnVector(rxnNames);
    % Only include formulas if at least 90% of metabolites have them (otherwise
    % the "formulas" are probably just parts of metabolite names)
    if (formulaCount < 0.9*nMets)
        model.metNames = columnVector(metNamesAlt);
    else
        model.metNames = columnVector(metNames);
        model.metFormulas = columnVector(metFormulas);
    end
    if (hasAnnotationField)
        model.metChEBIID = columnVector(metCHEBIID);
        model.metKEGGID = columnVector(metKEGGID);
        model.metPubChemID = columnVector(metPubChemID);
        model.metInChIString = columnVector(metInChIString);
end

%% Cleanup Formatting
function str = cleanUpFormatting(str)
str = strrep(str,'-DASH-','-');
str = strrep(str,'_DASH_','-');
str = strrep(str,'_FSLASH_','/');
str = strrep(str,'_BSLASH_','\');
str = strrep(str,'_LPAREN_','(');
str = strrep(str,'_LSQBKT_','[');
str = strrep(str,'_RSQBKT_',']');
str = strrep(str,'_RPAREN_',')');
str = strrep(str,'_COMMA_',',');
str = strrep(str,'_PERIOD_','.');
str = strrep(str,'_APOS_','''');
str = regexprep(str,'_e_$','(e)');
str = regexprep(str,'_e$','(e)');
str = strrep(str,'&amp;','&');
str = strrep(str,'&lt;','<');
str = strrep(str,'&gt;','>');
str = strrep(str,'&quot;','"');