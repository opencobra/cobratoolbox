if set==1
    pathdef;
    addpath(genpath('../../HH_final'))
    addpath(genpath('/home/ines.thiele/P/GitHub/codeBaseHarveyAnalysis'))
    addpath(genpath('/home/ines.thiele/P/GitHub/_cobraHARVEYGenerationONLY'))
    addpath(genpath('/opt/tomlab'))
end
% test multiple BMR's

load Harvey_1_01c
load Harvetta_1_01c


clear model* ExclList;

gender = 'female';
standardPhysiolDefaultParameters;
IndividualParameters_female = IndividualParameters;

female = physiologicalConstraintsHMDBbased(female,IndividualParameters_female);
EUAverageDietNew;
female = setDietConstraints(female, Diet);

female = setSimulationConstraints(female);

minInf = -1000000;
maxInf = 1000000;
minConstraints = length(intersect(find(female.lb>minInf),find(female.lb)));
maxConstraints =length(intersect(find(female.ub<maxInf),find(female.ub)));

female = changeObjective(female,'Whole_body_objective_rxn');
female.osense = -1;

% adjust Muscle and fat atp in biomass - compute and compare BMF's with
% BMRs

sensi_analysis = [1; 5; 10;50;100 ];

cnt = 1;
for y =3 %1 : length(sensi_analysis)
    femaleBMR = female;
    
    femaleBMR.S = femaleBMR.A;
    
    % femaleBMR
    BM = (find(~cellfun(@isempty,strfind(femaleBMR.rxns,'Muscle_biomass_'))));
    
    % find all reactions in the model that involve atp
    atp = (find(~cellfun(@isempty,strfind(femaleBMR.mets,'_atp[c'))));
    adp = (find(~cellfun(@isempty,strfind(femaleBMR.mets,'_adp[c'))));
    pi = (find(~cellfun(@isempty,strfind(femaleBMR.mets,'_pi[c'))));
    h = (find(~cellfun(@isempty,strfind(femaleBMR.mets,'_h[c'))));
    h2o = (find(~cellfun(@isempty,strfind(femaleBMR.mets,'_h2o[c'))));
    BMatpSum = 0;
    for i = 1: length(BM)
        % grab atp
        BMmets = (find(femaleBMR.S(:,BM(i))));
        BMatp = intersect(BMmets,atp);
        femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *sensi_analysis(y);
        BMatp = intersect(BMmets,adp);
        femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *sensi_analysis(y);
        BMatp = intersect(BMmets,pi);
        femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *sensi_analysis(y);
        BMatp = intersect(BMmets,h);
        femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *sensi_analysis(y);
        BMatp= intersect(BMmets,h2o);
        femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *sensi_analysis(y);
    end
    
    Energy_kJ_femaleBMR2(1,cnt) = sensi_analysis(y);
    for z =1%1: length(sensi_analysis)
        femaleBMR2 = femaleBMR;
        BM = (find(~cellfun(@isempty,strfind(femaleBMR2.rxns,'Adipocytes_biomass_'))));
        for i = 1: length(BM)
            % grab atp
            BMmets = (find(femaleBMR2.S(:,BM(i))));
            BMatp = intersect(BMmets,atp);
            femaleBMR2.S(BMatp,BM(i))= femaleBMR2.S(BMatp,BM(i)) *sensi_analysis(z);
            BMatp = intersect(BMmets,adp);
            femaleBMR2.S(BMatp,BM(i))= femaleBMR2.S(BMatp,BM(i)) *sensi_analysis(z);
            BMatp = intersect(BMmets,pi);
            femaleBMR2.S(BMatp,BM(i))= femaleBMR2.S(BMatp,BM(i))*sensi_analysis(z);
            BMatp = intersect(BMmets,h);
            femaleBMR2.S(BMatp,BM(i))= femaleBMR2.S(BMatp,BM(i)) *sensi_analysis(z);
            BMatp= intersect(BMmets,h2o);
            femaleBMR2.S(BMatp,BM(i))= femaleBMR2.S(BMatp,BM(i)) *sensi_analysis(z);
        end
        
        Energy_kJ_femaleBMR2(2,cnt) = sensi_analysis(z);
        
        femaleBMR2.A = femaleBMR2.S;
        
        InputDataAll =  {
            'gender' ''	'male'		'female'		'female'		'female'		'female'		'female'		'male'		'female'		'male'		'male'		'male'		'female'		'male'		'male'		'male'		'male'		'male'		'female'		'female'		'female'		'male'		'male'		'male'		'female'		'male'		'male'		'male'		'male'
            'age' '' num2str(15) num2str(14) num2str(12) num2str(18) num2str(16) num2str(15) num2str(17) num2str(11) num2str(13) num2str(14) num2str(16) num2str(16) num2str(12) num2str(15) num2str(16) num2str(18) num2str(13) num2str(11) num2str(12) num2str(17) num2str(12) num2str(15) num2str(17) num2str(12) num2str(15) num2str(15) num2str(14) num2str(15)
            'Height' '' num2str(168) num2str(164) num2str(152) num2str(162) num2str(166) num2str(173) num2str(172) num2str(161) num2str(164) num2str(165) num2str(170) num2str(156) num2str(172) num2str(175) num2str(177) num2str(173) num2str(161) num2str(155) num2str(157) num2str(165) num2str(150) num2str(174) num2str(175) num2str(139) num2str(184) num2str(162) num2str(159.5) num2str(177)
            'Weight' '' num2str(60.8) num2str(56.8) num2str(40.2) num2str(53.2) num2str(54.1) num2str(62.9) num2str(64.4) num2str(56.2) num2str(47.9) num2str(52.8) num2str(65.6) num2str(49.9) num2str(58) num2str(69.1) num2str(64.8) num2str(63.5) num2str(48) num2str(50.4) num2str(44.3) num2str(58) num2str(40.1) num2str(61.2) num2str(64.6) num2str(35.4) num2str(65.8) num2str(47.4) num2str(48.2) num2str(59.6)
            'Fat-free' '' num2str(51.66) num2str(40.08) num2str(30.08) num2str(43.71) num2str(42.88) num2str(53.44) num2str(58.18) num2str(36.4) num2str(41.4) num2str(47) num2str(55.91) num2str(39.52) num2str(48.23) num2str(59.75) num2str(56) num2str(53.86) num2str(42) num2str(33.75) num2str(37.31) num2str(45.31) num2str(33.62) num2str(53.22) num2str(56.62) num2str(20) num2str(49) num2str(38.56) num2str(39) num2str(50)
            'BMI' '' num2str(21.54) num2str(21.12) num2str(17.4) num2str(20.27) num2str(19.63) num2str(21.02) num2str(21.77) num2str(21.68) num2str(17.81) num2str(19.39) num2str(22.7) num2str(20.5) num2str(19.61) num2str(22.56) num2str(20.68) num2str(21.22) num2str(18.52) num2str(20.98) num2str(17.97) num2str(21.3) num2str(17.82) num2str(20.21) num2str(21.09) num2str(18.32) num2str(19.44) num2str(18.06) num2str(18.95) num2str(19.02)
            'BMR' '' num2str(1661.16) num2str(1414.97) num2str(1282.42) num2str(1489.45) num2str(1277.24) num2str(1582.33) num2str(1515.13) num2str(1495.3) num2str(1775.51) num2str(1576.21) num2str(1476.97) num2str(1271.78) num2str(1551.96) num2str(2039.63) num2str(1808.9) num2str(1537.86) num2str(1457.89) num2str(1243.59) num2str(1443.9) num2str(1318.07) num2str(1249.74) num2str(1537.93) num2str(1633.33) num2str(1103.2) num2str(1508.41) num2str(1393.85) num2str(1167.48) num2str(1612.75)
            };
       
        femaleBMR2O=femaleBMR2;
        for i = 3 :  size(InputDataAll,2) %
            InputData =  [InputDataAll(:,1), InputDataAll(:,2), InputDataAll(:,i)];
            femaleBMR2 = femaleBMR2O;
            
            gender =  InputDataAll(1,i);
            femaleBMR2.gender = gender;
            if strcmp(gender,'female')
                optionCardiacOutput = 0; %0 4 2
                [femaleBMR2,IndividualParametersPersonalized] = individualizedLabReport(femaleBMR2,IndividualParameters_female, InputData,optionCardiacOutput);
                % 3. set personalized constraints
                femaleBMR2.IndividualParametersPersonalized=IndividualParametersPersonalized;
                % 3. set personalized constraints
                
                % calculate new organ weight fraction for a given personalized weight
                [listOrgan,OrganWeight,OrganWeightFract,IndividualParametersPersonalized] = calcOrganFract(femaleBMR2,IndividualParametersPersonalized);
                
                % I repeat this step, as I calculate in some options the CO based on
                % bloodVol which is only calculated in calcOrganFract
                [femaleBMR2,IndividualParametersPersonalized] = individualizedLabReport(femaleBMR2,IndividualParametersPersonalized, InputData,optionCardiacOutput);
                femaleBMR2.IndividualParametersPersonalized=IndividualParametersPersonalized;
                
                if 1
                    % adjust whole body maintenance reaction based on new organ weight
                    % fractions
                    % adjust adipocyte and muscle weight to measured one
                    Fat_fraction = 1 - str2num(InputData{5,3})/str2num(InputData{4,3});
                    FatDiff = Fat_fraction-OrganWeightFract(11)
                    OrganWeightFract(11) = OrganWeightFract(11)+FatDiff;
                    OrganWeightFract(12) = OrganWeightFract(12)-FatDiff;
                    
                    Fat_weight =  (str2num(InputData{4,3})-str2num(InputData{5,3}))*1000;
                    Fat_weightOri=str2num(IndividualParametersPersonalized.OrgansWeights{11,2});
                    Muscle_weightOri=str2num(IndividualParametersPersonalized.OrgansWeights{12,2});
                    % substract higher fat_weight from Muscle_weight
                    Muscle_weight = Muscle_weightOri-(Fat_weight - Fat_weightOri);
                    
                    IndividualParametersPersonalized.OrgansWeights{11,2} = num2str(Fat_weight);
                    IndividualParametersPersonalized.OrgansWeights{11,3} = num2str(OrganWeightFract(11)*100);
                    IndividualParametersPersonalized.OrgansWeights{12,2} = num2str(Muscle_weight);
                    IndividualParametersPersonalized.OrgansWeights{12,3} = num2str(OrganWeightFract(12)*100);
                end
                [femaleBMR2] = adjustWholeBodyRxnCoeff(femaleBMR2, listOrgan, OrganWeightFract);
                femaleBMR2.listOrgan = listOrgan;
                femaleBMR2.OrganWeightFract = OrganWeightFract;
                femaleBMR2 = setDietConstraints(femaleBMR2);
                % set some more constraints
                %femaleBMR2 = setSimulationConstraints(femaleBMR2);
                femaleBMR2 = physiologicalConstraintsHMDBbased(femaleBMR2,IndividualParametersPersonalized);
                
                %femaleBMR2.ub(strmatch('Brain_EX_glc_D(',femaleBMR2.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state
                
                CO(i,cnt) = IndividualParametersPersonalized.CardiacOutput;
                BM = (find(~cellfun(@isempty,strfind(femaleBMR2.rxns,'Heart_DM_atp'))));
                femaleBMR2.lb(BM) = 1000;
                
                femaleBMR2 = changeObjective(femaleBMR2,'Whole_body_objective_rxn');
                femaleBMR2.osense = -1;
                [solution] = computeMin2Norm_HH(femaleBMR2);
                solStat(i,cnt) = solution.origStat;
                
                S = femaleBMR2.A;
                F = max(-S,0);
                R = max(S,0);
                vf = max(solution.full,0);
                vr = max(-solution.full,0);
                production=[R F]*[vf; vr];
                consumption=[F R]*[vf; vr];
                % find all reactions in the model that involve atp
                atp = (find(~cellfun(@isempty,strfind(femaleBMR2.mets,'_atp['))));
                % sum of atp consumption in the flux distribution
                Sum_atp_femaleBMR2=sum(consumption(atp,1)); % (in mmol ATP/day/person)
                % compute the energy release in kJ
                Energy_kJ_femaleBMR2(i,cnt) = Sum_atp_femaleBMR2/1000 * 64 % (in kJ/day/person)
                
                % compute the energy release in kcal, where 1 kJ = 0.239006 kcal
                Energy_kcal_femaleBMR2(i,cnt) =  Energy_kJ_femaleBMR2(i,cnt) *0.239006; % (in kcal/day/person)
            end
        end
        cnt = cnt +1;
        save Results_sensi2_2018_10_08x
    end
end
for i = 3 : size(InputDataAll,2)
    BMR_female_20(:,i) = calculateBMR('female', str2num(InputDataAll{4,i}), str2num(InputDataAll{3,i}), str2num(InputDataAll{2,i}));
end

%%
% test multiple BMR's
if 0

gender = 'male';
standardPhysiolDefaultParameters;
IndividualParameters_male = IndividualParameters;

male = physiologicalConstraintsHMDBbased(male,IndividualParameters_male);
EUAverageDietNew;
male = setDietConstraints(male, Diet);

male = setSimulationConstraints(male);

minInf = -1000000;
maxInf = 1000000;
minConstraints = length(intersect(find(male.lb>minInf),find(male.lb)));
maxConstraints =length(intersect(find(male.ub<maxInf),find(male.ub)));

male = changeObjective(male,'Whole_body_objective_rxn');
male.osense = -1;

% adjust Muscle and fat atp in biomass - compute and compare BMF's with
% BMRs

sensi_analysis = [1; 5; 10;50;100 ];

cnt = 1;
for y =3 %1 : length(sensi_analysis)
    maleBMR = male;
    
    maleBMR.S = maleBMR.A;
    
    % maleBMR
    BM = (find(~cellfun(@isempty,strfind(maleBMR.rxns,'Muscle_biomass_'))));
    
    % find all reactions in the model that involve atp
    atp = (find(~cellfun(@isempty,strfind(maleBMR.mets,'_atp[c'))));
    adp = (find(~cellfun(@isempty,strfind(maleBMR.mets,'_adp[c'))));
    pi = (find(~cellfun(@isempty,strfind(maleBMR.mets,'_pi[c'))));
    h = (find(~cellfun(@isempty,strfind(maleBMR.mets,'_h[c'))));
    h2o = (find(~cellfun(@isempty,strfind(maleBMR.mets,'_h2o[c'))));
    BMatpSum = 0;
    for i = 1: length(BM)
        % grab atp
        BMmets = (find(maleBMR.S(:,BM(i))));
        BMatp = intersect(BMmets,atp);
        maleBMR.S(BMatp,BM(i))= maleBMR.S(BMatp,BM(i)) *sensi_analysis(y);
        BMatp = intersect(BMmets,adp);
        maleBMR.S(BMatp,BM(i))= maleBMR.S(BMatp,BM(i)) *sensi_analysis(y);
        BMatp = intersect(BMmets,pi);
        maleBMR.S(BMatp,BM(i))= maleBMR.S(BMatp,BM(i)) *sensi_analysis(y);
        BMatp = intersect(BMmets,h);
        maleBMR.S(BMatp,BM(i))= maleBMR.S(BMatp,BM(i)) *sensi_analysis(y);
        BMatp= intersect(BMmets,h2o);
        maleBMR.S(BMatp,BM(i))= maleBMR.S(BMatp,BM(i)) *sensi_analysis(y);
    end
    
    Energy_kJ_maleBMR2(1,cnt) = sensi_analysis(y);
    for z =1%1: length(sensi_analysis)
        maleBMR2 = maleBMR;
        BM = (find(~cellfun(@isempty,strfind(maleBMR2.rxns,'Adipocytes_biomass_'))));
        for i = 1: length(BM)
            % grab atp
            BMmets = (find(maleBMR2.S(:,BM(i))));
            BMatp = intersect(BMmets,atp);
            maleBMR2.S(BMatp,BM(i))= maleBMR2.S(BMatp,BM(i)) *sensi_analysis(z);
            BMatp = intersect(BMmets,adp);
            maleBMR2.S(BMatp,BM(i))= maleBMR2.S(BMatp,BM(i)) *sensi_analysis(z);
            BMatp = intersect(BMmets,pi);
            maleBMR2.S(BMatp,BM(i))= maleBMR2.S(BMatp,BM(i))*sensi_analysis(z);
            BMatp = intersect(BMmets,h);
            maleBMR2.S(BMatp,BM(i))= maleBMR2.S(BMatp,BM(i)) *sensi_analysis(z);
            BMatp= intersect(BMmets,h2o);
            maleBMR2.S(BMatp,BM(i))= maleBMR2.S(BMatp,BM(i)) *sensi_analysis(z);
        end
        
        Energy_kJ_maleBMR2(2,cnt) = sensi_analysis(z);
        
        maleBMR2.A = maleBMR2.S;
        
        InputDataAll =  {
            'gender' ''	'male'		'female'		'female'		'female'		'female'		'female'		'male'		'female'		'male'		'male'		'male'		'female'		'male'		'male'		'male'		'male'		'male'		'female'		'female'		'female'		'male'		'male'		'male'		'female'		'male'		'male'		'male'		'male'
            'age' '' num2str(15) num2str(14) num2str(12) num2str(18) num2str(16) num2str(15) num2str(17) num2str(11) num2str(13) num2str(14) num2str(16) num2str(16) num2str(12) num2str(15) num2str(16) num2str(18) num2str(13) num2str(11) num2str(12) num2str(17) num2str(12) num2str(15) num2str(17) num2str(12) num2str(15) num2str(15) num2str(14) num2str(15)
            'Height' '' num2str(168) num2str(164) num2str(152) num2str(162) num2str(166) num2str(173) num2str(172) num2str(161) num2str(164) num2str(165) num2str(170) num2str(156) num2str(172) num2str(175) num2str(177) num2str(173) num2str(161) num2str(155) num2str(157) num2str(165) num2str(150) num2str(174) num2str(175) num2str(139) num2str(184) num2str(162) num2str(159.5) num2str(177)
            'Weight' '' num2str(60.8) num2str(56.8) num2str(40.2) num2str(53.2) num2str(54.1) num2str(62.9) num2str(64.4) num2str(56.2) num2str(47.9) num2str(52.8) num2str(65.6) num2str(49.9) num2str(58) num2str(69.1) num2str(64.8) num2str(63.5) num2str(48) num2str(50.4) num2str(44.3) num2str(58) num2str(40.1) num2str(61.2) num2str(64.6) num2str(35.4) num2str(65.8) num2str(47.4) num2str(48.2) num2str(59.6)
            'Fat-free' '' num2str(51.66) num2str(40.08) num2str(30.08) num2str(43.71) num2str(42.88) num2str(53.44) num2str(58.18) num2str(36.4) num2str(41.4) num2str(47) num2str(55.91) num2str(39.52) num2str(48.23) num2str(59.75) num2str(56) num2str(53.86) num2str(42) num2str(33.75) num2str(37.31) num2str(45.31) num2str(33.62) num2str(53.22) num2str(56.62) num2str(20) num2str(49) num2str(38.56) num2str(39) num2str(50)
            'BMI' '' num2str(21.54) num2str(21.12) num2str(17.4) num2str(20.27) num2str(19.63) num2str(21.02) num2str(21.77) num2str(21.68) num2str(17.81) num2str(19.39) num2str(22.7) num2str(20.5) num2str(19.61) num2str(22.56) num2str(20.68) num2str(21.22) num2str(18.52) num2str(20.98) num2str(17.97) num2str(21.3) num2str(17.82) num2str(20.21) num2str(21.09) num2str(18.32) num2str(19.44) num2str(18.06) num2str(18.95) num2str(19.02)
            'BMR' '' num2str(1661.16) num2str(1414.97) num2str(1282.42) num2str(1489.45) num2str(1277.24) num2str(1582.33) num2str(1515.13) num2str(1495.3) num2str(1775.51) num2str(1576.21) num2str(1476.97) num2str(1271.78) num2str(1551.96) num2str(2039.63) num2str(1808.9) num2str(1537.86) num2str(1457.89) num2str(1243.59) num2str(1443.9) num2str(1318.07) num2str(1249.74) num2str(1537.93) num2str(1633.33) num2str(1103.2) num2str(1508.41) num2str(1393.85) num2str(1167.48) num2str(1612.75)
            };
        
        maleBMR2O=maleBMR2;
        for i = 3 :  size(InputDataAll,2) %
            InputData =  [InputDataAll(:,1), InputDataAll(:,2), InputDataAll(:,i)];
            maleBMR2 = maleBMR2O;
            
            gender =  InputDataAll(1,i);
            maleBMR2.gender = gender;
            if strcmp(gender,'male')
                optionCardiacOutput = 0; %0 4 2
                [maleBMR2,IndividualParametersPersonalized] = individualizedLabReport(maleBMR2,IndividualParameters_male, InputData,optionCardiacOutput);
                % 3. set personalized constraints
                maleBMR2.IndividualParametersPersonalized=IndividualParametersPersonalized;
                % 3. set personalized constraints
                
                % calculate new organ weight fraction for a given personalized weight
                [listOrgan,OrganWeight,OrganWeightFract,IndividualParametersPersonalized] = calcOrganFract(maleBMR2,IndividualParametersPersonalized);
                
                % I repeat this step, as I calculate in some options the CO based on
                % bloodVol which is only calculated in calcOrganFract
                [maleBMR2,IndividualParametersPersonalized] = individualizedLabReport(maleBMR2,IndividualParametersPersonalized, InputData,optionCardiacOutput);
                maleBMR2.IndividualParametersPersonalized=IndividualParametersPersonalized;
                
                if 1
                    % adjust whole body maintenance reaction based on new organ weight
                    % fractions
                    % adjust adipocyte and muscle weight to measured one
                    Fat_fraction = 1 - str2num(InputData{5,3})/str2num(InputData{4,3});
                    FatDiff = Fat_fraction-OrganWeightFract(11)
                    OrganWeightFract(11) = OrganWeightFract(11)+FatDiff;
                    OrganWeightFract(12) = OrganWeightFract(12)-FatDiff;
                    
                    Fat_weight =  (str2num(InputData{4,3})-str2num(InputData{5,3}))*1000;
                    Fat_weightOri=str2num(IndividualParametersPersonalized.OrgansWeights{11,2});
                    Muscle_weightOri=str2num(IndividualParametersPersonalized.OrgansWeights{12,2});
                    % substract higher fat_weight from Muscle_weight
                    Muscle_weight = Muscle_weightOri-(Fat_weight - Fat_weightOri);
                    
                    IndividualParametersPersonalized.OrgansWeights{11,2} = num2str(Fat_weight);
                    IndividualParametersPersonalized.OrgansWeights{11,3} = num2str(OrganWeightFract(11)*100);
                    IndividualParametersPersonalized.OrgansWeights{12,2} = num2str(Muscle_weight);
                    IndividualParametersPersonalized.OrgansWeights{12,3} = num2str(OrganWeightFract(12)*100);
                end
                [maleBMR2] = adjustWholeBodyRxnCoeff(maleBMR2, listOrgan, OrganWeightFract);
                maleBMR2.listOrgan = listOrgan;
                maleBMR2.OrganWeightFract = OrganWeightFract;
                maleBMR2 = setDietConstraints(maleBMR2);
                % set some more constraints
                %maleBMR2 = setSimulationConstraints(maleBMR2);
                maleBMR2 = physiologicalConstraintsHMDBbased(maleBMR2,IndividualParametersPersonalized);
                
                %maleBMR2.ub(strmatch('Brain_EX_glc_D(',maleBMR2.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state
                
                CO(i,cnt) = IndividualParametersPersonalized.CardiacOutput;
                BM = (find(~cellfun(@isempty,strfind(maleBMR2.rxns,'Heart_DM_atp'))));
                maleBMR2.lb(BM) = 6000;
                
                maleBMR2 = changeObjective(maleBMR2,'Whole_body_objective_rxn');
                maleBMR2.osense = -1;
                [solution] = computeMin2Norm_HH(maleBMR2);
                solStat(i,cnt) = solution.origStat;
                
                S = maleBMR2.A;
                F = max(-S,0);
                R = max(S,0);
                vf = max(solution.full,0);
                vr = max(-solution.full,0);
                production=[R F]*[vf; vr];
                consumption=[F R]*[vf; vr];
                % find all reactions in the model that involve atp
                atp = (find(~cellfun(@isempty,strfind(maleBMR2.mets,'_atp['))));
                % sum of atp consumption in the flux distribution
                Sum_atp_maleBMR2=sum(consumption(atp,1)); % (in mmol ATP/day/person)
                % compute the energy release in kJ
                Energy_kJ_maleBMR2(i,cnt) = Sum_atp_maleBMR2/1000 * 64 % (in kJ/day/person)
                
                % compute the energy release in kcal, where 1 kJ = 0.239006 kcal
                Energy_kcal_maleBMR2(i,cnt) =  Energy_kJ_maleBMR2(i,cnt) *0.239006; % (in kcal/day/person)
            end
        end
        cnt = cnt +1;
        save Results_sensi2_2018_10_08x
    end
end
end
for i = 3 : size(InputDataAll,2)
    BMR_male_20(:,i) = calculateBMR('male', str2num(InputDataAll{4,i}), str2num(InputDataAll{3,i}), str2num(InputDataAll{2,i}));
end

save Results_sensi2_2018_10_08x