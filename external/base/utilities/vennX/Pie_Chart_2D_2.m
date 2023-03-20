%%
% This is an example of how to create an exploded pie chart in MATLAB&#174;.
% 
% Read about the <http://www.mathworks.com/help/matlab/ref/pie.html |pie|> function in the MATLAB documentation.
%
% For more examples, go to <http://www.mathworks.com/discovery/gallery.html MATLAB Plot Gallery>
%
% Copyright 2012-2014 The MathWorks, Inc.

% Load the data for South American populations
load TypesOfEvidence.mat

% Calculate the total populations and percentage by country
total = sum(numbers);


% Create a pie chart with sections 3 and 6 exploded
figure;
pie(numbers, evidence)

% Add title
title('Types of evidence for neuronal mitochondria')
