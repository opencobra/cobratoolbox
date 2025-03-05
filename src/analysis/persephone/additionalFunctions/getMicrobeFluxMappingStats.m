% INPUT: saveDirStats
saveDirStats = [rootDir filesep 'results' filesep 'statistics'];
%saveDirStats = '';

% Preallocate cell array
rows = ["PD significant metabolites";...
"Number of significant metabolites ";...
"Number of microbes that influence metabolites";...
"Microbes present in over 10 percent of samples";...
"Best correlating microbes";...
"Second best correlating microbes";...
"R2 of best correlating microbes";...
"R2 of second best correlating microbes";...
"Direction of significant metabolites";...
"Direction of change in patients of top microbe";...
"p-value of most altered microbe";...
"FDR of most altered microbe";...
"Direction of change in patients of second microbe";...
"p-value of second most altered microbe";...
"FDR of second most altered microbe"];

data = [cellstr(rows) cell(length(rows),4)];
i=0;
% Get the four top metabolites
mets = cellstr(results.Fluxes.Metabolite(1:4))';
i=i+1;data(i,2:end) = mets;

% Get the number of significant metabolites
i=i+1;data(i,2:3) = num2cell([sum(results.Fluxes.pValue<0.05) sum(results.Fluxes.FDR<0.05)]);

% Get the number of microbes that influence these metabolites
fluxMicrobeAssoc=readtable(fluxMicrobeInfluences,'Sheet','taxa summary stats','VariableNamingRule','preserve','ReadRowNames',false);
i=i+1;data(i,2:end) = num2cell(fluxMicrobeAssoc.("Total microbes")(matches(fluxMicrobeAssoc.Reaction,mets)));

% Microbes present in over 10 percent of samples
i=i+1;data(i,2:end) = num2cell([sum(~isnan(fluxMicrobeCorr{:,:}))]);

% Best correlating microbes

topMicrobes = cell(2,4);
topMicrobeR2 = cell(2,4);
for j=1:4
    varnames = string(fluxMicrobeCorr.Properties.VariableNames);
    R2met = fluxMicrobeCorr(:,varnames(j));
    R2met.(varnames(j))(isnan(R2met.(varnames(j))))=0;
    R2met = sortrows(R2met,varnames(j),'descend');
    topMicrobes(:,j) = regexprep(R2met.Row(1:2),'_',' ');
    topMicrobeR2(:,j) = num2cell(R2met.(varnames(j))(1:2)*100);
end

data(i+1:i+2,2:end) = topMicrobes;
data(i+3:i+4,2:end) = topMicrobeR2;

% Find the direction of the top 4 metabolites
direction(results.Fluxes.("ln(OR)")(1:4)<0)={'decreased'};
direction(results.Fluxes.("ln(OR)")(1:4)>0)={'increased'};
i=i+5;data(i,2:end) = direction;

% Find direction of best correlating microbes
%
% TODO: Find correct order of microbes + add data to latex template

% Get the top microbes

% Correct microbe names
microbeCaseControl = replace(mappedResults.relativeAbundance.Microbe,'_',' ');

microbeAnalysisRes = cell(6,4);
counter = 0;
for k=1:height(topMicrobes)
    counter = counter + 1;
    for j=1:width(microbeAnalysisRes)
        % Find microbe index
        idx = find(matches(microbeCaseControl,string(topMicrobes(k,j))));
        
        % Check if microbe is increased or decreased in case
        if mappedResults.relativeAbundance.("ln(OR)")(idx)<0
            microbeAnalysisRes(counter,j) = {'decreased'};
        elseif mappedResults.relativeAbundance.("ln(OR)")(idx)>0
            microbeAnalysisRes(counter,j) = {'increased'};
        end
    end
    
    % Obtain p-value 
    counter = counter + 1;
    for j=1:width(microbeAnalysisRes)
        idx = find(matches(microbeCaseControl,string(topMicrobes(k,j))));
        microbeAnalysisRes(counter,j) = num2cell(mappedResults.relativeAbundance.("pValue")(idx));
    end
    % and FDR
    counter = counter + 1;
    for j=1:width(microbeAnalysisRes)
        idx = find(matches(microbeCaseControl,string(topMicrobes(k,j))));
        microbeAnalysisRes(counter,j) = num2cell(mappedResults.relativeAbundance.("FDR")(idx));
    end
end
% Add data to data variable
data(10:15,2:end)=microbeAnalysisRes;

writecell(data,[saveDirStats filesep 'microbeFluxData.txt'],'Delimiter',';')