function printTable(data, opts)
s = '';
if isempty(data)
    for i = 1:length(opts.properties)
        p = opts.properties{i};
        [j,k] = regexp(p.format,'[0-9]*');
        if isempty(p.format)
            f = '%s';
        else
            f = strcat('%', p.format(j:k), 's');
        end
        s = [s sprintf(f, p.title) ' '];
    end
    disp(s);
else
    for i = 1:length(opts.properties)
        p = opts.properties{i};
        if (isfield(data, p.var))
            [j,k] = regexp(p.format,'[0-9]*');
            data_i = data.(p.var);
            if p.format(k+1) == 's'
                data_len = str2double(p.format(j:k))-1;
                if numel(data_i) > data_len, data_i = data_i(1:data_len); end
            end
            s = [s sprintf(strcat('%',p.format), data_i) ' '];
        else
            s = [s sprintf(strcat('%',p.format), NaN) ' '];
        end
    end
    disp(s);
end
end
