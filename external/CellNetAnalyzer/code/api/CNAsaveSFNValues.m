function err= CNAsaveSFNValues(cnap, fname, reacval, specval)
% CellNetAnalyzer API function 'CNAsaveSFNValues'
%
% save interaction and species values of signal-flow networks
% to a (CNA) val-file
%
% Usage: err= CNAsaveSFNValues(cnap, fname, reacval, specval)
%
% All parameters are mandatory:
%
%   cnap: CellNetAnalyzer (signal-flow) project variable 
%
%   fname: name of the val-file
%
%   reacval: vector of interaction values (if an interaction has the value
%     NaN it is not saved in the file)
%
%   specval: vector of species values (if a species has the value NaN it is
%     not saved in the file) 
%
% The following results are returned:
%
%   err: reports whether an error occurred (1) or not (0)

err= save_val_file(fname, vec2rb(reacval, NaN), vec2rb(specval, NaN), cnap.reacID, cnap.specID, '%d');
