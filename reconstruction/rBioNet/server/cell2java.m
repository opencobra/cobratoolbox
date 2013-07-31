% Use: res = cell2java(data)
% Input: data - cell array. 1 or 2 dimensional
% Output: res - java.lang.String array
function res = cell2java(data,dim)
if nargin < 2
    dim = 1;
end
rows = size(data,1);
columns = size(data,2);

if rows == 1 && dim == 1% One dimension: String[]
    java_array = javaArray('java.lang.String',columns);
    for k=1:columns
        if isempty(data{k})
            continue;
        end
        
        if isnumeric(data{k})
            java_array(k) = java.lang.String(num2str(data{k}));
        else
            java_array(k) = java.lang.String(data{k});
        end
    end
else % Two dimension: String[][]
    java_array = javaArray('java.lang.String',rows,columns);
    for k = 1:rows
        for i = 1:columns
            if isempty(data{k,i})
                continue;
            end
            
            if isnumeric(data{k,i})
                java_array(k,i) = java.lang.String(num2str(data{k,i}));
            else
                java_array(k,i) = java.lang.String(data{k,i});
            end
        end
    end
end


res = java_array;