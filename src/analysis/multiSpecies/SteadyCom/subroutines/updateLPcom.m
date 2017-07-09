function LPproblem = updateLPcom(modelCom, grCur, GRfx, BMcon, LPproblem, BMgdw)
% Create the LP problem [LP(grCur)] given growth rate grCur and other
% constraints if LPproblem in the input does not contain the field 'A',
% or is empty or is not given.
% Otherwise, update LPproblem with the growth rate grCur. Only the
% arguements 'modelCom', 'grCur', 'GRfx' and 'LPproblem' are used in this
% case.
%
% Usage:
%   LPproblem = updateLPcom(modelCom, grCur, GRfx, BMcon, LPproblem, BMgdw)
%
% Input:
%   modelCom:   community model
%   grCur:      the current growth rate for the LP to be updated to
%   GRfx:       fixed growth rates for certain organisms
%   BMcon:      constraint matrix for organism biomass
%   LPproblem:  LP problem structure with field 'A' or the problem matrix
%               directly
%   BMgdw:      the gram dry weight per mmol of the biomass reaction of
%               each organism (nSp x 1 vector, default all 1)
%
% Return a structure with the field 'A' updated if the input 'LPproblem' is
% a structure or return a matrix if 'LPproblem' is the problem matrix
m = size(modelCom.S, 1);
n = size(modelCom.S, 2);
nRxnSp = sum(modelCom.indCom.rxnSps > 0);
nSp = numel(modelCom.infoCom.spAbbr);
if ~exist('grCur', 'var')
    grCur = 0;
elseif isempty(grCur)
    grCur = 0;
end
if ~exist('GRfx', 'var') || isempty(GRfx)
    GRfx  = getSteadyComParams({'GRfx'}, struct(), modelCom);
end
if ~exist('LPproblem', 'var')
    LPproblem = struct();
end

construct = false;
if ~isstruct(LPproblem)
    if isempty(LPproblem)
        construct = true;
    end
elseif ~isfield(LPproblem, 'A')
    construct = true;
end
if construct
    if ~exist('BMgdw', 'var')
        BMgdw = ones(nSp,1);
    end
    %upper bound matrix
    S_ub = sparse([1:nRxnSp 1:nRxnSp]', [(1:nRxnSp)'; n + modelCom.indCom.rxnSps(1:nRxnSp)],...
          [ones(nRxnSp,1); -modelCom.ub(1:nRxnSp)], nRxnSp, n + nSp);
    %lower bound matrix
    S_lb = sparse([1:nRxnSp 1:nRxnSp]', [(1:nRxnSp)'; n + modelCom.indCom.rxnSps(1:nRxnSp)],...
          [-ones(nRxnSp,1); modelCom.lb(1:nRxnSp)], nRxnSp, n + nSp);
    %growth rate and biomass link matrix
    grSp = zeros(nSp, 1);
    grSp(isnan(GRfx)) = grCur;
    %given fixed growth rate
    grSp(~isnan(GRfx)) = GRfx(~isnan(GRfx));
    S_gr = sparse([1:nSp 1:nSp]', [modelCom.indCom.spBm(:) (n + 1:n + nSp)'],...
                  [BMgdw(:); -grSp], nSp, n + nSp);
    if isempty(BMcon)
        A = [modelCom.S sparse([],[],[], m, nSp); S_ub; S_lb; S_gr];
    else
        A = [modelCom.S sparse([],[],[], m, nSp); S_ub; S_lb; S_gr;...
                   sparse([],[],[],size(BMcon, 1), n) BMcon];
    end
    if isstruct(LPproblem)
        LPproblem.A = A;
    else
        LPproblem = A;
    end
else
    for j = 1:nSp
        if isstruct(LPproblem)
            if isnan(GRfx(j))
                LPproblem.A(m + 2*nRxnSp + j, n + j) = -grCur;
            else
                LPproblem.A(m + 2*nRxnSp + j, n + j) = -GRfx(j);
            end
        else
            if isnan(GRfx(j))
                LPproblem(m + 2*nRxnSp + j, n + j) = -grCur;
            else
                LPproblem(m + 2*nRxnSp + j, n + j) = -GRfx(j);
            end
        end
    end
end
end

