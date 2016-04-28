function [reacval, macroval, err]= CNAloadMFNValues(cnap, fname)
% CellNetAnalyzer API function 'CNAloadMFNValues'
%
% load reaction and macromolecule values of a mass-flow project
% from a (CNA) val-file
%
% Usage: [reacval, macroval]= CNAloadMFNValues(cnap, fname)
%
% All parameters are mandatory:
%
%   cnap: CellNetAnalyzer (mass-flow) project variable 
%
%   fname: name of the val-file
%
% The following results are returned:
%
%   reacval: vector of reaction values as specified in the val-file
%     (contains NaN for reactions that were not specified in the val_file)
%     or [] when err=2 
%
%   macroval: vector of macromolecule values as specified in the val-file
%     (contains NaN for macromolecules that were not specified in the
%     val_file) or [] when err=2 
%
%   err: error code; possible values:
%     0: no error occurred
%     1: invalid identifier(s) in the val-file; these are skipped
%     2: val-file could not be opened

[rv, mv, reac_ind, macro_ind, err]= load_val_file(fname, cnap.reacID, cnap.macroID, 'Reaction', 'Macromolecule');
if err == 2
  reacval= [];
  macroval= [];
else
  reacval= repmat(NaN, cnap.numr, 1);
  macroval= repmat(NaN, cnap.nummac, 1);
  reacval(reac_ind)= val2num(rv);
  macroval(macro_ind)= val2num(mv);
end
