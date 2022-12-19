function [sol,modelOut] = debugInfeasibleEntropyFBA(model)
%try to diagnose the reasons a model is infeasible for Entropy FBA

sol = optimizeCbModel(model);
if sol.stat~=1
    warning('Model does not admit a flux balance analysis solution')
    return
end

param.printLevel = 1;

%test with default parameters
[sol, ~] = entropicFluxBalanceAnalysis(model,param);

if sol.stat ==1
    fprintf('%s\n',['EFBA feasible with default solver: ' sol.solver '.'])
else
    fprintf('%s\n',['EFBA infeasible with default solver: ' sol.solver '.'])
end

switch sol.solver
    case 'mosek'
        solMOSEK = sol;
        
        %test with pdco
        param.solver = 'pdco';
        [solPDCO, ~] = entropicFluxBalanceAnalysis(model,param);
        
        if solPDCO.stat ==1
            fprintf('%s\n',['EFBA feasible with ' solPDCO.solver '.'])
        else
            fprintf('%s\n',['EFBA infeasible with ' solPDCO.solver '.'])
        end
    case 'pdco'
        solPDCO = sol;
        
        %test with mosek
        param.solver ='mosek';
        [solMOSEK, ~] = entropicFluxBalanceAnalysis(model,param);
        if solMOSEK.stat ==1
            fprintf('%s\n',['EFBA feasible with ' solMOSEK.solver '.'])
        else
            fprintf('%s\n',['EFBA infeasible with ' solMOSEK.solver '.'])
        end
end


if solPDCO.stat ~= solMOSEK.stat
    warning('pdco and mosek sol.stat are inconsistent')
end


if solMOSEK.stat==1
    fprintf('%s\n','EFBA feasible with mosek')
end
    fprintf('%s\n','EFBA infeasible with mosek')
    
    %test without coupling constraints
    modelTmp = rmfield(model,'C');
    modelTmp  = rmfield(modelTmp,'d');
    [sol, ~] = entropicFluxBalanceAnalysis(modelTmp,param);
    if sol.stat==1
        fprintf('%s\n','Coupling constraints are causing thermodynamic infeasibility, removed.')
        modelOut = modelTmp;
        return
    else
        param.internalNetFluxBounds = 'directional';
        [sol, modelOut] = entropicFluxBalanceAnalysis(modelTmp,param);
        if sol.stat==1
            fprintf('%s\n','Internal finite flux bounds are causing thermodynamic infeasibility, removed.')
        else
            
            param.internalNetFluxBounds = 'max';
            [sol, modelOut] = entropicFluxBalanceAnalysis(modelTmp,param);
            if sol.stat==1
                fprintf('%s\n','Small finite innternal directional flux bounds are causing thermodynamic infeasibility, removed.')
            else
                param.internalNetFluxBounds = 'none';
                [sol, modelOut] = entropicFluxBalanceAnalysis(modelTmp,param);
                if sol.stat==1
                    fprintf('%s\n','Internal directional flux bounds are causing thermodynamic infeasibility, removed.')
                else
                    %try rescaling finite model constraints, i.e. rhs, lb, ub
                    param.internalNetFluxBounds = 'none';
                    scaleFactor = 1e-2;
                    modelTmp2 = modelTmp;
                    modelTmp2.lb(~modelTmp.SConsistentRxnBool) = modelTmp.lb(~modelTmp.SConsistentRxnBool)*scaleFactor;
                    modelTmp2.ub(~modelTmp.SConsistentRxnBool) = modelTmp.ub(~modelTmp.SConsistentRxnBool)*scaleFactor;
                    modelTmp2.b = modelTmp.b*scaleFactor;
                    if isfield(modelTmp,'d')
                        modelTmp2.d = modelTmp.d*scaleFactor;
                    end
                    [sol, modelOut] = entropicFluxBalanceAnalysis(modelTmp2,param);
                    if sol.stat==1
                        fprintf('%s\n','Multiscale exchange bounds are causing thermodynamic infeasibility, rescaled.')
                    else
                        %try relaxing the exchange bounds
                        modelTmp2 = modelTmp;
                        modelTmp2.lb(~modelTmp.SConsistentRxnBool) = modelTmp.lb(~modelTmp.SConsistentRxnBool) - 1000;
                        modelTmp2.ub(~modelTmp.SConsistentRxnBool) = modelTmp.ub(~modelTmp.SConsistentRxnBool) + 1000;
                        param.internalNetFluxBounds = 'none';
                        [sol, modelOut] = entropicFluxBalanceAnalysis(modelTmp2,param);
                        if sol.stat==1
                            fprintf('%s\n','Exchange bounds are too tight and causing thermodynamic infeasibility, relaxed.')
                        else
                            
                        end
                    end
                end
            end
        end
    end
end

