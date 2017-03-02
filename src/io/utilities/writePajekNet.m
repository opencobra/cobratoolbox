function writePajekNet(model)
% writePajekNet builds a metabolite centric directed graph from a COBRA model
% and outputs a graph in a .net format ready
% to use for most graph analysis software e.g. Pajek, it does one fba to
% set the link width equal to reaction fluxes
%
% Ex: A + B -> C (hypergraph) with v = 0 => no output (empty line)
%     if v>0 then it becomes A -> C; B -> C (graph)
%     if v<0 then the order is reversed
%
% INPUT
% model    a COBRA structured model
%
% OUTPUT
% .net     file containing the graph
%
% USAGE    cobra2net(model)
%
% Marouen BEN GUEBILA 20/01/2016

%reaction and metabolite number
m = length(model.mets);
n = length(model.rxns);

%performs one FBA
FBA = solveCobraLPCPLEX(model, 1, 0, 0, [], 0);

%creats a .net file
fileID = fopen('COBRAmodel.net', 'w');
l = 0;  % initialize edge number

% write node id
fprintf(fileID, '*Vertices %d\n', m);

for i = 1:m
    fprintf(fileID, [num2str(i) ' "' model.mets{i} '"\n']);
end

for i = 1:n
    % cleans graph from biomass
    biomassRxn = strfind(model.rxns{i}, 'biomass');

    % cleans graph from objective functions
    objRxn = strfind(model.rxns{i}, 'objective');
    if isequal(biomassRxn, []) && isequal(objRxn, [])
        biomassRxn = 0;
    else
        biomassRxn = 1;
    end

    if (FBA.full(i) == 0 || biomassRxn)
        continue %controls for active reactions
    else
        metPos = find(model.S(:, i) > 0);
        metNeg = find(model.S(:, i) < 0);

        %cleans graph from demand and sink reactions
        if isequal(metPos, zeros(0, 1)) || isequal(metNeg, zeros(0, 1))
            continue
        end
        l = l + (length(metNeg) * length(metPos));
    end
end

%write edge number
fprintf(fileID, '*Edges %d\n', l);

for i = 1:n
    biomassRxn = strfind(model.rxns{i}, 'biomass');
    objRxn = strfind(model.rxns{i}, 'objective');

    if isequal(biomassRxn, []) && isequal(objRxn, [])
        biomassRxn = 0;
    else
        biomassRxn = 1;
    end

    if (FBA.full(i) == 0 || biomassRxn)
        continue
    else
        metPos = find(model.S(:, i) > 0);
        metNeg = find(model.S(:, i) < 0);

        if isequal(metPos, zeros(0, 1)) || isequal(metNeg, zeros(0, 1))
            continue
        end

        for j = 1:length(metNeg)
            for k = 1:length(metPos)
                %take into account flux value and directionality
                if FBA.full(i) > 0
                    fprintf(fileID, [num2str(metNeg(j)) ' ' num2str(metPos(k)) ' ' num2str(abs(FBA.full(i))) '\n']);  % write edges
                else
                    fprintf(fileID, [num2str(metPos(k)) ' ' num2str(metNeg(j)) ' ' num2str(abs(FBA.full(i))) '\n']);
                end

                l = l + 1;
            end
        end
    end
end

%close file
fclose(fileID);

end
