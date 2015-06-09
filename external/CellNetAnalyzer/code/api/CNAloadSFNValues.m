function [reacval, specval, err]= CNAloadSFNValues(cnap, fname)
% CellNetAnalyzer API function 'CNAloadSFNValues'
%
% load interaction and species values of a signal-flow network
% from a (CNA) val-file
%
% Usage: [reacval, specval]= CNAloadSFNValues(cnap, fname)
%
% All parameters are mandatory:
%
%   cnap: CellNetAnalyzer (signal-flow) project variable 
%
%   fname: name of the val-file
%
% The following results are returned:
%
%   reacval: vector of interaction values as specified in the val-file
%     (contains NaN for interactions that were not specified in the val_file)
%     or [] when err=2 
%
%   specval: vector of species values as specified in the val-file
%     (contains NaN for species that were not specified in the val_file)
%     or [] when err=2 
%
%   err: error code; possible values:
%     0: no error occurred
%     1: invalid identifier(s) in the val-file; these are skipped
%     2: val-file could not be opened

[rv, sv, reac_ind, spec_ind, err]= load_val_file(fname, cnap.reacID, cnap.specID, 'Interaction', 'Species');
if err == 2
  reacval= [];
  specval= [];
else
  reacval= repmat(NaN, cnap.numr, 1);
  specval= repmat(NaN, cnap.nums, 1);
  reacval(reac_ind)= val2num(rv);
  specval(spec_ind)= val2num(sv);
end
