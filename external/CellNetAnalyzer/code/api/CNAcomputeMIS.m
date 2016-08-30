function [mis, idx, ec, stat]= CNAcomputeMIS(cnap, scen, max_mis_size, err_tol,...
  count_minerr, spec_restr, allow_inact, allow_actv, excl_fix_spec, dispval, fpath, fname)
% CellNetAnalyzer API function 'CNAcomputeMIS'
% ---------------------------------------------
% --> calculation of (logical) minimal intervention sets in signal flow networks
%
% Usage: [mis, idx, ec, stat]= CNAcomputeMIS(cnap, scen, max_mis_size, err_tol,...
%     count_minerr, spec_restr, allow_inact, allow_actv, excl_fix_spec, dispval, fpath, fname)
%
% Computes minimal intervention sets (MIS) fulfilling a set of
% goals defined by a scenario.
% It is possible to define multiple scenarios whose goals all have to be
% fulfilled by the MIS. The goals and fixed species/interactions are
% specific for each scenario while the remaining parameters apply to all
% scenarios.
%
% cnap is a CellNetAnalyzer (signal-flow) project variable and mandatory
% argument.
% The function accesses the following fields in cnap (see also manual):
%   cnap.interMat: contains the incidence matrix of a graph	or of a
%     hypergraph
%   cnap.notMat: contains the minus signs along the (hyper)arcs
%   cnap.incTruthTable: vector containing the incomplete truth table flag
%     of the interactions
%   cnap.monotony: vector containing the monotony flag of the interactions
%   cnap.specID: names of the rows (species) in cnap.interMat
%   cnap.reacID: names of the columns (arcs/hyperarcs) in cnap.interMat  
%   cnap.nums: number of species in the network
%   cnap.numr: number of (hyper)arcs in the network
%
% The other arguments are:
%
%   scen(mandatory): struct array of scenarios with 6 fields; each field is
%     either empty or contains a row vector that describes the intervention
%     goal or the state of fixed species/interactions
%     these fields contain the intervention goals:
%      goal_spec: species values that must result from the intervention
%      goal_spec_not: species values that are forbidden in the intervention
%      goal_inter: interaction values that must result from the intervention
%      goal_inter_not: interaction values that are forbidden in the intervention
%     these fields contain the fixed states:
%      fix_spec: fixed species
%      fix_inter: fixed interactions
%     when a non-empty vector is given it must have as many elements as
%     interactions resp. species in the network; its entries correspond to
%     the interactions/species and contain either the value of the goal/state
%     or NaN when no goal/state is given
%     each index entry of the struct array describes the goals/states of one
%     scenario, i.e. the fields of scen(i) describe the i-th scenario
%
% The remaining arguments are optional:  
%
%   max_mis_size: the maximum number of interventions in one MIS
%     (default: Inf) 
%
%   err_tol: number of errors allowed in a MIS to count as accepted
%      (default: 0)
%
%   count_minerr: whether the minimal number of errors produced by an
%      candidate MISs should be stored and displayed at the end in case
%'     that no MISs could be found satisfying all intervention goals
%      (note that this may increase computation time considerably!) 
%      (default: 0)
%
%   spec_restr: an empty vector or a vector of restrictions on the
%     activatibility of the species; in the latter case the vector must
%     have a length equal to cnap.nums; it either contains NaN when no
%     restrictions are imposed on a species or one of the following:
%      -1: no inactivation allowed
%      -2: no activation allowed
%      -3: neither inactivation nor activation allowed
%     (default: [])
%
%   allow_inact: flag which determines whether species can be activated
%     (default: true) 
%
%   allow_actv: flag which determines whether species can be inactivated
%     (default: true) 
%
%   excl_fix_spec: flag which determines whether species with a fixed state
%     are excluded to be excluded from the interventions (default: false) 
%
%   dispval: controls the output printed to the console
%      0: print only warnings
%      1: output preprocessing information (summary information in case of
%         multiple scenarios)
%      2: additional preprocessing output for each scenario (applicable
%         only when multiple scenarios are defined)
%
%   fpath, fname: if both are specified the MIS are saved in the directory
%     fpath under fname
%
% The following results are returned:
%
%   mis: matrix that contains the MIS row-wise; depending on the value
%     the corresponding species (cf. idx) is:
%     1: activated
%     0: not part of the intervention set
%    -1: deactivated
%
%   idx: maps the columns in 'mis' onto the column indices in cnap.interMat,
%	    i.e. idx(i) refers to the column number in cnap.interMat (and to the
%	    row in cnap.reacID)
%
%   ec: ec(i) is the number of goals that were not fulfilled by mis(i, :);
%     always <= err_tol
%
%   stat: information about the way in which MIS calculation terminated;
%     especially useful when no MIS were calculated; possible values are:
%     0: calculation finished normally
%     1: goals are already fulfilled without any intervention
%     2: neither activatable nor removable species in at least one scenario
%     3: if count_minerr was on and no cut sets were found this status
%        indicates that 'ec' contains the minimal number of discrepancies
%    -1: incompatible goals within one scenario
%    -2: all scenarios without goals

error(nargchk(2, 12, nargin));

mis= zeros(0, cnap.nums);
idx= [];
ec= [];
stat= -1;

scen_fields= {'goal_spec', 'goal_spec_not', 'goal_inter', 'goal_inter_not', 'fix_spec', 'fix_inter'};
for fnm= scen_fields(~ismember(scen_fields, fieldnames(scen))) %A# add missing fields
  [scen(:).(fnm{:})]= deal([]);
end

num_scen= length(scen);
cnap.local.mlmcsgoal= repmat(NaN, num_scen, cnap.nums);
cnap.local.mlmcsgoalnot= repmat(NaN, num_scen, cnap.nums);
cnap.local.rlmcsgoal= repmat(NaN, num_scen, cnap.numr);
cnap.local.rlmcsgoalnot= repmat(NaN, num_scen, cnap.numr);
cnap.local.fixed_spec= repmat(NaN, num_scen, cnap.nums);
cnap.local.fixed_inter= repmat(NaN, num_scen, cnap.numr);

sc= 1;
while sc <= num_scen
  %A# check if any goal was set in this scenario
  %A# protect from any(~isnan(zeros(0,2))) -> [0 0] with (:) or hope for
  %A# the best?
  if any(~isnan(scen(sc).goal_spec)) || any(~isnan(scen(sc).goal_spec_not))...
      || any(~isnan(scen(sc).goal_inter)) || any(~isnan(scen(sc).goal_inter_not))
    %A# check for consistency and set goals
    if ~isempty(scen(sc).goal_spec) && ~isempty(scen(sc).goal_spec_not)
      ind= find(~isnan(scen(sc).goal_spec) & ~isnan(scen(sc).goal_spec_not));
      conflict= ~xor(scen(sc).goal_spec(ind), scen(sc).goal_spec_not(ind));
      if any(conflict)
        fprintf('Incompatible goals in scenario %d for the following species:\n', sc);
        disp(cnap.specID(ind(conflict), :));
        disp('No intervention sets exist.');
        return;
      else
        cnap.local.mlmcsgoal(sc, :)= scen(sc).goal_spec;
        cnap.local.mlmcsgoalnot(sc, :)= scen(sc).goal_spec_not;
      end
    else
      if ~isempty(scen(sc).goal_spec)
        cnap.local.mlmcsgoal(sc, :)= scen(sc).goal_spec;
      end
      if ~isempty(scen(sc).goal_spec_not)
        cnap.local.mlmcsgoalnot(sc, :)= scen(sc).goal_spec_not;
      end
    end

    if ~isempty(scen(sc).goal_inter) && ~isempty(scen(sc).goal_inter_not)
      ind= find(~isnan(scen(sc).goal_inter) & ~isnan(scen(sc).goal_inter_not));
      conflict= ~xor(scen(sc).goal_inter(ind), scen(sc).goal_inter_not(ind));
      if any(conflict)
        fprintf('Incompatible goals in scenario %d for the following species:\n', sc);
        disp(cnap.reacID(ind(conflict), :));
        disp('No intervention sets exist.');
        return;
      else
        cnap.local.rlmcsgoal(sc, :)= scen(sc).goal_inter;
        cnap.local.rlmcsgoalnot(sc, :)= scen(sc).goal_inter_not;
      end
    else
      if ~isempty(scen(sc).goal_inter)
        cnap.local.rlmcsgoal(sc, :)= scen(sc).goal_inter;
      end
      if ~isempty(scen(sc).goal_inter_not)
        cnap.local.rlmcsgoalnot(sc, :)= scen(sc).goal_inter_not;
      end
    end
  
    if ~isempty(scen(sc).fix_spec)
      cnap.local.fixed_spec(sc, :)= scen(sc).fix_spec;
    end
    if ~isempty(scen(sc).fix_inter)
      cnap.local.fixed_inter(sc, :)= scen(sc).fix_inter;
    end
    sc= sc + 1;
  else %A# no goal was set
    disp('Ignored scenario without goals.');
    num_scen= num_scen - 1;
  end
end
if num_scen == 0
  stat= -2;
  return;
elseif num_scen < length(scen) %A# some empty scenarions were deleted
  ind= num_scen+1:length(scen);
  cnap.local.mlmcsgoal(ind, :)= [];
  cnap.local.mlmcsgoalnot(ind, :)= [];
  cnap.local.rlmcsgoal(ind, :)= [];
  cnap.local.rlmcsgoalnot(ind, :)= [];
  cnap.local.fixed_spec(ind, :)= [];
  cnap.local.fixed_inter(ind, :)= [];
end

%A# set default parameters for unspecified arguments
cnap.local.count_minerr= false;
cnap.local.allowinactv= true;
cnap.local.allowactv= true;
cnap.local.excludefm= false;
cnap.local.spec_restr= repmat(NaN, 1, cnap.nums);
cnap.local.maxmcssize= Inf;
cnap.local.err_tol= 0;
cnap.local.dispval= 1;

if nargin > 2
  cnap.local.maxmcssize= max_mis_size;
  if nargin > 3
    cnap.local.err_tol= err_tol;
    if nargin > 4
      cnap.local.count_minerr= count_minerr;
      if nargin > 5
        cnap.local.spec_restr= spec_restr;
        if nargin > 6
          cnap.local.allowinactv= allow_inact;
          if nargin > 7
            cnap.local.allowactv= allow_actv;
            if nargin > 8
              cnap.local.excludefm= excl_fix_spec;
              if nargin > 9
                cnap.local.dispval= dispval;
              end
            end
          end
        end
      end
    end
  end
end

cnap= lmis_prep(cnap);

%A# save anything when status == 3 ?
if nargin > 11 && size(cnap.local.cutsets,1)
  cnap.local.fpath= fpath;
  cnap.local.ldat= fname;
  cnap= save_lmis(cnap);
end

mis= cnap.local.cutsets;
idx= cnap.local.cutsets_specs;
ec= cnap.local.err_count;
stat= cnap.local.stat;
