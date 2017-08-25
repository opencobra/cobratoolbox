function [transportRxnBool] = transportReactionBool(model, originCompartment, destinationCompartment, unidirectionalBool)
% Return a boolean vector indicating which reactions transport between compartments.
%
% USAGE:
%
%    [transportRxnBool] = transportReactionBool(model, originCompartment, destinationCompartment, unidirectionalBool)
%
% INPUT:
%    model:                     COBRA model structure with fields:
%
%                                 * .S
%                                 * .mets
%
% OPTIONAL INPUTS:
%    originCompartment:         origin compartment (only relevant for unidirectional)
%    destinationCompartment:    destination compartment (only relevant for unidirectional)
%    unidirectionalBool:        1 = only return transport reactions between specified
%                               compartments in the origin to destination direction
%
% OUTPUT:
%    transportRxnBool:          boolean vector indicating transport reactions
%
% .. Author: - Ronan M.T. Fleming

if ~exist('originCompartment','var')
    originCompartment='null';
end
if ~exist('destinationCompartment','var')
    destinationCompartment='null';
end
if ~exist('unidirectionalBool','var')
    unidirectionalBool=0;
end

[nMet,nRxn]=size(model.S);

%reversibleBool = model.lb=<0 & model.ub>=0;
%forwardBool = model.lb>=0 & model.ub>0;

%reorient the stoichiometric matrix if any reactions are reverse
reverseBool = model.lb<0 & model.ub<=0;
if any(reverseBool)
    orientation = ones(nRxn,1);
    orientation(reverseBool)=-1;
    S=model.S*spdiags(orientation,0,nRxn,nRxn);
else
    S=model.S;
end

transportRxnBool=false(nRxn,1);

[compartments,uniqueCompartments]=getCompartment(model.mets);

for n=1:nRxn
    originCompartments=compartments(S(:,n)<0);
    destinationCompartments=compartments(S(:,n)>0);
    %should also omit exchange reactions
    bothCompartments=unique({originCompartments{:},destinationCompartments{:}});
    if length(bothCompartments)>1
        if strcmp(originCompartment,'null') && strcmp(destinationCompartment,'null') &&  unidirectionalBool==0
            transportRxnBool(n,1)=1;
        else
            if unidirectionalBool==0
                %invariant wrt direction
                if any(strcmp(originCompartment,bothCompartments)) && any(strcmp(destinationCompartment,bothCompartments))
                    transportRxnBool(n,1)=1;
                end
            else
                %compartments must be in the correct direction
                if any(strcmp(originCompartment,originCompartments)) && any(strcmp(destinationCompartment,destinationCompartments))
                    transportRxnBool(n,1)=1;
                end
            end
        end
    end
end
