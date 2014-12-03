%
% FUNCTION opts = CreateFluxModeOpts(varargin)
%     Creates an options structure for the CalculateFluxModes function.
%
% Sample calls:
%    opts = CreateFluxModeOpts('arithmetic', 'fractional', 'compression', 'off');
%                     Fractional arithmetic will be used and all 
%                     compression options are switched off
%    opts = CreateFluxModeOpts('level', 'FINE', 'sign-only', true);
%                     Log level FINE is used for verbose output, and only
%                     sign values of reaction fluxes are computed.
%
% The following options are supported (any others are silently ignored):
%    'arithmetic'     Which arithmetic to use, one of
%                       'double'     Double precision floating point (default)
%                       'fractional' Fraction numbers, fixed or infinite
%                                    precision
%    'precision'      Bits to use for fraction numerator/denominator,
%                     -1 for infinite precision, or 64, 128, ... bits for
%                     fixed precision (only for arithmetic=fractional)
%    'zero'           Values to be treated as zero
%                     defaults are 1e-10 for double arithmetic and 0 for
%                     fractional arithmetic
%    'compression'    Which compression techniques should be applied to the
%                     network before efm computation, one of
%                       'default'                    Default compression
%                       'default-no-combine'         No reaction merging
%                       'default-no-couple-combine'  Reduced react. merging
%                       'default-no-duplicate'       No duplicate gene com.
%                       'default-all-duplicate'      Extended duplicate 
%                                                    gene compression
%                       'off'                        No compression at all
%                       'unique'                     only unique flows
%                                                    compression
%                       'nullspace'                  Only nullspace based
%                                                    compression
%                       'unique-no-recursion'        Only one round of 
%                                                    unique flows compr.
%                       'nullspace-no-recursion'     Only one round of 
%                                                    nullspace compression
%
%    'level'          The log level, default is INFO, supported:
%                       'WARNING', 'INFO', 'FINE', 'FINER', 'FINEST'
%
%    'maxthreads'     Maximum threads to use, default is 1 for single core
%                     systems and k for multi core systems with k cores.
% 
%    'normalize'      Normalization method of the output efms, one of
%                       'min'     default, minimum absolute value is 1
%                       'max'     maximum absolute value is 1
%                       'norm2'   norm 2, that is, vector length is 1
%                       'squared' like norm 2, but all values are squared, 
%                                 possibly negative. To get the original 
%                                 value, take the square root of the 
%                                 absolute value and keep the sign, i.e.
%                                 val = sign(valsq) * sqrt(abs(valsq)).
%                                 This method allows error free values
%                                 if fraction number arithmetic is used.
%                       'none'    no normalization
%
%    'count-only'     If true, the (binary) modes are computed and the 
%                       number of efms is returned, but not the efm vectors
%    'sign-only'      If true, the (binary) modes are computed, but only 
%                       sign values of reaction fluxes are returned as EFMs.
%                       The values +/-1 stand for forward/reverse flux, and 0
%                       for no flux, respectively. Such sign-valued EFMs can
%                       be converted back into double valued EFMs by using
%                       the SignToDouble function.
%    'parse-only'     If true, input data is processed and parsed, but no
%                       elementary modes are computed. The returned 
%                       structure contains no efms field
%    'convert-only'   If true, input data is processed and converted into
%                       the program's internal format. The efm computation
%                       itself is not started, but call options (for manual
%                       invocation of the Java program) are reported as
%                       return string. The converted files are stored in 
%                       the tmp directory.
%                       Depending on the input format, these files are:
%                           - stoich.txt    the stoichiometric matrix
%                           - revs.txt      the reaction reversibilities
%                           - mnames.txt    the metabolite names
%                           - rnames.txt    the reaction names
%                           - rlist.txt     the reaction list file
%                           - xbml.xml      the sbml input file
%                                 
%    'suppress'       List of reaction names to suppress, separated by 
%                       whitespace. All resulting flux modes will have a 
%                       zero flux value for suppressed reactions
%
%    'enforce'       List of reaction names to enforce, separated by 
%                       whitespace. All resulting flux modes will have a 
%                       non-zero flux value for enforced reactions
%
%    'adjacency-method' Many different methods, all using pattern trees, 
%                       the fastest methods are
%                       'pattern-tree-minzero'   default, combinatorial
%                                                test with pattern trees
%                       'pattern-tree-rank'      standard rank test with
%                                                doubles precision
%                       'pattern-tree-mod-rank'  rank test with residue
%                                                arithmetic
%                       'rankup-modpi-incore'    rank updating with residue 
%                                                int32 arithmetic, prime
%                                                p <= sqrt((2^31-1)/2),
%                                                pattern tree is stored in
%                                                memory (i.e. in-core)
%                       'rankup-modpi-outcore'   rank updating with residue 
%                                                int32 arithmetic, prime
%                                                p <= sqrt((2^31-1)/2),
%                                                pattern tree is stored out
%                                                of the main memory (i.e. 
%                                                out-of-core)
%                       'pattern-tree-rank-update-modpi' rank updating with
%                                                        residue int32
%                                                        arithmetic, prime
%                                                        p <= sqrt((2^31-1)/2)
%                       'pattern-tree-rank-update-modp'  rank updating with
%                                                        residue int64
%                                                        arithmetic, prime
%                                                        p <= 2^31-1
%                       'pattern-tree-rank-update-frac'  rank updating with
%                                                        fraction numbers
%                       'pattern-tree-rank-update-frac2' rank updating with
%                                                        fraction numbers
%                                                        and copying
%
%    'rowordering'    Nullspace row ordering, affecting growth of
%                     intermediary modes during the iteration phase.
%                     The fastest row orderings are
%                       'MostZerosOrAbsLexMin'    default, most zeros in a 
%                                                 row, or absoulte 
%                                                 lexicographical if equal
%                       'MostZeros'               most zeros in a row
%                       'AbsLexMin'               absoulte lexicographical
%                       'LexMin'                  lexicographical
%                       'FewestNegPos'            lowest product of 
%                                                 negative/positive counts
%                       'MostZerosOrFewestNegPos' the two orderings, the
%                                                 second ordering is used 
%                                                 if sorting equal with 1st
%                       'MostZerosOrLexMin'       the two orderings, the
%                                                 second ordering is used 
%                                                 if sorting equal with 1st
%                       'FewestNegPosOrMostZeros' the two orderings, the
%                                                 second ordering is used 
%                                                 if sorting equal with 1st
%                       'FewestNegPosOrAbsLexMin' the two orderings, the
%                                                 second ordering is used 
%                                                 if sorting equal with 1st
%                       'Random'                  random sorting
%
%    'model'          Algorithm variant for EFM computation. Default model
%                     is a nullspace-model, which uses the binary nullspace
%                     approach (J. Gagneur & S. Klamt / C. Wagner).
%                     Supported algorithm model variants are:
%                       'nullspace'              default, binary nullspace
%                                                approach
%                       'canonical'              canonical approach
%
%    'memory'         Memory type to use, which is usually in-core (main
%                     memory, RAM) or out-of-core (store intermediary 
%                     results on disk).
%                     Supported memory variants are:
%                       'in-core'                default, keep all modes in
%                                                main memory
%                       'out-core'               store intermediary results
%                                                in files on disk, in the
%                                                temp directory (see 
%                                                'tmpdir' option). For 
%                                                extreme cases, the bit 
%                                                pattern trees should also
%                                                stored on disk, which is
%                                                currently supported by the
%                                                'adjacency-method' option
%                                                'rankup-modpi-outcore'
%                       'sort-out-core'          like 'out-core', but also
%                                                sorting to create the 
%                                                pattern trees is performed
%                                                out of core memory
%
%    'impl'           Algorithm implementation for EFM computation. Default
%                     is a sequential double description implementation.
%                     Supported algorithm implementations:
%                       'SequentialDoubleDescriptionImpl'	default
%
%    'tmpdir'         Directory for temporary files, e.g. data files for
%                     intermediary results if out core implementation is
%                     used (see memory option). Fast, non-server 
%                     directories with large storage capacity are 
%                     preferable. Default is tmp subdirectory in the 
%                     installation path
%
% Version:
%	=========================================================================
%	efmtool version 4.7.1, 2009-12-04 18:29:52
%	Copyright (c) 2009, Marco Terzer, Zurich, Switzerland
%	This is free software, !!! NO WARRANTY !!!
%	See LICENCE.txt for redistribution conditions
%	=========================================================================
%
function opts = CreateFluxModeOpts(varargin)
    for i=1:2:length(varargin)
        opts.(strrep(varargin{i}, '-', '_')) = varargin{i+1};
    end
end
