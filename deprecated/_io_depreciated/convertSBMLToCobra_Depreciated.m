function model = convertSBMLToCobra(modelSBML,defaultBound,compSymbolList,compNameList)
%convertSBMLToCobra Convert SBML format model (created using SBML Toolbox)
%to Cobra format
%
% model = convertSBMLToCobra(modelSBML,defaultBound)
%
%INPUTS
% modelSBML         SBML model structure
%
%OPTIONAL INPUTS
% defaultBound      Maximum bound for model (Default = 1000)
% compSymbolList    List of compartment symbols
% compNameList      List of compartment names corresponding to compSymbolList
%
%OUTPUT
% model             COBRA model structure
% Markus Herrgard 1/25/08
%
% Ines Thiele 01/27/2010 - I added new field to be read-in from SBML file
% if provided in file (e.g., references, comments, metabolite IDs, etc.)
%
% Richard Que 02/08/10 - Properly format reaction and metabolite fields
%                        from SBML.
%
% Longfei Mao 23/09/15 - Add the support for FBCv2 package

if (nargin < 2)
    defaultBound = 1000;
end

if nargin < 3
    compSymbolList = {};
    compNameList = {};
end

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
            tmpSpecies = [ tmpSpecies  modelSBML.species(i)];
            speciesList{end+1} = modelSBML.species(i).id;
            notesField = modelSBML.species(i).notes;
            % Get formula if in notes field
            if (~isempty(notesField))
                [tmp,tmp,tmp,tmp,formula,tmp,tmp,tmp,tmp,charge] = parseSBMLNotesField(notesField);
                tmpCharge = charge;
                metFormulas {end+1} = formula;
                formulaCount = formulaCount + 1;
                haveFormulasFlag = true;
            end
            try
                chargeList= [chargeList modelSBML.species(i).charge];
            catch ME
                disp('error');
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
%h = waitbar(0,'Reading SBML file ...');
hasNotesField = false;

fbc_lb = zeros(nRxns,1);
fbc_ub = zeros(nRxns,1);

para_version='';

for i = 1:nRxns
    %if mod(i,10) == 0
    %    waitbar(i/nRxns,h);
    %end
    % Read the gpra from the notes field
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
            S(speciesID,i) = -stoichCoeff;
        end
    end
    productStruct = modelSBML.reaction(i).product;
    for j = 1:length(productStruct)
        speciesID = find(strcmp(productStruct(j).species,speciesList));
        if (~isempty(speciesID))
            stoichCoeff = productStruct(j).stoichiometry;
            S(speciesID,i) = stoichCoeff;
        end
    end
    
   % Convert conventional bounds to FBC bounds
    modelVersion=struct();
    if isfield(modelSBML,'fbc_version')
        para_version='fbc';    % Set a     
        fieldnameList=fieldnames(modelSBML);
        regMatch='(fbc_).+';
        result=regexpi(fieldnameList,regMatch); % Regular expression used to identify new FBC fields
        values=~cellfun('isempty',result);
        existed_fbc_list=fieldnameList(values);
        % Define a list of fbc extension keywords supported by COBRA
        fbc_list={'fbc_version'; 'fbc_activeObjective'; 'fbc_objective'; 'fbc_fluxBound'}; % Four new fields defined by FBC
        verList={'SBML_level'; 'SBML_version'; 'fbc_version'};
        listOfboundKeys={'greaterEqual';'lessEqual'};        
        listOffbc_type={'maximize','minimize'};
        for fbc_v=1:length(verList);
            if ismember(verList(fbc_v),fieldnameList);
                modelVersion.(verList{fbc_v})=modelSBML.(verList{fbc_v}); % Store FBC versions in the COBRA structure
            end
        end
        for fbc_i=1:length(fbc_list)

            if ismember(fbc_list(fbc_i),existed_fbc_list);
                if fbc_i==3 % In the case of fbc_objective
                    
                    fbc_obj=modelSBML.(fbc_list{fbc_i}).fbc_fluxObjective.fbc_reaction; % the variable stores the objective reaction ID
                    fbc_obj=regexprep(fbc_obj,'^R_','');                    
                    ind_obj=find(strcmp(listOffbc_type,modelSBML.(fbc_list{fbc_i}).fbc_type));                    
                    switch ind_obj
                        case 1 % maximise
                            fbc_obj_value=-1;
                        case 2 % minimise
                            fbc_obj_value=1;
                    end
                elseif fbc_i==4 % In the case of fbc_fluxBound
                    ind=find(strcmp(listOfboundKeys,modelSBML.(fbc_list{fbc_i})(2*i-1).fbc_operation));
                    if ind==1 % In the first case, the first row contains a lower bound, wheresas the second contains a upper bound
                        fbc_lb(i)=modelSBML.(fbc_list{fbc_i})(2*i-1).fbc_value;
                        fbc_ub(i)=modelSBML.(fbc_list{fbc_i})(2*i).fbc_value;
                    else ind==2  % In the second case, the first row contains a upper bound, wheresas the second contains a lower bound
                        fbc_ub(i)=modelSBML.(fbc_list{fbc_i})(2*i-1).fbc_value;
                        fbc_lb(i)=modelSBML.(fbc_list{fbc_i})(2*i).fbc_value;
                    end
                end
                % model.(fbc_list{fbc_i})=modelSBML.(fbc_list{fbc_i});                
            end                        
        end        
    else
        para_version='non_fbc'; % if the SBML file is not a FBC-supporting  
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
%close the waitbar if this is matlab
% if (regexp(version, 'R20'))
%     close(h);
% end
allGenes = unique(allGenes);

%% Construct gene to rxn mapping
if (hasNotesField)
    
    rxnGeneMat = sparse(nRxns,length(allGenes));
    %h = waitbar(0,'Constructing GPR mapping ...');
    for i = 1:nRxns
        %if mod(i,10) == 0
        %     waitbar(i/nRxns,h);
        % end
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
    %     %close the waitbar if this is matlab
    %     if (regexp(version, 'R20'))
    %         close(h);
    %     end
    
end

%% Construct metabolite list
mets = cell(nMets,1);
compartmentList = cell(length(modelSBML.compartment),1);
if isempty(compSymbolList), useCompList = true; else useCompList = false; end
for i=1:length(modelSBML.compartment)
    compartmentList{i} = modelSBML.compartment(i).id;
end

%h = waitbar(0,'Constructing metabolite lists ...');
hasAnnotationField = 0;
for i = 1:nMets
    %if mod(i,10) == 0
    %    waitbar(i/nMets,h);
    %end
    % Parse metabolite id's
    % Get rid of the M_ in the beginning of metabolite id's
    metID = regexprep(speciesList{i},'^M_','');
    metID = regexprep(metID,'^_','');
    % Find compartment id
    tmpCell = {};
    if useCompList
        for j=1:length(compartmentList)
            tmpCell = regexp(metID,['_(' compartmentList{j} ')$'],'tokens');
            if ~isempty(tmpCell), break; end
        end
        if isempty(tmpCell), useCompList = false; end
    elseif ~isempty(compSymbolList)
        for j = 1: length(compSymbolList)
            tmpCell = regexp(metID,['_(' compSymbolList{j} ')$'],'tokens');
            if ~isempty(tmpCell), break; end
        end
    end
    if isempty(tmpCell), tmpCell = regexp(metID,'_(.)$','tokens'); end
    if ~isempty(tmpCell)
        compID = tmpCell{1};
        metTmp = [regexprep(metID,['_' compID{1} '$'],'') '[' compID{1} ']'];
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
    if isfield(modelSBML.species(i),'annotation')
        hasAnnotationField = 1;
        [metCHEBI,metKEGG,metPubChem,metInChI] = parseSBMLAnnotationField(modelSBML.species(i).annotation);
        metChEBIID{i} = metCHEBI;
        metKEGGID{i} = metKEGG;
        metPubChemID{i} = metPubChem;
        metInChIString{i} = metInChI;
    end
    

   if strcmp(para_version, 'fbc')
    listSpeciesField={'fbc_charge';'fbc_chemicalFormula';'isSetfbc_charge';'fbc_version'};
    
    for s=1:length(listSpeciesField);
        
        fbcMet.(listSpeciesField{s}){i,1}=modelSBML.species(i).(listSpeciesField{s});
        
    end
   end
   
end
% if ( regexp( version, 'R20') )
%     close(h);
% end


%% Collect everything into a structure

model.modelVersion=modelVersion;
model.rxns = rxns;
model.mets = mets;
model.S = S;
model.rev = rev;

% model.fbc_lb=fbc_lb;
% model.fbc_ub=fbc_ub;
% 
% model.fbc_obj_value=fbc_obj_value;

model.c = c;


if (formulaCount < 0.9*nMets)
    model.metNames = columnVector(metNamesAlt);
else
    model.metNames = columnVector(metNames);
    model.metFormulas = columnVector(metFormulas);
end
    
if strcmp(para_version, 'fbc') % Check if it is a SBML with FBC file
    model.lb = fbc_lb;
    model.ub = fbc_ub;        
    ind_new=findRxnIDs(model,fbc_obj);        
    model.c(ind_obj)=fbc_obj_value;
    model.objFunction=fbc_obj;
    model.metFormulas=fbcMet.fbc_chemicalFormula;
    
    for num=1:length(fbcMet.fbc_chemicalFormula); % Convert FBC formats of the variable fields into COBRA formats
        model.metCharge=double(fbcMet.fbc_charge{num});
        model.isSetfbc_charge=double(fbcMet.isSetfbc_charge{num});
    end
    model.fbc_version=fbcMet.fbc_version;
    str={'fbc_activeObjective'; % Construct FBC fields that are used in FBCv2 scheme.
        'fbc_objective';
        'fbc_version';}
    for i=1:length(str);
        model.(str{i})=modelSBML.(str{i});
    end
    % Identify new fields that appear in the FBCv2 structure but not in the COBRA structure.
    listCOBRA=fieldnames(model);
    listSBML=fieldnames(modelSBML);
    ind=find(~ismember(listSBML,listCOBRA));
    for i=1:ind
        model.(listSBML{i})=modelSBML.(listSBML{i});
    end
    model.fbc2str=modelSBML;
    
    % model=changeObjective(model,modelSBML.fbc_objective.fbc_id,-1) % By default set the objective function to maximisation
    
    modelSBML.fbc_objective.fbc_fluxObjective.fbc_reaction

elseif strcmp(para_version, 'non_fbc') 
    model.lb = lb;
    model.ub = ub;
    model.metCharge = transpose(chargeList);

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

model.rxnNames = columnVector(rxnNames);
% Only include formulas if at least 90% of metabolites have them (otherwise
% the "formulas" are probably just parts of metabolite names)


if (hasAnnotationField)
    model.metChEBIID = columnVector(metChEBIID);
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
