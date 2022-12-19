function [dummyModel, coreRxnAbbr] = createDummyModel(model, activeEntrezGeneID, TolMaxBoundary, tissueSpecificSolver, coreRxnAbbr, fluxEpsilon)
% Add one dummy metabolite per active gene and for each reaction that has that
% active gene in the GPR, create a dummy metabolite, which is destroyed in the
% corresponding dummy reaction. This enables one to require that at least
% one reaction corresponding to a gene is active, rather than all genes
%
% INPUT:
% model:             	COBRA model with various fields, including:
% model.S:              m x n stoichiometric matrix
%
% activeEntrezGeneID:   k x 1 cell array of EntrezGeneID's, each in the format of model.genes{i}
%
% OPTIONAL INPUT:
% TolMaxBoundary:       scalar number giving the default reaction upper and lower bounds magnitude
% tissueSpecificSolver: {('thermoKernel'),'fastCore'} if 'fastCore' it runs a flux consistency check first
% fluxEpsilon:         Minimum non-zero flux value accepted for tolerance (Default: Primal feasibility tolerance X 10).
%
% OUTPUT:
% dummyModel:                COBRA model with dummy metabolites or reactions
% dummyModel.dummyMetBool:  m x 1 boolean vector indicating dummy metabolites i.e. contains(model.mets,'dummy_Met_');
% dummyModel.dummyRxnBool:  n x 1 boolean vector indicating dummy reactions  i.e. contains(model.rxns,'dummy_Rxn_');

% Ines Thiele & Ronan Fleming

if ~exist('TolMaxBoundary','var')
    TolMaxBoundary = max(model.ub);
end

if ~exist('tissueSpecificSolver','var')
    tissueSpecificSolver = 'thermoKernel';
end
if ~exist('coreRxnAbbr','var') && isequal(tissueSpecificSolver, 'fastCore')
    error('coreRxnAbbr must be provided')
end
if ~exist('fluxEpsilon','var')
    fluxEpsilon = getCobraSolverParams('LP', 'feasTol') * 10;
end


if isequal(tissueSpecificSolver, 'fastCore') && 0
    paramConsistency.epsilon = fluxEpsilon;
    paramConsistency.method = 'fastcc';
    [fluxConsistentMetBoolOrig, fluxConsistentRxnBoolOrig] = findFluxConsistentSubset(model, paramConsistency, 2);
    if any(~fluxConsistentMetBoolOrig) || any(~fluxConsistentRxnBoolOrig)
        warning('%6u\t%6u\t%s\n', nnz(~fluxConsistentMetBoolOrig), nnz(~fluxConsistentRxnBoolOrig),' flux inconsistent metabolites and reactions in input model.')
    end
end

%any zero rows or columns are considered inconsistent
zeroRowBool =~ any(model.S, 2);
zeroColBool =~ any(model.S, 1)';
if any(zeroRowBool) || any(zeroColBool)
    error('%6u\t%6u\t%s\n', nnz(zeroRowBool), nnz(zeroColBool), ' zero rows and columns in model.S of dummy model.')
end

[nMet,nRxn] = size(model.S);

%need to reverse the direction of the dummy coefficient for reverse
%reactions
rev = ones(1, nRxn);
rev(1, model.lb < 0 & model.ub <= 0) = -1;

% create a dummy reaction for each active gene in model
nGenes = length(model.genes);
for j = 1:nGenes
    boolGene = strcmp(model.genes{j},activeEntrezGeneID);
    if any(boolGene)
        boolRxn = model.rxnGeneMat(:,j)~=0;
        if any(boolRxn)
            %dummy metabolite
            dummyMet = strcat('dummy_Met_',model.genes{j});
            % dummy reaction
            dummyRxn = strcat('dummy_Rxn_',model.genes{j});
            
            %checking in case a dummy metabolite has already been created for this gene
            row = find(ismember(model.mets,dummyMet));
            
            if isempty(row)
                row = length(model.mets)+1;
            end
            %checking in case a dummy reaction has already been created for this gene
            col = find(ismember(model.rxns,dummyRxn));
            if isempty(col)
                col = length(model.rxns)+1;
            end
            
            if isfield(model, 'mets')
                model.mets{row} = dummyMet;
            end
            if isfield(model, 'S')
                model.S(row,boolRxn) = 1;
            end
            if isfield(model, 'S')
                model.S(row,col) = -1;
            end
            %flip sign of coefficient if it is a reverse reaction
            model.S(row,1:nRxn) = model.S(row,1:nRxn).*rev;
            
            if isfield(model, 'b')
                model.b(row)=0;
            end
            if isfield(model, 'csense')
                model.csense(row)='E';
            end
            if isfield(model,'SIntMetBool')
                model.SIntMetBool(row) = 0;
            end
            if isfield(model,'SIntRxnBool')
                model.SIntRxnBool(col) = 0;
            end
            if isfield(model,'SConsistentMetBool')
                model.SConsistentMetBool(row) = 0;
            end
            if isfield(model,'SConsistentRxnBool')
                model.SConsistentRxnBool(col) = 0;
            end
            if isfield(model,'fluxConsistentMetBool')
                model.fluxConsistentMetBool(row) = 1;
            end
            if isfield(model,'fluxConsistentRxnBool')
                model.fluxConsistentRxnBool(col) = 1;
            end
            if isfield(model,'thermoFluxConsistentMetBool')
                model.thermoFluxConsistentMetBool(row) = 1;
            end
            if isfield(model,'thermoFluxConsistentRxnBool')
                model.thermoFluxConsistentRxnBool(col) = 1;
            end
            if isfield(model, 'rxns')
                model.rxns{col} = dummyRxn;
            end
            if isfield(model, 'lb')
                model.lb(col)=-TolMaxBoundary;
            end
            if isfield(model, 'ub')
                model.ub(col)=TolMaxBoundary;
            end
            if isfield(model, 'c')
                model.c(col)=0;
            end
            if isfield(model, 'rxnGeneMat')
                model.rxnGeneMat(col,:)=0;
            end
            if isfield(model, 'rules')
                model.rules{col}='';
            end
            if isfield(model, 'rxnNames')
                model.rxnNames{col}=model.rxns{col};
            end
            if isfield(model,'subSystems')
                model.subSystems{col}= 'Dummy';
            end
            
            % 20190228 Aga: csense and C were not updated, causes verifyModel() to fail in fastcc()
            if isfield(model, 'ctrs')
                model.C(length(model.ctrs),col) = sparse(1,1);
            end
            
            
            %         if isfield(model, 'metNames')
            %             model.metNames(row)=dummyMet;
            %         end
            %         if isfield(model, 'metFormulas')
            %             model.metFormulas(row)={'N'};
            %         end
            %         if isfield(model, 'metCharge')
            %             model.metCharge(row)=0;
            %         end
            %         if isfield(model, 'metCHEBIID')
            %             model.metCHEBIID(row)={'N'};
            %         end
            %         if isfield(model, 'metInchiString')
            %             model.metInchiString(row)={'M'};
            %         end
            %         if isfield(model, 'metKeggID')
            %             model.metKeggID(row)={'M'};
            %         end
            %         if isfield(model, 'metPubChemID')
            %             model.metPubChemID(row)={'M'};
            %         end
            %         if isfield(model, 'metCharges')
            %             model.metCharges(row)=0;
            %         end
            %         if isfield(model, 'metSmiles')
            %             model.metSmiles(row)={'M'};
            %         end
            %         if isfield(model, 'metHMDBID')
            %             model.metHMDBID(row)={'M'};
            %         end
            %         if isfield(model, 'metInChIString')
            %             model.metInChIString(row)={'M'};
            %         end
            %         if isfield(model, 'metKEGGID')
            %             model.metKEGGID(row)={'M'};
            %         end
            %         if isfield(model, 'metPdMap')
            %             model.metPdMap(row) = {''};
            %         end
            %         if isfield(model, 'grRules')
            %             model.grRules(col)={''};
            %         end
            %         % confidence score change to admit double instead of cell
            %         % (j.modamio 15.12.2017)model.rxnConfidenceScores(col)={'1'}
            %         if isfield(model, 'subSystems')
            %             model.subSystems(col)={'Dummy_Rxn'};
            %         end
            
            %         if isfield(model, 'rxnNotes')
            %             model.rxnNotes(col)={''};
            %         end
            %         if isfield(model, 'rxnReferences')
            %             model.rxnReferences(col)={''};
            %         end
            %         if isfield(model, 'rxnECNumbers')
            %             model.rxnECNumbers(col)={''};
            %         end
            %         if isfield(model, 'rxnConfidenceScores')
            %             model.rxnConfidenceScores(col)='1';
            %         end
            %         if isfield(model, 'rxnKeggID')
            %             model.rxnKeggID(col)={''};
            %         end
            %         if isfield(model, 'rxnConfidenceEcoIDA')
            %             model.rxnConfidenceEcoIDA(col)={''};
            %         end
            %         if isfield(model, 'rxnsboTerm')
            %             model.rxnsboTerm(col)={''};
            %         end
            %         if isfield(model, 'rxnKEGGID')
            %             model.rxnKEGGID(col)={''};
            %         end
            
            %         if isfield(model, 'rxnCOG')
            %             model.rxnCOG(col) = {''};
            %         end
            %         if isfield(model, 'rxnKeggOrthology')
            %             model.rxnKeggOrthology(col) = {''};
            %         end
            %         if isfield(model, 'rxnReconMap')
            %             model.rxnReconMap(col) = {''};
            %         end
            %         if isfield(model, 'constraintDescription')
            %             model.constraintDescription(col) = {''};
            %         end
        end
    end
end
model.dummyMetBool = contains(model.mets,'dummy_Met_');
model.dummyRxnBool = contains(model.rxns,'dummy_Rxn_');
    
if 0 && isequal(tissueSpecificSolver, 'fastCore') 
    model.S = model.S(~model.dummyMetBool,~model.dummyRxnBool);
    model.b = model.b(~model.dummyMetBool,1);
    model.csense = model.csense(~model.dummyMetBool,1);
    model.mets = model.mets(~model.dummyMetBool);
    model.rxns = model.rxns(~model.dummyRxnBool);
    model.rxnNames = model.rxnNames(~model.dummyRxnBool);
    model.lb = model.lb(~model.dummyRxnBool);
    model.ub = model.ub(~model.dummyRxnBool);
    model.c = model.c(~model.dummyRxnBool);
    if isfield(model, 'ctrs')
        model.C = model.C(:,~model.dummyRxnBool);
    end
    if isfield(model, 'rxnGeneMat')
        model.rxnGeneMat = model.rxnGeneMat(~model.dummyRxnBool,:);
    end
    if isfield(model, 'rules')
        model.rules = model.rules(~model.dummyRxnBool);
    end
    if isfield(model,'subSystems')
        model.subSystems = model.subSystems(~model.dummyRxnBool);
    end
    if isfield(model,'SIntRxnBool')
        model.SIntRxnBool = model.SIntRxnBool(~model.dummyRxnBool);
    end
    if isfield(model,'SConsistentRxnBool')
        model.SConsistentRxnBool = model.SConsistentRxnBool(~model.dummyRxnBool);
    end
    if isfield(model,'SConsistentMetBool')
        model.SConsistentMetBool = model.SConsistentMetBool(~model.dummyMetBool);
    end
    if isfield(model,'fluxConsistentRxnBool')
        model.fluxConsistentRxnBool = model.fluxConsistentRxnBool(~model.dummyRxnBool);
    end
    if isfield(model,'thermoFluxConsistentRxnBool')
        model.thermoFluxConsistentRxnBool = model.thermoFluxConsistentRxnBool(~model.dummyRxnBool);
    end
    
    [fluxConsistentMetBool0, fluxConsistentRxnBool0] = findFluxConsistentSubset(model, paramConsistency,2);
    
    if 0
        %check if coupling constraints interfere
        modelnoC = rmfield(model,'C');
        modelnoC = rmfield(modelnoC,'d');
        [fluxConsistentMetBool2, fluxConsistentRxnBool2] = findFluxConsistentSubset(modelnoC, paramConsistency, 2);
    end
    model.dummyMetBool = contains(model.mets,'dummy_Met_');
    model.dummyRxnBool = contains(model.rxns,'dummy_Rxn_');
end

% Any zero rows or columns are considered inconsistent
zeroRowBool =~ any(model.S, 2);
zeroColBool =~ any(model.S, 1)';
if any(zeroRowBool) || any(zeroColBool)
    error('%6u\t%6u\t%s\n', nnz(zeroRowBool), nnz(zeroColBool), ' zero rows and columns in model.S of dummy model.')
end

if isfield(model, 'g0')
    model = rmfield(model, 'g0');
end
if isfield(model,'h0')
    model = rmfield(model,'h0');
end

if isequal(tissueSpecificSolver, 'fastCore')
    %need to add dummy reactions to set of core reactions for fastCore. Note thermoKernel does it differently, see modelExtraction
    coreRxnAbbr = [coreRxnAbbr; model.rxns(model.dummyRxnBool)];
    
    %TODO debug why this is so
    %addition of dummy reactions can cause flux inconsistency (e.g.
    %{'dummy_Rxns_471', 'dummy_Rxn_1734'})
    paramConsistency.epsilon = fluxEpsilon;
    paramConsistency.method = 'fastcc';
    [fluxConsistentMetBool, fluxConsistentRxnBool] = findFluxConsistentSubset(model, paramConsistency);
    
    
    %any zero rows or columns are considered inconsistent
    zeroRowBool=~any(model.S,2);
    zeroColBool=~any(model.S,1)';
    if any(zeroRowBool) || any(zeroColBool)
        fprintf('%6u\t%6u\t%s\n',nnz(zeroRowBool),nnz(zeroColBool),' zero rows and columns in model.S of dummy model:')
        disp(model.mets(zeroRowBool))
        disp(model.rxns(zeroColBool))
    end
    
    fluxConsistentMetBool = fluxConsistentMetBool & ~zeroRowBool;
    fluxConsistentRxnBool = fluxConsistentRxnBool & ~zeroColBool;
    
    %assume all non dummy reactions are flux consistent
    if any(~fluxConsistentRxnBool & ~model.dummyRxnBool)
        fprintf('%s\n',[int2str(nnz(~fluxConsistentRxnBool & ~model.dummyRxnBool)) ' flux inconsistent reaction(s) after dummy model creation, NOT removed:'])
        disp(model.rxns(~fluxConsistentRxnBool & ~model.dummyRxnBool))
        fluxConsistentRxnBool(~fluxConsistentRxnBool & ~model.dummyRxnBool) = 1;
    end
    
    if any(~fluxConsistentMetBool) || any(~fluxConsistentRxnBool)
        
        fluxInConsistentRxn = model.rxns(~fluxConsistentRxnBool);
        fprintf('%s\n',[int2str(nnz(~fluxConsistentRxnBool)) ' flux inconsistent reaction(s) after dummy model creation, removed:'])
        disp(model.rxns(~fluxConsistentRxnBool))
        
        model.S = model.S(fluxConsistentMetBool,fluxConsistentRxnBool);
        model.b = model.b(fluxConsistentMetBool,1);
        model.csense = model.csense(fluxConsistentMetBool,1);
        model.rxns = model.rxns(fluxConsistentRxnBool);
        model.rxnNames = model.rxnNames(fluxConsistentRxnBool);
        model.lb = model.lb(fluxConsistentRxnBool);
        model.ub = model.ub(fluxConsistentRxnBool);
        model.c = model.c(fluxConsistentRxnBool);
        if isfield(model, 'ctrs')
            model.C = model.C(:,fluxConsistentRxnBool);
        end
        if isfield(model, 'rxnGeneMat')
            model.rxnGeneMat = model.rxnGeneMat(fluxConsistentRxnBool,:);
        end
        if isfield(model, 'rules')
            model.rules = model.rules(fluxConsistentRxnBool);
        end
        if isfield(model,'subSystems')
            model.subSystems = model.subSystems(fluxConsistentRxnBool);
        end
        if isfield(model,'SIntRxnBool')
            model.SIntRxnBool = model.SIntRxnBool(fluxConsistentRxnBool);
        end
        if isfield(model,'SConsistentRxnBool')
            model.SConsistentRxnBool = model.SConsistentRxnBool(fluxConsistentRxnBool);
        end
        if isfield(model,'fluxConsistentRxnBool')
            model.fluxConsistentRxnBool = model.fluxConsistentRxnBool(fluxConsistentRxnBool);
        end
        if isfield(model,'thermoFluxConsistentRxnBool')
            model.thermoFluxConsistentRxnBool = model.thermoFluxConsistentRxnBool(fluxConsistentRxnBool);
        end
        
        %remove the flux inconsistent reactions from the core reaction set
        coreRxnAbbr = setdiff(coreRxnAbbr,fluxInConsistentRxn);
        
%         %hack - TODO debug why this is so
%         if any(strcmp('dummy_Rxns_471',fluxInConsistentRxn))
%             coreRxnAbbr= [coreRxnAbbr; {'AICART'; 'IMPC'}];
%         end
    end
    

end

model.dummyMetBool = contains(model.mets,'dummy_Met_');
model.dummyRxnBool = contains(model.rxns,'dummy_Rxn_');

dummyModel = model;
