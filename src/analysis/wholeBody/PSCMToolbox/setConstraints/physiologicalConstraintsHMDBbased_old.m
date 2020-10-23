function modelConstraint = physiologicalConstraintsHMDBbased(model,IndividualParameters, ExclList, Type, InputData, Biofluid, setDefault)
% apply constraints to Harvey
% metabolite concentrations have to be given in uM
% organ weights have to be given in g
%
% INPUT
% model                     model structure
% IndividualParameters      Structure containing physiological parameters,
%                           as generated in standardPhysiolDefaultParameters
% Type                      Input type (either 'xlsx' (default) --> loads by default
%                           'Parsed_hmdbConc.xlsx' or 'direct'). If
%                           'direct' InputData must be provided
% InputData                 first column corresponds to vmh id's of
%                           metabolites, 2nd to data points (will be set as lb and ub)
% Biofluid                  'all' (default if type is xlsx). For direct:
%                            'bc','u','csf'
%
%
% OUTPUT
% modelConstraint           model structure with updated constraints
%
% Ines Thiele, 2015/2016

modelConstraint = model;

setLB = 0;


%% Input physiological data
%standardPhysiolDefaultParameters;
gender = IndividualParameters.gender;
sex = IndividualParameters.sex;
CardiacOutput = IndividualParameters.CardiacOutput;

% default maximum concentration of a metabolite in blood plasma
MConDefaultBc = IndividualParameters.MConDefaultBc;

% default maximum concentration of a metabolite in csf
MConDefaultCSF = IndividualParameters.MConDefaultCSF;

% default maximum concentration of a metabolite in Ur
MConDefaultUrMax = IndividualParameters.MConDefaultUrMax;
MConDefaultUrMin = IndividualParameters.MConDefaultUrMin;

% creatinine concentration in urine
MConDefaultUrCreatinineMax = IndividualParameters.MConUrCreatinineMax;
MConDefaultUrCreatinineMin = IndividualParameters.MConUrCreatinineMin;

% CSF Flow rate
CSFFlowRate = IndividualParameters.CSFFlowRate;

% CSF Blood Flow rate
CSFBloodFlowRate = IndividualParameters.CSFBloodFlowRate;

% Urine flow rate
UrFlowRate = IndividualParameters.UrFlowRate;

% Hematocrite
Hematocrit = IndividualParameters.Hematocrit;

% lower concentration limit for setting a concentration constraint
MinConcConstraint = 5;
MaxConcConstraint = 50;
bloodFlowData = IndividualParameters.bloodFlowData;
bloodFlowPercCol = IndividualParameters.bloodFlowPercCol;
bloodFlowOrganCol = IndividualParameters.bloodFlowOrganCol;
% List of organs
OrganLists;

%% calculate GFR = Glomerular filtration rate
% the filtration fraction should be 20% of the renal plasma flow
%GlomerularFiltrationRate = IndividualParameters.GlomerularFiltrationRate; % in ml/min
RenalFiltrationFraction  = 0.2; %20%

% blood flow percentage that Kidney gets
if strcmp(gender,'male')
    BK = bloodFlowData{strmatch('Kidney',bloodFlowData(:,1),'exact'),bloodFlowPercCol(1)};
elseif strcmp(gender,'female')
    BK = bloodFlowData{strmatch('Kidney',bloodFlowData(:,1),'exact'),bloodFlowPercCol(2)};
    % BK = bloodFlowData{strmatch('Kidney',bloodFlowData(:,1),'exact'),4};
end
BK = str2num(BK(2:end-1));
RenalFlowRate=BK*CardiacOutput*(1-Hematocrit); % k_plasma_organ in ml/min
GlomerularFiltrationRate = RenalFlowRate*RenalFiltrationFraction;% in ml/min
%% read data
% read metabolic concentrations from HMDB if no input data are defined
if ~exist('InputData','var')
    Type = 'HMDB';
    Biofluid = 'all';
end
if ~exist('Type','var')
    Type = 'HMDB';
end
if ~exist('ExclList','var')
ExclList = '';
end
% default concentrations will be applied as constraints if not specified
% differently
if ~exist('setDefault','var')
    setDefault = 1; % default is true
end

if strcmp(Type,'HMDB')
    % BLOOD
    Biofluid = 'all';
    fileName='NormalBloodConcExtractedHMDB.txt';
    [Data] =importdata(fileName);
    
    % find start/header of data - Blood
    % find data start
    Start= (find(~cellfun(@isempty,strfind(Data.textdata(:,1),'####'))))+1;
    % find rxn abbr
    VMHIDCol= (find(~cellfun(@isempty,strfind(Data.textdata(Start,:),'VMH'))));
    MetConMin = (Data.data(:,1));% min = 1st col, max = 2nd col
    MetConMin = cellstr(num2str(MetConMin));
    MetConMin = regexprep(MetConMin,' ','');
    for j = 1 : size(MetConMin,1)
        MetConMin{j,1} = (MetConMin(j,1));
    end
    
    MetConMax = (Data.data(:,2));% min = 1st col, max = 2nd col
    MetConMax = cellstr(num2str(MetConMax));
    MetConMax = regexprep(MetConMax,' ','');
    for j = 1 : size(MetConMax,1)
        MetConMax{j,1} = (MetConMax(j,1));
    end
    metConcDataBc=[Data.textdata(Start+1:end,VMHIDCol) MetConMin MetConMax];
    maxConcColBc = 3;
    minConcColBc = 2;
    VMHIDCol = 1;
    
    % CSF;
    fileName='NormalCSFConcExtractedHMDB.txt';
    [Data] =importdata(fileName);
    
    % find start/header of data - Blood
    % find data start
    Start= (find(~cellfun(@isempty,strfind(Data.textdata(:,1),'####'))))+1;
    % find rxn abbr
    VMHIDCol= (find(~cellfun(@isempty,strfind(Data.textdata(Start,:),'VMH'))));
    MetConMin = (Data.data(:,1));% min = 1st col, max = 2nd col
    MetConMin = cellstr(num2str(MetConMin));
    MetConMin = regexprep(MetConMin,' ','');
    for j = 1 : size(MetConMin,1)
        MetConMin{j,1} = (MetConMin(j,1));
    end
    
    MetConMax = (Data.data(:,2));% min = 1st col, max = 2nd col
    MetConMax = cellstr(num2str(MetConMax));
    MetConMax = regexprep(MetConMax,' ','');
    for j = 1 : size(MetConMax,1)
        MetConMax{j,1} = (MetConMax(j,1));
    end
    metConcDataCSF=[Data.textdata(Start+1:end,VMHIDCol) MetConMin MetConMax];
    maxConcColCSF = 3;
    minConcColCSF = 2;
    VMHIDCol = 1;
    
    % URINE
    fileName='NormalUrineConcExtractedHMDB.txt';
    [Data] =importdata(fileName);
    
    % find start/header of data -
    % find data start
    Start= (find(~cellfun(@isempty,strfind(Data.textdata(:,1),'####'))))+1;
    % find rxn abbr
    VMHIDCol= (find(~cellfun(@isempty,strfind(Data.textdata(Start,:),'VMH'))));
    MetConMin = (Data.data(:,1));% min = 1st col, max = 2nd col
    MetConMin = cellstr(num2str(MetConMin));
    MetConMin = regexprep(MetConMin,' ','');
    for j = 1 : size(MetConMin,1)
        MetConMin{j,1} = (MetConMin(j,1));
    end
    
    MetConMax = (Data.data(:,2));% min = 1st col, max = 2nd col
    MetConMax = cellstr(num2str(MetConMax));
    MetConMax = regexprep(MetConMax,' ','');
    for j = 1 : size(MetConMax,1)
        MetConMax{j,1} = (MetConMax(j,1));
    end
    metConcDataUr=[Data.textdata(Start+1:end,VMHIDCol) MetConMin MetConMax];
    maxConcColUr = 3;
    minConcColUr = 2;
    VMHIDCol = 1;
    
elseif strcmp(Type,'direct')%direct data input
    VMHIDCol = 1; % first column corresponds to vmh id's, 2nd to data points (min), 3rd to data points (max)
    setLB = 1;
    if strcmp(Biofluid,'bc')%blood data
        minConcColBc = 2;
        maxConcColBc = 3;
        metConcDataBc = InputData;
    elseif strcmp(Biofluid,'csf')%blood data
        minConcColCSF = 2;
        maxConcColCSF = 3;
        metConcDataCSF = InputData;
    elseif strcmp(Biofluid,'u')%blood data
        minConcColUr = 2;
        maxConcColUr = 3;
        metConcDataUr = InputData;
    end
end
%% compute constraints
% Feher, p. 550 Q8!
% the following assumptions are made
% 1. steady-state
% 2. transport is bulk flow limited, not diffusion limited,  which is at
%    least true for higher blood flow rates
% 3. the metabolites is maximally consumed by tissue (gives an upper bound),
%    for metabolites for which the venal concentration is known the
%    difference between arterial and venal concentration should be rather used.
% Equation:
% Q = (ca-cv)*Qv - Feher, p 550, Ex 8
% vmax_met_organ = conc_met_max * k_blood_organ % no organ scaling
% necessary as those numbers are already adjusted to organs (in part to
% weight but also requirements)

% cardiac output and organ-specific blood flow rate
for i = 1 : length(OrgansListExt)
    BloodFlowOrgan(i,1)=OrgansListExt(i); %percentage of blood flow going to each organ
    tmp = strmatch(OrgansListExt(i),bloodFlowData(:,bloodFlowOrganCol),'exact');
    if ~isempty(tmp) && tmp>0
        if strcmp(IndividualParameters.gender,'male') % use first col
            B = bloodFlowData{tmp,bloodFlowPercCol(1)};
        elseif strcmp(IndividualParameters.gender,'female') % use 2nd col
            B = bloodFlowData{tmp,bloodFlowPercCol(2)};
        end
        B = str2num(B(2:end-1));
        if  ~isempty(B)
            BloodFlowRate(i,1)=(B)*CardiacOutput; % k_blood_organ in ml/min
            PlasmaFlowRate(i,1)=(B)*CardiacOutput*(1-Hematocrit); % k_plasma_organ in ml/min
        else
            % if no information is provided for percentage, assume 1%
            BloodFlowRate(i,1)=0.01*CardiacOutput; % k_blood_organ in ml/min
            PlasmaFlowRate(i,1)=0.01*CardiacOutput*(1-Hematocrit); % k_blood_organ in ml/min
        end
    elseif strcmp('BBB',OrgansListExt(i))% exception of BBB which gets the flow rate of Scord and Brain
        Scord = strmatch('Scord',bloodFlowData(:,bloodFlowOrganCol),'exact');
        Brain = strmatch('Brain',bloodFlowData(:,bloodFlowOrganCol),'exact');
        
        if strcmp(IndividualParameters.gender,'male') % use first col
            BScord = bloodFlowData{Scord,bloodFlowPercCol(1)};
            BBrain = bloodFlowData{Brain,bloodFlowPercCol(1)};
        elseif strcmp(IndividualParameters.gender,'female') % use 2nd col
            BScord = bloodFlowData{Scord,bloodFlowPercCol(2)};
            BBrain = bloodFlowData{Brain,bloodFlowPercCol(2)};
        end
        
        BScord = str2num(BScord(2:end-1));
        BBrain = str2num(BBrain(2:end-1));
        B = BBrain + BScord;
        
        BloodFlowRate(i,1)=(B)*CardiacOutput; % k_blood_organ in ml/min
        PlasmaFlowRate(i,1)=(B)*CardiacOutput*(1-Hematocrit); % k_plasma_organ in ml/min
    else
        % if no information is provided for percentage, assume 1%
        BloodFlowRate(i,1)=0.01*CardiacOutput; % k_blood_organ in ml/min
        PlasmaFlowRate(i,1)=0.01*CardiacOutput*(1-Hematocrit); % k_blood_organ in ml/min
    end
end

% Organs excluded from secretion into [bc]
ExclOrgan={'sIEC', 'Colon','Spleen','Pancreas','Gall','Brain'};

% compute maximal possible uptake and secretion rate for each metabolite in
% each organ
if strcmp( Biofluid, 'bc') || strcmp( Biofluid, 'all')
    for i = 1 : length(OrgansListExt)
        % find uptake and secretion reactions
        if ~isempty(strmatch('BBB',OrgansListExt{i})) %BBB for brain constraints
            ExR = find(~cellfun(@isempty,strfind(modelConstraint.rxns,'[CSF]upt'))); % uptake from [bc] into [csf] only
        else
            ExR = strmatch(strcat(OrgansListExt{i},'_EX_'),modelConstraint.rxns);
        end
        if ~isempty(ExR)
            for j = 1 : length(ExR)
                % ensure that the exchange is FROM BLOOD
                if (length(strfind(modelConstraint.rxns{ExR(j)},'[bc]'))>0 || length(strfind(modelConstraint.rxns{ExR(j)},'[CSF]upt'))>0) ...
                        && length(strfind(modelConstraint.rxns{ExR(j)},'_o2s(e)'))==0    ...
                        && length(strfind(modelConstraint.rxns{ExR(j)},'_h2o(e)'))==0 ...
                        && length(strfind(modelConstraint.rxns{ExR(j)},'_H2O[CSF]upt'))==0 %...
             %       && length(strfind(modelConstraint.rxns{ExR(j)},'_co2(e)'))==0
                    %&& length(strfind(modelConstraint.rxns{ExR(j)},'_o2(e)'))==0 ... %no oxygen constraint
                    
                    %  && length(strfind(modelConstraint.rxns{ExR(j)},'_aicar(e)'))==0    ...
                    % && length(strfind(modelConstraint.rxns{ExR(j)},'_CE2705(e)'))==0   % ...
                    
                    %&& length(strfind(modelConstraint.rxns{ExR(j)},'_h2o2(e)'))==0 % avoids setting uptake for o2s, co2, h2o2
                    %&& length(strfind(modelConstraint.rxns{ExR(j)},'_o2(e)'))==0 ... %no oxygen constraint
                    
                    % all reactions are written such that negative flux means
                    % uptake from (bc) and positive flux corresponds to secretion
                    % into (bc)
                    %
                    % get metabolite associated with reaction
                    ExM = modelConstraint.mets(find(modelConstraint.S(:,ExR(j))>0));
                    MCon = [];
                    if ~isempty(ExM)
                        % KIDNEY IS TREATED DIFFERENTLY - checked
                        % 29.04.2016 - IT
                        clear X
                        if ~isempty(strmatch(OrgansListExt(i),'Kidney','exact')) && length(strfind(modelConstraint.rxns{ExR(j)},'[bcK]'))==0
                            % get maximal concentration for metabolite
                            X = find(ismember(strcat(metConcDataBc(:,VMHIDCol),'[bc]'),ExM));
                            clear MConMin MConMax
                            if isempty(X) && ~strcmp(Type,'direct') % no concentration range/maximum defined in input data
                                MConMin = 0;
                                MConMax =  MConDefaultBc;
                            elseif ~isempty(X)
                                MConMin1 = metConcDataBc{X,minConcColBc};
                                MConMax1 = metConcDataBc{X,maxConcColBc};
                                if ischar(MConMin1)
                                    MConMin = str2num(MConMin1(2:end-1));
                                    MConMax = str2num(MConMax1(2:end-1));
                                elseif iscell(MConMin1)
                                    MConMin = MConMin1{1};
                                    MConMin = str2num(MConMin);
                                    MConMax = MConMax1{1};
                                    MConMax = str2num(MConMax);
                                else
                                    MConMin = MConMin1;
                                    MConMax = MConMax1;
                                end
                            else
                                continue;
                            end
                            % MCon is in (umol/L) --> : 1000 to be in mmol/L
                            % PlasmaFlowRate is in (ml/min)
                            % PlasmaFlowRate*60*24/1000 (L/day)
                            % Q = (ca-cv)*Qv; where ca is the aterial
                            % concentration, which is typically not measured, and
                            % cv the venous concentration, reported in HMDB and
                            % measured in general experiments.
                            % in the kidney the flux can go only from
                            % [e]<--[bc] !!!!!!
                            
                            %  UPPER BOUND
                            MSecretRateKidney = 1*(MConMin/1000)*GlomerularFiltrationRate*60*24/1000; % in mmol/day/person
                            R = {'Kidney_EX_na1(e)_[bc]'
                                'Kidney_EX_hco3(e)_[bc]'
                                'Kidney_EX_urea(e)_[bc]'
                                'Kidney_EX_k(e)_[bc]'
                                'Kidney_EX_cl(e)_[bc]'
                                'Kidney_EX_ca2(e)_[bc]'
                                'Kidney_EX_HC02172(e)_[bc]'
                                'Kidney_EX_avite1(e)_[bc]'
                                };
                            R = unique([R;ExclList]);
                            if ~ismember(modelConstraint.rxns(ExR(j)),R)
                                if setLB == 1
                                    modelConstraint.ub(ExR(j)) = -MSecretRateKidney; % maximal possible secretion rate
                                else
                                    if MConMax>=MaxConcConstraint % set lower constraint if max is higher or equal to MinConcConstraint
                                        modelConstraint.ub(ExR(j)) = -MSecretRateKidney; % maximal possible secretion rate
                                    else
                                        modelConstraint.ub(ExR(j)) = 0; % maximal possible secretion rate
                                    end
                                end
                            else
                                modelConstraint.ub(ExR(j)) = 0;
                            end
                            % LOWER BOUND
                            MSecretRateKidney = 1*(MConMax/1000)*GlomerularFiltrationRate*60*24/1000; % in mmol/day/person
                            
                            modelConstraint.lb(ExR(j)) = -MSecretRateKidney; % maximal possible secretion rate
                            
                        else
                            %% checked this part of the code - 29.04. IT
                            % get maximal concentration for metabolite
                            X = find(ismember(strcat(metConcDataBc(:,VMHIDCol),'[bc]'),ExM));
                            clear MCon
                            if isempty(X) && setDefault == 1 && ~strcmp(Type,'direct')% no concentration range/maximum defined in input data; only if requested
                                MCon =  MConDefaultBc;
                            elseif ~isempty(X)
                                MCon1 = metConcDataBc{X,maxConcColBc};
                                if ischar(MCon1)
                                    MCon = str2num(MCon1(2:end-1));
                                elseif iscell(MCon1)
                                    MCon = MCon1{1};
                                    MCon = str2num(MCon);
                                else
                                    MCon = MCon1;
                                end
                            else
                                continue;
                            end
                            R = {
                                % added to the list of  rxns excluded to be
                                % constraint - otw infeasible - Nov 2017 -
                                % IT
                                'BBB_NH4[CSF]upt'
                                'BBB_CHOL[CSF]upt'
                                'BBB_PI[CSF]upt'
                                'BBB_STRDNC[CSF]upt'
                                'BBB_HC00250[CSF]upt'
                                'BBB_PYDXN[CSF]upt'
                                'BBB_5MTHF[CSF]upt'
                                'BBB_SO3[CSF]upt'

                                };
                            
                            if ~ismember(modelConstraint.rxns(ExR(j)),R)
                            % MCon is in (umol/L) --> : 1000 to be in mmol/L
                            % PlasmaFlowRate is in (ml/min)
                            % PlasmaFlowRate*60*24/1000 (L/day)
                            % Q = (ca-cv)*Qv; where ca is the aterial
                            % concentration, which is typically not measured, and
                            % cv the venous concentration, reported in HMDB and
                            % measured in general experiments. ca is assumed to be
                            % 30% higher than cv, allowing the tissue to take up
                            % maximally 30% of the maximally reported cv value
                            if ~isempty(MCon)
                                %  MUptakeRateBc = ((MCon*(100/70)-MCon)/1000)*PlasmaFlowRate(i,1)*60*24/1000; % in mmol/day/person
                                MUptakeRateBc = ((MCon)/1000)*PlasmaFlowRate(i,1)*60*24/1000; % in mmol/day/person
                                if  modelConstraint.lb(ExR(j)) < 0;
                                    if MCon>1e-3%abs(MUptakeRateBc)>1e-3; % at least 1 nM
                                        modelConstraint.lb(ExR(j)) = -1*MUptakeRateBc; % maximal possible uptake rate
                                    else
                                        MUptakeRateBc = ((1e-3)/1000)*PlasmaFlowRate(i,1)*60*24/1000; % in mmol/day/person
                                        
                                        modelConstraint.lb(ExR(j)) = -1*MUptakeRateBc;
                                    end
                                end
                                % I cannot set this constraint as an organ
                                % could secrete a metabolite at a higher
                                % local concentration than in the blood but
                                % this gets then balance through the
                                % constribution (or rather lack of) by other
                                % organs
                                %                                 % allowing the tissue to secrete maximally 30% of the maximally reported cv value
                                %                                 if isempty(strmatch(OrgansListExt(i),ExclOrgan,'exact')) &&  modelConstraint.ub(ExR(j))>0
                                %                                     % MSecretRateBc = -1*((MCon*(100/130)-MCon)/1000)*PlasmaFlowRate(i,1)*60*24/1000; % in mmol/day/person
                                %                                     MSecretRateBc = ((MCon)/1000)*PlasmaFlowRate(i,1)*60*24/1000; % in mmol/day/person
                                %                                     % secretion rate does not apply to organs that are only taking up from [bc]
                                %                                     if abs(MCon)>1e-3; % at least 1 nM
                                %                                         modelConstraint.ub(ExR(j)) = MSecretRateBc; % maximal possible secretion rate
                                %                                     else
                                %                                          MSecretRateBc = ((1e-3)/1000)*PlasmaFlowRate(i,1)*60*24/1000; % in mmol/day/person
                                %
                                %                                         modelConstraint.ub(ExR(j)) = MSecretRateBc; % maximal possible secretion rate
                                %                                     end
                                %                                 end0
                            end
                            end
                            
                        end
                    else
                        modelConstraint.rxns(ExR(j));
                    end
                end
            end
        end
    end
    
end
%% BBB/Brain
% compute maximal possible uptake and secretion rate for each metabolite in
% each organ
if strcmp( Biofluid, 'csf') || strcmp( Biofluid, 'all')
    for i = 1 : length(OrgansListExt)
        % find uptake and secretion reactions
        ExR = strmatch('BBB_',modelConstraint.rxns);
        if ~isempty(ExR)
            for j = 1 : length(ExR)
                % ensure that only the export (exp) from csf-> bc receives
                % constraints
                if length(strfind(modelConstraint.rxns{ExR(j)},'[CSF]'))>0 && length(strfind(modelConstraint.rxns{ExR(j)},'exp'))>0 && length(strfind(modelConstraint.rxns{ExR(j)},'_o2(e)'))==0 ... %no oxygen constraint
                        && length(strfind(modelConstraint.rxns{ExR(j)},'_o2s(e)'))==0   && length(strfind(modelConstraint.rxns{ExR(j)},'_co2(e)'))==0
                    % all reactions are written such that negative flux means
                    % uptake from (bc) and positive flux corresponds to secretion
                    % into (bc)
                    
                    % get metabolite associated with reaction
                    ExM = modelConstraint.mets(find(modelConstraint.S(:,ExR(j))<0)); % reactions are written as [csf] <=> [bc]
                    if ~isempty(ExM)
                        % get maximal concentration for metabolite
                        X = find(ismember(strcat(metConcDataCSF(:,VMHIDCol),'[csf]'),ExM));
                        MConMin = [];
                        MConMax = [];
                        if isempty(X) && ~strcmp(Type,'direct') % no concentration range/maximum defined in input data
                            MConMin = 0;
                            MConMax =  MConDefaultCSF;
                        elseif ~isempty(X)
                            MConMin1 = metConcDataCSF{X,minConcColCSF};
                            MConMax1 = metConcDataCSF{X,maxConcColCSF};
                            if ischar(MConMin1)
                                MConMin = str2num(MConMin1(2:end-1));
                                MConMax = str2num(MConMax1(2:end-1));
                            elseif iscell(MConMin1)
                                MConMin = MConMin1{1};
                                MConMin = str2num(MConMin);
                                MConMax = MConMax1{1};
                                MConMax = str2num(MConMax);
                            else
                                MConMin = MConMin1;
                                MConMax = MConMax1;
                            end
                        else
                            continue;
                        end
                        if ~isempty(MConMin)
                            % MCon is in (umol/L) --> : 1000 to be in mmol/L
                            % PlasmaFlowRate is in (ml/min)
                            % PlasmaFlowRate*60*24/1000 (L/day)
                            % Q = (ca-cv)*Qv; where ca is the aterial
                            % concentration, which is typically not measured, and
                            % cv the venous concentration, reported in HMDB and
                            % measured in general experiments.
                            % LOWER BOUND
                            % flux will be positive as reaction is written as
                            % csf --> bc
                            MSecretRateCSF = (MConMin/1000)*CSFBloodFlowRate*60*24/1000; % in mmol/day/person
                            R = { 'na1[csf]'
                                'cl[csf]'
                                'k[csf]'
                                'h2o[csf]'
                                'sucsal[csf]'
                                'ca2[csf]'
                                'ser_D[csf]'};
                            if setLB == 1
                                modelConstraint.lb(ExR(j)) = MSecretRateCSF; % maximal possible secretion rate
                            else
                                if MConMin>=MinConcConstraint && MConMax>=MaxConcConstraint && isempty(find(ismember(R,ExM))) &&isempty(find(ismember(ExclList,modelConstraint.rxns(ExR(j))))) % || ismember(MustBeInCSF,ExM) % ismember(MustBeInCSF,ExM)
                                    modelConstraint.lb(ExR(j)) = MSecretRateCSF; % maximal possible uptake rate
                                else
                                    modelConstraint.lb(ExR(j)) = 0;
                                end
                            end
                            % UPPER BOUND
                            MSecretRateCSF = (MConMax/1000)*CSFFlowRate*60*24/1000; % in mmol/day/person
                            modelConstraint.ub(ExR(j)) = MSecretRateCSF; % maximal possible secretion rate
                            
                        end
                    else
                        modelConstraint.rxns(ExR(j));
                        
                    end
                end
                
            end
        end
    end
end
%% Urine excretion
% constraints are set on Exchange reactions for urine
if strcmp( Biofluid, 'u') || strcmp( Biofluid, 'all')
    
    % convert creatinine from mg/dL into mmol/L
    MWCreat = 113.1179;% g/mol
    MConDefaultUrCreatinineMax = MConDefaultUrCreatinineMax*10/MWCreat;
    MConDefaultUrCreatinineMin = MConDefaultUrCreatinineMin*10/MWCreat;
    ExR = strmatch('EX_',modelConstraint.rxns);
    if ~isempty(ExR)
        for j = 1 : length(ExR)
            if length(strfind(modelConstraint.rxns{ExR(j)},'[u]'))>0 && length(strfind(modelConstraint.rxns{ExR(j)},'_o2(e)'))==0 ... %no oxygen constraint
                    && length(strfind(modelConstraint.rxns{ExR(j)},'_o2s(e)'))==0   && length(strfind(modelConstraint.rxns{ExR(j)},'_co2(e)'))==0
                
                % all reactions are written such that positive flux corresponds to secretion
                % into urine (u)
                %
                % get metabolite associated with reaction
                ExM = modelConstraint.mets(find(modelConstraint.S(:,ExR(j))<0)); % this is a typical exchange reaction
                MConMin = [];
                MConMax = [];
                if ~isempty(ExM)
                    % get maximal concentration for metabolite
                    X = find(ismember(strcat(metConcDataUr(:,VMHIDCol),'[u]'),ExM));
                    if isempty(X) && ~strcmp(Type,'direct')%&& setDefault == 1 % no concentration range/maximum defined in input data, only if requested
                        MConMin =  MConDefaultUrMin;
                        MConMax =  MConDefaultUrMax;
                    elseif ~isempty(X)
                        MConMin1 = metConcDataUr{X,minConcColUr};
                        MConMax1 = metConcDataUr{X,maxConcColUr};
                        if ischar(MConMin1)
                            MConMin = str2num(MConMin1(2:end-1));
                            MConMax = str2num(MConMax1(2:end-1));
                        elseif iscell(MConMin1)
                            MConMin = MConMin1{1};
                            MConMin = str2num(MConMin);
                            MConMax = MConMax1{1};
                            MConMax = str2num(MConMax);
                        else
                            MConMin = MConMin1;
                            MConMax = MConMax1;
                        end
                    else
                        continue;
                    end
                    % Urine excretion
                    % lower bound based on min concentration
                    if ~isempty(MConMin) && ~isempty(MConMax)
                        MSecrRateUrLB = (MConMin/1000)*MConDefaultUrCreatinineMin*UrFlowRate*60*24/1000; % in mmol/day/person
                        % upper bound based on max concentration
                        MSecrRateUrUB = (MConMax/1000)*MConDefaultUrCreatinineMax*UrFlowRate*60*24/1000; % in mmol/day/person
                        R = { 'EX_na1[u]'
                            'EX_cl[u]'
                            'EX_k[u]'
                            'EX_ca2[u]'
                            % non-unique list!
                            %'EX_aldstrn[u]'
                            %         'EX_tststerone[u]'
                            %         'EX_pydxn[u]'
                            %         'EX_3moxtyr[u]'
                            %                'EX_cl[u]'
                            %               'EX_k[u]'
                            %         %         %   'EX_nh4[u]'
                            %         'EX_sphgn[u]' % i dont think that this metabolite is routinely secreted
                            %         'EX_sphings[u]'
                            %         'EX_csn[u]'
                            %         'EX_arab_L[u]'
                            %         'EX_tststerone[u]'
                            %         'EX_tststerone[u]'
                            %         'EX_pydxn[u]'
                            %         'EX_mma[u]'%Methylamine occurs endogenously from amine catabolism and its tissue levels increase in some pathological conditions, including diabetes.
                            %        'EX_tsul[u]'%Thiosulfate occurs naturally in hot springs and geysers, and is produced by certain biochemical processes. In the body, thiosulfate converts small amounts of cyanide ion into harmless products and plays a role in the biosynthesis of cysteine, a sulfur-containing amino acid that locks proteins into their correct three-dimensional shapes. Thiosulfate is not found in large quantities in nature.
                            %
                            
                            % metabolites with lower bound that is non-zero
                            % in data but should be not set as lb
                            % constraints
                            'EX_C05767[u]' %Uroporphyrin I
                            'EX_C05770[u]' %Coproporphyrin III
                            'EX_C05302[u]'% 2-Methoxyestradiol (2ME2) is a drug that prevents the formation of new blood vessels
                            'EX_trypta[u]'%Tryptamine is a monoamine compound that is common precursor molecule to many hormones and neurotransmitters
                            'EX_ppbng[u]'% porphobilinogen is produced in excess and excreted in the urine in acute intermittent porphyria and several other porphyrias.
                            'EX_13dampp[u]'%  It is a catabolic byproduct of spermidine. "The excretion of these  substances is usually very small compared to the respective amino acids. "http://www.sciencedirect.com/science/article/pii/0009898171904426
                            'EX_mhista[u]' %The primary application of urinary N-methylhistamine (NMH) testing is in the diagnosis and monitoring of mast-cell disorders, including mastocytosis, anaphylaxis, and other severe systemic allergic reactions.[1, 2, 3, 4, 5, 6, 7]. The reference range for urinary NMH varies according to subject age, as follows: Age 0-5 years - 120-510 �g/g creatinine; Age 6-16 years - 70-330 �g/g creatinine, Older than16 years - 30-200 �g/g creatinine
                            'EX_tym[u]' %Tyramine and its conjugates occur in normal and abnormal urines, although the biological role of tyramine, if any, is obscure. However, it has recently become of interest because severe Parkinsonians excrete raised amounts of tyraminel-R
                            'EX_2hyoxplac[u]'%2-Hydroxyphenylacetate
                            'EX_pmtcrn[u]'
                            'EX_dheas[u]'
                            'EX_34dhphe[u]' %L-dopa
                            'EX_srtn[u]'
                            'EX_gthrd[u]'
                            'EX_pcholhep_hs[u]'
                            'EX_pcholste_hs[u]'
                            'EX_pcholn204_hs[u]'
                            'EX_3moxtyr[u]'
                            'EX_aldstrn[u]'
                            'EX_tststerone[u]'
                            'EX_pydxn[u]'
                            'EX_sphgn[u]' % i dont think that this metabolite is routinely secreted
                            'EX_sphings[u]'
                            'EX_csn[u]'
                            'EX_arab_L[u]'
                            'EX_tststerone[u]'
                            'EX_tststerone[u]'
                            'EX_pydxn[u]'
                            'EX_mma[u]'%Methylamine occurs endogenously from amine catabolism and its tissue levels increase in some pathological conditions, including diabetes.
                            'EX_tsul[u]'%Thiosulfate occurs naturally in hot springs and geysers, and is produced by certain biochemical processes. In the body, thiosulfate converts small amounts of cyanide ion into harmless products and plays a role in the biosynthesis of cysteine, a sulfur-containing amino acid that locks proteins into their correct three-dimensional shapes. Thiosulfate is not found in large quantities in nature.
                            'EX_5htrp[u]'
                            'EX_7dhchsterol'
                            'EX_etoh[u]'
                            'EX_gsn[u]'
                            'EX_5aop[u]'
                            'EX_uri[u]';
                            'EX_dad_2[u]'
                            'EX_ocdca[u]'
                            'EX_gua[u]'
                            'EX_dcyt[u]'
                            'EX_glyleu[u]'
                            'EX_acald[u]'
                            'EX_HC02191[u]'
                            %%
                            % 'EX_ethamp[u]'
                            };
                        R = unique([R;ExclList]);
                        MustSecrete = {
                            'EX_urea[u]'
                            'EX_nh4[u]'
                            'EX_etha[u]'
                            %   'EX_na1
                            'EX_lcts[u]'
                            'EX_3hmp[u]'
                            'EX_acnam[u]'
                            };
                        
                        if  modelConstraint.ub(ExR(j)) > 0;
                            if    setLB == 1
                                if ~ismember(R,modelConstraint.rxns(ExR(j)))
                                    modelConstraint.lb(ExR(j)) = MSecrRateUrLB; % maximal possible uptake rate
                                    %        modelConstraint.lb(ExR(j)) = 0;
                                else
                                    modelConstraint.lb(ExR(j)) = 0;
                                end
                            else
                                if MConMax>=MaxConcConstraint  && MConMin>=MinConcConstraint && ~ismember(modelConstraint.rxns(ExR(j)),R)%ismember(modelConstraint.rxns(ExR(j)),MustSecrete)% %
                                    modelConstraint.lb(ExR(j)) = MSecrRateUrLB; % maximal possible uptake rate
                                else
                                    modelConstraint.lb(ExR(j)) = 0;
                                end
                            end
                            modelConstraint.ub(ExR(j)) = MSecrRateUrUB; % maximal possible secretion rate
                        end
                    end
                    
                else
                    modelConstraint.rxns(ExR(j));
                end
            end
        end
    end
end

%% woman is not producing milk! - IT 20.12.2016
% hence close all milk producing reactions
tmp = find(~cellfun(@isempty,strfind(modelConstraint.rxns,'(miB)_[mi]')));
modelConstraint.lb(tmp) = 0;
modelConstraint.ub(tmp) = 0;

if 1
    %% set o2[a] and co2[a] constraints
    % Put together by Maike
    % Composition air in: 78.62%�nitrogen, 21%�oxygen, 0.96%�argon, 0.04%�carbon dioxide, 0.5%�water vapour
    % Composition air out: 78.04% nitrogen, 14% - 16% oxygen, 4% - 5.3% carbon dioxide, 1% argon and other gases
    % Amount of O2 in:
    %   Tidal volume: 500 ml/breath
    %   Breathing frequency 12-15x/min
    %   Change of O2: 5%
    %   Volume of gas: 1mol gas = 22.4 l , 1mmol=22.4ml
    %   Volume O2/breath = 5*500 (ml)/100 = 25ml
    %   O2 change (mmol) = 25ml/22.4 ml = 1.1mmol
    %   Volume 02/day = 1.1mmol*12*60*24 = 19.080mol/day
    % Amount of CO2 out:
    %     Tidal volume: 500 ml/breath
    %     Breathing frequency 12-15x/min
    %     Change of CO2: 5.3%
    %     Volume of gas: 1mmol=22.4ml
    %
    %     Volume CO2/breath = 5.3*500 (ml)/100 = 26.5ml
    %     CO2 change (mmol) = 26.5ml/22.4 ml = 1.18mmol
    %     Volume 02/day = 1.18mmol*12*60*24 = 20.442 mol/day
    % Alternative calculation
    %     Ratio O2/CO2 = 0.8
    %     Tidal volume: 500 ml/breath
    %     Breathing frequency 12-15x/min
    %     Change of CO2: 4-5.3%
    %     Density of CO2 = 1.98g/l
    %
    %     Volume CO2/breath = 0.8*(0.05*0.5) = 0.02l
    %     Volume 02/day = 0.02l*12 = 0.24l
    %     Amount CO2/day = 1.98g/l*0.24l*60*24 =  0.475g*60*24= 684.288g/day
    %     Volume C02/day = 15.548 mol/day
    %
    %     Volume 02/day = 0.02l*15
    %                    = 0.30l ->19.436mol/day
    % Refs: http://biology.stackexchange.com/questions/5642/how-much-gas-is-exchanged-in-one-human-breath
    % https://en.wikipedia.org/wiki/Breathing#Breathing_in_gas
    % http://cozybeehive.blogspot.lu/2010/03/how-much-co2-do-you-exhale-while.html
    % http://www.convertunits.com/from/grams+CO2/to/moles
    if 1
        modelConstraint = changeRxnBounds(modelConstraint,'EX_o2[a]',-15000,'u');%change to 15k
        modelConstraint = changeRxnBounds(modelConstraint,'EX_o2[a]',-25000,'l');
        modelConstraint = changeRxnBounds(modelConstraint,'EX_co2[a]',15000*0.8,'l');
        modelConstraint = changeRxnBounds(modelConstraint,'EX_co2[a]',25000,'u');
    end
    % % %% water
    % % %breathing out of water
    % % % from Ref man
    % % % Sweat = 650 ml(water loss)/day - 650g = 650g/day / 18.01528g/mol = 36.0805 mol/day
    % % % Insensible(breathing??) 840g = 850/18.01528 = 47.1822 mol/day
    % % % Urine = 1400g = 1400/18.01528 = 77.7118 mol/day
    % % % Feces = 100g = 100/18.01528 = 5.5508 mol/day
    if 1
      %  modelConstraint = changeRxnBounds(modelConstraint,'EX_h2o[a]',36080*0.8,'l');%
       % modelConstraint = changeRxnBounds(modelConstraint,'EX_h2o[a]',36080*1.2,'u');
        
        
        modelConstraint = changeRxnBounds(modelConstraint,'EX_h2o[a]',47182*0.8,'l');%
        modelConstraint = changeRxnBounds(modelConstraint,'EX_h2o[a]',47182*1.2,'u');
        
        % % % sweating of water
        %modelConstraint = changeRxnBounds(modelConstraint,'EX_h2o[sw]',47182*0.8,'l');%
        %modelConstraint = changeRxnBounds(modelConstraint,'EX_h2o[sw]',47182*1.2,'u');
        
        modelConstraint = changeRxnBounds(modelConstraint,'EX_h2o[sw]',36080*0.8,'l');%
        modelConstraint = changeRxnBounds(modelConstraint,'EX_h2o[sw]',36080*1.2,'u');
        
        % % % water in urine
        modelConstraint = changeRxnBounds(modelConstraint,'EX_h2o[u]',77711*0.8,'l');%should be much higher
        modelConstraint = changeRxnBounds(modelConstraint,'EX_h2o[u]',77711*1.2,'u');
        % % % water in feces
        modelConstraint = changeRxnBounds(modelConstraint,'Excretion_EX_h2o[fe]',5550*0.8,'l');%
        modelConstraint = changeRxnBounds(modelConstraint,'Excretion_EX_h2o[fe]',5550*1.2,'u');
        
        % limit water secretion into bile duct
        modelConstraint = changeRxnBounds(modelConstraint,'Gall_H2Ot[bdG]',1000,'u'); % arbitrary number
        modelConstraint = changeRxnBounds(modelConstraint,'Liver_H2Ot[bdL]',1000,'u'); % arbitrary number
    end
    if 1
        % % %% specific reactions
        % % Muscle can only take up glc
        % set constrain only if the new constrain is tighter than existing one and
        % does not get smaller than LB
        if modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Muscle_EX_glc_D(e)_[bc]')))>= -0.01*1000 && modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Muscle_EX_glc_D(e)_[bc]')))<= -0.01*1000
            modelConstraint = changeRxnBounds(modelConstraint,'Muscle_EX_glc_D(e)_[bc]',-0.01*1000,'u');
        elseif modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Muscle_EX_glc_D(e)_[bc]')))> modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Muscle_EX_glc_D(e)_[bc]')))
            modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Muscle_EX_glc_D(e)_[bc]')))=0; %reset earlier constraints if lb>ub
        end
        
        % 'Muscle_EX_ala_l(e)_[bc]'	'Muscle_ala_L[e]  <=> ala_L[bc] '	alanine secretion	muscle	12.5 mg alanine/min/person (65 kg)	C3H7NO2	89.09	0.233126398	0.233126398	'Muscle_EX_ala_l(e)_[bc]'	0.187	0.280	postabsorption state	Frayn book
        met = 12.5; % mg per min per 65 kg
        MW = 89.09; % g�mol?1
        met = (met * 60 * 24 *IndividualParameters.bodyWeight/65)/1000; %g per day per person (weight adjusted)
        met = met * 1000/ MW ; %mmol per day per person (weight adjusted)
        if modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Muscle_EX_ala_L(e)_[bc]')))<met*0.80 && modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Muscle_EX_ala_L(e)_[bc]')))>=met*0.8
            modelConstraint = changeRxnBounds(modelConstraint,'Muscle_EX_ala_L(e)_[bc]',met*0.8,'l');% to be in mmol/day/person
            modelConstraint = changeRxnBounds(modelConstraint,'Muscle_EX_ala_L(e)_[bc]',met*1.2,'u');
        elseif modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Muscle_EX_ala_L(e)_[bc]')))> modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Muscle_EX_ala_L(e)_[bc]')))
            modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Muscle_EX_ala_L(e)_[bc]')))=0; %reset earlier constraints if lb>ub
        end
        
        
        % 	RBC_EX_glc(e)_[bc]'	'RBC_glc_D[e]  <=> glc_D[bc] '	glucose uptake 	RBC	25 mg/glc/min/person (65kg)	C6H12O6	180.16	0.230564285	-0.230564285	'RBC_EX_glc(e)_[bc]'	-0.184	-0.277		Frayn book
        met = 25; % mg per min per 65 kg
        MW = 180.16;% g�mol?1
        met = (met * 60 * 24 *IndividualParameters.bodyWeight/65)/1000; %g per day per person (weight adjusted)
        met = met * 1000/ MW ; %mmol per day per person (weight adjusted)
        % set constraints only if they make the range smaller
        if modelConstraint.lb(find(ismember(modelConstraint.rxns, 'RBC_EX_glc_D(e)_[bc]')))<-met*1.2 && modelConstraint.ub(find(ismember(modelConstraint.rxns, 'RBC_EX_glc_D(e)_[bc]')))>=-met*1.2
            modelConstraint = changeRxnBounds(modelConstraint,'RBC_EX_glc_D(e)_[bc]',-met*0.8,'u');
            modelConstraint = changeRxnBounds(modelConstraint,'RBC_EX_glc_D(e)_[bc]',-met*1.2,'l');
        elseif modelConstraint.lb(find(ismember(modelConstraint.rxns, 'RBC_EX_glc_D(e)_[bc]')))> modelConstraint.ub(find(ismember(modelConstraint.rxns, 'RBC_EX_glc_D(e)_[bc]')))
            modelConstraint.ub(find(ismember(modelConstraint.rxns, 'RBC_EX_glc_D(e)_[bc]')))=0; %reset earlier constraints if lb>ub
        end
    end
    
    if 1
        if 1
        % 'Brain_EX_glc(e)_[csf]'	'Brain_glc_D[e]  <=> glc_D[csf] '	glucose uptake 	brain	80 mg glc/min/person	C6H12O6	180.16	0.737805711	-0.737805711	'Brain_EX_glc(e)_[csf]'	-0.590	-0.885	all day	Frayn book
        met = 80; % mg per min per 65 kg
        MW = 180.16;% g�mol?1
        met = (met * 60 * 24 *IndividualParameters.bodyWeight/65)/1000; %g per day per person (weight adjusted)
        met = met * 1000/ MW ; %mmol per day per person (weight adjusted)
        if modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Brain_EX_glc_D(e)_[csf]')))<-met*1.20 && modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Brain_EX_glc_D(e)_[csf]')))>=-met*1.2
            modelConstraint = changeRxnBounds(modelConstraint,'Brain_EX_glc_D(e)_[csf]',-met*0.8,'u');
            modelConstraint = changeRxnBounds(modelConstraint,'Brain_EX_glc_D(e)_[csf]',-met*1.2,'l');
        elseif modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Brain_EX_glc_D(e)_[csf]')))> modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Brain_EX_glc_D(e)_[csf]')))
            modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Brain_EX_glc_D(e)_[csf]')))=0; %reset earlier constraints if lb>ub
        end
        end
        %% addition 21.12.2016
        %
        if 1
        brain_weight = cell2mat(IndividualParameters.OrgansWeights(find(ismember(IndividualParameters.OrgansWeights(:,1),'Brain')),2));
        brain_o2 = 156;% umol o2/100g brain/min; REF: http://link.springer.com/chapter/10.1007%2F978-1-59259-108-4_2#page-1
        brain_o2 = (brain_o2 * 60 * 24 * brain_weight/100)/1000; %mmol o2/person (brain)/day.
        if modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Brain_EX_o2(e)_[csf]')))<-brain_o2*1.2 && modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Brain_EX_o2(e)_[csf]')))>=-brain_o2*1.2
           modelConstraint = changeRxnBounds(modelConstraint,'Brain_EX_o2(e)_[csf]',-brain_o2*1.2,'l');
            modelConstraint = changeRxnBounds(modelConstraint,'Brain_EX_o2(e)_[csf]',-brain_o2*0.7,'u');
        elseif modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Brain_EX_o2(e)_[csf]')))> modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Brain_EX_o2(e)_[csf]')))
            modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Brain_EX_o2(e)_[csf]')))=0; %reset earlier constraints if lb>ub
        end
        end
        
    end
    if 1
        
        % 'Liver_EX_ala_l(e)_[bc]'	'Liver_ala_L[e]  <=> ala_L[bc] '	alanine uptake	liver	12.5 mg alanine/min/person (65 kg)	C3H7NO2	89.09	0.233126398	-0.233126398	'Liver_EX_ala_l(e)_[bc]'	-0.187	-0.280	postabsorption state	Frayn book
        met = 12.5; % mg per min per 65 kg
        MW = 89.09; % g�mol?1
        met = (met * 60 * 24 *IndividualParameters.bodyWeight/65)/1000; %g per day per person (weight adjusted)
        met = met * 1000/ MW ; %mmol per day per person (weight adjusted)
        if modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Liver_EX_ala_L(e)_[bc]')))<-met*1.20 && modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Liver_EX_ala_L(e)_[bc]')))>=-met*1.2
            modelConstraint = changeRxnBounds(modelConstraint,'Liver_EX_ala_L(e)_[bc]',-met*0.8,'u');
            modelConstraint = changeRxnBounds(modelConstraint,'Liver_EX_ala_L(e)_[bc]',-met*1.2,'l');
        elseif modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Liver_EX_ala_L(e)_[bc]')))> modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Liver_EX_ala_L(e)_[bc]')))
            modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Liver_EX_ala_L(e)_[bc]')))=0; %reset earlier constraints if lb>ub
        end
        
        % 'Liver_EX_glc(e)_[bc]'	'Liver_glc_D[e]  <=> glc_D[bc] '	glucose secretion	Liver	130 mg glc/min/person (65 kg	C6H12O6	180.16	1.198934281	1.198934281	'Liver_EX_glc(e)_[bc]'	0.959	1.439	postabsorption state	Frayn book
        met = 130; % mg per min per 65 kg
        MW = 180.16;% g�mol?1
        met = (met * 60 * 24 *IndividualParameters.bodyWeight/65)/1000; %g per day per person (weight adjusted)
        met = met * 1000/ MW ; %mmol per day per person (weight adjusted)
        if modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Liver_EX_glc_D(e)_[bc]')))<met*0.80 && modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Liver_EX_glc_D(e)_[bc]')))>=met*0.8
            modelConstraint = changeRxnBounds(modelConstraint,'Liver_EX_glc_D(e)_[bc]',met*1.2,'u');
            modelConstraint = changeRxnBounds(modelConstraint,'Liver_EX_glc_D(e)_[bc]',met*0.8,'l');
        elseif modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Liver_EX_glc_D(e)_[bc]')))> modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Liver_EX_glc_D(e)_[bc]')))
            modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Liver_EX_glc_D(e)_[bc]')))=0; %reset earlier constraints if lb>ub
        end
    end
    if 1
        
        % 'Adipocytes_EX_glyc(e)_[bc]'	'Adipocytes_glyc[e]  <=> glyc[bc] '	glycerol secretion 	adipocytes	12 mg glycerol/min/person (65 kg)	C3H8O3	92.09	0.216510604	0.216510604	'Adipocytes_EX_glyc(e)_[bc]'	0.173	0.260	postabsorption state	Frayn book
        met = 12; % mg per min per 65 kg
        MW = 	92.09;% g�mol?1
        met = (met * 60 * 24 *IndividualParameters.bodyWeight/65)/1000; %g per day per person (weight adjusted)
        met = met * 1000/ MW ; %mmol per day per person (weight adjusted)
        if modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Adipocytes_EX_glyc(e)_[bc]')))<met*0.80 && modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Adipocytes_EX_glyc(e)_[bc]')))>=met*0.8
            % modelConstraint =     changeRxnBounds(modelConstraint,'Adipocytes_EX_glyc(e)_[bc]',met*0.8,'l');
            % the lower bound seems to create troubles so I removed it.
            modelConstraint = changeRxnBounds(modelConstraint,'Adipocytes_EX_glyc(e)_[bc]',met*1.2,'u');
        elseif modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Adipocytes_EX_glyc(e)_[bc]')))> modelConstraint.ub(find(ismember(modelConstraint.rxns, 'Adipocytes_EX_glyc(e)_[bc]')))
            modelConstraint.lb(find(ismember(modelConstraint.rxns, 'Adipocytes_EX_glyc(e)_[bc]')))=0; %reset earlier constraints if lb>ub
        end
    end
    %% addition 19.12.2016
    % constrain growth rate of renewing organs
    % based on bionumbers
    % I am still not convinced that the constraints that I wanted to place
    % are correctly capturing the organ weight - I will leave it for the
    % moment. - IT 22.12.2-2016
    %   modelConstraint = changeRxnBounds(modelConstraint,'sIEC_biomass_reactionIEC01b_trtr',0.25,'l');% every 4 days turn over
    %   modelConstraint = changeRxnBounds(modelConstraint,'sIEC_biomass_reactionIEC01b_trtr',0.5,'u');% every 2 days turn over
    %   modelConstraint = changeRxnBounds(modelConstraint,'Stomach_biomass_reaction',0.11,'l');% every 9 days turn over
    %   modelConstraint = changeRxnBounds(modelConstraint,'Stomach_biomass_reaction',0.5,'u');% every 2 days turn over
    %
    %   modelConstraint = changeRxnBounds(modelConstraint, 'Colon_biomass_reaction',0.25,'l');% every 4 days turn over
    %   modelConstraint = changeRxnBounds(modelConstraint, 'Colon_biomass_reaction',0.33,'u');% every 3 days turn over
    %
    %   modelConstraint = changeRxnBounds(modelConstraint,  'Skin_biomass_reaction',0.033,'l');% every 30 days turn over
    %   modelConstraint = changeRxnBounds(modelConstraint,  'Skin_biomass_reaction',0.1,'u');% every 10 days turn over
    
    %% brain and liver can do co2 fixation - REF: http://www.jbc.org/content/237/8/2570.full.pdf
    
    %disallow carbon fixation -- Nov 2017
     L = (find(~cellfun(@isempty,strfind(modelConstraint.rxns,'EX_co2(e)_[bc]'))));
%     
   modelConstraint.lb(find(ismember(modelConstraint.rxns,modelConstraint.rxns(L)))) = 0;
    %% Co2 can cross BBB: http://www.sciencedirect.com/science/article/pii/0026286280900205
    modelConstraint = changeRxnBounds(modelConstraint,  'Brain_EX_co2(e)_[csf]',-10000,'l'); % arbiratry numbers
    modelConstraint = changeRxnBounds(modelConstraint,  'Liver_EX_co2(e)_[bc]',-10000,'l');
    % lung is also allowed to take up
    modelConstraint = changeRxnBounds(modelConstraint,  'Lung_EX_co2(e)_[bc]',-10000,'l');
    modelConstraint = changeRxnBounds(modelConstraint,  'Kidney_EX_co2(e)_[bc]',-10000,'l');
    if 1
        %% 10.01.17
        % brain atp requirement
        % apparently the brain consumes about 120g glc per day, corresponding to
        % 0.66 mol glc/day/person (MW=180.16)
        % 1 mol glc can be converted into 31 mol atp
        % hence 20.46 mol ATP could be theoretically produced from 0.66 mol glc
        % (if complete ox phos)
        % I will set the lower bound on DM_atp to 10 mol/day/person (this is an
        % arbitrary number). The GF Harvey under Av EU diet can produce max  12799.7
        % mmol ATP/person/day
        % ref: https://www.ncbi.nlm.nih.gov/books/NBK22436/, section 30.2
        
      %  modelConstraint = changeRxnBounds(modelConstraint,'Brain_DM_atp_c_',10000,'l');
        modelConstraint = changeRxnBounds(modelConstraint,'Brain_DM_atp_c_',0,'l');
    end
    
    if 1
    %% heart energy requirement - minimum
    % https://heartmdinstitute.com/heart-health/metabolic-cardiology-basics/
    % reports a minimum of 6000g of ATP per day per person, MW_ATP =
    % 507.18g/mol
    % hence lb = 11830 mmol/day/person
    modelConstraint = changeRxnBounds(modelConstraint,'Heart_DM_atp_c_',6000,'l');
    end
    % Also check this for future efforts: http://hypertextbook.com/facts/2003/IradaMuslumova.shtml
    
    %% constraint conversion of h2o + co2 to h + hco3
    
    % R = (find(~cellfun(@isempty,strfind(modelConstraint.rxns, 'RBC_H2CO3D'))));
    % modelConstraint.lb(R)=0;
    % modelConstraint.ub(R)=150; % no reference for this value except to avoid too high flux through this reaction
    
    %% o2 uptake lower bound constraints
    % each red blood cell contains ~ 270*10^6 haemoglobin, each of which can
    % carry up to 4 o2: e.g., https://en.wikipedia.org/wiki/Red_blood_cell
    % so one red blood cell carries 4*270*10^6 O2
    % The avogadro number is 6.022140857(74)�10^23 mol?1
    % The normal range in men is approximately 4.7 to 6.1 million cells/ul (microliter). The normal range in women range from 4.2 to 5.4 million cells/ul, according to NIH (National Institutes of Health) data.
    % men: assumed 5.5M/ul and  female: assumed 4.5M/ul
    % if strcmp(gender,'male')
    %     RBC = 5.5*10^6*
end