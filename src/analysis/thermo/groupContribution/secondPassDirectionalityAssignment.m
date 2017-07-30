function [model, solutionThermoRecon, solutionRecon, model1] = secondPassDirectionalityAssignment(model)
% Driver to call model specific code to manually generate a physiological model (if first pass does not result in a physiological model).
%
% The second pass directionality assignment needs careful manual curation
% since the adjustments necessary to get one organism to grow will not
% necessarily be the same as the ones which will get another
% organism to grow. There's no avioding manual debugging at this stage.
%
% USAGE:
%
%    [model, solutionThermoRecon, solutionRecon, model1] = secondPassDirectionalityAssignment(model)
%
% INPUTS:
%    model:
%
% OUTPUTS:
%    model:
%    solutionThermoRecon:
%    solutionRecon:
%    model1:
%
% NOTE:
%
%    This is the code  used for a number of organisms in order to point out
%    the kind of issues that arise. This is NOT supposed to work in the
%    general case.
%
% .. Author: - Ronan M. T. Fleming

global CBTLPSOLVER
switch model.description
    case 'iAF1260'
        % now assign reaction directions based on the P(\Delta_{r}G^{\primeo}<0)
        % doing so may prevent the model from growing, therefore at this stage it
        % is necessary to manually adjust some of the reaction directionalities
        % such that the model can grow, and grow at a similar rate as observed in
        % vivo. Therefore this script cannot be made model invariant as there is an
        % essential manual debugging stage. The script below is for E. coli iAF1260
        fprintf('%s\n%s\n%s\n','The second pass assignment of reaction directionality should',...
            'be a compromise between quantitative and qualitative assignment',...
            'this step requires manual imput as it is specific to each organism.');

        fprintf('%s\n',['The second pass assignment of reaction directionality is using the ' CBTLPSOLVER ' LP solver.']);
        fprintf('\n%s\n','...setThermoReactionDirectionality (based on the P(\Delta_{r}G^{\primeo}<0))');
        % this will update the model.lb_reconThermo & model.ub_reconThermo
        [model,solutionThermoRecon,solutionRecon,model1]=setThermoReactionDirectionalityiAF1260(model);
    otherwise
        fprintf('No manually generated .m file second pass directionality assignment is available for this model.')
end
