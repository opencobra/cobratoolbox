function [ret] = parseFlags(flags)
%this file will parse the string "flags" into a N element map, where N is the
%number of flags provided
flagList = [
    'round '; %turn rounding on, and optionally provide R s.t. K \in R*B_n
    'a_0   '; %set starting Gaussian
    'verb  '; %set verbosity level=0,1,2. Default is 1.
    'ratio '; %set the ratio for annealing schedule
    'C     '; %bound for E(Y^2)/E(Y)^2<=C
    'num_t '; %set the number of threads
    'a_stop'; %set the end Gaussian, by default "0". 0.5 for standard Gaussian
    'c_test'; %the type of convergence test, only for Sample.m (not Volume.m)
    'min_st'; %set a minimum number of steps per phase
    'walk  '; %change the walk type, either ball, har (hit and run), char (coordinate har)
    'plot  '; %turn on plotting, will plot a 2-dim projection at each phase
    'plot_c'; %turn on plotting for the convergence test
    ];

possFlags = cellstr(flagList);
%create a map that will store our parameter/value pairs
ret = containers.Map;
if isempty(flags)==1
    return
end
if flags(1)~='-'
    error('Please reformat flags string, must begin with -.');
end


start_ind=2;
for i=2:size(flags,2)
    if(flags(i)=='-')
        addToMap(ret,strtrim(flags(start_ind:i-1)),possFlags);
        start_ind = i+1;
    end
end
addToMap(ret,strtrim(flags(start_ind:end)),possFlags);

end

function addToMap(map, entry, possFlags)
for i=1:size(entry,2)
    if entry(i)==' '
        key = entry(1:i-1);
        value = str2num(entry(i+1:end));
        if isempty(value)
            %if the conversion to double fails, then 
            %the value to this flag is a string (or empty)
            value = entry(i+1:end);
        end
        break;
    elseif i==size(entry,2)
        key=entry;
        value='';
    end
end

%now add it to the map
if max(ismember(possFlags,key))==1
    map(key) = value;
else
    fprintf('%s is not a valid flag, refer to parseFlags.m.\n',key);
    error('Please use valid flags, there is a list in parseFlags.m.');
end
end