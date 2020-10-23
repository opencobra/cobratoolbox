% This script repeats the simulation described in Thiele et al.,
% "Personalized whole-body models integrate metabolism, physiology, and the gut microbiome", Method section 3.9.1. Identify  parameters that affect prediction accuracy.
% The input data come from A. M. Prentice et al., High levels of energy expenditure in obese women. Brit Med J, 292: 983-287 (1986).

if ~exist('fatFreeAdj','var')
    fatFreeAdj = 0; % adjust for fat free mass measured
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('useSolveCobraLPCPLEX','var')
    global useSolveCobraLPCPLEX
end

sex = female.sex;
standardPhysiolDefaultParameters;
IndividualParameters_female = IndividualParameters;

if ~exist('female','var')
    % only female data were available
    female = loadPSCMfile('Harvetta');
end

female = physiologicalConstraintsHMDBbased(female,IndividualParameters_female);
EUAverageDietNew;
female = setDietConstraints(female, Diet);

female = setSimulationConstraints(female);

% female.lb(strmatch('BBB_KYNATE[CSF]upt',female.rxns)) = -1000000;
% female.lb(strmatch('BBB_LKYNR[CSF]upt',female.rxns)) = -1000000;
% female.lb(strmatch('BBB_TRP_L[CSF]upt',female.rxns)) = -1000000;
% female.ub(strmatch('Brain_EX_glc_D(',female.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state


minInf = -1000000;
maxInf = 1000000;
minConstraints = length(intersect(find(female.lb>minInf),find(female.lb)));
maxConstraints =length(intersect(find(female.ub<maxInf),find(female.ub)));

if 0
    female = changeObjective(female,'Whole_body_objective_rxn');
    female.osenseStr = 'max';
else
    female.c(:) = 0;
end

Sum_atp_femaleBMR2 = [];

% adjust Muscle and fat atp in biomass - compute and compare BMF's with
% BMRs

sensi_analysis = [1; 5; 10; ];

cnt = 1;
for y = 1 : length(sensi_analysis)
    femaleBMR = female;
    
    if useSolveCobraLPCPLEX
        femaleBMR.S = femaleBMR.A;
    end
    
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
    for z = 1%: length(sensi_analysis)
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
        
        if useSolveCobraLPCPLEX
            femaleBMR2.A = femaleBMR2.S;
        end
        
        InputDataAll =  {
            'sex', '','female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female';
            'age' , '', num2str(37),  num2str(33), num2str(31), num2str(23), num2str(23), num2str(32), num2str(28), num2str(26), num2str(24), num2str(24), num2str(31), num2str(29), num2str(38), num2str(32), num2str(27), num2str(40), num2str(39), num2str(36), num2str(38), num2str(26), num2str(37), num2str(39);
            'Height' , '', num2str(161), num2str(158), num2str(163), num2str(165), num2str(163), num2str(158), num2str(163), num2str(160), num2str(156), num2str(180), num2str(151), num2str(150), num2str(170), num2str(161), num2str(160), num2str(168), num2str(161), num2str(164), num2str(162), num2str(160), num2str(169), num2str(165);
            'Weight', '', num2str(57.6), num2str(49.5), num2str(55.7), num2str(56.2), num2str(53.2), num2str(49.7), num2str(64.6), num2str(60.6), num2str(59), num2str(71.4), num2str(62.9), num2str(51), num2str(56.4), num2str(74.9), num2str(88.6), num2str(120.1), num2str(83.1), num2str(80.5), num2str(80.3), num2str(79.7), num2str(82.4), num2str(102.1);
            'Fat-free','',  num2str(41.0),  num2str(43.6), num2str(42.9), num2str(41.5), num2str(37.6), num2str(35), num2str(40.8), num2str(43.5), num2str(41.9), num2str(50.2), num2str(43.3), num2str(35.3), num2str(40.7), num2str(44.4), num2str(47.5), num2str(60.6), num2str(47.5), num2str(48.8), num2str(45.9), num2str(44.8), num2str(48.4), num2str(54.2);
            'BMR','', num2str(5.37), num2str(6.19), num2str(5.91), num2str(5.85), num2str(5.06), num2str(5.31), num2str(5.54), num2str(5.65), num2str(5.76), num2str(6.4), num2str(5.9), num2str(4.67), num2str(5.86), num2str(6.7), num2str(6.77), num2str(8.2), num2str(6.64), num2str(6.54), num2str(6.42), num2str(6.43), num2str(5.59), num2str(6.73);
            };
        femaleBMR2O=femaleBMR2;
        for i = 3 :  15% size(InputDataAll,2) % only normal BMI's
            InputData =  [InputDataAll(:,1), InputDataAll(:,2), InputDataAll(:,i)];
            femaleBMR2 = femaleBMR2O;
            
            sex =  InputDataAll(1,i);
            femaleBMR2.sex = sex;
            
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
            
            if fatFreeAdj ==1
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
            %adjusts whole body reaction coefficients and prints out 'Whole_body_objective_rxn'
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
            femaleBMR2.lb(BM) = 1000; % as BMR is determined at absolute rest

            if useSolveCobraLPCPLEX
                femaleBMR2 = changeObjective(femaleBMR2,'Whole_body_objective_rxn');
                femaleBMR2.osense = -1;
                [solution] = computeMin2Norm_HH(femaleBMR2);
            else
                param.minNorm = 1e-6;
                solution = optimizeWBModel(femaleBMR2, param);
            end
            %stat(i,cnt) = solution.stat;
            %origStat(i,cnt) = solution.origStat;
            
            if solution.stat==1 || solution.stat==3
                if useSolveCobraLPCPLEX
                    F = max(-femaleBMR2.A,0);
                    R = max(femaleBMR2.A,0);
                else
                    F = max(-femaleBMR2.S,0);
                    R = max(femaleBMR2.S,0);
                end
                vf = max(solution.v,0);
                vr = max(-solution.v,0);
                production=[R F]*[vf; vr];
                consumption=[F R]*[vf; vr];
                % find all reactions in the model that involve atp
                atp = (find(~cellfun(@isempty,strfind(femaleBMR2.mets,'_atp['))));
                % sum of atp consumption in the flux distribution
                Sum_atp_femaleBMR2=sum(consumption(atp,1)); % (in mmol ATP/day/person)
                % compute the energy release in kJ
                Energy_kJ_femaleBMR2(i,cnt) = Sum_atp_femaleBMR2/1000 * 64; % (in kJ/day/person)
           else
               % NaN if no solution reported
               Energy_kJ_femaleBMR2(i,cnt) = NaN;
           end
            
            % compute the energy release in kcal, where 1 kJ = 0.239006 kcal
            Energy_kcal_femaleBMR2(i,cnt) =  Energy_kJ_femaleBMR2(i,cnt) *0.239006; % (in kcal/day/person)
            Energy_kcal_femaleBMR2_origStatText{i,cnt}  = solution.origStatText;
        end
        cnt = cnt +1;
        if 0
            if fatFreeAdj ==1
                %save Results_sensi_2018_12_14_fatAdj
                save([resultsPath 'Results_sensi_fatAdj'])
                
            else
                %save Results_sensi_2018_12_14_no_fatAdj
                save([resultsPath 'Results_sensi_no_fatAdj'])
            end
        end
    end
end
for i = 3 : 15 % size(InputDataAll,2) - only normal BMI's
    BMR_female_All(:,i) = calculateBMR('female', str2num(InputDataAll{4,i}), str2num(InputDataAll{3,i}), str2num(InputDataAll{2,i}));
end
% if fatFreeAdj ==1
%     save Results_sensi_2018_12_14_fatAdj
% else
%     save Results_sensi_2018_12_14_no_fatAdj
% end

if ~exist('resultsPath','var')
    global resultsPath
    resultsPath = which('MethodSection3.mlx');
    resultsPath = strrep(resultsPath,'MethodSection3.mlx',['Results' filesep]);
end

if fatFreeAdj ==1
    %save Results_sensi_2018_12_14_fatAdj
    save([resultsPath 'Results_sensi_fatAdj'],'BMR_female_All','InputDataAll','Energy_kcal_femaleBMR2','Sum_atp_femaleBMR2','Energy_kcal_femaleBMR2_origStatText')
else
    %save Results_sensi_2018_12_14_no_fatAdj
    save([resultsPath 'Results_sensi_no_fatAdj'],'BMR_female_All','InputDataAll','Energy_kcal_femaleBMR2','Sum_atp_femaleBMR2','Energy_kcal_femaleBMR2_origStatText')
end