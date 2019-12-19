function [text,steps_text] = makeMixingTable(bodyType,samplers,dims)
if nargin < 2 || isempty(samplers)
    samplers = {'HMC_rk4','CHAR','HAR'};%'CHAR','HAR'};%, 'HMC_taylor', 'HMC_alt'};
end
if nargin < 3
    dims = [1e1,1e2,1e3,1e4];
end
% samplers = {'HAR'};
hmc_methods = containers.Map();
hmc_methods('HMC_rk4') = @RK4step;
% hmc_methods('HMC_taylor') = @TaylorStep;
% hmc_methods('HMC_alt') = @AltStep;

% bodyType = {'cube'};%,'simplex'};
options = [];
options.isFullDim=0;

row_headers = cell(length(dims),1);
col = 0;
col_headers = samplers;
mixing_data = zeros(length(row_headers),length(col_headers));
steps_to_mix = zeros(length(row_headers),length(col_headers));
for samplerType = samplers
    col = col+1;
    row = 0;
    for dim = dims
        row = row+1;
        row_headers{row} = num2str(dim);
        samplerName = samplerType{1};
        if contains(samplerName,'HMC')==1
            options.isFullDim = 0;
            %             bodyType = 'simplex';
            P = makeBody(bodyType,dim);
            options.method = hmc_methods(samplerName);
            options.walkType = 'HMC';
        elseif strcmp(samplerName,'CHAR')==1
            %             bodyType = 'standard_simplex';
            options.isFullDim = 1;
            P = makeBody(bodyType, dim);
            options.walkType = 'CHAR';
        elseif strcmp(samplerName,'HAR')==1
            %             bodyType = 'standard_simplex';
            options.isFullDim = 1;
            P = makeBody(bodyType,dim);
            options.walkType = 'HAR';
        end
        tic;
%         options.JL_dim = 1;
        if contains(samplerName,'HMC')==1
            options.numSamples = 50;
            options.numSteps = 1;
        else
            options.numSamples = dim;
            options.numSteps = dim/2;
        end
        options.warmup = 0;
        tic;
        x = sample(P,options);
        time_elapsed = toc;
        mt = halfspaceTest(x);
        mt = mt * options.numSteps;
        steps_to_mix(row,col) = mt;
        mixing_data(row,col) = time_elapsed / (options.numSamples*options.numSteps/mt );
    end
end

label = bodyType;
caption = strcat(bodyType,' time per effective sample.');
latexTable = makeLatexTable(col_headers,row_headers,mixing_data,caption,label);
fprintf(latexTable)
text = latexTable;

caption = strcat(bodyType,' steps per effective sample.');
latexTable = makeLatexTable(col_headers,row_headers,steps_to_mix,caption,label);
fprintf(latexTable)
steps_text = latexTable;
end