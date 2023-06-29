function [] = generateMetaboReport(modelProperties,reportDir,orgNames)
% This function generates the metaboReport.
%
% INPUT 
% modelProperties strcuture containing the model properties, generated with
% 
%
%
% Ines Thiele 2022

F = fieldnames(modelProperties);

for i = 1 : length(F)
    clear html
    fid=fopen('reportTemplate.html');
    tline = fgetl(fid);
    cnt =1;
    while ischar(tline)
        disp(tline)
        tline = fgetl(fid);
        disp(tline)
        % replace space holders in template html file
        if ~isnumeric(tline)
            if ~exist('orgNames','var')
                ModelName = regexprep(F{i},'_', ' ');
            else
                if strcmp(F{i},orgNames{i})
                    ModelName = regexprep(F{i},'_', ' ');
                else
                    ModelName = regexprep(orgNames{i},'_', ' ');
                end
            end
            tline= regexprep(tline,'###ModelName',ModelName);
            % Basic information
            tline= regexprep(tline,'###OverallScore',num2str(round(modelProperties.(F{i}).modelProp2.Scores.Overall,2)));
            tline= regexprep(tline,'###NumMets',num2str(modelProperties.(F{i}).modelProp2.m));
            tag = '###ListNumMets'; list = modelProperties.(F{i}).modelProp2.Details.metabolites; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumRxns',num2str(modelProperties.(F{i}).modelProp2.n));
            tag = '###ListNumRxns'; list = modelProperties.(F{i}).modelProp2.Details.reactions; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            tline= regexprep(tline,'###NumGenes',num2str(modelProperties.(F{i}).modelProp2.genes));
            tline= regexprep(tline,'###NumComp',num2str(modelProperties.(F{i}).modelProp2.compartments));
            tline= regexprep(tline,'###MetCov',num2str(round(modelProperties.(F{i}).modelProp2.metCov,2)));
            % Metabolic information
            tline= regexprep(tline,'###NumMUnique',num2str(modelProperties.(F{i}).modelProp2.metUnique));
            tag = '###ListMetUnique'; list = modelProperties.(F{i}).modelProp2.Details.metabolites_unique; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetNoCharge',num2str(modelProperties.(F{i}).modelProp2.MissingMetCharge));
            
            tline= regexprep(tline,'###NumMetNoForm',num2str(modelProperties.(F{i}).modelProp2.MissingMetFormulae));
            tag = '###ListNumMetNoForm'; list = modelProperties.(F{i}).modelProp2.Details.MissingMetFormulae; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###MedComp',num2str(modelProperties.(F{i}).modelProp2.MediumMets));
            tag = '###ListMedComp'; list = modelProperties.(F{i}).modelProp2.Details.MediumMets; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            % Reaction information
            tline= regexprep(tline,'###NumMetRxns',num2str(modelProperties.(F{i}).modelProp2.MetabolicRxns));
            tag = '###ListNumMetRxns'; list = modelProperties.(F{i}).modelProp2.Details.MetabolicRxns; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumTransRxns',num2str(modelProperties.(F{i}).modelProp2.TransportRxns));
            tag = '###ListNumTransRxns'; list = modelProperties.(F{i}).modelProp2.Details.TransportRxns; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumExRxns',num2str(modelProperties.(F{i}).modelProp2.ExchangeRxns));
            tag = '###ListNumExRxns'; list = modelProperties.(F{i}).modelProp2.Details.ExchangeRxns; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumDmRxns',num2str(modelProperties.(F{i}).modelProp2.DemandRxns));
            tag = '###ListNumDmRxns'; list = modelProperties.(F{i}).modelProp2.Details.DemandRxns; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumSinkRxns',num2str(modelProperties.(F{i}).modelProp2.SinkRxns));
            tag = '###ListNumSinkRxns'; list = modelProperties.(F{i}).modelProp2.Details.SinkRxns; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumBmRxns',num2str(modelProperties.(F{i}).modelProp2.BiomassRxns));
            tag = '###ListNumBmRxns'; list = modelProperties.(F{i}).modelProp2.Details.BiomassRxns; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            % GPR information
            tline= regexprep(tline,'###NumRxnWoGpr',num2str(round(modelProperties.(F{i}).modelProp2.RxnsWithoutGpr,2)));
            tag = '###ListNumRxnWoGpr'; list = modelProperties.(F{i}).modelProp2.Details.RxnsWithoutGpr; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumTRxnWoGpr',num2str(round(modelProperties.(F{i}).modelProp2.TRxnsWithoutGpr,2)));
            tag = '###ListNumTRxnWoGpr'; list = modelProperties.(F{i}).modelProp2.Details.TRxnsWithoutGpr; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            % Network topology
            tline= regexprep(tline,'###NumBlockedR',num2str(round(modelProperties.(F{i}).modelProp2.BlockedRxns,2)));
            tag = '###ListNumBlockedR'; list = modelProperties.(F{i}).modelProp2.Details.BlockedRxns; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumDeadM',num2str(round(modelProperties.(F{i}).modelProp2.DeadendsMets,2)));
            tag = '###ListNumDeadM'; list = modelProperties.(F{i}).modelProp2.Details.DeadendsMets; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumStoichCycleRxns',num2str(round(modelProperties.(F{i}).modelProp2.StoichCycleRxns,2)));
            tag = '###ListNumStoichCycleRxns'; list = modelProperties.(F{i}).modelProp2.Details.StoichCycleRxns; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            % Matrix Conditioning
            tline= regexprep(tline,'###NumMinMaxCoeff',num2str(round(modelProperties.(F{i}).modelProp2.maxminCoeff,2)));
            tag = '###ListNumMinMaxCoeff'; list = modelProperties.(F{i}).modelProp2.Details.maxminCoeff; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumRank',num2str(round(modelProperties.(F{i}).modelProp2.Rank,2)));
            
            % Consistency
            tline= regexprep(tline,'###NumConsRxns',num2str(round(modelProperties.(F{i}).modelProp2.ConsRxns,2)));
            tag = '###ListNumConsRxns'; list = modelProperties.(F{i}).modelProp2.Details.InconsRxns; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumBalRxns',num2str(round(modelProperties.(F{i}).modelProp2.BalancedMassRxns,2)));
            tag = '###ListNumBalRxns'; list = modelProperties.(F{i}).modelProp2.Details.UnBalancedMassRxns; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumChargeRxns',num2str(round(modelProperties.(F{i}).modelProp2.BalancedChargeRxns,2)));
            tag = '###ListNumChargeRxns'; list = modelProperties.(F{i}).modelProp2.Details.UnBalancedChargeRxns; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetConnec',num2str(round(modelProperties.(F{i}).modelProp2.MetConn,2)));
            tag = '###ListNumMetConnec'; list = modelProperties.(F{i}).modelProp2.Details.MetConn; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumUnboundR',num2str(round(modelProperties.(F{i}).modelProp2.UnboundedFlux,2)));
            tag = '###ListNumUnboundR'; list = modelProperties.(F{i}).modelProp2.Details.UnboundedFluxRxns; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###ScoreConsistency',num2str(round(modelProperties.(F{i}).modelProp2.Scores.Consistency,2)));
            
            % Annotation - Metabolites
            tline= regexprep(tline,'###NumMAnnoAny',num2str(round(modelProperties.(F{i}).modelProp2.MetWAnno,2)));
            tag = '###ListNumMAnnoAny'; list = modelProperties.(F{i}).modelProp2.Details.metWOAnno; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetPubCh',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetmetPubChemID,2)));
            tag = '###ListNumMetPubCh'; list = modelProperties.(F{i}).modelProp2.Details.missingmetPubChemID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetKegg',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetmetKEGGID,2)));
            tag = '###ListNumMetKegg'; list = modelProperties.(F{i}).modelProp2.Details.missingmetKEGGID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetSeed',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetmetSEEDID,2)));
            tag = '###ListNumMetSeed'; list = modelProperties.(F{i}).modelProp2.Details.missingmetSEEDID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetIKey',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetmetInchiKey,2)));
            tag = '###ListNumMetIKey'; list = modelProperties.(F{i}).modelProp2.Details.missingmetInchiKey; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetIString',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetmetInchiString,2)));
            tag = '###ListNumMetIString'; list = modelProperties.(F{i}).modelProp2.Details.missingmetInchiString; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetChebi',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetmetChEBIID,2)));
            tag = '###ListNumMetChebi'; list = modelProperties.(F{i}).modelProp2.Details.missingmetChEBIID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetHmdb',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetmetHMDBID,2)));
            tag = '###ListNumMetHmdb'; list = modelProperties.(F{i}).modelProp2.Details.missingmetHMDBID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetReac',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetmetReactomeID,2)));
            tag = '###ListNumMetReac'; list = modelProperties.(F{i}).modelProp2.Details.missingmetReactomeID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetMetNetX',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetmetMetaNetXID,2)));
            tag = '###ListNumMetMetNetX'; list = modelProperties.(F{i}).modelProp2.Details.missingmetMetaNetXID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetBigg',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetmetBiGGID,2)));
            tag = '###ListNumMetBigg'; list = modelProperties.(F{i}).modelProp2.Details.missingmetBiGGID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetBioc',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetmetBioCycID,2)));
            tag = '###ListNumMetBioc'; list = modelProperties.(F{i}).modelProp2.Details.missingmetBioCycID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            % Annotation - Metabolites - Conformity
            tline= regexprep(tline,'###NumMetCPubCh',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetConfmetPubChemID,2)));
            tag = '###ListNumMetCPubCh'; list = modelProperties.(F{i}).modelProp2.Details.missingmetPubChemID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetCKegg',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetConfmetKEGGID,2)));
            tag = '###ListNumMetCKegg'; list = modelProperties.(F{i}).modelProp2.Details.AnnoMetNonConfmetKEGGID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetCSeed',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetConfmetSEEDID,2)));
            tag = '###ListNumMetCSeed'; list = modelProperties.(F{i}).modelProp2.Details.AnnoMetNonConfmetSEEDID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetCIKey',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetConfmetInchiKey,2)));
            tag = '###ListNumMetCIKey'; list = modelProperties.(F{i}).modelProp2.Details.AnnoMetNonConfmetInchiKey; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetCIString',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetConfmetInchiString,2)));
            tag = '###ListNumMetCIString'; list = modelProperties.(F{i}).modelProp2.Details.AnnoMetNonConfmetInchiString; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetCChebi',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetConfmetChEBIID,2)));
            tag = '###ListNumMetCChebi'; list = modelProperties.(F{i}).modelProp2.Details.AnnoMetNonConfmetChEBIID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetCHmdb',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetConfmetHMDBID,2)));
            tag = '###ListNumMetCHmdb'; list = modelProperties.(F{i}).modelProp2.Details.AnnoMetNonConfmetHMDBID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetCReac',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetConfmetReactomeID,2)));
            tag = '###ListNumMetCReac'; list = modelProperties.(F{i}).modelProp2.Details.AnnoMetNonConfmetReactomeID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetCMetNetX',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetConfmetMetaNetXID,2)));
            tag = '###ListNumMetCMetNetX'; list = modelProperties.(F{i}).modelProp2.Details.AnnoMetNonConfmetMetaNetXID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetCBigg',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetConfmetBiGGID,2)));
            tag = '###ListNumMetCBigg'; list = modelProperties.(F{i}).modelProp2.Details.AnnoMetNonConfmetBiGGID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetCBioc',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetConfmetBioCycID,2)));
            tag = '###ListNumMetCBioc'; list = modelProperties.(F{i}).modelProp2.Details.AnnoMetNonConfmetBioCycID; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###ScoreAnnotationMetabolites',num2str(round(modelProperties.(F{i}).modelProp2.Scores.AnnotationMetabolites,2)));
            
            % Reaction Annotation
            tline= regexprep(tline,'###NumRAnnoAny',num2str(round(modelProperties.(F{i}).modelProp2.rxnWAnno,2)));
            tag = '###ListNumRAnnoAny'; list = modelProperties.(F{i}).modelProp2.Details.rxnWOAnno; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumRRhea',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnrxnRheaID,2)));
            tag = '###ListNumRRhea'; list = modelProperties.(F{i}).modelProp2.Details.missingrxnRheaID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCRRhea',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnConfrxnRheaID,2)));
            tag = '###ListNumCRRhea'; list = modelProperties.(F{i}).modelProp2.Details.AnnoRxnNonConfrxnRheaID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumRKegg',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnrxnKEGGID,2)));
            tag = '###ListNumRKegg'; list = modelProperties.(F{i}).modelProp2.Details.missingrxnKEGGID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCRKegg',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnConfrxnKEGGID,2)));
            tag = '###ListNumCRKegg'; list = modelProperties.(F{i}).modelProp2.Details.AnnoRxnNonConfrxnKEGGID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumRSeed',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnrxnSEEDID,2)));
            tag = '###ListNumRSeed'; list = modelProperties.(F{i}).modelProp2.Details.missingrxnSEEDID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCRSeed',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnConfrxnSEEDID,2)));
            tag = '###ListNumCRSeed'; list = modelProperties.(F{i}).modelProp2.Details.AnnoRxnNonConfrxnSEEDID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumRMetX',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnrxnMetaNetXID,2)));
            tag = '###ListNumRMetX'; list = modelProperties.(F{i}).modelProp2.Details.missingrxnMetaNetXID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCRMetX',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnConfrxnMetaNetXID,2)));
            tag = '###ListNumCRMetX'; list = modelProperties.(F{i}).modelProp2.Details.AnnoRxnNonConfrxnMetaNetXID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumRBigg',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnrxnBiGGID,2)));
            tag = '###ListNumRBigg'; list = modelProperties.(F{i}).modelProp2.Details.missingrxnBiGGID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCRBigg',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnConfrxnBiGGID,2)));
            tag = '###ListNumCRBigg'; list = modelProperties.(F{i}).modelProp2.Details.AnnoRxnNonConfrxnBiGGID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumRReac',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnrxnReactomeID,2)));
            tag = '###ListNumRReac'; list = modelProperties.(F{i}).modelProp2.Details.missingrxnReactomeID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCRReac',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnConfrxnReactomeID,2)));
            tag = '###ListNumCRReac'; list = modelProperties.(F{i}).modelProp2.Details.AnnoRxnNonConfrxnReactomeID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumRBren',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnrxnBRENDAID,2)));
            tag = '###ListNumRBren'; list = modelProperties.(F{i}).modelProp2.Details.missingrxnBRENDAID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCRBren',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnConfrxnBRENDAID,2)));
            tag = '###ListNumCRBren'; list = modelProperties.(F{i}).modelProp2.Details.AnnoRxnNonConfrxnBRENDAID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumRBioc',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnrxnBioCycID,2)));
            tag = '###ListNumRBioc'; list = modelProperties.(F{i}).modelProp2.Details.missingrxnBioCycID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCRBioc',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnConfrxnBioCycID,2)));
            tag = '###ListNumCRBioc'; list = modelProperties.(F{i}).modelProp2.Details.AnnoRxnNonConfrxnBioCycID; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            
            tline= regexprep(tline,'###NumREcn',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnrxnECNumbers,2)));
            tag = '###ListNumREcn'; list = modelProperties.(F{i}).modelProp2.Details.missingrxnECNumbers; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCREcn',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnConfrxnECNumbers,2)));
            tag = '###ListNumCREcn'; list = modelProperties.(F{i}).modelProp2.Details.AnnoRxnNonConfrxnECNumbers; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###ScoreAnnotationReactions',num2str(round(modelProperties.(F{i}).modelProp2.Scores.AnnotationReactions,2)));
            
            % Gene Annotation
            
            tline= regexprep(tline,'###NumGAnnoAny',num2str(round(modelProperties.(F{i}).modelProp2.geneWAnno,2)));
            tag = '###ListNumGAnnoAny'; list = modelProperties.(F{i}).modelProp2.Details.geneWOAnno; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumGRefSeq',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGenegeneRefSeqID,2)));
            tag = '###ListNumGRefSeq'; list = modelProperties.(F{i}).modelProp2.Details.missinggeneRefSeqID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumGUniProt',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGenegeneUniprotID,2)));
            tag = '###ListNumGUniProt'; list = modelProperties.(F{i}).modelProp2.Details.missinggeneUniprotID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumGEcoGene',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGenegeneEcoGeneID,2)));
            tag = '###ListNumGEcoGene'; list = modelProperties.(F{i}).modelProp2.Details.missinggeneEcoGeneID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumGKegg',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGenegeneKEGGID,2)));
            tag = '###ListNumGKegg'; list = modelProperties.(F{i}).modelProp2.Details.missinggeneKEGGID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumGNCBIG',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGenegeneEntrezID,2)));
            tag = '###ListNumGNCBIG'; list = modelProperties.(F{i}).modelProp2.Details.missinggeneEntrezID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumGNCBIP',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGenegeneNCBIProteinID,2)));
            tag = '###ListNumGNCBIP'; list = modelProperties.(F{i}).modelProp2.Details.missinggeneNCBIProteinID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumGCCDS',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGenegeneCCDSID,2)));
            tag = '###ListNumGCCDS'; list = modelProperties.(F{i}).modelProp2.Details.missinggeneCCDSID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumGHPRD',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGenegeneHPRDID,2)));
            tag = '###ListNumGHPRD'; list = modelProperties.(F{i}).modelProp2.Details.missinggeneHPRDID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumGASAP',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGenegeneASAPID,2)));
            tag = '###ListNumGASAP'; list = modelProperties.(F{i}).modelProp2.Details.missinggeneASAPID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            
            
            
            
            
            tline= regexprep(tline,'###NumCGRefSeq',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGeneConfgeneRefSeqID,2)));
            tag = '###ListNumCGRefSeq'; list = modelProperties.(F{i}).modelProp2.Details.AnnoGeneNonConfgeneRefSeqID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCGUniProt',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGeneConfgeneUniprotID,2)));
            tag = '###ListNumCGUniProt'; list = modelProperties.(F{i}).modelProp2.Details.AnnoGeneNonConfgeneUniprotID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCGEcoGene',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGeneConfgeneEcoGeneID,2)));
            tag = '###ListNumCGEcoGene'; list = modelProperties.(F{i}).modelProp2.Details.AnnoGeneNonConfgeneEcoGeneID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCGKegg',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGeneConfgeneKEGGID,2)));
            tag = '###ListNumCGKegg'; list = modelProperties.(F{i}).modelProp2.Details.AnnoGeneNonConfgeneKEGGID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCGNCBIG',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGeneConfgeneEntrezID,2)));
            tag = '###ListNumCGNCBIG'; list = modelProperties.(F{i}).modelProp2.Details.AnnoGeneNonConfgeneEntrezID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCGNCBIP',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGeneConfgeneNCBIProteinID,2)));
            tag = '###ListNumCGNCBIP'; list = modelProperties.(F{i}).modelProp2.Details.AnnoGeneNonConfgeneNCBIProteinID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCGCCDS',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGeneConfgeneCCDSID,2)));
            tag = '###ListNumCGCCDS'; list = modelProperties.(F{i}).modelProp2.Details.AnnoGeneNonConfgeneCCDSID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCGHPRD',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGeneConfgeneHPRDID,2)));
            tag = '###ListNumCGHPRD'; list = modelProperties.(F{i}).modelProp2.Details.AnnoGeneNonConfgeneHPRDID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumCGASAP',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGeneConfgeneASAPID,2)));
            tag = '###ListNumCGASAP'; list = modelProperties.(F{i}).modelProp2.Details.AnnoGeneNonConfgeneASAPID; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            
            
            
            
            tline= regexprep(tline,'###ScoreAnnotationGenes',num2str(round(modelProperties.(F{i}).modelProp2.Scores.AnnotationGenes,2)));
            
            % SBO Annotation
            tline= regexprep(tline,'###NumMSBOAny',num2str(round(modelProperties.(F{i}).modelProp2.metWSBO,2)));
            tag = '###ListNumMSBOAny'; list = modelProperties.(F{i}).modelProp2.Details.metWOSBO; type = 'met';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumMetSBO247',num2str(round(modelProperties.(F{i}).modelProp2.AnnoMetSBO0000247,2)));
            
            tline= regexprep(tline,'###NumRSBOAny',num2str(round(modelProperties.(F{i}).modelProp2.rxnWSBO,2)));
            tag = '###ListNumRSBOAny'; list = modelProperties.(F{i}).modelProp2.Details.rxnWOSBO; type = 'rxn';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumRSBO176',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnSBO0000176,2)));
            tline= regexprep(tline,'###NumRSBO176',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnSBO0000176,2)));
            tline= regexprep(tline,'###NumRSBO185',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnSBO0000185,2)));
            tline= regexprep(tline,'###NumRSBO627',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnSBO0000627,2)));
            tline= regexprep(tline,'###NumRSBO628',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnSBO0000628,2)));
            tline= regexprep(tline,'###NumRSBO632',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnSBO0000632,2)));
            tline= regexprep(tline,'###NumRSBO629',num2str(round(modelProperties.(F{i}).modelProp2.AnnoRxnSBO0000629,2)));
            
            tline= regexprep(tline,'###NumGSBOAny',num2str(round(modelProperties.(F{i}).modelProp2.geneWSBO,2)));
            tag = '###ListNumGSBOAny'; list = modelProperties.(F{i}).modelProp2.Details.geneWOSBO; type = 'none';
            tline = writeListItem(tline,tag,list,type);
            
            tline= regexprep(tline,'###NumGSBO243',num2str(round(modelProperties.(F{i}).modelProp2.AnnoGeneSBO0000243,2)));
            
            tline= regexprep(tline,'###ScoreAnnotationSBO',num2str(round(modelProperties.(F{i}).modelProp2.Scores.AnnotationSBO,2)));
            
        end
        html{cnt} = tline;
        cnt = cnt + 1;
    end
    fclose(fid);
    html = html';
    ModelName = regexprep(ModelName,' ','_');
    fid =fopen([reportDir filesep 'modelreport_' ModelName '.html'], 'w');
    
    for j = 1 : length(html)-1
        fprintf(fid,strcat(html{j},'\n'));
    end
    
    fclose(fid);
end

function tlineOut = writeListItem(tline,tag,list,type)
%type = 'rxn';
%type = 'met';
if  regexp(tline,tag)
    %  tline= regexprep(tline,'###ListMedComp',num2str(modelProperties.(F{i}).modelProp2.MediumMets+2));
    tlineOut = '';
    for k = 1 : length(list)
        m = list{k};
        if strcmp(type,'rxn')
            tlineOut = strcat(tlineOut,'<li class="list-group-item"> <a href = https://vmh.life/#reaction/',m,' target = "_blank">',m,'</a>','</li>','\n');
        elseif strcmp(type,'met')
            if contains(m,'[')
                mpart = split(m,'[');
                mpart = mpart{1};
            else
                mpart = m;
            end
            tlineOut = strcat(tlineOut,'<li class="list-group-item"> <a href = https://vmh.life/#metabolite/',mpart,' target = "_blank">',m,'</a>','</li>','\n');
        elseif strcmp(type,'none')
            tlineOut = strcat(tlineOut,'<li class="list-group-item">',m,'</li>','\n');
        end
    end
else
    tlineOut = tline;
end
