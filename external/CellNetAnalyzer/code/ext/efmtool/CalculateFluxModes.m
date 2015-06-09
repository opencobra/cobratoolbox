%
% FUNCTION mnet = CalculateFluxModes(...)
%     Computes elementary flux modes for a given metabolic network
%
% Input formats:
%
%    mnet = CalculateFluxModes(stru)
%           stru is a structure with the following fields:
%           - stru.stoich           the stoichiometric matrix
%           - stru.reversibilities  reaction reversibilities
%                                   0/1 for irreversible/reversible
%           - stru.metaboliteNames  optional, metabolite names (cell array)
%           - stru.reactionNames    optional, reaction names (cell array)
%
%    mnet = CalculateFluxModes(stoich, reversibilities)
%           - stoich           the stoichiometric matrix
%           - reversibilities  reaction reversibilities
%                              0/1 for irreversible/reversible
%
%    mnet = CalculateFluxModes(stoich, reversibilities, mnames, rnames)
%           - stoich           the stoichiometric matrix
%           - reversibilities  reaction reversibilities
%                              0/1 for irreversible/reversible
%           - mnames           metabolite names (cell array)
%           - rnames           reaction names (cell array)
% 
%    mnet = CalculateFluxModes(reactionFormulas)
%           - reactionFormulas cell array with reaction formulas, e.g. like
%                              {'S1 + 2 S2  --> 2 P1 + 3 P2', 'P2 <-->'}
%
%    mnet = CalculateFluxModes(reactionFormulas, reactionNames)
%           - reactionFormulas cell array with reaction formulas, e.g. like
%                              {'S1 + 2 S2  --> 2 P1 + 3 P2', 'P2 <-->'}
%           - reactionNames    cell array with reaction names
%
%    mnet = CalculateFluxModes(sbmlFileName, validateSchema)
%           - sbmlFileName     the SBML file to parse, 'external' is used
%                              as external compartment
%           - validateSchema   if true, the sbml file is validated 
%                              regarding to the associated xml schema file
%
%    mnet = CalculateFluxModes(sbmlFileName, validateSchema, extCompartment)
%           - sbmlFileName     the SBML file to parse
%           - validateSchema   if true, the sbml file is validated 
%                              regarding to the associated xml schema file
%           - extCompartment   name of the external compartment 
%
% Options:
%    To all calls above, an additional options structure object can be
%    appended as last argument. An options structure is created by using
%    the function CreateFluxModeOpts(...).
%
% Output format:
%    Structure mnet with the fields
%       - metaboliteNames      metabolite names (cell array)
%       - reactionNames        reaction names (cell array)
%       - reactionFormulas     reaction formulas (cell array)
%       - reactionLowerBounds  reaction upper bounds
%                              0/-Inf for irreversible/reversible reactions
%       - reactionUpperBounds  reaction upper bounds, usually all Inf
%       - stoich               the stoichiometric matrix
%       - efms                 the elementary flux modes
%    Note: 
%       - if option 'count-only' is true, the number of EFMs is returned
%         instead.
%       - if option 'sign-only' is true, the EFMs contain only the flux
%         sign values, i.e. +/-1 for forward/backward flux, and 0 for 
%	  no flux.
%       - if option 'parse-only' is true, the returned structure contains 
%         no efms field, i.e. the result contains no elementary modes.
%       - if option 'convert-only' is true, a string is returned,
%         containing the Java call arguments
%
% Version:
%    18-Aug-2009/V4.4.4    mt  compiled w. Java 1.5, SVD for SignToDouble
%    18-Aug-2009/V4.4.2    mt  performance improvements, better tracing
%    19-Mar-2009/V4.2.1    mt  merged with polco, new sort-out-core option
%    27-Oct-2008/V2.33.00  mt  package refactoring, use QR for SignToDouble
%    10-Oct-2008/V2.32.00  mt  fixed logging within MATLAB
%    04-Sep-2008/V2.31.20  mt  fixed 'memory' option & deletion of efm files
%    03-Sep-2008/V2.31.10  mt  added 'sign-only' option
%    28-Aug-2008/V2.31.01  mt  new doc version for options
%    28-Aug-2008/V2.31.00  mt  backward compat.: recompiled with Java 1.5
%    21-Aug-2008/V2.30.00  mt  speed-up (tree shortening) and added new
%                              'parse-only' option, version now in sync
%                              with java cvs tag
%    04-Aug-2008/V1.20.00  mt  various fixes (rev sign, opt arg, ...), 
%                              switched off duplicate gene compression
%    05-May-2008/V1.12.00  mt  added parse-only option
%    25-Apr-2008/V1.11.00  mt  added tmpdir/impl options, out core impl
%    01-Apr-2008/V1.10.00  mt  added options suppress/enforce
%    12-Feb-2008/V1.00.00  mt  initial version (online at paper submission)
%
function mnet = CalculateFluxModes(varargin)
    if (nargin == 1 && hasStringArg(varargin, '--clear'))
        initJava(true);
        return;
    else
%A#        initJava(false);
        if (nargin == 1 && hasStringArg(varargin, '--init'))
            return;
        end
    end

    if (nargin == 0)
        help CalculateFluxModes;
        return;
    end

    try
        opts = createOpts(varargin{:});
        if (nargin >= 1 && hasStringArg(varargin, '--help'))
            ch.javasoft.metabolic.efm.main.CalculateFluxModes.matlab('--help');
        elseif (nargin >= 2 && iscell(varargin{1}) && iscell(varargin{2}))
            mnet = CalculateFormulas(opts, varargin{1}, varargin{2});
        elseif (nargin >= 1 && iscell(varargin{1}))
            mnet = CalculateFormulas(opts, varargin{1});
        elseif (nargin >= 1 && isstruct(varargin{1}))
            if (isfield(varargin{1}, 'stoich') && isfield(varargin{1}, 'reversibilities'))
                if (isfield(varargin{1}, 'metaboliteNames') && isfield(varargin{1}, 'reactionNames'))
                    mnet = CalculateStoich(opts, ...
                        varargin{1}.stoich, ...
                        varargin{1}.reversibilities, ...
                        varargin{1}.metaboliteNames, ...
                        varargin{1}.reactionNames);
                else
                    mnet = CalculateStoich(opts, ...
                        varargin{1}.stoich, varargin{1}.reversibilities);
                end
            else
                error('struct argument must have at least two members: stoich/reversibilities');
            end
        elseif (nargin >= 4 && isnumeric(varargin{1}) && ...
                (isnumeric(varargin{2}) || islogical(varargin{2})) &&...
                iscell(varargin{3}) && iscell(varargin{4}))
            mnet = CalculateStoich(opts, varargin{1}, varargin{2}, varargin{3}, varargin{4});
        elseif (nargin >= 2 && isnumeric(varargin{1}) && ...
                (isnumeric(varargin{2}) || islogical(varargin{2})))
            mnet = CalculateStoich(opts, varargin{1}, varargin{2});
        elseif (nargin >= 3 && ischar(varargin{1}) && ...
                (isnumeric(varargin{2}) || islogical(varargin{2})) && ...
                ischar(varargin{3}))
            mnet = CalculateSBML(opts, varargin{1}, varargin{2}, varargin{3});
        elseif (nargin >= 2 && ischar(varargin{1}) && ...
                (isnumeric(varargin{2}) || islogical(varargin{2})))
            mnet = CalculateSBML(opts, varargin{1}, varargin{2}, 'external');
        else
            error('invalid usage of CalculateFluxModes');
        end
    catch
        fprintf('an unexpected error occurred\n');
        rethrow(lasterror);
    end
    initJavaLogging();
end

%% mnet = CalculateFormulas()
% 
% Writes the reaction formulas to the temp file ./tmp/rlist.txt
%
% Calls the java function with -kind reaction-list.
% 
function mnet = CalculateFormulas(opts, rformulas, rnames)
    if (nargin < 3)
        rnames = {};
        for i=1:length(rformulas)
            rnames{i} = ['R' num2str(i)];
        end
    end    
    delete(fullfile('tmp', 'efms_*.mat'));
    writeFormulas(fullfile('tmp', 'rlist.txt'), rformulas, rnames);
    callArgs = getCallArgs(opts, ...        
        '-kind', 'reaction-list', ...
        '-in', fullfile('tmp', 'rlist.txt') ...
	);
    if (opts.convert_only)
       mnet = callArgsAsString(callArgs); 
    else
        myprintf(opts, '%s\n', callArgsAsString(callArgs));
        val = ch.javasoft.metabolic.efm.main.CalculateFluxModes.matlab(callArgs);
        if (val < 0)
            mnet = 'An unexpected error occurred (see log for details)';
        else
            if (opts.count_only)        
                mnet = val;
            else
                mnet = loadMnet();
            end
        end
    end        
end

%% mnet = CalculateStoich()
% 
% Writes the reaction stoichiometry, reversibilities, metabolite and 
% reaction name files stoich.txt, revs.txt, mnames.txt and rnames.txt to
% the temp directory ./tmp
%
% Calls the java function with -kind stoichiometry.
% 
function mnet = CalculateStoich(opts, stoich, revs, mnames, rnames)
    if (nargin < 4)
        mnames = {};
        for i=1:size(stoich, 1)
            mnames{i} = ['M' num2str(i)];
        end
    end
    if (nargin < 5)
        rnames = {};
        for i=1:size(stoich, 2)
            rnames{i} = ['R' num2str(i)];
        end
    end    
    if ~exist(fullfile(pwd, 'tmp'), 'dir')
      mnet= sprintf('Cannot access EFM Tool temporary directory; cf. \n%s%sREADME.txt\nfor more information', pwd, filesep);
      return;
    end
    delete(fullfile('tmp', 'efms_*.mat'));
    save(fullfile('tmp', 'stoich.txt'), 'stoich', '-ASCII', '-double', '-TABS')
    writeBool(fullfile('tmp', 'revs.txt'),  revs);
    writeText(fullfile('tmp', 'mnames.txt'), mnames);
    writeText(fullfile('tmp', 'rnames.txt'), rnames);
    callArgs = getCallArgs(opts, ...        
        '-kind', 'stoichiometry', ...
        '-stoich', fullfile('tmp', 'stoich.txt'),...
        '-rev', fullfile('tmp', 'revs.txt'), ...
        '-meta', fullfile('tmp', 'mnames.txt'), ...
        '-reac', fullfile('tmp', 'rnames.txt') ...
    );
    if (opts.convert_only)
       mnet = callArgsAsString(callArgs); 
    else
      fid= fopen(fullfile(pwd, 'java.opts'), 'r');
      if fid ~= -1
        java_opts= fgetl(fid);
        fclose(fid);
      else
        java_opts= '';
      end
      if isunix
        call_str= ['java ', java_opts,...
          ' -cp lib/metabolic-efm-all.jar:lib/dom4j-1.6.1.jar:lib/junit-3.8.1.jar ch.javasoft.metabolic.efm.main.CalculateFluxModes',...
          callArgsAsString(callArgs, true)];
      elseif ispc
        call_str= ['java ', java_opts,...
          ' -cp lib\metabolic-efm-all.jar;lib\dom4j-1.6.1.jar;lib\junit-3.8.1.jar ch.javasoft.metabolic.efm.main.CalculateFluxModes',...
          callArgsAsString(callArgs, true)];
      else
        error('efmtool not supported on this operating system.');
      end
        disp(call_str);
        val= system(call_str);
        if val ~= 0
%A#         myprintf(opts, '%s\n', callArgsAsString(callArgs));
%A#         val = ch.javasoft.metabolic.efm.main.CalculateFluxModes.matlab(callArgs);
%A#         if (val < 0)
            mnet = 'An unexpected error occurred (see log for details)';
        else
            if (opts.count_only)        
                mnet = val;
            else
                mnet = loadMnet();
            end
        end
    end
end

%% mnet = CalculateSBML()
% 
% Copies the specified sbml file to the temp directory ./tmp
%
% Calls the java function with -kind sbml.
% 
function mnet = CalculateSBML(opts, sbmlFile, validateSchema, extCompartment)
    boolOpts = {'false', 'true'};
    
    delete(fullfile('tmp', 'efms_*.mat'));
    copyfile(sbmlFile, fullfile('tmp', 'sbml.xml'));
    callArgs = getCallArgs(opts, ...        
        '-kind', 'sbml', ...
        '-in', fullfile('tmp', 'sbml.xml'), ...
        '-ext', extCompartment, ...
        '-sbml-validate-schema', boolOpts{logical(validateSchema)+1} ...
	);
    if (opts.convert_only)
       mnet = callArgsAsString(callArgs); 
    else
        myprintf(opts, '%s\n', callArgsAsString(callArgs));
        val = ch.javasoft.metabolic.efm.main.CalculateFluxModes.matlab(callArgs);
        if (val < 0)
            mnet = 'An unexpected error occurred (see log for details)';
        else
            if (opts.count_only)        
                mnet = val;
            else
                mnet = loadMnet();
            end
        end
    end
end

%% args = getCallArgs(varargin)
% 
% Creates and returns a cell array with call arguments for the actual
% java call
function args = getCallArgs(opts, varargin)
    nonreq = {'suppress', 'enforce', 'impl', 'memory'}; % see also createOpts
    nonreqopts = {};
    for j=1:length(nonreq)
        if (isfield(opts, nonreq{j}))
            len = length(nonreqopts);
            nonreqopts{len+1} = ['-' nonreq{j}];
            nonreqopts{len+2} = opts.(nonreq{j});
        end
    end
    if (opts.count_only)
        args = {
            varargin{:} ...
            '-arithmetic' opts.arithmetic ...
            '-zero' num2str(opts.zero)...
            '-out' 'count' ...
            '-compression' opts.compression ...
            '-log' 'console' ...
            '-level' opts.level ...
            '-tmpdir' opts.tmpdir ...
            '-maxthreads' num2str(opts.maxthreads) ...
            '-normalize' opts.normalize ...
            '-adjacency-method' opts.adjacency_method ...
            '-rowordering' opts.rowordering ...
            nonreqopts{:} ...
        };
    elseif (opts.parse_only)
        args = {
            varargin{:} ...
            '-arithmetic' opts.arithmetic ...
            '-zero' num2str(opts.zero)...
            '-out' 'matlab' fullfile('tmp', 'efms.mat') ...
            '-parseonly' 'true' ...
            '-compression' opts.compression ...
            '-log' 'console' ...
            '-level' opts.level ...
            '-tmpdir' opts.tmpdir ...
            '-maxthreads' num2str(opts.maxthreads) ...
            '-normalize' opts.normalize ...
            '-adjacency-method' opts.adjacency_method ...
            '-rowordering' opts.rowordering ...
            nonreqopts{:} ...
        };
    elseif (opts.sign_only)
        args = {
            varargin{:} ...
            '-arithmetic' opts.arithmetic ...
            '-zero' num2str(opts.zero)...
            '-out' 'matlab-directions' fullfile('tmp', 'efms.mat') ...
            '-compression' opts.compression ...
            '-log' 'console' ...
            '-level' opts.level ...
            '-tmpdir' opts.tmpdir ...
            '-maxthreads' num2str(opts.maxthreads) ...
            '-normalize' opts.normalize ...
            '-adjacency-method' opts.adjacency_method ...
            '-rowordering' opts.rowordering ...
            nonreqopts{:} ...
        };
    else
        args = {
            varargin{:} ...
            '-arithmetic' opts.arithmetic ...
            '-zero' num2str(opts.zero)...
            '-out' 'matlab' fullfile('tmp', 'efms.mat') ...
            '-compression' opts.compression ...
            '-log' 'console' ...
            '-level' opts.level ...
            '-tmpdir' opts.tmpdir ...
            '-maxthreads' num2str(opts.maxthreads) ...
            '-normalize' opts.normalize ...
            '-adjacency-method' opts.adjacency_method ...
            '-rowordering' opts.rowordering ...
            nonreqopts{:} ...
        };
    end
end

%% myprintf()
%
% Like fprintf, but checks error level first
function count = myprintf(opts, varargin)
    silent = false;
    if (isfield(opts, 'level'))
        try
            lvl = java.util.logging.Level.parse(opts.level);
            silent = lvl.intValue() > 800; % 800 is INFO
        catch
            % ignore
        end
    end
    if (~silent)
        count = fprintf(varargin{:});
    end
end

%% callArgsAsString()
% 
% Writes the reaction formulas file
 function str = callArgsAsString(callArgs, simple)
    if nargin < 2
      simple= false;
    end
    if simple
      str= ' ';
    else
      str = sprintf('java call arguments:\n\t');
    end
    for i=1:length(callArgs)
        if (i > 1), str = sprintf('%s ', str); end
        str = sprintf('%s%s', str, callArgs{i});
    end
    str = sprintf('%s\n', str);
end

%% writeFormulas()
% 
% Writes the reaction formulas file
function writeFormulas(fileName, rformulas, rnames)
    fid = fopen(fileName, 'w');
    for i=1:length(rformulas);
        fprintf(fid, '"%s"\t"%s"\n', rnames{i}, rformat(rformulas{i}));
    end
    fclose(fid);
end
%% rformula = rformat()
% 
% Formula formatting, for uptake/extract reactions
function rformula = rformat(rformula)
    rformula = strtrim(rformula);
    if (length(rformula) > 2 && strcmp(rformula(1:2), '# '))
        rformula = rformula(3:end);
    end
    if (length(rformula) > 2 && strcmp(rformula(end-1:end), ' #'))
        rformula = rformula(1:end-2);
    end
    rformula = strtrim(rformula);
end

%% writeText()
% 
% Writes a tab separated ascii file for text entries (one row)
function writeText(fileName, cellArr)
    fid = fopen(fileName, 'w');
    for i=1:length(cellArr);
        if (i>1), fprintf(fid, '\t'); end
        fprintf(fid, '"%s"', cellArr{i});
    end
    fprintf(fid, '\n');
    fclose(fid);
end
%% writeBool()
% 
% Writes a tab separated ascii file for boolean entries (one row)
function writeBool(fileName, arr)
    fid = fopen(fileName, 'w');
    for i=1:length(arr);
        if (i>1), fprintf(fid, '\t'); end
        fprintf(fid, '%1.0f', arr(i));
    end
    fprintf(fid, '\n');
    fclose(fid);
end

%% mnet = loadMnet()
% 
% Loads one (or multiple) generated mnet files containing EFMs
function mnet = loadMnet()
    mnet = load(fullfile('tmp', 'efms_0.mat'));
    mnet = mnet.mnet;
    fnames = dir(fullfile('tmp', 'efms_*.mat'));
    for i=2:length(fnames)
        mnet2 = load(fullfile('tmp', fnames(i).name));
        mnet.efms = [mnet.efms mnet2.mnet.efms];
        clear mnet2;
    end
end

%% opts = createOpts()
% 
% Create options structure opts, defines default options and owerloads
% default values with specified ones (last varargin argument)
function opts = createOpts(varargin)
    
    opts.arithmetic             = 'double';
    opts.compression            = 'default';
    opts.level                  = 'INFO';
    opts.maxthreads             = -1;
    opts.normalize              = 'min';
    opts.adjacency_method       = 'pattern-tree-minzero';
    opts.rowordering            = 'MostZerosOrAbsLexMin';
    opts.tmpdir                 = fullfile(pwd, 'tmp');
    opts.count_only             = false;
    opts.sign_only              = false;
    opts.convert_only           = false;
    opts.parse_only             = false;
    
    nonreq = {'suppress', 'enforce', 'impl', 'memory', 'zero'}; % see also getCallArgs
    
    nm = fieldnames(opts);
    if (isstruct(varargin{end}))
        for j=1:length(nm)
            if (isfield(varargin{end}, nm{j}))
                opts.(nm{j}) = varargin{end}.(nm{j});
            end
        end
        for j=1:length(nonreq)
            if (isfield(varargin{end}, nonreq{j}))
                opts.(nonreq{j}) = varargin{end}.(nonreq{j});
            end
        end
    end
    if (~isfield(opts, 'zero'))
        if (strcmp(opts.arithmetic, 'fractional'))
            opts.zero = 0;
        else
            opts.zero = 1e-10;
        end
    end

end

%% initJava()
% 
% The following initialization steps are performed (forces reinitialization
% if doClear is true):
%   - Initializes the java path (adds the jar files in the lib directory)
%   - The 'user.dir' java system property is set to the current directory
%   - The 'java.util.logging.config.file' property is set to the file
%     'config/Loggers.properties'
%   - The log levels for 'sun' and 'java' are set to INFO (are at least 
%     FINE by default, causing that all awt events are logged)
function initJava(doClear) 
    java.lang.System.setProperty('user.dir', pwd);
    myjars = dir(fullfile(pwd, 'lib', '*.jar'));
    jpath  = javaclasspath;
    for i=1:length(myjars)
        myjar = fullfile(pwd, 'lib', myjars(i).name);
        if (isInPath(jpath, myjar))
            if (doClear)
                javarmpath(myjar);
                javaaddpath(myjar);
            end
        else
            javaaddpath(myjar);
        end
    end
    initJavaLogging();
end

%% initJavaLogging()
%
% Set log level for java classes to INFO
function initJavaLogging()
    logger = java.util.logging.Logger.getLogger('sun');
    logger.setLevel(java.util.logging.Level.INFO)
    logger = java.util.logging.Logger.getLogger('java');
    logger.setLevel(java.util.logging.Level.INFO);
    logger = java.util.logging.Logger.getLogger('javax');
    logger.setLevel(java.util.logging.Level.INFO);
    logger = java.util.logging.Logger.getLogger('com');
    logger.setLevel(java.util.logging.Level.INFO);
    logger = java.util.logging.Logger.getLogger('org');
    logger.setLevel(java.util.logging.Level.INFO);
    logger = java.util.logging.Logger.getLogger('');
    logger.setLevel(java.util.logging.Level.INFO);
end

%% ans = isInPath()
% 
% Used by initJava()
function ans = isInPath(javapath, myjar)
    ans = false;
    for i=1:length(javapath)
        if (strcmp(javapath{i}, myjar))
            ans = true;
            break;
        end
    end
end

%% ans = hasStringArg()
% 
% Used by CalculateFluxModes() for non-official options
function ans = hasStringArg(varargin, str)
    ans = false;
    for i=1:nargin-1
        if (ischar(varargin{i}) && strcmp(varargin{i}, str))
            ans = true;
        end
    end
end
