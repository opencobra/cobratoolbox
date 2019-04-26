function added = extendIndicesInDimenion(input,dimension,value, sizeIncrease)
% Remove the indices in a specified field in the given dimension
% USAGE:
%    added = extendIndicesInDimenion(input,dimension,indices)
%
% INPUTS:
%
%    input:              The input matrix or array
%    dimension:          The dimension in which to add values for the given
%                        indices
%    value:              The value to append in the given dimension.
%    sizeIncrease:       How many entries to add.
%
% OUTPUT:
%    added:              The Array/Matrix with the given indices set to the
%                        default values.
%
% .. Authors: 
%                   - Thomas Pfau Sept 2017, adapted to merge all fields.
% NOTE:  
%     Based on https://stackoverflow.com/questions/22537326/on-shape-agnostic-slicing-of-ndarrays

inputDimensions = ndims(input);
S.subs = repmat({':'},1,inputDimensions);
S.subs{dimension} = (size(input,dimension)+1):(size(input,dimension)+sizeIncrease);
S.type = '()';
if ~istable(input)
    added = subsasgn(input,S,value);
else
    % this can only happen for the first dimension, everything else will
    % error!
    added = [input;repmat(value,sizeIncrease,1)];
end