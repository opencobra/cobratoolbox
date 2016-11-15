function [SConsistentMetBool,SConsistentRxnBool,SInConsistentMetBool,SInConsistentRxnBool,unknownSConsistencyMetBool,unknownSConsistencyRxnBool,model]=findStoichConsistentSubset(model,epsilon,massBalanceCheck,printLevel,fileName)
%finds the subset of S that is stoichiometrically consistent using
%an iterative cardinality optimisation approach
%
%INPUT
% model
%    .S             m x n stoichiometric matrix
%
%OPTIONAL INPUT
% epsilon           (1e-4) minimum nonzero mass 
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

% Ronan Fleming & Minh Le, July 2016

if ~exist('epsilon','var')
    epsilon=1e-4;
end
if ~exist('printLevel','var')
    printLevel=1;
end
        
if ~exist('massBalanceCheck','var')
    massBalanceCheck=0;
end

[nMet,nRxn]=size(model.S);
if printLevel>0
    fprintf('%6s\t%6s\n','#mets','#rxns')
    fprintf('%6u\t%6u\t%s\n',nMet,nRxn,' totals.')
end
%%
%heuristically identify exchange reactions
if ~isfield(model,'SIntRxnBool')  || ~isfield(model,'SIntMetBool')
    %finds the reactions in the model which export/import from the model
    %boundary i.e. mass unbalanced reactions
    %e.g. Exchange reactions
    %     Demand reactions
    %     Sink reactions
    model = findSExRxnInd(model,[],printLevel-1);
end

if printLevel>0
    fprintf('%6u\t%6u\t%s\n',nnz(~model.SIntMetBool),nnz(~model.SIntRxnBool),' heuristically exchange.')
end
if printLevel>0
    fprintf('%6u\t%6u\t%s\n',nnz(model.SIntMetBool),nnz(model.SIntRxnBool),' heuristically non-exchange.')
end

if massBalanceCheck
    if ~isfield(model,'balancedMetBool') || ~isfield(model,'balancedRxnBool')
        %mass and charge balance can be checked by looking at formulas
        if isfield(model,'metFormulas')
            [massImbalance,imBalancedMass,imBalancedCharge,imBalancedRxnBool,Elements,missingFormulaeBool,balancedMetBool]...
                = checkMassChargeBalance(model,printLevel-1);
            model.balancedRxnBool=~imBalancedRxnBool;
            model.balancedMetBool=balancedMetBool;
            
            model.Elements=Elements;
            model.missingFormulaeBool=missingFormulaeBool;
        else
            error('No model.metFormulas');
        end
    end
    if printLevel>0
        fprintf('%6u\t%6u\t%s\n',nnz(model.balancedMetBool),nnz(model.balancedRxnBool),' seemingly elementally balanced.')
    end
    if printLevel>0
        fprintf('%6u\t%6u\t%s\n',nnz(~model.balancedMetBool),nnz(~model.balancedRxnBool),' seemingly elementally imbalanced.')
    end
    if printLevel>0
        fprintf('%s\n','-------')
    end
    if printLevel>0
        fprintf('%6u\t%6u\t%s\n',nnz(model.balancedMetBool & model.SIntMetBool),nnz(model.balancedRxnBool & model.SIntRxnBool),' heuristically non-exchange and seemingly elementally balanced.')
    end
    if printLevel>0
        fprintf('%6u\t%6u\t%s\n',nnz(~model.balancedMetBool & model.SIntMetBool),nnz(~model.balancedRxnBool & model.SIntRxnBool),' heuristically non-exchange and seemingly elementally imbalanced.')
    end
    if printLevel>0
        fprintf('%s\n','-------')
    end
else
    %add dummy entries for mass balanced
    model.balancedMetBool=model.SIntMetBool;
    model.balancedRxnBool=model.SIntRxnBool;
end

%assumes that all mass imbalanced reactions are exchange reactions
model.SIntMetBool = model.SIntMetBool & model.balancedMetBool;
model.SIntRxnBool = model.SIntRxnBool & model.balancedRxnBool;

if massBalanceCheck
    if printLevel>0
        fprintf('%6u\t%6u\t%s\n',nnz(model.SIntMetBool),nnz(model.SIntRxnBool),' heuristically non-exchange and seemingly elementally balanced.')
        fprintf('%6u\t%6u\t%s\n',nnz(~model.SIntMetBool),nnz(~model.SIntRxnBool),' heuristically exchange and seemingly elementally imbalanced.')
    end
end

%%
%iteratively try to identify largest consistent subset of metabolites and reactions
if 1
    %heuristically identified exchange reactions and metabolites
    model.SInConsistentMetBool=~model.SIntMetBool;
    model.SInConsistentRxnBool=~model.SIntRxnBool;
else
    %dont provide any starting information
    model.SInConsistentMetBool=false(nMet,1);
    model.SInConsistentRxnBool=false(nRxn,1);
end

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
    
%do leak test after each step to make sure that we are working correctly
doubleCheckConsistency=1;

maxCardConsParams.epsilon=epsilon;%1/epsilon is the largest mass considered, needed for numerical stability
maxCardConsParams.method = 'quasiConcave';%seems to work the best, but sometimes infeasible
%maxCardConsParams.method = 'dc';%seems to work, but not always the best
maxCardConsParams.theta = 0.5;

%decide whether or not to use the bounds on the model
modelBoundsFlag=0;

%number of metabolites involved in each reaction, used to kick out
%inconsistent reactions
nMetsPerRxn=sum(model.S~=0,1)';

leakParams.epsilon=epsilon;
leakParams.method='quasiConcave';
%leakParams.method='dc';
feasTol = getCobraSolverParams('LP', 'feasTol');
%leakParams.eta=feasTol*100;
leakParams.eta=feasTol*100;
leakParams.theta = 0.5;

%start the iterative loop
iterateCardinalityOpt=1;
while iterateCardinalityOpt>0   
    if printLevel>0
        fprintf('%s%u%s\n','Iteration #',iterateCardinalityOpt,' minimum cardinality of conservation relaxation vector.')
        fprintf('%6u\t%6u\t%s\n',nnz(model.unknownSConsistencyMetBool),nnz(model.unknownSConsistencyRxnBool),' unknown consistency.')
    end
    
    %decide subset to be tested during this iteration
    boolMet=model.SConsistentMetBool | model.unknownSConsistencyMetBool;
    boolRxn=model.SConsistentRxnBool | model.unknownSConsistencyRxnBool;
    if printLevel>0
        fprintf('%6u\t%6u\t%s\n',nnz(boolMet),nnz(boolRxn),' being tested.')
    end
    %compute minimum relaxation
    if nnz(model.S(boolMet,boolRxn))~=0
        %% minimum cardinality of conservation relaxation vector
        solutionRelax = minCardinalityConservationRelaxationVector(model.S(boolMet,boolRxn),epsilon);
        %chek optimality
        if printLevel>2 | 0
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
            if printLevel>2 | 0
                fprintf('%g%s\n',norm(model.S(boolMet,minConservationNonRelaxRxnBool)'*solutionRelax.z),' = ||N''*z||')
            end
            minConservationRelaxRxnBool=false(nRxn,1);
            minConservationRelaxRxnBool(boolRxn)=abs(solutionRelax.x)>=leakParams.eta;
        else
            disp(solutionRelax)
            error('solve for maximal conservation vector failed')
        end
        
      
        %corresponding rows matching non-relaxed reactions
        minConservationNonRelaxMetBool = getCorrespondingRows(model.S,boolMet,minConservationNonRelaxRxnBool,'inclusive');
        %reactions matching consistent metabolites
        %minConservationNonRelaxRxnBool = getCorrespondingCols(model.S,minConservationNonRelaxMetBool,minConservationNonRelaxRxnBool,'inclusive');
        if printLevel>2 | 0
            z=zeros(nMet,1);
            z(boolMet)=solutionRelax.z;
            z(~minConservationNonRelaxMetBool)=0;
            fprintf('%g%s\n',norm(model.S(minConservationNonRelaxMetBool,minConservationNonRelaxRxnBool)'*z(minConservationNonRelaxMetBool)),' = ||N''*z||')
        end
        
        if printLevel>0
            if nnz(minConservationNonRelaxMetBool)~=0 || nnz(minConservationNonRelaxRxnBool)~=0
                fprintf('%6u\t%6u\t%s\n',nnz(minConservationNonRelaxMetBool),nnz(minConservationNonRelaxRxnBool),' stoichiometrically consistent by min cardinality of stoich consistency relaxation.')
            end
        end
        
        if doubleCheckConsistency && any(minConservationNonRelaxMetBool)
            %check to see if the stoichiometrically consistent part is leaking
            printLevel=1;
            [VpRelax,YpRelax,statpRelax,VnRelax,YnRelax,statnRelax] = findMassLeaksAndSiphons(model,minConservationNonRelaxMetBool,minConservationNonRelaxRxnBool,modelBoundsFlag,leakParams,printLevel);
            leakSiphonMetBool=YpRelax>=leakParams.eta | YnRelax>=leakParams.eta;
            if any(leakSiphonMetBool)
                %omit leaking metabolites
                minConservationNonRelaxMetBool(leakSiphonMetBool)=0;
                %columns exclusively involved in stoichiometrically consistent rows
                if iterateCardinalityOpt==1
                    minConservationNonRelaxRxnBool = getCorrespondingCols(model.S,minConservationNonRelaxMetBool,model.SConsistentRxnBool | minConservationNonRelaxRxnBool,'inclusive');
                else
                    minConservationNonRelaxRxnBool = getCorrespondingCols(model.S,minConservationNonRelaxMetBool,model.SConsistentRxnBool | minConservationNonRelaxRxnBool,'inclusive');
                end
            end
        end
    else
        minConservationNonRelaxMetBool=model.SConsistentMetBool;
        minConservationNonRelaxRxnBool=model.SConsistentRxnBool;
        minConservationRelaxRxnBool=false(nRxn,1);
    end
           
    if printLevel>0
        fprintf('%6u\t%6u\t%s\n',nnz(minConservationNonRelaxMetBool),nnz(minConservationNonRelaxRxnBool),' confirmed stoichiometrically consistent by min cardinality of stoich consistency relaxation (after leak testing).')
    end
    
    if iterateCardinalityOpt==13
        pause(eps)
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
    
    if printLevel>0
        fprintf('%6u\t%6u\t%s\n',nnz(model.SConsistentMetBool),nnz(model.SConsistentRxnBool),' total stoichiometrically consistent thus far.')
        
    end
    
    if nnz(model.unknownSConsistencyMetBool)==0 && nnz(model.unknownSConsistencyRxnBool)==0
        break
    else
        %stop the loop when the number is too high
        if iterateCardinalityOpt==1000
            break;
        end
     end
    
    if nnz(model.unknownSConsistencyRxnBool)==0
        pause(eps)
    end
    
    %remove reactions with unknown consistency of maximal cardinality
    if any(model.unknownSConsistencyRxnBool)
        fprintf('%6u\t%6u\t%s\n',nnz(model.unknownSConsistencyMetBool),nnz(model.unknownSConsistencyRxnBool),' unknown consistency.')
        nMetsPerRxnTmp=nMetsPerRxn;
        %reactions with known consistency set to zero
        nMetsPerRxnTmp(~model.unknownSConsistencyRxnBool)=0;
        %find the reaction(s) with unknown consistency involving maximum
        %number of metabolites
        maxMetsPerRxn=full(max(nMetsPerRxnTmp(model.unknownSConsistencyRxnBool)));
        %boolean reactions to be consisdered inconsistent and removed
        rxnRemoveBool=nMetsPerRxnTmp==maxMetsPerRxn;
        %remove metabolites exclusively involved in reactions considered
        %inconsistent and slated for removal
        metRemoveBool = getCorrespondingRows(model.S,true(nMet,1),rxnRemoveBool,'exclusive');
        
        %extend inconsistent part
        model.SInConsistentRxnBool = model.SInConsistentRxnBool | rxnRemoveBool;
        model.SInConsistentMetBool = model.SInConsistentMetBool | metRemoveBool;
        
        %reduce unknown part
        model.unknownSConsistencyMetBool=~model.SConsistentMetBool & ~model.SInConsistentMetBool;
        model.unknownSConsistencyRxnBool=~model.SConsistentRxnBool & ~model.SInConsistentRxnBool;
        if printLevel>0
            fprintf('%6u\t%6u\t%s%u%s\n',nnz(metRemoveBool), nnz(rxnRemoveBool), ' removed inconsistent heuristically non-exchange reactions, each involving ',maxMetsPerRxn, ' metabolites.')
        end
    end
    
%     %remove reactions with unknown consistency of maximal cardinality
%     if any(minConservationRelaxRxnBool) && any(model.unknownSConsistencyRxnBool)
%         fprintf('%6u\t%6u\t%s\n',nnz(model.unknownSConsistencyMetBool),nnz(model.unknownSConsistencyRxnBool),' unknown consistency.')
%         nMetsPerRxnTmp=nMetsPerRxn;
%         %reactions with known consistency set to zero
%         nMetsPerRxnTmp(~model.unknownSConsistencyRxnBool)=0;
%         %find the reaction(s) with unknown consistency involving maximum
%         %number of metabolites
%         maxMetsPerRxn=full(max(nMetsPerRxnTmp(minConservationRelaxRxnBool)));
%         %boolean reactions to be consisdered inconsistent and removed
%         rxnRemoveBool=nMetsPerRxnTmp==maxMetsPerRxn;
%         %remove metabolites exclusively involved in inconsistent reactions
%         metRemoveBool = getCorrespondingRows(model.S,true(nMet,1),rxnRemoveBool,'exclusive');
%         %remove inconsistent part
%         model.SInConsistentRxnBool = model.SInConsistentRxnBool | rxnRemoveBool;
%         model.SInConsistentMetBool = model.SInConsistentMetBool | metRemoveBool;
%         
%         %reduce unknown part
%         model.unknownSConsistencyMetBool=~model.SConsistentMetBool & ~model.SInConsistentMetBool;
%         model.unknownSConsistencyRxnBool=~model.SConsistentRxnBool & ~model.SInConsistentRxnBool;
%         if printLevel>0
%             fprintf('%6u\t%6u\t%s%u%s\n',nnz(metRemoveBool), nnz(rxnRemoveBool), ' removed inconsistent heuristically non-exchange reactions, each involving ',maxMetsPerRxn, ' metabolites.')
%         end
%     end
    iterateCardinalityOpt=iterateCardinalityOpt+1;
    if printLevel>0
        fprintf('%s\n','-------')
    end
end
    
%check to see if the stoichiometrically consistent part is leaking
[Vp,Yp,statp,Vn,Yn,statn] = findMassLeaksAndSiphons(model,model.SConsistentMetBool,model.SConsistentRxnBool,modelBoundsFlag,leakParams,0);
leakMetBool=Yp>=leakParams.eta;
siphonMetBool=Yn>=leakParams.eta;

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

          
if printLevel>0
    fprintf('%s\n','--- Summary of stoichiometric consistency ----')
    fprintf('%6u\t%6u\t%s\n',nMet,nRxn,' totals.')
    fprintf('%6u\t%6u\t%s\n',nnz(~model.SIntMetBool),nnz(~model.SIntRxnBool),' heuristically exchange.')
    fprintf('%6u\t%6u\t%s\n',nnz(model.SIntMetBool),nnz(model.SIntRxnBool),' heuristically non-exchange:')
    fprintf('%6u\t%6u\t%s\n',nnz(model.SConsistentMetBool & model.SIntMetBool),nnz(model.SConsistentRxnBool & model.SIntRxnBool),' ... of which are stoichiometrically consistent.')
    fprintf('%6u\t%6u\t%s\n',nnz(model.SInConsistentMetBool & model.SIntMetBool),nnz(model.SInConsistentRxnBool & model.SIntRxnBool),' ... of which are stoichiometrically inconsistent.')
    if nnz(maxConservationMetBoolFinal)==nnz(model.SConsistentMetBool) && nnz(maxConservationRxnBoolFinal_exclusive)==nnz(model.SConsistentRxnBool)...
            && nnz(leakMetBool)==0 && nnz(siphonMetBool)==0
        fprintf('%6u\t%6u\t%s\n',nnz(model.SConsistentMetBool),nnz(model.SConsistentRxnBool),' total stoichiometrically consistent.')
    else
        fprintf('%6u\t%6u\t%s%s%s\n',nnz(maxConservationMetBoolFinal),nnz(maxConservationRxnBoolFinal_exclusive),' exclusive stoich. consistent cols from stoichiometrically consistent rows, (',maxCardConsParams.method, ' method).')
        fprintf('%6u\t%6u\t%s%s%s\n',nnz(maxConservationMetBoolFinal),nnz(maxConservationRxnBoolFinal_inclusive),' inclusive stoich. consistent cols from stoichiometrically consistent rows, (',maxCardConsParams.method, ' method).')
        fprintf('%6u\t%6u\t%s%s%s\n',nnz(leakMetBool),NaN,' semipositive leak metabolites. (',leakParams.method, ' method)');
        fprintf('%6u\t%6u\t%s%s%s\n',nnz(siphonMetBool),NaN,' seminegative siphon metabolites. (',leakParams.method, ' method)');
    end
    fprintf('%6u\t%6u\t%s\n',nnz(model.SInConsistentMetBool),nnz(model.SInConsistentRxnBool),' total stoichiometrically inconsistent.')
    fprintf('%6u\t%6u\t%s\n',nnz(model.unknownSConsistencyMetBool),nnz(model.unknownSConsistencyRxnBool),' unknown consistency.')
    fprintf('%s\n','--- END ----')
end


if exist('fileName','var') && ~isempty(fileName)
    fid=fopen([fileName '_InconsistentNonHeuristicallyExchangeRxns_' datestr(now,30) '.tab'],'w');
    
    for m=1:nMet
        if model.unknownSConsistencyMetBool(m)
            fprintf(fid,'%s\n',model.mets{m});
        end
    end
    
    rxnAbbrList=model.rxns(model.SInConsistentRxnBool);
    printFlag=1;
    lineChangeFlag=1;
    metNameFlag=0;
    directionFlag=0;
    gprFlag=0;
    % rxnAbbrList       Abbrs of reactions whose formulas are to be printed
    % printFlag         Print formulas or just return them (Default = true)
    % lineChangeFlag    Append a line change at the end of each line
    %                   (Default = true)
    % metNameFlag       print full met names instead of abbreviations
    %                   (Default = false)
    % fid               Optional file identifier for printing in files
    % directionFlag     Checks directionality of reaction. See Note.
    %                   (Default = false)
    % gprFlag           print gene protein reaction association
    %                   (Default = false)
    formulas = printRxnFormula(model,rxnAbbrList,printFlag,lineChangeFlag,metNameFlag,fid,directionFlag,gprFlag);
end

%deal variables out for result
SConsistentMetBool=model.SConsistentMetBool;
SConsistentRxnBool=model.SConsistentRxnBool;
SInConsistentMetBool=model.SInConsistentMetBool;
SInConsistentRxnBool=model.SInConsistentRxnBool;
unknownSConsistencyMetBool=model.unknownSConsistencyMetBool;
unknownSConsistencyRxnBool=model.unknownSConsistencyRxnBool;

%   if 0
%         %% start of step 3: maximum cardinality conservation vector
%         if printLevel>0
%             fprintf('%s%u%s\n','Iteration #',iterateCardinalityOpt,'a maximum cardinality conservation vector:')
%         end
%         
%         if globalApproachA
%             boolMetA=model.SConsistentMetBool | model.unknownSConsistencyMetBool;
%             boolRxnA=model.SConsistentRxnBool | model.unknownSConsistencyRxnBool;
%         else
%             boolMetA= model.unknownSConsistencyMetBool;
%             boolRxnA= model.unknownSConsistencyRxnBool;
%         end
%         
%         %%%%%%%%% compute maximum cardinality conservation vector %%%%%%%%%%%%%
%         
%         if nnz(boolMetA)==0
%             pause(eps)
%         end
%         if nnz(boolRxnA)==0
%             pause(eps)
%         end
%         
%         %dont test if the selected part of the stoichiometric matrix is all zeros
%         if nnz(model.S(boolMetA,boolRxnA))~=0
%             if printLevel>0
%                 fprintf('\n%6u\t%6u\t%s\n',nnz(boolMetA),nnz(boolRxnA),' being tested.')
%             end
%             solutionMaxCons=maxCardinalityConservationVector(model.S(boolMetA,boolRxnA),maxCardConsParams);
%             
%             maxConservationMetBool=false(nMet,1);
%             if solutionMaxCons.stat==1
%                 %conserved if molecular mass is above epsilon
%                 maxConservationMetBool(boolMetA)=solutionMaxCons.l>=epsilon;
%             else
%                 disp(solutionMaxCons)
%                 error('solve for maximal conservation vector failed')
%             end
%             
%             if removeInconsistentFlag
%                 pause(eps)
%             end
%             %columns matching stoichiometrically consistent rows
%             maxConservationRxnBool = getCorrespondingCols(model.S,maxConservationMetBool,boolRxnA,'inclusive');
%             
%             if printLevel>0
%                 fprintf('%6u\t%6u\t%s%s%s\n',nnz(maxConservationMetBool),nnz(maxConservationRxnBool),' stoichiometrically consistent by max cardinality of conservation vector. (',maxCardConsParams.method, ' method)')
%             end
%             
%             if doubleCheckConsistency && any(maxConservationMetBool)
%                 %check to see if the new stoichiometrically consistent part is leaking
%                 
%                 printLevel=1;
%                 [VpMaxCons,YpMaxCons,statpMaxCons,VnMaxCons,YnMaxCons,statnMaxCons] = findMassLeaksAndSiphons(model,maxConservationMetBool,maxConservationRxnBool,modelBoundsFlag,leakParams,printLevel);
%                 leakSiphonMetBool=YpMaxCons>=leakParams.eta | YnMaxCons>=leakParams.eta;
%                 if any(leakSiphonMetBool)
%                     %omit leaking metabolites before extending consistent part
%                     maxConservationMetBool(leakSiphonMetBool)=0;
%                     %columns exclusively matching stoichiometrically consistent rows
%                     if iterateCardinalityOpt==1
%                         maxConservationRxnBool = getCorrespondingCols(model.S,maxConservationMetBool,maxConservationRxnBool,'inclusive');
%                     else
%                         maxConservationRxnBool = getCorrespondingCols(model.S,maxConservationMetBool,maxConservationRxnBool,'inclusive');
%                     end
%                 end
%             end
%             
%             if printLevel>0 && any(maxConservationMetBool)
%                 fprintf('%6u\t%6u\t%s%s%s\n',nnz(maxConservationMetBool),nnz(maxConservationRxnBool),' confirmed stoichiometrically consistent by max cardinality of conservation vector. (',maxCardConsParams.method, ' method)')
%             end
%             
%             if doubleCheckConsistency && any(maxConservationMetBool)
%                 %check to see if the total stoichiometrically consistent part is leaking
%                 printLevel=1;
%                 [VpMaxCons,YpMaxCons,statpMaxCons,VnMaxCons,YnMaxCons,statnMaxCons] = findMassLeaksAndSiphons(model,model.SConsistentMetBool | maxConservationMetBool,...
%                     model.SConsistentRxnBool | maxConservationRxnBool,modelBoundsFlag,leakParams,printLevel);
%                 
%                 leakSiphonMetBool=YpMaxCons>=leakParams.eta | YnMaxCons>=leakParams.eta;
%                 if any(leakSiphonMetBool)
%                     %omit leaking metabolites before extending consistent part
%                     maxConservationMetBool(leakSiphonMetBool)=0;
%                     %columns exclusively matching stoichiometrically consistent rows
%                     if iterateCardinalityOpt==1
%                         maxConservationRxnBool = getCorrespondingCols(model.S,maxConservationMetBool,maxConservationRxnBool,'inclusive');
%                     else
%                         maxConservationRxnBool = getCorrespondingCols(model.S,maxConservationMetBool,maxConservationRxnBool,'inclusive');
%                     end
%                 end
%             end
%         else
%             if printLevel>0
%                 %fprintf('%s\n',' No nonzero stoichiometry to be tested.')
%             end
%             %if nothing is tested because that part of the stochiometric matrix
%             %is all zero then set it inconsistent by default
%             maxConservationMetBool=false(nMet,1);
%             %maxConservationMetBool(boolMetA)=1;
%             maxConservationRxnBool=false(nRxn,1);
%             %maxConservationRxnBool(boolRxnA)=1;
%         end
%         
%         %now extend consistent part
%         if globalApproachA
%             model.SConsistentMetBool=maxConservationMetBool;
%             model.SConsistentRxnBool=maxConservationRxnBool;
%         else
%             model.SConsistentMetBool=model.SConsistentMetBool | maxConservationMetBool;
%             model.SConsistentRxnBool=model.SConsistentRxnBool | maxConservationRxnBool;
%         end
%         %reduce unknown part
%         model.unknownSConsistencyMetBool=~model.SConsistentMetBool & ~model.SInConsistentMetBool;
%         model.unknownSConsistencyRxnBool=~model.SConsistentRxnBool & ~model.SInConsistentRxnBool;
%         
%         if printLevel>0
%             fprintf('%6u\t%6u\t%s\n',nnz(model.SConsistentMetBool),nnz(model.SConsistentRxnBool),' total stoichiometrically consistent.')
%         end
%         if printLevel>0
%             fprintf('%6u\t%6u\t%s\n',nnz(model.unknownSConsistencyMetBool),nnz(model.unknownSConsistencyRxnBool),' unknown consistency.')
%         end
%     end