function dispMatrix(A,mode)
% display a matrix A in a tight format
%
% INPUT
% A     m x n matrix
% mode  'Z' integers (default)
%       'N' natural number
%

% from: https://stackoverflow.com/questions/7919004/tightening-the-display-of-matrices-in-matlab

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

