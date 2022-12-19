function [model, specificData, coreRxnAbbr, modifiedFluxes, modelGenerationReport] = metabolomicsTomodel(model, specificData, param, coreRxnAbbr, modelGenerationReport)
% Integrates metabolomics data to COBRA models obtained in the cell culture 
% media either by metabolomics experiments or by the content of the culture 
% medium
%
% USAGE:
%
%    [model, specificData, coreRxnAbbr, modifiedFluxes, modelGenerationReport] = metabolomicsToModel(model, specificData, param, coreRxnAbbr, modelGenerationReport)
%
% INPUT:
%    model:     	A generic COBRA model
%
%        * .S - Stoichiometric matrix
%        * .mets - Metabolite ID vector
%        * .rxns - Reaction ID vector
%        * .lb - Lower bound vector
%        * .ub - Upper bound vector
%        * .genes - Upper bound vector
%
%    specificData:  A structure containing the context-specific data
%    param:     a structure containing the parameters for the function
%    coreRxnAbbr:   Set of core reactions
%    modelGenerationReport:	A struct array where the data will be saved
%
% OUTPUTS:
%    model:  A Context-specific COBRA model with the metabolomic data.
%    specificData:  The exometabolomic data is updated according to the
%                   relaxations
%    coreRxnAbbr:  A Context-specific COBRA model with the metabolomic data.
%    modifiedFluxes:  New set of core reactions.
%    modelGenerationReport: an updated version od the struct array

feasTol = getCobraSolverParams('LP', 'feasTol');

%% 10/22.b. Metabolomics data integration
if isfield(specificData, 'exoMet') && ~isempty(specificData.exoMet)
    
    if param.printLevel > 0
        disp('--------------------------------------------------------------')
        disp(' ')
        disp('Adding quantitative metabolomics constraints ...')
        disp(' ')
    end
    
    % Remove repeated reactions
    if isfield(specificData, 'rxns2constrain')
        rxnsRepeated = intersect(specificData.exoMet.rxns, specificData.rxns2constrain.rxns);
        if ~isempty(rxnsRepeated) && param.curationOverOmics
            specificData.exoMet(ismember(specificData.exoMet.rxns, rxnsRepeated), :) = [];
            if param.printLevel > 0
                disp('Since some rxns were repeated in specificData.rxns2constrain,')
                disp([num2str(numel(rxnsRepeated)) ' reactions were removed from specificData.exoMet:'])
            end
        elseif ~isempty(rxnsRepeated) && ~param.curationOverOmics
            %specificData.rxns2constrain(~ismember(specificData.rxns2constrain.rxns,rxnsRepeated), :) = []; %THIS LINE IS WRONG AS IT SHOULD NOT HAVE THE TILDA
            specificData.rxns2constrain(ismember(specificData.rxns2constrain.rxns, rxnsRepeated), :) = [];
            if param.printLevel > 0
                disp('Since some rxns were repeated in specificData.exoMet,')
                disp([num2str(numel(rxnsRepeated)) ' reactions were removed from specificData.rxns2constrain:'])
            end
        end
        if param.printLevel > 1 && ~isempty(rxnsRepeated)
            display(rxnsRepeated)
        end
    end
        
    if param.printLevel > 2
        disp(' ')
        disp('Exchange bounds prior to fitting to experimental data')
        printConstraints(model,-inf,inf,~model.SIntRxnBool)
    end
    
    if ~isfield(model, 'constraintDescription')
        model.constraintDescription(1:length(model.rxns), 1) = {''};
    end
    
    if ~ismember('rxns', specificData.exoMet.Properties.VariableNames)
        allExRxns = model.rxns(findExcRxns(model));
        for i=1:length(specificData.exoMet.mets)
            if any(contains(allExRxns, strcat('_', specificData.exoMet.mets(i))))
                specificData.exoMet.rxns(i) = allExRxns(contains(allExRxns, strcat('_', specificData.exoMet.mets(i))));
            end
        end
    end
    
    if isfield(param, 'addSinksexoMet') && param.addSinksexoMet
        if ~isfield(modelGenerationReport, 'sinksAddedFromexoMet')
            modelGenerationReport.sinksAddedFromexoMet = [];
        end
        disp('Following sinks are added:')
        for  i=1:length(specificData.exoMet.mets)
            if isempty(specificData.exoMet.rxns{i})
                model = addSinkReactions(model, specificData.exoMet.mets(i));
                specificData.exoMet.rxns(i) = strcat('sink_', specificData.exoMet.mets(i));
                modelGenerationReport.sinksAddedFromexoMet = [modelGenerationReport.sinksAddedFromexoMet; specificData.exoMet.rxns(i)];
            end
        end
    end
    
    % save the old bounds
    model.lb_preconstrainRxns = model.lb;
    model.ub_preconstrainRxns = model.ub;
        
    %fit the exchange reaction rates to the metabolomic data
    [model, ~, ~, specificData] = constrainRxns(model, specificData, param, 'exometabolomicConstraints',param.printLevel-1);
    
    if any(model.lb > model.ub)
        error('lower bounds greater than upper bounds')
    end
    
    [bool,locb] = ismember(specificData.exoMet.rxns, model.rxns);
    if ~all(model.lb(locb(bool))==model.ub(locb(bool))) && 0
        error('inconsistent fitting of reaction bounds')
    end
    
    sol = optimizeCbModel(model);
    if  sol.stat ~=1
        disp(' ')
        fprintf('%s\n','Infeasible after application of metabolomic constraints')
    elseif sol.stat ==1
        if param.printLevel > 0
            disp(' ')
            fprintf('%s\n\n','Feasible after application of metabolomic constraints')
        end
    end
    
    if param.metabolomicsBeforeExtraction && param.debug
        save([param.workingDirectory filesep '10.c.debug_prior_to_test_exchange_mismatch.mat'])
    elseif param.debug
        save([param.workingDirectory filesep '22.c.debug_prior_to_test_exchange_mismatch.mat'])
    end
    
    %% 10/22.c. Exchange mismatch
    
    if param.printLevel > 0
        disp('--------------------------------------------------------------')
        disp(' ')
        disp('Checking for mismatches ...')
        disp(' ')
    end
    
    signMatch = specificData.exoMet.signMatch;
    isnanSignMatch = isnan(specificData.exoMet.signMatch);
    signMatch(isnanSignMatch)=1;
    signMatch = logical(signMatch);
    
    % Test for ability to uptake metabolites that should but are not exchanged
    if isfield(specificData,'exoMet') && any(~signMatch)
        if param.printLevel > 0
            [~,nRxn]=size(model.S);
            fprintf('%20s%40s%16s%16s%16s%16s%16s\n','rxn', 'rxnNames','vExp','sdExp','vFit','vMin','vMax')
            for i=1:size(specificData.exoMet,1)
                if signMatch(i)==0
                    modelTmp=model;
                    modelTmp.c=zeros(nRxn,1);
                    indRxn = find(ismember(model.rxns,specificData.exoMet.rxns{i}));
                    modelTmp.c(indRxn)=1;
                    if modelTmp.lb(indRxn)==0 || modelTmp.ub(indRxn)==0
                        modelTmp.lb(indRxn)=-10000;
                        modelTmp.ub(indRxn)=10000;
                    end
                    solMax = optimizeCbModel(modelTmp,'max');
                    solMin = optimizeCbModel(modelTmp,'min');
                    specificData.exoMet.vMin(i)=solMin.v(indRxn);
                    specificData.exoMet.vMax(i)=solMax.v(indRxn);
                    fprintf('%20s%40s%16g%16g%16g%16g%16g\n',model.rxns{indRxn},model.rxnNames{indRxn},specificData.exoMet.mean(i),specificData.exoMet.SD(i),specificData.exoMet.v(i),solMin.v(indRxn),solMax.v(indRxn));
                end
            end
            
            nMisMatch = nnz(~signMatch) + nnz(isnanSignMatch);
            if param.printLevel > 0
                fprintf('\n%s\n',['Analysis of the reasons for ' int2str(nMisMatch) ' mismatches between sign of experimental and fit metabolite exchange:'])
            end
            
            reason = ' experimental metabolite not part of model:';
            nanBool = isnanSignMatch;
            if param.printLevel > 0
                fprintf('%s\n',['... of whom ' int2str(nnz(nanBool)) reason])
                disp([specificData.exoMet.rxns(nanBool),specificData.exoMet.rxnNames(nanBool)])
            end
            
            reason = ' fit perfectly but experimental mean +/- SD includes zero:';
            expZeroFitBool = ~signMatch & abs(specificData.exoMet.dv)<=feasTol...
                & (specificData.exoMet.mean- specificData.exoMet.SD)<0 & (specificData.exoMet.mean+ specificData.exoMet.SD)>0;
            if param.printLevel > 0
                fprintf('%s\n',['... of whom ' int2str(nnz(expZeroFitBool)) reason])
                disp([specificData.exoMet.rxns(expZeroFitBool),specificData.exoMet.rxnNames(expZeroFitBool)])
            end
            
            reason = ' fit sign but not magnitude and experimental mean +/- SD includes zero:';
            expZeroAlmostFitBool = ~signMatch & sign(specificData.exoMet.mean)==sign(specificData.exoMet.v) & abs(specificData.exoMet.dv)>feasTol...
                & (specificData.exoMet.mean- specificData.exoMet.SD)<0 & (specificData.exoMet.mean+ specificData.exoMet.SD)>0;
            if param.printLevel > 0
                fprintf('%s\n',['... of whom ' int2str(nnz(expZeroAlmostFitBool)) reason])
                disp([specificData.exoMet.rxns(expZeroAlmostFitBool),specificData.exoMet.rxnNames(expZeroAlmostFitBool)])
            end
            
            reason = ' mean measured to be taken up but cannot be taken up:';
            cannotBeTakenUpBool = ~signMatch & specificData.exoMet.mean<0 & specificData.exoMet.vMin >= -feasTol;
            if param.printLevel > 0
                fprintf('%s\n',['... of whom ' int2str(nnz(cannotBeTakenUpBool)) reason])
                disp([specificData.exoMet.rxns(cannotBeTakenUpBool),specificData.exoMet.rxnNames(cannotBeTakenUpBool)])
            end
            
            reason = ' mean measured to be taken up but can only be secreted:';
            takenUpButSecretedBool = ~signMatch & specificData.exoMet.mean<0 & specificData.exoMet.v>=feasTol & specificData.exoMet.vMin >= feasTol;
            if param.printLevel > 0
                fprintf('%s\n',['... of whom ' int2str(nnz(takenUpButSecretedBool)) reason])
                disp([specificData.exoMet.rxns(takenUpButSecretedBool),specificData.exoMet.rxnNames(takenUpButSecretedBool)])
            end
            
            reason = ' mean measured to be taken up but secreted, even if it can be uptaken:';
            takenUpButSecretedBool = ~signMatch & specificData.exoMet.mean<0 & specificData.exoMet.v>=feasTol & specificData.exoMet.vMin <-feasTol & specificData.exoMet.vMax >= feasTol;
            if param.printLevel > 0
                fprintf('%s\n',['... of whom ' int2str(nnz(takenUpButSecretedBool)) reason])
                disp([specificData.exoMet.rxns(takenUpButSecretedBool),specificData.exoMet.rxnNames(takenUpButSecretedBool)])
            end
            
            reason = ' mean measured to be secreted but cannot be secreted:';
            cannotBeSecretedBool = ~signMatch & specificData.exoMet.mean>0 & specificData.exoMet.vMin > -feasTol & specificData.exoMet.vMax < feasTol;
            if param.printLevel > 0
                fprintf('%s\n',['... of whom ' int2str(nnz(cannotBeSecretedBool)) reason])
                disp([specificData.exoMet.rxns(cannotBeSecretedBool),specificData.exoMet.rxnNames(cannotBeSecretedBool)])
            end
            
            reason = ' mean measured to be secreted but must be uptaken:';
            secretedButMustBeTakenUpBool = ~signMatch & specificData.exoMet.mean>0 & specificData.exoMet.v<-feasTol & specificData.exoMet.vMax < -feasTol;
            if param.printLevel > 0
                fprintf('%s\n',['... of whom ' int2str(nnz(secretedButMustBeTakenUpBool)) reason])
                disp([specificData.exoMet.rxns(secretedButMustBeTakenUpBool),specificData.exoMet.rxnNames(secretedButMustBeTakenUpBool)])
            end
            
            reason = ' mean measured to be secreted but uptaken, even if it can be secreted:';
            secretedButTakenUpBool = ~signMatch & specificData.exoMet.mean>0 & specificData.exoMet.v<-feasTol & specificData.exoMet.vMin < -feasTol & specificData.exoMet.vMax > feasTol;
            if param.printLevel > 0
                fprintf('%s\n',['... of whom ' int2str(nnz(secretedButTakenUpBool)) reason])
                disp([specificData.exoMet.rxns(secretedButTakenUpBool),specificData.exoMet.rxnNames(secretedButTakenUpBool)])
            end
            
            reason = ' mean measured secretion of an essential amino acid, which can only be uptaken:';
            specificData.exoMet.essentialAA=ismember(specificData.exoMet.rxns,specificData.essentialAA.rxns);
            essentialAACcannotBeSecretedBool = ~signMatch & specificData.exoMet.essentialAA;
            if param.printLevel > 0
                fprintf('%s\n',['... of whom ' int2str(nnz(essentialAACcannotBeSecretedBool)) reason])
                disp([specificData.exoMet.rxns(essentialAACcannotBeSecretedBool),specificData.exoMet.rxnNames(essentialAACcannotBeSecretedBool)])
            end
            
            bool = ~signMatch & ~(expZeroFitBool | cannotBeTakenUpBool | cannotBeSecretedBool |...
                expZeroAlmostFitBool | takenUpButSecretedBool | secretedButTakenUpBool | secretedButMustBeTakenUpBool | essentialAACcannotBeSecretedBool);
            if any(bool) && param.printLevel > 0
                fprintf('%s\n',['... of whom ' int2str(nnz(bool)) ' unclassified'])
                disp(specificData.exoMet.rxns(bool))
            end
            if any(essentialAACcannotBeSecretedBool)
                boolRevertBounds = ismember(model.rxns,specificData.exoMet.rxns(essentialAACcannotBeSecretedBool));
                fprintf('%s\n','Reverting constrainRxns changes to bounds for the following reactions:')
                disp(model.rxns(boolRevertBounds))
                model.lb(boolRevertBounds) = model.lb_preconstrainRxns(boolRevertBounds);
                model.ub(boolRevertBounds) = model.ub_preconstrainRxns(boolRevertBounds);
                %specificData.exoMet = specificData.exoMet(~essentialAACcannotBeSecretedBool,:);
            end
        end
    end
    
    % Try to force the model to exchange experimentally measured uptake & secretion
    if 0
        % Try to force the model to exchange experimentally measured uptake & secretion
        relaxOptionsMetabolomics = options.relaxOptions;
        relaxOptionsMetabolomics.exchangeRelax = 2;
        relaxOptionsMetabolomics.internalRelax = 2;
        %relaxOptionsMetabolomics.excludedReactionLB = ~model.SConsistentRxnBool;
        
        cannotBeExchangedInd = find(cannotBeTakenUpBool | cannotBeSecretedBool);
        cannotBeTakenUpInd = find(cannotBeTakenUpBool);
        cannotBeSecretedInd = find(cannotBeSecretedBool);
        fprintf('%s\n',['Trying to force exchange by ' int2str(nnz(cannotBeExchangedInd)) ' exchange reactions'])
        modelForceExchange = model;
        modelForceExchange.lb(ismember(model.rxns,options.exoMet.rxns(cannotBeTakenUpInd))) = -10000;
        modelForceExchange.ub(ismember(model.rxns,options.exoMet.rxns(cannotBeTakenUpInd))) =  options.exoMet.mean(cannotBeTakenUpInd);
        modelForceExchange.lb(ismember(model.rxns,options.exoMet.rxns(cannotBeSecretedInd))) =  options.exoMet.mean(cannotBeSecretedInd);
        modelForceExchange.ub(ismember(model.rxns,options.exoMet.rxns(cannotBeSecretedInd))) =  10000;
        relaxOptionsMetabolomics.excludedReactions=false(size(model.S,2),1);
        relaxOptionsMetabolomics.excludedReactions(ismember(model.rxns,options.exoMet.rxns(cannotBeExchangedInd)))=1;
        [solution, modelRelaxed] = relaxedFBA(modelForceExchange, relaxOptionsMetabolomics);
        solution
        %     Forward_Reaction                       Name                        lb_before          lb_after          ub_before    ub_after                          equation
        %     ________________    ___________________________________________    _________    ____________________    _________    ________    _____________________________________________________
        %
        %     'ACGSm'             'N-Acteylglutamate Synthase, Mitochondrial'        0        -0.00220676906348284      10000       10000      'glu_L[m] + accoa[m]  -> h[m] + coa[m] + acglu[m] '
        %     'EX_utp[e]'         'Exchange of UTP '                                 0         -0.0266434991899587      10000       10000      'utp[e]  -> '
        %     'r1440'             'Transport Reaction'                               0         -0.0975115847662083      10000       10000      'thr_L[c]  -> thr_L[m] '
        %     'EX_udpglcur[e]'    'Exchange '                                        0         -0.0156081541354069      10000       10000      'udpglcur[e]  -> '
        %     'EX_elaidcrn[e]'    'Exchange of Elaidic Carnitine'                    0           -0.03374885869016      10000       10000      'elaidcrn[e]  -> '
        %     'THRACm'            'Acetylation of Threonine'                         0         -0.0975115847662083      10000       10000      'accoa[m] + thr_L[m]  -> h[m] + coa[m] + acthr_L[m] '
        %     'ACILEm'            'Acetylation of Isoleucine'                        0         -0.0857858423675497      10000       10000      'accoa[m] + ile_L[m]  -> h[m] + coa[m] + acile_L[m] '
        %     'ACLEUm'            'Acetylation of Leucine'                           0        -0.00238257243998418      10000       10000      'accoa[m] + leu_L[m]  -> h[m] + coa[m] + acleu_L[m] '
        %     'EX_M02909[e]'      'EX_M02909[e]'                                     0          -0.579911506057156      10000       10000      'M02909[e]  -> '
        
        % Try to force the model to take up experimentally measured uptake
        relaxOptionsMetabolomics = options.relaxOptions;
        relaxOptionsMetabolomics.exchangeRelax = 0;
        relaxOptionsMetabolomics.internalRelax = 2;
        cannotBeTakenUpInd = find(cannotBeTakenUpBool);
        fprintf('%s\n',['Trying to force uptake by ' int2str(nnz(cannotBeTakenUpInd)) ' exchange reactions'])
        modelForceExchange = model;
        modelForceExchange.lb(ismember(model.rxns,options.exoMet.rxns(cannotBeTakenUpInd))) = -10000;
        modelForceExchange.ub(ismember(model.rxns,options.exoMet.rxns(cannotBeTakenUpInd))) =  options.exoMet.mean(cannotBeTakenUpInd);
        relaxOptionsMetabolomics.excludedReactions=false(size(model.S,2),1);
        relaxOptionsMetabolomics.excludedReactions(ismember(model.rxns,options.exoMet.rxns(cannotBeTakenUpInd)))=1;
        [solution, modelRelaxed] = relaxedFBA(modelForceExchange, relaxOptionsMetabolomics);
        solution
        % Forward_Reaction                       Name                        lb_before          lb_after          ub_before    ub_after                          equation
        % ________________    ___________________________________________    _________    ____________________    _________    ________    _____________________________________________________
        %
        % 'ACGSm'         'N-Acteylglutamate Synthase, Mitochondrial'        0        -0.00220676906348284      10000       10000      'glu_L[m] + accoa[m]  -> h[m] + coa[m] + acglu[m] '
        % 'r1440'         'Transport Reaction'                               0         -0.0975115847662083      10000       10000      'thr_L[c]  -> thr_L[m] '
        % 'THRACm'        'Acetylation of Threonine'                         0         -0.0975115847662083      10000       10000      'accoa[m] + thr_L[m]  -> h[m] + coa[m] + acthr_L[m] '
        % 'ACILEm'        'Acetylation of Isoleucine'                        0         -0.0857858423675497      10000       10000      'accoa[m] + ile_L[m]  -> h[m] + coa[m] + acile_L[m] '
        % 'ACLEUm'        'Acetylation of Leucine'                           0        -0.00238257243998418      10000       10000      'accoa[m] + leu_L[m]  -> h[m] + coa[m] + acleu_L[m] '
        
        
        % Try to force the model to take up experimentally measured uptake
        relaxOptionsMetabolomics = options.relaxOptions;
        
        relaxOptionsMetabolomics.exchangeRelax = 0;
        relaxOptionsMetabolomics.internalRelax = 2;
        cannotBeTakenUpInd = find(cannotBeTakenUpBool);
        for i=1:length(cannotBeTakenUpInd)
            fprintf('%s\n',['Trying to force uptake by ' options.exoMet.rxns{cannotBeTakenUpInd(i)} ' ' options.exoMet.rxnNames{cannotBeTakenUpInd(i)}])
            modelForceExchange = model;
            modelForceExchange.lb(ismember(model.rxns,options.exoMet.rxns{cannotBeTakenUpInd(i)})) = -10000;
            modelForceExchange.ub(ismember(model.rxns,options.exoMet.rxns{cannotBeTakenUpInd(i)})) =  options.exoMet.mean(cannotBeTakenUpInd(i));
            relaxOptionsMetabolomics.excludedReactions=false(size(model.S,2),1);
            relaxOptionsMetabolomics.excludedReactions(ismember(model.rxns,options.exoMet.rxns{cannotBeTakenUpInd(i)}))=1;
            if strcmp('EX_acthr_L[e]',options.exoMet.rxns{cannotBeTakenUpInd(i)})
                relaxOptionsMetabolomics.excludedReactions(ismember(model.rxns,'THRACm'))=1;
            end
            if strcmp('EX_acleu_L[e]',options.exoMet.rxns{cannotBeTakenUpInd(i)})
                relaxOptionsMetabolomics.excludedReactions(ismember(model.rxns,'ACLEUm'))=1;
            end
            if strcmp('EX_acile_L[e]',options.exoMet.rxns{cannotBeTakenUpInd(i)})
                relaxOptionsMetabolomics.excludedReactions(ismember(model.rxns,'ACILEm'))=1;
            end
            [solution, modelRelaxed] = relaxedFBA(modelForceExchange, relaxOptionsMetabolomics);
            solution
        end
        
        % Trying to force uptake by EX_acglu[e] 'Exchange of N-Acetyl-L-Glutamate'
        % model.lb(ismember(model.rxns,'ACGSm'))=-10000; %thermodynamically reversible
        %         'ACGSm'         'N-Acteylglutamate Synthase, Mitochondrial'        0        -0.0975115847662083      10000       10000      'glu_L[m] + accoa[m]  -> h[m] + coa[m] + acglu[m] '
        
        % Trying to force the uptake of EX_acthr_L[e]
        % 'r1440'         'Transport Reaction'              0        -0.0857858423675497      10000       10000      'thr_L[c]  -> thr_L[m] '
        % 'THRACm'        'Acetylation of Threonine'        0        -0.0857858423675497      10000       10000      'accoa[m] + thr_L[m]  -> h[m] + coa[m] + acthr_L[m] '
        
        % Trying to force the uptake of EX_acleu_L[e]
        %         'ACLEUm'        'Acetylation of Leucine'        0        -0.00238257243998418      10000       10000      'accoa[m] + leu_L[m]  -> h[m] + coa[m] + acleu_L[m] '
        %
        % Trying to force the uptake of EX_acile_L[e]
        %         'ACILEm'        'Acetylation of Isoleucine'        0        -0.00220676906348284      10000       10000      'accoa[m] + ile_L[m]  -> h[m] + coa[m] + acile_L[m] '
        
        % Unexpected differences in the pharmacokinetics of N-acetyl-DL-leucine enantiomers after oral dosing and their clinical relevance https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0229585
        
        % Try to force the model to take up experimentally measured secretion
        relaxOptionsMetabolomics = options.relaxOptions;
        
        relaxOptionsMetabolomics.exchangeRelax = 2;
        relaxOptionsMetabolomics.internalRelax = 2;
        cannotBeSecretedInd = find(cannotBeSecretedBool);
        
        fprintf('%s\n',['Trying to force secretion by ' int2str(nnz(cannotBeSecretedInd)) ' exchange reactions'])
        modelForceExchange = model;
        modelForceExchange.lb(ismember(model.rxns,options.exoMet.rxns(cannotBeSecretedInd))) =  options.exoMet.mean(cannotBeSecretedInd);
        modelForceExchange.ub(ismember(model.rxns,options.exoMet.rxns(cannotBeSecretedInd))) =  10000;
        modelForceExchange.lb(ismember(model.rxns,'EX_ura[e]'))=0;%
        modelForceExchange.lb(ismember(model.rxns,'EX_odecrn[e]'))=-0.04; %this might be in plasma
        modelForceExchange.lb(ismember(model.rxns,'EX_octa[e]'))=0;%requires reversal of reaction generating atp 'FACOAL80i'       'Fatty-Acid- Coenzyme A Ligase (Octanoate)'
        modelForceExchange.lb(ismember(model.rxns,'HMR_0180'))=0;%requires reversal of reaction generating atp 'HMR_0180'       'Butyrate Coenzyme A Ligase'
        modelForceExchange.lb(ismember(model.rxns,'EX_M03117[e]'))=0; %requires uptake of 'EX_M02909[e]' Smcfa-Blood-Pool!!
        relaxOptionsMetabolomics.excludedReactions=false(size(model.S,2),1);
        relaxOptionsMetabolomics.excludedReactions(ismember(model.rxns,options.exoMet.rxns(cannotBeSecretedInd)))=1;
        %relaxOptionsMetabolomics.excludedReactions(ismember(model.rxns,'EX_udpglcur[e]'))=1;
        %relaxOptionsMetabolomics.excludedReactions(ismember(model.rxns,'EX_utp[e]'))=1;
        %relaxOptionsMetabolomics.excludedReactions(ismember(model.rxns,'EX_orot5p[e]'))=1;
        relaxOptionsMetabolomics.excludedReactions(ismember(model.rxns,'EX_M02909[e]'))=1;
        [solution, modelRelaxed] = relaxedFBA(modelForceExchange, relaxOptionsMetabolomics);
        solution
        %     Forward_Reaction                 Name                  lb_before         lb_after          ub_before    ub_after         equation
        %     ________________    _______________________________    _________    ___________________    _________    ________    __________________
        %
        %     'EX_udpglcur[e]'    'Exchange '                            0        -0.0422516533271846      10000       10000      'udpglcur[e]  -> '
        %     'EX_odecrn[e]'      'Exchange of L-Oleoylcarnitine'        0         -0.033748858688341      10000       10000      'odecrn[e]  -> '
        %     'EX_M02909[e]'      'EX_M02909[e]'                         0         -0.579911506057156      10000       10000      'M02909[e]  -> '
        
        % Try to force the model to take up experimentally measured secretion
        relaxOptionsMetabolomics = options.relaxOptions;
        relaxOptionsMetabolomics.exchangeRelax = 0;
        relaxOptionsMetabolomics.internalRelax = 2;
        %relaxOptionsMetabolomics.nbMaxIteration = 4;
        
        cannotBeSecretedInd = find(cannotBeSecretedBool);
        for i=1:length(cannotBeSecretedInd)
            fprintf('%s\n',['Trying to force secretion by ' options.exoMet.rxns{cannotBeSecretedInd(i)} ' ' options.exoMet.rxnNames{cannotBeSecretedInd(i)}])
            modelForceExchange = model;
            modelForceExchange.lb(ismember(model.rxns,options.exoMet.rxns{cannotBeSecretedInd(i)})) =  options.exoMet.mean(cannotBeSecretedInd(i));
            modelForceExchange.ub(ismember(model.rxns,options.exoMet.rxns{cannotBeSecretedInd(i)})) =  10000;
            relaxOptionsMetabolomics.excludedReactions=false(size(model.S,2),1);
            relaxOptionsMetabolomics.excludedReactions(ismember(model.rxns,options.exoMet.rxns{cannotBeSecretedInd(i)}))=1;
            if strcmp('EX_ura[e]',options.exoMet.rxns{cannotBeSecretedInd(i)})
                relaxOptionsMetabolomics.excludedReactions=false(size(model.S,2),1);
                relaxOptionsMetabolomics.excludedReactions(model.S(ismember(model.mets,'q10[m]'),:)~=0)=1;
                relaxOptionsMetabolomics.excludedReactions(model.S(ismember(model.mets,'q10[c]'),:)~=0)=1;
            end
            [solution, modelRelaxed] = relaxedFBA(modelForceExchange, relaxOptionsMetabolomics);
            solution
        end
        
        % Trying to force secretion by EX_pmtcrn[e] 'Exchange of L-Palmitoylcarnitine'
        % relaxOptionsMetabolomics.exchangeRelax = 2;
        % relaxOptionsMetabolomics.internalRelax = 2;
        % 'EX_elaidcrn[e]'    'Exchange of Elaidic Carnitine'        0        -0.000194968677533325      10000       10000      'elaidcrn[e]  -> '
        % Without exchange relaxation, infeasible
        
        % Trying to force secretion by EX_pcrn[e] 'Exchange of O-Propanoylcarnitine'
        % relaxOptionsMetabolomics.exchangeRelax = 2;
        % relaxOptionsMetabolomics.internalRelax = 2;
        % 'EX_elaidcrn[e]'    'Exchange of Elaidic Carnitine'        0        -0.000194968677533325      10000       10000      'elaidcrn[e]  -> '
        % Without exchange relaxation, infeasible
        
        % Trying to force secretion by EX_ura[e] 'Exchange of Uracil '
        % relaxOptionsMetabolomics.exchangeRelax = 2;
        % relaxOptionsMetabolomics.internalRelax = 2;
        % 'EX_udpglcur[e]'    'Exchange '        0        -0.00136261003825666      10000       10000      'udpglcur[e]  -> '
        % Non-exchange: 'TMDS'         'Thymidylate Synthase'        0        -0.00136261003899563      10000       10000      'mlthf[c] + dump[c]  -> dhf[c] + dtmp[c] '
        
        % Trying to force secretion by EX_c10crn[e] 'Exchange of Decanoyl Carnitine'
        % relaxOptionsMetabolomics.exchangeRelax = 2;
        % relaxOptionsMetabolomics.internalRelax = 2;
        % 'EX_stcrn[e]'      'Exchange of O-Octadecanoyl-R-Carnitine'        0        -0.00206770066142781      10000       10000      'stcrn[e]  -> '
        % Without exchange relaxation, infeasible
        
        % Trying to force secretion by EX_M03117[e] 'EX_M03117[e]' i.e. Undecanoic acid
        % Human Metabolome Database (HMDB): Undecanoic acid is a medium chain length monocarboxylic acid that appears to be involved in the control of triacylglycerol synthesis.(PMID 1739406). It is found in breast milk produced by women in the United States (PMID 16332663), in infant formulas ( Mljekarstvo (2005), 55(2), 101-112.), in seminal plasma (PMID 736283), and other fluids (PMID 8548929).
        % relaxOptionsMetabolomics.exchangeRelax = 2;
        % relaxOptionsMetabolomics.internalRelax = 2;
        % 'EX_M02909[e]'     'EX_M02909[e]'        0        -0.038541975089834      10000       10000      'M02909[e]  -> '
        % 'EX_M02909[e]' Smcfa-Blood-Pool!!
        % https://europepmc.org/article/pmc/pmc4937331 ‘SMCFA blood pool’ short- and medium-chain fatty acids
        % Without exchange relaxation, infeasible
        % https://metabolicatlas.org/explore/gem-browser/human1/metabolite/m02909s
        
        % Trying to force secretion by EX_octa[e] 'Exchange of Octanoate (N-C8:0)'
        % relaxOptionsMetabolomics.exchangeRelax = 2;
        % relaxOptionsMetabolomics.internalRelax = 2;
        % 'FACOAL80i'       'Fatty-Acid- Coenzyme A Ligase (Octanoate)'        0        -0.0260509381128012      10000       10000      'atp[c] + coa[c] + octa[c]  -> amp[c] + ppi[c] + occoa[c] '
        %
        % Trying to force secretion by EX_acrn[e] 'Exchange of O-Acetylcarnitine'
        % relaxOptionsMetabolomics.exchangeRelax = 2;
        % relaxOptionsMetabolomics.internalRelax = 2;
        % 'EX_stcrn[e]'      'Exchange of O-Octadecanoyl-R-Carnitine'        0        -0.0422516533290036      10000       10000      'stcrn[e]  -> '
        % Without exchange relaxation, infeasible
        
        % Trying to force secretion by EX_dca[e] 'Exchange of Decanoate (N-C10:0)'
        % relaxOptionsMetabolomics.exchangeRelax = 2;
        % relaxOptionsMetabolomics.internalRelax = 2;
        % 'HMR_0180'       'Butyrate Coenzyme A Ligase'        0        -0.0724889382571445      10000       10000      'atp[c] + coa[c] + dca[c]  -> amp[c] + ppi[c] + dcacoa[c] '
    end
end

%% 10/22.d. Test feasability & relax bounds if needed

sol = optimizeCbModel(model);
modifiedFluxes = [];
if  sol.stat ~=1
    if ~isfield(param, 'relaxOptions')
        
        % Allow to relax only exchange rxns
        relaxOptionsOrig.internalRelax = 0;
        relaxOptionsOrig.steadyStateRelax = 1;
        relaxOptionsOrig.printLevel = param.printLevel;
        relaxOptionsOrig.excludedReactionLB = ones(length(model.rxns), 1);
        relaxOptionsOrig.excludedReactionUB = ones(length(model.rxns), 1);
        relaxOptionsOrig.maxRelaxR = param.TolMaxBoundary;
        
        % if provided, exclude certain metabolites from relaxing
        if isfield(param, 'excludeMetsFromRelax')
            relaxOptionsOrig.excludedMetabolites = zeros(length(model.mets), 1);
            disp('excluding provided metabolites from relaxation')
            relaxOptionsOrig.excludedMetabolites(ismember(model.mets, param.excludeMetsFromRelax)) = 1;
            allRxns = findRxnsFromMets(model, param.excludeMetsFromRelax);
            excRxnsFromMets = allRxns(ismember(allRxns, model.rxns(findExcRxns(model))));
        end
        
        modelTemp = [];
        relaxationSteps = 1;
        while isempty(modelTemp)
            relaxOptions = relaxOptionsOrig;
            switch relaxationSteps
                case 1 % Relax media metabolites (if present)
                    if isfield(specificData, 'mediaData')
                        toRelax = specificData.mediaData.rxns;
                        if isfield(param, 'excludeMetsFromRelax')
                            toRelax = toRelax(~ismember(toRelax, excRxnsFromMets));
                        end
                        relaxOptions.excludedReactionLB(ismember(model.rxns, toRelax)) = 0;
                    end
                case 2 % Relax media metabolites and custom constraints (if present)
                    if isfield(specificData, 'rxns2constrain')
                        disp('relaxing mediaData and custom constraints')
                        relaxOptions.excludedReactionUB(ismember(model.rxns, specificData.rxns2constrain.rxns)) = 0;
                        for i = 1:length(specificData.rxns2constrain.rxns)
                            if specificData.rxns2constrain.lb(i) > 0
                                relaxOptions.excludedReactionLB(ismember(model.rxns, specificData.rxns2constrain.rxns(i))) = 0;
                            end
                        end
                    end
                case 3 % Relax media metabolites and custom and metabolomics constraints (if present)
                    if isfield(specificData, 'exoMet')
                        disp('relaxing mediaData, custom, and metabolomics constraints')
                        relaxOptions.excludedReactionUB(ismember(model.rxns, specificData.exoMet.rxns)) = 0;
                    end
                case 4 % Relax media metabolites and all secretion reactions
                    disp('allow relaxation of mediaData and all UB of exchange reactions')
                    selExc = findSExRxnInd(model);
                    exRxns = model.rxns(selExc.ExchRxnBool);
                    exRxns = exRxns(~ismember(exRxns, 'EX_o2[e]'));
                    relaxOptions.excludedReactionUB(ismember(model.rxns, exRxns)) = 0;
                case 5 % Relax all exchanges, don't relax excluded metabolites
                    disp('allow relaxation of all exchange reactions, but do not relax excluded metabolites (if provided)')
                    if isfield(param, 'excludeMetsFromRelax')
                        exRxns_M = exRxns(~ismember(exRxns, excRxnsFromMets));
                        relaxOptions.excludedReactionLB(ismember(model.rxns, exRxns_M)) = 0;
                    else
                        relaxOptions.excludedReactionLB(ismember(model.rxns, exRxns)) = 0;
                    end
                case 6 % Relax all exchanges
                    disp('allow relaxation of all exchange reactions, ignore excluded metabolites')
                    relaxOptions = rmfield(relaxOptions, 'excludedReactionLB');
                    relaxOptions = rmfield(relaxOptions, 'excludedReactionUB');
                    relaxOptions = rmfield(relaxOptions, 'excludedMetabolites');
                    relaxOptions.exchangeRelax = 2;
                otherwise
                    error('The omics model is not feasible and couldn''t be relaxed')
            end
            [~, modelTemp] = relaxedFBA(model, relaxOptions);
            relaxationSteps = relaxationSteps + 1;
        end
    else
        if isfield(param, 'boundsToRelaxExoMet')
            switch param.boundsToRelaxExoMet
                case 'upper'
                    param.relaxOptions.excludedReactionLB = ~ismember(model.rxns,param.relaxOptions.rxns);
                case 'lower'
                    param.relaxOptions.excludedReactionUB = ~ismember(model.rxns,param.relaxOptions.rxns);
                case 'both'
                    param.relaxOptions.excludedReactions = ~ismember(model.rxns,param.relaxOptions.rxns);
            end
            [~, modelTemp] = relaxedFBA(model, param.relaxOptions);
            if isempty(modelTemp)
                disp(param.relaxOptions)
                error('The omics model is not feasible and couldn''t be relaxed, try different parameters in param.relaxOptions')
            end
        else
            [~, modelTemp] = relaxedFBA(model);
            if isempty(modelTemp)
                error('The omics model is not feasible and couldn''t be relaxed, try different parameters in param.relaxOptions')
            end
        end
    end
    
    % Realx bounds to make it feasible
    if ~isempty(modelTemp)
        if ~isfield(modelTemp, 'constraintDescription')
            modelTemp.constraintDescription(1:length(modelTemp.rxns), 1) = {''};
        end
        idx = [find(~(model.lb == modelTemp.lb)); find(~(model.ub == modelTemp.ub))];
        for i = 1:length(idx)
            modelTemp.constraintDescription(idx(i)) = {[modelTemp.constraintDescription{idx(i)} ' (Relaxed)']};
        end
        modifiedFluxes = [model.rxns(idx) num2cell(model.lb(idx)) num2cell(model.ub(idx)) num2cell(modelTemp.lb(idx)) num2cell(modelTemp.ub(idx)) modelTemp.constraintDescription(idx)];
        if param.printLevel > 0
            disp('Relaxed fluxes:')
            modifiedFluxes
            disp(' ')
        end
        model = modelTemp;
    else
        disp('Both original and relaxed model are INFEASIBLE! Please see the report for more information about constraints.')
    end
end
