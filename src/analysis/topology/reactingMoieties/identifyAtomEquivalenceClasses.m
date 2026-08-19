function [canonicalAtomNumberMap, equivalenceClasses, unsafeNeighborsByClass] = identifyAtomEquivalenceClasses(atomNumbers, elements, headAtoms, tailAtoms, bTypes, metName)
% Identify symmetry/resonance-equivalence classes of atoms within one metabolite
%
% For one metabolite's own molblock (atoms and bonds from a single RXN-file
% instance), detects sets of atoms that are interchangeable under the
% metabolite's own bond-graph automorphism group -- e.g. a gem-dimethyl
% pair's two methyl carbons, or a carboxylate's two resonance-equivalent
% oxygens -- and returns a deterministic atomNumber -> canonicalAtomNumber
% map, so that bond-node identities built from equivalence-class members
% resolve consistently regardless of which RXN file's raw atom numbering
% produced them (feature 020-canonicalize-symmetric-atom-bonds).
%
% Detection uses iterative colour refinement (1-dimensional Weisfeiler-Leman)
% over the metabolite's own atom-adjacency graph, built with MATLAB's
% `graph` object (Graph and Network Algorithms, base MATLAB, already used
% for a structurally analogous problem by `identifyIsomorphicClasses.m` in
% this domain folder), to find candidate equivalence classes. Each candidate
% class is then cross-checked with `isisomorphic` (same base-MATLAB
% machinery) to confirm a genuine graph automorphism maps every member onto
% every other member, guarding against a color-refinement false-positive.
%
% A class member's raw atom number MUST NOT be blindly substituted for the
% class's canonical representative in every bond it appears in: doing so for
% a bond to a neighbour that is ITSELF simultaneously bonded to more than one
% class member (e.g. the shared backbone carbon a gem-dimethyl pair's two
% methyl carbons both attach to) would collapse two genuinely distinct,
% simultaneously-present bonds into one, undercounting the metabolite's true
% bond count. `unsafeNeighboursByClass` names, per class, exactly the
% neighbours for which substitution is unsafe; a caller MUST leave a class
% member's raw atom number untouched for any bond whose other endpoint
% appears in its class's unsafe set, and MAY substitute the canonical
% representative for every other bond (FR-002, FR-004, FR-005).
%
% If detection is inconclusive for this metabolite (a malformed or
% inconsistent input, or colour refinement failing to converge), a warning
% names the metabolite and the identity map (every atom number maps to
% itself, no unsafe neighbours) is returned instead -- the same
% canonicalization behaviour as before this feature, for that metabolite
% only (FR-011).
%
% USAGE:
%
%    [canonicalAtomNumberMap, equivalenceClasses, unsafeNeighborsByClass] = identifyAtomEquivalenceClasses(atomNumbers, elements, headAtoms, tailAtoms, bTypes, metName)
%
% INPUTS:
%    atomNumbers:  p x 1 vector of raw atom numbers (`metNrs`) for one
%                  metabolite instance's own molblock
%    elements:     p x 1 cell array of element symbols, matching atomNumbers
%    headAtoms:    q x 1 vector of the first atom number of each bond
%    tailAtoms:    q x 1 vector of the second atom number of each bond
%    bTypes:       q x 1 vector of bond order (1/2/3) for each bond
%    metName:      metabolite identifier, used only to name the metabolite
%                  in the fallback warning
%
% OUTPUTS:
%    canonicalAtomNumberMap:    containers.Map (KeyType 'double', ValueType
%                                'double') from raw atomNumber to its
%                                equivalence class's canonical representative
%                                atomNumber (the lowest raw atom number among
%                                the class's members); singleton classes map
%                                each atom number to itself
%    equivalenceClasses:        cell array, one cell per equivalence class,
%                                each a sorted vector of the class's raw atom
%                                numbers (including singleton classes)
%    unsafeNeighborsByClass:    containers.Map (KeyType 'double', ValueType
%                                'any') from a class's canonical
%                                representative atom number to a row vector
%                                of neighbour atom numbers that are unsafe to
%                                use as the trigger for substituting that
%                                class's canonical representative (only
%                                populated for classes with more than one
%                                member)
%
% NOTE:
%    Requires MATLAB R2016b or later for the `graph` object (as
%    `identifyIsomorphicClasses.m` already requires for `isisomorphic`).
%
% Authors:
%    - COBRA Toolbox, feature 020-canonicalize-symmetric-atom-bonds

try
    if isempty(atomNumbers)
        error('identifyAtomEquivalenceClasses:emptyInput', 'No atoms provided for metabolite %s.', metName);
    end
    if numel(atomNumbers) ~= numel(elements)
        error('identifyAtomEquivalenceClasses:sizeMismatch', 'atomNumbers and elements must be the same length for metabolite %s.', metName);
    end
    if numel(headAtoms) ~= numel(tailAtoms) || numel(headAtoms) ~= numel(bTypes)
        error('identifyAtomEquivalenceClasses:sizeMismatch', 'headAtoms, tailAtoms, and bTypes must be the same length for metabolite %s.', metName);
    end
    if any(~ismember(headAtoms, atomNumbers)) || any(~ismember(tailAtoms, atomNumbers))
        error('identifyAtomEquivalenceClasses:danglingBond', 'A bond references an atom number not present in atomNumbers for metabolite %s.', metName);
    end

    p = numel(atomNumbers);
    atomNumbers = atomNumbers(:);
    elements = elements(:);

    localIndexMap = containers.Map(num2cell(atomNumbers), num2cell(1:p));
    localHead = zeros(numel(headAtoms), 1);
    localTail = zeros(numel(tailAtoms), 1);
    for b = 1:numel(headAtoms)
        localHead(b) = localIndexMap(headAtoms(b));
        localTail(b) = localIndexMap(tailAtoms(b));
    end

    NodeTable = table((1:p)', elements, 'VariableNames', {'LocalIndex', 'Element'});
    G = graph(localHead, localTail, bTypes(:), NodeTable);
    if numedges(G) ~= numel(headAtoms)
        error('identifyAtomEquivalenceClasses:duplicateBond', 'Duplicate bond between the same atom pair for metabolite %s.', metName);
    end

    % iterative colour refinement (1-WL) to a fixed point
    color = elements;
    maxIter = p + 1; % colour refinement always converges within p-1 rounds; +1 is a defensive margin
    converged = false;
    for iter = 1:maxIter
        newColor = cell(p, 1);
        for k = 1:p
            nbrs = neighbors(G, k);
            if isempty(nbrs)
                signature = '';
            else
                sigParts = cell(numel(nbrs), 1);
                for ni = 1:numel(nbrs)
                    eIdx = findedge(G, k, nbrs(ni));
                    bt = G.Edges.Weight(eIdx);
                    sigParts{ni} = sprintf('%d:%s', bt, color{nbrs(ni)});
                end
                signature = strjoin(sort(sigParts), ',');
            end
            newColor{k} = [color{k} '|' signature];
        end
        % Convergence check: `newColor{k}` always has `color{k}` as a literal prefix, so
        % refinement is monotone -- a round can only ever SPLIT an existing group, never
        % merge two groups or leave the partition otherwise reshuffled. Two nodes that
        % already differ in `color` therefore always differ in `newColor` too, so the
        % refined partition is stable (no split occurred) iff the number of distinct
        % colours is unchanged. Comparing group COUNTS (order-independent) rather than
        % `isequal` on `groupIndicesByColor`'s ordered cell arrays matters because that
        % ordering is driven by each round's arbitrary lexicographic string sort, which
        % differs round to round even when the underlying partition has already reached
        % its fixed point -- verified empirically: comparing ordered group lists reported
        % spurious non-convergence (falling back to `maxIter` and the FR-011 fallback path)
        % on a plain unbranched carbon chain that a correct convergence check confirms
        % stabilizes in a handful of rounds.
        oldGroupCount = numel(unique(color));
        newGroupCount = numel(unique(newColor));
        % Re-hash this round's signature to a short, compact per-round label before it is
        % carried forward into the NEXT round's neighbour signature. Carrying the raw
        % concatenated string forward instead (i.e. `color = newColor` directly) makes a
        % node's colour string grow multiplicatively (~(average degree + 1)x) per round,
        % which for ordinary organic molecules needing more than a handful of rounds to
        % converge blows up to multi-gigabyte strings within `maxIter` and OOM-kills MATLAB
        % -- observed directly during implementation (two kernel OOM kills, anon-rss 17.9GB
        % and 25.3GB). `unique` maps identical strings to identical labels and distinct
        % strings to distinct labels, so the induced partition -- and therefore
        % `localGroups` below -- is unaffected; only the string representation carried
        % between rounds is bounded.
        [~, ~, colorId] = unique(newColor);
        color = arrayfun(@(x) sprintf('%d', x), colorId, 'UniformOutput', false);
        if oldGroupCount == newGroupCount
            converged = true;
            break;
        end
    end
    if ~converged
        error('identifyAtomEquivalenceClasses:nonTerminating', 'Colour refinement did not converge within %d iterations for metabolite %s.', maxIter, metName);
    end

    localGroups = groupIndicesByColor(color);

    % Cross-check each candidate class against a genuine graph automorphism, guarding
    % against a color-refinement false-positive (data-model.md "Classify" step, research
    % R6, FR-004): two atoms with the same iterative invariant that are nonetheless not
    % truly interchangeable is a known, if rare, limitation of color refinement alone on
    % graphs with certain regular substructures. A failed check makes the whole
    % metabolite's detection inconclusive (caught below, FR-011 fallback) rather than
    % attempting to guess a finer, unverified partition.
    for gi = 1:numel(localGroups)
        members = localGroups{gi};
        if numel(members) > 1
            for a = 1:numel(members) - 1
                for b = (a + 1):numel(members)
                    if ~pairIsGraphAutomorphic(G, members(a), members(b))
                        error('identifyAtomEquivalenceClasses:collisionCheckFailed', ...
                            ['Colour-refinement candidate equivalence class failed the isisomorphic ', ...
                             'collision check for metabolite %s.'], metName);
                    end
                end
            end
        end
    end

    equivalenceClasses = cell(numel(localGroups), 1);
    canonicalAtomNumberMap = containers.Map('KeyType', 'double', 'ValueType', 'double');
    unsafeNeighborsByClass = containers.Map('KeyType', 'double', 'ValueType', 'any');
    for gi = 1:numel(localGroups)
        members = localGroups{gi};
        classAtomNumbers = sort(atomNumbers(members));
        equivalenceClasses{gi} = classAtomNumbers;
        canonicalAtomNum = min(classAtomNumbers);
        for m = 1:numel(members)
            canonicalAtomNumberMap(atomNumbers(members(m))) = canonicalAtomNum;
        end

        if numel(members) > 1
            % a neighbour of 2+ class members simultaneously must never have
            % its bonds to those members collapsed onto one canonical key
            neighborCount = containers.Map('KeyType', 'double', 'ValueType', 'double');
            for m = 1:numel(members)
                nbrs = neighbors(G, members(m));
                for n = 1:numel(nbrs)
                    nbrAtomNum = atomNumbers(nbrs(n));
                    if isKey(neighborCount, nbrAtomNum)
                        neighborCount(nbrAtomNum) = neighborCount(nbrAtomNum) + 1;
                    else
                        neighborCount(nbrAtomNum) = 1;
                    end
                end
            end
            unsafeList = [];
            ks = keys(neighborCount);
            for kk = 1:numel(ks)
                if neighborCount(ks{kk}) >= 2
                    unsafeList = [unsafeList, ks{kk}]; %#ok<AGROW>
                end
            end
            unsafeNeighborsByClass(canonicalAtomNum) = unsafeList;
        end
    end

    % --- cross-class / cross-bond collision guard ------------------------------------
    % The per-class "shared hub neighbour" check above catches one bond endpoint
    % simultaneously connected to 2+ members of the SAME class (the gem-dimethyl anchor
    % pattern). It does not, by itself, catch a structurally different collision: two
    % DIFFERENT bonds, each between a member of one class and a member of a different (or
    % the same) class, whose EFFECTIVE substituted keys -- computed the same way the
    % caller's safeCanonicalizeBondAtoms/safeCanonicalizeOneAtom would compute them, using
    % the unsafe map so far -- would coincide even though no single hub atom is shared.
    % Found during this feature's T022 network-scale validation: a two-fold-symmetric
    % molecule (glutathione disulfide, gthox[c]) where an entire half of the molecule
    % mirrors the other, so many distinct, simultaneously-present bonds would otherwise
    % collapse onto the same canonical key (69 true bonds collapsed to 46 before this
    % guard was added). Detected by iterating to a fixed point: simulate the caller's
    % per-bond substitution decision using the unsafe map built so far, find any distinct
    % bonds whose simulated keys collide, and add each such bond's raw endpoints to each
    % other's class's unsafe set (extending, never replacing, the map above) -- repeating
    % since blocking one collision can occasionally surface another. This can only ADD
    % entries (never remove), and there are finitely many (class, neighbour) pairs to add,
    % so it converges within at most numel(headAtoms) rounds.
    numBonds = numel(headAtoms);
    addedThisRound = true;
    guardIter = 0;
    while addedThisRound && guardIter <= numBonds
        guardIter = guardIter + 1;
        addedThisRound = false;
        effHead = zeros(numBonds, 1);
        effTail = zeros(numBonds, 1);
        for bIdx = 1:numBonds
            effHead(bIdx) = simulateSafeCanonicalizeOneAtom(headAtoms(bIdx), tailAtoms(bIdx), canonicalAtomNumberMap, unsafeNeighborsByClass);
            effTail(bIdx) = simulateSafeCanonicalizeOneAtom(tailAtoms(bIdx), headAtoms(bIdx), canonicalAtomNumberMap, unsafeNeighborsByClass);
        end
        effKeyStr = cell(numBonds, 1);
        for bIdx = 1:numBonds
            a = effHead(bIdx); b = effTail(bIdx);
            if a <= b
                effKeyStr{bIdx} = sprintf('%d_%d', a, b);
            else
                effKeyStr{bIdx} = sprintf('%d_%d', b, a);
            end
        end
        [~, ~, keyIc] = unique(effKeyStr);
        keyCounts = accumarray(keyIc, 1);
        for bIdx = 1:numBonds
            if keyCounts(keyIc(bIdx)) > 1
                h = headAtoms(bIdx); t = tailAtoms(bIdx);
                rh = canonicalAtomNumberMap(h);
                rt = canonicalAtomNumberMap(t);
                if rh ~= h
                    if ~isKey(unsafeNeighborsByClass, rh)
                        unsafeNeighborsByClass(rh) = [];
                    end
                    if ~ismember(t, unsafeNeighborsByClass(rh))
                        unsafeNeighborsByClass(rh) = [unsafeNeighborsByClass(rh), t];
                        addedThisRound = true;
                    end
                end
                if rt ~= t
                    if ~isKey(unsafeNeighborsByClass, rt)
                        unsafeNeighborsByClass(rt) = [];
                    end
                    if ~ismember(h, unsafeNeighborsByClass(rt))
                        unsafeNeighborsByClass(rt) = [unsafeNeighborsByClass(rt), h];
                        addedThisRound = true;
                    end
                end
            end
        end
    end

catch ME
    if ~isempty(ME.stack)
        locInfo = sprintf('%s line %d', ME.stack(1).file, ME.stack(1).line);
    else
        locInfo = 'no stack available';
    end
    warning('identifyAtomEquivalenceClasses:fallback', ...
        ['Symmetry-equivalence-class detection was inconclusive for metabolite %s and fell back to plain ', ...
         'atom-number canonicalization for this metabolite only (%s, at %s).'], ...
        metName, ME.message, locInfo);
    canonicalAtomNumberMap = containers.Map('KeyType', 'double', 'ValueType', 'double');
    equivalenceClasses = cell(numel(atomNumbers), 1);
    for k = 1:numel(atomNumbers)
        canonicalAtomNumberMap(atomNumbers(k)) = atomNumbers(k);
        equivalenceClasses{k} = atomNumbers(k);
    end
    unsafeNeighborsByClass = containers.Map('KeyType', 'double', 'ValueType', 'any');
end

end

function atomOut = simulateSafeCanonicalizeOneAtom(atomRaw, otherAtomRaw, rankMap, unsafeMap)
% Mirrors buildAtomAndBondTransitionMultigraph.m's safeCanonicalizeOneAtom exactly (kept as
% a separate, intentionally duplicated copy rather than a shared utility, since the two
% call sites serve different purposes: the caller's copy performs the real substitution
% decision on actual reaction bonds, this one only SIMULATES that decision, once per
% candidate metabolite instance, to let the cross-bond collision guard above detect
% collisions the caller would actually produce). Any behavioural change to
% safeCanonicalizeOneAtom must be mirrored here.
atomOut = atomRaw;
if ~isKey(rankMap, atomRaw)
    return;
end
canonicalRep = rankMap(atomRaw);
if canonicalRep == atomRaw
    return;
end
if isKey(unsafeMap, canonicalRep) && ismember(otherAtomRaw, unsafeMap(canonicalRep))
    return;
end
atomOut = canonicalRep;
end

function groups = groupIndicesByColor(colorCellArray)
% Partition 1:numel(colorCellArray) into groups sharing the same colour string
[~, ~, ic] = unique(colorCellArray);
groups = cell(max(ic), 1);
for u = 1:max(ic)
    groups{u} = find(ic == u)';
end
end

function tf = pairIsGraphAutomorphic(G, idxA, idxB)
% True iff there exists a graph automorphism of G (element- and bond-type-preserving)
% mapping local node idxA to local node idxB. Checked by tagging idxA's Element with a
% unique sentinel in one copy of G, idxB's Element with the same sentinel in another copy,
% and testing isisomorphic across the two tagged copies (matching on 'Element' and edge
% 'Weight'): only an isomorphism that sends idxA to idxB can match the sentinel-tagged
% node on both sides, so a match here certifies idxA and idxB are truly interchangeable
% (not merely sharing a color-refinement invariant).
GA = G;
GB = G;
GA.Nodes.Element{idxA} = [GA.Nodes.Element{idxA} '_ROOT'];
GB.Nodes.Element{idxB} = [GB.Nodes.Element{idxB} '_ROOT'];
tf = isisomorphic(GA, GB, 'NodeVariables', 'Element', 'EdgeVariables', 'Weight');
end
