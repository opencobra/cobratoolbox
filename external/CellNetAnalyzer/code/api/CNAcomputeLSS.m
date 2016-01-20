function [spec_lss, inter_lss]= CNAcomputeLSS(cnap, spec_vals, inter_vals)
%
% CellNetAnalyzer API function 'CNAcomputeLSS'
% ---------------------------------------------
% --> calculation of logical steady states
%
% Usage: [spec_lss, inter_lss]= CNAcomputeLSS(cnap, spec_vals, inter_vals)
% 
%   cnap: is a CellNetAnalyzer (signal-flow) project variable and mandatory argument. 
%     The function accesses the following fields in cnap (see also manual):
%   		cnap.interMat: contains the interactions
%   		cnap.notMat: contains the minus signs along the (hyper)arcs
% 		  cnap.excludeInLogical: if cnap.excludeInLogical(i) ~= 0 then reaction i
% 	  		will be excluded from the calculation
%   		cnap.nums: number of species (rows in cnap.interMat)
%   		cnap.numr: number of interactions (columns in cnap.interMat)
%
% The other arguments are optional:
%
%   spec_vals: [] or a vector of length 'cnap.nums'; if non-empty the
%     value of spec_vals(i) is used as predefined value for species i;
%     use 'NaN' as value to leave species undefined
%     (default: [])
%
%   inter_vals: [] or a vector of length 'cnap.numr'; if non-empty the
%     value of inter_vals(i) is used as predefined value for interaction i;
%     use 'NaN' as value to leave interactions undefined
%     (default: [])
%
%
% The following results are returned:
%
%   spec_lss: the logical steady states of the species 
%	    (NaN indicates that the steady state of the 
%	    corresponding species is  undetermined) 
%
%   inter_lss: the signal flow along the interactions in the computed
%	    logical steady states (NaN means that the value of the 
%	    corresponding interaction is undetermined) 
%

error(nargchk(1, 3, nargin));

%A# default parameters:
cnap.local.rb= zeros(0, 2);
cnap.local.metvals= zeros(0, 2);

if nargin > 1
  spec_vals= reshape(spec_vals, length(spec_vals), 1);
  cnap.local.metvals= find(~isnan(spec_vals));
  cnap.local.metvals(:, 2)= spec_vals(cnap.local.metvals);
  if nargin > 2
    inter_vals= reshape(inter_vals, length(inter_vals), 1);
    cnap.local.rb= find(~isnan(inter_vals));
    cnap.local.rb(:, 2)= inter_vals(cnap.local.rb);
  end
end

cnap= compute_lss(cnap);

spec_lss= cnap.local.met_fertig;
inter_lss= cnap.local.r_fertig;
