function x = cpltaxes(z)
%CPLTAXES   Determine suitable AXIS for plot of complex vector.
%           X = CPLTAXES(Z), where Z is a complex vector,
%           determines a 4-vector X such that AXIS(X) sets axes for a plot
%           of Z that has axes of equal length and leaves a reasonable amount
%           of space around the edge of the plot.

%           Called by FV, GERSH, PS and PSCONT.

% Set x and y axis ranges so both have the same length.

xmin = min(real(z)); xmax = max(real(z));
ymin = min(imag(z)); ymax = max(imag(z));

% Fix for rare case of `trivial data'.
if xmin == xmax, xmin = xmin - 1/2; xmax = xmax + 1/2; end
if ymin == ymax, ymin = ymin - 1/2; ymax = ymax + 1/2; end

if xmax-xmin >= ymax-ymin
   ymid = (ymin + ymax)/2;
   ymin =  ymid - (xmax-xmin)/2; ymax = ymid + (xmax-xmin)/2;
else
   xmid = (xmin + xmax)/2;
   xmin = xmid - (ymax-ymin)/2; xmax = xmid + (ymax-ymin)/2;
end
axis('square')

% Scale ranges by 1+2*alpha to give extra space around edges of plot.

alpha = 0.1;
x(1) = xmin - alpha*(xmax-xmin);
x(2) = xmax + alpha*(xmax-xmin);
x(3) = ymin - alpha*(ymax-ymin);
x(4) = ymax + alpha*(ymax-ymin);

if x(1) == x(2), x(2) = x(2) + 0.1; end
if x(3) == x(4), x(4) = x(3) + 0.1; end
