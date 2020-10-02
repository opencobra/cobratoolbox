function s = num2str(x, f)
%NUM2STR Convert number to string.
%   T = NUM2STR(X) converts the matrix X into a string representation T
%   with about 4 digits and an exponent if required.  This is useful for
%   labeling plots with the TITLE, XLABEL, YLABEL, and TEXT commands.
%
%   T = NUM2STR(X,N) converts the matrix X into a string representation
%   with a maximum N digits of precision.  The default number of digits is
%   based on the magnitude of the elements of X.
%
%   T = NUM2STR(X,FORMAT) uses the format string FORMAT (see SPRINTF for
%   details). 
%
%   Example:
%       num2str(randn(2,2),3) produces the string matrix
%
%       '-0.433    0.125'
%       ' -1.67    0.288'
%
%   See also INT2STR, SPRINTF, FPRINTF.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.32 $  $Date: 2002/04/09 00:33:35 $

if isstr(x)
   s = x;
   return
end

maxDigitsOfPrecision = 256;

if nargin < 2 & ~isempty(x) & all(all(x==fix(x)))
   % If there is an element in x that is negative and divisible by 10, 
   % then add 1 so log10 will return a non-integer.  Without the offset,
   % CEIL will not round up to the next highest integer for these elements
   % and there will not be enough whitespace to accommodate the minus
   % sign.
   %clv start
   %original    roundUp = any(rem(x(find(x<0 & isreal(x))),10)==0);
   q=find(x<0 & isreal(x));
   if isempty(q)
       roundUp=0;
   else
       roundUp=any(rem(x(q),10));
   end
   %original d = min(12,max(1,max(ceil(log10((abs(x(:))+(x(:)==0))+roundUp)))));
   d = (abs(x(:))+double(x(:)==0))+double(roundUp);
   d = log10(d);
   d = max(ceil(d));
   d = min(12,max(1,d))+4;
   %clv end
   f = ['%' sprintf('%d',d+2) 'd']; 
   fi = ['%-' sprintf('%d',d+2) 's'];
elseif nargin < 2
   %clv start
   %original roundUp = any(~rem(x(find(x<0 & isreal(x))),10));
   q=find(x<0 & isreal(x));
   if isempty(q)
       roundUp=0;
   else
       roundUp=any(~rem(x(q),10));
   end
   %original d = min(11,max(1,max(ceil(log10((abs(x(:))+(x(:)==0))+roundUp)))))+4;
   d = (abs(x(:))+double(x(:)==0))+double(roundUp);
   d = log10(d);
   d = max(ceil(d));
   d = min(11,max(1,d))+4;
   %clv end
   f = ['%' int2str(d+7) '.' int2str(d) 'g'];
   fi = ['%-' int2str(d+7) 's'];
elseif ~isstr(f)
    % Windows gets a segmentation fault at around 512 digits of precision,
    % as if it had an internal buffer that cannot handle more than 512 digits
    % to the RIGHT of the decimal point. Thus, allow half of the windows buffer
    % of digits of precision, as it should be enough for most computations.
    % Large numbers of digits to the LEFT of the decimal point seem to be allowed.
    if f > maxDigitsOfPrecision
        error('MATLAB:num2str:exceededMaxDigitsOfPrecision', 'Exceeded maximum %d digits of precision.',maxDigitsOfPrecision);
    end
   fi = ['%-' int2str(f+7) 's'];
   f = ['%' int2str(f+7) '.' int2str(f) 'g'];
else
  % Sanity check on format
  k = find(f=='%');
  if isempty(k), error('MATLAB:num2str:fmtInvalid', '''%s'' is an invalid format.',f); end
  % If digits of precision to the right of the decimal point are specified,
  % make sure it will not cause a segmentation fault on windows.
  dotPositions = find(f=='.');
  if ~isempty(dotPositions)
      decimalPosition = find(dotPositions > k(1)); % dot to the right of %
      if ~isempty(decimalPosition)
          digitsOfPrecision = sscanf(f(dotPositions(decimalPosition(1))+1:end),'%d');
          if digitsOfPrecision > maxDigitsOfPrecision
              error('MATLAB:num2str:exceededMaxDigitsOfPrecision', 'Exceeded maximum %d digits of precision.',maxDigitsOfPrecision);
          end
      end
  end
  d = sscanf(f(k(1)+1:end),'%f');
  if isempty(d), error('MATLAB:num2str:fmtFieldWidth', 'Format must contain field width.'); end
  fi = ['%-' int2str(d) 's'];
end

[m,n] = size(x);
s = '';
for i = 1:m,
   t = [];
   for j = 1:n,

      u = sprintf(f, real(x(i,j)));
      % If we are printing integers and have overflowed, then
      % add in an extra space.
      if (real(x(i,j)) > 2^31-1) & (~isempty(findstr(f,'d')))
        u = [' ' u];
      end 
      if ~isreal(x) & imag(x(i,j)) == 0,
          u = [u '+' formatimag(f,fi,0)];
      elseif imag(x(i,j)) > 0
          u = [u '+' formatimag(f,fi,imag(x(i,j)))];
      elseif imag(x(i,j)) < 0
          u = [u '-' formatimag(f,fi,-imag(x(i,j)))];
      end
      t = [t u];
   end
   s = strvcat(s,t);
end

s = lefttrim(s);

% If it's a scalar remove the trailing blanks too.
if length(x)==1,
  s = deblank(s);
end

%-----------------------
function v = formatimag(f,fi,x)
% Format imaginary part
v = [sprintf(f,x) 'i'];
v = lefttrim(v);
v = sprintf(fi,v);


%-----------------------
function s = lefttrim(s)
% Remove leading blanks
if ~isempty(s)
  [r,c] = find(s ~= ' ');
  if ~isempty(c)
    s = s(:,min(c):end);
  end
end
