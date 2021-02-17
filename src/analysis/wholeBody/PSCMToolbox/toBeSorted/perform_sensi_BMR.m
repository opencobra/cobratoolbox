% test multiple BMR's

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
    femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *10;
    BMatp = intersect(BMmets,adp);
    femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *10;
    BMatp = intersect(BMmets,pi);
    femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *10;
    BMatp = intersect(BMmets,h);
    femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *10;
    BMatp= intersect(BMmets,h2o);
    femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *10;
 end
% 
% BM = (find(~cellfun(@isempty,strfind(femaleBMR.rxns,'Heart_biomass_'))));
% for i = 1: length(BM)
%     % grab atp
%     BMmets = (find(femaleBMR.S(:,BM(i))));
%     BMatp = intersect(BMmets,atp);
%     femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *5;
%     BMatp = intersect(BMmets,adp);
%     femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *5;
%     BMatp = intersect(BMmets,pi);
%     femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *5;
%     BMatp = intersect(BMmets,h);
%     femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *5;
%     BMatp= intersect(BMmets,h2o);
%     femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *5;
% end
% 
% BM = (find(~cellfun(@isempty,strfind(femaleBMR.rxns,'Adipocytes_biomass_'))));
% for i = 1: length(BM)
%     % grab atp
%     BMmets = (find(femaleBMR.S(:,BM(i))));
%     BMatp = intersect(BMmets,atp);
%     femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *5;
%     BMatp = intersect(BMmets,adp);
%     femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *5;
%     BMatp = intersect(BMmets,pi);
%     femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *5;
%     BMatp = intersect(BMmets,h);
%     femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *5;
%     BMatp= intersect(BMmets,h2o);
%     femaleBMR.S(BMatp,BM(i))= femaleBMR.S(BMatp,BM(i)) *5;
% end



femaleBMR.A = femaleBMR.S;

o2R = femaleBMR.rxns(find(~cellfun(@isempty,strfind(femaleBMR.rxns,'_EX_o2(e)_[bc]'))));
% replace o2[bc] with RBC_o2[e]
femaleBMR.mets = regexprep(femaleBMR.mets,'o2[bc]','RBC_o2[e]');
%allow lung to secrete o2
femaleBMR.ub( strmatch('Lung_EX_o2(e)_[bc]',femaleBMR.rxns,'exact'))= 100000;
%allow rbc to secrete o2
femaleBMR.ub( strmatch('RBC_EX_o2(e)_[bc]',femaleBMR.rxns,'exact'))= 100000;
%% co2
co2R = femaleBMR.rxns(find(~cellfun(@isempty,strfind(femaleBMR.rxns,'_EX_co2(e)_[bc]'))));
% replace o2[bc] with RBC_o2[e]
femaleBMR.mets = regexprep(femaleBMR.mets,'co2[bc]','RBC_co2[e]');
%allow lung to secrete o2
femaleBMR.lb( strmatch('Lung_EX_co2(e)_[bc]',femaleBMR.rxns,'exact'))= -100000;
%allow rbc to secrete o2
femaleBMR.lb( strmatch('RBC_EX_co2(e)_[bc]',femaleBMR.rxns,'exact'))= -100000;

InputDataAll =  {
    'gender', '','female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female', 'female';
    'age' , '', num2str(37),  num2str(33), num2str(31), num2str(23), num2str(23), num2str(32), num2str(28), num2str(26), num2str(24), num2str(24), num2str(31), num2str(29), num2str(38), num2str(32), num2str(27), num2str(40), num2str(39), num2str(36), num2str(38), num2str(26), num2str(37), num2str(39);
    'Height' , '', num2str(161), num2str(158), num2str(163), num2str(165), num2str(163), num2str(158), num2str(163), num2str(160), num2str(156), num2str(180), num2str(151), num2str(150), num2str(170), num2str(161), num2str(160), num2str(168), num2str(161), num2str(164), num2str(162), num2str(160), num2str(169), num2str(165);
    'Weight', '', num2str(57.6), num2str(49.5), num2str(55.7), num2str(56.2), num2str(53.2), num2str(49.7), num2str(64.6), num2str(60.6), num2str(59), num2str(71.4), num2str(62.9), num2str(51), num2str(56.4), num2str(74.9), num2str(88.6), num2str(120.1), num2str(83.1), num2str(80.5), num2str(80.3), num2str(79.7), num2str(82.4), num2str(102.1);
    'Fat-free','',  num2str(41.0),  num2str(43.6), num2str(42.9), num2str(41.5), num2str(37.6), num2str(35), num2str(40.8), num2str(43.5), num2str(41.9), num2str(50.2), num2str(43.3), num2str(35.3), num2str(40.7), num2str(44.4), num2str(47.5), num2str(60.6), num2str(47.5), num2str(48.8), num2str(45.9), num2str(44.8), num2str(48.4), num2str(54.2);
    'BMR','', num2str(5.37), num2str(6.19), num2str(5.91), num2str(5.85), num2str(5.06), num2str(5.31), num2str(5.54), num2str(5.65), num2str(5.76), num2str(6.4), num2str(5.9), num2str(4.67), num2str(5.86), num2str(6.7), num2str(6.77), num2str(8.2), num2str(6.64), num2str(6.54), num2str(6.42), num2str(6.43), num2str(5.59), num2str(6.73);
    };
femaleBMRO=femaleBMR;
for i = 3 : 3%15% size(InputDataAll,2) non obese only
    InputData =  [InputDataAll(:,1), InputDataAll(:,2), InputDataAll(:,i)];
    femaleBMR = femaleBMRO;
    
    gender =  InputDataAll(1,i);
    femaleBMR.gender = gender;
    
    optionCardiacOutput = 0; %0 4 2
    [femaleBMR,IndividualParametersPersonalized] = individualizedLabReport(femaleBMR,IndividualParameters_female, InputData,optionCardiacOutput);
    % 3. set personalized constraints
    femaleBMR.IndividualParametersPersonalized=IndividualParametersPersonalized;
    % 3. set personalized constraints
    
    % calculate new organ weight fraction for a given personalized weight
    [listOrgan,OrganWeight,OrganWeightFract,IndividualParametersPersonalized] = calcOrganFract(femaleBMR,IndividualParametersPersonalized);
    
    % I repeat this step, as I calculate in some options the CO based on
    % bloodVol which is only calculated in calcOrganFract
    [femaleBMR,IndividualParametersPersonalized] = individualizedLabReport(femaleBMR,IndividualParametersPersonalized, InputData,optionCardiacOutput);
    femaleBMR.IndividualParametersPersonalized=IndividualParametersPersonalized;
    
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
    [femaleBMR] = adjustWholeBodyRxnCoeff(femaleBMR, listOrgan, OrganWeightFract);
    femaleBMR.listOrgan = listOrgan;
    femaleBMR.OrganWeightFract = OrganWeightFract;
    femaleBMR = setDietConstraints(femaleBMR);
    % set some more constraints
    %femaleBMR = setSimulationConstraints(femaleBMR);
    femaleBMR = physiologicalConstraintsHMDBbased(femaleBMR,IndividualParametersPersonalized);
    
    %femaleBMR.ub(strmatch('Brain_EX_glc_D(',femaleBMR.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state
    
    CO(i,1) = IndividualParametersPersonalized.CardiacOutput;
    BM = (find(~cellfun(@isempty,strfind(femaleBMR.rxns,'Heart_DM_atp'))));
femaleBMR.lb(BM) = 0;

    femaleBMR = changeObjective(femaleBMR,'Whole_body_objective_rxn');
    femaleBMR.osense = -1;
    [solution] = computeMin2Norm_HH(femaleBMR);
    solStat(i,1) = solution.origStat;
    
    S = femaleBMR.A;
    F = max(-S,0);
    R = max(S,0);
    vf = max(solution.full,0);
    vr = max(-solution.full,0);
    production=[R F]*[vf; vr];
    consumption=[F R]*[vf; vr];
    % find all reactions in the model that involve atp
    atp = (find(~cellfun(@isempty,strfind(femaleBMR.mets,'_atp['))));
    % sum of atp consumption in the flux distribution
    Sum_atp_femaleBMR=sum(consumption(atp,1)); % (in mmol ATP/day/person)
    % compute the energy release in kJ
    Energy_kJ_femaleBMR(i,1) = Sum_atp_femaleBMR/1000 * 64 % (in kJ/day/person)
    
    % compute the energy release in kcal, where 1 kJ = 0.239006 kcal
    Energy_kcal_femaleBMR = Energy_kJ_femaleBMR*0.239006; % (in kcal/day/person)
end

for i = 3 : size(InputDataAll,2)
    BMR_female_20(:,i) = calculateBMR('female', str2num(InputDataAll{4,i}), str2num(InputDataAll{3,i}), str2num(InputDataAll{2,i}));
end