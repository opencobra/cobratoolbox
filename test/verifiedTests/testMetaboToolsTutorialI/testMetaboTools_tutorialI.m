% The COBRAToolbox: testMetaboTools_tutorialI.m
%
% Purpose:
%     - tests the functions and correct output of consecutively used
%     functions in MetaboTools tutorial I.

% Authors:
%    Maike Aurich, June 2017.
%
clear
global CBTDIR

% save the current path
currentDir = pwd;
outputPath = pwd;

toltests =  1e-6;

% initialize the test
fileDir = fileparts(which('testMetaboTools_tutorialI'));
cd(fileDir);
%%
 % define the solver packages to be used to run this test
solverPkgs = {'glpk', 'ibm_cplex', 'tomlab_cplex'};

for k = 1:length(solverPkgs)
    fprintf(' -- Running testMetaboTools_tutorialI using the solver interface: %s ... ', solverPkgs{k});
    
    solverLPOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);
    solver = solverPkgs{k};
    if solverLPOK
        
        
        
        %% Step *0* Define variables
        
        outputPath = pwd;
        solver = solverPkgs{k};
        
        %%
        % set and check solver
        solverOK = changeCobraSolver(solver, 'LP');
        
        if solverOK == 1
            fprintf('Solver %s is set.\n', solver);
        else
            error('Solver %s could not be used. Check if %s is in the matlab path (set path) or check for typos', solver, solver);
        end
        
        %%
        % load and check input is loaded correctly
        tutorialPath = [CBTDIR filesep 'tutorials' filesep 'metabotools' filesep 'tutorial_I'];
        if isequal(exist([tutorialPath filesep 'starting_model.mat'], 'file'), 2)  % 2 means it's a file.
            load([tutorialPath filesep 'starting_model.mat']);
            fprintf('The model is loaded.\n');
        else
            error('The model ''starting_model'' could not be loaded.');
        end
        
        %%
        % Check output path and writing permission
        if ~exist(outputPath, 'dir') == 7
            error('Output directory in ''outputPath'' does not exist. Verify that you type it correctly or create the directory.');
        end
        
        % make and save dummy file to test writing to output directory
        A = rand(1);
        try
            save([outputPath filesep 'A']);
        catch ME
            error('Files cannot be saved to the provided location: %s\nObtain rights to write into %s directory or set ''outputPath'' to a different directory.', outputPath, outputPath);
        end
        
        %% Step 1: Shaping the model's environment using setMediumConstraints
        % RPMI medium composition.
        load('testdata_setmediumconstraints.mat');
        
        [modelMedium, ~] = setMediumConstraints(starting_model, set_inf, current_inf, medium_composition, met_Conc_mM, cellConc, t, cellWeight, mediumCompounds, mediumCompounds_lb, customizedConstraints, customizedConstraints_ub, customizedConstraints_lb);
        
        FBA = optimizeCbModel(modelMedium);
        
        % % % % test on modelMedium
        ov =0.9228;
        assert(FBA.f - ov < toltests); % tol must be defined previously, e.g. tol = 1e-6;
        
        
        
        %% Step *2* calculateLODs
        load('testdata_calculateLODs.mat');
        [lod_mM] = calculateLODs(theo_mass, lod_ngmL);
        
        % % % test on lod_mM
        load('test_output.mat');
        assert(abs(output_lod_mM(1,1) - lod_mM(1,1)) < toltests); % tol must be defined previously, e.g. tol = 1e-6;
        
        
        %% Step *3* define Uptake and Secretion Profiles
        load('testdata_defineUptakeSecretionProfiles.mat');
        [cond1_uptake, cond2_uptake, cond1_secretion, cond2_secretion, slope_Ratio] = defineUptakeSecretionProfiles(input_A, input_B, data_RXNS, tol, essAA_excl, exclude_upt, exclude_secr, add_secr, add_upt);
        
        
        % % % test on output_defineUptakeSecretionProfiles
        load('output_defineUptakeSecretionProfiles');
        
        assert(abs(length(slope_Ratio) - length(o_slope_Ratio)) < tol); % refData_output2 can be loaded from a file
        assert(abs(length(cond1_uptake) - length(o_cond1_uptake)) < tol); % refData_output2 can be loaded from a file
        assert(abs(length(cond1_secretion) - length(o_cond1_secretion)) < tol); % refData_output2 can be loaded from a file
        assert(abs(length(cond2_uptake) - length(o_cond2_uptake)) < tol); % refData_outp
        assert(abs(length(cond2_secretion) - length(o_cond2_secretion)) < tol); % refData_output2 can be loaded from a file
        
        
        %% Step *4* Calculate Quantitative Diffs
        % MANIPULATE OUTPUT: Add secretion without data points to secretion condition 2.
        load('testdata_calculateQuantitativeDiffs.mat');
        
        cond2_secretion = [cond2_secretion; add_secretion];
        cond2_secretion(ismember(cond2_secretion, remove_secretion)) = [];
        cond2_uptake = [cond2_uptake; add_uptake];
        cond2_uptake(find(ismember(cond2_uptake, remove_uptake))) = [];
        
        [cond1_upt_higher, cond2_upt_higher, cond2_secr_higher, cond1_secr_higher, cond1_uptake_LODs, cond2_uptake_LODs, cond1_secretion_LODs, cond2_secretion_LODs] = calculateQuantitativeDiffs(data_RXNS, slope_Ratio, ex_RXNS, lod_mM, cond1_uptake, cond2_uptake, cond1_secretion, cond2_secretion);
        
        
        % % % test on calculateQuantitativeDiffs
        load('output_calculateQuantitativeDiffs');
        assert(abs(cell2mat(o_cond1_upt_higher(2,2)) - cell2mat(cond1_upt_higher(2,2))) < tol);
        assert(abs(cell2mat(o_cond2_upt_higher(2,2)) - cell2mat(cond2_upt_higher(2,2))) < tol);
        
        assert(abs(cell2mat(o_cond2_secr_higher(2,2)) - cell2mat(cond2_secr_higher(2,2))) < tol);
        assert(abs(cell2mat(o_cond1_secr_higher(2,2)) - cell2mat(cond1_secr_higher(2,2))) < tol);
        
        assert(abs(o_cond1_secretion_LODs(2,1) - cond1_secretion_LODs(2,1)) < tol);
        assert(abs(o_cond1_uptake_LODs(2,1) - cond1_uptake_LODs(2,1)) < tol);
        
        assert(abs(o_cond2_secretion_LODs(2,1) - cond2_secretion_LODs(2,1)) < tol);
        assert(abs(o_cond2_uptake_LODs(2,1) - cond2_uptake_LODs(2,1)) < tol);
        
        
        % MANIPULATE OUTPUT: Remove the metabolites from the uptake and secretion profiles that you adjusted in the previous steps, e.g. those for which you assume a different directionality as in the data, for metabolites that have inconclusive data (e.g., in case of the anth the metabolite was not detected in the 48 hr samples. It coulod be assumed that all of it (down to the LOD) was consumed, however in the case of the two cell lines, the relative difference between the cell lines based on the slope ratio (of consumption) would have been 1975% higher in Molt-4 compared the CCRF-CEM cells. In order to prevent that this extreme point distorts the results, these metabolites need t be removed from the input for semi-quantitative adjustment unless such large differences are justified, and make biological sense).
        
        A = [];
        for i = 1:length(cond2_upt_higher)
            if find(ismember(remove, cond2_upt_higher{i, 1})) > 0
                A = [A; i];
            end
        end
        cond2_upt_higher(A, :) = [];
        
        %% Step *5* setQualitativeConstraints
        
        cellConc = 2.17 * 1e6;
        t = 48;
        cellWeight = 3.645e-12;
        
        %%
        % Molt-4 model
        load('testdata_setQualitativeConstraintsA.mat');
        [model_A] = setQualitativeConstraints(modelMedium, cond1_uptake, cond1_uptake_LODs, cond1_secretion, cond1_secretion_LODs, cellConc, t, cellWeight, ambiguous_metabolites, basisMedium);
        
        %%
        % CCRF-CEM model ModelB
        
        load('testdata_setQualitativeConstraintsB.mat');
        [model_B] = setQualitativeConstraints(modelMedium, cond2_uptake, cond2_uptake_LODs, cond2_secretion, cond2_secretion_LODs, cellConc, t, cellWeight, ambiguous_metabolites, basisMedium);
        
        % % % test on output1
        FBAA = optimizeCbModel(model_A);
        FBAB = optimizeCbModel(model_B);
        
        % % % % test on modelMedium
        ovA =0.9228;
        ovB =0.9228;
        assert(FBAA.f - ovA < toltests); % tol must be defined previously, e.g. tol = 1e-6;
        assert(FBAB.f - ovB < toltests); % t
                
        
        %% Step *5* setSemiQuantConstraints
        % This function applies the constraints to the models. It takes two
        % condition specific models into consideration.
        
        toltests = 1.0000e-04; % reduce for FBA results.
        [modelA_QUANT, modelB_QUANT] = setSemiQuantConstraints(model_A, model_B, cond1_upt_higher, cond2_upt_higher, cond2_secr_higher, cond1_secr_higher);
        
        FBAA = optimizeCbModel(modelA_QUANT);
        FBAB = optimizeCbModel(modelB_QUANT);
        
        % % % % test on setSemiQuantConstraints
        ovA =0.9228;
        ovB =0.7227;
        assert(FBAA.f - ovA < toltests);
        assert(abs(FBAB.f - ovB) < toltests); %
        
        
        
        %% Step *6* Apply growth constraints
        
        load('testdata_setConstraintsOnBiomassReactionA');
        [model_A_BM] = setConstraintsOnBiomassReaction(modelA_QUANT, of, dT, tolerance);
        
        
        %%
        % set constraints on CCRF-CEM model
        load('testdata_setConstraintsOnBiomassReactionB');
        
        [model_B_BM] = setConstraintsOnBiomassReaction(modelB_QUANT, of, dT, tolerance);
        
        
        FBAA = optimizeCbModel(model_A_BM);
        FBAB = optimizeCbModel(model_B_BM);
        
        % % % % test on setSemiQuantConstraints
        ovA =0.0424;
        ovB =0.0378;
        assert(FBAA.f - ovA < toltests);
        assert(FBAB.f - ovB < toltests); %
        
        %% Step *7* integrateGeneExpressionData
        
        dataGenes = [535
            1548
            2591
            3037
            4248
            4709
            6522
            7167
            7367
            8399
            23545
            129807
            221823
            ];
        
        [model_A_GE] = integrateGeneExpressionData(model_A_BM, dataGenes);
        
        
        dataGenes = [239
            443
            535
            1548
            2683
            3037
            4248
            4709
            5232
            6522
            7364
            7367
            8399
            23545
            54363
            66002
            129807
            221823
            ];
        
        [model_B_GE] = integrateGeneExpressionData(model_B_BM, dataGenes);
        
        % % % test on integrateGeneExpressionData
        FBAA = optimizeCbModel(model_A_GE);
        FBAB = optimizeCbModel(model_B_GE);
        
        % % % % test on setSemiQuantConstraints
        ovA =0.0424;
        ovB =0.0378;
        assert(FBAA.f - ovA < toltests);
        assert(FBAB.f - ovB < toltests); %
        
        %% Step *8* extractConditionSpecificModel
        
        theshold = 1e-6;
        [model_Molt] = extractConditionSpecificModel(model_A_GE, theshold);
        
        %%
        [model_CEM] = extractConditionSpecificModel(model_B_GE, theshold);
        
        % % % test on extractConditionSpecificModel
        FBAA = optimizeCbModel(model_Molt);
        FBAB = optimizeCbModel(model_CEM);
        
        % % % % test on extractConditionSpecificModel
        ovA =0.0424;
        ovB =0.0378;
        assert(FBAA.f - ovA < toltests);
        assert(FBAB.f - ovB < toltests); %
        
        load('output_extractConditionSpecificModel');
        assert(abs(length(o_model_Molt.rxns) - length(model_Molt.rxns))< toltests);
        assert(abs(length(o_model_CEM.rxns) - length(model_CEM.rxns))< toltests);
        assert(abs(length(o_model_Molt.genes) - length(model_Molt.genes))< toltests);
        assert(abs(length(o_model_CEM.genes )- length(model_CEM.genes))< toltests);
        
        
        %%
        [MetConn, RxnLength] = networkTopology(modelMedium);
        [MetConnA, RxnLengthA] = networkTopology(model_Molt);
        [MetConnB, RxnLengthB] = networkTopology(model_CEM);
        MetConnCompare = sort(MetConn, 'descend');
        MetConnCompareA = sort(MetConnA, 'descend');
        MetConnCompareB = sort(MetConnB, 'descend');
        
        % % % % test on extractConditionSpecificModel
        
        load('output_networkTopology.mat');
        assert(RxnLength(19,1) - o_RxnLength(19,1) < toltests);
        assert(RxnLengthA(19,1) - o_RxnLengthA(19,1) < toltests); %
        assert(RxnLengthB(19,1) - o_RxnLengthB(19,1) < toltests); %
        
        assert(MetConn(19,1) - o_MetConn(19,1) < toltests);
        assert(MetConnA(19,1) - o_MetConnA(19,1) < toltests); %
        assert(MetConnB(19,1) - o_MetConnB(19,1) < toltests); %
        
        assert(MetConnCompare(19,1) - o_MetConnCompare(19,1) < toltests);
        assert(MetConnCompareA(19,1) - o_MetConnCompareA(19,1) < toltests); %
        assert(MetConnCompareB(19,1) - o_MetConnCompareB(19,1) < toltests); %
        
        
        
        %% Do we test that ??????
        % Plot metabolite connectivity
        figure
        semilogy(sort(MetConnCompare, 'descend'), 'ro')
        hold
        semilogy(sort(MetConnCompareA, 'descend'), 'bo')
        semilogy(sort(MetConnCompareB, 'descend'), 'go')
        title('Metabolite connectivity')
        
        
        
        
        %% Step *9* perform sampling analysis
        load('testdata_performSampling.mat');
        fileName = 'modelA';
        performSampling(model_Molt, warmupn, fileName, nFiles, pointsPerFile, stepsPerPoint, fileBaseNo, maxTime, outputPath);
        
        
        fileName = 'modelB';
        performSampling(model_CEM, warmupn, fileName, nFiles, pointsPerFile, stepsPerPoint, fileBaseNo, maxTime, outputPath);
        
        % summarize sampling results
        starting_Model = modelMedium;
        modelA = model_Molt;
        modelB = model_CEM;
        
        [stats, statsR] = summarizeSamplingResults(modelA, modelB, outputPath, nFiles, pointsPerFile, starting_Model, dataGenes, show_rxns, fonts, hist_per_page, bin, 'modelA', 'modelB');
        
         clearvars -EXCEPT model_Molt model_CEM modelMedium stats statsR solverPkgs CBTDIR currentDir outputPath toltests fileDir solver

              
        % % % % test on extractConditionSpecificModel
        toltests =  1e-4;
        load('output_Sampling');
        assert(stats(1,1) - o_stats(1,1) < toltests);
        
        delete('sampling_page1.pdf');
        delete('modelA_1.mat');
        delete('modelB_1.mat');
        delete('ACHRerror.txt');
        delete('ACHR_last_point.mat');
        delete('A.mat');
        delete('clone1.log');
    end
    close all
    % output a success message
    fprintf('Done.\n');
end





