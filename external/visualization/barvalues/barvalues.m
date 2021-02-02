function varargout = barvalues(h,precision)
% BARVALUES  Display bar values ontop of bars in bar or histogram plot.
% SYNTAX:
% barvalues;                  - operates on currnet axes.
% barvalues(h);               - operates on h.
% barvalues(_,precision);     - additionaly, specifies the precision of
%                               displayed values. or format.
% t = barvalues(_,_);         - returns the handles to the value text objects.
% 
% h - handle to axes or bar (operates on specified object only) 
%     or figure (operates on all child axes).
%  
% precision - Decimal precision to display (0-10),
%             or 'formatSpec' as in num2str. (default:'% .0f')
%
% t - handles to the text objects.
%   
%   For more information about 'formatSpec': 
%   See also NUM2STR.

%Author: Elimelech Schreiber, 11/2017 
% ver 2.1    - updated 04/2018

t=[];

if nargin>1 && ~isempty(precision) % Parse precision
    if isnumeric(precision) && precision >=0 && precision <=10
        precision =['% .',int2str(precision),'f'];
    elseif ~ischar(precision) && ~isstring(precision)
        error('Precision format unsupported.');
    end
else
    precision ='% .0f';
end

if nargin<1 || isempty(h)   % parse h (handle)
    h =gca;
elseif isaType(h,'figure')
   B = findobj(h,'type','bar','-or','type','Histogram'); % apply to multiple axes in figure.
   for b =B'
           t = [t; {barvalues(b,precision)}]; % Return array of text objects
                                              % for each bar plot.
   end
    if nargout>0
        varargout{1}=t;
    end
    return;
end
if isaType(h,'axes')
    h  = findobj(h,'type','bar','-or','type','Histogram','-or','type','patch');
    if isempty(h)
        return; % silently. to support multiple axes in figure.
    end
end
h = h(isaType(h,'bar') | isaType(h,'patch') | isaType(h,'histogram'));
if isempty(h)
    error('Cannot find bar plot.');
end
if size(h,1)>size(h,2)
    h=h';
end
for hn = h 
    axes(ancestor(hn,'axes')); % make intended axes curent.
    if isaType(hn,'histogram')
        t =[t;  histvalues(hn,precision)];
        continue;
    end   
    if isfield(hn,'XOffset')&&~isempty(hn.XOffset)
        XOffset = hn.XOffset;
    else
        XOffset = 0; 
    end
    if isfield(hn,'YOffset')&&~isempty(hn.YOffset)
        YOffset = hn.YOffset; 
    else
        YOffset = 0;
    end
    xData = hn.XData +XOffset;
    yData = hn.YData +YOffset;
    if size(xData,1)==4
      xData=mean(xData);
      yData=yData(2,:);
    end     
    t = [t;  text(xData,yData,...    %position
       arrayfun(@(x)num2str(x,precision),yData,'UniformOutput' ,false),...    %text to display
        'HorizontalAlignment','center','VerticalAlignment','bottom')];
end
if nargout>0
    varargout{1}=t;
end

function flag =isaType(h,type)
try
    flag =strcmpi(get(h, 'type'), type); 
catch
    flag =false;
end


function flag = isfield(h,fld)
flag =true;
try
    get(h,fld);
catch
    flag =false;
end


function t =histvalues(h,precision)
   hn=h;
    axes(ancestor(hn,'axes')); % make intended axes curent.
%     if isfield(hn,'XOffset')&&~isempty(hn.XOffset), XOffset = hn.XOffset; else XOffset = 0; end
%     if isfield(hn,'YOffset')&&~isempty(hn.YOffset), YOffset = hn.YOffset; else YOffset = 0; end
    xData = (hn.BinEdges(1:end-1) + hn.BinEdges(2:end))/2; yData = hn.Values;
     
    t = text(xData,yData,...    %position
       arrayfun(@(x)num2str(x,precision),yData,'UniformOutput' ,false),...    %text to display
        'HorizontalAlignment','center','VerticalAlignment','bottom');