function violins = violinplot(data, cats, varargin)
%Violinplots plots violin plots of some data and categories
%   VIOLINPLOT(DATA) plots a violin of a double vector DATA
%
%   VIOLINPLOT(DATAMATRIX) plots violins for each column in
%   DATAMATRIX.
%
%   VIOLINPLOT(TABLE), VIOLINPLOT(STRUCT), VIOLINPLOT(DATASET)
%   plots violins for each column in TABLE, each field in STRUCT, and
%   each variable in DATASET. The violins are labeled according to
%   the table/dataset variable name or the struct field name.
%
%   VIOLINPLOT(DATAMATRIX, CATEGORYNAMES) plots violins for each
%   column in DATAMATRIX and labels them according to the names in the
%   cell-of-strings CATEGORYNAMES.
%
%   VIOLINPLOT(DATA, CATEGORIES) where double vector DATA and vector
%   CATEGORIES are of equal length; plots violins for each category in
%   DATA.
%
%   violins = VIOLINPLOT(...) returns an object array of
%   <a href="matlab:help('Violin')">Violin</a> objects.
%
%   VIOLINPLOT(..., 'PARAM1', val1, 'PARAM2', val2, ...)
%   specifies optional name/value pairs for all violins:
%     'Width'        Width of the violin in axis space.
%                    Defaults to 0.3
%     'Bandwidth'    Bandwidth of the kernel density estimate.
%                    Should be between 10% and 40% of the data range.
%     'ViolinColor'  Fill color of the violin area and data points.
%                    Defaults to the next default color cycle.
%     'ViolinAlpha'  Transparency of the violin area and data points.
%                    Defaults to 0.3.
%     'EdgeColor'    Color of the violin area outline.
%                    Defaults to [0.5 0.5 0.5]
%     'BoxColor'     Color of the box, whiskers, and the outlines of
%                    the median point and the notch indicators.
%                    Defaults to [0.5 0.5 0.5]
%     'MedianColor'  Fill color of the median and notch indicators.
%                    Defaults to [1 1 1]
%     'ShowData'     Whether to show data points.
%                    Defaults to true
%     'ShowNotches'  Whether to show notch indicators.
%                    Defaults to false
%     'ShowMean'     Whether to show mean indicator
%                    Defaults to false

% Copyright (c) 2016, Bastian Bechtold
% This code is released under the terms of the BSD 3-clause license

    hascategories = exist('cats') && not(isempty(cats));

    % tabular data
    if isa(data, 'dataset') || isstruct(data) || istable(data)
        if isa(data, 'dataset')
            colnames = data.Properties.VarNames;
        elseif istable(data)
            colnames = data.Properties.VariableNames;
        elseif isstruct(data)
            colnames = fieldnames(data);
        end
        catnames = {};
        for n=1:length(colnames)
            if isnumeric(data.(colnames{n}))
                catnames = [catnames colnames{n}];
            end
        end
        for n=1:length(catnames)
            thisData = data.(catnames{n});
            violins(n) = Violin(thisData, n, varargin{:});
        end
        set(gca, 'xtick', 1:length(catnames), 'xticklabels', catnames);

    % 1D data, one category for each data point
    elseif hascategories && numel(data) == numel(cats)
        cats = categorical(cats);
        catnames = categories(cats);
        for n=1:length(catnames)
            thisCat = catnames{n};
            thisData = data(cats == thisCat);
            violins(n) = Violin(thisData, n, varargin{:});
        end
        set(gca, 'xtick', 1:length(catnames), 'xticklabels', catnames);

    % 1D data, no categories
    elseif not(hascategories) && isvector(data)
        violins = Violin(data, 1, varargin{:});
        set(gca, 'xtick', 1);

    % 2D data with or without categories
    elseif ismatrix(data)
        for n=1:size(data, 2)
            thisData = data(:, n);
            violins(n) = Violin(thisData, n, varargin{:});
        end
        set(gca, 'xtick', 1:size(data, 2));
        if hascategories && length(cats) == size(data, 2)
            set(gca, 'xticklabels', cats);
        end

    end

end
