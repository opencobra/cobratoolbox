function [key, met1, atomNum1, elem1, met2, atomNum2, elem2] = canonicalBondKey(metA, atomNumA, elemA, metB, atomNumB, elemB)
% Build an order-independent identifier for one bond instance
%
% Orders the two (metabolite, atomNumber, element) triples describing a
% bond's two atoms deterministically, so the same physical bond always
% produces the same key and the same canonically-ordered atom pair,
% regardless of which atom a given RXN file's connection table happened to
% list first. Used to canonicalise the bond-node identity strings built in
% `buildAtomAndBondTransitionMultigraph`, so that a bond of a metabolite
% shared across independently-generated RXN files always collapses onto one
% `dBTM.Nodes` row instead of one row per raw-order variant encountered.
%
% USAGE:
%
%    [key, met1, atomNum1, elem1, met2, atomNum2, elem2] = canonicalBondKey(metA, atomNumA, elemA, metB, atomNumB, elemB)
%
% INPUTS:
%    metA:      metabolite identifier of the bond's first raw-order atom
%    atomNumA:  in-metabolite atom number of the bond's first raw-order atom
%    elemA:     element symbol of the bond's first raw-order atom
%    metB:      metabolite identifier of the bond's second raw-order atom
%    atomNumB:  in-metabolite atom number of the bond's second raw-order atom
%    elemB:     element symbol of the bond's second raw-order atom
%
% OUTPUTS:
%    key:       order-independent string identifier for this bond, of the
%               form `<met1>#<atomNum1>#<elem1>#<met2>#<atomNum2>#<elem2>`
%    met1:      metabolite identifier of the canonically-first atom
%    atomNum1:  in-metabolite atom number of the canonically-first atom
%    elem1:     element symbol of the canonically-first atom
%    met2:      metabolite identifier of the canonically-second atom
%    atomNum2:  in-metabolite atom number of the canonically-second atom
%    elem2:     element symbol of the canonically-second atom
%
% Primary sort key: metabolite identifier (handles a bond crossing to a
% different metabolite/energy node, where `metA` and `metB` differ).
% Secondary sort key: atom number within one metabolite (handles the common
% intramolecular case, `metA == metB`). Two distinct real atoms within one
% molecule instance cannot share an atom number, so no further tie-break is
% needed.
%
% Authors:
%    - COBRA Toolbox, feature 019-canonicalize-bond-node-keys

if strcmp(metA, metB)
    firstIsA = atomNumA <= atomNumB;
else
    sortedMets = sort({metA, metB});
    firstIsA = strcmp(sortedMets{1}, metA);
end

if firstIsA
    met1 = metA; atomNum1 = atomNumA; elem1 = elemA;
    met2 = metB; atomNum2 = atomNumB; elem2 = elemB;
else
    met1 = metB; atomNum1 = atomNumB; elem1 = elemB;
    met2 = metA; atomNum2 = atomNumA; elem2 = elemA;
end

key = [met1 '#' num2str(atomNum1) '#' elem1 '#' met2 '#' num2str(atomNum2) '#' elem2];

end
