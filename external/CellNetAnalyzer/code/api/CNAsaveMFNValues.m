function err= CNAsaveMFNValues(cnap, fname, reacval, macroval)
% CellNetAnalyzer API function 'CNAsaveMFNValues'
%
% Save reaction and macromolecule values of mass-flow projects
% to a (CNA) val-file
%
% Usage: err= CNAsaveMFNValues(cnap, fname, reacval, macroval)
%
% All parameters are mandatory:
%
%   cnap: CellNetAnalyzer (mass-flow) project variable 
%
%   fname: name of the val-file
%
%   reacval: vector of reaction values (if a reaction has the value NaN it
%     is not saved in the file)
%
%   macroval: vector of macromolecule values (if a macromolecule has the
%   value NaN it is not saved in the file)
%
% The following results are returned:
%
%   err: reports whether an error occurred (1) or not (0)

err= save_val_file(fname, vec2rb(reacval, NaN), vec2rb(macroval, NaN), cnap.reacID, cnap.macroID, '%f');
