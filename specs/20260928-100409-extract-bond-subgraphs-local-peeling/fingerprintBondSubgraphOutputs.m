function fingerprint = fingerprintBondSubgraphOutputs(bondSubgraphs, BMG, bmgEdgeIndex)
% SHA-256 fingerprints of the outputs of extractBondSubgraphs
%
% USAGE:
%
%    fingerprint = fingerprintBondSubgraphOutputs(bondSubgraphs, BMG, bmgEdgeIndex)
%
% INPUTS:
%    bondSubgraphs:    cell array of graph/digraph objects
%    BMG:              cell array of digraph objects
%    bmgEdgeIndex:     cell array of EdgeIndex vectors
%
% OUTPUT:
%    fingerprint:      structure with fields
%
%                        * .bondSubgraphs - cell array, one hex SHA-256 per graph, of the
%                          serialised {class, Nodes, Edges}
%                        * .BMG - the same for every Bond Mapping Graph
%                        * .bmgEdgeIndex - one hex SHA-256 of the serialised cell array
%                        * .outputSize - sum of numnodes + numedges over both cell arrays
%
% NOTE:
%    The golden outputs of the large local fixtures would take many gigabytes as MAT files,
%    so they are stored as these fingerprints (research R8). Equal fingerprints imply equal
%    outputs. A different fingerprint is not by itself a failure: serialised tables can
%    differ in bytes while being isequaln, so extractBondSubgraphsPeelingCheck.m decides
%    equality by comparing live against the pre-change function.
%
% .. Author: - COBRA Toolbox, feature 20260928-100409-extract-bond-subgraphs-local-peeling

fingerprint.bondSubgraphs = cellfun(@graphFingerprint, bondSubgraphs, 'UniformOutput', false);
fingerprint.BMG = cellfun(@graphFingerprint, BMG, 'UniformOutput', false);
fingerprint.bmgEdgeIndex = sha256Hex(getByteStreamFromArray(bmgEdgeIndex));
fingerprint.outputSize = sum(cellfun(@(g) numnodes(g) + numedges(g), [bondSubgraphs(:); BMG(:)]));
end

function hex = graphFingerprint(G)
hex = sha256Hex(getByteStreamFromArray({class(G), G.Nodes, G.Edges}));
end

function hex = sha256Hex(bytes)
digester = java.security.MessageDigest.getInstance('SHA-256');
digest = typecast(digester.digest(bytes(:)), 'uint8');
hex = lower(reshape(dec2hex(digest, 2)', 1, []));
end
