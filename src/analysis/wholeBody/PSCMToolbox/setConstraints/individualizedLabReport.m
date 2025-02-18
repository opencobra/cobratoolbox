function [modelPersonalized,IndividualParametersNew] = individualizedLabReport(model,IndividualParameters, InputData,optionCardiacOutput)
% This function computes personalized physiolgical parameters based on the
% provided input data.
%
% function [modelPersonalized,IndividualParametersNew] = individualizedLabReport(model,IndividualParameters, InputData,optionCardiacOutput)
%
% INPUT
% model                     model structure, whole-body metabolic model
% IndividualParameters      structure with Individual parameters to be
%                           personalized or updated based on the input
%                           data. This structure, with default parameters, can be obtained using the
%                           script standardPhysiolDefaultParameters.m
% InputData                 InputData: specify compartment by placing [bc], [u] or [csf] after the metabolite name
% optionCardiacOutput       Different ways of calculatibg the cardiac
%                           output based on physiological data have been implemented.
%                           - Based on heart rate and stroke volume: CardiacOutput = HeartRate * StrokeVolume. (optionCardiacOutput = 1, default)
%                           - Assume that cardiac output = blood volume.(optionCardiacOutput = 2)
%                           - Based on the polynomial suggested by Youndg et al [http://www.ams.sunysb.edu/~hahn/psfile/pap_obesity.pdf]: CardiacOutput = 9119-exp(9.164-2.91e-2*Wt+3.91e-4*Wt^2-1.91e-6*Wt^3); Wt = weight in kg (optionCardiacOutput = 0)
%                           - Based on Fick's principle, which requires that the oxygen consumption rate is known: VO_2 = (CO* C_a) - (CO *C_v);  where CO = Cardiac Output, Ca = Oxygen concentration of arterial blood and Cv = Oxygen concentration of mixed venous blood. We assume that C_a is 200 ml O2/L and C_v is 150 ml O2/L. (optionCardiacOutput = 3)
%                           - Based on Fick's principle, while estimating the VO_2 based on the body surface area (BSA):   We use the Du Bois formula,[4][5]: BSA=0.007184 * Wt^0.425* Ht^0.725; Wt = weight in kg; Ht in cm; (optionCardiacOutput = 4)
%
% OUTPUT
% modelPersonalized         Updated model structure
% IndividualParametersNew   Updated, personalized individual parameters
%
% Ines Thiele, 2016-2018


if ~exist('optionCardiacOutput','var')
    optionCardiacOutput = 1; %CO estimation based on heart rate
end
%% check units are all valid
% Define valid units
validUnits = {'mg/dL', 'g/dL', 'pg/mL', 'mmol/L', 'µmol/L', 'umol/L', 'ng/dL'};
% Find indices of matching rows
idx = find(contains(InputData(:, 1), {'[bc]', '[csf]', '[u]'}));
% Extract rows with matching patterns
InputDataMets = InputData([idx], :);
% Extract units column
units = InputDataMets(:, 2);
% Initialize validity flag
valid = true;
% Loop through each unit to check validity
for i = 1:length(units)
    if ~ismember(units{i}, validUnits)
        valid = false; % Mark as invalid if unit is not valid
        break; % Exit loop on first invalid unit
    end
end
% Display result based on validity
if valid
    disp('All units are valid.');
else
    disp('Some metabolite units are not valid. Please provide concentration in either: "mg/dL", "g/dL", "pg/mL", "mmol/L", "µmol/L", or "ng/dL".')
    return; % Exit if any unit is invalid
end
%% update individual parameters
% ID
ID = ismember(lower(InputData(:,1)),'id');
if ~isempty(find(ID))
    ID = InputData(ID,3);
    IndividualParameters.ID =ID;
end

InputDataSex = ismember(lower(InputData(:,1)),'sex');
G = InputData(InputDataSex,3);
if strcmp('male',lower(G))
    IndividualParameters.sex = 'male';
else
    IndividualParameters.sex = 'female';
end

% Age
Age = ismember(lower(InputData(:,1)),'age');
updated = 0;
if ~isempty(find(Age))
    A = InputData(Age,3);
    if ischar(A)
        IndividualParameters.age =str2num(char(A{1})) ;
    elseif iscell(A)
        try
            IndividualParameters.age =str2num((A{1})) ;
            updated = 1;
        end
        if updated ==0
            try
                IndividualParameters.age =A{1} ;
                updated = 1;
                
            end
        end
    else
        IndividualParameters.age =A{1} ;
    end
end

% weight
Weight = ismember(lower(InputData(:,1)),'weight');
updated =0;
if ~isempty(find(Weight))
    W = InputData(Weight,3);
    if ischar(W)
        IndividualParameters.bodyWeight =str2num(char(W{1})) ;
    elseif iscell(W)
        try
            IndividualParameters.bodyWeight =str2num((W{1})) ;
            updated = 1;
        end
        if updated ==0
            try
                IndividualParameters.bodyWeight =W{1} ;
            end
        end
    else
        IndividualParameters.bodyWeight =W{1} ;
    end
end

% Hematocrit given as fraction in IndividualParameters but in percentage in
% InputData
Hematocrit = ismember(lower(InputData(:,1)),'hematocrit');
if ~isempty(find(Hematocrit))
    He = InputData(Hematocrit,3);
    IndividualParameters.Hematocrit = char(He{1})/100 ;
end

% Creatinine given in mg/dL in InputData and in IndividualParameters
Creatinine = ismember(lower(InputData(:,1)),'creatinine');
if ~isempty(find(Creatinine))
    Cr = InputData(Creatinine,3);
    if ischar(Cr{1})
    IndividualParameters.MConUrCreatinineMin =str2num(char(Cr{1})); % minimum
    IndividualParameters.MConUrCreatinineMax =str2num(char(Cr{1})); % maximum
    else 
    IndividualParameters.MConUrCreatinineMin = Cr{1}; % minimum
    IndividualParameters.MConUrCreatinineMax = Cr{1}; % maximum
    end
end

% heart rate given in beats per min in InputData and in IndividualParameters
HeartRate = ismember(lower(InputData(:,1)),'heartrate');
if ~isempty(find(HeartRate))
    HR = InputData(HeartRate,3);
    if ischar(HR{1})
        IndividualParameters.HeartRate =str2num(char(HR{1}));
    else
        IndividualParameters.HeartRate =HR{1};
    end
end

% VO2 for CO estimation
VO2 = ismember(lower(InputData(:,1)),'vo2');
if ~isempty(find(VO2))
    VO2 = InputData(VO2,3);
    if ischar(VO2{1})
        IndividualParameters.VO2 =str2num(char(VO2{1}));
    else
        IndividualParameters.VO2 =VO2{1};
    end
end
%% estimate blood volume:
%http://www.mc.vanderbilt.edu/documents/vmcpathology/files/TBV%20caclulation.docx.pdf
% Nadler's equation
%For Males = 0.3669 * Ht in M3 + 0.03219 * Wt in kgs + 0.6041 For	Females = 0.3561 * Ht in M3 + 0.03308 x Wt in kgs + 0.1833
%Note: * Ht in M = Height in Meters, which is then cubed * Wt in kgs = Body weight in kilograms

% read in height given in cm in InputData and in IndividualParameters
Height = ismember(lower(InputData(:,1)),'height');
updated = 0;
if ~isempty(find(Height))
    H = InputData(Height,3);
    if ischar(H)
        IndividualParameters.Height =str2num(char(H{1})) ;
    elseif iscell(H)
        try
            IndividualParameters.Height =str2num((H{1})) ;
            updated = 1;
        end
        if updated ==0
            try
                IndividualParameters.Height = H{1} ;
            end
        end
    else
        IndividualParameters.Height = H{1} ;
    end
end

% blood volume in ml/min
if strcmp(IndividualParameters.sex, 'male')
    IndividualParameters.BloodVolume = (0.3669 * (IndividualParameters.Height/100)^3 + 0.03219 * IndividualParameters.bodyWeight + 0.6041)*1000;
elseif strcmp(IndividualParameters.sex, 'female')
    IndividualParameters.BloodVolume = (0.3561 * (IndividualParameters.Height/100)^3 + 0.03308 * IndividualParameters.bodyWeight + 0.1833)*1000;
end

%% estimate (resting) cardiac output from blood volume in case that no stroke volume is provided
StrokeVolume = ismember(lower(strtrim(InputData(:,1))), 'stroke volume');

if optionCardiacOutput ~=-1 % skip adjustment of CO
    if ~isempty(find(StrokeVolume))
        S = InputData(StrokeVolume,3);
        if ischar(S) 
            IndividualParameters.StrokeVolume =str2num(char(S{1})) ;
        else
            IndividualParameters.StrokeVolume = S{1} ;
        end
        IndividualParameters.CardiacOutput = IndividualParameters.HeartRate * IndividualParameters.StrokeVolume; % in ml/min = beats/min * ml/beat
        IndividualParameters.CardiacOutput_Note = 'Calculated from personalized StrokeVolume and heart rate';
    elseif optionCardiacOutput == 1
        
        % actually I think that it makes more sense to keep the cardiac output to
        % be calculated based on default strokevolume and heart rate
        IndividualParameters.CardiacOutput = IndividualParameters.HeartRate * IndividualParameters.StrokeVolume; % in ml/min = beats/min * ml/beat
        IndividualParameters.CardiacOutput_Note = 'Calculated from default StrokeVolume and heart rate';
    elseif optionCardiacOutput == 2
        IndividualParameters.StrokeVolume ='NaN';
        IndividualParameters.CardiacOutput = IndividualParameters.BloodVolume;
        IndividualParameters.CardiacOutput_Note = 'Estimated from BloodVolume'; % in ml/min = beats/min * ml/beat
    elseif optionCardiacOutput == 0
        % With the blood volume estimate the CO gets too low.
        % hence I used the equation given here:
        % http://www.ams.sunysb.edu/~hahn/psfile/pap_obesity.pdf
        % note that the weight here is given in kg rather than g
        
        Wt = IndividualParameters.bodyWeight;
        IndividualParameters.CardiacOutput = 9119-exp(9.164-2.91e-2*Wt+3.91e-4*Wt^2-1.91e-6*Wt^3);
        IndividualParameters.CardiacOutput_Note = 'Estimated from CO equation'; % in ml/min = beats/min * ml/beat
    elseif optionCardiacOutput == 3
        % from wikipedia: https://en.wikipedia.org/wiki/Fick_principle
        %     VO_2 = (CO \times\ C_a) - (CO \times\ C_v)
        % where CO = Cardiac Output, Ca = Oxygen concentration of arterial blood and Cv = Oxygen concentration of mixed venous blood.
        % Note that (Ca ? Cv) is also known as the arteriovenous oxygen difference.
        % Cardiac Output = (125 ml O2/minute x 1.9) / (200 ml O2/L - 150 ml O2/L) = 4.75 L/minute
        % can be refined to account for haemoglobin content
        IndividualParameters.CardiacOutput = ((IndividualParameters.VO2*1000)*60*24/(200 - 150));
        IndividualParameters.CardiacOutput_Note = 'Estimated from VO2 ';
    elseif optionCardiacOutput == 4 %
        %Cardiac Output = (125 ml O2/minute x 1.9) / (200 ml O2/L - 150 ml O2/L) = 4.75 L/minute
        % Various calculations have been published to arrive at the BSA without direct measurement. In the following formulae, BSA is in m2, W is mass in kg, and H is height in cm.
        % The most widely used is the Du Bois, Du Bois formula,[4][5] which has been shown to be equally as effective in estimating body fat in obese and non-obese patients, something the Body mass index fails to do.[6]
        % BSA=0.007184 * W^{0.425}* H^{0.725}}
        W = IndividualParameters.bodyWeight;
        H = IndividualParameters.Height;
        BSA=0.007184 * W^0.425* H^0.725 ;
        IndividualParameters.CardiacOutput = ((0.125*1000*BSA)*60*24/(200 - 150));
        IndividualParameters.CardiacOutput_Note = 'Estimated from surface area ';
    elseif optionCardiacOutput == 5 %
        % estimation of vO2max
        % file:///Users/ines.thiele/Dropbox/work/Papers/SystemsPhysiology/schneider2013.pdf
        % for males: VO2max/kg = -0.42 A + 58, where A is age
        % for females: VO2max/kg = -0.35 A + 46, where A is age
        % assuming that at low activity the vo2 is 25% of vo2max
        % "At low exercise intensities (25% of maximal oxygen uptake (VO2max)), which in an average
        % healthy untrained young adult (VO2max per kg body mass = 42 ml kg?1min?1)
        % corresponds with level walking at 4?5 km h?1
        W = IndividualParameters.bodyWeight;
        A = IndividualParameters.age;
        if strcmp(IndividualParameters.sex,'male')
            VO2max = (-0.42* A + 58)*W; %ml/min
        elseif strcmp(IndividualParameters.sex,'female')
            VO2max = (-0.35* A + 46)*W;
        end
        VO2 = 0.07*VO2max;
        IndividualParameters.CardiacOutput = ((VO2)*60*24/(200 - 150));
    elseif  optionCardiacOutput == 6 %
        %estimation of stroke volume based on Frick
        % http://circ.ahajournals.org/content/circulationaha/14/2/250.full.pdf
        PP = 40; % pulse pressure
        DP = 80; % diatstolic blood pressure
        IndividualParameters.StrokeVolume = 91.0 + 0.54 * PP - 0.57*DP-0.61 *IndividualParameters.age ;
        IndividualParameters.CardiacOutput = IndividualParameters.HeartRate * IndividualParameters.StrokeVolume; % in ml/min = beats/min * ml/beat
    elseif  optionCardiacOutput == 7 %
        %estimation of stroke volume based on Bridwell
        % http://circ.ahajournals.org/content/circulationaha/14/2/250.full.pdf
        PP = 40; % pulse pressure
        DP = 80; % diatstolic blood pressure
        IndividualParameters.StrokeVolume = 66.0 + 0.34 * PP - 0.11*DP-0.36 *IndividualParameters.age ;
        IndividualParameters.CardiacOutput = IndividualParameters.HeartRate * IndividualParameters.StrokeVolume; % in ml/min = beats/min * ml/beat
        
    end
end
%% apply HMDB data based on IndividualParameters
modelPersonalized = model;
modelPersonalized = physiologicalConstraintsHMDBbased(modelPersonalized,IndividualParameters);
 % Test feasibility
% enforce body weight maintenance
modelPersonalized = changeRxnBounds(modelPersonalized, 'Whole_body_objective_rxn', 1, 'b');
modelPersonalized.osenseStr = 'max';
modelPersonalized = changeObjective(modelPersonalized, 'Whole_body_objective_rxn');
FBA = optimizeWBModel(modelPersonalized);
if FBA.f == 1
    IndividualParameters.Feasible{1, 1} = 'Feasible after personalising physiological parameters';
else 
    IndividualParameters.Feasible{1, 1} = 'Infeasible after personalising physiological parameters';
    disp('Infeasible after personalising physiological parameters, check constraints')
    return;
end
%% Convert input data
InputDataT = array2table(InputData);
InputDataT.Properties.VariableNames = ["parameter" "unit" "MetCon"];
DB = loadVMHDatabase();

% Obtain molecular weights using computeMW and create table of metabolite name and moleceular weight
formulae = DB.metabolites(:, 4);
formulae = DB.metabolites(~cellfun('isempty', DB.metabolites(:, 4)), 4); % Remove empty entries
emptyIdx = find(cellfun('isempty', DB.metabolites(:, 4))); % Indices of original empty entries

MW = getMolecularMass(formulae);

metIDs = DB.metabolites(:, 1);
metIDs(emptyIdx) = [];

% Now, create the table
AllMolecularWeights = table(metIDs, formulae, MW);
%% Blood metabolites
Type = 'direct';
counter = 0;
%Load each metabolite and MW, calculate lb and ub
ContainsBC = find(contains(InputDataT.parameter, '[bc]'));
BCmet = InputDataT.parameter(ContainsBC);
InputDataMetabolitesBC = cell(size(BCmet, 1),3);

if ~isempty(ContainsBC)
    for i= 1:size(BCmet,1)
        inputMet = BCmet{i};
        row = ismember(InputDataT.parameter,inputMet);
        met = regexprep(inputMet, '\[.*?\]', '');
        idx = find(strcmp(AllMolecularWeights.metIDs, met));
        MW = AllMolecularWeights.MW(idx);
        if isempty(MW)|MW == 0|isnan(MW)
            InputDataMetabolitesBC{i, 2} = 'MW unavailable in VMH database';
        end
        if ~isempty(row)
            Conc = InputDataT.MetCon{row};
            Name = inputMet;  
            % CONVERT TO MICROMOLE PER LITER
            % Determine the unit
            unit = InputDataT.unit{row};
            switch unit
                case {'µmol/L', 'umol/L'}
                    Conc_umolL = Conc; % Already in µmol/L, no conversion needed
                case 'mg/dL'
                    Conc_umolL = Conc*10^4/MW; % Convert from mg/dL to µmol/L
                case 'g/dL'
                    Conc_umolL = Conc*10^7/MW;  % Convert from g/dL to µmol/L
                case 'pg/mL'  
                    Conc_umolL = Conc/MW; % Convert from pg/mL to µmol/L
                case 'mmol/L'
                    Conc_umolL = Conc*10^3; % Convert from mmol/L to µmol/L (direct conversion)
                case 'ng/dL' 
                    Conc_umolL = Conc*10^2/MW; % Convert from ng/dL to µmol/L
                otherwise
                    error('Unknown unit: %s', unit);
            end
   
            % Calculate the bounds
            MetConMin  = Conc_umolL * 0.8; % 80% for lower bound
            MetConMax  = Conc_umolL * 1.2; % 120% for upper bound
            
            % Store results
            InputDataMetabolitesBC(i, :) = {Name, MetConMin, MetConMax};
            clear Name MetConMin MetConMax
            
        else
            missing{i} = inputMet;
            missing = missing(~cellfun('isempty', missing));
        end
        counter = counter + 1;
        fprintf('Calculated blood metabolite concentration #%d\n', counter);
        
        if isempty(row)
            disp  'Metabolite not found: please check spelling or naming of metabolite in input data'
        end
    end
    
    InputDataMetabolitesBC(:, 1) = BCmet; 

    
    if exist('InputDataMetabolitesBC','var')
        modelPersonalized = physiologicalConstraintsHMDBbased(modelPersonalized,IndividualParameters, '',Type, InputDataMetabolitesBC, 'bc');
        % Test feasibility
        % enforce body weight maintenance
        modelPersonalized = changeRxnBounds(modelPersonalized, 'Whole_body_objective_rxn', 1, 'b');
        modelPersonalized.osenseStr = 'max';
        modelPersonalized = changeObjective(modelPersonalized, 'Whole_body_objective_rxn');
        FBA = optimizeWBModel(modelPersonalized);
        if FBA.f == 1
            IndividualParameters.Feasible{2, 1} = 'Feasible after personalising blood metabolome';
         else 
            IndividualParameters.Feasible{4, 1} = 'Infeasible after personalising blood metabolome';
            disp('Infeasible after personalising blood metabolome, check constraints')
            return;
        end
        InputDataMetabolitesBC = [{'met', 'lb', 'ub'}; InputDataMetabolitesBC];
        IndividualParameters.BloodMetabolites = InputDataMetabolitesBC;
    end

end
 %% Urine Metabolites
ContainsU = find(contains(InputDataT.parameter, '[u]'));
Umet = InputDataT.parameter(ContainsU);
InputDataMetabolitesU = cell(size(Umet, 1),3);
if ~isempty(ContainsU)
    for i= 1:size(Umet,1)
        inputMet = Umet{i};
        row = ismember(InputDataT.parameter,inputMet);
        met = regexprep(inputMet, '\[.*?\]', '');
        idx = find(strcmp(AllMolecularWeights.metIDs, met));
        MW = AllMolecularWeights.MW(idx);
        if isempty(MW)|MW == 0|isnan(MW)
            InputDataMetabolitesU{i, 2} = 'MW unavailable in VMH database';
        end
        if ~isempty(row)
            Conc = InputDataT.MetCon{row};
            Name = inputMet;
            unit = InputDataT.unit{row};
            switch unit
                case {'µmol/L', 'umol/L'}
                    Conc_umolL = Conc; % Already in µmol/L, no conversion needed
                case 'mg/dL'
                    Conc_umolL = Conc * 10^4 / MW; % Convert from mg/dL to µmol/L
                case 'g/dL'
                    Conc_umolL = Conc * 10^7 / MW;  % Convert from g/dL to µmol/L
                case 'pg/mL'  
                    Conc_umolL = Conc / MW; % Convert from pg/mL to µmol/L
                case 'mmol/L'
                    Conc_umolL = Conc * 10^3; % Convert from mmol/L to µmol/L (direct conversion)
                case 'ng/dL' 
                    Conc_umolL = Conc * 10^2 / MW; % Convert from ng/dL to µmol/L
                otherwise
                    error('Unknown unit: %s', unit);
            end
            % CONVERT TO MICROMOLE PER LITER
            MetConMin  = Conc*10*(1/MW)*1000*0.8;
            MetConMax = Conc*10*(1/MW)*1000*1.2;
            
            InputDataMetabolitesU(i, :) = {Name,  MetConMin,  MetConMax};
            clear Name MetConMin MinCon MetConMax MaxCon
        else
            missing{i} =  inputMet;
            missing = missing(~cellfun('isempty',missing));
        end
        counter = counter + 1;
        fprintf('Calculated urine metabolite concentration #%d\n', counter);
        
        if isempty(row)
            disp  'Metabolite not found: please check spelling or naming of metabolite in input data'
        end
    end
    
     InputDataMetabolitesU(:, 1) = Umet; 
    
    if exist('InputDataMetabolitesU','var')
        modelPersonalized = physiologicalConstraintsHMDBbased(modelPersonalized,IndividualParameters, '',Type, InputDataMetabolitesU, 'u');
        % Test feasibility
        % enforce body weight maintenance
        modelPersonalized = changeRxnBounds(modelPersonalized, 'Whole_body_objective_rxn', 1, 'b');
        modelPersonalized.osenseStr = 'max';
        modelPersonalized = changeObjective(modelPersonalized, 'Whole_body_objective_rxn');
        FBA = optimizeWBModel(modelPersonalized);
        if FBA.f == 1
            IndividualParameters.Feasible{3, 1} = 'Feasible after personalising urinary metabolome';
        else 
            IndividualParameters.Feasible{4, 1} = 'Infeasible after personalising urinary metabolome';
            disp('Infeasible after personalising urinary metabolome, check constraints')
            return;
        end
        InputDataMetabolitesU = [{'met', 'lb', 'ub'}; InputDataMetabolitesU];
        IndividualParameters.UrineMetabolites = InputDataMetabolitesU;
    end
    
end
 %% CSF metabolites   
ContainsCSF = find(contains(InputDataT.parameter, '[csf]'));
CSFmet = InputDataT.parameter(ContainsCSF);
InputDataMetabolitesCSF = cell(size(CSFmet, 1),3);
if ~isempty(ContainsCSF)
    for i= 1:size(CSFmet,1)
        inputMet = CSFmet{i};
         row = ismember(InputDataT.parameter,inputMet);
         met = regexprep(inputMet, '\[.*?\]', '');
         idx = find(strcmp(AllMolecularWeights.metIDs, met));
         MW = AllMolecularWeights.MW(idx);
        if isempty(MW)|MW == 0|isnan(MW)
            InputDataMetabolitesCSF{i, 2} = 'MW unavailable in VMH database';
        end
        if ~isempty(row)
            Conc = InputDataT.MetCon{row};
            Name = inputMet;
            unit = InputDataT.unit{row};
            switch unit
                case {'µmol/L', 'umol/L'}
                    Conc_umolL = Conc; % Already in µmol/L, no conversion needed
                case 'mg/dL'
                    Conc_umolL = Conc * 10^4 / MW; % Convert from mg/dL to µmol/L
                case 'g/dL'
                    Conc_umolL = Conc * 10^7 / MW;  % Convert from g/dL to µmol/L
                case 'pg/mL'  
                    Conc_umolL = Conc / MW; % Convert from pg/mL to µmol/L
                case 'mmol/L'
                    Conc_umolL = Conc * 10^3; % Convert from mmol/L to µmol/L (direct conversion)
                case 'ng/dL' 
                    Conc_umolL = Conc * 10^2 / MW; % Convert from ng/dL to µmol/L
                otherwise
                    error('Unknown unit: %s', unit);
            end
            % CONVERT TO MICROMOLE PER LITER
            MetConMin  = Conc*10*(1/MW)*1000*0.8;
            MetConMax = Conc*10*(1/MW)*1000*1.2;
            
            Name = inputMet;
            MetConMin  = Conc*10*(1/MW)*1000*0.8;
            MetConMax = Conc*10*(1/MW)*1000*1.2;
            InputDataMetabolitesCSF(i, :) = {Name,  MetConMin,  MetConMax};
            clear Name MetConMin MinCon MetConMax MaxCon
        else
            missing{i} =  inputMet;
            missing = missing(~cellfun('isempty',missing));
            
        end
        counter = counter + 1;
        fprintf('Calculated Cerebrospinal fluid metabolite concentration #%d\n', counter);
        
        if isempty(row)
            disp('Metabolite not found: please check spelling or naming of metabolite in input data')
        end
    end
    
    InputDataMetabolitesCSF(:, 1) = CSFmet; 
    
    if exist('InputDataMetabolitesCSF','var')
        modelPersonalized = physiologicalConstraintsHMDBbased(modelPersonalized,IndividualParameters, '',Type, InputDataMetabolitesCSF, 'csf');
        % Test feasibility
        % enforce body weight maintenance
        modelPersonalized = changeRxnBounds(modelPersonalized, 'Whole_body_objective_rxn', 1, 'b');
        modelPersonalized.osenseStr = 'max';
        modelPersonalized = changeObjective(modelPersonalized, 'Whole_body_objective_rxn');
        FBA = optimizeWBModel(modelPersonalized);
        if FBA.f == 1
            IndividualParameters.Feasible{4, 1} = 'Feasible after personalising csf metabolome';
        else 
            IndividualParameters.Feasible{4, 1} = 'Infeasible after personalising csf metabolome';
            disp('Infeasible after personalising csf metabolome, check constraints')
            return;
        end
        InputDataMetabolitesCSF = [{'met', 'lb', 'ub'}; InputDataMetabolitesCSF];
        IndividualParameters.CerebrospinalFluid = InputDataMetabolitesCSF;
    end
   
end
    IndividualParametersNew = IndividualParameters;
end