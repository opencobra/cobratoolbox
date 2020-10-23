function [IEMSol] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy, reverseDirObj, fractionKO,minBiomarker,fixIEMlb, LPSolver)
% This function performs the inborn error of metabolism simulations by
% deleting (or reducing) the flux through reaction(s) affected by a gene
% defect and optimized the flux through a defined set of biomarker
% reactions.
%
% function [IEMSol] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy, reverseDirObj, fractionKO,minBiomarker,fixIEMlb)
%
% INPUT
% model                 whole-body metabolic reconstruction or Recon3Dmodel
% IEMRxns               Reaction(s) affected by the inborn error of
%                       metabolism
% minRxnsFluxHealthy    min flux value(s) through the IEMRxns
% reverseDirObj         the function maximizes the objective flux by
%                       default. If set to 1, the function also checks the minimization problem.
% fractionKO            By default, a complete knowckout of BiomarkerRxnsthe IEM
%                       reactions is computed but it is possible to set a fraction (default = 1
%                       for 100% knockout)
% minBiomarker          Minimization through biomarker reaction (default = 0)
% fixIEMlb              fix IEM to lb = ub
%                       =(1-fractionKO)*solution.v(find(model.c)) (default = 0, i.e., lb =0,
%                       while ub = (1-fractionKO)*solution.v(find(model.c))
% LPSolver              Define LPSolver ('ILOGcomplex' - default;
%                       'tomlab_cplex')
%
% OUTPUT
% IEMSol                Predicted biomarker fluxes and comparison with the
%                       reported biomarkers
%
% USAGE:
% Exampe of preparation of a set of inputs to checkIEM_WBM
%     R = {'_2OXOADPTm';'_2AMADPTm';'_r0879'};
%     RxnsAll2 = '';
%     for i = 1: length(R)
%         RxnsAll = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,R{i}))));
%         RxnsAll2 =[RxnsAll2;RxnsAll];
%     end
%     IEMRxns = unique(RxnsAll2);
%     RxnMic = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'Micro_')))) ;
%     IEMRxns = setdiff(IEMRxns,RxnMic);
%
%     if ~strcmp(modelName,'Recon3D')
%         % add demand reactions to blood compartment for those biomarkers reported for blood
%         % biomarker based on https://www.omim.org/entry/204750
%         model = addDemandReaction(model, 'L2aadp[bc]');
%
%         BiomarkerRxns = {
%             'DM_L2aadp[bc]'	'Increased (blood)'
%             'EX_2oxoadp[u]'	'Increased (urine)'
%             'EX_adpoh[u]'	'Increased (urine)'
%             };
%     else
%         BiomarkerRxns = {
%             'EX_2oxoadp[u]'	'Increased (urine)'
%             'EX_adpoh[u]'	'Increased (urine)'
%             };
%     end
%
% Then call the checkIEM_WBM function
%     [IEMSol_2OAA] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
%
% Example IEMSol returned from the above
%     {'IEM Rxns All obj - Healthy'}    {'65403.5393' }    {0×0 double                    }
%     {'IEM Rxns All obj - Disease'}    {'65403.5393' }    {0×0 double                    }
%     {'WB obj - Healthy'          }    {'NA'         }    {0×0 double                    }
%     {'WB obj - Disease'          }    {'1'          }    {'1'                           }
%     {'Healthy:DM_L2aadp[bc]'     }    {'-5.5324e-08'}    {'Disease - Reported:Increas…'}
%     {'Disease:DM_L2aadp[bc]'     }    {'40.2418'    }    {'Disease - Reported:Increas…'}
%     {'Healthy:EX_2oxoadp[u]'     }    {'-2.3603e-10'}    {'Disease - Reported:Increas…'}
%     {'Disease:EX_2oxoadp[u]'     }    {'3.7368'     }    {'Disease - Reported:Increas…'}
%     {'Healthy:EX_adpoh[u]'       }    {'-1.6985e-10'}    {'Disease - Reported:Increas…'}
%     {'Disease:EX_adpoh[u]'       }    {'3.7368'     }    {'Disease - Reported:Increas…'}
%
% 2018 - Ines Thiele
% 2019 - Ines Thiele, included more options (minBiomarker,fixIEMlb,LPSolver)

if ~exist('minRxnsFluxHealthy','var')
    minRxnsFluxHealthy = 0.75;
end
if ~exist('reverseDirObj','var')
    reverseDirObj = 0;
end

if ~exist('fractionKO','var')
    fractionKO = 1;% complete KO
end
if ~exist('minBiomarker','var')
    minBiomarker = 0;% no minimization of flux through biomarkers
end

if ~exist('fixIEMlb','var')
    fixIEMlb = 0;% lb = 0 for IEM rxns, while ub is constraint to (1-fractionKO)*solution.v(find(model.c));
end

if ~exist('LPSolver','var')
    LPSolver = 'ILOGcomplex';
    LPSolver = 'tomlab_cplex';
end
[solverOK, solverInstalled] = changeCobraSolver(LPSolver, 'LP',0,1);

global useSolveCobraLPCPLEX
%
cnt = 1;
tol = 1e-6;

if useSolveCobraLPCPLEX
    [r,c] = size(model.A);
    % dummy rxn obj
    model.A(r+1,c+1) = -1;
    for i = 1 : length(IEMRxns)
        model.A(r+1,strmatch(IEMRxns{i},model.rxns,'exact')) = 1;
    end
    model.b(r+1) = 0;
    model.csense(r+1)='E';
    model.lb(c+1)=-100000;
    model.ub(c+1)=100000;
    model.c = zeros(size(model.A,2),1);
    model.c(c+1) = 1;
else
    [r,c] = size(model.S);
    % dummy rxn obj
    model.S(r+1,c+1) = -1;
    for i = 1 : length(IEMRxns)
        model.S(r+1,strmatch(IEMRxns{i},model.rxns,'exact')) = 1;
    end
    model.b(r+1) = 0;
    model.csense(r+1)='E';
    model.lb(c+1)=-100000;
    model.ub(c+1)=100000;
    model.c = zeros(size(model.S,2),1);
    model.c(c+1) = 1;
    if isfield(model,'C')
        %pad coupling constraints
        model.C = [model.C, sparse(size(model.C,1),1)];
    end
end

if reverseDirObj ==  1 % minimize obj
    model.osense = 1;
else
    model.osense = -1;
end

% maximize joint objective in healthy model
tic;
if useSolveCobraLPCPLEX
    [solution,~]=solveCobraLPCPLEX(model,1,0,0,[],0,'ILOGcomplex');
    solution.v=solution.full;
else
    model.osenseStr='max';
    solution = optimizeWBModel(model);
end
timeTaken=toc;
IEMSol{cnt,1} = 'IEM Rxns All obj - Healthy';

%cplex origStat code meanings
%       1 (S,B) Optimal solution found
%       2 (S,B) Model has an unbounded ray
%       3 (S,B) Model has been proved infeasible
%       4 (S,B) Model has been proved either infeasible or unbounded
%       5 (S,B) Optimal solution is available, but with infeasibilities after unscaling
%       6 (S,B) Solution is available, but not proved optimal, due to numeric difficulties

%the original status codes
%if solution.origStat ~= 3 && solution.origStat ~= 5
if solution.stat == 1 || solution.stat == 3 %only proceed if the wild type was optimal, or almost optimal
    IEMSol{cnt,2} = num2str(solution.v(model.c~=0));cnt = cnt + 1;
    if  abs(solution.v(model.c~=0)) > 1e-6
        
        % Healthy: set organ reactions to be at least 75% of max value
        model.lb(c+1) = minRxnsFluxHealthy*solution.v(model.c~=0);
        model.lb(c+1)=fix(model.lb(c+1)*1000000)/1000000;% remove the last few digits from the 16 digits allowed by matlab
        % Disease: set them all to 0
        modelIEM = model;
        if fixIEMlb == 1
            modelIEM.lb(c+1) = (1-fractionKO)*solution.v(model.c~=0);
            modelIEM.lb(c+1)=fix(modelIEM.lb(c+1)*1000000)/1000000;% remove the last few digits from the 16 digits allowed by matlab
            
        else
            modelIEM.lb(c+1) = 0;
        end
        modelIEM.ub(c+1) = (1-fractionKO)*solution.v(model.c~=0);
        modelIEM.ub(c+1)=fix(modelIEM.lb(c+1)*1000000)/1000000;% remove the last few digits from the 16 digits allowed by matlab
        
        tic;
        if useSolveCobraLPCPLEX
            [solution,~]=solveCobraLPCPLEX(modelIEM,1,0,0,[],0,'ILOGcomplex');
            solution.v=solution.full;
        else
            %note model.osense set above ~line 135
            solution = optimizeWBModel(modelIEM);
        end
        timeTaken=toc;
        IEMSol{cnt,1} = 'IEM Rxns All obj - Disease';
        
        %if solution.origStat ~= 3 && solution.origStat ~= 5% feasible solution
        if solution.stat == 1 || solution.stat == 3
            f = solution.v(modelIEM.c~=0);
            if abs(f) <= tol
                f = 0;
            end
            IEMSol{cnt,2} = num2str(f);cnt = cnt + 1;
            % IEMSol{cnt,3} = num2str(solution.origStat);cnt = cnt + 1;
        else
            IEMSol{cnt,2} = 'NaN';
            cnt = cnt + 1;
        end
        
        % check that healthy model is still feasible
        model = changeObjective(model,'Whole_body_objective_rxn');
        model.osenseStr = 'max';
        IEMSol{cnt,1} = 'WB obj - Healthy';
        IEMSol{cnt,2} = 'ND';cnt = cnt + 1;
        
        %if solution.origStat ~= 3 && solution.origStat ~= 5% feasible solution
        if solution.stat == 1 || solution.stat == 3
            modelO = model;
            modelIEMO = modelIEM;
            
            % is biomass maintenance feasible
            modelIEM = changeObjective(modelIEM,'Whole_body_objective_rxn');
            modelIEM.osense = -1;
            tic;
            if useSolveCobraLPCPLEX
                [solution,~]=solveCobraLPCPLEX(modelIEM,1,0,0,[],0,'ILOGcomplex');
                solution.v=solution.full;
            else
                solution = optimizeWBModel(modelIEM);
            end
            timeTaken=toc;
            IEMSol{cnt,1} = 'WB obj - Disease';
            if solution.stat == 1 || solution.stat == 3
                f = solution.v(modelIEM.c~=0);
                if abs(f) <= tol
                    f = 0;
                end
                IEMSol{cnt,2} = num2str(f);
            else
                IEMSol{cnt,2} = NaN;
            end
            IEMSol{cnt,3} = num2str(solution.origStat);cnt = cnt + 1;
            % IEMSol{cnt,2} = 'NA';cnt = cnt + 1;
            
            %if solution.origStat ~= 3 && solution.origStat ~= 5% feasible
            if solution.stat == 1 || solution.stat == 3
                for i = 1 : size(BiomarkerRxns,1)
                    model = modelO;
                    %displaying the biomarker being predicted helps to
                    %track progress
                    disp(BiomarkerRxns{i,1})
                    % Healthy
                    model.ub(strmatch(BiomarkerRxns{i,1},model.rxns)) = 100000;
                    model = changeObjective(model,BiomarkerRxns{i,1});
                    % max of biomarker
                    model.osenseStr = 'max';
                    model.osense = -1;
                    tic;
                    if useSolveCobraLPCPLEX
                        [solution,~]=solveCobraLPCPLEX(model,1,0,0,[],0,'ILOGcomplex');
                        solution.v=solution.full;
                    else
                        solution = optimizeWBModel(model);
                        if solution.origStat == 3 % in the case that the solution is returned infeasible, which can happen due to numerical difficulties of the cplex solver, remove some more digits from the constrain. This does not change the solution. Note if the function went until here the model itself is feasible as only the objective function is changed from the previous simulation.
                            model.lb(c+1)=fix(model.lb(c+1)*10000)/10000;
                            solution = optimizeWBModel(model);
                        end
                        
                    end
                    timeTaken=toc;
                    IEMSol{cnt,1} = strcat('Healthy:',BiomarkerRxns{i,1});
                    if solution.stat == 1 || solution.stat == 3
                        f = solution.v(model.c~=0);
                        if abs(f) <= tol
                            f = 0;
                        end
                        IEMSol{cnt,2} = num2str(f);
                    else
                        IEMSol{cnt,2} = 'NaN';
                    end
                    IEMSol{cnt,3} = strcat('Disease - Reported:',BiomarkerRxns{i,2});
                    % minimization of biomarker
                    if minBiomarker == 1
                        % min of biomarker
                        model.osense = 1;
                        model.osenseStr = 'min';
                        tic;
                        if useSolveCobraLPCPLEX
                            [solution,~]=solveCobraLPCPLEX(model,1,0,0,[],0,'ILOGcomplex');
                            solution.v=solution.full;
                        else
                            solution = optimizeWBModel(model);
                        end
                        timeTaken=toc;
                        if solution.stat == 1 || solution.stat == 3
                            f = solution.v(model.c~=0);
                            if abs(f) <= tol
                                f = 0;
                            end
                            IEMSol{cnt,4} = num2str(solution.v(model.c~=0));
                        else
                            IEMSol{cnt,4} = 'NaN';
                        end
                    end
                    cnt = cnt + 1;
                    %KO
                    modelIEM = modelIEMO;
                    modelIEM.ub(strmatch(BiomarkerRxns{i,1},modelIEM.rxns)) = 100000;
                    modelIEM = changeObjective(modelIEM,BiomarkerRxns{i,1});
                    modelIEM.osense = -1;
                    tic;
                    if useSolveCobraLPCPLEX
                        [solution,~]=solveCobraLPCPLEX(modelIEM,1,0,0,[],0,'ILOGcomplex');
                        solution.v=solution.full;
                    else
                        solution = optimizeWBModel(modelIEM);
                        if solution.origStat == 3 % in the case that the solution is returned infeasible, which can happen due to numerical difficulties of the cplex solver, remove some more digits from the constrain. This does not change the solution. Note if the function went until here the model itself is feasible as only the objective function is changed from the previous simulation.
                            modelIEM.lb(c+1)=fix(modelIEM.lb(c+1)*10000)/10000;
                            solution = optimizeWBModel(modelIEM);
                        end
                    end
                    timeTaken=toc;
                    IEMSol{cnt,1} = strcat('Disease:',BiomarkerRxns{i,1});
                    if solution.stat == 1 || solution.stat == 3
                        f = solution.v(modelIEM.c~=0);
                        if abs(f) <= tol
                            f = 0;
                        end
                        IEMSol{cnt,2} = num2str(solution.v(modelIEM.c~=0));
                    else
                        IEMSol{cnt,2} = 'NaN';
                    end
                    IEMSol{cnt,3} =strcat('Disease - Reported:',BiomarkerRxns{i,2});
                    % minimization of biomarker
                    if minBiomarker == 1
                        % min of biomarker
                        modelIEM.osense = 1;
                        tic;
                        if useSolveCobraLPCPLEX
                            [solution,~]=solveCobraLPCPLEX(modelIEM,1,0,0,[],0,'ILOGcomplex');
                            solution.v=solution.full;
                        else
                            solution = optimizeWBModel(modelIEM);
                        end
                        timeTaken=toc;
                        if solution.stat == 1 || solution.stat == 3
                            f = solution.v(modelIEM.c~=0);
                            if abs(f) <= tol
                                f = 0;
                            end
                            IEMSol{cnt,4} = num2str(f);
                        else
                            IEMSol{cnt,4} = 'NaN';
                        end
                    end
                    cnt = cnt + 1;
                end
            end
        end
    end
end