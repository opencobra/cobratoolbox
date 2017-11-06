function [StopFlag, Status] = StopCritBDCA(nfxk, Niter, Nmap, T, MaxNumIter, MaxNumMapEval, TimeLimit, epsilon, Stopping_Crit)
% Function checking that one of the stopping criteria
% holds to terminate LLM and GLM. It perepare the status determining why
% the algorithm is stopped.
%
% USAGE:
%
%    [StopFlag, Status] = StopCritBDCA(nfxk, Niter, Nmap, T, MaxNumIter, MaxNumMapEval, TimeLimit, epsilon, Stopping_Crit)
%
% INPUTS:
%    nhxk:             the norm 2 of `h(xk)`
%    Niter:            the number of iterations
%    Nmap:             the number of mapping calls
%    T:                the running time
%    MaxNumIter:       maximum number of iterations
%    MaxNumMapEval:    maximum number of function evaluations
%    TimeLimit:        maximum running time
%    epsilon:          accuracy parameter
%    Stopping_Crit:    stopping criterion:
%
%                        1. stop if :math:`||nfxk|| \leq \epsilon`
%                        2. stop if `MaxNumIter` is reached
%                        3. stop if `MaxNumMapEval` is reached
%                        4. stop if `TimeLimit` is reached
%                        5. stop if (default) :math:`||hxk|| \leq \epsilon` or `MaxNumIter` is reached
%
% OUTPUTS:
%    StopFlag:         1: if one of the stopping criteria holds, 0: if none of the stopping criteria holds
%    Status:           the reason of the scheme termination

switch Stopping_Crit

  case 1
    if nhxk <= epsilon
      StopFlag = 1;
      Status   = 'A solution of nonlinear system is found.';
    else
      StopFlag = 0;
      Status   = [];
    end

  case 2
    if Niter >= MaxNumIter
      StopFlag = 1;
      Status   = 'Maximum number of iterations is reached.';
    else
      StopFlag = 0;
      Status   = [];
    end

  case 3
    if Nmap >= MaxNumMapEval
      StopFlag = 1;
      Status   = 'Maximum number of mapping evaluations is reached.';
    else
      StopFlag = 0;
      Status   = [];
    end

  case 4
    if T >= TimeLimit
      StopFlag = 1;
      Status   = 'Time limit is reached.';
    else
      StopFlag = 0;
      Status   = [];
    end

  case 5
    if (nfxk <= epsilon || Niter >= MaxNumIter)
      StopFlag = 1;
      if Niter < MaxNumIter
          Status = 'a solution is found';
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
%%%%%%%%%%%%%%%%%%%%%%%% End of StopCritBDCA.m %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
