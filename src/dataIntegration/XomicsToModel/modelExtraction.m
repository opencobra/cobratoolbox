% Extract a tissue specific model, if no core reactions provided this step will be skipped
if ~isempty(coreMetAbbr) || ~isempty(coreRxnAbbr) || isfield(specificData, 'presentMetabolites') || isfield(specificData, 'absentMetabolites') || isfield(model, 'expressionRxns')
    
    if param.printLevel > 0
        disp('--------------------------------------------------------------')
        disp(' ')
        disp('Extracting tissue specific model ...')
        disp(' ')
    end
    
    % Set the parameters for createTissueSpecificModel
    tissueModelOptions.solver = param.modelExtractionAlgorithm;
    
    switch param.modelExtractionAlgorithm
        case {'fastcore','fastCore'}
            tissueModelOptions.epsilon = param.fluxEpsilon;
            tissueModelOptions.core = find(ismember(model.rxns, coreRxnAbbr));
         
            %this section of text can be used to debug the performance of fastCore, which is sensitive to the value of epsilon.
            if 0
                [nMet, nRxn] = size(model.S);
                fprintf('%u%s%u%s\n', nMet, ' x ', nRxn, ' stoichiometric matrix before fastCore.')
                
                coreRxnInd = find(ismember(model.rxns, coreRxnAbbr));
                epsilon = 1e-5;
                printLevel =2;
                [tissueModel,coreRxnBool,coreMetBool,coreCtrsBool] = fastcore(model, coreRxnInd, epsilon, printLevel);
                
                [nMet, nRxn] = size(tissueModel.S);
                fprintf('%u%s%u%s\n', nMet, ' x ', nRxn, ' stoichiometric matrix after fastCore.')
               
                if 0
                    paramConsistency.printLevel = 1;
                    paramConsistency.epsilon = epsilon;
                    paramConsistency.method = 'null_fastcc';
                    [fluxConsistentMetBool, fluxConsistentRxnBool, ~, ~, ~, fluxConsistModel]...
                        = findFluxConsistentSubset(tissueModel, paramConsistency);
                    fprintf('%u%s%u%s\n', nnz(fluxConsistentMetBool), ' x ', nnz(fluxConsistentRxnBool), ' stoichiometric matrix after flux consistency with null_fastcc.')
                    printConstraints(tissueModel,-inf,inf,~fluxConsistentRxnBool)
                else
                    paramConsistency.epsilon = epsilon;
                    paramConsistency.method = 'fastcc';
                    [fluxConsistentMetBool, fluxConsistentRxnBool, ~, ~, ~, fluxConsistModel]...
                        = findFluxConsistentSubset(tissueModel, paramConsistency);
                    fprintf('%u%s%u%s\n', nnz(fluxConsistentMetBool), ' x ', nnz(fluxConsistentRxnBool), ' stoichiometric matrix after flux consistency with fastcc.')
                    printConstraints(tissueModel,-inf,inf,~fluxConsistentRxnBool)
                end
                if 0
                    paramConsistency.epsilon = epsilon;
                    paramConsistency.method = 'swiftcc';
                    [fluxConsistentMetBool, fluxConsistentRxnBool, ~, ~, ~, fluxConsistModel]...
                        = findFluxConsistentSubset(tissueModel, paramConsistency);
                    fprintf('%u%s%u%s\n', nnz(fluxConsistentMetBool), ' x ', nnz(fluxConsistentRxnBool), ' stoichiometric matrix after flux consistency with swiftcc.')
                end
                return
            end
            
        case 'thermoKernel'
            if ~isfield(model,'dummyMetBool')
                % to avoid "Reference to non-existent field 'dummyMetBool"
                model.dummyMetBool = false(size(model.S, 1), 1);
                model.dummyRxnBool = false(size(model.S, 2), 1);
            end
            
            %default weights of NaN
            % metWeights = NaN * ones(length(model.mets), 1);
            % rxnWeights = NaN * ones(length(model.rxns), 1);

            metWeights = zeros(length(model.mets), 1);
            rxnWeights = zeros(length(model.rxns), 1);
                        
            if param.weightsFromOmics && isfield(model, 'expressionRxns')
                % If present set the fixed weight relative to median of the log of the gene expression value
                fprintf('%s\n', 'Using real valued weights on metabolites and reactions as input to thermoKernel.')
                if isequal(param.activeGenesApproach, 'oneRxnPerActiveGene')
                    % Variable weight on any dummy reaction in the core set from omics
                    % data but weights in range [-1,0)
                    dummyRxn = model.rxns(model.dummyRxnBool);
                    dummyGene = strrep(dummyRxn, 'dummy_Rxn_', '');
                    [bool, locb] = ismember(dummyGene, model.genes);
                    activeModelGeneBool = model.geneExpVal >= exp(param.transcriptomicThreshold);
       
                    if median(log(model.geneExpVal(activeModelGeneBool))) <= 0 % The distribution of genes expression value in log scale is not normal
                        defaultRxnWeight = median(log(model.geneExpVal(activeModelGeneBool))) - param.transcriptomicThreshold;%To avoid negative weights on core reactions
                    else
                        defaultRxnWeight = median(log(model.geneExpVal(activeModelGeneBool)));
                    end
                    
                    if param.printLevel > 1
                        figure
                        histogram(log(model.geneExpVal(activeModelGeneBool)))
                        title('log(model.geneExpVal)')
                        ylabel('Number of active genes')
                    end
                else
                    defaultRxnWeight = median(log(model.expressionRxns(isfinite(model.expressionRxns) & model.expressionRxns > 0)));
                    if param.printLevel > 1
                        figure
                        histogram(log(model.expressionRxns(isfinite(model.expressionRxns))))
                        title('log(model.expressionRxns)')
                        ylabel('Number of reactions')
                    end
                end
                defaultMetWeight = defaultRxnWeight;
            else
                fprintf('%s\n', 'Using unitary weights on metabolites and reactions as input to thermoKernel.')
                defaultRxnWeicoreRxnBool = ismember(model.rxns, coreRxnAbbr);ght = 1.1;
                defaultMetWeight = 1.1;
                defaultRxnWeight = 1.1;
            end
            
            % Correspondence between weights on core metabolites and reactions
            if 1
                %identify the metabolites that are exclusively involved in core reactions, ignoring dummy metabolites
                coreMetAbbr2 = model.mets(getCorrespondingRows(model.S, ~model.dummyMetBool, ismember(model.rxns, coreRxnAbbr), 'exclusive'));
                coreMetAbbr = unique([coreMetAbbr; coreMetAbbr2]);
            end
            if 0
                %identify the reactions that are exclusively involved in core metabolites, ignoring dummy reactions
                coreRxnAbbr2 = model.rxns(getCorrespondingCols(model.S, ismember(model.mets, coreMetAbbr), ~model.dummyRxnBool, 'exclusive'));
                coreRxnAbbr = unique([coreRxnAbbr; coreRxnAbbr2]);
            end
            coreMetBool = ismember(model.mets, coreMetAbbr);
            coreRxnBool = ismember(model.rxns, coreRxnAbbr);
            
            % add weights from omics data first
            if isequal(param.activeGenesApproach, 'oneRxnPerActiveGene')
                % dummyModel.dummyMetBool:  m x 1 boolean vector indicating dummy metabolites i.e. contains(model.mets,'dummy_Met_');
                % dummyModel.dummyRxnBool:  n x 1 boolean vector indicating dummy reactions  i.e. contains(model.rxns,'dummy_Rxn_');
                if param.weightsFromOmics
                    fprintf('%s\n', 'Using real valued weights from omics on dummy reactions as input to thermoKernel.')
                    %variable weight on any dummy reaction in the core set from omics
                    %data but weights in range [-1,0)
                    dummyRxn = model.rxns(model.dummyRxnBool);
                    dummyGene = strrep(dummyRxn, 'dummy_Rxn_', '');
                    
                    [bool, locb] = ismember(dummyGene, model.genes);
                    
                    %negative means incentivise
                    geneExpVal = log(model.geneExpVal);
                    geneExpVal(~activeModelGeneBool) = 0;
                    
                    %reaction weights on dummy reaction in logarithmic scale
                    dummyRxnWeights = -geneExpVal(locb(bool)) - defaultRxnWeight;
                    
                    rxnWeights(model.dummyRxnBool) = dummyRxnWeights;
                    
                    %some dummy reactions may have positive weights
                    bool = model.dummyRxnBool & rxnWeights > 0;
                    if any(bool)
                        if param.printLevel > 0
                            fprintf('%s\n', [num2str(mean(rxnWeights(bool))) ...
                                ' = mean positive weight on ' int2str(nnz(bool)) ' of ' ...
                                int2str(nnz(model.dummyRxnBool)) ' dummy reactions.']);
                        end
                        rxnWeights(bool) = -defaultRxnWeight;
                    end
                    
                    if 0
                        % Check that the indexing is correct
                        ind = find(model.dummyRxnBool);
                        aGeneName = strrep(model.rxns{ind(end)}, 'dummy_Rxn_', '');
                        % TODO - fix this check
                        assert(rxnWeights(end) * max(model.geneExpVal(locb(bool)))...
                            == -model.geneExpVal(strcmp(model.genes, aGeneName)))
                    end
                    
                    %identify the reactions corresponding to dummy reactions
                    A = abs(model.S(model.dummyMetBool, :));
                    rxnCorrespondingToDummyRxn = (A' * ones(size(A, 1), 1))~=0 & ~model.dummyRxnBool;
                    
                    %zero weights for reactions corresponding to dummy reactions
                    rxnWeights(rxnCorrespondingToDummyRxn)=0;
                    
%                     if 1
%                         %no disincentive on non-core reactions corresponding to dummy reactions
%                         rxnWeights(~coreRxnBool & rxnCorrespondingToDummyRxn & ~model.dummyRxnBool) = 0;
%                     else
%                         % small disincentive for on non-core  reactions corresponding to core dummy reactions
%                         rxnWeights(~coreRxnBool & rxnCorrespondingToDummyRxn & ...
%                             ~model.dummyRxnBool) =  (defaultRxnWeight / 100);
%                     end
                    
                    if 0
                        % increase the incentive for core dummy reactions in proportion to the number of reactions involved
                        nDummyRxnsPerActiveGene = (A * ones(size(A, 2), 1));
                        nDummyRxnsPerActiveGene = min(nDummyRxnsPerActiveGene, 10);
                        
                        rxnWeights(model.dummyRxnBool) = rxnWeights(model.dummyRxnBool) .* nDummyRxnsPerActiveGene;
                    end
                    
                    %replace any NaN due to missing gene expression data with zero weight
                    bool= isnan(rxnWeights) & model.dummyRxnBool;
                    if any(bool)
                        fprintf('%u%s\n',nnz(bool),' NaN rxnWeights replaced with with zero weight, due to missing gene expression data.')
                        rxnWeights(bool) = 0;
                    end
                    
                else
                    fprintf('%s\n','Using default weights on all dummy reactions as input to thermoKernel.')
                    rxnWeights(model.dummyRxnBool) = -defaultRxnWeight;
                end
            else
                rxnCorrespondingToDummyRxn = false(nRxn,1);
                
                if param.weightsFromOmics
                    fprintf('%s\n','Using real valued weights from omics on dummy reactions as input to thermoKernel.')
                    rxnWeights =  -log(model.expressionRxns + 1) - defaultRxnWeight; % +1 necessary to avoid double negative
                    
                    %replace any NaN due to missing gene expression data with zero weight
                    rxnWeights(isnan(rxnWeights)) = 0;
                end
            end
            
            % Add weights from bibliomics after other omics data
            LIA = false(length(model.mets), 1);
            LIA2 = false(length(model.mets), 1);
            if isfield(specificData, 'presentMetabolites')
                if ismember('weights', specificData.presentMetabolites.Properties.VariableNames)
                    if any(specificData.presentMetabolites.weights > 0)
                        error('specificData.presentMetabolites.weights must be non-positive')
                    end
                    % [LIA, LOCB] = ismember(A,B) for arrays A and B returns
                    % LIA = an array of the same size as A containing true where the elements of A are in B and false otherwise.
                    % LOCB containing the lowest absolute index in B for each element in A which is a member of B and 0 if there is no such index.
                    [LIA, LOCB] = ismember(model.mets,specificData.presentMetabolites.mets);
                    LOCB(LOCB == 0) = [];
                    metWeights(LIA) = specificData.presentMetabolites.weights(LOCB);
                end
            end
            
            if isfield(specificData, 'absentMetabolites')
                if ismember('weights', specificData.absentMetabolites.Properties.VariableNames)
                    if any(specificData.absentMetabolites.weights < 0)
                        error('specificData.absentMetabolites must be non-positive')
                    end
                    
                    [LIA2, LOCB2] = ismember(model.mets,specificData.absentMetabolites.mets);
                    LOCB2(LOCB2 == 0) = [];
                    metWeights(LIA2) = specificData.absentMetabolites.weights(LOCB2);
                end
            end
            
            if any(coreMetBool)
                % Add weights from bibliomics after other omics data
                % Core metabolites incentivised with default weight
                metWeights(coreMetBool) = -defaultMetWeight;
            end
            
            if any(coreRxnBool)
                % Add weights from bibliomics after other omics data
                % Core reactions incentivised with default weight
                rxnWeights(coreRxnBool) = -defaultRxnWeight;
            end
            
            % disincentives on metabolites
            if 1
                % Disincentive to include a metabolite not in the core set or dummy metabolite set
                % Disincentive should not be greater than incentive, so multiply by 0.95
                metWeights(~(coreMetBool | LIA | LIA2)) = defaultMetWeight * 0.95;
                % No disincentive to include any highly connected metabolite
                param.n = 100; % Connectivity of top 100 metabolites
                param.plot = 0; % Do not plot ranked connectivity
                param.internal = 1; % Ignore connectivity of stoichiometrically inconsistent part
                [rankMetConnectivity,rankMetInd,rankConnectivity] = rankMetabolicConnectivity(model, param);
                boolConnected = false(length(metWeights),1);
                boolConnected(rankMetInd(1:param.n))=1;
                metWeights(boolConnected & ~(coreMetBool | model.dummyMetBool)) = 0;
            else
                %no disincentive to include a metabolite not in the core set
                metWeights(~(coreMetBool | LIA | LIA2)) = 0;
            end
            
            %no incentive or disincentive for dummy metabolites corresponding to dummy reactions
            metWeights(model.dummyMetBool) = 0;
            
            
            % disincentives on reactions
            if 1
                %disincentive to include any reaction not in the core set or dummy reaction set
                %disincentive should not be greater than incentive, so multiply by 0.95
                if isequal(param.activeGenesApproach, 'oneRxnPerActiveGene') && param.weightsFromOmics
                    rxnWeights(~(coreRxnBool | model.dummyRxnBool | rxnCorrespondingToDummyRxn)) = defaultRxnWeight * 0.95;
                else
                    rxnWeights(~(coreRxnBool | model.dummyRxnBool)) = defaultRxnWeight * 0.95;
                end
            else
                if isequal(param.activeGenesApproach, 'oneRxnPerActiveGene') && param.weightsFromOmics
                    %no disincentive to include any reaction not in the core set
                    rxnWeights(~(coreRxnBool | model.dummyRxnBool | rxnCorrespondingToDummyRxn)) = 0;
                else
                    rxnWeights(~(coreRxnBool | model.dummyRxnBool)) = 0;
                end
            end
            
            %making sure that all core metabolites and reactions have negative weights
            if any(ismember(model.mets, coreMetAbbr) & metWeights >= 0)
                disp(model.mets(ismember(model.mets, coreMetAbbr) & metWeights >= 0))
                error('metWeights should be negative for all core metabolites')
            end
            
            if any(ismember(model.rxns, coreRxnAbbr) & rxnWeights >= 0)
                disp(model.rxns(ismember(model.rxns, coreRxnAbbr) & rxnWeights >= 0))
                error('rxnWeights should be negative for all core reactions')
            end
            
            %making sure that all weights have been set to some value
            if any(isnan(metWeights))
                error('tissueModelOptions.metWeights cannot contain NaN')
            else
                tissueModelOptions.metWeights = metWeights;
            end
            if any(isnan(rxnWeights))
                error('tissueModelOptions.rxnWeights cannot contain NaN')
            else
                tissueModelOptions.rxnWeights = rxnWeights;
            end
            
            %general options
            tissueModelOptions.printLevel = param.printLevel - 1;
            tissueModelOptions.formulation = 'pqzwrs';
            tissueModelOptions.nMax = 40; %can be ~40
            tissueModelOptions.relaxBounds = 1;
            tissueModelOptions.acceptRepairedFlux = 1;
            if ~isfield(tissueModelOptions,'iterationMethod')
                %tissueModelOptions.iterationMethod = 'greedyRandomSubset';
                %tissueModelOptions.iterationMethod = 'random';
                %tissueModelOptions.iterationMethod = 'vanilla';
                tissueModelOptions.iterationMethod = 'greedyAdd'; %seems to give the most reproducible results
            end
            tissueModelOptions.plotThermoKernelStats = param.plotThermoKernelStats;
            tissueModelOptions.plotThermoKernelWeights = param.plotThermoKernelWeights;
            
            tissueModelOptions.normalizeZeroNormWeights = 0;
            tissueModelOptions.epsilon = param.thermoFluxEpsilon;
            tissueModelOptions.findThermoConsistentFluxSubset = 0; %already done above
            
            if param.printLevel >0
                tissueModelOptions.plotThermoKernelStats=1;
                %saveas(gcf,'thermoKernelStats.fig')
                tissueModelOptions.plotThermoKernelWeights=1;
                %saveas(gcf,'thermoKernelWeights.fig')
            end
            
            %DEBUG
            %tissueModelOptions.rxnWeights(:)=0;
            %tissueModelOptions.metWeights(tissueModelOptions.metWeights>0)=0;
            
%             if param.printLevel >0
%                 plotThermoKernelWeights(tissueModelOptions.metWeights, tissueModelOptions.rxnWeights)
%                 saveas(gcf,'thermoKernelWeights.fig')
%             end
    end
    
    if 0
        tissueModelOptions.metWeights(~model.dummyMetBool) = 0;
        tissueModelOptions.metWeights(model.dummyMetBool) = 0;
        tissueModelOptions.rxnWeights(~model.dummyRxnBool) = 0;
        tissueModelOptions.rxnWeights(model.dummyRxnBool) = -1;
        coreMetAbbr = intersect(model.mets(model.dummyMetBool),coreMetAbbr);
        coreRxnAbbr = intersect(model.rxns(model.dummyRxnBool),coreRxnAbbr);
    end
    % Run createTissueSpecificModel
    % Note, if tissueModelOptions.oneRxnPerActiveGene==1, the input model will contain
    % dummy reactions and metabolites
    
    modelTemp = createTissueSpecificModel(model, tissueModelOptions);

    %procced with tissue specific model
    if isequal(param.activeGenesApproach, 'oneRxnPerActiveGene')      
        %remove the dummy reactions from the core reaction list, so that it
        %does not show below that real core reactions are removed
        if ~isempty(coreMetAbbr)
            coreMetAbbr = coreMetAbbr(~contains(coreMetAbbr,'dummy_Met_'));
        end
        if ~isempty(coreRxnAbbr)
            coreRxnAbbr = coreRxnAbbr(~contains(coreRxnAbbr,'dummy_Rxn_'));
        end
    end
    
    if isfield(modelTemp,'thermoModelMetBool')
        modelTemp = rmfield(modelTemp,'thermoModelMetBool');
    end
    if isfield(modelTemp,'thermoModelRxnBool')
        modelTemp = rmfield(modelTemp,'thermoModelRxnBool');
    end
    
    param.message = 'removal by createTissueSpecificModel';
    [coreMetAbbr3, coreRxnAbbr3] = coreMetRxnAnalysis(model, modelTemp, coreMetAbbr, coreRxnAbbr, [], [], param);
    
    model = modelTemp;
    
    % Check feasibility and relax if necessary
    sol = optimizeCbModel(model);
    if  sol.stat ~= 1
        relaxationUsed = 1;
        fprintf('%s\n', 'Infeasible tissue specific model. Trying relaxation...')
        [solution, modelTemp] = relaxedFBA(model, param.relaxOptions);
        if solution.stat == 1
            fprintf('%s\n', '... relaxation worked.')
            model = modelTemp;
        else
            error('Infeasible tissue specific model and relaxation failed.')
        end
    else
        if param.printLevel > 0
            fprintf('%s\n\n','Feasible tissue specific model. Done.')
            disp('--------------------------------------------------------------')
        end
    end
    if param.debug && 0
        if ~exist(param.workingDirectory,'dir')
            fprintf('%s%s',param.workingDirectory,  ' did not exist so had to be created.')
            mkdir(param.workingDirectory)
        end
        save([param.workingDirectory filesep '20.debug_after_create_tissue_specific_model.mat'])
    end
else
    if param.printLevel > 0
        disp('--------------------------------------------------------------')
        disp('No core reactions specified, tissueSpecificModel not generated ...')
    end
end

if param.printLevel > 0
    [nMet, nRxn] = size(model.S);
    fprintf('%u%s%u%s\n', nMet, ' x ', nRxn, ' stoichiometric matrix after model extraction.')
end
