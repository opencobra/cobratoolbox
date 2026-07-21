function [involvedRxns, involvedMets, deadEnds, deadRxns] = bio_draw_by_met(model, metAbbr, drawMap, radius, direction, excludeMets, flux, save, closev)
% Defines the visualisation scope from a starting metabolite (Paint4Net).
%
% USAGE:
%
%    [involvedRxns, involvedMets, deadEnds, deadRxns] = bio_draw_by_met(model, metAbbr, drawMap, radius, direction, excludeMets, flux, save, closev)
%
% INPUTS:
%    model:          COBRA model structure with fields:
%
%                      * .S - `m x n` stoichiometric matrix
%    metAbbr:        Cell array containing the abbreviation of a metabolite in
%                    the COBRA model. This metabolite is the starting point
%                    for visualisation.
%
% OPTIONAL INPUTS:
%    drawMap:        Logical indicating whether to visualise the COBRA model.
%
%                    Default: false
%    radius:         Positive integer (1, 2, 3, ...) defining the search depth
%                    from `metAbbr`.
%
%                    Default: 1
%    direction:      Direction used by the algorithm. Allowed values are
%                    `struc`, `sub`, `prod`, or `both`.
%
%                    Default: 'struc'
%    excludeMets:    Cell array of metabolite abbreviations to exclude from the
%                    visualisation map.
%
%                    Default: empty
%    flux:           `nRxns x 1` vector of reaction fluxes, where `nRxns` is
%                    the number of reactions in the model.
%
%                    Default: empty (no flux data provided)
%    save:           Boolean indicating whether to save the visualisation
%                    automatically as a JPEG file.
%
%                    Default: false
%    closev:         Boolean indicating whether to close the biograph viewer
%                    window after visualisation.
%
%                    Default: false
%
% OUTPUTS:
%    involvedRxns:    Cell array containing the list of involved reactions.
%    involvedMets:    Cell array containing the list of involved metabolites.
%    deadEnds:       Cell array containing the list of dead-end metabolites.
%    deadRxns:       Cell array containing the list of dead-end reactions.
%
% .. Author: - Andrejs Kostromins, 04/10/2012, andrejs.kostromins@gmail.com

% --- FIX: All nargin defaults moved to top level so they apply regardless
%     of whether flux was supplied or not. ---

if nargin < 3
    drawMap = false;
end

if nargin < 4
    radius = 1;
end

% FIX: direction and excludeMets defaults moved outside the nargin<7 block
if nargin < 5
    direction = 'struc';
end

if nargin < 6
    excludeMets{1} = '';
end

% FIX: Instead of filling flux with ASCII value of 'x' (which caused
%      numeric/char comparison bugs), use an empty array as the
%      "no flux provided" sentinel and track it with a logical flag.
if nargin < 7 || isempty(flux)
    flux = [];
    noFlux = true;
else
    noFlux = false;
end

if nargin < 8  % FIX: corrected comment index (was labelled <8 twice)
    save = false;
end

if nargin < 9  % FIX: corrected from erroneous duplicate comment "<8"
    closev = false;
end

% FIX: Initialise all outputs so MATLAB never errors on undefined outputs
%      in early-exit branches.
involvedRxns = 'No rxns';
involvedMets  = 'No mets';
deadEnds      = 'No dead ends';
deadRxns      = 'No dead rxns';

if radius > 0

    % FIX: noFlux flag replaces the old isempty(flux) check, which would
    %      have been true for the old char-filled vector too.
    if ~noFlux || strcmp(direction,'struc')

        Rxns = findRxnsFromMets(model, metAbbr); % find reactions around the initial metabolite

        % FIX: replaced length(Rxns)~=0 with ~isempty(Rxns) (more idiomatic)
        if ~isempty(Rxns)

            RxnsID = findRxnIDs(model, Rxns);   % find reaction IDs in the model
            metID  = findMetIDs(model, metAbbr); % find initial metabolite ID in the model

            % FIX: use a logical flag instead of the fragile 'No rxns' sentinel string
            involvedRxns = {};
            foundRxns    = false;

            for q = 1:length(RxnsID)

                switch direction

                    case 'sub'
                        % Add reaction if the metabolite is consumed (substrate)
                        % FIX: noFlux guard replaces the old flux(i)~='x' char comparison
                        if ~noFlux && ...
                           (model.S(metID,RxnsID(q)) < 0 && flux(RxnsID(q)) < -1e-9 || ...
                            model.S(metID,RxnsID(q)) > 0 && flux(RxnsID(q)) >  1e-9)

                            involvedRxns{end+1,1} = Rxns{q};
                            foundRxns = true;
                        end

                    case 'prod'
                        % Add reaction if the metabolite is produced (product)
                        if ~noFlux && ...
                           (model.S(metID,RxnsID(q)) > 0 && flux(RxnsID(q)) < -1e-9 || ...
                            model.S(metID,RxnsID(q)) < 0 && flux(RxnsID(q)) >  1e-9)

                            involvedRxns{end+1,1} = Rxns{q};
                            foundRxns = true;
                        end

                    case 'both'
                        % Add reaction if metabolite participates and flux is non-zero
                        if ~noFlux && ...
                           (model.S(metID,RxnsID(q)) ~= 0 && ...
                           (flux(RxnsID(q)) < -1e-9 || flux(RxnsID(q)) > 1e-9))

                            involvedRxns{end+1,1} = Rxns{q};
                            foundRxns = true;
                        end

                    case 'struc'
                        % Add reaction if stoichiometric coefficient is non-zero (no flux needed)
                        if model.S(metID,RxnsID(q)) ~= 0
                            involvedRxns{end+1,1} = Rxns{q};
                            foundRxns = true;
                        end

                end % switch

            end % for q

            if foundRxns

                for q = 1:radius-1
                    involvedRxns = findNearRxns(model, involvedRxns, direction, flux);
                end

                [involvedMets,deadEnds,deadRxns] = bio_draw_by_rxn(model,involvedRxns,drawMap,direction,metAbbr,excludeMets,flux,save,closev);

            else

                % FIX: deadRxns was never assigned in this branch in the original
                switch direction
                    case 'sub'
                        disp(['According to given fluxes no substrates were found for metabolite ', metAbbr{1}])
                    case 'prod'
                        disp(['According to given fluxes no products were found for metabolite ', metAbbr{1}])
                    case 'both'
                        disp(['According to given fluxes no substrates and products were found for metabolite ', metAbbr{1}])
                end

                % Outputs already initialised to 'No ...' defaults above

            end

        else % metabolite not present in the model

            disp(strcat(metAbbr, ' is not present in the model'))
            % Outputs already initialised to 'No ...' defaults above

        end

    else % flux vector is empty (and direction requires flux)

        disp('The flux vector is empty')
        % Outputs already initialised to 'No ...' defaults above

    end

else % radius <= 0

    disp('The value of the argument RADIUS must be a natural number, for example, 1,2,3...n')
    % Outputs already initialised to 'No ...' defaults above

end
