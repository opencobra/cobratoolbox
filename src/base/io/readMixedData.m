function [id, data, header] = readMixedData(file, n_header, n_labels, delimiter, verbose)
% Read floating point data with row identifiers (text) in the first n columns
% and m headerlines (text)
%
% USAGE:
%
%    [id, data, header] = readMixedData(file, n_header, n_labels, delimiter, verbose)
%
% INPUTS:
%    file:      Filename
%    n_header:  Number of header lines (default 0)
%    n_labels:  Number of label columns (default 1)
%    delimiter: Delimiter character (default tab)
%    verbose:   Print out the string to be evaluated for debugging (default 0)
%
% .. Authors: Markus Herrgard 2/9/05

if (nargin < 2)
    n_header = 0;
end
if (nargin < 3)
    n_labels = 1;
end
if (nargin < 4)
    delimiter = '\t';
end
if (nargin < 5)
    verbose = 0;
end

% Figure out the # of columns
fid = fopen(file, 'r');
line = fgetl(fid);
tmp = splitString(line, delimiter);
ncol = length(tmp);
fclose(fid);

% Process header lines
if (n_header > 0)
    fid = fopen(file, 'r');
    for i = 1:n_header
        line = fgetl(fid);
        header_tmp = splitString(line, delimiter);
        header{i} = header_tmp;
    end
    fclose(fid);
    if (n_header == 1)
        header = header_tmp;
    end
else
    header = [];
end

% Create strings to be evaluated
tr_lh_str = '[';
tr_rh_str = [' = textread(''' file ''','''];
data_str = ['data = ['];
for i = 1:n_labels
    tr_lh_str = [tr_lh_str 'id' num2str(i)];
    tr_rh_str = [tr_rh_str ' %s'];
    if (i < n_labels)
        tr_lh_str = [tr_lh_str ','];
    end
end
for i = 1:ncol - n_labels
    tr_lh_str = [tr_lh_str ',d' num2str(i)];
    tr_rh_str = [tr_rh_str ' %f'];
    data_str = [data_str 'd' num2str(i) ' '];
end
tr_lh_str = [tr_lh_str ']'];
tr_rh_str = [tr_rh_str ''',''delimiter'',''' delimiter ''''];
if (n_header > 0)
    tr_rh_str = [tr_rh_str ',''headerlines'',' num2str(n_header) ');'];
else
    tr_rh_str = [tr_rh_str ');'];
end
data_str = [data_str '];'];

% Display and evaluate strings
if (verbose > 0)
    disp([tr_lh_str tr_rh_str])
    disp(data_str)
end
eval([tr_lh_str tr_rh_str]);
eval(data_str);

% Collect row labels
for i = 1:n_labels
    eval(['id{i} = id' num2str(i) ';']);
end

if (n_labels == 1)
    id = id1;
elseif (n_labels == 0)
    id = [];
end
