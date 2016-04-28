% ODEFYSIMULATION  Perform simulation with given Odefy simulation
% structure.
%
%   [T,Y]=ODEFYSIMULATION(SIMSTRUCT,SHOWPLOT,HEATMAP) performs a Boolean or
%   continuous time-course simulation according to the settings specified
%   in SIMSTRUCT. If SHOWPLOT is set to 1, the function will display the
%   results visually. If HEATMAP is 1, a heatmap-like visualization will be
%   shown instead of a commom line diagramm.
%
%   Note that for Boolean simulations, the function only returns one output
%   value: the time-course vector of Boolean states.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function varargout=OdefySimulation(simstruct, showplot, heatmap)

if nargin<3
    heatmap=0;
end

if IsOdefyModel(simstruct)
    fprintf('Warning: You provided an Odefy model instead of a simulation structure, using default values.\nSee also: CreateSimstruct\n');
end
simstruct = CreateSimstruct(simstruct);

% type
type = ValidateType(simstruct.type);
caption = '';
switch type
    case 1
        caption = 'BooleCube';
    case 2
        caption = 'HillCube';
    case 3
        caption = 'HillCube (normalized)';
    case 4
        caption = 'Boolean (sync.)';
    case 5
        caption = 'Boolean (async.)';
    case 6
        caption = 'Boolean (random async.)';
end

if type<=3
    % ODE
    if (nargout ~= 2 && nargout ~= 0)
        error('Invalid number of output arguments. Call without arguments or use "[t,y] = ..."');
    end
    % prepare temporary ODE model files
    tmpfull = strrep([tempname() '.m'],'-','_'); % replacement because octave likes to generate temp files names with a minus sign
    [tmppath, tmpname] = fileparts(tmpfull);
    % go to that temp directory
    lwd = pwd;
    eval(['cd ' tmppath]);

    % general parameters
    step = 50;

    % create actual model
    SaveMatlabODE(simstruct.model, tmpfull, simstruct.type);
    rehash;

    % parameters
    simparams = ParameterVector(simstruct);

    % additional (computed) parameters
    steps = 1000;

    % do the simulation
    if IsMatlab
        simtime = [0 simstruct.timeto];
        cmd = sprintf('[t,yp] = ode15s(@(t,y)%s(t,y,simparams), simtime, simstruct.initial);',tmpname);
        eval(cmd);
        realtime = t;
    else
        % Octave has some different calling conventions
        realtime = linspace(0,simstruct.timeto,steps);
        cmd = sprintf('yp = lsode(@(t,y)%s(y,t,simparams,@%s), simstruct.initial'', realtime);',tmpname,extname);
        eval(cmd);
    end

    % create species order if necessary
    if ~isfield(simstruct,'speciesorder')
        simstruct.speciesorder = 1:numel(simstruct.model.species);
    end

    % permutate species names and result
    yp = yp(:, simstruct.speciesorder);

    % return values?
    if (nargout == 2)
        varargout{1} = realtime;
        varargout{2} = yp;
    end
    eval(['cd ''' lwd '''']);
%     delete(tmpfull);

else
    % bool
    if (nargout ~= 1 && nargout ~= 0)
        error('Invalid number of output arguments. Call without arguments or use "y = ..."');
    end
    
    % create speciesorder if necessary
    if ~isfield(simstruct,'speciesorder')
        simstruct.speciesorder = 1:numel(simstruct.model.species);
    end

    if type==4
        % SYNCHRONOUS BOOLEAN SIMULATION
        state = simstruct.initial ;
        model = simstruct.model;
        numspecies = numel(model.species);

        % initialize result matrix
        result = zeros(simstruct.timeto, numspecies);
        result(1,:) = state;
        % iterate over timesteps
        for t=2:simstruct.timeto
            newstate = zeros(numspecies,1);
            % iterate over species
            for s=1:numspecies
                % get state of input species
                numinput = numel(model.tables(s).inspecies);

                if (numinput > 0)
                    inpstate = zeros(numinput,1);
                    for i=1:numinput
                        inpstate(i) = state(model.tables(s).inspecies(i));
                    end
                    % evaluate
                    newstate(s) = model.tables(s).truth(vec2dec(inpstate)+1);
                else
                    % species has no inputs => keep state
                    newstate(s) = state(s);
                end

            end
            state = newstate;
            result(t,:) = state;
        end
        yp = result;
        
        % return values?
        if (nargout == 1)
            varargout{1} = yp;
        end
    else
        
        % ASYNCHRONOUS BOOLEAN SIMULATION
        state = simstruct.initial ;
        model = simstruct.model;
        numspecies = numel(model.species);
        if type==5
            % normal async
            if isfield(simstruct,'asyncorder')
                order = simstruct.asyncorder;
            else
                order = randperm(numspecies);
            end
        else
            % completely random
            order = [];
        end

        % initialize result matrix
        result = zeros(simstruct.timeto, numspecies);

        result(1,:) = state;
        index = 1;
        % iterate over timesteps
        for t=2:simstruct.timeto
            % iterate over species
            if (numel(order)>0)
                s = order(index);
            else
                s = floor(rand*numspecies+1);
            end
            % get state of input species
            numinput = numel(model.tables(s).inspecies);
            if (numinput > 0)
                inpstate = zeros(numinput,1);
                for i=1:numinput
                    inpstate(i) = state(model.tables(s).inspecies(i));
                end
                % evaluate
                state(s) = model.tables(s).truth(vec2dec(inpstate)+1);
            else
                % species has no inputs => keep state
            end
            result(t,:) = state;
            index = mod(index ,numspecies) +1;
        end
        yp = result;
        
        % return values?
        if (nargout == 1)
            varargout{1} = yp;
        end

    end

    % stuff for all boolean simulations
    realtime = 1:simstruct.timeto;
    step = 5;
end


% show the plot?
if (nargin > 1 && showplot)
    if ~heatmap
        permutedspecies = simstruct.model.species(simstruct.speciesorder);
    else
        permutedspecies = simstruct.model.species;
    end

    Visualize(realtime,yp,permutedspecies,caption,heatmap,step);
end


% private function which converts a binary vector to the corresponding decimal value
% assumes lowest-order bits first
function v = vec2dec(vec)
v = 0;
for i=1:size(vec,1)
    v = v + 2^(i-1)*vec(i);
end

