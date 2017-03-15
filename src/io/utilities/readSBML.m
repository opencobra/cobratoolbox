function model = readSBML(fileName,defaultBound,compSymbolList,compNameList)

% readSBML reads in a SBML format model as a COBRA matlab structure
%
%
%INPUTS
% fileName          File name for file to read in
%
%OPTIONAL INPUTS
% defaultBound      Maximum bound for model (Default = 1000)
% compSymbolList    List of compartment symbols
% compNameList      List of compartment names corresponding to compSymbolList
%
%OUTPUT
% model             COBRA model structure
%
% Markus Herrgard 1/25/08
%
% Ines Thiele 01/27/2010 - I added new field to be read-in from SBML file
% if provided in file (e.g., references, comments, metabolite IDs, etc.)
%
% Richard Que 02/08/10 - Properly format reaction and metabolite fields
%                        from SBML.
%
% Longfei Mao 23/09/15 - Added support for the FBCv2 format
%


if (nargin < 2)
    defaultBound = 1000;
end

if nargin < 3
    compSymbolList = {};
    compNameList = {};
end

modelSBML = readSBMLCbModel(fileName,defaultBound,compSymbolList,compNameList); % call the TranslateSBML funciton
% % % % % %
% % % % % % str={'id','name','notes'};
% % % % % % for i=1:length(str)
% % % % % %     model.(str{1})=ListFields.(str{1})
% % % % % % end
% % % % % %
% % % % % %
% % % % % % modelSBML=combineStruct(ListStructArrays,ListStructs)

nMetsTmp = length(modelSBML.species);
nRxns = length(modelSBML.reaction);

if ~isfield(modelSBML,'fbc_version')
    warning('The current version of the COBRA toolbox only supports SBML-FBCv2 files');

end

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
            tmpSpecies = [ tmpSpecies  modelSBML.species(i)];
            speciesList{end+1} = modelSBML.species(i).id;
            notesField = modelSBML.species(i).notes;
            % Get formula if in notes field
            if (~isempty(notesField))
                [tmp,tmp,tmp,tmp,formula,tmp,tmp,tmp,tmp,charge] = parseSBMLNotesField(notesField);
                chargeList = [chargeList; charge];
                metFormulas {end+1} = formula;
                formulaCount = formulaCount + 1;
                haveFormulasFlag = true;
            end
            % This is a really bad idea, since charge is initialized
            % as zero even if it is undefined in the SBML file. Seems like
            % a bug in libSBML, perhaps?
            % Keeping it for compatibility, but adding an if statement
            % around it. Can it be reomved?
            if (isfield(modelSBML.species(i), 'isSetCharge') && modelSBML.species(i).isSetCharge && (~exist('charge','var') || isempty(charge)))
                try
                    chargeList(end) = modelSBML.species(i).charge; % for compatibility with the old version
                catch ME
                %                 try
                %                     chargeList= [chargeList modelSBML.species(i).fbc_charge];
                %                 catch
                %                     disp('error'); % disable the eorror message in the
                %                     case where the code above fails to retrieve the
                %                     charge information from the species(i).charge
                %                 end
                end
            end
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
hasNotesField = false;

fbc_lb = zeros(nRxns,1);
fbc_ub = zeros(nRxns,1);

if isfield(modelSBML,'parameter')&&~isempty(modelSBML.parameter)
    listKey={'parameter'};
    for d=1:length(listKey) % listKey

        fieldNameList=fieldnames(modelSBML.(listKey{d}));

        for f=1:length(fieldNameList) % fieldname in each substructure

            numValues=length(modelSBML.(listKey{d})); % number of structures in one array

            for i=1:numValues

                converted.(listKey{d}).(fieldNameList{f})(i,1)={modelSBML.(listKey{d})(i).(fieldNameList{f})};

                % for each reactions there are two fields "reactant" and
                % "product"; they are two indepedent sub-structures.
                % {'reactant', 'product', 'modifier', 'kineticLaw'} are are structures.
            end

        end
        converted.name.(listKey{d})=fieldnames(converted.(listKey{d}));
    end

end

if isfield(modelSBML,'fbc_version')&&modelSBML.fbc_version==1;
    if isfield(modelSBML,'fbc_fluxBound')&&~isempty(modelSBML.fbc_fluxBound)
        listKey={'fbc_fluxBound'};
        for d=1:length(listKey) % listKey

            fieldNameList=fieldnames(modelSBML.(listKey{d}));

            for f=1:length(fieldNameList) % fieldname in each substructure

                numValues=length(modelSBML.(listKey{d})); % number of structures in one array
                for i=1:numValues
                    convertedFluxbounds.(listKey{d}).(fieldNameList{f})(i,1)={modelSBML.(listKey{d})(i).(fieldNameList{f})};
                    % for each reactions there are two fields "reactant" and
                    % "product"; they are two indepedent substructures.
                    % {'reactant', 'product', 'modifier', 'kineticLaw'}; they are structures.
                end

            end
            convertedFluxbounds.name.(listKey{d})=fieldnames(convertedFluxbounds.(listKey{d}));
        end

    end
end


% Define a list of fbc extension keywords supported by COBRA
%       fbc_list={'fbc_version'; 'fbc_activeObjective'; 'fbc_objective'; 'fbc_fluxBound'}; % Four new fields defined by FBC
fbc_list={'fbc_objective'; 'fbc_fluxBound'};
verList={'SBML_level'; 'SBML_version'; 'fbc_version'};

listOfboundKeys={'greaterEqual';'lessEqual';'equal'};
listOffbc_type={'maximize','minimize'};

%% Reaction

modelVersion=struct();
noObjective=0; % by default there is an objective function.

subSystems = cell(nRxns, 1);
grRules = cell(nRxns, 1);
confidenceScores = cell(nRxns, 1);
citations = cell(nRxns, 1);
comments = cell(nRxns, 1);
ecNumbers = cell(nRxns, 1);

for i = 1:nRxns
    % Read the gpra from the notes field; compliant with the previous
    % version of the SBML files
    notesField = modelSBML.reaction(i).notes;
    if (~isempty(notesField))
        [geneList,rule,subSystem,grRule,formula,confidenceScore, citation, comment, ecNumber] = parseSBMLNotesField(notesField);
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
    annotationField = modelSBML.reaction(i).annotation;
    if (~isempty(annotationField))
        [ecNumber, citation] = parseSBMLAnnotationFieldRxn(annotationField);
        tmpStr = '';
        if (~isempty(citations{i})); tmpStr = ','; end
        citations{i} = strcat(citations{i}, tmpStr, citation);
        tmpStr = '';
        if (~isempty(ecNumbers{i})); tmpStr = ','; end
        ecNumbers{i} = strcat(ecNumbers{i}, tmpStr, ecNumber);
    end

    %if isfield(model, 'grRules')
    %         sbml_tmp_grRules= model.grRules(i);
    %% need to be improved since the fbc_id for the gene association is not provided.

    % tmp_fbc_id=['gene',num2str(i)];
    %     tmp_Rxn.tmp_fbc_geneProductAssociation=[];
    %         if i==1;
    % modelSBML.reaction.fbc_geneProductAssociation.fbc_id       % a COBRA model doesn't need the information of this field

    if isfield(modelSBML.reaction,'fbc_geneProductAssociation')
        if size(modelSBML.reaction(i).fbc_geneProductAssociation,2)~=0 % the Matlab structure of the "geneAssociation" is defined.
            grRules{i}= modelSBML.reaction(i).fbc_geneProductAssociation.fbc_association.fbc_association; % sbml_tmp_grRules;  % (8639.1) or (26.1) or (314.2) or (314.1)
            [geneList,rule] = parseBoolean(grRules{i}); % the rules are not commonly seen in a COBRA model structure.
            % genes{i}= geneList;
            rules{i}=rule; % (x(1)) | (x(2)) | (x(3)) | (x(4))
            genes{i}=geneList;   % 8639.1
        else  % in the case that no geneAssociation is defined in the XML code
            grRules{i}=''; % no gene rule at all
            rules{i}='';
            genes{i}='';
        end
    end
    %         else
    %     sbmlModel.reaction=[sbmlModel.reaction,sbml_tmp_grRules];
    %         end
    % end

    rev(i) = modelSBML.reaction(i).reversible;
    rxnNameTmp = regexprep(modelSBML.reaction(i).name,'^R_','');
    rxnNames{i} = regexprep(rxnNameTmp,'_+',' ');
    rxnsTmp = regexprep(modelSBML.reaction(i).id,'^R_','');
    rxns{i} = cleanUpFormatting(rxnsTmp);
    % Construct S-matrix
    reactantStruct = modelSBML.reaction(i).reactant;
    for j = 1:length(reactantStruct)
        speciesID = find(strcmp(reactantStruct(j).species,speciesList));
        if (~isempty(speciesID))
            stoichCoeff = reactantStruct(j).stoichiometry;
            if (isnan(stoichCoeff))
                warning on;
                warning(['In the SBML file, ', 'the stoichiometric coefficient of ', '"', reactantStruct(j).species,'"', ' in the reaction ', '"', rxns{i}, '"', ' is not defined']);
            end
            S(speciesID,i) = -stoichCoeff;
        end
    end
    productStruct = modelSBML.reaction(i).product;
    for j = 1:length(productStruct)
        speciesID = find(strcmp(productStruct(j).species,speciesList));
        if (~isempty(speciesID))
            stoichCoeff = productStruct(j).stoichiometry;
            if (isnan(stoichCoeff))
                warning on;
                warning(['In the SBML file, ', 'the stoichiometric coefficient of ', '"', reactantStruct(j).species,'"', ' in the reaction ', '"', rxns{i}, '"', ' is not defined']);
            end
            S(speciesID,i) = stoichCoeff;
        end
    end

    % Convert conventional bounds to FBC bounds

    if isfield(modelSBML,'fbc_version')
        fieldnameList=fieldnames(modelSBML);
        regMatch='(fbc_).+';
        result=regexpi(fieldnameList,regMatch); % Regular expression used to identify new FBC fields
        values=~cellfun('isempty',result);
        existed_fbc_list=fieldnameList(values);

        for v=1:length(verList);
            if ismember(verList(v),fieldnameList);
                modelVersion.(verList{v})=modelSBML.(verList{v}); % Store FBC versions in the COBRA structure
            end
        end

        for f=1:length(fbc_list)
            %             if f==2
            %                 disp('good');
            %             end

            if ismember(fbc_list(f),existed_fbc_list);
                if f==1 % In the case of fbc_objective
                    %TODO: Adapt this to properly import multiple
                    %objectives. This will need to be also addressed in the
                    %model structure (multiple c vectors and osense values)
                    %For now, we only import the first objective!

                    if ~isempty(modelSBML.(fbc_list{f})) && ~isempty({modelSBML.(fbc_list{f})(1).fbc_fluxObjective.fbc_reaction})
                        fbc_obj=modelSBML.(fbc_list{f})(1).fbc_fluxObjective.fbc_reaction; % the variable stores the objective reaction ID
                        fbc_obj=regexprep(fbc_obj,'^R_','');
                        if isfield(modelSBML.(fbc_list{f})(1).fbc_fluxObjective,'fbc_coefficient')
                            fbc_obj_value=modelSBML.(fbc_list{f})(1).fbc_fluxObjective.fbc_coefficient;
                            %By FBC definition the fbc_type of an objective
                            %has to be either "minimize" or maximize"
                            %As such, we use the first 3 lettters of the
                            %objective type to define the osenseStr of the
                            %model.
                            fbc_obj_value = modelSBML.(fbc_list{f})(1).fbc_type(1:3);
                        end
                    else % if the objective function is not specified according to the FBCv2 rules.
                        noObjective=1; % no objective function is defined for the COBRA model.
                        % % % %                         ind_obj=1;
                        % % % %                         fbc_obj=modelSBML.reaction(ind_obj).id;
                        % % % %                         fbc_obj=regexprep(fbc_obj,'^R_','');
                        % % % %                         fbc_obj_value=-1;

                    end

                elseif f==2 % In the case of fbc_bound
                    if modelSBML.fbc_version==1;

                        if rev(i)==0
                            fbc_lb(i)=0;
                            fbc_ub(i)=defaultBound;
                        else
                            fbc_lb(i)=-defaultBound;
                            fbc_ub(i)=defaultBound;
                        end

                        if size(modelSBML.fbc_fluxBound,2)>0 % not an empty structure;

                            indBds=find(strcmp(modelSBML.reaction(i).id,convertedFluxbounds.fbc_fluxBound.fbc_reaction));
                            if ~isempty(indBds)
                                for b=1:length(indBds)
                                    ind=find(strcmp(listOfboundKeys,convertedFluxbounds.fbc_fluxBound.fbc_operation(indBds(b))));
                                    switch ind
                                        case 1
                                            % In the first case, the first row contains a lower bound, wheresas the second contains a upper bound
                                            fbc_lb(i)=convertedFluxbounds.(fbc_list{f}).fbc_value{indBds(b)};

                                        case 2

                                            fbc_ub(i)=convertedFluxbounds.(fbc_list{f}).fbc_value{indBds(b)};
                                        case 3
                                            fbc_lb(i)=convertedFluxbounds.(fbc_list{f}).fbc_value{indBds(b)};
                                            fbc_ub(i)=convertedFluxbounds.(fbc_list{f}).fbc_value{indBds(b)};

                                    end
                                end

                            end
                            %%% start of the depreicated code chunk %%%
                            %                             try
                            %
                            %                             ind=find(strcmp(listOfboundKeys,modelSBML.(fbc_list{f})(2*i-1).fbc_operation));
                            %                             catch
                            % %                                 find(strcmp(modelSBML.reaction(1).id,convertedFluxbounds.fbc_fluxBound.fbc_reaction))
                            %                                 disp('good');
                            %                                 find(strcmp(modelSBML.reaction(i).id,convertedFluxbounds.fbc_fluxBound.id))
                            %                                 % index text
                            %                                 indUpper=find(strcmp(modelSBML.reaction(i).id,fbc_upperFluxBound,convertedFluxbounds.fbc_fluxBound.id)); % index text
                            %                             end
                            %

                            %
                            %                             if ind==1 % In the first case, the first row contains a lower bound, wheresas the second contains a upper bound
                            %                                 fbc_lb(i)=modelSBML.(fbc_list{f})(2*i-1).fbc_value;
                            %                                 fbc_ub(i)=modelSBML.(fbc_list{f})(2*i).fbc_value;
                            %                             else ind==2  % In the second case, the first row contains a upper bound, wheresas the second contains a lower bound
                            %                                 fbc_ub(i)=modelSBML.(fbc_list{f})(2*i-1).fbc_value;
                            %                                 fbc_lb(i)=modelSBML.(fbc_list{f})(2*i).fbc_value;
                            %                             end
                            %                         else % in case that there is an empty structure, the default bounds are assigned.
                            %                             if rev(i)==0
                            %                                 fbc_lb(i)=0;
                            %                                 fbc_ub(i)=defaultBound;
                            %                             else
                            %                                 fbc_lb(i)=-defaultBound;
                            %                                 fbc_ub(i)=defaultBound;
                            %                             end
                            %%% end of the depreicated code chunk %%%
                        end
                    end
                end
            elseif modelSBML.fbc_version==2;
                %                         if isnumeric(modelSBML.reaction(i).fbc_lowerFluxBound)
                %                             fbc_lb(i)=modelSBML.reaction(i).fbc_lowerFluxBound;
                %                         else
                %                             fbc_lb(i)=-1000; % in the case the field contains 'low';
                %                         end
                %
                %                         if isnumeric(modelSBML.reaction(i).fbc_upperFluxBound)
                %                             fbc_ub(i)=modelSBML.reaction(i).fbc_upperFluxBound;
                %                         else
                %                             fbc_ub(i)=1000;    % in the case the field contains 'high';
                %                         end
                %                         modelSBML.reaction(i).fbc_lowerFluxBound
                %
                %                         modelSBML.reaction(i).fbc_upperFluxBound
                try
                    indLow=find(strcmp(modelSBML.reaction(i).fbc_lowerFluxBound,converted.parameter.id)); % index text
                    indUpper=find(strcmp(modelSBML.reaction(i).fbc_upperFluxBound,converted.parameter.id)); % index text
                catch
                    indLow=[];
                    indUpper=[];
                end
                if ~isempty(indLow)
                    fbc_lb(i)=converted.parameter.value{indLow}; % bound values
                else % in case that there is an empty structure, the default bounds are assigned.
                    if rev(i)==0
                        fbc_lb(i)=0;
                    else
                        fbc_lb(i)=-defaultBound;
                    end
                end
                if ~isempty(indUpper)
                    fbc_ub(i)=converted.parameter.value{indUpper}; % bound values
                else
                    if rev(i)==0
                        fbc_ub(i)=defaultBound;
                    else
                        fbc_ub(i)=defaultBound;
                    end
                end

                % model.(fbc_list{fbc_i})=modelSBML.(fbc_list{fbc_i});
            end
        end
    else
        % if the SBML file is not a FBC file.
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

end

%% gene


warning off
%% Construct gene to rxn mapping

if isfield(modelSBML,'fbc_version')&&modelSBML.fbc_version==2   % in the case of the fbc v2 file, the gene products are stored in the different XML attributes
    allGenes = {};
    for i=1:size(modelSBML.fbc_geneProduct,2)
        allGenes{i,1}=modelSBML.fbc_geneProduct(i).fbc_label; % according to Recon2 COBRA structure, 'allGenes' are converted to "model.genes".
    end
end

allGenes = unique(allGenes);

if (hasNotesField)||(isfield(modelSBML,'fbc_version')&&(modelSBML.fbc_version==2))
    rxnGeneMat = sparse(nRxns,length(allGenes));
    for i = 1:nRxns
        if iscell(genes{i})
            [tmp,geneInd] = ismember(genes{i},allGenes);
        else
            [tmp,geneInd] = ismember(num2cell(genes{i}),allGenes);
        end
        rxnGeneMat(i,geneInd) = 1;
        for j = 1:length(geneInd)
            rules{i} = strrep(rules{i},['x(' num2str(j) ')'],['x(' num2str(geneInd(j)) '_TMP_)']);
        end
        rules{i} = strrep(rules{i},'_TMP_','');
    end
end
%% Construct metabolite list
mets = cell(nMets,1);
compartmentList = cell(length(modelSBML.compartment),1);

if isempty(compSymbolList)
    useCompList = true;
else
    useCompList = false;
end

for i=1:length(modelSBML.compartment)
    compartmentList{i} = modelSBML.compartment(i).id;
end

hasAnnotationField = 0;

listSpeciesField={'fbc_charge';'fbc_chemicalFormula';'isSetfbc_charge';'fbc_version'};

for i = 1:nMets
    % Parse metabolite id's
    % Get rid of the M_ in the beginning of metabolite id's
    metID = regexprep(speciesList{i},'^M_','');
    metID = regexprep(metID,'^_','');
    % Find compartment id
    tmpCell = {};
    if useCompList
        for j=1:length(compartmentList)
            tmpCell = regexp(metID,['_(' compartmentList{j} ')$'],'tokens'); % search the metID for compartment IDs.
            if ~isempty(tmpCell), break; end
        end
        if isempty(tmpCell), useCompList = false; end
    elseif ~isempty(compSymbolList)
        for j = 1: length(compSymbolList)
            tmpCell = regexp(metID,['_(' compSymbolList{j} ')$'],'tokens');
            if ~isempty(tmpCell), break; end
        end
        %     else
        %         modelSBML.species(1).compartment;
    end

    % 31/03/2016
    %     if isempty(tmpCell), tmpCell = regexp(metID,'_(.)$','tokens'); end

    if ~isempty(tmpCell)
        compID = tmpCell{1};
        metTmp = [regexprep(metID,['_' compID{1} '$'],'') '[' compID{1} ']'];
    else
        metTmp = metID;
        if ~isempty(modelSBML.species(i).compartment)
            metTmp=regexprep(metTmp,'(\[[a-z]{1,2}\])$','');
            metTmp=[metTmp,'[',modelSBML.species(i).compartment,']'];
        end
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
        [tmp,tmp,tmp,tmp,tokens] = regexp(metNamesTmp,'(.*)_((((A|Ag|As|C|Ca|Cd|Cl|Co|Cu|F|Fe|H|Hg|I|K|L|M|Mg|Mn|Mo|N|Na|Ni|O|P|R|S|Se|U|W|X|Y|Zn)?)(\d*)))*$');
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
    % parse the anotation fields of the species structures
    if isfield(modelSBML.species(i),'annotation')
        hasAnnotationField = 1;
        % %         if i==2 % for debugging
        % %             disp('good');
        % %         end

        if exist('parseSBMLAnnotationField','file')
            [metCHEBI,metHMDBparsed,metKEGG,metPubChem,metInChI] = parseSBMLAnnotationField(modelSBML.species(i).annotation); %% replace the older version of the function with the newer version
            metChEBIID{i} = metCHEBI;
            metHMDB{i}=metHMDBparsed;
            metKEGGID{i} = metKEGG;
            metPubChemID{i} = metPubChem;
            metInChIString{i} = metInChI;
        else
            warning('parseSBMLAnnotationField is not on the Matlab path');

        end

    end
    %%%%%%%%%%%% charge and formula %%%%%%%%%%%%
    if isfield(modelSBML,'fbc_version')
        for s=1:length(listSpeciesField);
            fbcMet.(listSpeciesField{s}){i,1}=modelSBML.species(i).(listSpeciesField{s});

        end
    end
end

%% Collect everything into a structure

model.modelVersion=modelVersion;
model.rxns = rxns;
model.mets = mets;
model.S = S;
model.rev = rev;
model.c = c;
if nMets~=0
    if (formulaCount < 0.9*nMets)
        model.metNames = columnVector(metNamesAlt);
    else

        model.metNames = columnVector(metNames);
        model.metFormulas = columnVector(metFormulas);
    end
else
    warning on;
    warning('no metabolite defined in the SBML file');
end

if ~isfield(modelSBML,'fbc_version') % % in the case of an older SBML file.
    model.lb = lb;
    model.ub = ub;
    model.metCharge = columnVector(chargeList);
else    % in the case of fbc file
    model.lb = fbc_lb;
    model.ub = fbc_ub;
    if noObjective==0; % when there is an objective function
        indexObj=findRxnIDs(model,fbc_obj);
        % indexObj=find(strcmp(fbc_obj,model.rxns))
        model.c(indexObj)=1;
        model.osense = - sign(fbc_obj_value);
    end

    if all(cellfun('isempty',fbcMet.fbc_chemicalFormula))~=1  % if all formulas are empty
        % model.objFunction=fbc_obj;
        model.metFormulas=fbcMet.fbc_chemicalFormula;
    end

    for num=1:length(fbcMet.fbc_chemicalFormula);
        model.metCharge(num,1)=double(fbcMet.fbc_charge{num});
        %         model.isSetfbc_charge(num,1)=double(fbcMet.isSetfbc_charge{num});
    end
    % model.fbc_version=modelSBML.fbc_version;

    % % % %     str={'fbc_activeObjective';
    % % % %         'fbc_objective';
    % % % %         'fbc_version';}
    % % % % %     for i=1:length(str);
    % % % % %         model.(str{i})=modelSBML.(str{i});
    % % % % %     end
    %
    % 1.identify new fields that appear in the FBCv2 structure
    % but not in the COBRA structure.

    % % % % Ensure all the information stored in the new FBCv2 fields is passed to the COBRA structure.
    % % %     listCOBRA=fieldnames(model);
    % % %     listSBML=fieldnames(modelSBML);
    % % %     ind=find(~ismember(listSBML,listCOBRA));
    % % %     for i=transpose(ind)
    % % %         model.(listSBML{i})=modelSBML.(listSBML{i});
    % % %     end

    % model.fbc2=modelSBML;
    % model=changeObjective(model,modelSBML.fbc_objective.fbc_id,-1) % be default set the objective function to maximisation
    %     modelSBML.fbc_objective.fbc_fluxObjective.fbc_reaction

end

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
if isfield(modelSBML,'fbc_version')

    if modelSBML.fbc_version==2
        model.rules = rules;
        model.genes = columnVector(allGenes);
        model.rxnGeneMat = rxnGeneMat;
        model.grRules = columnVector(grRules);
    end
end

if nRxns~=0
    model.rxnNames = columnVector(rxnNames);
else
    warning on;
    warning('no reaction defined in the SBML file');
end


% Only include formulas if at least 90% of metabolites have them (otherwise
% the "formulas" are probably just parts of metabolite names)

if (hasAnnotationField)
    model.metChEBIID = columnVector(metChEBIID);
    model.metHMDB = columnVector(metHMDB);
    model.metKEGGID = columnVector(metKEGGID);
    model.metPubChemID = columnVector(metPubChemID);
    model.metInChIString = columnVector(metInChIString);
end

end


function modelSBML =  readSBMLCbModel(fileName,defaultBound,compSymbolList,compNameList)
%
% Implement "TranslateSBML" functiont to read the SBML model file.
%
if ~(exist(fileName,'file'))
    error(['Input file ' fileName ' not found']);
end

if isempty(compSymbolList)
    compSymbolList = {'c','m','v','x','e','t','g','r','n','p'};
    compNameList = {'Cytosol','Mitochondria','Vacuole','Peroxisome','Extra-organism','Pool','Golgi Apparatus','Endoplasmic Reticulum','Nucleus','Periplasm'};
end

% Read SBML
validate=0;
verbose=0;% Ronan Nov 24th 2014
modelSBML = TranslateSBML(fileName,validate,verbose);

% % Convert
% model = convertSBMLToCobra(modelSBML,defaultBound,compSymbolList,compNameList);
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

function vec = columnVector(vec)
%columnVector Converts a vector to a column vector
%
% vec = columnVector(vec)
%
% Markus Herrgard

[n,m] = size(vec);

if (n < m)
    vec = vec';
end

end
