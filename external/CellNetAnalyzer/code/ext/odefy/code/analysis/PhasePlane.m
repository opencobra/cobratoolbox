% PHASEPLANE  Draw a 2D phase plane of a given ODE system
%
%   PHASEPLANE(FUN,N,V1,V1RANGE,V2,V2RANGE,[param1,value1,param2,value2,...]
%   draws a two-dimensional phase plane of an ODE system with respect to
%   two given variables and initial value ranges. FUN defines the ODE
%   function handle to be used for creating the trajectories. N defines the
%   number of species in the system. V1 is the index of the first species
%   to be varied and V1RANGE is the range over which th initial values of
%   that species are varied. V2 and V2RANGE have an analogous meaning.
% 
%
%   Optional parameters:
%   
%     initial   - Inital value vector, required for systems with >2 species
%                 Default value: 0 for all species
%
%     time      - Time units to be simulated. Default value: 10
%
%     colormult - Color multiplicator, useful for emphasizing closely
%                 located steady states in the system. Default value: 1.0
%
%     markends  - Mark ends of trajectories visually?

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function PhasePlane(fun, n, v1, v1range, v2, v2range, varargin)

if ~IsMatlab
    error('Odefy plotting not supported in Octave. Please use the regular plot function.');
end

% parse, verify parameters
p = inputParser;
p.addRequired('fun', @(x)isa(x, 'function_handle'));
p.addRequired('n', @isscalar);
p.addRequired('v1', @isscalar);
p.addRequired('v1range', @isnumeric);
p.addRequired('v2', @isscalar);
p.addRequired('v2range', @isnumeric);
p.addOptional('initial', zeros(2,1), @isnumeric);
p.addOptional('colormult', 1, @isscalar);
p.addOptional('time', 100, @isscalar);
p.addOptional('markends', false, @(x)(islogical(x) & isscalar(x)));
p.parse(fun,n,v1,v1range,v2,v2range,varargin{:});
params=p.Results;

% verify that we have enough initial values
if numel(params.initial) < n
    error('For systems with > 2 variables you have to provide an ''initial'' parameter. See ''help PHASEPLANE''');
end

% initialize
max1 = max(v1range);
max2 = max(v2range);
time = params.time;

hold on;

for valv1 = v1range
    for valv2 = v2range
        % set initial values
        init = params.initial;
        init(v1) = valv1;
        init(v2) = valv2;
        % simulate
        r = ode15s(fun, [0 time], init);
        
        % get final state
        y1f = r.y(v1,end);
        y2f = r.y(v2,end);
        
        % calculate color for trajectories
        col = [y1f/max1 0 y2f/max2] * params.colormult;
   
        % correct, if OOB
        col(1) = max(0, col(1));
        col(1) = min(1, col(1));
        col(3) = max(0, col(3));
        col(3) = min(1, col(3));   
 
        % plot trajectory
    	plot(r.y(v1,:), r.y(v2,:), 'Color', col);
              
        % mark ends?
        if params.markends
            plot(r.y(1,end), r.y(2,end), 'o', 'Color', 'black');
        end
    end

end

hold off;

