function dispMatrix(A, mode)
% display a matrix A in a tight format
%
% USAGE:
%
%    dispMatrix(A, mode)
%
% INPUTS:
%    A:       m x n matrix
%
% OPTIONAL INPUTS:
%    mode:    format used to display `A` (char, default = 'Z'):
%
%               * 'disp'     - display `A` using `disp`
%               * 'N'        - one space-separated natural number per entry
%               * 'Z'        - integers, right-aligned to a common width
%               * 'nonzeroZ' - same as `'Z'`, after removing all-zero rows/columns
%               * 'nonzeroN' - same as `'N'`, after removing all-zero rows/columns
%
% NOTE:
%    Adapted from https://stackoverflow.com/questions/7919004/tightening-the-display-of-matrices-in-matlab

if ~exist('mode','var')
    mode='Z';
end

switch mode
    case 'disp'
        disp(A)
    case 'N'
        fprintf([repmat('%d ',1,size(A,2)) '\n'],A');
    case 'Z'
        fprintf([repmat(sprintf('%% %dd',max(floor(log10(abs(A(:)))))+2+any(A(:)<0)),1,size(A,2)) '\n'],A');
    case 'nonzeroZ'
        A = removeZeroRowsCols(A);
        fprintf([repmat(sprintf('%% %dd',max(floor(log10(abs(A(:)))))+2+any(A(:)<0)),1,size(A,2)) '\n'],A');
    case 'nonzeroN'
        A = removeZeroRowsCols(A);
        fprintf([repmat('%d ',1,size(A,2)) '\n'],A');
        
        
end

end

