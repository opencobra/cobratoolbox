function [atom, atomIndex] = resolveAtomNodeIndex(nodeTable, nodeIndexMap, met, atomNumber, element)
% Resolve one composite atom identity against a once-built node-identity index
%
% Looks up the row of `nodeTable` (typically `dATM.Nodes`) matching the
% composite identity `(met, atomNumber, element)` via `nodeIndexMap` -- a
% `containers.Map` built once per caller invocation, keyed on the same
% composite identity -- and returns that row's `Atom`/`AtomIndex` values.
% Replaces the repeated `ismember`-based boolean-mask scans previously used
% at each bond-transition iteration in `buildAtomAndBondTransitionMultigraph`
% to resolve substrate/product head/tail atom identities.
%
% Raises an explicit, identifiable error -- rather than silently selecting an
% arbitrary match or silently returning an empty/default value -- when the
% key resolves to zero or more than one `nodeTable` row, since `nodeIndexMap`
% stores every matching row index per key (not just the last one written) to
% preserve visibility into a duplicate-key data-invariant violation.
%
% USAGE:
%
%    [atom, atomIndex] = resolveAtomNodeIndex(nodeTable, nodeIndexMap, met, atomNumber, element)
%
% INPUTS:
%    nodeTable:      table with `Atom` (cell array of char) and `AtomIndex`
%                    (double) columns, row-aligned with the row indices
%                    stored in `nodeIndexMap`
%    nodeIndexMap:   `containers.Map('KeyType','char','ValueType','any')`
%                    built by one pass over `nodeTable`, keyed on
%                    `sprintf('%s\x1f%d\x1f%s', met, atomNumber, element)`,
%                    with values being the 1-based row index (or indices, if
%                    more than one row shares a key) into `nodeTable`
%    met:            metabolite identifier component of the composite key
%    atomNumber:     in-metabolite canonical atom number component of the
%                    composite key
%    element:        element symbol component of the composite key
%
% OUTPUTS:
%    atom:           `nodeTable.Atom` sliced at the uniquely-resolved row
%    atomIndex:      `nodeTable.AtomIndex` sliced at the uniquely-resolved row
%
% NOTE:
%    Raises `resolveAtomNodeIndex:missingNodeIdentity` when
%    `(met, atomNumber, element)` is not a key in `nodeIndexMap` (zero
%    matching rows), and `resolveAtomNodeIndex:ambiguousNodeIdentity` when it
%    resolves to more than one row. Both are raised before either column of
%    `nodeTable` is read.
%
% Authors:
%    - COBRA Toolbox, feature 20260902-150020-eliminate-bond-transition-ismember-scans

key = sprintf('%s\x1f%d\x1f%s', met, full(atomNumber), element);
if isKey(nodeIndexMap, key)
    idx = nodeIndexMap(key);
else
    idx = [];
end

if isempty(idx)
    error('resolveAtomNodeIndex:missingNodeIdentity', ...
        'No node matches (mets=%s, AtomNumber=%d, Element=%s).', met, atomNumber, element);
elseif numel(idx) > 1
    error('resolveAtomNodeIndex:ambiguousNodeIdentity', ...
        '%d nodes match (mets=%s, AtomNumber=%d, Element=%s); expected exactly 1.', ...
        numel(idx), met, atomNumber, element);
end

atom = nodeTable.Atom(idx);
atomIndex = nodeTable.AtomIndex(idx);

end
