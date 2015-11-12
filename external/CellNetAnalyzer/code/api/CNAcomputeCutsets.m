function cutsets= CNAcomputeCutsets(targets, mcsmax, names, sets2save, earlycheck)
%
% CellNetAnalyzer API function 'CNAcomputeCutsets'
% ---------------------------------------------
% --> Berge algorithm for calculation of minimal cut sets (= hypergraph transversal)
%
% Usage: cutsets= CNAcomputeCutsets(targets, mcsmax, names, sets2save, earlycheck)   
%
% computes cutsets for paths/cycles/elementary modes with Berge algorithm
% (equivalent to hypergraph transversal
%
%   targets (mandatory): matrix that row-wise contains the 
%     paths/cycles/elementary modes; the only distinction made is between zero
%     and non-zero elements; mandatory argument, has to be non-empty
% 
%   mcsmax: maximal size of cutsets to be calculated; must
%     be a value grater 0; Inf means no size limit (default: Inf)
%
%   names: a char matrix; its rows are names corresponding to the columns of
%     'targets'; used for diagnostics in preprocessing 
%      (default:[]; the matrix is then constructed with 'I1,',I2',....)
%
%   sets2save: struct array with set of sets (modes/paths/cycles) that should
%      be preserved (not be hit by the cut sets computed). Should have the
%      following fields (default: []):
%            sets2save(i).tabl2save = i-th matrix that row-wise contains the
%                                     sets (paths/cycles/modes) that should be saved
%				      (must have the same number of columns as 'targets')
%            sets2save(i).min2save  = specifies theminimum number of sets (paths/cycles/modes) 
%				      in sets2save(i).tabl2save that should not be hit
%				      by the cutsets computed
%
%   earlycheck: whether the test checking for the fulfillment of constraints 
%      in sets2save should be caried out during (1) or after (0) computation 
%      of cut sets [default: 1; makes only sense in combination with sets2save] 
%
%
% The following results are returned:
%
%   cutsets: matrix that contains the cutsets row-wise; a 1
%     means that the reaction/interaction is part of the cutset, 0 means
%      the reaction/interaction is not involved.  Each cutset hits all modes stored 
%      in ‘targets’ while it does not hit at least ‘sets2save(i).min2save’ many modes 
%      in ‘sets2save(i).tabl2save’ for each specified set i.  

%

error(nargchk(1, 6, nargin));

%A# set default parameters for unspecified arguments
if nargin<5
  earlycheck=1;
  if(nargin<4)
     sets2save=[];
     if (nargin < 3)
        names= default_names('I', size(targets, 2));
        if nargin < 2
            mcsmax= Inf;
        end
     end
  end
end
if(isempty(names))
	names= default_names('I', size(targets, 2));
end


targets= targets ~= 0;

[cutsets, cs_equi_rates, not_involved]= cutsets_calc(targets, names, mcsmax, 0, sets2save, earlycheck);

if ~isempty(not_involved) %A# restore unused reactions/interactions
  involved= true(1, size(targets, 2));
  involved(not_involved)= false;
  tmp= false(size(cutsets, 1), size(targets, 2));
  tmp(:, involved)= cutsets;
  cutsets= tmp;
end
