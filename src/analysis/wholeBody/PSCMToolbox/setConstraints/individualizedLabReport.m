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
% InputData                 InputData
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
    IndividualParameters.Hematocrit =str2num(char(He{1}))/100 ;
end

% Creatinine given in mg/dL in InputData and in IndividualParameters
Creatinine = ismember(lower(InputData(:,1)),'creatinine');
if ~isempty(find(Creatinine))
    Cr = InputData(Creatinine,3);
    IndividualParameters.MConUrCreatinineMin =str2num(char(Cr{1})); % minimum
    IndividualParameters.MConUrCreatinineMax =str2num(char(Cr{1})); % maximum
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
StrokeVolume = ismember(lower(InputData(:,1)),'StrokeVolume');
if optionCardiacOutput ~=-1 % skip adjustment of CO
    if ~isempty(find(StrokeVolume))
        S = InputData(StrokeVolume,3);
        IndividualParameters.StrokeVolume =str2num(char(S{1})) ;
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
%modelPersonalized = physiologicalConstraintsHMDBbased(modelPersonalized,IndividualParameters);

%% prepare for the urine and blood concentration data
%
if 0
    %InputDataMetabolites=[Data.textdata(Start+1:end,VMH) MetConMin MetConMax];
    Type = 'direct';
    % first blood
    % glucose
    MW_glc= 180.16;% g�mol?1;
    Glc = ismember(InputData(:,1),'Glucose');
    if ~isempty(find(Glc))
        Glc = InputData(Glc,3);
        Glc =str2num(char(Glc{1})) ;
        % calculate glucose in mM
        GlcMin = Glc * 10 * (1/MW_glc)*1000*0.8; %in mmol/L
        GlcMax = Glc * 10 * (1/MW_glc)*1000*1.2; %in mmol/L
        GlcMin = cellstr(num2str(GlcMin));
        GlcMin = regexprep(GlcMin,' ','');
        for j = 1 : size(GlcMin,1)
            GlcMin{j,1} = (GlcMin(j,1));
        end
        GlcMax = cellstr(num2str(GlcMax));
        GlcMax = regexprep(GlcMax,' ','');
        for j = 1 : size(GlcMax,1)
            GlcMax{j,1} = (GlcMax(j,1));
        end
        InputDataMetabolitesBC(1,:) = ['glc_D'   GlcMin  GlcMax];
    end
    % Cholesterol
    MW_chsterol = 386.65;% g/mol;
    Chsterol = ismember(InputData(:,1),'Cholesterol');
    if ~isempty(find(Chsterol))
        Chsterol = InputData(Chsterol,3);
        Chsterol =str2num(char(Chsterol{1})) ;
        % calculate Chsterol in mM
        ChsterolMin = Chsterol * 10 * (1/MW_chsterol)*1000*0.8; %in mmol/L
        ChsterolMax = Chsterol * 10 * (1/MW_chsterol)*1000*1.2; %in mmol/L
        ChsterolMin = cellstr(num2str(ChsterolMin));
        ChsterolMin = regexprep(ChsterolMin,' ','');
        for j = 1 : size(ChsterolMin,1)
            ChsterolMin{j,1} = (ChsterolMin(j,1));
        end
        ChsterolMax = cellstr(num2str(ChsterolMax));
        ChsterolMax = regexprep(ChsterolMax,' ','');
        for j = 1 : size(ChsterolMax,1)
            ChsterolMax{j,1} = (ChsterolMax(j,1));
        end
        InputDataMetabolitesBC(2,:) = ['chsterol'   ChsterolMin  ChsterolMax];
    end
    modelPersonalized = physiologicalConstraintsHMDBbased(modelPersonalized,IndividualParameters, Type, InputDataMetabolitesBC, 'bc');
    %urea given in mg/dl in input data
    % Cholesterol
    MW_urea = 60.06;% g/mol;
    MW_creatinine = 113.1179;%g/mol
    Urea = ismember(InputData(:,1),'Urea');
    if ~isempty(find(Urea))
        Urea = InputData(Urea,3);
        Urea =str2num(char(Urea{1})) ;
        % calculate Urea in mM
        UreaMin = Urea * 10 * (1/MW_urea)*1000*0.8/(IndividualParameters.MConUrCreatinineMax * 10 * (1/MW_creatinine)); %in umol urea/mmol creatine
        UreaMax = Urea * 10 * (1/MW_urea)*1000*1.2/(IndividualParameters.MConUrCreatinineMax * 10 * (1/MW_creatinine)); %in umol urea/mmol creatine
        UreaMin = cellstr(num2str(UreaMin));
        UreaMin = regexprep(UreaMin,' ','');
        for j = 1 : size(UreaMin,1)
            UreaMin{j,1} = (UreaMin(j,1));
        end
        UreaMax = cellstr(num2str(UreaMax));
        UreaMax = regexprep(UreaMax,' ','');
        for j = 1 : size(UreaMax,1)
            UreaMax{j,1} = (UreaMax(j,1));
        end
        InputDataMetabolitesU(2,:) = ['urea'   UreaMin  UreaMax];
    end
    modelPersonalized = physiologicalConstraintsHMDBbased(modelPersonalized,IndividualParameters, Type, InputDataMetabolitesU, 'u');
end
IndividualParametersNew =IndividualParameters;