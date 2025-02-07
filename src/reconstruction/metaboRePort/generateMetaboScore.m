function [modelProp,ScoresOverall] = generateMetaboScore(model,nworkers)

% Ines Thiele June 2022

if ~exist('nworkers','var')
    nworkers = 4;
end

%% Basic model properties
% number of reactions
modelProp.n = size(model.S,2);
modelProp.Details.reactions = model.rxns;

% number of metabolites
modelProp.m = size(model.S,1);
modelProp.Details.metabolites = model.mets;

% number of genes
modelProp.genes = size(model.genes,1);
modelProp.Details.genes = model.genes;
% metabolic coverage
modelProp.metCov = modelProp.n/modelProp.genes  ;

% unique metabolites
m = split(model.mets,'[');
mUnique = unique(m(:,1));
modelProp.metUnique = length(mUnique);
modelProp.Details.metabolites_unique = mUnique;

ExR = 0;
DmR = 0;
SinkR = 0;
BioR = 0;
MetR = 0;
TransR = 0;
cntM = 1;
cntT = 1;
listAllComp =[];
for i = 1 : length(model.rxns)
    if ~isempty(find(contains(model.rxns{i},'EX_'))) ||  ~isempty(find(contains(model.rxns{i},'Ex_')))
        % Number of  Exchange Reactions
        ExR = ExR + 1;
    elseif  ~isempty(find(contains(model.rxns{i},'DM_')))
        % Demand Reaction
        DmR = DmR + 1;
    elseif  ~isempty(find(contains(model.rxns{i},'Sink_'))) || ~isempty(find(contains(model.rxns{i},'sink_')))
        SinkR = SinkR + 1;
    elseif  ~isempty(find(contains(lower(model.rxns{i}),'biomass')))
        % Biomass Reactions SBO:0000629 Presence
        BioR = BioR + 1;
    else
        % get compartments in reactions
        a = printRxnFormula(model,'rxnAbbrList',model.rxns{i},'printFlag',0);
        c = regexp(a,'\[\w]');
        c = c{1};
        if exist('comp','var')
            clear comp;
        end
        for k = 1 : length(c)
            comp{k} = a{1}(c(k):c(k)+2);
        end
        listAllComp = [listAllComp;comp'];
        % find transport and metabolic reactions
        if length(comp) > 1 % exclude some other unmapped reactions
            if  length(unique(comp)) == 1 % metabolic reaction
                % Metabolic Reaction SBO:0000176 Presence
                MetRxns{cntM} = model.rxns{i}; cntM = cntM + 1;
                MetR = MetR +1;
            elseif  length(unique(comp)) > 1
                % they have 2 different compartments
                % Transport Reaction SBO:0000185 Presence
                TransRxns{cntT} = model.rxns{i}; cntT = cntT + 1;
                TransR = TransR + 1;
            end
        end
    end
end
listAllComp = unique(listAllComp);
modelProp.Details.compartments = listAllComp;
modelProp.compartments = length(listAllComp);
% exchange reactions
modelProp.ExchangeRxns = ExR;
modelProp.Details.ExchangeRxns = [model.rxns(contains(model.rxns,'EX_'));model.rxns(contains(model.rxns,'Ex_'))];

% Medium metabolites - should correspond to exchange reactions
modelProp.MediumMets = ExR;
modelProp.Details.MediumMets = [model.rxns(contains(model.rxns,'EX_'));model.rxns(contains(model.rxns,'Ex_'))];

% demand reactopms
modelProp.DemandRxns = DmR;
modelProp.Details.DemandRxns = model.rxns(contains(model.rxns,'DM_'));

% sink reactions
modelProp.SinkRxns = SinkR;
modelProp.Details.SinkRxns = [model.rxns(contains(model.rxns,'Sink_'));model.rxns(contains(model.rxns,'sink_'))];
% biomass reactions
modelProp.BiomassRxns = BioR;
modelProp.Details.BiomassRxns = model.rxns(contains(lower(model.rxns),'biomass'));% exclude EX_biomass?

modelProp.MetabolicRxns = MetR;
modelProp.Details.MetabolicRxns =MetRxns';
modelProp.TransportRxns = TransR;
modelProp.Details.TransportRxns =TransRxns';

% internal reactions without GPR 
RxnsWOGpr = model.rxns(find(cellfun(@isempty,model.grRules)));
External = [modelProp.Details.ExchangeRxns;modelProp.Details.DemandRxns;modelProp.Details.SinkRxns ;modelProp.Details.BiomassRxns ];
RxnsWOGpr = setdiff(RxnsWOGpr,External);
modelProp.RxnsWithoutGpr = length(RxnsWOGpr)*100/modelProp.n;
modelProp.Details.RxnsWithoutGpr = RxnsWOGpr;

% transport reactions without GPR
TRxnsWithoutGpr = intersect(TransRxns',RxnsWOGpr);
modelProp.TRxnsWithoutGpr = length(TRxnsWithoutGpr)*100/TransR;
modelProp.Details.TRxnsWithoutGpr = TRxnsWithoutGpr;

% Enzyme complexes - TODO
%% CONSISTENCY
% stoichiometric consistency

%method.interface = 'LP';
method.interface = 'SDCCO';
t = tic;
[inform, mass, model] = checkStoichiometricConsistency(model, 0, method);
timeTaken = toc(t);
modelProp.mStoichC = nnz(model.SConsistentMetBool);
%  modelProp.nStoich = nnz(model.SConsistentRxnBool);

% calcuate percentage of stoichiometric consistent reactions (consistent
% reactions divided by internal reactions
modelProp.ConsRxns = nnz(model.SConsistentRxnBool)*100/length(find(model.SIntRxnBool));
inconR = model.rxns(find(model.SConsistentRxnBool==0));
inconR = intersect(inconR,model.rxns(model.SIntRxnBool));% only internal reactions
modelProp.Details.InconsRxns = inconR;
% mass and charge balanced
% remove all reactions that are not internal (i.e, ex, biomass, sink, dm)
modelInt = removeRxns(model, model.rxns(~model.SIntRxnBool));
modelInt=findSExRxnInd(modelInt);
[massImbalance, imBalancedMass, imBalancedCharge, imBalancedRxnBool, elements, missingFormulaeBool, balancedMetBool] = checkMassChargeBalance(modelInt, 0);
%modelProp.imBalancedMass = nnz(imBalancedRxnBool);
% modelProp.imBalancedCharge = nnz(imBalancedCharge);
modelProp.BalancedMassRxns =  100 - (nnz(imBalancedRxnBool)*100/modelProp.n);
modelProp.BalancedChargeRxns =  100 - (nnz(imBalancedCharge)*100/modelProp.n);
modelProp.Details.UnBalancedMassRxns = modelInt.rxns(find(imBalancedRxnBool));
modelProp.Details.UnBalancedChargeRxns = modelInt.rxns(find(imBalancedCharge));

missingMissingMetFormulae = model.metFormulas(cellfun('isempty', model.metFormulas));
modelProp.MissingMetFormulae = length(missingMissingMetFormulae);
modelProp.Details.MissingMetFormulae = missingMissingMetFormulae;

missingMissingMetCharge = model.metCharges(find(isempty(model.metCharges)));
modelProp.MissingMetCharge = length(missingMissingMetCharge);
modelProp.Details.MissingMetCharge = missingMissingMetCharge;


% metabolite connectivity - find any metabolite that does not appear in any
% reaction
modelProp.MetConn = 100-nnz(all(model.S == 0, 2))*100/modelProp.n;
modelProp.Details.MetConn = model.rxns(all(model.S == 0, 2));

% Unbounded Flux in unconstraint model
% get minimal/maximal allowed flux
maxBound = max(model.ub);
minBound = min(model.lb);
modelOpen = model;
modelOpen.lb(find(ismember(model.rxns,modelProp.Details.ExchangeRxns))) = minBound;
modelOpen.ub(find(ismember(model.rxns,modelProp.Details.ExchangeRxns))) = maxBound;
setWorkerCount(nworkers);
[minFlux, maxFlux, optsol, ret, fbasol, fvamin, fvamax, statussolmin, statussolmax] = fastFVA(modelOpen, 0,'max');

% find blocked reactions
tol = 1e-6;
blocked1 = model.rxns(find(abs(minFlux) <= tol));
blocked2 = model.rxns( find(abs(maxFlux) <= tol));
blocked = intersect(blocked1,blocked2);
modelProp.BlockedRxns = length(blocked)*100/modelProp.n;
modelProp.Details.BlockedRxns = blocked;
% find minFlux,maxFlux  on max and min Bound
minmin = model.rxns(find(minFlux == minBound));
maxmax = model.rxns(find(maxFlux == maxBound));
minmax = model.rxns(find(minFlux == maxBound));
maxmin = model.rxns(find(maxFlux == minBound));
b = unique([minmin;maxmax;minmax;maxmin]);
modelProp.UnboundedFlux = 100-(length(b)*100/(modelProp.n));
modelProp.Details.UnboundedFluxRxns = b;

% deadend metabolites
deadends = detectDeadEnds(model, 1);
modelProp.DeadendsMets = (length(deadends))*100/(modelProp.m);
modelProp.Details.DeadendsMets = model.mets(deadends);

% determine stoichiometric cycles
clear b
modelClosed = model;
modelClosed.lb(find(ismember(model.rxns,modelProp.Details.ExchangeRxns))) = 0;
modelClosed.ub(find(ismember(model.rxns,modelProp.Details.ExchangeRxns))) = 0;
modelClosed.lb(find(ismember(model.rxns,modelProp.Details.DemandRxns))) = 0;
modelClosed.ub(find(ismember(model.rxns,modelProp.Details.DemandRxns))) = 0;
modelClosed.lb(find(ismember(model.rxns,modelProp.Details.SinkRxns))) = 0;
modelClosed.ub(find(ismember(model.rxns,modelProp.Details.SinkRxns))) = 0;
[minFlux, maxFlux, optsol, ret, fbasol, fvamin, fvamax, statussolmin, statussolmax] = fastFVA(modelClosed,0,'max');
% find minFlux,maxFlux  on max and min Bound
minmin = model.rxns(find(minFlux == minBound));
maxmax = model.rxns(find(maxFlux == maxBound));
minmax = model.rxns(find(minFlux == maxBound));
maxmin = model.rxns(find(maxFlux == minBound));
b = unique([minmin;maxmax;minmax;maxmin]);
modelProp.StoichCycleRxns = (length(b))*100/length(find(model.SIntRxnBool));
modelProp.Details.StoichCycleRxns = b;

%% Matrix Conditioning
% Ratio Min/Max Non-Zero Coefficients
Coeff = model.S(find(model.S));
minCoeff = min(abs(Coeff));
maxCoeff = max(abs(Coeff));
RmaxminCoeff = maxCoeff/minCoeff;
modelProp.maxminCoeff = RmaxminCoeff;
modelProp.Details.maxminCoeff = {num2str(minCoeff);num2str(maxCoeff)};

% Rank of S
modelProp.Rank = rank(full(model.S));

% Degree of freedom - TODO
% there some other cool things that one could add: tutorial_numCharact.mlx
%% calculate subscore for consistency
modelProp.Scores.Consistency = (modelProp.ConsRxns + modelProp.BalancedMassRxns + modelProp.BalancedChargeRxns + ...
    modelProp.MetConn + modelProp.UnboundedFlux)*100/(5*100) ;

%% Annotation Metabolites
% Metabolite Annotations Per Database; regular expressions taken from
% memote

fields = {'metPubChemID'    '^\d+$'
    'metKEGGID' '^C\d+$'
    'metSEEDID' '^cpd\d+$'
    'metInchiString' '^InChI\=1S?\/[A-Za-z0-9\.]+(\+[0-9]+)?###(\/[cnpqbtmsih][A-Za-z0-9\-\+\(\)\,\/\?\;\.]+)*$'
    'metInchiKey' '^[A-Z]{14}\-[A-Z]{10}(\-[A-Z])?'
    'metChEBIID' '^CHEBI:\d+$'
    'metHMDBID' '^HMDB\d{5}$###^HMDB\d{7}$' % I included the new format
    'metReactomeID' '^R-[A-Z]{3}-[0-9]+(-[0-9]+)?$)|(^REACT_\d+(\.\d+)?$'
    'metMetaNetXID' '^MNXM\d+$'
    'metBioCycID' '^[A-Z-0-9]+(?<!CHEBI)(\:)?[A-Za-z0-9+_.%-]+$'
    'metBiGGID' '^[a-z_A-Z0-9]+$'
    };

metWOAnno = model.mets;
for i = 1 : size(fields)
    if isfield(model,fields{i,1})
        missingMet1 = model.mets(cellfun('isempty', model.(fields{i,1})));
        missingMet2 = model.mets(find((strcmp(model.(fields{i,1}),'NaN'))));
        missingMet = unique([missingMet1;missingMet2]);
        missingMetNonUnique = missingMet;
        missingMet = split(missingMet,'[');
        missingMet = unique(missingMet(:,1));
        modelProp.Details.(strcat('missing', fields{i})) = missingMet;
        modelProp.(strcat('AnnoMet', fields{i}))= (modelProp.metUnique - length(missingMet))*100/modelProp.metUnique; % how many have it
        % remove met from variable metWOAnno (metabolite without
        % annotation)
        metWOAnno = (intersect(metWOAnno,missingMet)) ;
        
        % get number of metabolites with annotation that conform with
        % database id format
        % test format
        clear confF* missing
        if contains(fields(i,2),'###')
            strs = strsplit(fields{i,2},'###');
            
            confFormat1 = model.(fields{i,1})(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), strs{1}))));
            confFormat2 =  model.(fields{i,1})(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), strs{2}))));
            confFormat = unique([confFormat1;confFormat2]);
            
            confFormatM1 = model.mets(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), strs{1}))));
            confFormatM2 =  model.mets(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), strs{2}))));
            confFormatM = unique([confFormatM1;confFormatM2]);
            
            % remove any potential NaN
            confFormat(ismember(confFormat,'NaN'))=[];
            confFormatM(ismember(confFormat,'NaN'))=[];
            
            confFormatM = split(confFormatM,'[');
            confFormatM = unique(confFormatM(:,1));
            modelProp.(strcat('AnnoMetConf', fields{i}))= (length(confFormatM))*100/(modelProp.metUnique - length(missingMet)); % how many have it
            p =  setdiff(modelProp.Details.metabolites_unique, missingMet);
            
            NonConf = setdiff(p,confFormatM);
            modelProp.Details.(strcat('AnnoMetNonConf', fields{i})) = NonConf;
        else
            confFormat = model.(fields{i,1})(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), fields(i,2)))));
            confFormatM =  model.mets(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), fields(i,2)))));
            % remove any potential NaN
            confFormatM(ismember(confFormat,'NaN'))=[];
            confFormat(ismember(confFormat,'NaN'))=[];
            
            confFormatM = split(confFormatM,'[');
            confFormatM = unique(confFormatM(:,1));
            modelProp.(strcat('AnnoMetConf', fields{i}))= (length(confFormatM))*100/(modelProp.metUnique - length(missingMet)); % how many have it
            p =  setdiff(modelProp.Details.metabolites_unique, missingMet);
            
            NonConf = setdiff(p,confFormatM);
            modelProp.Details.(strcat('AnnoMetNonConf', fields{i})) = NonConf;
        end
    else
        modelProp.Details.(strcat('missing' ,fields{i})) = model.mets;
        modelProp.(strcat('AnnoMet' ,fields{i})) = 0; % how many have it
        modelProp.(strcat('AnnoMetConf', fields{i})) = 0; % how many have it
        modelProp.Details.(strcat('AnnoMetNonConf', fields{i})) = {};
        
        
    end
end
% Presence of Metabolite Annotation
modelProp.MetWAnno = (modelProp.m - length(metWOAnno))*100/modelProp.m;
modelProp.Details.metWOAnno = metWOAnno;

% Calculate subscore
F = fieldnames(modelProp);
FAnnoMet = F(contains(F,'AnnoMet'));
modelProp.Scores.AnnotationMetabolites  = 0;
for i = 1 : length(FAnnoMet)
    if isnan(modelProp.(FAnnoMet{i}))
        modelProp.(FAnnoMet{i}) = 0;
    end
    modelProp.Scores.AnnotationMetabolites = modelProp.Scores.AnnotationMetabolites + modelProp.(FAnnoMet{i});
end
modelProp.Scores.AnnotationMetabolites = modelProp.Scores.AnnotationMetabolites + modelProp.MetWAnno;
% Uniform Metabolite Identifier Namespace - I do not understand what is
% tested here - hence we do not do it
modelProp.Scores.AnnotationMetabolites = modelProp.Scores.AnnotationMetabolites*100/(23*100) ;


%% Annotation Reactions
% Reactions Annotations Per Database; regular expressions taken from
% memote
fields = {'rxnKEGGID'  '^R\d+$'
    'rxnMetaNetXID' 'MNXR\d+$'
    'rxnRheaID' '^\d{5}$'
    'rxnSEEDID' '^rxn\d+$'
    'rxnBiGGID' '^[a-z_A-Z0-9]+$'
    'rxnReactomeID' '^R-[A-Z]{3}-[0-9]+(-[0-9]+)?$)|(^REACT_\d+(\.\d+)?$)'
    'rxnECNumbers' '^\d+\.-\.-\.-|\d+\.\d+\.-\.-|###\d+\.\d+\.\d+\.-|###\d+\.\d+\.\d+\.(n)?\d+$'
    'rxnBRENDAID' '^\d+\.-\.-\.-|\d+\.\d+\.-\.-|###\d+\.\d+\.\d+\.-|###\d+\.\d+\.\d+\.(n)?\d+$'
    'rxnBioCycID' '^[A-Z-0-9]+(?<!CHEBI)" r"(\:)?[A-Za-z0-9+_.%-]+$'
    };
rxnWOAnno = model.rxns;
for i = 1 : size(fields)
    if isfield(model,fields{i,1})
        missingRxn = model.rxns(cellfun('isempty', model.(fields{i,1})));
        
        modelProp.Details.(strcat('missing', fields{i})) = missingRxn;
        modelProp.(strcat('AnnoRxn', fields{i}))= (modelProp.n - length(missingRxn))*100/modelProp.n; % how many have it
        % remove rxn from variable rxnWOAnno (reaction without
        % annotation)
        rxnWOAnno = (intersect(rxnWOAnno,missingRxn)) ;
        
        % get number of reactions with annotation that conform with
        % database id format
        % test format
        if contains(fields(i,2),'###')
            strs = strsplit(fields{i,2},'###');
            confFormat1 = model.rxns(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), strs{1}))));
            confFormat2 = model.rxns(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), strs{2}))));
            confFormat3 = model.rxns(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), strs{3}))));
            confFormat = [confFormat1;confFormat2;confFormat3];
            
            modelProp.(strcat('AnnoRxnConf', fields{i}))= (length(confFormat))*100/(modelProp.n - length(missingRxn)); % how many have it
            
            p =  setdiff(model.rxns, missingRxn);
            NonConf = setdiff(p,confFormat);
            modelProp.Details.(strcat('AnnoRxnNonConf', fields{i})) = NonConf;
        else
            confFormat = model.(fields{i,1})(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), fields(i,2)))));
            modelProp.(strcat('AnnoRxnConf', fields{i}))= (length(confFormat))*100/(modelProp.n - length(missingRxn)); % how many have it
            p =  setdiff(model.rxns, missingRxn);
            NonConf = setdiff(p,confFormat);
            modelProp.Details.(strcat('AnnoRxnNonConf', fields{i})) = NonConf;
            
        end
    else
        modelProp.Details.(strcat('missing' ,fields{i})) = model.rxns;
        modelProp.(strcat('AnnoRxn' ,fields{i})) = 0; % how many have it
        modelProp.(strcat('AnnoRxnConf', fields{i})) = 0; % how many have it
        modelProp.Details.(strcat('AnnoRxnNonConf', fields{i})) = {};
        
    end
    %
end
% Presence of Reaction Annotation
modelProp.rxnWAnno = (modelProp.n-length(rxnWOAnno))*100/modelProp.n;
modelProp.Details.rxnWOAnno = rxnWOAnno;

% Calculate subscore
F = fieldnames(modelProp);
FAnnoRxn = F(contains(F,'AnnoRxn'));
modelProp.Scores.AnnotationReactions  = 0;
for i = 1 : length(FAnnoRxn)
    if isnan(modelProp.(FAnnoRxn{i}))
        modelProp.(FAnnoRxn{i}) = 0;
    end
    modelProp.Scores.AnnotationReactions = modelProp.Scores.AnnotationReactions + modelProp.(FAnnoRxn{i});
end
modelProp.Scores.AnnotationReactions = modelProp.Scores.AnnotationReactions + modelProp.rxnWAnno;
% Uniform Reaction Identifier Namespace - I do not understand what is
% tested here - hence we do not do it
modelProp.Scores.AnnotationReactions = modelProp.Scores.AnnotationReactions*100/(19*100) ;


%% ANNOTATIONS - GENE
% Presence of Gene Annotation = find any model.gene that is empty
missingGeneAnno = model.genes(cellfun('isempty', model.genes));
modelProp.geneWAnno = (length(model.genes)-length(missingGeneAnno))*100/length(model.genes);
modelProp.Details.geneWOAnno = missingGeneAnno;

fields = {
    'geneRefSeqID' '^((AC|AP|NC|NG|NM|NP|NR|NT|###NW|XM|XP|XR|YP|ZP)_\d+|###(NZ\_[A-Z]{4}\d+))(\.\d+)?$'
    'geneUniprotID' '^([A-N,R-Z][0-9]([A-Z][A-Z, 0-9]###[A-Z, 0-9][0-9]){1,2})|([O,P,Q]###[0-9][A-Z, 0-9][A-Z, 0-9][A-Z, 0-9]###[0-9])(\.\d+)?$'
    'geneEcoGeneID'    '^EG\d+$'
    'geneKEGGID' '^\w+:[\w\d\.-]*$'
    'geneHPRDID' '^\d+$'
    'geneASAPID' '^[A-Za-z0-9-]+$'
    'geneCCDSID' '^CCDS\d+\.\d+$'
    'geneEntrezID' '^\d+$'%ncbigene
    'geneNCBIProteinID' '^(\w+\d+(\.\d+)?)|(NP_\d+)$'
    %        ("ncbigi", re.compile(r"^(GI|gi)\:\d+$")),
    };
for i = 1 : size(fields)
    if isfield(model,fields{i,1})
        missingGene = model.genes(cellfun('isempty', model.(fields{i,1})));
        
        modelProp.Details.(strcat('missing', fields{i})) = missingGene;
        modelProp.(strcat('AnnoGene', fields{i}))= (length(model.genes) - length(missingGene))*100/length(model.genes); % how many have it
        % remove rxn from variable geneWOAnno (reaction without
        % annotation)
        
        % get number of reactions with annotation that conform with
        % database id format
        % test format
        if contains(fields(i,2),'###')
            strs = strsplit(fields{i,2},'###');
            if length(str) == 3
                confFormat1 = model.(fields{i,1})(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), strs{1}))));
                confFormat2 = model.(fields{i,1})(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), strs{2}))));
                confFormat3 = model.(fields{i,1})(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), strs{3}))));
                confFormat = [confFormat1;confFormat2;confFormat3];
            elseif length(str) ==4
                confFormat1 = model.(fields{i,1})(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), strs{1}))));
                confFormat2 = model.(fields{i,1})(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), strs{2}))));
                confFormat3 = model.(fields{i,1})(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), strs{3}))));
                confFormat4 = model.(fields{i,1})(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), strs{4}))));
                confFormat = [confFormat1;confFormat2;confFormat3;confFormat4];
            end
            modelProp.(strcat('AnnoGeneConf', fields{i}))= (length(confFormat))*100/(length(model.genes) - length(missingGene)); % how many have it
            
            p =  setdiff(model.genes, missingGene);
            NonConf = setdiff(p,confFormat);
            modelProp.Details.(strcat('AnnoGeneNonConf', fields{i})) = NonConf;
        else
            confFormat = model.(fields{i,1})(find(cellfun(@(x)~isempty(x),regexp(model.(fields{i,1}), fields(i,2)))));
            modelProp.(strcat('AnnoGeneConf', fields{i}))= (length(confFormat))*100/(length(model.genes) - length(missingGene)); % how many have it
            
            p =  setdiff(model.genes, missingGene);
            NonConf = setdiff(p,confFormat);
            modelProp.Details.(strcat('AnnoGeneNonConf', fields{i})) = NonConf;
        end
    else
        modelProp.Details.(strcat('missing' ,fields{i})) = model.genes;
        modelProp.(strcat('AnnoGene' ,fields{i})) = 0; % how many have it
        modelProp.(strcat('AnnoGeneConf', fields{i})) = 0; % how many have it
        modelProp.Details.(strcat('AnnoGeneNonConf', fields{i})) = {};
    end
    %
end

% Calculate subscore
F = fieldnames(modelProp);
FAnnoGene = F(contains(F,'AnnoGene'));
modelProp.Scores.AnnotationGenes  = 0;
for i = 1 : length(FAnnoGene)
    if isnan(modelProp.(FAnnoGene{i}))
        modelProp.(FAnnoGene{i}) = 0;
    end
    modelProp.Scores.AnnotationGenes = modelProp.Scores.AnnotationGenes + modelProp.(FAnnoGene{i});
end
modelProp.Scores.AnnotationGenes = modelProp.Scores.AnnotationGenes + modelProp.geneWAnno;
% Uniform Metabolite Identifier Namespace - I do not understand what is
% tested here - hence we do not do it
modelProp.Scores.AnnotationGenes = modelProp.Scores.AnnotationGenes*100/(19*100) ;


%% Annotation - SBO Terms
% metabolites without any SBO term
if ~isfield(model,'metSBOTerms')
    modelProp.metWSBO = 0;
    modelProp.Details.metWOSBO = model.mets;
    modelProp.('AnnoMetSBO0000247')= 0;
else
    missingMetSBOAnno = model.mets(cellfun('isempty', model.metSBOTerms));
    modelProp.metWSBO = (modelProp.m-length(missingMetSBOAnno))*100/modelProp.m;
    modelProp.Details.metWOSBO = missingMetSBOAnno;
    % metabolites without SBO:0000247 represents the term 'simple chemical'.
    confFormat = model.metSBOTerms(find(cellfun(@(x)~isempty(x),regexp(model.metSBOTerms, 'SBO:0000247'))));
    modelProp.('AnnoMetSBO0000247')= (length(confFormat))*100/(modelProp.m - length(missingMetSBOAnno)); % how many have it
end

clear confFormat;
% reactions without any SBO term
if ~isfield(model,'rxnSBOTerms')
    modelProp.rxnWSBO = 0;
    modelProp.Details.rxnWOSBO = model.rxns;
    % Metabolic Reaction SBO:0000176 Presence
    modelProp.('AnnoRxnSBO0000176')= 0;
    modelProp.('AnnoRxnSBO0000185') =0;
    modelProp.('AnnoRxnSBO0000627') =0;
    modelProp.('AnnoRxnSBO0000628') =0;
    modelProp.('AnnoRxnSBO0000632') =0;
    modelProp.('AnnoRxnSBO0000629') =0;
else
    missingRxnSBOAnno = model.rxns(cellfun('isempty', model.rxnSBOTerms));
    modelProp.rxnWSBO = (modelProp.n-length(missingRxnSBOAnno))*100/modelProp.n;
    modelProp.Details.rxnWOSBO = missingRxnSBOAnno;
    % Metabolic Reaction SBO:0000176 Presence
    confFormat = model.rxnSBOTerms(find(cellfun(@(x)~isempty(x),regexp(model.rxnSBOTerms, 'SBO:0000176'))));
    modelProp.('AnnoRxnSBO0000176')= (length(confFormat))*100/(modelProp.MetabolicRxns); % how many have it
    % Transport Reaction SBO:0000185 Presence
    confFormat = model.rxnSBOTerms(find(cellfun(@(x)~isempty(x),regexp(model.rxnSBOTerms, 'SBO:0000185'))));
    modelProp.('AnnoRxnSBO0000185')= (length(confFormat))*100/(modelProp.TransportRxns); % how many have it
    % Exchange Reaction SBO:0000627 Presence
    confFormat = model.rxnSBOTerms(find(cellfun(@(x)~isempty(x),regexp(model.rxnSBOTerms, 'SBO:0000627'))));
    modelProp.('AnnoRxnSBO0000627')= (length(confFormat))*100/(modelProp.ExchangeRxns); % how many have it
    % Demand Reaction SBO:0000628 Presence
    confFormat = model.rxnSBOTerms(find(cellfun(@(x)~isempty(x),regexp(model.rxnSBOTerms, 'SBO:0000628'))));
    modelProp.('AnnoRxnSBO0000628')= (length(confFormat))*100/(modelProp.DemandRxns); % how many have it
    %Sink Reactions SBO:0000632 Presence
    confFormat = model.rxnSBOTerms(find(cellfun(@(x)~isempty(x),regexp(model.rxnSBOTerms, 'SBO:0000632'))));
    modelProp.('AnnoRxnSBO0000632')= (length(confFormat))*100/(modelProp.SinkRxns); % how many have it
    % Biomass Reactions SBO:0000629 Presence
    confFormat = model.rxnSBOTerms(find(cellfun(@(x)~isempty(x),regexp(model.rxnSBOTerms, 'SBO:0000629'))));
    modelProp.('AnnoRxnSBO0000629')= (length(confFormat))*100/(modelProp.BiomassRxns); % how many have it
end

% genes without any SBO term
%SBO:0000243 represents the term 'gene'.
if ~isfield(model,'geneSBOTerms')
    modelProp.geneWSBO = 0;
    modelProp.Details.geneWOSBO = model.genes;
    modelProp.('AnnoGeneSBO0000243')= 0;
else
    missingGeneSBOAnno = model.genes(cellfun('isempty', model.geneSBOTerms));
    modelProp.geneWSBO = (length(model.genes)-length(missingMetSBOAnno))*100/length(model.genes);
    modelProp.Details.geneWOSBO = missingGeneSBOAnno;
    % genes without SBO:0000243 represents the term 'gene'.
    confFormat = model.geneSBOTerms(find(cellfun(@(x)~isempty(x),regexp(model.geneSBOTerms, 'SBO:0000243'))));
    modelProp.('AnnoGeneSBO0000243')= (length(confFormat))*100/(length(model.genes) - length(missingGeneSBOAnno)); % how many have it
end
% calculate subscore
F = fieldnames(modelProp);
FAnnoSBO = F(contains(F,'SBO'));
modelProp.Scores.AnnotationSBO = 0;
for i = 1 : length(FAnnoSBO)
    if isnan(modelProp.(FAnnoSBO{i}))
        modelProp.(FAnnoSBO{i}) = 0;
    end
    modelProp.Scores.AnnotationSBO = modelProp.Scores.AnnotationSBO + modelProp.(FAnnoSBO{i});
end

modelProp.Scores.AnnotationSBO = modelProp.Scores.AnnotationSBO*100/(11*100) ;

modelProp.Scores.Overall = (3* modelProp.Scores.Consistency + modelProp.Scores.AnnotationMetabolites + modelProp.Scores.AnnotationReactions + ...
    modelProp.Scores.AnnotationGenes +  2* modelProp.Scores.AnnotationSBO)*100/(3*100 + 100 +100 +100 + 2*100);
ScoresOverall = modelProp.Scores.Overall;