%% Reading in JSON Strings
% This file is designed to help you oonvert JSON strings into MATLAB-usable
% data. Note that it works with a string, not a file, so you have to load
% in the file yourself.

%% Starting with a string
% Let's take a simple structure in JSON and load it. The JSON.m file is a
% MATLAB class with a single public method: JSON.parse()

str = '{"name":"North Carolina","capital":"Raleigh","population":"9,752,073"}';
data = JSON.parse(str)

%% 
% Now we can work with the data in MATLAB.

fprintf('The capital of %s is %s\n', ...
    data.name,data.capital)

%% Dealing with Numbers
% Be aware the numbers may be represented as strings or as numbers,
% depending on how they appear in the JSON text.

fprintf('The population of %s is %s\n', ...
    data.name, ...
    data.population)

%% 
% That looks good. But if you try to do math on the population, you're in
% for a surprise. Suppose we try to round to the nearest thousand.

round(data.population/1000)*1000

%%
% Not exactly what we want. So we can use
% <http://www.mathworks.com/help/matlab/ref/str2double.html str2double>
% like so:

round(str2double(data.population)/1000)*1000

%%
% If we are the ones making the JSON string in the first place, it might be
% preferable to store the number without the quotes. In this case

str = '{"name":"North Carolina","capital":"Raleigh","population":9752073}';
data = JSON.parse(str)

fprintf('Rounded to the nearest thousand, the population of %s is %d\n', ...
    data.name, ...
    round(data.population/1000)*1000)

%% Reading from Files
% Generally your JSON text will come from a file.

fname = 'capitals.json';
fid = fopen(fname);
raw = fread(fid,inf);
str = char(raw');
fclose(fid);

data = JSON.parse(str)

%% 
% The result in this case is a cell array of structures.

for n = 1:length(data)
    fprintf('The capital of %s is %s\n', ...
        data{n}.name,data{n}.capital)
end

