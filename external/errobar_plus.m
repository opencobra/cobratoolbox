function errobar_plus(x,y,e,prop,dir)
% By Nguyen Chuong 2004/06/30
% This is to the problem of legend in errorbar
% This function put an errobar range onto plot
% Usage similar to errorbar():
%   errobar_plus(x,y,e)
%   errobar_plus(x,y,e,prop)
%   errobar_plus(x,y,e,dir)
%   errobar_plus(x,y,e,prop,dir)
%   where prop is the property string like for plot()
%   and dir is the vertical or horizontal direction of error
% For example,
%        x = 1:10;
%        y = sin(x);
%        e = std(y)*ones(size(x));
%        errorbar(x,y,e,'ri')
%        figure
%        errorbar(x,y,e,'r^')
%     draws symmetric error bars of unit standard deviation.

if exist('prop')
	color_list='bgrcmyk';
	mark_list='.ox+*sdv^<>ph';
	color='b';
    for j=1:numel(prop)
    	for i=1:numel(color_list)
            if prop(j)==color_list(i)
               color=color_list(i);
               break
            end
        end
        if prop(j)==color_list(i)
           break
        end
	end
	mark='i';
    for j=1:numel(prop)
    	for i=1:numel(mark_list)
            if prop(j)==mark_list(i)
               mark=mark_list(i);
               break
            end
        end
        if prop(j)==mark_list(i)
           break
        end
	end
else
	color='b'; %default values
	mark='i';
end
if (exist('dir')==1) & (dir ~= 'v') & (dir ~= 'h')
    dir = 'v'; %default value
elseif exist('dir')==5 % not exist
    dir = 'v'; %default value
end
dx=(x(1)-x(end))/numel(x)/12; % for the case mark='i' only
dy=(y(1)-y(end))/numel(y)/12; % for the case mark='i' only
hold on
for i=1:numel(x)
    if dir == 'v' % vertical errobar
    plot([x(i) x(i)], [y(i)-e(i) y(i)+e(i)],color)
        switch lower(mark)
            case 'i'
                plot([x(i)-dx x(i)+dx], [y(i)-e(i) y(i)-e(i)],color)
                plot([x(i)-dx x(i)+dx], [y(i)+e(i) y(i)+e(i)],color)
            case '^'
                plot(x(i), y(i)-e(i),[color,'v'])
                plot(x(i), y(i)+e(i),[color,'^'])
            case 'v'
                plot(x(i), y(i)-e(i),[color,'^'])
                plot(x(i), y(i)+e(i),[color,'v'])
            otherwise
                plot([x(i) x(i)], [y(i)-e(i) y(i)+e(i)],[color,mark])
        end
    else    %horizontal errorbar
    plot([x(i)-e(i) x(i)+e(i)], [y(i) y(i)],color)
        switch lower(mark)
            case 'i'
                plot([x(i)-e(i) x(i)-e(i)], [y(i)-dy y(i)+dy],color)
                plot([x(i)+e(i) x(i)+e(i)], [y(i)-dy y(i)+dy],color)
            case '<'
                plot(x(i)-e(i), y(i),[color,'<'])
                plot(x(i)+e(i), y(i),[color,'>'])
            case '>'
                plot(x(i)-e(i), y(i),[color,'>'])
                plot(x(i)+e(i), y(i),[color,'<'])
            otherwise
                plot([x(i)-e(i) x(i)+e(i)], [y(i) y(i)],[color,mark])
        end
    end
end
hold off