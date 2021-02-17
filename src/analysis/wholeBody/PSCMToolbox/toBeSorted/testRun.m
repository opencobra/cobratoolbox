OrganLists;
%ResultsAll = [];
%Results.List = [];
female = {'SRS011239'
    'SRS011302'
    'SRS011405'
    'SRS011586'
    'SRS012273'
    'SRS012902'
    'SRS013521'
    'SRS014313'
    'SRS014459'
    'SRS014613'
    'SRS014979'
    'SRS015065'
    'SRS015133'
    'SRS015190'
    'SRS015217'
    'SRS015369'
    'SRS016095'
    'SRS016203'
    'SRS016495'
    'SRS016517'
    'SRS016585'
    'SRS017433'
    'SRS017521'
    'SRS017701'
    'SRS018656'
    'SRS019267'
    'SRS019601'
    'SRS019968'
    'SRS020328'
    'SRS021948'
    'SRS022071'
    'SRS022137'
    'SRS022524'
    'SRS022713'
    'SRS023346'
    'SRS023583'
    'SRS023829'
    'SRS024009'
    'SRS024265'
    'SRS024388'
    'SRS042284'
    'SRS043001'
    'SRS043411'
    'SRS048870'
    'SRS049995'
    'SRS050752'
    'SRS051882'
    'SRS052697'
    'SRS053214'
    'SRS053335'
    'SRS053398'
    'SRS054590'
    'SRS054956'
    'SRS055982'
    'SRS057478'
    'SRS057717'
    'SRS058723'
    'SRS063040'
    'SRS063985'
    'SRS064276'
    'SRS064557'
    'SRS065504'
    'SRS075398'
    'SRS077730'
    'SRS078176'
    'SRS024388'
    'SRS011061'
    };

male = {'SRS011134'
    'SRS011271'
    'SRS011452'
    'SRS011529'
    'SRS013158'
    'SRS013215'
    'SRS013476'
    'SRS013687'
    'SRS013800'
    'SRS013951'
    'SRS014235'
    'SRS014287'
    'SRS014683'
    'SRS014923'
    'SRS015264'
    'SRS015578'
    'SRS015663'
    'SRS015782'
    'SRS015794'
    'SRS015854'
    'SRS015960'
    'SRS016018'
    'SRS016056'
    'SRS016267'
    'SRS016335'
    'SRS016753'
    'SRS016954'
    'SRS016989'
    'SRS017103'
    'SRS017191'
    'SRS017247'
    'SRS017307'
    'SRS017821'
    'SRS018133'
    'SRS018313'
    'SRS018351'
    'SRS018427'
    'SRS018575'
    'SRS018817'
    'SRS019030'
    'SRS019161'
    'SRS019397'
    'SRS019582'
    'SRS019685'
    'SRS019787'
    'SRS019910'
    'SRS020233'
    'SRS020869'
    'SRS021484'
    'SRS022609'
    'SRS023176'
    'SRS023526'
    'SRS023914'
    'SRS023971'
    'SRS024075'
    'SRS024132'
    'SRS024331'
    'SRS024435'
    'SRS024549'
    'SRS024625'
    'SRS042628'
    'SRS043701'
    'SRS045004'
    'SRS045645'
    'SRS045713'
    'SRS064645'
    'SRS011084'
    'SRS047014'
    %
    'SRS047044'
    'SRS048164'
    'SRS049164'
    'SRS049712'
    'SRS049900'
    'SRS049959'
    'SRS050299'
    'SRS050422'
    'SRS050925'
    'SRS051031'
    'SRS052027'
    'SRS056259'
    'SRS056519'
    'SRS058770'
    'SRS062427'
    'SRS064645'
    
    };
for j = 1 : length(male)
    if 1
        if strcmp(gender,'male')
            S= load(strcat('Y:\Federico\HMP\Run_Almut_17_03_31_with10_new_strains\Results_Setup2\microbiota_model_samp_',male{j}));
            microbiota_model = S.microbiota_model;
            %  load Y:\Federico\HMP\Run_Almut_17_03_31_with10_new_strains\Results_Setup2\microbiota_model_samp_SRS064645.mat
            % load Y:\Federico\HMP\Run_Almut_17_03_31_with10_new_strains\Results_Setup2\microbiota_model_samp_SRS011084.mat
        else
            % load Y:\Federico\HMP\Run_Almut_17_03_31_with10_new_strains\Results_Setup2\microbiota_model_samp_SRS024388.mat
            % load Y:\Federico\HMP\Run_Almut_17_03_31_with10_new_strains\Results_Setup2\microbiota_model_samp_SRS011061.mat
            S= load(strcat('Y:\Federico\HMP\Run_Almut_17_03_31_with10_new_strains\Results_Setup2\microbiota_model_samp_',female{j}));
            microbiota_model = S.microbiota_model;
        end
        
        modelHM = combineHarveyMicrotiota(microbiota_model,modelOrganAllCoupled);
    end
    k = 1;
    if 0
        modelHM.lb(find(ismember(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=1; %
        modelHM.ub(find(ismember(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=1; %
        
        modelOrganAllCoupled = changeRxnBounds(modelOrganAllCoupled,'Whole_body_objective_rxn',1000,'u');
        modelHM = changeRxnBounds(modelHM,'Whole_body_objective_rxn',1000,'u');
        
        Results.List{1,k} = 'Whole_body_objective_rxn';k = k+1;
        modelHM = changeObjective(modelHM,'Whole_body_objective_rxn');
        modelHM.osense = -1;
        tic;[solutionHM_Max,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
        Results.List{1,k} = num2str(solutionHM_Max.obj);k = k+1;
        if 1
            modelOrganAllCoupled = changeObjective(modelOrganAllCoupled,'Whole_body_objective_rxn');
            modelOrganAllCoupled.osense = -1;
            tic;[solutionGF_Max,LPProblem]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');toc
            Results.List{1,k} = num2str(solutionGF_Max.obj);k = k+1;
            Results.List{1,k} = num2str(solutionHM_Max.obj/solutionGF_Max.obj);k = k+1;
        end
        
        modelOrganAllCoupled = changeRxnBounds(modelOrganAllCoupled,'Whole_body_objective_rxn',1,'b');
        modelHM = changeRxnBounds(modelHM,'Whole_body_objective_rxn',1,'b');
        
        % minimize all [u] output
        M1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'Kidney_EX_'))));
        M2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'[u]'))));
        M = setdiff(M2,M1);
        modelOrganAllCoupled.c = zeros(length(modelOrganAllCoupled.rxns),1);
        modelOrganAllCoupled.c(M) =1;
        modelOrganAllCoupled.osense = -1;%max
        tic;[solutionGF,LPProblem]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');toc
        USecretion(:,1)=solutionGF.full(M);
        % [bc] metabolites
        %     K1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'Kidney_EX'))));
        %     K2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'(e)_[bc]'))));
        %     M = intersect(K1,K2);
        %     modelOrganAllCoupled.c = zeros(length(modelOrganAllCoupled.rxns),1);
        %     modelOrganAllCoupled.c(M) =1;
        %     modelOrganAllCoupled.osense = 1;%min
        %     tic;[solutionGF,LPProblem]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');toc
        %     KSecretion(:,1)=solutionGF.full(M);
        
        %bbb metabolites
        K1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'BBB_'))));
        K2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'[CSF]upt'))));
        M = intersect(K1,K2);
        modelOrganAllCoupled.c = zeros(length(modelOrganAllCoupled.rxns),1);
        modelOrganAllCoupled.c(M) =1;
        modelOrganAllCoupled.osense = 1;%min
        tic;[solutionGF,LPProblem]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');toc
        BSecretion(:,1)=solutionGF.full(M);
        
        %     for i = 1 :length(OrgansListShort)
        %         k = 1;
        %         Results.List{i+1,k} = OrgansListShort{i};k = k+1;
        %         if ~isempty(find(ismember(modelHM.rxns,strcat(OrgansListShort{i},'_DM_atp_c_'))))
        %             modelHM = changeObjective(modelHM,strcat(OrgansListShort{i},'_DM_atp_c_'));
        %             modelHM.osense = -1;
        %             tic;[solutionHM_Max,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
        %             Results.List{i+1,k} = num2str(solutionHM_Max.obj);k = k+1;
        %             if i==1
        %                 modelOrganAllCoupled = changeObjective(modelOrganAllCoupled,strcat(OrgansListShort{i},'_DM_atp_c_'));
        %                 modelOrganAllCoupled.osense = -1;
        %                 tic;[solutionGF_Max,LPProblem]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');toc
        %                 Results.List{i+1,k} = num2str(solutionGF_Max.obj);k = k+1;
        %                 Results.List{i+1,k} = num2str(solutionHM_Max.obj/solutionGF_Max.obj);k = k+1;
        %             end
        %         end
        %     end
        
        % minimize all [u] output
        M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'Kidney_EX_'))));
        M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[u]'))));
        M = setdiff(M2,M1);
        modelHM.c = zeros(length(modelHM.rxns),1);
        modelHM.c(M) =1;
        modelHM.osense = -1;%max
        tic;[solutionGF,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
        USecretion(:,j+1)=solutionGF.full(M);
        
        %     % maximize all [bc] kidney reactions
        %     K1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'Kidney_EX'))));
        %     K2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'(e)_[bc]'))));
        %     M = intersect(K1,K2);
        %     modelHM.c = zeros(length(modelHM.rxns),1);
        %     modelHM.c(M) =1;
        %     modelHM.osense = 1;%min
        %     tic;[solutionGF,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
        %     KSecretion(:,j+1)=solutionGF.full(M);
        
        %bbb metabolites
        K1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'BBB_'))));
        K2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[CSF]upt'))));
        M = intersect(K1,K2)
        modelHM.c = zeros(length(modelHM.rxns),1);
        modelHM.c(M) =1;
        modelHM.osense = 1;%min
        tic;[solutionGF,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
        BSecretion(:,j+1)=solutionGF.full(M);
        
        ResultsAll = [ResultsAll Results.List];
        if strcmp(gender,'male')
            Results.gender = 'male';
            Results.ID = male{j};
            % save Results_male_microbiota_model_samp_SRS064645.mat modelHM microbiota_model modelOrganAllCoupled Results
            % save Results_male_microbiota_model_samp_SRS011084.mat modelHM microbiota_model modelOrganAllCoupled Results
            save(strcat('Results_male_microbiota_model_samp_',male{j},'.mat'), 'modelHM', 'microbiota_model' ,'modelOrganAllCoupled' ,'Results');
            save ResultsAll_male ResultsAll USecretion  BSecretion % KSecretion
        else
            Results.gender = 'female';
            Results.ID = female{j};
            %   save Results_female_microbiota_model_samp_SRS024388.mat modelHM microbiota_model modelOrganAllCoupled Results
            save(strcat('Results_female_microbiota_model_samp_',female{j},'.mat'), 'modelHM', 'microbiota_model' ,'modelOrganAllCoupled' ,'Results');
            save ResultsAll_female ResultsAll USecretion BSecretion % KSecretion
        end
    else
        
        if strcmp(gender,'male')
            Results.gender = 'male';
            Results.ID = male{j};
            % save Results_male_microbiota_model_samp_SRS064645.mat modelHM microbiota_model modelOrganAllCoupled Results
            % save Results_male_microbiota_model_samp_SRS011084.mat modelHM microbiota_model modelOrganAllCoupled Results
            save(strcat('2017_10_28_male_microbiota_model_samp_',male{j},'.mat'), 'modelHM', 'microbiota_model' ,'modelOrganAllCoupled' );
        else
            Results.gender = 'female';
            Results.ID = female{j};
            %   save Results_female_microbiota_model_samp_SRS024388.mat modelHM microbiota_model modelOrganAllCoupled Results
            save(strcat('2017_10_28_female_microbiota_model_samp_',female{j},'.mat'), 'modelHM', 'microbiota_model' ,'modelOrganAllCoupled' );
        end
    end
end