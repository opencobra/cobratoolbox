function [tf, bool,ind] = isvar(T,varName)
%checks if varName is a column of table T

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

