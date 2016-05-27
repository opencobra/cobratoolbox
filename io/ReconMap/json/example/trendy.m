%% From Trendy to MATLAB
% This is an example of how we can use the JSON parser to take
% data directly from Trendy (such as this 
% <http://www.mathworks.com/matlabcentral/trendy/trends/1282 trend for Cody
% problem count>) and bring them into MATLAB.

%% Start with the trend ID

trendId = 1282;

%% Generate the URL for the trend
urlPrefix = 'http://www.mathworks.com/matlabcentral/trendy/trends';

url = sprintf('%s/%d',urlPrefix,trendId)

%% Append the suffix "trend_data.json"

urlSuffix = 'trend_data.json';
urlJson = sprintf('%s/%d/%s',urlPrefix,trendId,urlSuffix)

%% Read and Parse the XML

xml = urlread(urlJson);
vals = JSON.parse(xml);

%% Put the values into MATLAB variables

t = zeros(size(vals));
d = zeros(size(vals));

for i = 1:length(vals)
    t(i) = vals{i}{1};
    d(i) = str2num(vals{i}{2}{1});
end

%% Plot

plot(t,d)
datetick
title('Number of Cody Problems Over Time')