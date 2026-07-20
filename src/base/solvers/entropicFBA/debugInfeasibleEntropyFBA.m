function [sol, modelOut] = debugInfeasibleEntropyFBA(model)
% Tries to diagnose the reasons a model is infeasible for entropic flux
% balance analysis (EFBA) by progressively relaxing coupling constraints,
% internal flux bounds, and exchange bounds until a feasible EFBA solution
% is found
%
% USAGE:
%
%    [sol, modelOut] = debugInfeasibleEntropyFBA(model)
%
% INPUT:
%    model:         COBRA model structure, compatible with
%                   `entropicFluxBalanceAnalysis`. Diagnosis progressively
%                   removes/relaxes its optional coupling constraint fields
%                   (`.C`, `.d`) and rescales/relaxes `.lb`, `.ub`, and `.b`
%                   on the reactions not in `.SConsistentRxnBool` if needed
%
% OUTPUTS:
%    sol:           Solution structure returned by the last
%                   `entropicFluxBalanceAnalysis` call attempted (see
%                   `entropicFluxBalanceAnalysis` for fields), with `.stat`
%                   equal to 1 if that attempt was feasible
%    modelOut:      The (possibly relaxed) model corresponding to `sol`;
%                   only assigned once a relaxation is found that yields a
%                   feasible solution
%

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

