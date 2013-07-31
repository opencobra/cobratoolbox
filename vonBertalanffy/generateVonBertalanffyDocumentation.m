function generateVonBertalanffyDocumentation
% generateDoc uses m2html to create a set of html docs in the vonBertalanffy
% cobra toolbox extension and places them in vonBertalanffy/docs
%
% generateDoc(pathname, graph)
%
%OPTIONAL INPUTS
% graph     {0,(1)} generate function dependcy graph 
%
%generateDoc uses m2html, therefore m2html must be in the path.
%m2html will be located in the cba toolbox and added to the path 
%if not found on the path.
%
% Ronan M. T.Fleming

if (exist('m2html','file') ~= 2)
    disp('http://www.artefact.tk/software/matlab/m2html/')
    error('m2html not installed or in path')
end

tmp=which('generateVonBertalanffyDocumentation');
%Get Directory Name
parentDir=tmp(1:end-(length('generateVonBertalanffyDocumentation')+3));
cd(parentDir)

%M2HTML - Documentation System for Matlab M-files in HTML
%  M2HTML by itself generates an HTML documentation of Matlab M-files in the
%  current directory. HTML files are also written in the current directory.
%  M2HTML('PropertyName1',PropertyValue1,'PropertyName2',PropertyValue2,...)
%  sets multiple option values. The list of option names and default values is:
%    o mFiles - Cell array of strings or character array containing the
%       list of M-files and/or directories of M-files for which an HTML
%       documentation will be built [ '.' ]
%    o htmlDir - Top level directory for generated HTML files [ '.' ]
%    o recursive - Process subdirectories [ on | {off} ]
%    o source - Include Matlab source code in the HTML documentation
%                               [ {on} | off ]
%    o syntaxHighlighting - Syntax Highlighting [ {on} | off ]
%    o tabs - Replace '\t' (horizontal tab) in source code by n white space
%        characters [ 0 ... {4} ... n ]
%    o globalHypertextLinks - Hypertext links among separate Matlab 
%        directories [ on | {off} ]
%    o todo - Create a TODO file in each directory summarizing all the
%        '% TODO %' lines found in Matlab code [ on | {off}]
%    o graph - Compute a dependency graph using GraphViz [ on | {off}]
%        'dot' required, see <http://www.research.att.com/sw/tools/graphviz/>
%    o indexFile - Basename of the HTML index file [ 'index' ]
%    o extension - Extension of generated HTML files [ '.html' ]
%    o template - HTML template name to use [ 'blue' ]
%    o save - Save current state after M-files parsing in 'm2html.mat' 
%        in directory htmlDir [ on | {off}]
%    o load - Load a previously saved '.mat' M2HTML state to generate HTML 
%        files once again with possibly other options [ <none> ]
%    o verbose - Verbose mode [ {on} | off ]
%
%  Examples:
%    >> m2html('mfiles','matlab', 'htmldir','doc');
%    >> m2html('mfiles',{'matlab/signal' 'matlab/image'}, 'htmldir','doc');
%    >> m2html('mfiles','matlab', 'htmldir','doc', 'recursive','on');
%    >> m2html('mfiles','mytoolbox', 'htmldir','doc', 'source','off');
%    >> m2html('mfiles','matlab', 'htmldir','doc', 'global','on');
%    >> m2html( ... , 'template','frame', 'index','menu');

if isunix
    [status, result] = system('which dot');
    if ~isempty(result)
        graph='on';
    else
        graph='off';
    end
else
    graph='off';
end
    
m2html('mfiles','setupThermoModel','htmldir','doc','recursive','on', 'global','on','save','on','template','frame', 'index','menu', 'globalHypertextLinks', 'on','graph', graph);

if 0
% %full dependency graph
% m2html('mfiles','setupThermoModel','htmldir','doc2','recursive','on', 'global','on', 'save','on','template','frame', 'index','menu', 'globalHypertextLinks', 'on');
mdot([pwd '/doc/' 'm2html.mat'],'m2html.dot');
system('dot -Tpng m2html.dot -o m2html.png');
end