function removed = removeIndicesInDimenion(input,dimension,indices)
% Remove the indices in a specified field in the given dimension
% USAGE:
%    removed = removeIndicesInDimenion(input, dimension, indices)
%
% INPUTS:
%
%    input:              The input matrix or array
%    dimension:          The dimension from which to remove the indices
%    indices:            The indices to remove
%
% OUTPUT:
%
%    removed:          The array/matrix with the given indices removed.
%
% NOTE:  
%     Based on https://stackoverflow.com/questions/22537326/on-shape-agnostic-slicing-of-ndarrays
%
% .. Authors: 
%                   - Thomas Pfau Sept 2017, adapted to merge all fields.

inputDimensions = ndims(input);
S.subs = repmat({':'},1,inputDimensions);
S.subs{dimension} = indices;
S.type = '()';
removed = subsref(input,S);