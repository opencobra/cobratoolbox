function [SConsistentMetBool,SConsistentRxnBool,SInConsistentMetBool,SInConsistentRxnBool,unknownSConsistencyMetBool,unknownSConsistencyRxnBool,model]=...
    findStoichConsistentSubset(model,massBalanceCheck,printLevel,fileName,epsilon)
%finds the subset of S that is stoichiometrically consistent using
%an iterative cardinality optimisation approach
%
%INPUT
% model
%    .S             m x n stoichiometric matrix
%
%OPTIONAL INPUT
% massBalanceCheck  {(0),1}
%                   0 = heuristic detection of exchange reactions (using
%                   findSExRxnInd) will be use to warm start algorithmic
%                   part
%                   1 = reactions that seem mass imbalanced will be used to
%                   warm start the algorithmic steps to find the
%                   stoichiometrically consistent part.
%                   model.metFormulas must exist for mass balance check
% printLevel
% fileName          char, used when writing inconsistent metabolites and
%                   reactions to a file
% epsilon           (feasTol*100) min nonzero mass, 1/epsilon = max mass
%
%OUTPUT
% SConsistentMetBool            m x 1 boolean vector indicating consistent mets
% SConsistentRxnBool            n x 1 boolean vector indicating consistent rxns
% SInConsistentMetBool          m x 1 boolean vector indicating inconsistent mets
% SInConsistentRxnBool          n x 1 boolean vector indicating inconsistent rxns
% unknownSConsistencyMetBool    m x 1 boolean vector indicating unknown consistent mets (all zeros when algorithm converged perfectly!)
% unknownSConsistencyRxnBool    n x 1 boolean vector indicating unknown consistent rxns (all zeros when algorithm converged perfectly!)
% model
%   .SConsistentMetBool            m x 1 boolean vector indicating consistent mets
%   .SConsistentRxnBool            n x 1 boolean vector indicating consistent rxns
%   .SInConsistentMetBool          m x 1 boolean vector indicating inconsistent mets
%   .SInConsistentRxnBool          n x 1 boolean vector indicating inconsistent rxns
%   .unknownSConsistencyMetBool    m x 1 boolean vector indicating unknown consistent mets (all zeros when algorithm converged perfectly!)
%   .unknownSConsistencyRxnBool    n x 1 boolean vector indicating unknown consistent rxns (all zeros when algorithm converged perfectly!)
%   .SIntMetBool                   m x 1 boolean of metabolites heuristically though to be involved in mass balanced reactions
%   .SIntRxnBool                   n x 1 boolean of reactions heuristically though to be mass balanced
% Ronan Fleming 2016


if ~exist('printLevel','var')
    printLevel=1;
end

if ~exist('massBalanceCheck','var')
    massBalanceCheck=0;
end

%set parameters according to feastol
feasTol = getCobraSolverParams('LP', 'feasTol');

if ~exist('epsilon','var')
    epsilon=1e-4;
end

%final double check of stoichiometric consistent subset
finalCheckMethod='findMassLeaksAndSiphons'; %works with smaller leakParams.epsilon
%finalCheckMethod='maxCardinalityConservationVector'; %Needs leakParams.epsilon=1e-4;

removalStrategy='imBalanced';
%removalStrategy='isolatedInconsistent';
removalStrategy='highCardinalityReactions';

minCardRelaxParams.epsilon=epsilon;
minCardRelaxParams.eta=feasTol*100;

maxCardinalityConsParams.epsilon=epsilon;%1/epsilon is the largest mass considered, needed for numerical stability
maxCardinalityConsParams.method = 'quasiConcave';%seems to work the best, but sometimes infeasible
%maxCardinalityConsParams.method = 'dc';%seems to work, but not always the best
maxCardinalityConsParams.theta = 0.5;
maxCardinalityConsParams.eta=feasTol*100;

leakParams.epsilon=epsilon;
%leakParams.method='quasiConcave'; %seems to have problems need to debug
leakParams.method='dc';
%leakParams.eta=feasTol*100;
leakParams.eta=feasTol*100;
leakParams.theta = 0.5;

%do leak test after each step to make sure that we are working correctly
doubleCheckConsistency=1;  %leak/siphon test, turn on when debugging a model
tripleCheckConsistencey=0; %max card conservation vector, needs debugging

%show the relaxation from stoichiometric consistency relative to the cutoff
%at each iteration. Useful for debugging if numerical issues are suspected
followProgressOfEliminationRelativeToCutoff=0;

%decide whether or not to use the bounds on the model
modelBoundsFlag=0;

%%%%%%%%%%%%%
[nMet,nRxn]=size(model.S);
if printLevel>1
    fprintf('%s\n','-------')
    fprintf('%6s\t%6s\n','#mets','#rxns')
    fprintf('%6u\t%6u\t%s\n',nMet,nRxn,' totals.')
    fprintf('%s\n','-------')
end
%%
%heuristically identify exchange reactions and metabolites exclusively
%involved in exchange reactions
if ~isfield(model,'SIntRxnBool')  || ~isfield(model,'SIntMetBool')
    %finds the reactions in the model which export/import from the model
    %boundary i.e. mass unbalanced reactions
    %e.g. Exchange reactions
    %     Demand reactions
    %     Sink reactions
    model = findSExRxnInd(model,[],printLevel-1);
end

if printLevel>1
    fprintf('%6u\t%6u\t%s\n',nnz(~model.SIntMetBool),nnz(~model.SIntRxnBool),' heuristically exchange.')
end
if printLevel>1
    fprintf('%6u\t%6u\t%s\n',nnz(model.SIntMetBool),nnz(model.SIntRxnBool),' heuristically non-exchange.')
end

if massBalanceCheck
    if ~isfield(model,'balancedMetBool') || ~isfield(model,'balancedRxnBool')
        printLevelcheckMassChargeBalance=0;  % -1; % print problem reactions to a file

        if exist('fileName','var')
            fileNameBase=[fileName datestr(now,30) '_'];
            %mass and charge balance can be checked by looking at formulas
            if isfield(model,'metFormulas')
                [massImbalance,imBalancedMass,imBalancedCharge,imBalancedRxnBool,Elements,missingFormulaeBool,balancedMetBool]...
                    = checkMassChargeBalance(model,printLevelcheckMassChargeBalance,fileNameBase);
                model.balancedRxnBool=~imBalancedRxnBool;
                model.balancedMetBool=balancedMetBool;

                model.Elements=Elements;
                model.missingFormulaeBool=missingFormulaeBool;
            else
                error('No model.metFormulas');
            end
        else
            if isfield(model,'metFormulas')
                [massImbalance,imBalancedMass,imBalancedCharge,imBalancedRxnBool,Elements,missingFormulaeBool,balancedMetBool]...
                    = checkMassChargeBalance(model,printLevelcheckMassChargeBalance);
                model.balancedRxnBool=~imBalancedRxnBool;
                model.balancedMetBool=balancedMetBool;
                model.Elements=Elements;
                model.missingFormulaeBool=missingFormulaeBool;
            else
                error('No model.metFormulas');
            end
        end
    end

    %% minimum cardinality of conservation relaxation vector
    [relaxRxnBool,solutionRelax] = minCardinalityConservationRelaxationVector(model.S(:,model.balancedRxnBool),minCardRelaxParams,printLevel-1);
    minConservationNonRelaxRxnBool=false(nRxn,1);
    minConservationNonRelaxRxnBool(model.balancedRxnBool)=~relaxRxnBool;
    minConservationNonRelaxMetBool = getCorrespondingRows(model.S,true(nMet,1),minConservationNonRelaxRxnBool,'exclusive');

    %keeps the mass balanced reactions as part of the non-relaxed reaction
    %set when testing for the minimal number of relaxed reactions
    % if nnz(model.balancedRxnBool)==nnz(minConservationNonRelaxRxnBool)
    %     minCardRelaxParams.nonRelaxBool=model.balancedRxnBool;
    % end

    % %check to see if the mass balanced part is leaking
    % [leakMetBool,leakRxnBool,siphonMetBool,siphonRxnBool,statpRelax,statnRelax]= findMassLeaksAndSiphons(model,model.balancedMetBool,model.balancedRxnBool,modelBoundsFlag,leakParams,printLevel-2);
    % leakSiphonMetBool=leakMetBool | siphonMetBool;
    % if any(leakMetBool | siphonMetBool)
    %     %omit leaking metabolites
    %     minConservationNonRelaxMetBool(leakMetBool | siphonMetBool)=0;
    %     %columns exclusively involved in stoichiometrically consistent rows
    %     if iterateCardinalityOpt==1
    %         minConservationNonRelaxRxnBool = getCorrespondingCols(model.S,minConservationNonRelaxMetBool,model.SConsistentRxnBool | minConservationNonRelaxRxnBool,'inclusive');
    %     else
    %         minConservationNonRelaxRxnBool = getCorrespondingCols(model.S,minConservationNonRelaxMetBool,model.SConsistentRxnBool | minConservationNonRelaxRxnBool,'inclusive');
    %     end
    % end

    if printLevel>1
        fprintf('%6u\t%6u\t%s\n',nnz(model.balancedMetBool),nnz(model.balancedRxnBool),' seemingly elementally balanced.')
        fprintf('%6u\t%6u\t%s\n',nnz(minConservationNonRelaxMetBool),nnz(minConservationNonRelaxRxnBool),' seemingly elementally balanced and stoichiometrically consistent.')
        fprintf('%6u\t%6u\t%s\n',nnz(~model.balancedMetBool),nnz(~model.balancedRxnBool),' seemingly elementally imbalanced.')
        fprintf('%s\n','-------')
        fprintf('%6u\t%6u\t%s\n',nnz(model.balancedMetBool & model.SIntMetBool),nnz(model.balancedRxnBool & model.SIntRxnBool),' heuristically non-exchange and seemingly elementally balanced.')
        fprintf('%6u\t%6u\t%s\n',nnz(minConservationNonRelaxMetBool  & model.SIntMetBool),nnz(minConservationNonRelaxRxnBool & model.SIntRxnBool),' seemingly elementally balanced and stoichiometrically consistent.')
        fprintf('%6u\t%6u\t%s\n',nnz(~model.balancedMetBool & model.SIntMetBool),nnz(~model.balancedRxnBool & model.SIntRxnBool),' heuristically non-exchange and seemingly elementally imbalanced.')
    end
end

% assumes that all mass imbalanced reactions are exchange reactions
% model.SIntMetBool = model.SIntMetBool & model.balancedMetBool;
% model.SIntRxnBool = model.SIntRxnBool & model.balancedRxnBool;

%%
%iteratively try to identify largest consistent subset of metabolites and reactions

%heuristically identified exchange reactions and metabolites
model.SInConsistentMetBool = ~model.SIntMetBool;% metabolites involved in exchange reactions
model.SInConsistentRxnBool = ~model.SIntRxnBool;

% dont provide any starting information
% model.SInConsistentMetBool=false(nMet,1);
% model.SInConsistentRxnBool=false(nRxn,1);

%any zero rows or columns are considered inconsistent
zeroRowBool=~any(model.S,2);
zeroColBool=~any(model.S,1)';
if any(zeroRowBool) || any(zeroColBool)
     fprintf('%6u\t%6u\t%s\n',nnz(zeroRowBool),nnz(zeroColBool),' zero rows and columns set to inconsistent.')
end
model.SInConsistentMetBool = model.SInConsistentMetBool | zeroRowBool;
model.SInConsistentRxnBool = model.SInConsistentRxnBool | zeroColBool;

%initially we have no proof of any stoichiometric consistency
model.SConsistentMetBool=false(nMet,1);
model.SConsistentRxnBool=false(nRxn,1);

%isolate the part of S where we are unsure of its stoichiometric
%consistency
model.unknownSConsistencyMetBool=~model.SConsistentMetBool & ~model.SInConsistentMetBool;
model.unknownSConsistencyRxnBool=~model.SConsistentRxnBool & ~model.SInConsistentRxnBool;

%number of metabolites involved in each reaction, used to kick out
%inconsistent reactions
nMetsPerRxn=sum(model.S~=0,1)';

%start the iterative loop
lastUnkownConsistencyMetBool=inf;
lastUnkownConsistencyRxnBool=inf;
iterateCardinalityOpt=1;
if printLevel>1
    fprintf('%s\n','-------')
end
while iterateCardinalityOpt>0
    if printLevel>1
        fprintf('%s%u%s\n','Iteration #',iterateCardinalityOpt,' minimum cardinality of conservation relaxation vector.')
        fprintf('%6u\t%6u\t%s\n',nnz(model.unknownSConsistencyMetBool),nnz(model.unknownSConsistencyRxnBool),' unknown consistency.')
    end

    %decide subset to be tested during this iteration
    boolMet=model.SConsistentMetBool | model.unknownSConsistencyMetBool;
    boolRxn=model.SConsistentRxnBool | model.unknownSConsistencyRxnBool;
    if printLevel>1
        fprintf('%6u\t%6u\t%s\n',nnz(boolMet),nnz(boolRxn),' being tested.')
    end
    %compute minimum relaxation
    if nnz(model.S(boolMet,boolRxn))~=0
        %% minimum cardinality of conservation relaxation vector
        [relaxRxnBool,solutionRelax] = minCardinalityConservationRelaxationVector(model.S(boolMet,boolRxn),minCardRelaxParams,printLevel-1);
        minConservationNonRelaxRxnBool=false(nRxn,1);
        minConservationNonRelaxRxnBool(boolRxn)=~relaxRxnBool;

        %corresponding rows matching non-relaxed reactions
        minConservationNonRelaxMetBool = getCorrespondingRows(model.S,boolMet,minConservationNonRelaxRxnBool,'inclusive');
        %minConservationNonRelaxMetBool = getCorrespondingRows(model.S,boolMet,minConservationNonRelaxRxnBool,'exclusive');

        %reactions matching consistent metabolites
        %minConservationNonRelaxRxnBool = getCorrespondingCols(model.S,minConservationNonRelaxMetBool,minConservationNonRelaxRxnBool,'inclusive');

        if printLevel>1
            if nnz(minConservationNonRelaxMetBool)~=0 || nnz(minConservationNonRelaxRxnBool)~=0
                fprintf('%6u\t%6u\t%s\n',nnz(minConservationNonRelaxMetBool),nnz(minConservationNonRelaxRxnBool),' ... of which are stoichiometrically consistent by min cardinality of stoich consistency relaxation.')
            end
        end

        if doubleCheckConsistency && any(minConservationNonRelaxMetBool)
            %leakParams.method='quasiConcave';
            %check to see if the stoichiometrically consistent part is leaking
            [leakMetBool,leakRxnBool,siphonMetBool,siphonRxnBool,statpRelax,statnRelax]= findMassLeaksAndSiphons(model,minConservationNonRelaxMetBool,minConservationNonRelaxRxnBool,modelBoundsFlag,leakParams,printLevel-2);
            if any(leakMetBool | siphonMetBool)
                %omit leaking metabolites
                minConservationNonRelaxMetBool(leakMetBool | siphonMetBool)=0;
                %columns exclusively involved in stoichiometrically consistent rows
                if iterateCardinalityOpt==1
                    minConservationNonRelaxRxnBool = getCorrespondingCols(model.S,minConservationNonRelaxMetBool,model.SConsistentRxnBool | minConservationNonRelaxRxnBool,'inclusive');
                else
                    minConservationNonRelaxRxnBool = getCorrespondingCols(model.S,minConservationNonRelaxMetBool,model.SConsistentRxnBool | minConservationNonRelaxRxnBool,'inclusive');
                end
            end
            if printLevel>1
                fprintf('%6u\t%6u\t%s\n',nnz(minConservationNonRelaxMetBool),nnz(minConservationNonRelaxRxnBool),'Confirmed stoichiometrically consistent by leak/siphon testing.')
            end
        end
       if tripleCheckConsistencey && any(minConservationNonRelaxMetBool)
            [maxConservationMetBool,maxConservationRxnBool,solution]=maxCardinalityConservationVector(model.S, maxCardinalityConsParams);
             if printLevel>1
                fprintf('%6u\t%6u\t%s\n',nnz(maxConservationMetBool),nnz(maxConservationRxnBool),' ... of which are confirmed stoichiometrically consistent by maximum conservation vector testing.')
            end
        end
    else
        minConservationNonRelaxMetBool=model.SConsistentMetBool;
        minConservationNonRelaxRxnBool=model.SConsistentRxnBool;
    end

    if followProgressOfEliminationRelativeToCutoff
        %relaxation of stoichiometric consistency for reactions above the
        %threshold of leakParams.eta
        x=zeros(nRxn,1);
        x(boolRxn)=abs(solutionRelax.x);
        log10absSolutionRelax=log10(x);
        %histogram
        hist(log10absSolutionRelax(boolRxn & ~minConservationNonRelaxRxnBool),200)
        title(['relaxation of stoich. consistency for reactions above ' num2str(leakParams.eta)])
        xlabel('log_{10}(relaxation)')
        ylabel('#reactions')
        [~,sortedlog10absSolutionRelaxInd]=sort(log10absSolutionRelax,'descend');
        sortedlog10absSolutionRelaxAbbr=model.rxns(sortedlog10absSolutionRelaxInd);
        for k=1:10
            formulas = printRxnFormula(model,model.rxns(sortedlog10absSolutionRelaxInd(k)));
            if imBalancedRxnBool(sortedlog10absSolutionRelaxInd(k))
                fprintf('%s\n',imBalancedMass{sortedlog10absSolutionRelaxInd(k)});
            end
        end
    end

    %update consistent part
    model.SConsistentMetBool=minConservationNonRelaxMetBool;
    model.SConsistentRxnBool=minConservationNonRelaxRxnBool;

    %update inconsistent part
    model.SInConsistentMetBool(model.SConsistentMetBool)=0;
    model.SInConsistentRxnBool(model.SConsistentRxnBool)=0;

    %reduce unknown part
    model.unknownSConsistencyMetBool=~model.SConsistentMetBool & ~model.SInConsistentMetBool;
    model.unknownSConsistencyRxnBool=~model.SConsistentRxnBool & ~model.SInConsistentRxnBool;

    if printLevel>1
        fprintf('%6u\t%6u\t%s\n',nnz(model.unknownSConsistencyMetBool),nnz(model.unknownSConsistencyRxnBool),' ... of which are of unknown consistency.')
    end

    if nnz(model.unknownSConsistencyMetBool)==0 && nnz(model.unknownSConsistencyRxnBool)==0
        break
    else
        %stop the loop when the number is too high
        if iterateCardinalityOpt==100
            break;
        end
     end

    if nnz(model.unknownSConsistencyRxnBool)==0
        pause(eps)
    end

    metRemoveBool=0;
    rxnRemoveBool=0;

    %hack for HMR
    if ~exist('imBalancedRxnBool','var')
        removalStrategy='highCardinalityReactions';
    end
    switch removalStrategy
        case 'highCardinalityReactions'
            %%remove reactions with unknown consistency of maximal cardinality
            if any(model.unknownSConsistencyMetBool) || any(model.unknownSConsistencyRxnBool)
                nMetsPerRxnTmp=nMetsPerRxn;
                %reactions with known consistency set to zero
                nMetsPerRxnTmp(~model.unknownSConsistencyRxnBool)=0;
                %find the reaction(s) with unknown consistency involving maximum
                %number of metabolites
                maxMetsPerRxn=full(max(nMetsPerRxnTmp(model.unknownSConsistencyRxnBool)));

                if maxMetsPerRxn>=8
                    %check in case any(model.unknownSConsistencyRxnBool)==0
                    if isempty(maxMetsPerRxn)
                        maxMetsPerRxn=0;
                    end
                    %boolean reactions to be consisdered inconsistent and removed
                    rxnRemoveBool=nMetsPerRxnTmp==maxMetsPerRxn;

                    %metabolites exclusively involved in inconsistent reactions are
                    %deemed inconsistent also
                    metRemoveBool = getCorrespondingRows(model.S,true(nMet,1),rxnRemoveBool,'exclusive');

                    %extend inconsistent reaction boolean vector
                    model.SInConsistentRxnBool = model.SInConsistentRxnBool | rxnRemoveBool;
                    model.SInConsistentMetBool = model.SInConsistentMetBool | metRemoveBool;

                    %reduce unknown part
                    model.unknownSConsistencyMetBool=~model.SConsistentMetBool & ~model.SInConsistentMetBool;
                    model.unknownSConsistencyRxnBool=~model.SConsistentRxnBool & ~model.SInConsistentRxnBool;
                    if printLevel>1
                        fprintf('%6u\t%6u\t%s%u%s\n',nnz(metRemoveBool), nnz(rxnRemoveBool), ' removed heuristically non-exchange reactions, each involving ',maxMetsPerRxn, ' metabolites.')
                        if printLevel >1
                             formulas = printRxnFormula(model,model.rxns(rxnRemoveBool));
                        end
                    end
                else
                    %stop the loop when the number of metabolites in exchange
                    %reactions is too small
                    break
                end
            end
        case 'isolatedInconsistent'
            %%decide subset to be tested during this iteration
            boolRxn=model.unknownSConsistencyRxnBool;
            boolMet = getCorrespondingRows(model.S,true(nMet,1),boolRxn,'inclusive');

            if printLevel>1
                fprintf('%s\n','------')
                fprintf('%6u\t%6u\t%s\n',nnz(boolMet),nnz(boolRxn),' subset of unknown consistency being tested in isolation.')
            end
            %% minimum cardinality of conservation relaxation vector
            solutionRelax = minCardinalityConservationRelaxationVector(model.S(boolMet,boolRxn),epsilon);

            %check optimality
            if printLevel>2
                fprintf('%g%s\n',norm(solutionRelax.x + model.S(boolMet,boolRxn)'*solutionRelax.z),' = ||x + S''*z||')
                fprintf('%g%s\n',min(solutionRelax.z),' = min(z_i)')
                fprintf('%g%s\n',max(solutionRelax.z),' = min(z_i)')
                fprintf('%g%s\n',min(solutionRelax.x),' = min(x_i)')
                fprintf('%g%s\n',max(solutionRelax.x),' = max(x_i)')
            end

            minConservationNonRelaxRxnBool=false(nRxn,1);
            if solutionRelax.stat==1
                %conserved if relaxation is below epsilon
                minConservationNonRelaxRxnBool(boolRxn)=abs(solutionRelax.x)<leakParams.eta;
                if printLevel>2
                    fprintf('%g%s\n',norm(model.S(boolMet,minConservationNonRelaxRxnBool)'*solutionRelax.z),' = ||N''*z||')
                end
                minConservationRelaxRxnBool=false(nRxn,1);
                minConservationRelaxRxnBool(boolRxn)=abs(solutionRelax.x)>=leakParams.eta;
            else
                disp(solutionRelax)
                error('solve for maximal conservation vector failed')
            end
            minConservationNonRelaxMetBool = getCorrespondingRows(model.S,boolMet,minConservationNonRelaxRxnBool,'inclusive');

            if printLevel>2
                fprintf('%6u\t%6u\t%s\n',nnz(minConservationNonRelaxMetBool),nnz(minConservationNonRelaxRxnBool),' subset confirmed stoichiometrically consistent by min cardinality of stoich consistency relaxation (after leak testing).')
                pause(eps)
            end
            rxnRemoveBool=model.unknownSConsistencyRxnBool & ~minConservationNonRelaxRxnBool;

            %metabolites exclusively involved in inconsistent reactions are
            %deemed inconsistent also
            metRemoveBool = getCorrespondingRows(model.S,true(nMet,1),rxnRemoveBool,'exclusive');

            %extend inconsistent reaction boolean vector
            model.SInConsistentRxnBool = model.SInConsistentRxnBool | rxnRemoveBool;
            model.SInConsistentMetBool = model.SInConsistentMetBool | metRemoveBool;

            %reduce unknown part
            model.unknownSConsistencyMetBool=~model.SConsistentMetBool & ~model.SInConsistentMetBool;
            model.unknownSConsistencyRxnBool=~model.SConsistentRxnBool & ~model.SInConsistentRxnBool;
        case 'imBalanced'
            rxnRemoveBool=model.unknownSConsistencyRxnBool & model.SIntRxnBool & imBalancedRxnBool;
            %metabolites exclusively involved in imbalanced reactions
            metRemoveBool = getCorrespondingRows(model.S,true(nMet,1),rxnRemoveBool,'exclusive');

            %extend inconsistent reaction boolean vector
            model.SInConsistentRxnBool = model.SInConsistentRxnBool | rxnRemoveBool;
            model.SInConsistentMetBool = model.SInConsistentMetBool | metRemoveBool;

            %reduce unknown part
            model.unknownSConsistencyMetBool=~model.SConsistentMetBool & ~model.SInConsistentMetBool;
            model.unknownSConsistencyRxnBool=~model.SConsistentRxnBool & ~model.SInConsistentRxnBool;
    end

    if any(metRemoveBool) | any(rxnRemoveBool)
        %print out reactions and metabolites being removed
        if printLevel>1
            if printLevel>2
                fprintf('%6u\t%6u\t%s\n',nnz(metRemoveBool),nnz(rxnRemoveBool),' removed.')
                if any(rxnRemoveBool)
                    fprintf('%s\n','Removed reactions:')
                    for j=1:length(rxnRemoveBool)
                        if rxnRemoveBool(j)==1
                            fprintf('%s\t%s\n',model.rxns{j},model.rxnNames{j})
                        end
                    end
                end
                if any(metRemoveBool)
                    fprintf('%s\n','Removed metabolites:')
                    for j=1:length(metRemoveBool)
                        if metRemoveBool(j)==1
                            fprintf('%s\t%s\n',model.mets{j},model.metNames{j})
                        end
                    end
                end
            else
                fprintf('%6u\t%6u\t%s\n',nnz(metRemoveBool),nnz(rxnRemoveBool),' removed.')
            end
        end
    end

    %check if there has been any progress
    if lastUnkownConsistencyMetBool==nnz(model.unknownSConsistencyMetBool) && lastUnkownConsistencyRxnBool==nnz(model.unknownSConsistencyRxnBool)
        break
    else
        lastUnkownConsistencyMetBool=nnz(model.unknownSConsistencyMetBool);
        lastUnkownConsistencyRxnBool=nnz(model.unknownSConsistencyRxnBool);
    end

    iterateCardinalityOpt=iterateCardinalityOpt+1;
    if printLevel>1
        fprintf('%s\n','-------')
    end
end

%check to confirm the stoichiometrically consistent part
switch finalCheckMethod
    case 'findMassLeaksAndSiphons'
        [leakMetBool,leakRxnBool,siphonMetBool,siphonRxnBool,statpRelax,statnRelax] = findMassLeaksAndSiphons(model,model.SConsistentMetBool,model.SConsistentRxnBool,modelBoundsFlag,leakParams,0);
    case 'maxCardinalityConservationVector'
        %maximum cardinality conservation vector computation is not as reliable
        %as the leak/siphon test.
        try
            %compute maximum cardinality conservation vector using a DC approach
            %with all inconsistent reactions removed
            solution=maxCardinalityConservationVector(model.S(model.SConsistentMetBool,model.SConsistentRxnBool),maxCardConsParams);
            maxConservationMetBoolFinal=false(nMet,1);
            if solution.stat==1
                %conserved if molecular mass is above epsilon
                maxConservationMetBoolFinal(model.SConsistentMetBool)=solution.l>=epsilon;
            else
                disp(solution)
                error('solve for maximal conservation vector failed')
            end
            maxConservationRxnBoolFinal_exclusive = getCorrespondingCols(model.S,maxConservationMetBoolFinal,model.SConsistentRxnBool,'exclusive');
            maxConservationRxnBoolFinal_inclusive = getCorrespondingCols(model.S,maxConservationMetBoolFinal,model.SConsistentRxnBool,'inclusive');
        catch
            display('FAILURE AT END')
            maxConservationMetBoolFinal=false(nMet,1);
            maxConservationRxnBoolFinal_exclusive=false(nRxn,1);
            maxConservationRxnBoolFinal_inclusive=false(nRxn,1);
        end
end

if printLevel>0
    fprintf('%s\n','--- Summary of stoichiometric consistency ----')
    fprintf('%6u\t%6u\t%s\n',nMet,nRxn,' totals.')
    fprintf('%6u\t%6u\t%s\n',nnz(~model.SIntMetBool),nnz(~model.SIntRxnBool),' heuristically exchange.')
    fprintf('%6u\t%6u\t%s\n',nnz(model.SIntMetBool),nnz(model.SIntRxnBool),' heuristically non-exchange:')
    fprintf('%6u\t%6u\t%s\n',nnz(model.SConsistentMetBool & model.SIntMetBool),nnz(model.SConsistentRxnBool & model.SIntRxnBool),' ... of which are stoichiometrically consistent.')
    fprintf('%6u\t%6u\t%s\n',nnz(model.SInConsistentMetBool & model.SIntMetBool),nnz(model.SInConsistentRxnBool & model.SIntRxnBool),' ... of which are stoichiometrically inconsistent.')
    fprintf('%6u\t%6u\t%s\n',nnz(model.unknownSConsistencyMetBool & model.SIntMetBool),nnz(model.unknownSConsistencyRxnBool & model.SIntRxnBool),' ... of which are of unknown consistency.')
    if massBalanceCheck
        fprintf('%s\n','---')
        fprintf('%6u\t%6u\t%s\n',nnz((model.SInConsistentMetBool | model.unknownSConsistencyMetBool) & model.SIntMetBool),nnz((model.SInConsistentRxnBool | model.unknownSConsistencyRxnBool) & model.SIntRxnBool),' heuristically non-exchange and stoichiometrically inconsistent or unknown consistency.')
        bool = getCorrespondingRows(model.S,true(nMet,1), (model.SInConsistentRxnBool | model.unknownSConsistencyRxnBool) & model.SIntRxnBool & imBalancedRxnBool,'inclusive');
        fprintf('%6u\t%6u\t%s\n',nnz(bool),nnz((model.SInConsistentRxnBool | model.unknownSConsistencyRxnBool) & model.SIntRxnBool & imBalancedRxnBool),' ... of which are elementally imbalanced (inclusively involved metabolite).')
        bool = getCorrespondingRows(model.S,true(nMet,1), (model.SInConsistentRxnBool | model.unknownSConsistencyRxnBool) & model.SIntRxnBool & imBalancedRxnBool,'exclusive');
        fprintf('%6u\t%6u\t%s\n',nnz(bool),nnz((model.SInConsistentRxnBool | model.unknownSConsistencyRxnBool) & model.SIntRxnBool & imBalancedRxnBool),' ... of which are elementally imbalanced (exclusively involved metabolite).')
    end

    switch finalCheckMethod
        case 'findMassLeaksAndSiphons'
            if nnz(leakMetBool)==0 && nnz(siphonMetBool)==0
                fprintf('%6u\t%6u\t%s\n',nnz(model.SConsistentMetBool),nnz(model.SConsistentRxnBool),' Confirmed stoichiometrically consistent by leak/siphon testing.')
            else
                fprintf('%6u\t%6u\t%s%s%s\n',nnz(leakMetBool),NaN,' semipositive leak metabolites. (',leakParams.method, ' method)');
                fprintf('%6u\t%6u\t%s%s%s\n',nnz(siphonMetBool),NaN,' seminegative siphon metabolites. (',leakParams.method, ' method)');
            end
        case 'maxCardinalityConservationVector'
            if nnz(maxConservationMetBoolFinal)==nnz(model.SConsistentMetBool) && nnz(maxConservationRxnBoolFinal_exclusive)==nnz(model.SConsistentRxnBool)
                %   fprintf('%6u\t%6u\t%s\n',nnz(model.SConsistentMetBool),nnz(model.SConsistentRxnBool),' total stoichiometrically consistent.')
            else
                fprintf('%6u\t%6u\t%s%s%s\n',nnz(maxConservationMetBoolFinal),nnz(maxConservationRxnBoolFinal_exclusive),' exclusive stoich. consistent cols from stoichiometrically consistent rows, (',maxCardConsParams.method, ' method).')
                fprintf('%6u\t%6u\t%s%s%s\n',nnz(maxConservationMetBoolFinal),nnz(maxConservationRxnBoolFinal_inclusive),' inclusive stoich. consistent cols from stoichiometrically consistent rows, (',maxCardConsParams.method, ' method).')
            end
    end
    %fprintf('%6u\t%6u\t%s\n',nnz(model.SInConsistentMetBool),nnz(model.SInConsistentRxnBool),' total stoichiometrically inconsistent.')
    %fprintf('%6u\t%6u\t%s\n',nnz(model.unknownSConsistencyMetBool),nnz(model.unknownSConsistencyRxnBool),' unknown consistency.')
    fprintf('%s\n','--- END ----')
end


if exist('fileName','var') && ~isempty(fileName) && massBalanceCheck
    % printFlag         Print formulas or just return them (Default = true)
    printFlag=1;
    % lineChangeFlag    Append a line change at the end of each line
    lineChangeFlag=1;
    % metNameFlag       print full met names instead of abbreviations
    metNameFlag=0;
    % fid               Optional file identifier for printing in files
    % directionFlag     Checks directionality of reaction. See Note.
    directionFlag=0;
    % gprFlag           print gene protein reaction association
    gprFlag=0;

    %% print the list of metabolites and reactions of unknown consistency
    fid=fopen([fileName '_Unknown_Consistency_' datestr(now,30) '.tab'],'w');
    fprintf(fid,'%u%s\n',nnz(model.unknownSConsistencyMetBool),' metabolites exclusively involved in reactions with unknown consistency.');
    for m=1:nMet
        if model.unknownSConsistencyMetBool(m)
            fprintf(fid,'%s\n',model.mets{m});
        end
    end
    %print the list of reactions involved in reactions with unknown consistency
    fprintf(fid,'%u%s\n',nnz(model.unknownSConsistencyRxnBool),' reactions with unknown consistency.');
    for n=1:nRxn
        if model.unknownSConsistencyRxnBool(n)
            fprintf(fid,'%s\n',model.rxns{n});
        end
    end
    rxnAbbrList=model.rxns(model.unknownSConsistencyRxnBool);
    formulas = printRxnFormula(model,rxnAbbrList,printFlag,lineChangeFlag,metNameFlag,fid,directionFlag,gprFlag);

    fileNameBase=[fileName '_Unknown_Consistency_' datestr(now,30) '_'];
    if isfield(model,'metFormulas')
        modelTmp=model;
        modelTmp.SIntRxnBool=model.unknownSConsistencyRxnBool;
        [massImbalance,imBalancedMass,imBalancedCharge,imBalancedRxnBool,Elements,missingFormulaeBool,balancedMetBool]...
            = checkMassChargeBalance(modelTmp,-1,fileNameBase);
        if nnz(imBalancedRxnBool & model.unknownSConsistencyRxnBool)==0
            if printLevel>2
                fprintf('%s\n','All reactions with unknown stoichiometric consistency appear elementally balanced.')
            end
        end
    else
        error('No model.metFormulas');
    end

    %% print the list of inconsistent metabolites and reactions
    fid=fopen([fileName '_Heuristically_internal_inconsistent_' datestr(now,30) '.tab'],'w');
    fprintf(fid,'%u%s\n',nnz(model.SInConsistentMetBool & model.SIntMetBool),' metabolites exclusively involved in inconsistent reactions.');
    for m=1:nMet
        if model.SInConsistentMetBool(m) && model.SIntMetBool(m)
            fprintf(fid,'%s\n',model.mets{m});
        end
    end
    %print the list of reactions involved in reactions with unknown consistency
    fprintf(fid,'%u%s\n',nnz(model.SInConsistentRxnBool & model.SIntRxnBool),' inconsistent reactions.');
    for n=1:nRxn
        if model.SInConsistentRxnBool(n) && model.SIntRxnBool(n)
            fprintf(fid,'%s\n',model.rxns{n});
        end
    end
    rxnAbbrList=model.rxns(model.SInConsistentRxnBool & model.SIntRxnBool);
    formulas = printRxnFormula(model,rxnAbbrList,printFlag,lineChangeFlag,metNameFlag,fid,directionFlag,gprFlag);

    fileNameBase=[fileName '_Heuristically_internal_inconsistent_' datestr(now,30) '_'];
    if isfield(model,'metFormulas')
        modelTmp=model;
        modelTmp.SIntRxnBool=model.SInConsistentRxnBool & model.SIntRxnBool;
        [massImbalance,imBalancedMass,imBalancedCharge,imBalancedRxnBool,Elements,missingFormulaeBool,balancedMetBool]...
            = checkMassChargeBalance(modelTmp,-1,fileNameBase);
    else
        error('No model.metFormulas');
    end

    %% print list of internal, unknown consistency, imbalanced reactions
    if massBalanceCheck && nnz(model.unknownSConsistencyRxnBool & model.SIntRxnBool & imBalancedRxnBool)>0
        fid=fopen([fileName '_Heuristically_internal_unknown_consistent_imbalanced_rxns_' datestr(now,30) '.tab'],'w');
        fprintf(fid,'%u%s\n',nnz(model.unknownSConsistencyRxnBool & model.SIntRxnBool & imBalancedRxnBool),' Heuristically internal, unknown consistency, imbalanced rxns.');
        rxnAbbrList=model.rxns(model.unknownSConsistencyRxnBool & model.SIntRxnBool & imBalancedRxnBool);
        formulas = printRxnFormula(model,rxnAbbrList,printFlag,lineChangeFlag,metNameFlag,fid,directionFlag,gprFlag);
    end
    % mass and charge balance
    fileNameBase=[fileName '_Heuristically_internal_unknown_consistent_imbalanced_rxns_' datestr(now,30) '_'];
    %mass and charge balance can be checked by looking at formulas
    if isfield(model,'metFormulas')
        modelTmp=model;
        modelTmp.SIntRxnBool=model.unknownSConsistencyRxnBool & model.SIntRxnBool & imBalancedRxnBool;
        [massImbalance,imBalancedMass,imBalancedCharge,imBalancedRxnBool,Elements,missingFormulaeBool,balancedMetBool]...
            = checkMassChargeBalance(modelTmp,-1,fileNameBase);
    else
        error('No model.metFormulas');
    end

    %% print list of internal inconsistent and imbalanced reactions
    if massBalanceCheck && nnz(model.SInConsistentRxnBool & model.SIntRxnBool & imBalancedRxnBool)>0
        fid=fopen([fileName '_Heuristically_internal_stoich_inconsistent_imbalanced_Rxns_' datestr(now,30) '.tab'],'w');
        fprintf(fid,'%u%s\n',nnz(model.SInConsistentRxnBool & model.SIntRxnBool & imBalancedRxnBool),' Heuristically internal, stoich inconsistent, imbalanced rxns.');
        rxnAbbrList=model.rxns(model.SInConsistentRxnBool & model.SIntRxnBool & imBalancedRxnBool);
        formulas = printRxnFormula(model,rxnAbbrList,printFlag,lineChangeFlag,metNameFlag,fid,directionFlag,gprFlag);
    end
    % mass and charge balance
    fileNameBase=[fileName '_Heuristically_internal_stoich_inconsistent_imbalanced_Rxns_' datestr(now,30) '_'];
    %mass and charge balance can be checked by looking at formulas
    if isfield(model,'metFormulas')
        modelTmp=model;
        modelTmp.SIntRxnBool=model.SInConsistentRxnBool & model.SIntRxnBool & imBalancedRxnBool;
        [massImbalance,imBalancedMass,imBalancedCharge,imBalancedRxnBool,Elements,missingFormulaeBool,balancedMetBool]...
            = checkMassChargeBalance(modelTmp,-1,fileNameBase);
    else
        error('No model.metFormulas');
    end

end

%deal variables out for result
SConsistentMetBool=model.SConsistentMetBool;
SConsistentRxnBool=model.SConsistentRxnBool;
SInConsistentMetBool=model.SInConsistentMetBool;
SInConsistentRxnBool=model.SInConsistentRxnBool;
unknownSConsistencyMetBool=model.unknownSConsistencyMetBool;
unknownSConsistencyRxnBool=model.unknownSConsistencyRxnBool;
