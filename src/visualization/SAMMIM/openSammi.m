function openSammi(htmlName)
% Visualize the given model, set of reactions, and/or data using SAMMI.
% Documentation at: https://sammim.readthedocs.io/en/latest/index.html
% 
% Citation: Schultz, A., & Akbani, R. (2019). SAMMI: A Semi-Automated 
%     Tool for the Visualization of Metabolic Networks. Bioinformatics.
% 
% USAGE:
% openSAMMI(htmlName)
% 
% OPTIONAL INPUT:
%   htmlName: Name of the html file previously written using the sammi
%   function. If left blank will print all available models.
% 
% OUTPUT:
%   No MATLAB output, opens the visualization in a new browser tab.

sammipath = strrep(which('sammi'),'sammi.m','');
if nargin < 1
    % htmlName = 'index_load.html';
    files = dir(sammipath);
    for i = 1:length(files)
        if contains(files(i).name,'.html')
            disp(files(i).name)
        end
    end
    return
elseif isempty(regexp(htmlName,'\.html$'))
    htmlName = [htmlName '.html'];
end
%Define path
filename = [sammipath htmlName];
if ~exist(filename,'file')
    warning(['Could not locate file ' filename])
    return
end
%Open file
web(filename,'-browser')
end