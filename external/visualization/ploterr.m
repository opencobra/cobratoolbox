function hh = ploterr(x, y, xerr, yerr, varargin)
%PLOTERR General error bar plot.
%
%
% Usage for the impatient
% =======================
%
%  X, Y: x and y axis values
%  xerr, yerr: if matrix relative error
%              if cell array lower and upper bound
%  LineSpec as in plot. Must be passed after yerr, before properties
%  Properties: 'logx', 'logy', 'logxy':
%                 toggles for logarithmic scaling, no value needed
%              'hhx', 'hhy', 'hhxy':
%                 relative handle sizes (Handle Height)
%
%  X, Y, xerr and yerr must be of the same size as long as dimensions are
%  not equal to 1, otherwise singletons are expanded. You can pass every-
%  thing you like, e.g. xerr={0, 20:29} and x=[(1:10)' (2:11)'] to
%  indicate a lower bound of 0 for all values and an upper bound of 20:29
%  for both columns (which result in two separate lines).
%
%
% USAGE
% =====
%
%   PLOTERR(X,Y,{LX,UX},{LY,UY}) plots the graph of vector X vs. vector Y 
%   with error bars specified by LX and UX in horizontal direction and
%   with error bars specified by LY and UY in vertical direction.
%   L and U contain the lower and upper error ranges for each point
%   in X resp. Y (L = lower, U = upper).  Each error bar ranges from L(i)
%   to U(i). X, LX and UX sizes may vary in singleton dimensions only, the
%   same accounts for Y, LY and UY. If any of X,Y,LX,UX,LY,UY is a matrix 
%   then each column produces a separate line.
%
%   PLOTERR(X,Y,EX,EY) plots X vs. Y with x error bars [X-XE X+XE] and y
%   error bars [Y-YE Y+YE].
%
%   PLOTERR(X,Y,[],EY) plots no x error bars
%   PLOTERR(X,Y,EX,[]) plots no y error bars
%   PLOTERR(X,Y,EX,{LY,UY}) plots x error bars [X-XE X+XE] and y error bars
%   [LY UY]
%   ... etc ...
%
%   PLOTERR(X,Y,EX,EY,LineSpec) uses the color and linestyle specified by
%   the string 'LineSpec'. See PLOT for possibilities. Pass '' for default,
%   which is a solid line connecting the points (X,Y).
%
%   PLOTERR(X,Y,EX,EY,LineSpec,'Property1',Value1,'Property2',Value2,...)
%   Property Value pairs can be passed after LineSpec, however, LineSpec
%   does not need to be passed.
%   The Following properties are available:
%      'logx', 'logy', 'logxy': Logarithmic scaling of x axis, y axis or both
%   a value is not required. If you still specify a value, 0 turns logscale
%   off, 1 turns it on. E.g. PLOTERR(X,Y,EX,EY,'logx') plots on a logarithmi-
%   cally scaled x axis.
%      'hhx', 'hhy', 'hhxy': relative size of bar handles compared to the aver-
%   age distance of the datapoints. The default for hhx and hhy is 2/3,
%   indicating a total width of the handles of the bars of 2/3 of the mean
%   distance of datapoints in y. For logarithmic plots that is the mean
%   distance on a logarithmic scale. E.g. PLOTERR(X,Y,EX,EY,'logy','hhy',0.1)
%   plots normal x error bars and tiny y errorbars on a logarithmic y scale and
%   a linear x scale.
%
%   H = PLOTERR(...) returns a vector of line handles in this order:
%      H(1) = handle to datapoints
%      H(2) = handle to errorbar y OR errorbar x if error y not specified
%      H(3) = handle to errorbar x if error y specified
%   If more than one line is plotted, the ordering is the following:
%      H(1:n) = handle to lines with datapoints
%      H(n+1:2*n) = handle to y error bars
%      H(2*n+1:3*n) = handle to x erro bars
%
%
% Examples
% ========
%
%   Basic example:
%   -------------
%      x = 2:11;
%      y = sin(x);
%      e = std(y)*ones(size(x));
%      ploterr(x,y,e)
%
%   Draws symmetric error bars of unit standard deviation along a sine wave.
%   
%   Extended example:
%   -----------------
%      x = 0:15;
%      y=exp(-x).*(rand(1,16)*0.9+0.1);
%      h=ploterr(x,y,0.3,{exp(-x)*0.1 exp(-x)},'r.','logy','hhxy',0.5)
%      set(h(2),'Color','b'), set(h(3),'Color','b')
%      legend(h,{'data' 'error x' 'error y'})
%   Draws samples of a noisy exponential function on a logarithmic y scale
%   with constant relative errors in x and variable absolute errors in y with
%   slim error bar handles. The lineseries objects are used to set the color
%   of the error bars and to display a legend.
%
%
% Acknowledgements
% ================
%
%  technique for plotting error bars
%  ---------------------------------
%   L. Shure 5-17-88, 10-1-91 B.A. Jones 4-5-93
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.19 $  $Date: 2002/06/05 20:05:14 $
%
%  modified for plotting horizontal error bars
%  -------------------------------------------
%   Goetz Huesken
%   e-mail: goetz.huesken(at)gmx.de
%   Date: 10/23/2006
%
%
% Version History
% ===============
%  
%  v1.0, October 2008: modification of errorbar_x by Goetz Huesken for
%          plotting horizontal and/or vertical errorbars and to support
%          logarithmic scaling.
%  v1.1, December 2008: changed the user interface. Handle sizes and
%          logarithmic scaling can now be set via properties. LineSpec is
%          not compulsory anymore when setting logscale or handle sizes.
%  v1.1.1, December 2008: bugfix of v1.1
%
%   Felix Zörgiebel
%   email: felix_z -> web.de
%   Date: 12/03/2008

%% read inputs, set default values
if nargin<1, error('Not enough input arguments.'), end
if nargin<2, y=x; x=[]; end
if nargin<3, xerr=[]; end
if nargin<4, yerr=[]; end

[symbol,logx,logy,hhx,hhy]=getproperties(varargin);

%% analyse and prepare inputs (this section is a little ugly, you are invited to improve it!)
if ndims(x)~=2 || ndims(y)~=2
    error('x and y must not have more than two dimensions!')
end

if isempty(x), x = (1:size(y,1))'; end

try [x,y]=expandarrays(x,y); catch error('x and y are not consistent in size.'), end

% check if xerror is relative or absolute
relxerr=false;
if ~iscell(xerr)
    if ~isempty(xerr)
        relxerr=true;
        xerr={-xerr, +xerr};
    else
        xerr={[],[]};
    end
elseif length(xerr)~=2
    error('xerr must have two entries (low and upper bounds) if it is a cell array,')
end

% make xerr and x and y values same size
try [xl,xh]=expandarrays(xerr{1},xerr{2}); catch error('xl and xh are not consistent in size.'), end
try [y,xl,ty,txl]=expandarrays(y,xl); catch error('xl and y are not consistent in size.'), end
if ty, y=y'; xl=xl'; txl=~txl; end % make sure x and y still match
if txl, xh=xh'; end % make sure xl and xh still match
try [y,xh]=expandarrays(y,xh); catch error('xh and y are not consistent in size.'), end
if relxerr
    try [xl,x,txl]=expandarrays(xl,x); catch error('xl and x are not consistent in size.'), end
    if txl, xh=xh'; end
    try [x,xh]=expandarrays(x,xh); catch error('xh and x are not consistent in size.'), end
    xl=x+xl; xh=x+xh;
end

% check if yerror is relative or absolute
relyerr=false;
if ~iscell(yerr)
    if ~isempty(yerr)
        relyerr=true;
        yerr={-yerr, +yerr};
    else
        yerr={[],[]};
    end
elseif length(yerr)~=2
    error('yerr must have two entries (low and upper bounds) if it is a cell array,')
end

% make yerr and x and y values same size
try [yl,yh]=expandarrays(yerr{1},yerr{2}); catch error('yl and yh are not consistent in size.'), end
try [x,yl,tx,tyl]=expandarrays(x,yl); catch error('yl and x are not consistent in size.'), end
if tx, x=x'; yl=yl'; tyl=~tyl; end % make sure x and y still match
if tyl, yh=yh'; end % make sure yl and yh still match
try [x,yh]=expandarrays(x,yh); catch error('yh and x are not consistent in size.'), end
if relyerr
    try [y,yl]=expandarrays(y,yl); catch error('yl and y are not consistent in size.'), end
    try [y,yh]=expandarrays(y,yh); catch error('yh and y are not consistent in size.'), end
    yl=y+yl; yh=y+yh;
end

% choose the appropriate function for the plot
if      logx &&  logy, plotfct=@loglog;
elseif  logx && ~logy, plotfct=@semilogx;
elseif ~logx &&  logy, plotfct=@semilogy;
else                   plotfct=@plot;
end

% LineSpec setup
[ls,col,mark,msg] = colstyle(symbol); if ~isempty(msg), error(msg); end
symbol = [ls mark col]; % Use marker only on data part
esymbol = ['-' col]; % Make sure bars are solid

%% do the plotting
hold_state = ishold;
h=[];

% plot specified data
if ~isempty(xl) % x errorbars
    [bary,barx]=barline(y,xl,xh,logy,hhx);
    h = plotfct(barx,bary,esymbol); hold on
end
if ~isempty(yl) % y errorbars
    [barx,bary]=barline(x,yl,yh,logx,hhy);
    h = [plotfct(barx,bary,esymbol);h]; hold on
end
if ~isempty(y) % function values
    h = [plotfct(x,y,symbol);h];
end

if ~hold_state, hold off; end

if nargout>0, hh = h; end

end

%% helper functions
function [perp,para] = barline(v,l,h,uselog,handleheight_rel)
% v: value "perpendicular"
% l: lower bound "parallel"
% h: upper bound "parallel"
    
    [npt,n]=size(l);
    
    % calculate height of errorbar delimiters
    
    % set basic operations for linear spacing
    diff=@minus;
    invdiff=@plus;
    scale=@times;
    
    if uselog
        % overwrite basic operations for logarithmic spacing
        diff=@rdivide;
        invdiff=@times;
        scale=@power;
    end
    
    % set width of ends of bars to 2/3 of the mean distance of the bars,
    % only if number of points is under 15, space as if 15 points were there.
    if diff(max(v(:)),min(v(:)))==0
      dv = scale(abs(v),1/40) + (abs(v)==0);
    else
      dv = scale(diff(max(v(:)),min(v(:))),1/max(15,npt-1)*handleheight_rel/2);
    end
    vh = invdiff(v,dv);
    vl = diff(v,dv);

    % build up nan-separated vector for bars
    para = zeros(npt*9,n);
    para(1:9:end,:) = h;
    para(2:9:end,:) = l;
    para(3:9:end,:) = NaN;
    para(4:9:end,:) = h;
    para(5:9:end,:) = h;
    para(6:9:end,:) = NaN;
    para(7:9:end,:) = l;
    para(8:9:end,:) = l;
    para(9:9:end,:) = NaN;

    perp = zeros(npt*9,n);
    perp(1:9:end,:) = v;
    perp(2:9:end,:) = v;
    perp(3:9:end,:) = NaN;
    perp(4:9:end,:) = vh;
    perp(5:9:end,:) = vl;
    perp(6:9:end,:) = NaN;
    perp(7:9:end,:) = vh;
    perp(8:9:end,:) = vl;
    perp(9:9:end,:) = NaN;
end

function [A,B,tA,tB] = expandarrays(A,B)
% A, B: Matrices to be expanded by repmat to have same size after being processed
% tA, tB: indicate wether A or B have been transposed
    sizA=size(A); tA=false;
    sizB=size(B); tB=false;
    % do not process empty arrays
    if isempty(A) || isempty(B), return, end
    % make vectors column vectors
    if sizA(1)==1, A=A(:); tA=~tA; sizA=sizA([2 1]); end
    if sizB(1)==1, B=B(:); tB=~tB; sizB=sizB([2 1]); end
    % transpose to fit column, if necessary
    if sizA(2)==1 && sizB(2)~=1 && sizB(2)==sizA(1) && sizB(1)~=sizA(1), B=B'; tB=~tB; sizB=sizB([2 1]); end
    if sizB(2)==1 && sizA(2)~=1 && sizA(2)==sizB(1) && sizB(1)~=sizB(1), A=A'; tA=~tA; sizA=sizA([2 1]); end
    % if only singletons need to be expanded, do it
    if all(sizA==sizB | sizA==1 | sizB==1)
        singletonsA=find(sizA==1 & sizB~=1);
        repA=ones(1,2);
        repA(singletonsA)=sizB(singletonsA);
        A=repmat(A,repA);
        singletonsB=find(sizB==1 & sizA~=1);
        repB=ones(1,2);
        repB(singletonsB)=sizA(singletonsB);
        B=repmat(B,repB);
    else % otherwise return error
        error('Arrays A and B must have equal size for all dimensions that are not singleton!')
    end
end

function [sym,lx,ly,hx,hy] = getproperties(A)
lx=0; ly=0; hx=2/3; hy=2/3; sym='-'; % presets
if isempty(A), return, end
[k,k,k,errmsg]=colstyle(A{1});
if isempty(errmsg)
    sym = A{1}; % get symbol from first entry if it is a style
    A=A(2:end); % skip symbol for properties
end
n=length(A);
A=[A '!"§$%&()=?']; % append some stupid string for the case that the last property comes without a value
idx=1;
while idx <= n
    prop=A{idx};
    val=A{idx+1};
    switch prop
     case 'logx'
        if isnumeric(val), lx=val;
        else lx=1; idx=idx-1;
        end
     case 'logy'
        if isnumeric(val), ly=val;
        else ly=1; idx=idx-1;
        end
     case 'logxy'
        if isnumeric(val), ly=val; lx=val;
        else ly=1; lx=1; idx=idx-1;
        end
     case 'hhx'
        if isnumeric(val), hx=val;
        else error('Property hhx must be followed by a numerical value.');
        end
     case 'hhy'
        if isnumeric(val), hy=val;
        else error('Property hhy must be followed by a numerical value.');
        end
     case 'hhxy'
        if isnumeric(val), hy=val; hx=val;
        else error('Property hhxy must be followed by a numerical value.');
        end
     otherwise
        if ischar(prop), error(['Unknown property: ' prop])
        else error('Parsed a property that is not a string.')
        end
    end
    idx=idx+2;
end
end