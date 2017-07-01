function res = reaction2sparse(s)
tmp = regexp(s, '\s*=\s*', 'split');
left = regexp(tmp{1}, '\s*\+\s*', 'split');
right = regexp(tmp{2}, '\s*\+\s*', 'split');

res = sparse([]);

d = regexp(left, '\s*(\d+ )?C(\d\d\d\d\d)\s*', 'tokens');
for i = 1:length(d)
    d{i}{1} = d{i}{1}(~cellfun('isempty',d{i}{1}));
    if length(d{i}{1}) == 1
        cid = str2double(d{i}{1}{1});
        coeff = -1;
    else
        coeff = -str2double(d{i}{1}{1});
        cid = str2double(d{i}{1}{2});
    end
    if (cid > length(res)) % first instance of this CID
        res(cid) = coeff;
    else % not the first instance
        res(cid) = res(cid) + coeff;
    end
end

d = regexp(right, '\s*(\d+ )?C(\d\d\d\d\d)\s*', 'tokens');
for i = 1:length(d)
    d{i}{1} = d{i}{1}(~cellfun('isempty',d{i}{1}));
    if length(d{i}{1}) == 1
        cid = str2double(d{i}{1}{1});
        coeff = 1;
    else
        coeff = str2double(d{i}{1}{1});
        cid = str2double(d{i}{1}{2});
    end
    if (cid > length(res)) % first instance of this CID
        res(cid) = coeff;
    else % not the first instance
        res(cid) = res(cid) + coeff;
    end
end
