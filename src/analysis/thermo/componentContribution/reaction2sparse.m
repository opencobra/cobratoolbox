function res = reaction2sparse(s)
% Convert a KEGG-style reaction formula string into a sparse stoichiometric vector
%
% Parses a reaction string of the form `a C00001 + C00002 = C00003`, where
% each `Cddddd` is a KEGG compound identifier with an optional integer
% coefficient, and returns the net stoichiometric coefficients indexed by
% compound id (negative for substrates on the left, positive for products on
% the right).
%
% USAGE:
%
%    res = reaction2sparse(s)
%
% INPUT:
%    s:      char, KEGG-style reaction formula (e.g. `2 C00001 + C00002 = C00003`)
%
% OUTPUT:
%    res:    sparse row vector of net stoichiometric coefficients indexed by
%            KEGG compound id (CID)
%

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
