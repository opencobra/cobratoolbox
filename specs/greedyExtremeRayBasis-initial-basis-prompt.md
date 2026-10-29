/speckit-human-loop

Feature: let greedyExtremeRayBasis complete a supplied partial non-negative basis of the left nullspace, and recover when its targeted objective has the wrong sign.

## Context

The manuscript /home/rfleming/drive/sbgCloud/projects/variationalKinetics/repo/papers/moietyRank/moietyRank.lyx (Appendix D, "Constructive identification of complete moiety bases", Proposition "prop:mr:left-basis") describes a procedure for completing a basis of ker(N^T). Read that appendix before specifying. It starts from L0, a set of independent conserved moiety vectors with L0*N = 0 and L0 >= 0, such as the output of identifyConservedMoieties (arm.L) after an independent subset of rows has been selected. The procedure adds delta = (m - rank(N)) - rank(L0) extreme rays of the cone K = {w >= 0 : N^T w = 0}, until L0 together with the added rays is a basis of ker(N^T).

When delta > 0, no set of conserved moiety vectors spans ker(N^T). The added rays are the conservation relations that are not moieties. The output must therefore keep L0 unchanged and add only the missing rays. Computing an unrelated basis from scratch does not meet the requirement.

src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m already solves the right linear programme, through findExtremePool: maximise c^T w subject to S^T w = 0, 1^T w = 1, w >= 0. When it stalls, targetedObjective uses as c the leading direction g of ker(S^T) that is orthogonal to the rays accepted so far. That is exactly Proposition (c) in the manuscript, with G the accepted rays. It has two gaps:

1. It always starts from an empty basis. Each restart (after maxNewBasisTime) discards everything back to empty, around line 450.
2. targetedObjective takes the leading left singular vector, whose sign is arbitrary, and maximises +g only. The shift by min(direction) adds a constant on the feasible set, so it does not fix the sign. If the maximum of g^T w over the feasible polytope is 0, the optimal vertex can lie in the span of G, and the search stalls. The manuscript shows that at least one of +g and -g has a positive optimum, and that any optimal vertex of that programme is a new extreme ray outside span(G).

## Required behaviour

- Add an optional input (suggested name: param.initialBasis), a k x m matrix of candidate rows.
  - Validate each row: non-negative, and meeting the same accuracy target that the function applies to accepted rays. Report any row that fails, and do not return it.
  - Keep a maximal independent subset in the supplied row order, and report which rows were dropped as dependent.
  - Put the kept rows in the first rows of Zpos, never alter them, and restore them after every restart.
  - Search only for the remaining (nullity - kept) rays.
  - If nothing remains, return without solving any LP.
- In the targeted step, if the vertex returned for +g is dependent on the current basis, or |g^T w| is below tolerance, re-solve with -g before counting a failure.
- With initialBasis absent or empty, behaviour must be unchanged: same random stream, same outputs. Check the existing tests and the spec history in specs/20260914-*, 20260915-*, 20261003-* to see what bit-for-bit compatibility has meant in this repo.
- Extend status, which is populated on every call, with suitably named fields for: rows supplied, rows kept, rows dropped as dependent, rows rejected for accuracy or sign, and rays added. Add a count of sign retries. The meaning of the existing fields must not change.
- In right-nullspace mode (param.leftRight = 'right'), initialBasis must behave the same way on the transposed problem.

## Acceptance fixtures

Build these as small models with S equal to the given internal N and no exchange reactions. Species are rows. Rays are compared up to positive scaling and in exact rational form.

1. Dimer. N = [-1 0 2; 1 -2 0; 0 1 -1], L0 = [1 1 2]. Expected: complete immediately, 0 rays added, no LP solved.

2. Coupled antiport. Species in the order Xe, Xp, Xc, Yc, Ye, Yp.
   N = [-1 1 0 0; 0 -1 1 0; 1 0 -1 0; -1 0 1 0; 1 0 0 -1; 0 0 -1 1]
   L0 = [1 1 1 0 0 0; 0 0 0 1 1 1]
   rank(N) = 3 and the nullity is 3, so exactly 1 ray is added. It must be (0,0,1,1,0,0) or (1,1,0,0,1,1), and the first two rows of Zpos must equal L0.

3. Exchange with transport.
   N (8x6) = [-1 0 0 0 1 0; -1 0 0 0 0 1; 1 -1 0 0 0 0; 1 0 -1 0 0 0; 0 0 0 1 -1 0; 0 0 0 1 0 -1; 0 1 0 -1 0 0; 0 0 1 -1 0 0]
   initialBasis = [1 0 1 0 1 0 1 0; 1 0 0 1 1 0 0 1; 0 1 1 0 0 1 1 0; 0 1 0 1 0 1 0 1]
   rank(N) = 5 and the nullity is 3. Expected: rows 1-3 kept, row 4 reported as dependent, complete with 0 rays added.

4. Sign recovery. S = [1; -1; 0] (3 species, 1 reaction). The cone's extreme rays are (1,1,0) and (0,0,1).
   With initialBasis = [1 1 0], the objective -g, where g is proportional to (0,0,1), returns (1,1,0)/2, which is dependent.
   Write a test that forces the -g sign first, through a test-only hook or by unit-testing the helper, and show that the search recovers (0,0,1) by retrying with +g.

5. Regression. The existing testGreedyExtremeRayBasis and related tests (testCheckNullspaceBasis, testNullspaceAccuracyTarget) pass unchanged.

6. Real model. On iDopaNeuroC or Recon3D, as used in earlier features:
   - pass as initialBasis the conserved moiety matrix L from identifyConservedMoieties, if an atom-mapped model is available in this repo, or else a random subset of rows of a previously computed Zpos;
   - show that the supplied rows survive unchanged and that the result is complete.
   Report the counts with their scope.

## Constraints and non-goals

- LP solver: gurobi, as the function already nominates. mosek is rejected because it does not return vertices.
- Do not change findExtremePool's behaviour for its other callers.
- Out of scope; record each one as a separate follow-up in the spec, not in this feature:
  - recovering exact integer rays from the support of a floating-point vertex;
  - adding the entrywise faithful-accounting check M*M2R == M2M'*N to identifyConservedMoieties (it currently checks only M2M*M2M'*N == M2M*M*M2R).
- Update the function's header documentation, including a NOTE entry in the style of the existing ones, and record the change in the repo's usual places.
