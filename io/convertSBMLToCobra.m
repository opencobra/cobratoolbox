function model = convertSBMLToCobra(modelSBML, defaultBound, ...
        compSymbolList, compNameList, legacyFlag)
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
    %                     compSymbolList
    %  legacyFlag        true to use old convertSBMLToCobra code that
    %                     parses SBML metabolite names for formulas,
    %                     compartments, and other information, instead of
    %                     using modern SBML approaches (Default false)
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
    % Ben Heavner August 2013 - rewritten to facilitate support of changing
    %                         SBML standard
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
    % add case switch for SBML fbc package support
    % Test on lots of models:
    % ok: Yeast 6 COBRA, iND750, recon 2, iAF
    % to test: Yeast 6 FBC, Nielsen group models, neurospora, 
    

    if (nargin < 2)
        defaultBound = 1000;
    end

    if nargin < 3
        compSymbolList = {};
        compNameList = {};
    end
    
    if nargin < 5
        legacyFlag = 0;
    end

    if legacyFlag % run legacy code (not the default)
        
        warnString = ['Using legacy convertSBMLToCobra code. This ' ...
            'code parses legacy metabolite and reaction naming ' ...
            'conventions and may not import all information from ' ...
            'notes or annotation fields.'];
        warning(warnString);
    
        nMetsTmp = length(modelSBML.species);
        nRxns = length(modelSBML.reaction);

        %% Construct initial metabolite list
        formulaCount = 0;
        speciesList = {};
        chargeList = [];
        metFormulas = {};
        haveFormulasFlag = false;
        tmpSpecies = [];
        for i = 1:nMetsTmp
            % Ignore boundary metabolites
            if (~modelSBML.species(i).boundaryCondition)
              %Check for the Palsson lab _b$ boundary condition indicator
              if (isempty(regexp(modelSBML.species(i).id,'_b$')));
                tmpSpecies = [ tmpSpecies modelSBML.species(i)];
                speciesList{end+1} = modelSBML.species(i).id;
                notesField = modelSBML.species(i).notes;
                % Get formula if in notes field
                if (~isempty(notesField))
                  [~, ~, ~, ~, formula, ~, ~, ~, ~, charge] = ...
                      parseSBMLNotesField(notesField);
                  tmpCharge = charge;
                  metFormulas {end+1} = formula;
                  formulaCount = formulaCount + 1;
                  haveFormulasFlag = true;
                end
                chargeList= [chargeList modelSBML.species(i).charge];
              end
            end
        end

        nMets = length(speciesList);

        %% Construct stoichiometric matrix and reaction list
        S = sparse(nMets,nRxns);
        rev = zeros(nRxns,1);
        lb = zeros(nRxns,1);
        ub = zeros(nRxns,1);
        c = zeros(nRxns,1);
        rxns = cell(nRxns,1);
        rules = cell(nRxns,1);
        genes = cell(nRxns,1);
        allGenes = {};
        h = waitbar(0,'Reading SBML file ...');
        hasNotesField = false;
        for i = 1:nRxns
            if mod(i,10) == 0
                waitbar(i/nRxns,h);
            end
            % Read the gpra from the notes field
            notesField = modelSBML.reaction(i).notes;
            if (~isempty(notesField))
                [geneList, rule, subSystem, grRule, formula, ...
                    confidenceScore, citation, comment, ecNumber] = ...
                    parseSBMLNotesField(notesField);
                subSystems{i} = subSystem;
                genes{i} = geneList;
                allGenes = [allGenes geneList];
                rules{i} = rule;
                grRules{i} = grRule;
                hasNotesField = true;
                confidenceScores{i}= confidenceScore;
                citations{i} = citation;
                comments{i} = comment;
                ecNumbers{i} = ecNumber;
            end
            rev(i) = modelSBML.reaction(i).reversible;
            rxnNameTmp = regexprep(modelSBML.reaction(i).name, '^R_','');
            rxnNames{i} = regexprep(rxnNameTmp, '_+', ' ');
            rxnsTmp = regexprep(modelSBML.reaction(i).id, '^R_', '');
            rxns{i} = cleanUpFormatting(rxnsTmp);
            % Construct S-matrix
            reactantStruct = modelSBML.reaction(i).reactant;
            for j = 1:length(reactantStruct)
                speciesID = find(strcmp ...
                    (reactantStruct(j).species,speciesList));
                if (~isempty(speciesID))
                    stoichCoeff = reactantStruct(j).stoichiometry;
                    S(speciesID,i) = -stoichCoeff;
                end
            end
            productStruct = modelSBML.reaction(i).product;
            for j = 1:length(productStruct)
                speciesID = find(strcmp ...
                    (productStruct(j).species,speciesList));
                if (~isempty(speciesID))
                    stoichCoeff = productStruct(j).stoichiometry;
                    S(speciesID,i) = stoichCoeff;
                end
            end
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
        allGenes = unique(allGenes);

        %% Construct gene to rxn mapping
        if (hasNotesField)

            rxnGeneMat = sparse(nRxns,length(allGenes));
            h = waitbar(0,'Constructing GPR mapping ...');
            for i = 1:nRxns
                if mod(i,10) == 0
                    waitbar(i/nRxns,h);
                end
                if iscell(genes{i})
                    [~,geneInd] = ismember(genes{i}, allGenes);
                else
                    [~,geneInd] = ismember(num2cell(genes{i}), allGenes);
                end

                rxnGeneMat(i,geneInd) = 1;
                for j = 1:length(geneInd)
                    rules{i} = strrep(rules{i}, ...
                        ['x(' num2str(j) ')'], ...
                        ['x(' num2str(geneInd(j)) '_TMP_)']);
                end
                rules{i} = strrep(rules{i},'_TMP_','');
            end
            %close the waitbar if this is matlab
            if (regexp(version, 'R20'))
                close(h);
            end

        end

        %% Construct metabolite list
        mets = cell(nMets, 1);
        compartmentList = cell(length(modelSBML.compartment), 1);
        if isempty(compSymbolList), useCompList = true; 
        else useCompList = false; 
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
                    tmpCell = regexp(metID, ...
                        ['_(' compartmentList{j} ')$'], 'tokens');
                    if ~isempty(tmpCell), break; end
                end
                if isempty(tmpCell), useCompList = false; end
            elseif ~isempty(compSymbolList)
                for j = 1: length(compSymbolList)
                    tmpCell = regexp(metID, ...
                        ['_(' compSymbolList{j} ')$'], 'tokens');
                    if ~isempty(tmpCell), break; end
                end
            end
            
            if isempty(tmpCell), tmpCell = regexp(metID, '_(.)$','tokens'); 
            end
            
            if ~isempty(tmpCell)
                compID = tmpCell{1};
                metTmp = [regexprep(metID, ...
                    ['_' compID{1} '$'], '') '[' compID{1} ']'];
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
            % metNamesTmp = strrep(metNamesTmp,'_','-');
            metNamesTmp = regexprep(metNamesTmp,'-+','-');
            metNamesTmp = regexprep(metNamesTmp,'-$','');
            metNamesAlt{i} = metNamesTmp;
            % Separate formulas from names [tmp,tmp,tmp,tmp,tokens] =
            % regexp(metNamesTmp,
            % '(.*)-((([A(Ag)(As)C(Ca)(Cd)(Cl)(Co)(Cu)F(Fe)H(Hg)IKLM(Mg)(Mn)N(Na)(Ni)OPRS(Se)UWXY(Zn)]?)(\d*)))*$');
            if (~haveFormulasFlag)
                regExString = ['(.*)_((((A|Ag|As|C|Ca|Cd|Cl|Co|Cu|F|' ...
                    'Fe|H|Hg|I|K|L|M|Mg|Mn|Mo|N|Na|Ni|O|P|R|S|Se|U|W' ...
                    '|X|Y|Zn)?)(\d*)))*$'];
                [~,~,~,~,tokens] = regexp(metNamesTmp, regExString);
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
                    parseSBMLAnnotationField(...
                    modelSBML.species(i).annotation);
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
        % Only include formulas if at least 90% of metabolites have them
        % (otherwise the "formulas" are probably just parts of metabolite
        % names)
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


    else % if legacyFlag is false (the default), use new code

        rxns = {modelSBML.reaction.id}';
        rxnNames = {modelSBML.reaction.name}';
        
        rev = logical([modelSBML.reaction.reversible]');

        % need to ignore boundary mets when building met ids and names.
        boundaryMetIndexes = [modelSBML.species.boundaryCondition]';

        % build a logical for mets not annotated as boundary mets that end
        % with _b (a legacy way to indicate boundary mets)
        b_boundaryMets = ~cellfun('isempty', ...
            (regexp({modelSBML.species(~boundaryMetIndexes).id}, '_b$')));

        % if there are _b mets, set the corresponding boundaryCondition
        if sum(b_boundaryMets)
            modelSBML.species(b_boundaryMets).boundaryCondition = 1;
        end 

        % then ignore those mets for which
        % modelSBML.species.boundaryCondition == 1
        boundaryMetIndexes = [modelSBML.species.boundaryCondition]';
        mets = {modelSBML.species(~boundaryMetIndexes).id}';
        metNames = {modelSBML.species(~boundaryMetIndexes).name}';
                
        compartments = ...
            {modelSBML.species(~boundaryMetIndexes).compartment}';
        
        % strip the leading C_
        compartments = regexprep(compartments, '^C_', '', 'ignorecase');
       
        % get the metabolite notes, and parse to get formula and charge
        % (legacy support - should move to annotation in the future)
        unparsedMetNotes = {modelSBML.species(~boundaryMetIndexes).notes};

        [~, ~, ~, ~, metFormulas, ~, ~, ~, ~, chargeList, ~] = ...
                      parseSBMLNotesField(unparsedMetNotes);

        % if the charge isn't in the notes field, see if it's in the sbml
        % species field, and if so, get it from there.
        if sum(cellfun('isempty', chargeList))
            if isfield(modelSBML.species, 'charge')
                chargeList = ...
                    [modelSBML.species(~boundaryMetIndexes).charge]';
            end
        end
        
        if ~isnumeric(chargeList)
            chargeList = cellfun(@str2num, chargeList, ...
                'UniformOutput', false);
        end
        
        % get the metabolite annotation, and parse to get CHEBI, KEGG,
        % PubChem, and InChI info (expect to modify in the future as SBML
        % evolves)
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

        % This is a bottleneck. Is there a better way to do this?
        h = waitbar(0,'Constructing S matrix: reactants ...');
        
        for reactants_index = 1:length(reactants)
            [~,~,IB] = intersect( ...
                {reactants{reactants_index}.species}', mets, 'stable');

            % exchange reactions may return a 1x0 struct array
            if length(reactants{reactants_index}) 
                % stoichiometric coefficient is negative for reactants
                S(IB,reactants_index) = S(IB,reactants_index)' - ...
                    ([reactants{reactants_index}.stoichiometry]);
            end
            
            if mod(reactants_index,10) == 0
                    waitbar(reactants_index/length(reactants),h);
            end
        end
        
        % close the waitbar
        close(h);

        % This is a bottleneck. Is there a better way to do this?
        h = waitbar(0,'Constructing S matrix: products ...');
        for products_index = 1:length(products) 
            [~,~,IB] = intersect({products{products_index}.species}', ...
                mets, 'stable');

            % exchange reactions may return a 1x0 struct array
            if length(products{products_index}) 
                % stoichiometric coefficient is positive for products
                S(IB,products_index) = S(IB,products_index)' + ...
                    ([products{products_index}.stoichiometry]);
            end
            
            if mod(products_index,10) == 0
                    waitbar(products_index/length(products),h);
            end
        end
        
        % close the waitbar
        close(h);

        S = sparse(S);

        % get reaction notes fields, parse to get info and build genes,
        % rules, and grRules

        unparsedRxnNotes = {modelSBML.reaction.notes}';

        [genes, rule, subSystem, grRule, ~, confidenceScore, ...
            citation, comment, ecNumber, ~, rxnGeneMat] = ...
            parseSBMLNotesField(unparsedRxnNotes);

        % get parameters for reactions to set lb, ub, and c

        % if the parameter.ids are LOWER_BOUND, UPPER_BOUND,
        % OBJECTIVE_COEFFICIENT, and FLUX_VALUE, this works as I'd like

        % note that iFF708 and iIN800 use paramaeter.name instead of
        % parameter.id. This code doesn't support this noncompliant SBML at
        % the moment.

        parameter_values = cell2mat(arrayfun(@(x) ...
            [x.kineticLaw.parameter.value], modelSBML.reaction, 'uni', ...
            0)');

        lb_column = strcmpi(...
            {modelSBML.reaction(1).kineticLaw.parameter.id}, ...
            'LOWER_BOUND');

        ub_column = strcmpi(...
            {modelSBML.reaction(1).kineticLaw.parameter.id}, ...
            'UPPER_BOUND');

        objective_column = strcmpi(...
            {modelSBML.reaction(1).kineticLaw.parameter.id}, ...
            'OBJECTIVE_COEFFICIENT');

        lb = parameter_values(:, lb_column);
        ub = parameter_values(:, ub_column);
        c = parameter_values(:, objective_column);

        lb(lb < -defaultBound) = -defaultBound;
        ub(ub > defaultBound) = defaultBound;

        % Clean up met names and ids if they contain legacy strings or
        % SBML-required character substitutions
        metNames = regexprep(metNames, '^M_', '');
        metNames = regexprep(metNames, '_+', ' ');
                
        mets = regexprep(mets, '^M_', '');
        mets = regexprep(mets, '^_', '');
        % next, replace old _c compartments with [c]
        mets = regexprep(mets, '_(\w)\>', '[$1]'); 
        mets = cleanUpFormatting(mets);

        % Clean up reaction names and ids if they contain legacy strings or
        % SBML-required character substitutions
        rxnNames = regexprep(rxnNames, '^R_', '');
        rxnNames = regexprep(rxnNames, '_+', ' ');
        
        rxns = regexprep(rxns, '^R_', '');
        rxns = cleanUpFormatting(rxns);
        
        %TODO
        % Clean up compartment names, replace abbreviation with long names
        % if supplied in function call. 
        compartments = regexprep(compartments, '^C_', '');
        
        %% Collect everything into a structure
        
        % mathematical requirements
        model.S = S;      
        model.c = c;
        model.rev = rev;
        model.lb = lb;
        model.ub = ub;
        model.rxnGeneMat = rxnGeneMat;
        
        % met info
        model.mets = mets;
        model.metNames = metNames;
        %model.metConfidenceScores = ; % future?
        model.metCharge = chargeList;
        model.metCompartment = compartments;
        model.metFormulas = metFormulas;
        model.metChEBIID = metCHEBI;
        model.metKEGGID = metKEGG;
        model.metPubChemID = metPubChem;
        model.metInChIString = metInChI;
        % the following metNotes is a bit different from the old version,
        % which parsed the notes field to return comments
        model.metNotes = unparsedMetNotes'; 
        model.unparsedMetAnnotations = unparsedMetAnnotation';

        % rxn info
        model.rxns = rxns;
        model.rxnNames = rxnNames;
        model.rxnSubSystems = subSystem;
        model.rules = rule;
        model.rxnConfidenceScores = confidenceScore;
        model.rxnReferences = citation;
        model.rxnECNumbers = ecNumber;
        model.rxnNotes = unparsedRxnNotes;
        % model.unparedRxnAnnotations = unparsedRxnAnnotation; % future?
        model.grRules = grRule;

        % gene info
        model.genes = genes;
        %model.geneConfidenceScores = ; % future?
        
        %model info
        model.compartments = {modelSBML.compartment.id}';
        % strip the leading C_
        model.compartments = regexprep(model.compartments, '^C_', '', ...
            'ignorecase'); 
        model.compartmentNames = {modelSBML.compartment.name}';
       
        % protein info - future?
        % constraint info - future?

    end
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
end