function modelConstrained = addCouplingConstraint(model, rxnList, c, d, ineqSense)
% Constrains one (weighted) sum of fluxes to be above a lower bound.
% Appends to existing inequality constraints if they are present
%
% USAGE:
%
%    modelConstrained = constrainRxnListAboveBound(model, rxnList, c, d, ineqSense)
%
% INPUTS:
%    model:               model structure
%    rxnList:             cell array of reaction names
%
% OPTIONAL INPUTS:
%    c:                   `k x 1` vector :math:`c*v \geq d`
%    d:                   `n x 1` vector :math:`c*v \geq d`
%    ineqSense:           `k x 1` inequality sense {'L','G'}
%
% OUTPUT:
%    modelConstrained:    constrained model:
%
%                           * S - Stoichiometric matrix
%                           * b - Right hand side = dx/dt
%                           * C - Inequality constraint matrix
%                           * d - Inequality constraint right hand side
%                             :math:`[S; C] * v {=, \leq, \geq } [dxdt, d]`  

% EXAMPLE:
%
%    rxnList = {'PCHOLP_hs_f', 'PLA2_2_f', 'SMS_f','PCHOLP_hs_b', 'PLA2_2_b', 'SMS_b'};
%    c = [1, 1, 1, 1, 1, 1];
%    d = 10;
%    ineqSense = 'G';
%    modelConstrained = constrainRxnListAboveBound(modelIrrev, rxnList, C, d, ineqSense);

modelConstrained = addCOBRAConstraints(model, rxnList ,d ,'c',c,'dsense',ineqSense);
