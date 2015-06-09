% BOOLEANSTATES   Boolean steady states and state transition graph.
%
%   S=BOOLEANSTATES(MODEL) returns all Boolean steady states S for the 
%   given Boolean Odefy MODEL.
%
%   [S,G]=BOOLEANSTATES(MODEL,SYNC) returns both steady states and the
%   state transition graph. SYNC is optional an determines whether a
%   synchronous update or an asynchronous update state transition graph is
%   calculated. By default, Odefy computes asychronous ST graphs.
%
%   [...]=BOOLEANSTATES(...,INIT) works identical as the two variants
%   above, but enumerates the state-transition graph and the steady states
%   starting from a given initial state.
%
%   States of input species are always kept constant.
%
%
%   State encoding
%   --------------
%   Boolean states in Odefy are encoded as integer numbers. The 
%   corresponding binary representation of a state integer defines for each 
%   species whether it is on or off.
%
%   Example:
%   Your model contains three species A, B and C.
%   The integer state 5 corresponds to the binary number 101, indicating 
%   that A and C are on and B is off.
%
%   Use Odefy's num2bin function to get the binary representation of a 
%   given integer.
%
%   IMPORTANT NOTE: In the state transition graph the matrix indices
%   represent a state increased by one, as matrix indices having the value 
%   0 are not allowed in MATLAB. The matrix edge (2,6) for instance stands 
%   for an ST graph edge from the state 1 (binary 100) to the state 5 
%   (binary 101).

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function [s,g] = BooleanStates(model, sync, init)

n = numel(model.species);

% parameter stuff
dograph = nargout>1;
if ~dograph
    gmode = 0; % no graph
else
    if nargin<2 || sync == false
        gmode = 1; % async
    else
        gmode = 2; % sync
    end
end

% initialize graph
if gmode > 0
    g = sparse(2^n,2^n);
end

% init?
if nargin<3
    init=[];
end

if numel(init)
    % from given state
    queue = bin2num(init)+1;
    
    used = [];  
    s = [];
  
    while numel(queue) > 0
        % get next entry
        next = queue(1);
        queue = queue(2:end);
        % put into used list
        used = [used next];

        % convert to binary vector
        ostate = num2bin(next-1,n);

        % determine follow up states
        syncstate = ostate;
        for curs=1:n
            state = ostate;
            % get state of input species
            numinput = numel(model.tables(curs).inspecies);
            if (numinput > 0)
                inpstate = zeros(numinput,1);
                for i=1:numinput
                    inpstate(i) = state(model.tables(curs).inspecies(i));
                end
                % evaluate
                state(curs) = model.tables(curs).truth(bin2num(inpstate)+1);
                syncstate(curs) = model.tables(curs).truth(bin2num(inpstate)+1);
            else
                % species has no inputs => keep state
            end
            % done with this species

            % draw edge
            if gmode==1
                numstate = bin2num(state)+1;
                g(next,numstate) = 1;
                % if not in queue and not used yet => put into queue
                if numel(find(queue==numstate))==0 && numel(find(used==numstate))==0
                    queue = [queue numstate];
                end                
            end           
        end
        
        if gmode==2
            numstate = bin2num(syncstate)+1;
            g(next,numstate) = 1;
            % if not in queue and not used yet => put into queue
            if numel(find(queue==numstate))==0 && numel(find(used==numstate))==0
                queue = [queue numstate];
            end
        end
        
        if all(ostate==syncstate)
            s = [s bin2num(syncstate)];
        end

    end

else
    % iterate over all possible states
    s = [];
    for i=0:2^n-1
        % get binary representation
        state = num2bin(i,n);
        syncstate=state;
        
        % check steadyness
        for sp=1:n
            % get state of input species
            numinput = numel(model.tables(sp).inspecies);
            newstate = state;
            if (numinput > 0)
                inpstate = zeros(numinput,1);
                for j=1:numinput
                    inpstate(j) = state(model.tables(sp).inspecies(j));
                end
                % evaluate
                newstate(sp) = model.tables(sp).truth(bin2num(inpstate)+1);
                syncstate(sp) = newstate(sp);
                % async follow up state?  
            else
                % species has no inputs => keep state
                newstate(sp) = state(sp);
            end
            if gmode==1
                fustate = state;
                fustate(sp) = newstate(sp);
                g(i+1,bin2num(fustate)+1) = 1;
            end
        end

        % sync follow up state?
        if gmode==2
            g(i+1,bin2num(syncstate)+1) = 1;
        end
        
        if all(state==syncstate)
            s = [s i];
        end
    end
end