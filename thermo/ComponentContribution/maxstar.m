function y = maxstar(x, w, dim)
% maxstar   Log of a sum of exponentials.
%   For vectors, maxstar(x) is equivalent to log(sum(exp(x))).
%   For matrices, maxstar(x) is a row vector and maxstar operates on 
%   each column of x. For N-D arrays, maxstar(x) operates along the
%   first non-singleton dimension.
%
%   maxstar(x,w) is the log of a weighted sum of exponentials,
%   equivalent to log(sum(w.*exp(x))). Vectors w and x must be
%   the same length. For matrix x, the weights w can be input as
%   a matrix the same size as x, or as a vector of the same length 
%   as columns of x. Weights may be zero or negative, but the result
%   sum(w.*exp(x)) must be greater than zero. 
%   
%   maxstar(x, [], dim) operates along the dimension dim, and has 
%   the same dimensions as the MATLAB function max(x, [], dim).
%
%   Note:
%   The max* function is described in Lin & Costello, Error Control
%   Coding, 2nd Edition, equation 12.127, in the two-argument form
%     max*(x1,x2) = max(x1,x2) + log(1 + exp(-abs(x1-x2))).
%   The function max* can be applied iteratively: 
%     max*(x1,x2,x3) = max*(max*(x1,x2),x3).
%   Functions max(x) ~ max*(x), and min(x) ~ -max*(-x).
%
%   Algorithm:
%   The double precision MATLAB expresson log(sum(exp(x))) fails 
%   if all(x < -745), or if any(x > 706). This is avoided using 
%   m = max(x) in  max*(x) = m + log(sum(exp(x - m))).
%
%   Example: If x = [2 8 4 
%                    7 3 9]
%
%   then maxstar(x,[],1) is [7.0067 8.0067 9.0067],
%
%   and  maxstar(x,[],2) is [8.0206    
%                            9.1291]. 
%
% 2006-02-10   R. Dickson
% 2006-03-25   Implemented N-D array features following a suggestion 
%              from John D'Errico.
%              
%   Uses: max, log, exp, sum, shiftdim, repmat, size, zeros, ones,
%         length, isempty, error, nargin, find, reshape

if nargin < 1 || nargin > 3
    error('Wrong number of input arguments.');
end

[x, n] = shiftdim(x);
szx = size(x); 

switch nargin
    case 1
        w = [];
        dim = 1;
    case 2 
        dim = 1;
    case 3
        dim = dim - n;
end

if isempty(w)
    % replicate m = max(x) to get mm, with size(mm) == size(x)
    m = max(x,[],dim);
    szm = ones(size(szx));
    szm(dim) = szx(dim);
    mm = repmat(m,szm);
    y = m + log(sum(exp(x - mm), dim));
else
    w = shiftdim(w);
    szw = size(w);
    % protect the second condition with a short-circuit or 
    if ~(length(szw) == length(szx)) || ~all(szw == szx)
        if size(w,1) == size(x,dim)
            % replicate w with repmat so size(w) == size(x)
            szw = ones(size(szx)); 
            szw(dim) = size(w,1);
            w = reshape(w, szw);
            szr = szx;
            szr(dim) = 1;
            w = repmat(w, szr);
        else
            error('Length of w must match size(x,dim).');
        end
    end
    
    % Move the weight into the exponent xw and find 
    % m = max(xw) over terms with positive weights
    ipos = find(w>0);
    xw = -Inf*zeros(szx);
    xw(ipos) = x(ipos) + log(w(ipos));
    m = max(xw,[],dim);
    % replicate m with repmat so size(mm) == size(x)
    szm = ones(size(szx));
    szm(dim) = szx(dim);
    mm = repmat(m,szm); 
    exwp = zeros(szx);
    exwp(ipos) = exp(xw(ipos)-mm(ipos));
    % check for terms with negative weights 
    ineg = find(w<0);
    if ~isempty(ineg)
        exwn = zeros(szx);
        exwn(ineg) = exp(x(ineg) + log(-w(ineg)) - mm(ineg));
        y = m + log(sum(exwp, dim) - sum(exwn, dim));
    else
        y = m + log(sum(exwp, dim));
    end
end


