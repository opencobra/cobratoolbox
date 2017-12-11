function [newmap] = defaultLookMap(map)
% Give default look to structures on map in terms of color, size and areaWidth.
%
% USAGE:
%
%   [newmap] = defaultLookMap(map)
%
%   INPUT:
%   map:        Map from CellDesigner parsed to matlab format
%
% OUTPUT:
%   newmap:     MATLAB structure of new map with default look
%
% NOTE:
%   Note that this is specific to MitoMap and Recon3Map, as it uses Recon3
%   and PDmap nomenclature for metabolites
%
% .. Authors:
%       - A.Danielsdottir 01/08/2017 LCSB. Belval. Luxembourg
%       - N.Sompairac - Institut Curie, Paris, 01/08/2017.

    newmap = map;
    colors = createColorsMap();

    % Set all rxn lines to black and normal areaWidth
    color = 'BLACK';
    areaWidth = 1.0;

    for j = 1:length(newmap.rxnName)
        newmap.rxnColor{j} = colors(color);
        newmap.rxnWidth{j} = areaWidth;
    end

    % Use the existence of reactant lines to check if the map has the
    % complete structure, and if so change also secondary lines.
    if any(strcmp('rxnReactantLineColor', fieldnames(map))) == 1
        for j = 1:length(newmap.rxnName)
            if ~isempty(newmap.rxnReactantLineColor{j})
                for k = 1:length(map.rxnReactantLineColor{j})
                    newmap.rxnReactantLineColor{j, 1}{k, 1} = colors(color);
                    newmap.rxnReactantLineWidth{j, 1}{k, 1} = areaWidth;
                end
            end
            if ~isempty(newmap.rxnProductLineColor{j})
                for m = 1:1:length(newmap.rxnProductLineColor{j})
                    newmap.rxnProductLineColor{j, 1}{m, 1} = colors(color);
                    newmap.rxnProductLineWidth{j, 1}{m, 1} = areaWidth;
                end
            end
        end
    end

    % Start with giving all simple molecules the CellDesigner default color and size
    smID = newmap.specID(ismember(newmap.specType, 'SIMPLE_MOLECULE'));
    smAlias = find(ismember(newmap.molID, smID));

    for i = smAlias'
        newmap.molColor{i} = 'ffccff66';
        newmap.molWidth{i} = '70';
        newmap.molHeight{i} = '25';
    end
    % Use the existence of reactant lines to check if the map has the
    % complete structure, and if so change also included species.
    if any(strcmp('rxnReactantLineColor', fieldnames(map))) == 1
        smIncID = newmap.specIncID(ismember(newmap.specIncType, 'SIMPLE_MOLECULE'));
        smIncAlias = find(ismember(newmap.molID, smIncID));
            for i = smIncAlias'
                newmap.molColor{i} = 'ffccff66';
                newmap.molWidth{i} = '70';
                newmap.molHeight{i} = '25';
            end
    end

    % Identify the metabolites that should be considered "secondary
    % metabolites"
    % Groups of metabolites as chosen during drawing of Recon3map
    mets{1} = {'^atp\[\w\]'; '^adp\[\w\]'; '^amp\[\w\]'; '^utp\[\w\]'; '^udp\[\w\]'; '^ump\[\w\]'; '^ctp\[\w\]'; '^cdp\[\w\]'; '^cmp\[\w\]'; '^gtp\[\w\]'; '^gdp\[\w\]'; '^gmp\[\w\]'; '^imp\[\w\]'; '^idp\[\w\]'; '^itp\[\w\]'; '^dgtp\[\w\]'; '^dgdp\[\w\]'; '^dgmp\[\w\]'; '^datp\[\w\]'; '^dadp\[\w\]'; '^damp\[\w\]'; '^dctp\[\w\]'; '^dcdp\[\w\]'; '^dcmp\[\w\]'; '^dutp\[\w\]'; '^dudp\[\w\]'; '^dump\[\w\]'; '^dttp\[\w\]'; '^dtdp\[\w\]'; '^dtmp\[\w\]'; '^pppi\[\w\]'; '^ppi\[\w\]'; '^pi\[\w\]'};
    mets{2} = {'^h2o\[\w\]'};
    mets{3} = {'^h\[\w\]'};
    mets{4} = {'^nadp\[\w\]'; '^nadph\[\w\]'; '^nad\[\w\]'; '^nadh\[\w\]'; '^fad\[\w\]'; '^fadh2\[\w\]'; '^fmn\[\w\]'; '^fmnh2\[\w\]'; 'FAD'; 'FADH2'; 'NAD(_plus_)'; 'NADH'};
    % Also with PDmap nomenclature, for full version of MitoMap, as these
    % are sometimes included in complexes.
    mets{5} = {'^coa\[\w\]'};
    mets{6} = {'^h2o2\[\w\]'; '^o2\[\w\]'; '^co2\[\w\]'; '^co\[\w\]'; '^no\[\w\]'; '^no2\[\w\]'; '^o2s\[\w\]'; '^oh1\[\w\]'};
    mets{7} = {'^na1\[\w\]'; '^nh4\[\w\]'; '^hco3\[\w\]'; '^h2co3\[\w\]'; '^so4\[\w\]'; '^so3\[\w\]'; '^cl\[\w\]'; '^k\[\w\]'; '^ca2\[\w\]'; '^fe2\[\w\]'; '^fe3\[\w\]'; '^i\[\w\]'; '^zn2\[\w\]'; 'Ca2_plus_'; 'Cl_minus_'; 'Co2_plus_'; 'Fe2_plus_'; 'Fe3_plus_'; 'H_plus_'; 'K_plus_'; 'Mg2_plus_'; 'Mn2_plus_'; 'Na_plus_'; 'Ni2_plus_'; 'Zn2_plus_'};
    % Also added are names of ions in PD map, for full version of MitoMap,
    % as ions are sometimes included in complexes

    % Carnitine to be reviewed later, if it should be visualized differently
    % from "general" metabolites or not (01082017)
    mets{8} = {'^crn\[\w\]'};

    % Choose seperate color for each metabolite group. Avoid using bright red,
    % as that is default color for highlighting fluxes and moieties.
    clr{1} = 'fff0adbb';  % faded red/pink ;
    clr{2} = 'ff79adf5';  % blue
    clr{3} = 'ffb993ec';  % purple
    clr{4} = 'ff06f7e1';  % light blue
    clr{5} = 'fff0a10e';  % orange
    clr{6} = 'ff61f81b';  % green
    clr{7} = 'fff5f81b';  % yellow
    clr{8} = 'ff99edc5';  % sea green

    for i = 1:8
        list = mets{i};
        % find species ID for each metabolite in a group
        index = [];
        for h = list'
            j = find(~cellfun(@isempty, regexp(newmap.specName, h)));
            index = [index; j];
        end
        specID = newmap.specID(index);
        % Find index of all aliases of each species
        index2 = find(ismember(newmap.molID, specID));
        % Change clr and size (same size for all metabolite groups, smaller than "main metabolites")
        for k = index2'
            newmap.molColor{k} = clr{i};
            newmap.molWidth{k} = '50.0';
            newmap.molHeight{k} = '20.0';
        end
        % If complete structure is used, also change for included species
        if any(strcmp('rxnReactantLineColor', fieldnames(map))) == 1
            index3 = [];
            for h = list'
                j = find(~cellfun(@isempty, regexp(newmap.specIncName, h)));
                index3 = [index3; j];
            end
            specIncID = newmap.specIncID(index3);
            index4 = find(ismember(newmap.molID, specIncID));
            for k = index4'
                newmap.molColor{k} = clr{i};
                newmap.molWidth{k} = '50.0';
                newmap.molHeight{k} = '20.0';
            end
        end
    end

    % Define and change species type for known "secondary" metabolites from model
    % (all ions will acquire round shape instead of oval, no matter how areaWidth and height is defined)
    ions = {'^h\[\w\]'; '^na1\[\w\]'; '^cl\[\w\]'; '^k\[\w\]'; '^ca2\[\w\]'; '^fe2\[\w\]'; '^fe3\[\w\]'; '^i\[\w\]'; '^zn2\[\w\]'; 'Ca2_plus_'; 'Cl_minus_'; 'Co2_plus_'; 'Fe2_plus_'; 'Fe3_plus_'; 'H_plus_'; 'K_plus_'; 'Mg2_plus_'; 'Mn2_plus_'; 'Na_plus_'; 'Ni2_plus_'; 'Zn2_plus_'};
    nonIons = {'^atp\[\w\]'; '^adp\[\w\]'; '^amp\[\w\]'; '^utp\[\w\]'; '^udp\[\w\]'; '^ump\[\w\]'; '^ctp\[\w\]'; '^cdp\[\w\]'; '^cmp\[\w\]'; '^gtp\[\w\]'; '^gdp\[\w\]'; '^gmp\[\w\]'; '^imp\[\w\]'; '^idp\[\w\]'; '^itp\[\w\]'; '^dgtp\[\w\]'; '^dgdp\[\w\]'; '^dgmp\[\w\]'; '^datp\[\w\]'; '^dadp\[\w\]'; '^damp\[\w\]'; '^dctp\[\w\]'; '^dcdp\[\w\]'; '^dcmp\[\w\]'; '^dutp\[\w\]'; '^dudp\[\w\]'; '^dump\[\w\]'; '^dttp\[\w\]'; '^dtdp\[\w\]'; '^dtmp\[\w\]'; '^pppi\[\w\]'; '^ppi\[\w\]'; '^pi\[\w\]'; '^h2o\[\w\]'; '^nadp\[\w\]'; '^nadph\[\w\]'; '^nad\[\w\]'; '^nadh\[\w\]'; '^fad\[\w\]'; '^fadh2\[\w\]'; '^fmn\[\w\]'; '^fmnh2\[\w\]'; '^coa\[\w\]'; '^h2o2\[\w\]'; '^o2\[\w\]'; '^co2\[\w\]'; '^co\[\w\]'; '^no\[\w\]'; '^no2\[\w\]'; '^o2s\[\w\]'; '^oh1\[\w\]'; '^nh4\[\w\]'; '^hco3\[\w\]'; '^h2co3\[\w\]'; '^so4\[\w\]'; '^so3\[\w\]'; '^crn\[\w\]'; 'FAD'; 'FADH2'; 'NAD(_plus_)'; 'NADH'};
    ionindex = [];
    for i = ions'
        % Find species index for ions
        j = find(~cellfun(@isempty, regexp(newmap.specName, i)));
        ionindex = [ionindex; j];
    end
    for j = ionindex'
        newmap.specType{j} = 'ION';
    end

    % If complete structure is used, also change for included species
    if any(strcmp('rxnReactantLineColor', fieldnames(map))) == 1
        ionIncindex = [];
        for i = ions'
            % Find species index for ions
            m = find(~cellfun(@isempty, regexp(newmap.specIncName, i)));
            ionIncindex = [ionIncindex; m];
        end
        for m = ionIncindex'
            newmap.specType{m} = 'ION';
        end
    end

    % Give the type simple molecule, in case they were manually drawn with wrong
    % species type (this is not done for the whole species list, in case there are proteins, receptors, etc. present on map)
    notIonIndex = [];
    for i = nonIons'
        j = find(~cellfun(@isempty, regexp(newmap.specName, i)));
        notIonIndex = [notIonIndex; j];
    end
    for j = notIonIndex'
        newmap.specType{j} = 'SIMPLE_MOLECULE';
    end

    % If complete structure is used, also change for included species
    if any(strcmp('rxnReactantLineColor', fieldnames(map))) == 1
        notIonIncIndex = [];
        for i = nonIons'
            m = find(~cellfun(@isempty, regexp(newmap.specIncName, i)));
            notIonIncIndex = [notIonIncIndex; m];
        end
        for m = notIonIncIndex'
            newmap.specIncType{m} = 'SIMPLE_MOLECULE';
        end
    end

    % Give unified look to all proteins
    protID = newmap.specID(ismember(newmap.specType, 'PROTEIN'));
    protAlias = find(ismember(newmap.molID, protID));
    for i = protAlias'
        newmap.molColor{i} = 'ffccffcc';
        newmap.molWidth{i} = '55';
        newmap.molHeight{i} = '30';
    end
    % If complete structure is used, also change for included species
    if any(strcmp('rxnReactantLineColor', fieldnames(map))) == 1
        protIncID = newmap.specIncID(ismember(newmap.specIncType, 'PROTEIN'));
        protIncAlias = find(ismember(newmap.molID, protIncID));
        for i = protIncAlias'
            newmap.molColor{i} = 'ffccffcc';
            newmap.molWidth{i} = '55';
            newmap.molHeight{i} = '30';
        end
    end

end
