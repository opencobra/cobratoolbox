InputDataAll =  {
    'gender', '','female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female';
    'age' , '', num2str(37),  num2str(33), num2str(31), num2str(23), num2str(23), num2str(32), num2str(28), num2str(26), num2str(24), num2str(24), num2str(31), num2str(29), num2str(38), num2str(32), num2str(27), num2str(40), num2str(39), num2str(36), num2str(38), num2str(26), num2str(37), num2str(39);
    'Height' , '', num2str(161), num2str(158), num2str(163), num2str(165), num2str(163), num2str(158), num2str(163), num2str(160), num2str(156), num2str(180), num2str(151), num2str(150), num2str(170), num2str(161), num2str(160), num2str(168), num2str(161), num2str(164), num2str(162), num2str(160), num2str(169), num2str(165);
    'Weight', '', num2str(57.6), num2str(49.5), num2str(55.7), num2str(56.2), num2str(53.2), num2str(49.7), num2str(64.6), num2str(60.6), num2str(59), num2str(71.4), num2str(62.9), num2str(51), num2str(56.4), num2str(74.9), num2str(88.6), num2str(120.1), num2str(83.1), num2str(80.5), num2str(80.3), num2str(79.7), num2str(82.4), num2str(102.1);
    'Fat-free','',  num2str(41.0),  num2str(43.6), num2str(42.9), num2str(41.5), num2str(37.6), num2str(35), num2str(40.8), num2str(43.5), num2str(41.9), num2str(50.2), num2str(43.3), num2str(35.3), num2str(40.7), num2str(44.4), num2str(47.5), num2str(60.6), num2str(47.5), num2str(48.8), num2str(45.9), num2str(44.8), num2str(48.4), num2str(54.2);
    'BMR','', num2str(5.37), num2str(6.19), num2str(5.91), num2str(5.85), num2str(5.06), num2str(5.31), num2str(5.54), num2str(5.65), num2str(5.76), num2str(6.4), num2str(5.9), num2str(4.67), num2str(5.86), num2str(6.7), num2str(6.77), num2str(8.2), num2str(6.64), num2str(6.54), num2str(6.42), num2str(6.43), num2str(5.59), num2str(6.73);
    };

InputDataAll =  {
    'gender', '','female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female';
    'age' , '', num2str(37),  num2str(33), num2str(31), num2str(23), num2str(23), num2str(32), num2str(28), num2str(26), num2str(24), num2str(24), num2str(31), num2str(29), num2str(38), num2str(32), num2str(27), num2str(40), num2str(39), num2str(36), num2str(38), num2str(26), num2str(37), num2str(39);
    'Height' , '', num2str(161), num2str(158), num2str(163), num2str(165), num2str(163), num2str(158), num2str(163), num2str(160), num2str(156), num2str(180), num2str(151), num2str(150), num2str(170), num2str(161), num2str(160), num2str(168), num2str(161), num2str(164), num2str(162), num2str(160), num2str(169), num2str(165);
    'Weight', '', num2str(57.6), num2str(49.5), num2str(55.7), num2str(56.2), num2str(53.2), num2str(49.7), num2str(64.6), num2str(60.6), num2str(59), num2str(71.4), num2str(62.9), num2str(51), num2str(56.4), num2str(74.9), num2str(88.6), num2str(120.1), num2str(83.1), num2str(80.5), num2str(80.3), num2str(79.7), num2str(82.4), num2str(102.1);
    };

InputDataAll =  {
    'gender', '','female', 'female', 'female', 'female', 'female', 'female';
    'age' , '', num2str(20),  num2str(20), num2str(20), num2str(20), num2str(20), num2str(20);
    'Height' , '', num2str(160), num2str(160), num2str(160), num2str(170), num2str(170), num2str(170);
    'Weight', '', num2str(52), num2str(55), num2str(60), num2str(60), num2str(65), num2str(70);
    };


femaleBMR2O=female;
cnt =1 ;
for i = 3 :  size(InputDataAll,2) %
    
    InputData =  [InputDataAll(:,1), InputDataAll(:,2), InputDataAll(:,i)];
    femaleBMR2 = femaleBMR2O;
    
    gender =  InputDataAll(1,i);
    femaleBMR2.gender = gender;
    
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
    
    if 0
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
    %femaleBMR2.lb(BM) = 0;
    
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

for i = 3 :  size(InputDataAll,2)
BMR_female(:,i) = calculateBMR('female', str2num(InputDataAll{4,i}), str2num(InputDataAll{3,i}), str2num(InputDataAll{2,i}));
end