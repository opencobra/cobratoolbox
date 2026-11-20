function removed = removeIndicesInDimenion(input, dimension, indices)
% Keep only the given indices of the input in the given dimension (all other entries in that dimension are removed)
%
% USAGE:
%
%    removed = removeIndicesInDimenion(input, dimension, indices)
%
% INPUTS:
%
%    input:              The input matrix or array
%    dimension:          The dimension in which to select the indices
%    indices:            The indices to keep (numeric indices or a logical vector); all other entries of that dimension are removed
%
% OUTPUT:
%
%    removed:          The array/matrix restricted to the given indices in the given dimension (all other entries of that dimension removed).
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