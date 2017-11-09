function [StopFlag, Status] = StopCriterion(grad, nhxk, Niter, Nmap, Ngmap, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, T, TimeLimit, epsilon, nhx0, ngradx0, Stopping_Crit)
% `StopCriterion` is a function checking that one of the stopping criteria
% holds to terminate LLM and GLM. It perepare the status determining why
% the algorithm is stopped.
%
% USAGE:
%
%    [StopFlag, Status] = StopCriterion(grad, nhxk, Niter, Nmap, Ngmap, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, T, TimeLimit, epsilon, nhx0, ngradx0, Stopping_Crit)
%
% INPUTS:
%    grad:              gradient of the merit funcrion
%    nhxk:              the norm 2 of `h(xk)`
%    MaxNumIter:        maximum number of iterations
%    MaxNumMapEval:     maximum number of function evaluations
%    MaxNumGmapEval:    maximum number of subgradient evaluations
%    TimeLimit:         maximum running time
%    epsilon:           accuracy parameter
%    Stopping_Crit:     stopping criterion
%
%                         1. stop if :math:`||grad|| \leq \epsilon`
%                         2. stop if :math:`||nhxk|| \leq \epsilon`
%                         3. stop if `MaxNumIter` is reached
%                         4. stop if `MaxNumMapEval` is reached
%                         5. stop if `MaxNumGmapEval` is reached
%                         6. stop if `TimeLimit` is reached
%                         7. stop if :math:`||grad|| \leq \textrm{max}(\epsilon, \epsilon^2 * ngradx0)`
%                         8. stop if :math:`||nhxk|| \leq \textrm{max}(\epsilon, \epsilon^2 * nhx0)`
%                         9. stop if (default) :math:`||hxk|| \leq \epsilon` or `MaxNumIter` is reached
%
% OUTPUTS:
%    StopFlag:          1: if one of the stopping criteria holds, 0: if none of the stopping criteria holds
%    Status:            the reason of the scheme termination

switch Stopping_Crit
  case 1
    if norm(grad) <= epsilon
      StopFlag = 1;
      Status   = 'Local (global) solution of merit function is found.';
    else
      StopFlag = 0;
      Status   = [];
    end
  case 2
    if nhxk <= epsilon
      StopFlag = 1;
      Status   = 'A solution of nonlinear system is found.';
    else
      StopFlag = 0;
      Status   = [];
    end
  case 3
    if Niter >= MaxNumIter
      StopFlag = 1;
      Status   = 'Maximum number of iterations is reached.';
    else
      StopFlag = 0;
      Status   = [];
    end
  case 4
    if Nmap >= MaxNumMapEval
      StopFlag = 1;
      Status   = 'Maximum number of mapping evaluations is reached.';
    else
      StopFlag = 0;
      Status   = [];
    end
  case 5
    if Ngmap >= MaxNumGmapEval
      StopFlag = 1;
      Status   = 'Maximum number of gradient evaluations is reached.';
    else
      StopFlag = 0;
      Status   = [];
    end
  case 6
    if T >= TimeLimit
      StopFlag = 1;
      Status   = 'Time limit is reached.';
    else
      StopFlag = 0;
      Status   = [];
    end

  case 7
    if norm(grad) <= max(epsilon,epsilon^2*ngradx0)
      StopFlag = 1;
      Status   = 'A possible stationary point is found.';
    else
      StopFlag = 0;
      Status   = [];
    end

  case 8
    if nhxk <= max(epsilon,epsilon^2*nhx0)
      StopFlag = 1;
      Status   = 'A possible solution is found.';
    else
      StopFlag = 0;
      Status   = [];
    end

  case 9
    if (nhxk <= epsilon || Niter >= MaxNumIter)
      StopFlag = 1;
      if Niter < MaxNumIter
          Status = 'a solution is found.';
      else
          Status = 'Maximum number of iterations is reached.';
      end
    else
      StopFlag = 0;
      Status   = [];
    end

end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% End of StopCriterion.m %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
