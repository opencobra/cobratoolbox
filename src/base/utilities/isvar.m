function [tf, bool, ind] = isvar(T, varName)
% Check if `varName` is a field of struct `T`, or a column (variable) of
% table `T`
%
% USAGE:
%
%    [tf, bool, ind] = isvar(T, varName)
%
% INPUTS:
%    T:          struct, or table to search. When `T` is a table, fields
%                used are:
%
%                  * .Properties - table metadata; `Properties.VariableNames`
%                    is read to test membership of `varName`
%    varName:    char, the field/variable name to look for
%
% OUTPUTS:
%    tf:         true if `varName` is present in `T`
%    bool:       logical (vector for a table, scalar for a struct)
%                indicating which entries of `T` match `varName`
%    ind:        index of the match (1 for a struct; the column index/indices
%                for a table)

if isstruct(T)
    tf = isfield(T,varName);
    bool = tf;
    ind = 1;
else
    bool = ismember(T.Properties.VariableNames,varName);
    tf = any(bool);
    ind = find(bool);
end

end

