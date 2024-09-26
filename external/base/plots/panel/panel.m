
% Panel is an alternative to Matlab's "subplot" function.
% 
% INSTALLATION. To install panel, place the file "panel.m"
% on your Matlab path.
% 
% DOCUMENTATION. Scan the introductory information in the
% folder "docs". Learn to use panel by working through the
% demonstration scripts in the folder "demo" (list the demos
% by typing "help panel/demo"). Reference information is
% available through "doc panel" or "help panel". For the
% change log, use "edit panel" to view the file "panel.m".



% CHANGE LOG
% 
% ############################################################
% 22/05/2011
% First Public Release Version 2.0
% ############################################################
% 
% 23/05/2011
% Incorporated an LP solver, since the one we were using
% "linprog()" is not available to users who do not have the
% Optimisation Toolbox installed.
% 
% 21/06/2011
% Added -opdf option, and changed PageSize to be equal to
% PaperPosition.
%
% 12/07/2011
% Made some linprog optimisations, inspired by "Ian" on
% Matlab central. Tested against subplot using
% demopanel2(N=9). Subplot is faster, by about 20%, but
% panel is better :). For my money, 20% isn't much of a hit
% for the extra functionality. NB: Using Jeff Stuart's
% linprog (unoptimised), panel is much slower (especially
% for large N problems); we will probably have to offer a
% faster solver at some point (optimise Jeff's?).
%
% NOTES: You will see a noticeable delay, also, on resize.
% That's the price of using physical units for the layout,
% because we have to recalculate everything when the
% physical canvas size changes. I suppose in the future, we
% could offer an option so that physical units are only used
% during export; that would make resizes fast, and the user
% may not care so much about layout on screen, if they are
% aiming for print figures. Or, you could have the ability
% to turn off auto-refresh on resize().
%
% ############################################################
% 20/07/2011
% Release Version 2.1
% ############################################################
%
% 05/10/2011
% Tidied in-file documentation (panel.m).
%
% 11/12/2011
% Added flag "no-manage-font" to constructor, as requested
% by Matlab Central user Mukhtar Ullah.
%
% ############################################################
% 13/12/2011
% Release Version 2.2
% ############################################################
%
% 21/01/2012
% Fixed bug in explicit height export option "-hX" which
% wasn't working right at all.
%
% 25/01/12
% Fixed bug in tick label display during print. _Think_ I've
% got it right, this time! Some notes below, search for
% "25/01/12".
%
% 25/01/12
% Fixed DPI bug in smoothed export figures. Bug was flagged
% up by Jesper at Matlab Central.
%
% ############################################################
% 26/01/2012
% Release Version 2.3
% ############################################################
%
% 09/03/12
% Fixed bug whereby re-positioning never got done if only
% one panel was created in an existing figure window.
%
% ############################################################
% 13/03/2012
% Release Version 2.4
% ############################################################
%
% 15/03/12
% NB: On 2008b, and possibly later versions, the fact that
% the resizeCallback() and closeCallback() are private makes
% things not work. You can fix this by removing the "Access
% = Private" modifier on that section of "methods". It works
% fine in later versions, they must have changed the access
% rules I guess.
%
% 19/07/12
% Modified so that more than one object can be managed by
% one axis. Just use p.select([h1 h2 ...]). Added function
% "getAllManagedAxes()" which returns only objects from the
% "object list" (h_object), as it now is, which represent
% axes. Suggested by Brendan Sullivan @ Matlab Central.
%
% 19/07/12
% Added support for zlabel() call (not applicable to parent
% panels, since they are implicitly 2D for axis labelling).
%
% 19/07/12
% Fixed another export bug - how did this one not get
% noticed? XLimMode (etc.) was not getting locked during
% export, so that axes without manual limits might get
% re-dimensioned during export, which is bad news. Added
% locking of limits as well as ticks, in storeAxisState().
% Hope this has no side effects!
%
% ############################################################
% 19/07/12
% Release Version 2.5
%
% NB: Owing to the introduction of management of multiple
% objects by each panel, this release should be considered
% possibly flaky. Revert to 2.4 if you have problems with
% 2.5.
% ############################################################
%
% 23/07/12
% Improved documentation for figure export in demopanelA.
%
% 24/07/12
% Added support for export to SVG, using "plot2svg" (Matlab
% Central File Exchange) as the renderer. Along the way,
% tidied the behaviour of export() a little, and improved
% reporting to the user. Changed default DPI for EPS to 600,
% since otherwise the output files are pretty shoddy, and
% the filesize is relatively unaffected.
%
% 24/07/12
% Updated documentation, particularly HTML pages and
% associated figures. Bit nicer, now.
%
% ############################################################
% 24/07/12
% Release Version 2.6
% ############################################################
%
% 22/09/12
% Added demopanelH, which illustrates how to do insets. Kudos
% to Ann Hickox for the idea.
%
% 20/03/13
% Added panel.plot() to work around poor rendering of dashed
% lines, etc. Added demopanelI to illustrate its use.
%
% 20/03/13
% Renamed setCallback to addCallback, so we can have more
% than one. Added "userdata" argument to addCallback(), and
% "event" field (and "userdata" field) to "data" passed when
% callback is fired.
%
% ############################################################
% 21/03/13
% Release Version 2.7
% ############################################################
%
% 21/03/13
% Fixed bug in panel.plot() which did not handle solid lines
% correctly.
%
% 12/04/13
% Added back setCallback() with appropriate semantics, for
% the use of legacy code (or, really, future code, these
% semantics might be useful to someone). Also added the
% function clearCallbacks().
%
% 12/04/13
% Removed panel.plot() because it just seemed to be too hard
% to manage. Instead, we'll let the user plot things in the
% usual way, but during export (when things are well under
% our control), we'll fix up any dashed lines that the user
% has requested using the call fixdash(). Thus, we apply the
% fix only where it's needed, when printing to an image
% file, and save all the faffing with resize callbacks.
%
% ############################################################
% 12/04/13
% Release Version 2.8
% ############################################################
%
% 13/04/13
% Changed panel.export() to infer image format from file
% extension, in the case that it is not explicitly specified
% and the passed filename has an extension.
%
% 03/05/13
% Changed term "render", where misused, to "layout", so as
% not to confuse users of the help/docs. Changed name of
% callback event from "render-complete" to "layout-updated",
% is the only functional effect.
%
% 03/05/13
% Added argument to panel constructor so that units can be
% set there, rather than through a separate call to the
% "units" property.
%
% 03/05/13
% Added set descriptor "family" to go with "children" and
% "descendants". This one should be of particular use for
% the construct p.fa.margin = 0.
%
% 03/05/13
% Updated demopanel9 to be a walkthrough of how to set
% margins. Will be useful to point users at this if they ask
% "how do I do margins?".
%
% 03/05/13
% Added panel.version().
%
% 03/05/13
% Added page size "LNCS" to export.
%
% ############################################################
% 03/05/13
% Release Version 2.9
% ############################################################
%
% 10/05/13
% Removed linprog solution in favour of recursive
% computation. This should speed things up for people who
% don't have the optimisation toolbox.
%
% 10/05/13
% Added support for panels of fixed physical size. See new
% documentation for panel/pack().
%
% 10/05/13
% Added support for packing into panels packed in absolute
% mode, which wasn't previously possible.
%
% 10/05/13
% Removed advertisement for 'defer' flag, since I suspect
% it's no longer needed now we've moved away from LP. There
% may be some optimisation required before this is true -
% defer still functions as before, it's just not advertised.
%
% ############################################################
% 10/05/13
% Release Version 2.10
% ############################################################
%
% 14/05/13
% Some minor optimisations, so now panel is not slower than
% subplot (see demopanelK).
%
% 14/01/15
% Various fixes to work correctly under R2014b. Essentially,
% checked the demos, added retirement notes to fixdash(), and
% added function "fignum()".
%
% ############################################################
% 14/01/15
% Release Version 2.11
% ############################################################
%
% 28/03/15
% Changed export() logic slightly so that if either -h or -w option is
% specified, direct sizing model is selected (and, therefore, /all/
% options from the paper sizing model are ignored). Thus, either -w or
% -h can be specified, with -a, and intuitively-correct behaviour
% results.
%
% 02/04/15
% Changed functions x/y/zlabel and title to return a handle to the
% referenced object so that caller can access its properties.
%
% ############################################################
% 02/04/15
% Release Version 2.12
% ############################################################
%
% 30/07/19
% Fixed bug in dereferencing 'children' field, not sure when
% this was introduced but behaviour is now correct.
%
% ############################################################
% 30/07/19
% Release Version 2.13
% ############################################################
%
% 02/08/19
% Fixed display bug.
%
% 02/08/19
% Added find() method.
%
% 02/08/19
% Removed rejection of re-select()-ing managed objects of a
% panel, because it seems an unnecessary restriction.
%
% 21/11/19
% Changed uistack position of axes that are present only to
% position labels to 'bottom', allowing mouse interactions
% with the underlying axes (thanks to File Exchange user
% 'zwbxyzeng' for the heads-up).
%
% ############################################################
% 21/11/19
% Release Version 2.14
% ############################################################

classdef (Sealed = true) panel < handle
	

	
	%% ---- PROPERTIES ----
	
	properties (Constant = true, Hidden = true)
		
		PANEL_TYPE_UNCOMMITTED = 0;
		PANEL_TYPE_PARENT = 1;
		PANEL_TYPE_OBJECT = 2;
		
	end
	
	properties (Constant = true)
		
		LAYOUT_MODE_NORMAL = 0;
		LAYOUT_MODE_PREPRINT = 1;
		LAYOUT_MODE_POSTPRINT = 2;
		
	end
	
	properties
		
		% these properties are only here for documentation. they
		% are actually stored in "prop". it's just some subsref
		% madness.
		
		% font name to use for axis text (inherited)
		%
		% access: read/write
		% default: normal
		fontname
		
		% font size to use for axis text (inherited)
		%
		% access: read/write
		% default: normal
		fontsize
		
		% font weight to use for axis text (inherited)
		%
		% access: read/write
		% default: normal
		fontweight
		
		% the units that are used when reading/writing margins
		%
		% units can be set to any of 'mm', 'cm', 'in' or 'pt'.
		% it only affects the read/write interface; values
		% stored already are not re-interpreted.
		%
		% access: read/write
		% default: mm
		units
		
		% the panel's margin vector in the form [left bottom right top]
		%
		% the margin is key to the layout process. the layout
		% algorithm makes all panels as large as possible whilst
		% not violating margin constraints. margins are
		% respected between panels within their parent and
		% between the root panel and the edges of the canvas
		% (figure or image file).
		%
		% access: read/write
		% default: [12 10 2 2] (mm)
		%
		% see also: marginleft, marginbottom, marginright, margintop
		margin
		
		% one element of the margin vector
		%
		% access: read/write
		% default: see margin
		%
		% see also: margin
		marginleft
		
		% one element of the margin vector
		%
		% access: read/write
		% default: see margin
		%
		% see also: margin
		marginbottom
		
		% one element of the margin vector
		%
		% access: read/write
		% default: see margin
		%
		% see also: margin
		marginright
		
		% one element of the margin vector
		%
		% access: read/write
		% default: see margin
		%
		% see also: margin
		margintop
		
		% return position of panel
		%
		% return the panel's position in normalized
		% coordinates (normalized to the figure window that
		% is associated with the panel). note that parent
		% panels have positions too, even though nothing is
		% usually rendered. uncommitted panels, too.
		%
		% access: read only
		position
		
		% return handle of associated figure
		%
		% access: read only
		figure
		
		% return handle of associated axis
		%
		% if the panel is not an axis panel, empty is returned.
		% object includes axis, but axis does not include
		% object.
		%
		% access: read only
		%
		% see also: object
		axis
		
		% return handle of associated object
		%
		% if the panel is not an object panel, empty is
		% returned. object includes axis, but axis does not
		% include object.
		%
		% access: read only
		%
		% see also: axis
		object
		
		% access properties of panel's children
		%
		% if the panel is a parent panel, "children" gives
		% access to some properties of its children (direct
		% descendants). "children" can be abbreviated "ch".
		% properties that can be accessed are as follows.
		%
		% axis: read-only, returns an array
		% object: read-only, returns an array
		%
		% margin: write-only
		% fontname: write-only
		% fontsize: write-only
		% fontweight: write-only
		%
		% EXAMPLE:
		%   h = p.ch.axis;
		%   p.ch.margin = 3;
		%
		% see also: descendants, family
		children
		
		% access properties of panel's descendants
		%
		% if the panel is a parent panel, "descendants" gives
		% access to some properties of its descendants
		% (children, grandchildren, etc.). "descendants" can be
		% abbreviated "de". properties that can be accessed are
		% as follows.
		%
		% axis: read-only, returns an array
		% object: read-only, returns an array
		%
		% margin: write-only
		% fontname: write-only
		% fontsize: write-only
		% fontweight: write-only
		%
		% EXAMPLE:
		%   h = p.de.axis;
		%   p.de.margin = 3;
		%
		% see also: children, family
		descendants
		
		% access properties of panel's family
		%
		% if the panel is a parent panel, "family" gives access
		% to some properties of its family (self, children,
		% grandchildren, etc.). "family" can be abbreviated
		% "fa". properties that can be accessed are as follows.
		%
		% axis: read-only, returns an array
		% object: read-only, returns an array
		%
		% margin: write-only
		% fontname: write-only
		% fontsize: write-only
		% fontweight: write-only
		%
		% EXAMPLE:
		%   h = p.fa.axis;
		%   p.fa.margin = 3;
		%
		% see also: children, descendants
		family
		
	end
	
	properties (Access = private)
		
		% associated figure window
		h_figure
		
		% parent graphics object
		h_parent
		
		% this is empty for the root PANEL, populated for all others
		parent
		
		% this is always the root panel associated with this
		m_root
		
		% packing specifier
		%
		% empty:              relative positioning mode (stretch)
		% scalar fraction:    relative positioning mode
		% scalar percentage:  relative positioning mode
		% 1x4 dimension:      absolute positioning mode
		packspec
		
		% packing dimension of children
		%
		% 1 : horizontal
		% 2 : vertical
		packdim
		
		% panel type
		m_panelType
		
		% fixdash lines
		m_fixdash
		m_fixdash_restore
		
		% associated managed graphics object (usually, an axis)
		h_object
		
		% show axis (only the root has this extra axis, if show() is active)
		h_showAxis
		
		% children (only a parent panel has non-empty, here)
		m_children
		
		% callback (any functions listed in this cell array are called when events occur)
		m_callback
		
		% local properties (actual properties is this overlaid on inherited/default properties)
		%
		% see getPropertyValue()
		prop
		
		% state
		%
		% private state information used during various processing
		state
		
		% layout context for this panel
		%
		% this is the layout context for the panel. this is
		% computed in the function recomputeLayout(), and used
		% to reposition the panel in applyLayout(). storage of
		% this data means that we can call applyLayout() to
		% layout only a branch of the panel tree without having
		% to recompute the whole thing. however, I don't know
		% how efficient this system is, might need some work.
		m_context
		
	end
	
	
	
	
	
	
	
	%% ---- PUBLIC CTOR/DTOR ----
	
	methods
		
		function p = panel(varargin)
			
			% create a new panel
			%
			% p = panel(...)
			%   create a new root panel. optional arguments listed
			%   below can be supplied in any order. if "h_parent"
			%   is not supplied, it is set to gcf - that is, the
			%   panel fills the current figure.
			%
			%   initially, the root panel is an "uncommitted
			%   panel". calling pack() or select() on it will
			%   commit it as a "parent panel" or an "object
			%   panel", respectively. the following arguments may
			%   be passed, in any order.
			%
			% h_parent
			%   a handle to a graphics object that will act as the
			%   parent of the new panel. this is usually a figure
			%   handle, but may be a handle to any graphics
			%   object, in principle. currently, an error is
			%   raised unless it's a figure or a uipanel - if you
			%   want to try other object types, edit the code
			%   where the error is raised, and let me know if you
			%   have positive results so I can update panel to
			%   allow other object types.
			%
			% 'add'
			%   usually, when you attach a new root panel to a
			%   figure, any existing attached root panels are
			%   first deleted to make way for it. if you pass this
			%   argument, this is not done, so that you can attach
			%   more than one root panel to the same figure. see
			%   demopanelE for an example of this use.
			%
			% 'no-manage-font'
			%   by default, a panel will manage fonts of titles
			%   and axis labels. this prevents the user from
			%   setting individual fonts on those items. pass this
			%   flag to disable font management for this panel.
			%
			% 'mm', 'cm', 'in', 'pt'
			%   by default, panel uses mm as the unit of
			%   communication with the user over margin sizes.
			%   pass any of these to change this (you can achieve
			%   the same effect after creating a panel by setting
			%   the property "units").
			%
			% see also: panel (overview), pack(), select()

			% PRIVATE DOCUMENTATION
			%
			% 'defer'
			%   THIS IS NO LONGER ADVERTISED since we replaced the
			%   LP solution with a procedural solution, but still
			%   functions as before, to provide legacy support.
			%   the panel will be created with layout disabled.
			%   the layout computations take a little while when
			%   large numbers of panels are involved, and are
			%   re-run every time you add a panel or change a
			%   margin, by default. this is tedious if you are
			%   preparing a complex layout; pass 'defer', and
			%   layout will not be computed at all until you call
			%   refresh() or export() on the root panel.
			%
			% 'pack'
			%   this constructor is called internally from pack()
			%   to create new panels when packing them into
			%   parents. the first argument is passed as 'pack' in
			%   this case, which allows us to do slightly quicker
			%   parsing of the arguments, since we know the
			%   calling convention (see immediately below).

			% default state
			p.state = [];
			p.state.name = '';
			p.state.defer = 0;
			p.state.manage_font = 1;
			p.m_callback = {};
			p.m_fixdash = {};
			p.packspec = [];
			p.packdim = 2;
			p.m_panelType = p.PANEL_TYPE_UNCOMMITTED;
			p.prop = panel.getPropertyInitialState();
			
			% handle call from pack() aqap
			if nargin && isequal(varargin{1}, 'pack')
				
				% since we know the calling convention, in this
				% case, we can handle this as quickly as possible,
				% so that large recursive layouts do not get held up
				% by spurious code, here.
				
				% parent is a panel
				passed_h_parent = varargin{2};
				
				% become its child
				indexInParent = int2str(length(passed_h_parent.m_children)+1);
				if passed_h_parent.isRoot()
					p.state.name = ['(' indexInParent ')'];
				else
					p.state.name = [passed_h_parent.state.name(1:end-1) ',' indexInParent ')'];
				end
				p.h_parent = passed_h_parent.h_parent;
				p.h_figure = passed_h_parent.h_figure;
				p.parent = passed_h_parent;
				p.m_root = passed_h_parent.m_root;
				
				% done!
				return
				
			end
				
			% default condition
			passed_h_parent = [];
			add = false;

			% peel off args
			while ~isempty(varargin)

				% get arg
				arg = varargin{1};
				varargin = varargin(2:end);

				% handle text
				if ischar(arg)

					switch arg

						case 'add'
							add = true;
							continue;

						case 'defer'
							p.state.defer = 1;
							continue;

						case 'no-manage-font'
							p.state.manage_font = 0;
							continue;

						case {'mm' 'cm' 'in' 'pt'}
							p.setPropertyValue('units', arg);
							continue;

						otherwise
							error('panel:InvalidArgument', ['unrecognised text argument "' arg '"']);

					end

				end

				% handle parent
				if isscalar(arg) && ishandle(arg)
					passed_h_parent = arg;
					continue;
				end

				% error
				error('panel:InvalidArgument', 'unrecognised argument to panel constructor');

			end

			% attach to current figure if no parent supplied
			if isempty(passed_h_parent)
				passed_h_parent = gcf;

				% this might cause a figure to be created - if so,
				% give it time to display now so we don't get a (or
				% two, in fact!) resize event(s) later
				drawnow
			end

			% we are a root panel
			p.state.name = 'root';
			p.parent = [];
			p.m_root = p;

			% get parent type
			parentType = get(passed_h_parent, 'type');

			% set handles
			switch parentType

				case 'uipanel'
					p.h_parent = passed_h_parent;
					p.h_figure = getParentFigure(passed_h_parent);

				case 'figure'
					p.h_parent = passed_h_parent;
					p.h_figure = passed_h_parent;

				otherwise
					error('panel:InvalidArgument', ...
						['panel() cannot be attached to an object of type "' parentType '"']);

			end

			% lay in callbacks
			addHandleCallback(p.h_figure, 'CloseRequestFcn', @panel.closeCallback);
			addHandleCallback(p.h_parent, 'ResizeFcn', @panel.resizeCallback);

			% register for callbacks
			if add
				panel.callbackDispatcher('registerNoClear', p);
			else
				panel.callbackDispatcher('register', p);
			end

			% lock class in memory (prevent persistent from being cleared by clear all)
			panel.lockClass();
			
		end
		
		function delete(p)
			
			% destroy a panel
			%
			% delete(p)
			%   destroy the passed panel, deleting all associated
			%   graphics objects.
			%
			% NB: you won't usually have to call this explicitly.
			% it is called automatically for all attached panels
			% when you close the associated figure.
			
			% debug output
% 			panel.debugmsg(['deleting "' p.state.name '"...']);
			
			% delete managed graphics objects
			for n = 1:length(p.h_object)
				h = p.h_object(n);
				if ishandle(h)
					delete(h);
				end
			end
			
			% delete associated show axis
			if ~isempty(p.h_showAxis) && ishandle(p.h_showAxis)
				delete(p.h_showAxis);
			end
			
			% delete all children (child will remove itself from
			% "m_children" on delete())
			while ~isempty(p.m_children)
				delete(p.m_children(end));
			end
			
			% unregister...
			if p.isRoot()
				
				% ...for callbacks
				panel.callbackDispatcher('unregister', p);
				
			else
				
				% ...from parent
				p.parent.removeChild(p);
				
			end
			
			% debug output
% 			panel.debugmsg(['deleted "' p.state.name '"!']);
			
		end
		
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	%% ---- PUBLIC DISPLAY ----

	methods (Hidden = true)
		
		function disp(p)
			
			display(p);
			
        end
        
		function display(p, label)
			
			if nargin == 2
				disp([10 label ' =' 10])
			end
		
			display_sub(p);
			
			disp(' ')
			
		end
			
		function display_sub(p, indent)

			% default
			if nargin < 2
				indent = '';
			end
			
			% handle non-scalar (should not exist!)
			nels = numel(p);
			if nels > 1
				sz = size(p);
				sz = sprintf('%dx', sz);
				disp([sz(1:end-1) ' array of panel objects']);
				return
			end
			
			% header
			header = indent;
			if p.isObject()
				header = [header 'Object ' p.state.name ': '];
			elseif p.isParent()
				header = [header 'Parent ' p.state.name ': '];
			else
				header = [header 'Uncommitted ' p.state.name ': '];
			end
			if p.isRoot()
				pp = ['attached to Figure ' panel.fignum(p.h_figure)];
			else
				if isempty(p.packspec)
					pp = 'stretch';
				elseif iscell(p.packspec)
					units = p.getPropertyValue('units');
					val = panel.resolveUnits({p.packspec{1} 'mm'}, units);
					pp = sprintf('%.1f%s', val, units);
				elseif isscalar(p.packspec)
					if p.packspec > 1
						pp = sprintf('%.0f%%', p.packspec);
					else
						pp = sprintf('%.3f', p.packspec);
					end
				else
					pp = sprintf('%.3f ', p.packspec);
					pp = pp(1:end-1);
				end
			end
			header = [header '[' pp];
			if p.isParent()
				edges = {'hori' 'vert'};
				header = [header ', ' edges{p.packdim}];
			end
			header = [header ']'];

			% margin
			header = rpad(header, 60);
			header = [header '[ margin ' sprintf('%.3g ', p.getPropertyValue('margin')) p.getPropertyValue('units') ']'];
			
% 			% index
% 			if isfield(p.state, 'index')
% 				header = [header ' (' int2str(p.state.index) ')'];
% 			end

			% display
			disp(header);
			
			% children
			for c = 1:length(p.m_children)
				p.m_children(c).display_sub([indent '  ']);
			end
						
		end
			
	end
	
	
	
	
	
	
	
	
	
	
	%% ---- PUBLIC METHODS ----

	methods
		
		function h = xlabel(p, text)
			
			% apply an xlabel to the panel (or group)
			%
			% p.xlabel(...)
			%   behaves just like xlabel() at the prompt (you can
			%   use that as an alternative) when called on an axis
			%   panel. when called on a parent panel, however, the
			%   group of objects within that parent have a label
			%   applied. when called on a non-axis object panel,
			%   an error is raised.
			
			h = get(p.getOrCreateAxis(), 'xlabel');
			set(h, 'string', text);
			if p.isParent()
				set(h, 'visible', 'on');
			end
			
		end
		
		function h = ylabel(p, text)
			
			% apply a ylabel to the panel (or group)
			%
			% p.ylabel(...)
			%   behaves just like ylabel() at the prompt (you can
			%   use that as an alternative) when called on an axis
			%   panel. when called on a parent panel, however, the
			%   group of objects within that parent have a label
			%   applied. when called on a non-axis object panel,
			%   an error is raised.
			
			h = get(p.getOrCreateAxis(), 'ylabel');
			set(h, 'string', text);
			if p.isParent()
				set(h, 'visible', 'on');
			end
			
		end
		
		function h = zlabel(p, text)
			
			% apply a zlabel to the panel (or group)
			%
			% p.zlabel(...)
			%   behaves just like zlabel() at the prompt (you can
			%   use that as an alternative) when called on an axis
			%   panel. when called on a parent panel, however,
			%   this method raises an error, since parent panels
			%   are assumed to be 2D, with respect to axes.
			
			if p.isParent()
				error('panel:ZLabelOnParentAxis', 'can only call zlabel() on an object panel');
			end
			
			h = get(p.getOrCreateAxis(), 'zlabel');
			set(h, 'string', text);
			
		end
		
		function h = title(p, text)
			
			% apply a title to the panel (or group)
			%
			% p.title(...)
			%   behaves just like title() at the prompt (you can
			%   use that as an alternative) when called on an axis
			%   panel. when called on a parent panel, however, the
			%   group of objects within that parent have a title
			%   applied. when called on a non-axis object panel,
			%   an error is raised.
			
			h = title(p.getOrCreateAxis(), text);
			if p.isParent()
				set(h, 'visible', 'on');
			end
			
		end
		
		function hold(p, state)
			
			% set the hold on/off state of the associated axis
			% 
			% p.hold('on' / 'off')
			%   you can use matlab's "hold" function with plots in
			%   panel, just like any other plot. there is,
			%   however, a very minor gotcha that is somewhat
			%   unlikely to ever come up, but for completeness
			%   this is the problem and the solutions:
			%
			% if you create a panel "p", change its font using
			% panel, e.g. "p.fontname = 'Courier New'", then call
			% "hold on", then "hold off", then plot into it, the
			% font is not respected. this situation is unlikely to
			% arise because there's usually no reason to call
			% "hold off" on a plot. however, there are three
			% solutions to get round it, if it does:
			%
			%   a) call p.refresh() when you're finished, to
			%   update all fonts to managed values.
			%
			%   b) if you're going to call p.export() anyway,
			%   fonts will get updated when you do.
			%
			%   c) if for some reason you can't do (a) OR (b) (I
			%   can't think why), you can use the hold() function
			%   provided by panel instead of that provided by
			%   Matlab. this will not affect your fonts. for
			%   example, call "p(2).hold('on')".
			
			% because the matlab "hold off" command sets an axis's
			% nextplot state to "replace", we lose control over
			% the axis properties (such as fontname). we set
			% nextplot to "replacechildren" when we create an
			% axis, but if the user does a "hold on, hold off"
			% cycle, we lose that. therefore, we offer this
			% alternative.
			
			% check
			if ~p.isObject()
				error('panel:HoldWhenNotObjectPanel', 'can only call hold() on an object panel');
			end
			
			% check
			h_axes = p.getAllManagedAxes();
			if isempty(h_axes)
				error('panel:HoldWhenNoAxes', 'can only call hold() on a panel that manages one or more axes');
			end
			
			% switch
			switch state
				case {'on' true 1}
					set(h_axes, 'nextplot', 'add');
				case {'off' false 0}
					set(h_axes, 'nextplot', 'replacechildren');
				otherwise
					error('panel:InvalidArgument', 'argument to hold() must be ''on'', ''off'', or boolean');
			end
			
		end
		
		function fixdash(p, hs, linestyle)
			
			% pass dashed lines to be fixed up during export
            %
            % NB: Matlab's difficulty with dotted/dashed lines on export
            % seems to be fixed in R2014b, so if using this version or a
            % later one, this functionality of panel will be of no
            % interest. Text below was from pre R2014b.
			%
			% p.fixdash(h, linestyle)
			%   add the lines specified as handles in "h" to the
			%   list of lines to be "fixed up" during export.
			%   panel will attempt to get the lines to look right
			%   during export to all formats where they would
			%   usually get mussed up. see demopanelI for an
			%   example of how it works.
			%
			%   the above is the usual usage of fixdash(), but
			%   you can get more control over linestyle by
			%   specifying the additional argument, "linestyle".
			%   if "linestyle" is supplied, it is used as the
			%   linestyle; if not, the current linestyle of the
			%   line (-, --, -., :) is used. "linestyle" can
			%   either be a text string or a series of numbers, as
			%   described below.
			%
			%     '-' solid
			%     '--' dashed, equal to [2 0.75]
			%     '-.' dash-dot, equal to [2 0.75 0.5 0.75]
			%     ':', '.' dotted, equal to [0.5 0.5]
			%
			%   a number series should be 1xN, where N is a
			%   multiple of 2, as in the examples above, and
			%   specifies the lengths of any number of dash
			%   components that are used before being repeated.
			%   for instance, '-.' generates a 2 unit segment
			%   (dash), a 0.75 unit gap, then a 0.5 unit segment
			%   (dot) and a final 0.75 unit gap. at present, the
			%   units are always millimetres. this system is
			%   extensible, so that the following examples are
			%   also valid:
			%
			%     '--..' dash-dash-dot-dot
			%     '-..-.' dash-dot-dot-dash-dot
			%     [2 1 4 1 6 1] 2 dash, 4 dash, 6 dash

			% default
			if nargin < 3
				linestyle = [];
			end
			
			% bubble up to root
			if ~p.isRoot()
				p.m_root.fixdash(hs, linestyle);
				return
			end
			
			% for each passed handle
			for h = (hs(:)')
				
				% check it's still a handle
				if ~ishandle(h)
					continue
				end
				
				% check it's a line
				if ~isequal(get(h, 'type'), 'line')
					continue
				end
				
				% update if in list
				found = false;
				for i = 1:length(p.m_fixdash)
					if h == p.m_fixdash{i}.h
						p.m_fixdash{i}.linestyle = linestyle;
						found = true;
						break
					end
				end
				
				% else add to list
				if ~found
					p.m_fixdash{end+1} = struct('h', h, 'linestyle', linestyle);
				end
				
			end
			
		end
		
		function show(p)
			
			% highlight the outline of the panel
			%
			% p.show()
			%   make the outline of the panel "p" show up in red
			%   in the figure window. this is useful for
			%   understanding a complex layout.
			%
			% see also: identify()

			r = p.getObjectPosition();
			
			if ~isempty(r)
				h = p.getShowAxis();
				delete(get(h, 'children'));
				xdata = [r(1) r(1)+r(3) r(1)+r(3) r(1) r(1)];
				ydata = [r(2) r(2) r(2)+r(4) r(2)+r(4) r(2)];
				plot(h, xdata, ydata, 'r-', 'linewidth', 5);
				axis([0 1 0 1])
			end
			
		end
		
		function export(p, varargin)
			
			% to export the root panel to an image file
			%
			% p.export(filename, ...)
			%
			% export the figure containing panel "p" to an image file.
			% you must supply the filename of this output file, with or
			% without a file extension. any further arguments must be
			% option strings starting with the dash ("-") character. "p"
			% should be the root panel.
			%
			% if the filename does not include an extension, the
			% appropriate extension will be added. if it does, the
			% output format will be inferred from it, unless overridden
			% by the "-o" option, described below.
			%
			% if you are targeting a print publication, you may find it
			% easiest to size your output using the "paper sizing model"
			% (below). if you prefer, you can use the "direct sizing
			% model", instead. these two sizing models are described
			% below. underneath these are listed the options unrelated
			% to sizing (which apply regardless of which sizing model
			% you use).
			%
			%
			%
			% PAPER SIZING MODEL:
			%
			% using the paper sizing model, you specify your target as a
			% region of a piece of paper, and the actual size in
			% millimeters is calculated for you. this is usually very
			% convenient, but if you find it unsuitable, the direct
			% sizing model (next section) is provided as an alternative.
			%
			% to specify the region, you specify the type (size) of
			% paper, the orientation, the number of columns, and the
			% aspect ratio of the figure (or the fraction of a column to
			% fill). usually, the remaining options can be left as
			% defaults.
			%
			% -pX
			%   X is the paper type, A2-A6 or letter (default is A4).
			%   NB: you can also specify paper type LNCS (Lecture Notes
			%   in Computer Science), using "-pLNCS". If you do this,
			%   the margins are also adjusted to match LNCS format.
			%
			% -l
			%   specify landscape mode (default is portrait).
			%
			% -mX
			%   X is the paper margins in mm. you can provide a scalar
			%   (same margins all round) or a comma-separated list of
			%   four values, specifying the left, bottom, right, top
			%   margins separately (default is 20mm all round).
			%
			% -iX
			%   X is the inter-column space in mm (default is
			%   5mm).
			%
			% -cX
			%   X is the number of columns (default is 1).
			%
			% NB: the following two options represent two ways to
			% specify the height of the figure relative to the space
			% defined by the above options. if you supply both,
			% whichever comes second will be used.
			%
			% -aX
			%   X is the aspect ratio of the resulting image file (width
			%   is set by the paper model). X can be one of the strings:
			%   s (square), g (landscape golden ratio), gp (portrait
			%   golden ratio), h (half-height), d (double-height); or, a
			%   number greater than zero, to specify the aspect ratio
			%   explicitly. note that, if using the numeric form, the
			%   ratio is expressed as the quotient of width over height,
			%   in the usual way. ratios greater than 10 or less than
			%   0.1 are disallowed, since these can cause a very large
			%   figure file to be created accidentally. default is to
			%   use the landscape golden ratio.
			%
			% -fX
			%   X is the fraction of the column (or page, if there are
			%   not columns) to fill. X can be one of the following
			%   strings - a (all), tt (two thirds), h (half), t (third),
			%   q (quarter) - or a fraction between 0 and 1, to specify
			%   the fraction of the space to fill as a number. default
			%   is to use aspect ratio, not fill fraction.
			%
			%
			%
			% DIRECT SIZING MODEL:
			%
			% if one of these two options is set, the output image is
			% sized according to that option and the aspect ratio (see
			% above) and the paper model is not used. if both are set,
			% the aspect ratio is not used either.
			%
			% -wX
			%   X is the explicit width in mm.
			%
			% -hX
			%   X is the explicit height in mm.
			%
			%
			%
			% NON-SIZING OPTIONS:
			%
			% finally, a few options are provided to control how
			% the prepared figure is exported. note that DPI below
			% 150 is only recommended for sizing drafts, since
			% font and line sizes are not rendered even vaguely
			% accurately in some cases. at the other end, DPI
			% above 600 is unlikely to be useful except when
			% submitting camera-ready copy.
			%
			% -rX
			%   X is the resolution (DPI) at which to produce the
			%   output file. X can be one of the following strings
			%   - d (draft, 75DPI), n (normal, 150DPI), h (high,
			%   300DPI), p (publication quality, 600DPI), x
			%   (extremely high quality, 1200DPI) - or just
			%   the DPI as a number (must be in 75-2400). the
			%   default depends on the output format (see below).
			%
			% -rX/S
			%   X is the DPI, S is the smoothing factor, which can
			%   be 2 or 4. the output file is produced at S times
			%   the specified DPI, and then reduced in size to the
			%   specified DPI by averaging. thus, the hard edges
			%   produced by the renderer are smoothed - the effect
			%   is somewhat like "anti-aliasing".
			%
			% NB: the DPI setting might be expected to have no
			% effect on vector formats. this is true for SVG, but
			% not for EPS, where the DPI affects the numerical
			% precision used as well as the size of some image
			% elements, but has little effect on file size. for
			% this reason, the default DPI is 150 for bitmap
			% formats but 600 for vector formats.
			%
			% -s
			%   print sideways (default is to print upright)
			%
			% -oX
			%   X is the output format - choose from most of the
			%   built-in image device drivers supported by "print"
			%   (try "help print"). this includes "png", "jpg",
			%   "tif", "eps" and "pdf". note that "eps"/"ps"
			%   resolve to "epsc2"/"psc2", for convenience. to use
			%   the "eps"/"ps" devices, use "-oeps!"/"-ops!". you
			%   may also specify "svg", if you have the tool
			%   "plot2svg" on your path (available at Matlab
			%   Central File Exchange). the default output format
			%   is inferred from the file extension, or "png" if
			%   the passed filename has no extension.
			%
			%
			%
			% EXAMPLES:
			%
			% default export of 'myfig', creates 'myfig.png' at a
			% size of 170x105mm (1004x620px). this size comes
			% from: A4 (210mm wide), minus two 20mm margins
			% (170mm), and using the golden aspect ratio to give a
			% height of 105mm, and finally 150DPI to give the
			% pixel size.
			%
			% p.export('myfig')
			%
			% when producing the final camera-ready image for a
			% square figure that will sit in one of the two
			% columns of a letter-size paper journal with default
			% margins and inter-column space, we might use this:
			%
			% p.export('myfig', '-pletter', '-c2', '-as', '-rp');

			% LEGACY
			%
			% (this is legacy since the 'defer' flag is no longer
			% needed - though it is still supported)
			%
			% NB: if you pass 'defer' to the constructor, calling
			% export() both exports the panel and releases the
			% defer mode. future changes to properties (e.g.
			% margins) will cause immediate recomputation of the
			% layout.
			
			% check
			if ~p.isRoot()
				error('panel:ExportWhenNotRoot', 'cannot export() this panel - it is not the root panel');
			end
			
			% used below
			default_margin = 20;
			
			% parameters
			pars = [];
			pars.filename = '';
			pars.fmt = '';
			pars.ext = '';
			pars.dpi = [];
			pars.smooth = 1;
			pars.paper = 'A4';
			pars.landscape = false;
			pars.fill = -1.618;
			pars.cols = 1;
			pars.intercolumnspacing = 5;
			pars.margin = default_margin;
			pars.sideways = false;
			pars.width = 0;
			pars.height = 0;
			invalid = false;
			
			% interpret args
			for a = 1:length(varargin)
				
				% extract
				arg = varargin{a};
				
				% all arguments must be non-empty strings
				if ~isstring(arg)
					error('panel:InvalidArgument', ...
						'all arguments to export() must be non-empty strings');
				end
				
				% is filename?
				if arg(1) ~= '-'
					
					% error if already set
					if ~isempty(pars.filename)
						error('panel:InvalidArgument', ...
							['at argument "' arg '", the filename is already set ("' pars.filename '")']);
					end
					
					% ok, continue
					pars.filename = arg;
					continue
					
				end

				% split off option key and option value
				if length(arg) < 2
					error('panel:InvalidArgument', ...
						['at argument "' arg '", no option specified']);
				end
				key = arg(2);
				val = arg(3:end);
				
				% switch on option key
				switch key

					case 'p'
						pars.paper = validate_par(val, arg, {'A2' 'A3' 'A4' 'A5' 'A6' 'letter' 'LNCS'});

					case 'l'
						pars.landscape = true;
						validate_par(val, arg, 'empty');

					case 'm'
						pars.margin = validate_par(str2num(val), arg, 'dimension', 'nonneg');

					case 'i'
						pars.intercolumnspacing = validate_par(str2num(val), arg, 'scalar', 'nonneg');

					case 'c'
						pars.cols = validate_par(str2num(val), arg, 'scalar', 'integer');

					case 'f'
						switch val
							case 'a', pars.fill = 1;      % all
							case 'w', pars.fill = 1;      % whole (legacy, not documented)
							case 'tt', pars.fill = 2/3;   % two thirds
							case 'h', pars.fill = 1/2;    % half
							case 't', pars.fill = 1/3;    % third
							case 'q', pars.fill = 1/4;    % quarter
							otherwise
								pars.fill = validate_par(str2num(val), arg, 'scalar', [0 1]);
						end

					case 'a'
						switch val
							case 's', pars.fill = -1;         % square
							case 'g', pars.fill = -1.618;     % golden ratio (landscape)
							case 'gp', pars.fill = -1/1.618;  % golden ratio (portrait)
							case 'h', pars.fill = -2;         % half height
							case 'd', pars.fill = -0.5;       % double height
							otherwise
								pars.fill = -validate_par(str2num(val), arg, 'scalar', [0.1 10]);
						end

					case 'w'
						pars.width = validate_par(str2num(val), arg, 'scalar', 'nonneg', [10 Inf]);

					case 'h'
						pars.height = validate_par(str2num(val), arg, 'scalar', 'nonneg', [10 Inf]);

					case 'r'
						% peel off smoothing ("/...")
						if any(val == '/')
							f = find(val == '/', 1);
							switch val(f+1:end)
								case '2', pars.smooth = 2;
								case '4', pars.smooth = 4;
								otherwise, error('panel:InvalidArgument', ...
										['invalid argument "' arg '", part after / must be "2" or "4"']);
							end
							val = val(1:end-2);
						end

						switch val
							case 'd', pars.dpi = 75;      % draft
							case 'n', pars.dpi = 150;     % normal
							case 'h', pars.dpi = 300;     % high
							case 'p', pars.dpi = 600;     % publication quality
							case 'x', pars.dpi = 1200;    % extremely high quality
							otherwise
								pars.dpi = validate_par(str2num(val), arg, 'scalar', [75 2400]);
						end

					case 's'
						pars.sideways = true;
						validate_par(val, arg, 'empty');

					case 'o'
						fmts = {
							'png' 'png' 'png'
							'tif' 'tiff' 'tif'
							'tiff' 'tiff' 'tif'
							'jpg' 'jpeg' 'jpg'
							'jpeg' 'jpeg' 'jpg'
							'ps' 'psc2' 'ps'
							'ps!' 'psc' 'ps'
							'psc' 'psc' 'ps'
							'ps2' 'ps2' 'ps'
							'psc2' 'psc2' 'ps'
							'eps' 'epsc2' 'eps'
							'eps!' 'eps' 'eps'
							'epsc' 'epsc' 'eps'
							'eps2' 'eps2' 'eps'
							'epsc2' 'epsc2' 'eps'
							'pdf' 'pdf' 'pdf'
							'svg' 'svg' 'svg'
							};
						validate_par(val, arg, fmts(:, 1)');
						index = isin(fmts(:, 1), val);
						pars.fmt = fmts(index, 2:3);

					otherwise
						error('panel:InvalidArgument', ...
							['invalid argument "' arg '", option is not recognised']);

				end
				
			end
			
			% if not specified, infer format from filename
			if isempty(pars.fmt)
				[path, base, ext] = fileparts(pars.filename);
				if ~isempty(ext)
					ext = ext(2:end);
				end
				switch ext
					case {'tif' 'tiff'}
						pars.fmt = {'tiff' 'tif'};
					case {'jpg' 'jpeg'}
						pars.fmt = {'jpeg' 'jpg'};
					case 'eps'
						pars.fmt = {'epsc2' 'eps'};
					case {'png' 'pdf' 'svg'}
						pars.fmt = {ext ext};
					case ''
						pars.fmt = {'png' 'png'};
					otherwise
						warning('panel:CannotInferImageFormat', ...
							['unable to infer image format from file extension "' ext '" (PNG assumed)']);
						pars.fmt = {'png' 'png'};
				end
			end
			
			% extract
			pars.ext = pars.fmt{2};
			pars.fmt = pars.fmt{1};
			
			% extract
			is_bitmap = ismember(pars.fmt, {'png' 'jpeg' 'tiff'});
			
			% default DPI
			if isempty(pars.dpi)
				if is_bitmap
					pars.dpi = 150;
				else
					pars.dpi = 600;
				end
			end

			% validate
			if isequal(pars.fmt, 'svg') && isempty(which('plot2svg'))
				error('panel:Plot2SVGMissing', 'export to SVG requires plot2svg (Matlab Central File Exchange)');
			end
			
			% validate
			if ~is_bitmap && pars.smooth ~= 1
				pars.smooth = 1;
				warning('panel:NoSmoothVectorFormat', 'requested smoothing will not be performed (chosen export format is not a bitmap format)');
			end
			
			% validate
			if isempty(pars.filename)
				error('panel:InvalidArgument', 'filename not supplied');
			end
			
			% make sure filename has extension
			if ~any(pars.filename == '.')
				pars.filename = [pars.filename '.' pars.ext];
			end
			
			
			
%%%% GET TARGET DIMENSIONS (BEGIN)
			
			% get space for figure
			switch pars.paper
				case 'A0', sz = [841 1189];
				case 'A1', sz = [594 841];
				case 'A2', sz = [420 594];
				case 'A3', sz = [297 420];
				case 'A4', sz = [210 297];
				case 'A5', sz = [148 210];
				case 'A6', sz = [105 148];
				case 'letter', sz = [216 279];
				case 'LNCS', sz = [152 235];
					% if margin is still at default, set it to LNCS
					% margin size
					if isequal(pars.margin, default_margin)
						pars.margin = [15 22 15 20];
					end
				otherwise
					error(['unrecognised paper size "' pars.paper '"'])
			end
			
			% orientation of paper
			if pars.landscape
				sz = sz([2 1]);
			end
			
			% paper margins (scalar or quad)
			if isscalar(pars.margin)
				pars.margin = pars.margin * [1 1 1 1];
			end
			sz = sz - pars.margin(1:2) - pars.margin(3:4);
			
			% divide by columns
			w = (sz(1) + pars.intercolumnspacing) / pars.cols - pars.intercolumnspacing;
			sz(1) = w;
			
			% apply fill / aspect ratio
			if pars.fill > 0
				% fill fraction
				sz(2) = sz(2) * pars.fill;
			elseif pars.fill < 0
				% aspect ratio
				sz(2) = sz(1) * (-1 / pars.fill);
			end
			
			% direct sizing model is used if either of width or height
			% is set
			if pars.width || pars.height
				
				% use aspect ratio to fill in either one that is not
				% specified
 				if ~pars.width || ~pars.height
					
					% aspect ratio must not be a fill
					if pars.fill >= 0
						error('cannot use fill fraction with direct sizing model');
					end

					% compute width
					if ~pars.width
	 					pars.width = pars.height * -pars.fill;
					end
					
					% compute height
					if ~pars.height
	 					pars.height = pars.width / -pars.fill;
					end
					
				end
				
				% store
				sz = [pars.width pars.height];
				
			end
			
%%%% GET TARGET DIMENSIONS (END)

			
			
			% orientation of figure is upright, unless printing
			% sideways, in which case the printing space is rotated too
			if pars.sideways
				set(p.h_figure, 'PaperOrientation', 'landscape')
				sz = fliplr(sz);
			else
				set(p.h_figure, 'PaperOrientation', 'portrait')
			end
			
			% report export size
			msg = ['exporting to ' int2str(sz(1)) 'x' int2str(sz(2)) 'mm'];
			if is_bitmap
				psz = sz / 25.4 * pars.dpi;
				msg = [msg ' (' int2str(psz(1)) 'x' int2str(psz(2)) 'px @ ' int2str(pars.dpi) 'DPI)'];
			else
				msg = [msg ' (vector format @ ' int2str(pars.dpi) 'DPI)'];
			end
			disp(msg);
			
			% if we are in defer state, we need to do a clean
			% recompute first so that axes get positioned so that
			% axis ticks get set correctly (if they are in
			% automatic mode), since the LAYOUT_MODE_PREPRINT
			% recompute will store the tick states.
			if p.state.defer
				p.state.defer = 0;
				p.recomputeLayout([]);
			end

			% turn off defer, if it is on
			p.state.defer = 0;
			
			% do a pre-print layout
			context.mode = panel.LAYOUT_MODE_PREPRINT;
			context.size_in_mm = sz;
			context.rect = [0 0 1 1];
			p.recomputeLayout(context);
			
			% need also to disable the warning that we should set
			% PaperPositionMode to auto during this operation -
			% we're setting it explicitly.
			w = warning('off', 'MATLAB:Print:CustomResizeFcnInPrint');
			
			% handle smoothing
			pars.write_dpi = pars.dpi;
			if pars.smooth > 1
				pars.write_dpi = pars.write_dpi * pars.smooth;
				print_filename = [pars.filename '-temp'];
			else
				print_filename = pars.filename;
			end

			% disable layout so it doesn't get computed during any
			% figure resize operations that occur during printing.
			p.state.defer = 1;
			
			% set size of figure now. it's important we do this
			% after the pre-print layout, because in SVG export
			% mode the on-screen figure size is changed and that
			% would otherwise affect ticks and limits.
			switch pars.fmt
				
				case 'svg'
					% plot2svg (our current SVG export mechanism) uses
					% 'Units' and 'Position' (i.e. on-screen position)
					% rather than the Paper- prefixed ones used by the
					% Matlab export functions.
					
					% store old on-screen position
					svg_units = get(p.h_figure, 'Units');
					svg_pos = get(p.h_figure, 'Position');
					
					% update on-screen position
					set(p.h_figure, 'Units', 'centimeters');
					pos = get(p.h_figure, 'Position');
					pos(3:4) = sz / 10;
					set(p.h_figure, 'Position', pos);
					
				otherwise
					set(p.h_figure, ...
						'PaperUnits', 'centimeters', ...
						'PaperPosition', [0 0 sz] / 10, ...
						'PaperSize', sz / 10 ... % * 1.5 / 10 ... % CHANGED 21/06/2011 so that -opdf works correctly - why was this * 1.5, anyway? presumably was spurious...
						);
					
			end
			
			% do fixdash (not for SVG, since plot2svg does a nice
			% job of dashed lines without our meddling...)
			if ~isequal(pars.fmt, 'svg')
				p.do_fixdash(context);
			end
			
			% do the export
			switch pars.fmt
				case 'svg'
					plot2svg(print_filename, p.h_figure);
				otherwise
					print(p.h_figure, '-loose', ['-d' pars.fmt], ['-r' int2str(pars.write_dpi)], print_filename)
			end

			% undo fixdash
			if ~isequal(pars.fmt, 'svg')
				p.do_fixdash([]);
			end
			
			% set on-screen figure size back to what it was, if it
			% was changed.
			switch pars.fmt
				case 'svg'
					set(p.h_figure, 'Units', svg_units);
					set(p.h_figure, 'Position', svg_pos);
			end
			
			% enable layout again (it was disabled, above, during
			% printing).
			p.state.defer = 0;
			
			% enable warnings
			warning(w);
			
			% do a post-print layout
			context.mode = panel.LAYOUT_MODE_POSTPRINT;
			context.size_in_mm = [];
			context.rect = [0 0 1 1];
			p.recomputeLayout(context);
			
			% handle smoothing
			if pars.smooth > 1
				psz = sz * pars.smooth / 25.4 * pars.dpi;
				msg = [' (reducing from ' int2str(psz(1)) 'x' int2str(psz(2)) 'px)'];
				disp(['smoothing by factor ' int2str(pars.smooth) msg]);
				im1 = imread(print_filename);
				delete(print_filename);
				sz = size(im1);
				sz = [sz(1)-mod(sz(1),pars.smooth) sz(2)-mod(sz(2),pars.smooth)] / pars.smooth;
				im = zeros(sz(1), sz(2), 3);
				mm = 1:pars.smooth:(sz(1) * pars.smooth);
				nn = 1:pars.smooth:(sz(2) * pars.smooth);
				for m = 0:pars.smooth-1
					for n = 0:pars.smooth-1
						im = im + double(im1(mm+m, nn+n, :));
					end
				end
				im = uint8(im / (pars.smooth^2));
				
				% set the DPI correctly in the new file
				switch pars.fmt
					case 'png'
						dpm = pars.dpi / 25.4 * 1000; 
						imwrite(im, pars.filename, ... 
							'XResolution', dpm, ... 
							'YResolution', dpm, ... 
							'ResolutionUnit', 'meter');
					case 'tiff'
						imwrite(im, pars.filename, ... 
							'Resolution', pars.dpi * [1 1]);
					otherwise
						imwrite(im, pars.filename);
				end
			end
			
		end

		function clearCallbacks(p)
			
			% clear all callback functions for the panel
			%
			% p.clearCallbacks()
			p.m_callback = {};
			
		end
		
		function setCallback(p, func, userdata)
			
			% set the callback function for the panel
			%
			% p.setCallback(myCallbackFunction, userdata)
			%
			% NB: this function clears all current callbacks, then
			%   calls addCallback(myCallbackFunction, userdata).
			p.clearCallbacks();
			p.addCallback(func, userdata);
			
		end
		
		function addCallback(p, func, userdata)
			
			% attach a callback function to receive panel events
			%
			% p.addCallback(myCallbackFunction, userdata)
			%   register myCallbackFunction() to be called when
			%   events occur on the panel. at present, the only
			%   event is "layout-updated", which usually occurs
			%   after the figure is resized. myCallbackFunction()
			%   should accept one argument, "data", which will
			%   have the following fields.
			%
			% "userdata": the userdata passed to this function, if
			%     any was supplied, else empty.
			%
			% "panel": a reference to the panel on which the
			%     callback was set. this object can be queried in
			%     the usual way.
			%
			% "event": name of event (currently only
			%	    "layout-updated").
			%
			% "context": the layout context for the panel. this
			%	    includes a field "size_in_mm" which is the
			%	    physical size of the rendering surface (screen
			%	    real estate, or image file) and "rect" which is
			%	    the relative size of the rectangle within that
			%	    occupied by the panel which is the context of
			%	    the callback (in [left, bottom, width, height]
			%	    format).
			
			invalid = ~isscalar(func) || ~isa(func, 'function_handle');
			if invalid
				error('panel:InvalidArgument', 'argument to callback() must be a function handle');
			end
			if nargin == 2
				p.m_callback{end+1} = {func []};
			else
				p.m_callback{end+1} = {func userdata};
			end
			
		end
		
		function q = find(p, varargin)
			
			% find panel according to some search conditions
			%
			% p.find(...)
			%   you can use this to recover the panel
			%   associated with a particular graphics
			%   object, for example. conditions are
			%   specified as {type, data} pairs, as listed
			%   below.
			%
			% {'object', h}
			%   returned panels must be managing the object
			%   "h".
			%
			% example:
			%   q = p.find({'object', h_axis})
			
			% get all panels
			f = p.getPanels('*');
			
			% return value
			q = {};
			
			% search
			for i = 1:length(f)
				
				% get panel
				p = f{i};
				
				% check conditions
				for c = 1:length(varargin)
					
					% get condition
					cond = varargin{c};
					
					% switch on type
					switch cond{1}
						
						case 'object'
							h = cond{2};
							if ~any(h == p.h_object)
								p = [];
							end
							
						otherwise
							error(['unrecognised condition type "' cond{1} '"']);
						
					end
					
				end
				
				% if still there
				if ~isempty(p)
					q{end+1} = p;
				end
				
			end
			
		end
		
		function identify(p)

			% add annotations to help identify individual panels
			%
			% p.identify()
			%   when creating a complex layout, it can become
			%   confusing as to which panel is which. this
			%   function adds a text label to each axis panel
			%   indicating how to reference the axis panel through
			%   the root panel. for instance, if "(2, 3)" is
			%   indicated, you can find that panel at p(2, 3).
			%
			% see also: show()
			
			if p.isObject()
				
				% get managed axes
				h_axes = p.getAllManagedAxes();
			
				% if no axes, ignore
				if isempty(h_axes)
					return
				end
				
				% mark first axis
				h_axes = h_axes(1);
				cla(h_axes);
				text(0.5, 0.5, p.state.name, 'fontsize', 12, 'hori', 'center', 'parent', h_axes);
				axis(h_axes, [0 1 0 1]);
				grid(h_axes, 'off')

			else
				
				% recurse
				for c = 1:length(p.m_children)
					p.m_children(c).identify();
				end
				
			end
			
		end
		
		function repack(p, packspec)
			
			% change the packing specifier for an existing panel
			%
			% p.repack(packspec)
			%   repack() is a convenience function provided to
			%   allow easy development of a layout from the
			%   command prompt. packspec can be any packing
			%   specifier accepted by pack().
			%
			% see also: pack()
			
			% deny repack() on root
			if p.isRoot()
				
				% let's deny this. I'm not sure it makes anyway. you
				% could always pack into root with a panel with
				% absolute positioning, so let's deny first, and
				% allow later if we're sure it's a good idea.
				error('panel:InvalidArgument', 'root panel cannot be repack()ed');
				
			end
			
			% validate
			validate_packspec(packspec);
			
			% handle units
			if iscell(packspec)
				units = p.getPropertyValue('units');
				packspec{1} = panel.resolveUnits({packspec{1} units}, 'mm');
			end
			
			% update the packspec
			p.packspec = packspec;
			
			% and recomputeLayout
			p.recomputeLayout([]);
			
		end
		
		function pack(p, varargin)
			
			% add (pack) child panel(s) into an existing panel
			%
			% p.pack(...)
			%   add children to the panel "p", committing it as a
			%   "parent" panel (if it is not already). new (child)
			%   panels are created using this call - they start as
			%   "uncommitted" panels. if the parent already has
			%   children, the new children are appended. The
			%   following arguments are understood:
			%
			% 'h'/'v' - switch "p" to pack in the horizontal or
			%   vertical packing dimension for relative packing
			%   mode (default for new panels is vertical).
			%
			% {a, b, c, ...} (a cell row vector) - pack panels
			%   into "p" with "packing specifiers" a, b, c, etc.
			%   packing specifiers are detailed below.
			%
			% PACKING MODES
			%   panels can be packed into their parent in two
			%   modes, dependent on their packing specifier. you
			%   can see a visual representation of these modes on
			%   the HTML documentation page "Layout".
			%
			% (i) Relative Mode - panels are packed into the space
			%   occupied by their parent. size along the parent's
			%   "packing dimension" is dictated by the packing
			%   specifier; along the other dimension size matches
			%   the parent. the following packing specifiers
			%   indicate Relative Mode.
			%
			%   a) Fixed Size: the specifier is a scalar double in
			%   a cell {d}. The panel will be of size d in the
			%   current units of "p" (see the property "p.units"
			%   for details, but default units are mm).
			%
			%   b) Fractional Size: the specifier is a scalar
			%   double between 0 and 1 (or between 1 and 100, as a
			%   percentage). The panel is sized as a fraction of
			%   the space remaining in its parent after Fixed Size
			%   panels and inter-panel margins have been subtracted.
			%
			%   c) Stretchable: the specifier is the empty matrix
			%   []. remaining space in the parent after Fixed and
			%   Fractional Size panels have been subtracted is
			%   shared out amongst Stretchable Size panels.
			%
			% (ii) Absolute Mode - panels hover above their
			%   parent and do not take up space, as if using the
			%   position:absolute property in CSS. The packing
			%   specifier is a 1x4 double vector indicating the
			%   [left bottom width height] of the panel in
			%   normalised coordinates of its parent. for example,
			%   the specifier [0 0 1 1] generates a child panel
			%   that fills its parent.
			%
			% SHORTCUTS
			%
			% ** a small scalar integer, N, (1 to 32) is expanded
			%    to {[], [], ... []}, with N entries. that is, it
			%    packs N panels in Relative Mode (Stretchable) and
			%    shares the available space between them.
			%
			% ** the call to pack() is recursive, so following a
			%    packing specifier list, an additional list will
			%    be used to generate a separate call to pack() on
			%    each of the children created by the first. hence:
			%
			%      p.pack({[] []}, {[] []})
			%
			%    will create a 2x2 grid of panels that share the
			%    space of their parent, "p". since the argument
			%    "2" expands to {[] []} (see above), the same grid
			%    can be created using:
			%
			%      p.pack(2, 2)
			%
			%    which is a common idiom in the demos. NB: on
			%    recursion, the packing dimension is flipped
			%    automatically, so that a grid is formed.
			%
			% ** if no arguments are passed at all, a single
			%    argument {[]} is assumed, so that a single
			%    additional panel is packed into the parent in
			%    relative packing mode and with stretchable size.
			%
			% see also: panel (overview), panel/panel(), select()
			%
			% LEGACY
			%
			%   the interface to pack() was changed at release
			%   2.10 to add support for panels of fixed physical
			%   size. the interface offered at 2.9 and earlier is
			%   still available (look inside panel.m - search for
			%   text "LEGACY" - for details).

			% LEGACY
			%
			%  releases of panel prior to 2.10 did not support
			%  panels of fixed physical size, and therefore had
			%  developed a different argument form to that used in
			%  2.10 and beyond. specifically, the following
			%  additional arguments are accepted, for legacy
			%  support:
			%
			% 'abs'
			%   the next argument will be an absolute position, as
			%   described below. you should avoid using absolute
			%   positioning mode, in general, since this does not
			%   take advantage of panel's automatic layout.
			%   however, on occasion, you may need to take manual
			%   control of the position of one or more panels. see
			%   demopanelH for an example.
			%
			% 1xN row vector (without 'abs')
			%   pack N new panels along the packing dimension in
			%   relative mode, with the relative size of each
			%   given by the elements of the vector. -1 can be
			%   passed for any elements to mark those panel as
			%   'stretchable', so that they fill available space
			%   left over by other panels packed alongside. the
			%   sum of the vector (apart from any -1 entries)
			%   should not come to more than 1, or a warning will
			%   be generated during laying out. an example would
			%   be [1/4 1/4 -1], to pack 3 panels, at 25, 25 and
			%   50% relative sizes. though, NB, you can use
			%   percentages instead of fractions if you prefer, in
			%   which case they should not sum to over 100. so
			%   that same pack() would be [25 25 -1].
			%
			% 1x4 row vector (after 'abs')
			%   pack 1 new panel using absolute positioning. the
			%   argument indicates the [left bottom width height]
			%   of the new panel, in normalised coordinates, as a
			%   fraction of its parent's position. panels using
			%   absolute positioning mode are ignored for the sake
			%   of layout, much like items using
			%   'position:absolute' in CSS.
			
			% handle legacy, parse arguments from varargin into args
			args = {};
			while ~isempty(varargin)
				
				% peel
				arg = varargin{1};
				varargin = varargin(2:end);
				
				% handle shortcut (small integer) on current interface
				if isa(arg, 'double') && isscalar(arg) && round(arg) == arg && arg >= 1 && arg <= 32
					arg = cell(1, arg);
				end
					
				% handle current interface - note that the argument
				% "recursive" is private and not advertised to the
				% user.
				if isequal(arg, 'h') || isequal(arg, 'v') || (iscell(arg) && isrow(arg)) || isequal(arg, 'recursive')
					args{end+1} = arg;
					continue
				end
				
				% report (DEBUG)
% 				panel.debugmsg('use of LEGACY interface to pack()', 1);
				
				% handle legacy case
				if isequal(arg, 'abs')
					if length(varargin) ~= 1 || ~isnumeric(varargin{1}) || ~isofsize(varargin{1}, [1 4])
						error('panel:LegacyAbsNotFollowedBy1x4', 'the argument "abs" on the legacy interface should be followed by a [1x4] row vector');
					end
					abs = varargin{1};
					varargin = varargin(2:end);
					args{end+1} = {abs};
					continue
				end
				
				% handle legacy case
				if isa(arg, 'double') && isrow(arg)
					arg_ = {};
					for a = 1:length(arg)
						aa = arg(a);
						if isequal(aa, -1)
							arg_{end+1} = [];
						else
							arg_{end+1} = aa;
						end
					end
					args{end+1} = arg_;
					continue
				end
				
				% unrecognised argument
				error('panel:InvalidArgument', 'argument to pack() not recognised');
				
			end
			
			% check m_panelType
			if p.isObject()
				error('panel:PackWhenObjectPanel', ...
					'cannot pack() into this panel - it is already committed as an object panel');
			end
			
			% if no arguments, simulate an argument of [], to pack
			% a single panel of stretchable size
			if isempty(args)
				args = {{[]}};
			end
			
			% state
			recursive = false;
			
			% handle arguments one by one
			while ~isempty(args) && ischar(args{1})
				
				% extract
				arg = args{1};
				args = args(2:end);
				
				% handle string arguments
				switch arg
					case 'h'
						p.packdim = 1;
					case 'v'
						p.packdim = 2;
					case 'recursive'
						recursive = true;
					otherwise
						error('panel:InvalidArgument', ['pack() did not recognise the argument "' arg '"']);
				end
					
			end
			
			% if no more arguments that's weird but not bad
			if isempty(args)
				return
			end
			
			% next argument now must be a cell
			arg = args{1};
			args = args(2:end);
			if ~iscell(arg)
				panel.error('InternalError');
			end

			% commit as parent
			p.commitAsParent();				

			% for each element
			for i = 1:length(arg)

				% get packspec
				packspec = arg{i};

				% validate
				validate_packspec(packspec);
				
				% handle units
				if iscell(packspec)
					units = p.getPropertyValue('units');
					packspec{1} = panel.resolveUnits({packspec{1} units}, 'mm');
				end

				% create a child
				child = panel('pack', p);
				child.packspec = packspec;

				% store it in the parent
				if isempty(p.m_children)
					p.m_children = child;
				else
					p.m_children(end+1) = child;
				end

				% recurse (further argumens are passed on)
				if ~isempty(args)
					child_packdim = flippackdim(p.packdim);
					edges = 'hv';
					child.pack('recursive', edges(child_packdim), args{:});
				end

			end
				
			% this must generate a recomputeLayout(), since the
			% addition of new panels may affect the layout. any
			% recursive call passes 'recursive', so that only the
			% root call actually bothers doing a layout.
			if ~recursive
				p.recomputeLayout([]);
			end
			
		end
		
		function h_out = select(p, h_object)
			
			% create or select an axis or object panel
			%
			% h = p.select(h)
			%   this call will return the handle of the object
			%   associated with the panel. if the panel is not yet
			%   committed, this will involve first committing it
			%   as an "object panel". if a list of objects ("h")
			%   is passed, these are the objects associated with
			%   the panel; if not, a new axis is created by the
			%   panel when this function is called.
			%
			%   if the object list includes axes, then the "object
			%   panel" is also known as an "axis panel". in this
			%   case, the call to select() will make the (first)
			%   axis current, unless an output argument is
			%   requested, in which case the handle of the axes
			%   are returned but no axis is made current.
			%
			%   the passed objects can be user-created axes (e.g.
			%   a colorbar) or any graphics object that is to have
			%   its position managed (e.g. a uipanel). your
			%   mileage may vary with different types of graphics
			%   object, please let me know.
			%
			% see also: panel (overview), panel/panel(), pack()
			
			% handle "all" and "data"
			if nargin == 2 && isstring(h_object) && (strcmp(h_object, 'all') || strcmp(h_object, 'data'))
				
				% collect
				h_out = [];
				
				% commit all uncommitted panels as axis panels by
				% selecting them once
				if p.isParent()

					% recurse
					for c = 1:length(p.m_children)
						h_out = [h_out p.m_children(c).select(h_object)];
					end

				elseif p.isUncommitted()

					% select in an axis
					h_out = p.select();
					
					% plot some data
					if strcmp(h_object, 'data')
						plot(h_out, randn(100, 1), 'k-');
					end

				end
				
				% ok
				return
				
			end
			
			% check m_panelType
			if p.isParent()
				error('panel:SelectWhenParent', 'cannot select() this panel - it is already committed as a parent panel');
			end
			
			% commit as object
			p.commitAsObject();

			% assume not a new object
			newObject = false;
			
			% use passed graphics object
			if nargin >= 2
				
				% validate
				if ~all(ishandle(h_object))
					error('panel:InvalidArgument', 'argument to select() must be a list of handles to graphics objects');
				end
				
				% validate
				if ~isempty(p.h_object)
					% 02/08/19 I disabled this check because
					% I don't see why it's needed (why
					% should we not change the managed
					% objects on the fly?)
% 					error('panel:SelectWithObjectWhenObject', 'cannot select() new objects into this panel - it is already managing objects');
				end
				
				% store
				p.h_object = h_object;
				newObject = true;
				
				% make sure it has the correct parent - this doesn't
				% seem to affect axes, so we do it for all
 				set(p.h_object, 'parent', p.h_parent);
				
			end
			
			% create new axis if necessary
			if isempty(p.h_object)
				% 'NextPlot', 'replacechildren'
				%   make sure fonts etc. don't get changed when user
				%   plots into it
				p.h_object = axes( ...
					'Parent', p.h_parent, ...
					'NextPlot', 'replacechildren' ...
					);
				newObject = true;
			end
			
			% if wrapped objects include an axis, and no output args, make it current
			h_axes = p.getAllManagedAxes();
			if ~isempty(h_axes) && ~nargout
				set(p.h_figure, 'CurrentAxes', h_axes(1));
				
				% 12/07/11: this call is slow, because it implies "drawnow"
% 				figure(p.h_figure);

				% 12/07/11: this call is fast, because it doesn't
				set(0, 'CurrentFigure', p.h_figure);
				
			end
			
			% and return object list
			if nargout
				h_out = p.h_object;
			end
			
			% this must generate a applyLayout(), since the axis
			% will need positioning appropriately
			if newObject
				% 09/03/12 mitch
				% if there isn't a context yet, we'll have to
				% recomputeLayout(), in fact, to generate a context first.
				% this will happen, for instance, if a single panel
				% is generated in a window that was already open
				% (no resize event will fire, and since pack() is
				% not called, it will not call recomputeLayout() either).
				% nonetheless, we have to reposition this object, so
				% this forces us to recomputeLayout() now and generate
				% that context we need.
				if isempty(p.m_context)
					p.recomputeLayout([]);
				else
					p.applyLayout();
				end
			end
			
		end
		
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	%% ---- HIDDEN OVERLOADS ----
	
	methods (Hidden = true)
		
		function out = vertcat(p, q)
			error('panel2:MethodNotImplemented', 'concatenation is not supported by panel (use a cell array instead)');
		end
		
		function out = horzcat(p, q)
			error('panel2:MethodNotImplemented', 'concatenation is not supported by panel (use a cell array instead)');
		end
		
		function out = cat(dim, p, q)
			error('panel2:MethodNotImplemented', 'concatenation is not supported by panel (use a cell array instead)');
		end
		
		function out = ge(p, q)
			error('panel2:MethodNotImplemented', 'inequality operators are not supported by panel');
		end
		
		function out = le(p, q)
			error('panel2:MethodNotImplemented', 'inequality operators are not supported by panel');
		end
		
		function out = lt(p, q)
			error('panel2:MethodNotImplemented', 'inequality operators are not supported by panel');
		end
		
		function out = gt(p, q)
			error('panel2:MethodNotImplemented', 'inequality operators are not supported by panel');
		end
		
		function out = eq(p, q)
			out = eq@handle(p, q);
		end
		
		function out = ne(p, q)
			out = ne@handle(p, q);
		end
		
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	%% ---- PUBLIC HIDDEN GET/SET ----
	
	methods (Hidden = true)
		
		function p = descend(p, indices)
			
			while ~isempty(indices)

				% validate
				if numel(p) > 1
					error('panel:InvalidIndexing', 'you can only use () on a single (scalar) panel');
				end

				% validate
				if ~p.isParent()
					error('panel:InvalidIndexing', 'you can only use () on a parent panel');
				end
				
				% extract
				index = indices{1};
				indices = indices(2:end);

				% only accept numeric
				if ~isnumeric(index) || ~isscalar(index)
					error('panel:InvalidIndexing', 'you can only use () with scalar indices');
				end
					
				% do the reference
				p = p.m_children(index);
					
			end
			
		end

		function p_out = subsasgn(p, refs, value)
			
			% output is always subject
			p_out = p;
			
			% handle () indexing
			if strcmp(refs(1).type, '()')
				p = p.descend(refs(1).subs);
				refs = refs(2:end);
			end
				
			% is that it?
			if isempty(refs)
				error('panel:InvalidIndexing', 'you cannot assign to a child panel');
			end
			
 			% next ref must be .
 			if ~strcmp(refs(1).type, '.')
				panel.error('InvalidIndexing');
			end
			
			% either one (.X) or two (.ch.X)
			switch numel(refs)
				
				case 2
			
					% validate
					if ~strcmp(refs(2).type, '.')
						panel.error('InvalidIndexing');
					end
					
					% validate
					switch refs(2).subs
						case {'fontname' 'fontsize' 'fontweight'}
						case {'margin' 'marginleft' 'marginbottom' 'marginright' 'margintop'}
						otherwise
							panel.error('InvalidIndexing');
					end
					
					% avoid computing layout whilst setting descendant
					% properties
					p.defer();
					
					% recurse
					switch refs(1).subs
						case {'children' 'ch'}
							cs = p.m_children;
							for c = 1:length(cs)
								subsasgn(cs(c), refs(2:end), value);
							end
						case {'descendants' 'de'}
							cs = p.getPanels('*');
							for c = 1:length(cs)
								if cs{c} ~= p
									subsasgn(cs{c}, refs(2:end), value);
								end
							end
						case {'family' 'fa'}
							cs = p.getPanels('*');
							for c = 1:length(cs)
								subsasgn(cs{c}, refs(2:end), value);
							end
					end
					
					% release for laying out
					p.undefer();

					% mark for appropriate updates
					refs(1).subs = refs(2).subs;
					
				case 1

					% delegate
					p.setPropertyValue(refs(1).subs, value);
					
				otherwise
					panel.error('InvalidIndexing');
	
			end
			
			% update layout as necessary
			switch refs(1).subs
				case {'fontname' 'fontsize' 'fontweight'}
					p.applyLayout('recurse');
				case {'margin' 'marginleft' 'marginbottom' 'marginright' 'margintop'}
					p.recomputeLayout([]);
			end

		end
		
		function out = subsref(p, refs)

			% handle () indexing
			if strcmp(refs(1).type, '()')
				p = p.descend(refs(1).subs);
				refs = refs(2:end);
			end
				
			% is that it?
			if isempty(refs)
				out = p;
				return
			end

 			% next ref must be .
 			if ~strcmp(refs(1).type, '.')
				panel.error('InvalidIndexing');
			end
			
			% switch on "fieldname"
			switch refs(1).subs
				
				case { ...
						'fontname' 'fontsize' 'fontweight' ...
						'margin' 'marginleft' ...
						'marginbottom' 'marginright' 'margintop' ...
 						'units' ...
						}

					% delegate this property get
					out = p.getPropertyValue(refs(1).subs);
					
				case 'position'
					out = p.getObjectPosition();
					
				case 'figure'
					out = p.h_figure;
					
				case 'packspec'
					out = p.packspec;
					
				case 'axis'
					if p.isObject()
						out = p.getAllManagedAxes();
					else
						out = [];
					end
					
				case 'object'
					if p.isObject()
						h = p.h_object;
						ih = ishandle(h);
						out = h(ih);
					else
						out = [];
					end
					
 				case {'ch' 'children' 'de' 'descendants' 'fa' 'family'}
					
					% get the set
					switch refs(1).subs
						case {'children' 'ch'}
							out = {};
							for n = 1:length(p.m_children)
								out{n} = p.m_children(n);
							end
						case {'descendants' 'de'}
							out = p.getPanels('*');
							for c = 1:length(out)
								if out{c} == p
									out = out([1:c-1 c+1:end]);
									break
								end
							end
						case {'family' 'fa'}
							out = p.getPanels('*');
					end
					
					% we handle a special case of deeper reference
					% here, because we are abusing matlab's syntax to
					% do it. other cases (non-abusing) will be handled
					% recursively, as usual. this is when we go:
					%
					% p.ch.axis
					%
					% which isn't syntactically sound since p.ch is a
					% cell array (and potentially a non-singular one
					% at that). we re-interpret this to mean
					% [p.ch{1}.axis p.ch{2}.axis ...], as follows.
					if length(refs) > 1 && isequal(refs(2).type, '.')
						switch refs(2).subs
							case {'axis' 'object'}
								pp = out;
								out = [];
								for i = 1:length(pp)
									out = cat(2, out, subsref(pp{i}, refs(2)));
								end
								refs = refs(2:end); % used up!
							otherwise
								% give an informative error message
								panel.error('InvalidIndexing');
						end
					end
					
				case { ...
						'addCallback' 'setCallback' 'clearCallbacks' ...
						'hold' ...
						'refresh' 'export' ...
						'pack' 'repack' ...
						'identify' 'show' ...
						}

					% validate
					if length(refs) ~= 2 || ~strcmp(refs(2).type, '()')
						error('panel:InvalidIndexing', ['"' refs(1).subs '" is a function (try "help panel/' refs(1).subs '")']);
					end
					
					% delegate this function call with no output
					builtin('subsref', p, refs);
					return
					
				case { ...
						'select' 'fixdash' ...
						'xlabel' 'ylabel' 'zlabel' 'title' ...
						 'find' ...
						}
					
					% validate
					if length(refs) ~= 2 || ~strcmp(refs(2).type, '()')
						error('panel:InvalidIndexing', ['"' refs(1).subs '" is a function (try "help panel/' refs(1).subs '")']);
					end
					
					% delegate this function call with output
					if nargout
						out = builtin('subsref', p, refs);
					else
						builtin('subsref', p, refs);
					end
					return
					
				otherwise
					panel.error('InvalidIndexing');
							
			end
			
			% continue
			if length(refs) > 1
				out = subsref(out, refs(2:end));
			end
			
		end
		
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	%% ---- UTILITY METHODS ----
	
	methods (Access = private)
		
		function b = ismanagefont(p)
			
			% ask root
			b = p.m_root.state.manage_font;
			
		end
		
		function b = isdefer(p)
			
			% ask root
			b = p.m_root.state.defer ~= 0;
			
		end
		
		function defer(p)
			
			% increment
			p.m_root.state.defer = p.m_root.state.defer + 1;
			
		end

		function undefer(p)
			
			% decrement
			p.m_root.state.defer = p.m_root.state.defer - 1;
			
		end

		function cs = getPanels(p, panelTypes, edgespec, all)
			
			% return all the panels that match the specification.
			%
			% panelTypes "*": return all panels
			% panelTypes "s": return all sizeable panels (parent,
			%		object and uncommitted)
			% panelTypes "p": return only physical panels (object
			%   or uncommitted)
			% panelTypes "o": return only object panels
			%
			% if edgespec/all is specified, only panels matching
			% the edgespec are returned (all of them if "all" is
			% true, or any of them - the first one, in fact - if
			% "all" is false).
			
			cs = {};
			
			% do not include any that use absolute positioning -
			% they stand outside of the sizing model
			skip = (numel(p.packspec) == 4) && ~any(panelTypes == '*');
			
			if p.isParent()
				
				% return if appropriate type
 				if any(panelTypes == '*s') && ~skip
					cs = {p};
 				end
				
				% if edgespec was supplied
				if nargin == 4

					% if we are perpendicular to the specified edge
					if p.packdim ~= edgespec(1)

						if all
							
							% return all matching
							for c = 1:length(p.m_children)
								ppp = p.m_children(c).getPanels(panelTypes, edgespec, all);
								cs = cat(2, cs, ppp);
							end
							
						else
							
							% return only the first one
							cs = cat(2, cs, p.m_children(1).getPanels(panelTypes, edgespec, all));
							
						end

					else

						% if we are parallel to the specified edge
						if edgespec(2) == 2
							
							% use last
							ppp = p.m_children(end).getPanels(panelTypes, edgespec, all);
							cs = cat(2, cs, ppp);
							
						else
							
							% use first
							cs = cat(2, cs, p.m_children(1).getPanels(panelTypes, edgespec, all));
							
						end

					end
					
				else
					
					% else, return all
					for c = 1:length(p.m_children)
						ppp = p.m_children(c).getPanels(panelTypes);
						cs = cat(2, cs, ppp);
					end
					
				end
				
			elseif p.isObject()
				
				% return if appropriate type
				if any(panelTypes == '*spo') && ~skip
					cs = {p};
				end
				
			else
				
				% return if appropriate type
				if any(panelTypes == '*sp') && ~skip
					cs = {p};
				end
				
			end
			
		end
		
		function commitAsParent(p)
			
			if p.isUncommitted()
				p.m_panelType = p.PANEL_TYPE_PARENT;
			elseif p.isObject()
				error('panel:AlreadyCommitted', 'cannot make this panel a parent panel, it is already an object panel');
			end

		end
		
		function commitAsObject(p)
			
			if p.isUncommitted()
				p.m_panelType = p.PANEL_TYPE_OBJECT;
			elseif p.isParent()
				error('panel:AlreadyCommitted', 'cannot make this panel an object panel, it is already a parent panel');
			end

		end
		
		function b = isRoot(p)
			
			b = isempty(p.parent);
			
		end
		
		function b = isParent(p)
			
			b = p.m_panelType == p.PANEL_TYPE_PARENT;
			
		end
		
		function b = isObject(p)
			
			b = p.m_panelType == p.PANEL_TYPE_OBJECT;
			
		end
		
		function b = isUncommitted(p)
			
			b = p.m_panelType == p.PANEL_TYPE_UNCOMMITTED;
			
		end

		function h_axes = getAllManagedAxes(p)
			
			h_axes = [];
			for n = 1:length(p.h_object)
				h = p.h_object(n);
				if isaxis(h)
					h_axes = [h_axes h];
				end
			end
			
		end
		
		function h_object = getOrCreateAxis(p)
			
			switch p.m_panelType
				
				case p.PANEL_TYPE_PARENT
					
					% create if not present
					if isempty(p.h_object)
						
						% 'Visible', 'off'
						%   this is the hidden axis of a parent panel,
						%   used for displaying a parent panel's xlabel,
						%   ylabel and title, but not as a plotting axis
						%
						% 'NextPlot', 'replacechildren'
						%   make sure fonts etc. don't get changed when user
						%   plots into it
						p.h_object = axes( ...
							'Parent', p.h_parent, ...
							'Visible', 'off', ...
							'NextPlot', 'replacechildren' ...
							);
						
						% make sure it's unitary, to help us in
						% positioning labels and title
						axis(p.h_object, [0 1 0 1]);
						
						% refresh this axis position
						p.applyLayout();
						
					end
					
					% ok
					h_object = p.h_object;
					
				case p.PANEL_TYPE_OBJECT
					
					% ok
					h_object = p.getAllManagedAxes();
					if isempty(h_object)
						error('panel:ManagedObjectNotAnAxis', 'this object panel does not manage an axis');
					end
					
				case p.PANEL_TYPE_UNCOMMITTED
					
					panel.error('PanelUncommitted');
					
			end
			
		end
		
		function removeChild(p, child)
			
			% if not a parent, fail but warn (shouldn't happen)
			if ~p.isParent()
				warning('panel:NotParentOnRemoveChild', 'i am not a parent (in removeChild())');
				return
			end
			
			% remove from children
			for c = 1:length(p.m_children)
				if p.m_children(c) == child
					p.m_children = p.m_children([1:c-1 c+1:end]);
					return
				end
			end
			
			% warn
			warning('panel:ChildAbsentOnRemoveChild', 'child not found (in removeChild())');
			
		end
		
		function h = getShowAxis(p)
			
			if p.isRoot()
				if isempty(p.h_showAxis)
					
					% create
					p.h_showAxis = axes( ...
						'Parent', p.h_parent, ...
						'units', 'normalized', ...
						'position', [0 0 1 1] ...
						);
					
					% move to bottom
					c = get(p.h_parent, 'children');
					c = [c(2:end); c(1)];
					set(p.h_parent, 'children', c);
					
					% finalise axis
					set(p.h_showAxis, ...
						'xtick', [], 'ytick', [], ...
						'color', 'none', 'box', 'off' ...
						);
					axis(p.h_showAxis, [0 1 0 1]);
					
					% hold
					hold(p.h_showAxis, 'on');
					
				end
				
				% return it
				h = p.h_showAxis;
				
			else
				h = p.parent.getShowAxis();
			end
			
		end
		
		function fireCallbacks(p, event)
		
			% for each attached callback
			for c = 1:length(p.m_callback)
				
				% extract
				callback = p.m_callback{c};
				func = callback{1};
				userdata = callback{2};
				
				% fire
				data = [];
				data.panel = p;
				data.event = event;
				data.context = p.m_context;
				data.userdata = userdata;
				func(data);
				
			end
				
		end
		
	end
	
	
	
	

		
	
	
	
	
	
		
	%% ---- LAYOUT METHODS ----
	
	methods

		function refresh(p)
			
			% recompute layout of all panels
			%
			% p.refresh()
			%   recompute the layout of all panels from scratch.
			%   this should not usually be required, and is
			%   provided primarily for legacy support.
			
			% LEGACY
			%
			% NB: if you pass 'defer' to the constructor, calling
			% refresh() both recomputes the layout and releases
			% the defer mode. future changes to properties (e.g.
			% margins) will cause immediate recomputation of the
			% layout, so only call refresh() when you're done.
			
			% bubble up to root
			if ~p.isRoot()
				p.m_root.refresh();
				return
			end
			
			% release defer
			p.state.defer = 0;

			% debug output
% 			panel.debugmsg(['refresh "' p.state.name '"...']);
			
			% call recomputeLayout
			p.recomputeLayout([]);
			
		end
		
	end
		
	methods (Access = private)
		
		function do_fixdash(p, context)
			
			% if context is [], this is _after_ the layout for
			% export, so we need to restore
			if isempty(context)
				
				% restore lines we changed to their original state
				for r = 1:length(p.m_fixdash_restore)
					
					% get
					restore = p.m_fixdash_restore{r};
					
					% if empty, no change was made
					if ~isempty(restore)
						set(restore.h_line, ...
							'xdata', restore.xdata, 'ydata', restore.ydata);
						delete([restore.h_supp restore.h_mark]);
					end
					
				end
				
			else
				
% 				% get handles to objects that still exist
% 				h_lines = p.m_fixdash(ishandle(p.m_fixdash));
				
				% no restores
				p.m_fixdash_restore = {};
				
				% for each line
				for i = 1:length(p.m_fixdash)
					
					% get
					fix = p.m_fixdash{i};
					
					% final check
					if ~ishandle(fix.h) || ~isequal(get(fix.h, 'type'), 'line')
						continue
					end
					
					% apply dashstyle
					p.m_fixdash_restore{end+1} = dashstyle_line(fix, context);

				end
				
			end

		end

		function p = recomputeLayout(p, context)
			
			% this function recomputes the layout from scratch.
			% this means calculating the sizes of the root panel
			% and all descendant panels. after this is completed,
			% the function calls applyLayout to effect the new
			% layout.
			
			% if not root, bubble up to root
			if ~p.isRoot()
				p.m_root.recomputeLayout(context);
				return
			end
			
			% if in defer mode, do not compute layout
			if p.isdefer()
				return
			end
			
			% if no context supplied (e.g. on resize events), use
			% the figure window (a context is supplied if
			% exporting to an image file).
			if isempty(context)
				context.mode = panel.LAYOUT_MODE_NORMAL;
				context.size_in_mm = [];
				context.rect = [0 0 1 1];
			end				
			
			% debug output
% 			panel.debugmsg(['recomputeLayout "' p.state.name '"...']);

% 			% root may have a packspec of its own
% 			if ~isempty(p.packspec)
% 				if isscalar(p.packspec)
% 					% this should never happen, because it should be
% 					% caught when the packspec is set in repack()
% 					warning('panel:RootPanelCannotUseRelativeMode', 'the root panel uses relative positioning mode - this is ignored');
% 				else
% 					context.rect = p.packspec;
% 				end
% 			end
			
			% if not given a context size, use the size on screen
			% of the parent figure
			if isempty(context.size_in_mm)
				
				% get context (whole parent) size in its units
				pp = get(p.h_figure, 'position');
				context_size = pp(3:4);

				% defaults, in case this fails for any reason
				screen_size = [1280 1024];
				if ismac
					screen_dpi = 72;
				else
					screen_dpi = 96;
				end

				% get screen DPI
				try
					local_screen_dpi = get(0, 'ScreenPixelsPerInch');
					if ~isempty(local_screen_dpi)
						screen_dpi = local_screen_dpi;
					end
				end

				% get screen size
				try
					local_screen_size = get(0, 'ScreenSize');
					if ~isempty(local_screen_size)
						screen_size = local_screen_size;
					end
				end
				
				% get figure width and height on screen
				switch get(p.h_figure, 'Units')
					
					case 'points'
						points_per_inch = 72;
						context.size_in_mm = context_size / points_per_inch * 25.4;
						
					case 'inches'
						context.size_in_mm = context_size * 25.4;
						
					case 'centimeters'
						context.size_in_mm = context_size * 10.0;
						
					case 'pixels'
						context.size_in_mm = context_size / screen_dpi * 25.4;
						
					case 'characters'
						context_size = context_size .* [5 13]; % convert to pixels (based on empirical measurement)
						context.size_in_mm = context_size / screen_dpi * 25.4;
						
					case 'normalized'
						context_size = context_size .* screen_size(3:4); % convert to pixels (based on screen size)
						context.size_in_mm = context_size / screen_dpi * 25.4;
						
					otherwise
						error('panel:CaseNotCoded', ['case not coded, (Parent Units are ' get(p.h_figure, 'Units') ')']);
						
				end
				
			end
			
			% that's the figure size, now we need the size of our
			% parent, if it's not the figure too
			if p.h_parent ~= p.h_figure
				units = get(p.h_parent, 'units');
				set(p.h_parent, 'units', 'normalized');
				pos = get(p.h_parent, 'position');
				set(p.h_parent, 'units', units);
				context.size_in_mm = context.size_in_mm .* pos(3:4);
			end
			
			% for the root, we apply the margins here, since it's
			% a special case because there's always exactly one of
			% it
			margin = p.getPropertyValue('margin', 'mm');
			m = margin([1 3]) / context.size_in_mm(1);
			context.rect = context.rect + [m(1) 0 -sum(m) 0];
			m = margin([2 4]) / context.size_in_mm(2);
			context.rect = context.rect + [0 m(1) 0 -sum(m)];
			
			% now, recurse
			p.recurseComputeLayout(context);
			
			% clear h_showAxis when we recompute the layout
			if ~isempty(p.h_showAxis)
				delete(p.h_showAxis);
				p.h_showAxis = [];
			end

			% having computed the layout, we now apply it,
			% starting at the root panel.
			p.applyLayout('recurse');
			
		end
		
		function recurseComputeLayout(p, context)
			
			% store context
			p.m_context = context;
			
			% if no children, do nothing further
			if isempty(p.m_children)
				return
			end
			
			% else, we're going to recompute the layout for our
			% children
			margins = [];
			
			% get size to pack into
			mm_canvas = context.size_in_mm(p.packdim);
			mm_context = mm_canvas * context.rect(2+p.packdim);
			
			% get list of children that are packed relative - we
			% do this because the computation only handles these
			% relative children; absolute packed children are
			% ignored through the computation, and are just packed
			% as specified when the time comes.
			rel_list = [];
			
			% for each child
			for i = 1:length(p.m_children)

				% get child
				c = p.m_children(i);			
			
				% is it packed abs?
				if isofsize(c.packspec, [1 4])
					continue
				end
				
				% if not, it's packed relative, so add to list
				rel_list(end+1) = i;
				
			end
				
			% array of actual sizes as fraction of parent (note we
			% only represent the rel_list).
			zz = zeros(1, length(rel_list));
			sz_phys = zz;
			sz_frac = zz;
			i_stretch = zz;
			
			% for each child that is packed relative
			for i = 1:length(rel_list)

				% get child
				c = p.m_children(rel_list(i));

				% get internal margin
				margin = c.getPropertyValue('margin', 'mm');
				if p.packdim == 2
					margin = margin([2 4]);
					margin = fliplr(margin); % doclink FLIP_PACKDIM_2 - same reason, here!
				else
					margin = margin([1 3]);
				end
				margins(i:i+1, i) = margin';
				
				% subtract fixed size packspec from packing size
				if iscell(c.packspec)
					% NB: fixed size is always _stored_ in mm!
					sz_phys(i) = c.packspec{1};
				end
				
				% get relative packing sizes
				if isnumeric(c.packspec) && isscalar(c.packspec)
					% NB: relative size is a scalar numeric
					sz_frac(i) = c.packspec;
					% convert perc to frac
					if sz_frac(i) > 1
						sz_frac(i) = sz_frac(i) / 100;
					end
				end
				
				% get stretch packing size
				if isempty(c.packspec)
					% NB: these will be filled later
					i_stretch(i) = 1;
				end
				
				% else, it's an abs packing size, and we can ignore
				% it for this phase of layout
				
			end
			
			% finalise internal margins (that is, the margin at
			% each boundary between two adjacent relative packed
			% panels is the maximum of the margins specified by
			% each of the pair).
			margins = max(margins, [], 2);
			margins = margins(2:end-1)';
			
			% subtract internal margins to give available space
			% for objects (in mm)
			mm_objects = mm_context - sum(margins);
			
			% now, subtract physically sized objects to give
			% available space to share out amongst panels that
			% specify their size as a fraction.
			mm_share = mm_objects - sum(sz_phys);
			
			% and now stretch items can be given their actual
			% fractional size, since we now know who they are
			% sharing space with.
			sz_frac(find(i_stretch)) = (1 - sum(sz_frac)) / sum(i_stretch);
			
			% and we can now get the real physical size of all the
			% fractionally-sized panels in mm.
			sz_frac = sz_frac * mm_share;
			
			% finally, we've got the physical boundaries of
			% everything; let's just tidy that up.
			sz = [[sz_phys + sz_frac]; margins 0];
			sz = sz(1:end-1);
			
			% and let's normalise the physical boundaries, because
			% we're actually going to specify them to matlab in
			% normalised form, even though we computed them in mm.
			if ~isempty(sz)
				
				% do it
				sz_norm = reshape([0 cumsum(sz / mm_context)]', 2, [])';
			
				% for packdim 2, we pack from the top, whereas
				% matlab's position property packs from the bottom, so
				% we have to flip these. doclink FLIP_PACKDIM_2.
				if p.packdim == 2
					sz_norm = fliplr(1 - sz_norm);
				end
				
			end
			
			% recurse
			for i = 1:length(p.m_children)
				
				% get child
 				c = p.m_children(i);
				
				% handle abs packed panels
				if isofsize(c.packspec, [1 4])
					
					% child context
					child_context = context;
					rect = child_context.rect;
					rect([1 3]) = c.packspec([1 3]) * rect(3) + [rect(1) 0];
					rect([2 4]) = c.packspec([2 4]) * rect(4) + [rect(2) 0];
					child_context.rect = rect;

				else
				
					% child context
					child_context = context;
					rr = sz_norm(1, :);
					sz_norm = sz_norm(2:end, :); % sz_norm has only as many entries as there are rel-packed panels
					ri = p.packdim + [0 2];
					a = child_context.rect(ri(1));
					b = child_context.rect(ri(2));
					child_context.rect(ri) = [a+rr(1)*b diff(rr)*b];
					
				end
				
				% recurse
 				c.recurseComputeLayout(child_context);
				
			end
			
		end
		
		function applyLayout(p, varargin)
			
			% this function applies the layout that is stored in
			% each panel objects "m_context" member, and fixes up
			% the position of any associated objects (such as axis
			% group labels).
			
			% skip if disabled
			if p.isdefer()
				return
			end
			
			% debug output
% 			panel.debugmsg(['applyLayout "' p.state.name '"...']);
			
			% defaults
			recurse = false;
			
			% handle arguments
			while ~isempty(varargin)
				
				% get
				arg = varargin{1};
				varargin = varargin(2:end);
				
				% handle
				switch arg
					case 'recurse'
						recurse = true;
					otherwise
						panel.error('InternalError');
				end
				
			end
			
			% recurse
			if recurse
				pp = p.getPanels('*');
			else
				pp = {p};
			end
			
			% why do we have to split the applyLayout() operation
			% into two?
			%
			% because the "group labels" are positioned with
			% respect to the axes in their group depending on
			% whether those axes have tick labels, and what those
			% tick labels are. if those tick labels are in
			% automatic mode (as they usually are), they may
			% change when those axes are positioned. since an axis
			% group may contain many of these nested deep, we have
			% to position all axes (step 1) first, then (step 2)
			% position any group labels.
			
			% step 1
			for pi = 1:length(pp)
				pp{pi}.applyLayout1();
			end
			
			% step 2
			for pi = 1:length(pp)
				pp{pi}.applyLayout2();
			end
			
			% callbacks
			for pi = 1:length(pp)
				fireCallbacks(pp{pi}, 'layout-updated');
			end
			
		end
		
		function r = getObjectPosition(p)
			
			% get packed position
			r = p.m_context.rect;
			
			% if empty, must be absolute position
			if isempty(r)
				r = p.packspec;
				pp = getObjectPosition(p.parent);
				r = panel.getRectangleOfRectangle(pp, r);
			end
			
		end
		
		function applyLayout1(p)
			
			% if no context yet, skip this call
			if isempty(p.m_context)
				return
			end
			
			% if no managed objects, skip this call
			if isempty(p.h_object)
				return
			end

			% debug output
% 			panel.debugmsg(['applyLayout1 "' p.state.name '"...']);
			
			% handle LAYOUT_MODE
			switch p.m_context.mode

				case panel.LAYOUT_MODE_PREPRINT

					% if in LAYOUT_MODE_PREPRINT, store current axis
					% layout (ticks and ticklabels) and lock them into
					% manual mode so they don't get changed during the
					% print operation
					h_axes = p.getAllManagedAxes();
					for n = 1:length(h_axes)
						p.state.store{n} = storeAxisState(h_axes(n));
					end

				case panel.LAYOUT_MODE_POSTPRINT

					% if in LAYOUT_MODE_POSTPRINT, restore axis
					% layout, leaving it as it was before we ran
					% export
					h_axes = p.getAllManagedAxes();
					for n = 1:length(h_axes)
						restoreAxisState(h_axes(n), p.state.store{n});
					end

			end
			
			% position it
			try
				set(p.h_object, 'position', p.getObjectPosition(), 'units', 'normalized');
			catch err
				if strcmp(err.identifier, 'MATLAB:hg:set_chck:DimensionsOutsideRange')
					w = warning('query', 'backtrace');
					warning off backtrace
					warning('panel:PanelZeroSize', 'a panel had zero size, and the managed object was hidden');
					set(p.h_object, 'position', [-0.3 -0.3 0.2 0.2]);
					if strcmp(w.state, 'on')
						warning on backtrace
					end
				elseif strcmp(err.identifier, 'MATLAB:class:InvalidHandle')
					% this will happen if the user deletes the managed
					% objects manually. an obvious way that this
					% happens is if the user select()s some panels so
					% that axes get created, then calls clf. it would
					% be nice if we could clear the panels attached to
					% a figure in response to a clf call, but there
					% doesn't seem any obvious way to pick up the clf
					% call, only the delete(objects) that follows, and
					% this is indistinguishable from a call by the
					% user to delete(my_axis), for instance. how are
					% we to respond if the user deletes the axis the
					% panel is managing? it's not clear. so, we'll
					% just fail silently, for now, and these panels
					% will either never be used again (and will be
					% destroyed when the figure is closed) or will be
					% destroyed when the user creates a new panel on
					% this figure. either way, i think, no real harm
					% done.
% 					w = warning('query', 'backtrace');
% 					warning off backtrace
% 					warning('panel:PanelObjectDestroyed', 'the object managed by a panel has been destroyed');
% 					if strcmp(w.state, 'on')
% 						warning on backtrace
% 					end
% 					panel.debugmsg('***WARNING*** the object managed by a panel has been destroyed');
					return
				else
					rethrow(err)
				end
			end

			% if managing fonts
			if p.ismanagefont()
				
				% apply properties to objects
				h = p.h_object;
				
				% get those which are axes
				h_axes = p.getAllManagedAxes();

				% and labels/title objects, for any that are axes
				for n = 1:length(h_axes)
					h = [h ...
						get(h_axes(n), 'xlabel') ...
						get(h_axes(n), 'ylabel') ...
						get(h_axes(n), 'zlabel') ...
						get(h_axes(n), 'title') ...
						];
				end
				
				% apply font properties
				set(h, ...
					'fontname', p.getPropertyValue('fontname'), ...
					'fontsize', p.getPropertyValue('fontsize'), ...
					'fontweight', p.getPropertyValue('fontweight') ...
					);
				
			end

		end
			
		function applyLayout2(p)
			
			% if no context yet, skip this call
			if isempty(p.m_context)
				return
			end
			
			% if no object, skip this call
			if isempty(p.h_object)
				return
			end

			% if not a parent, skip this call
			if ~p.isParent()
				return
			end

			% if not an axis, skip this call - NB: this is not a
			% displayed and managed object, rather it is the
			% invisible axis used to display parent labels/titles.
			% we checked above if this panel is a parent. thus,
			% the member h_object must be scalar, if it is
			% non-empty.
			if ~isaxis(p.h_object)
				return
			end

			% debug output
% 			panel.debugmsg(['applyLayout2 "' p.state.name '"...']);
			
			% matlab moves x/ylabels around depending on
			% whether the axis in question has any x/yticks,
			% so that the label is always "near" the axis.
			% we try to do the same, but it's hack-o-rama.

			% calibration offsets - i measured these
			% empirically, what a load of shit
			font_fudge = [2 1/3];
			nofont_fudge = [2 0];

			% do xlabel
			cs = p.getPanels('o', [2 2], true);
			y = 0;
			for c = 1:length(cs)
				ch = cs{c};
				h_axes = ch.getAllManagedAxes();
				for h_axis = h_axes
					% only if there are some tick labels, and they're
					% at the bottom...
					if ~isempty(get(h_axis, 'xticklabel')) && ~isempty(get(h_axis, 'xtick')) ...
							&& strcmp(get(h_axis, 'xaxislocation'), 'bottom')
						fontoffset_mm = get(h_axis, 'fontsize') * font_fudge(2) + font_fudge(1);
						y = max(y, fontoffset_mm);
					end
				end
			end
			y = max(y, get(p.h_object, 'fontsize') * nofont_fudge(2) + nofont_fudge(1));

			% convert and lay in
			axisheight_mm = p.m_context.size_in_mm(2) * p.m_context.rect(4);
			y = y / axisheight_mm;
			set(get(p.h_object, 'xlabel'), ...
				'VerticalAlignment', 'Cap', ...
				'Units', 'Normalized', ...
				'Position', [0.5 -y 1]);

			% calibration offsets - i measured these
			% empirically, what a load of shit
			font_fudge = [3 1/6];
			nofont_fudge = [2 0];

			% do ylabel
			cs = p.getPanels('o', [1 1], true);
			x = 0;
			for c = 1:length(cs)
				ch = cs{c};
				h_axes = ch.getAllManagedAxes();
				for h_axis = h_axes
					% only if there are some tick labels, and they're
					% at the left...
					if ~isempty(get(h_axis, 'yticklabel')) && ~isempty(get(h_axis, 'ytick')) ...
							&& strcmp(get(h_axis, 'yaxislocation'), 'left')
						yt = get(h_axis, 'yticklabel');
						if ischar(yt)
							ml = size(yt, 2);
						else
							ml = 0;
							for i = 1:length(yt)
								ml = max(ml, length(yt{i}));
							end
						end
						fontoffset_mm = get(h_axis, 'fontsize') * ml * font_fudge(2) + font_fudge(1);
						x = max(x, fontoffset_mm);
					end
				end
			end
			x = max(x, get(p.h_object, 'fontsize') * nofont_fudge(2) + nofont_fudge(1));

			% convert and lay in
			axisheight_mm = p.m_context.size_in_mm(1) * p.m_context.rect(3);
			x = x / axisheight_mm;
			set(get(p.h_object, 'ylabel'), ...
				'VerticalAlignment', 'Bottom', ...
				'Units', 'Normalized', ...
				'Position', [-x 0.5 1]);

			% calibration offsets - made up based on the
			% ones i measured for the labels
			nofont_fudge = [2 0];

			% get y position
			y = max(y, get(p.h_object, 'fontsize') * nofont_fudge(2) + nofont_fudge(1));

			% convert and lay in
			axisheight_mm = p.m_context.size_in_mm(2) * p.m_context.rect(4);
			y = y / axisheight_mm;
			set(get(p.h_object, 'title'), ...
				'VerticalAlignment', 'Bottom', ...
				'Position', [0.5 1+y 1]);
			
			% 21/11/19 move to bottom of z-index stack so
			% that it does not interfere with mouse
			% interactions with the other axes (e.g.
			% zooming)
			uistack(p.h_object, 'bottom')

		end
		
	end
	
	
	
	
	
	
	%% ---- PROPERTY METHODS ----
	
	methods (Access = private)
		
		function value = getPropertyValue(p, key, units)

			value = p.prop.(key);
			
			if isempty(value)

				% inherit
				if ~isempty(p.parent)
					switch key
						case {'fontname' 'fontsize' 'fontweight' 'margin' 'units'}
							if nargin == 3
								value = p.parent.getPropertyValue(key, units);
							else
								value = p.parent.getPropertyValue(key);
							end
							return
					end
				end
				
				% default
				if isempty(value)
					value = panel.getPropertyDefault(key);
				end
				
			end
			
			% translate dimensions
			switch key
				case {'margin'}
					if nargin < 3
						units = p.getPropertyValue('units');
					end
					value = panel.resolveUnits(value, units);
			end
			
		end
		
		function setPropertyValue(p, key, value)
			
			% root properties
			switch key
				case 'units'
					if ~isempty(p.parent)
						p.parent.setPropertyValue(key, value);
						return
					end
			end
			
			% value validation
			switch key
				case 'units'
					invalid = ~( (isstring(value) && isin({'mm' 'in' 'cm' 'pt'}, value)) || isempty(value) );
				case 'fontname'
					invalid = ~( isstring(value) || isempty(value) );
				case 'fontsize'
					invalid = ~( (isnumeric(value) && isscalar(value) && value >= 4 && value <= 60) || isempty(value) );
				case 'fontweight'
					invalid = ~( (isstring(value) && isin({'normal' 'bold'}, value)) || isempty(value) );
				case 'margin'
					invalid = ~( (isdimension(value)) || isempty(value) );
				case {'marginleft' 'marginbottom' 'marginright' 'margintop'}
					invalid = ~isscalardimension(value);
				otherwise
					error('panel:UnrecognisedProperty', ['unrecognised property "' key '"']);
			end
			
			% value validation
			if invalid
				error('panel:InvalidValueForProperty', ['invalid value for property "' key '"']);
			end
			
			% marginX properties
			switch key
				case {'marginleft' 'marginbottom' 'marginright' 'margintop'}
					index = isin({'left' 'bottom' 'right' 'top'}, key(7:end));
					element = value;
					value = p.getPropertyValue('margin');
					value(index) = element;
					key = 'margin';
			end
			
			% translate dimensions
			switch key
				case {'margin'}
					if isscalar(value)
						value = value * [1 1 1 1];
					end
					if ~isempty(value)
						units = p.getPropertyValue('units');
						value = {panel.resolveUnits({value units}, 'mm') 'mm'};
					end
			end
			
			% lay in
			p.prop.(key) = value;
			
		end
		
	end	
		
	methods (Static = true, Access = private)
	
        function s = fignum(h)
            
            % handled differently pre/post 2014b
            if isa(h, 'matlab.ui.Figure')
                % R2014b
                s = num2str(h.Number);
            else
                % pre-R2014b
                s = num2str(h);
            end
        end
		
		function prop = getPropertyInitialState()
			
			prop = panel.getPropertyDefaults();
			for key = fieldnames(prop)'
				prop.(key{1}) = [];
			end
			
		end
		
		function value = getPropertyDefault(key)
			
			persistent defprop
			
			if isempty(defprop)
				defprop = panel.getPropertyDefaults();
			end
			
			value = defprop.(key);
			
		end
		
		function defprop = getPropertyDefaults()
			
			% root properties
			defprop.units = 'mm';
			
			% inherited properties
			defprop.fontname = get(0, 'defaultAxesFontName');
			defprop.fontsize = get(0, 'defaultAxesFontSize');
			defprop.fontweight = 'normal';
			defprop.margin = {[15 15 5 5] 'mm'};
			
			% not inherited properties
			% CURRENTLY, NONE!
% 			defprop.align = false;
			
		end
		
	end	
		
	
	

	
	
	
	%% ---- STATIC PUBLIC METHODS ----
	
	methods (Static = true)
		
		function p = recover(h_figure)
			
			% get a handle to the root panel associated with a figure
			%
			% p = recover(h_fig)
			%   if you have not got a handle to the root panel of
			%   the figure h_fig, this call will retrieve it. if
			%   h_fig is not supplied, gcf is used.
			
			if nargin < 1
				h_figure = gcf;
			end
			
			p = panel.callbackDispatcher('recover', h_figure);
			
		end
		
		function version()
			
			% report the version of panel that is active
			%
			% panel.version()
			
			fid = fopen(which('panel'));
			tag = '% Release Version';
			ltag = length(tag);
			tagline = 'Unable to determine Release Version';
			while 1
				line = fgetl(fid);
				if ~ischar(line)
					break
				end
				if length(line) > ltag && strcmp(line(1:ltag), tag)
					tagline = line(3:end);
				end
			end
			fclose(fid);
			disp(tagline)
			
		end
		
		function panic()
			
			% call delete on all children of the global workspace,
			% to recover from bugs that leave us with uncloseable
			% figures. call this as "panel.panic()".
			%
			% NB: if you have to call panic(), something has gone
			% wrong. if you are able to reproduce the problem,
			% please contact me to report the bug.
			delete(allchild(0));
			
		end
		
	end
	
	
	
	
	
	
	%% ---- STATIC PRIVATE METHODS ----
	
	methods (Static = true, Access = private)
		
		function error(id)

			switch id
				case 'PanelUncommitted'
					throwAsCaller(MException('panel:PanelUncommitted', 'this action cannot be performed on an uncommitted panel'));
				case 'InvalidIndexing'
					throwAsCaller(MException('panel:InvalidIndexing', 'you cannot index a panel object in this way'));
				case 'InternalError'
					throwAsCaller(MException('panel:InternalError', 'an internal error occurred'));
				otherwise
					throwAsCaller(MException('panel:UnknownError', ['an unknown error was generated with id "' id '"']));
			end
				
		end
		
		function lockClass()
			
			persistent hasLocked
			if isempty(hasLocked)
				
				% only lock if not in debug mode
				if ~panel.isDebug()
					% in production code, must mlock() file at this point,
					% to avoid persistent variables being cleared by user
					if strcmp(getenv('USERDOMAIN'), 'BERGEN')
						% my machine, do nothing
					else
						mlock
					end
				end
				
				% mark that we've handled this
				hasLocked = true;
				
			end
			
		end
		
		function debugmsg(msg, focus)
			
			% focus can be supplied to force only focussed
			% messages to be shown
			if nargin < 2
				focus = 1;
			end
			
			% display, if in debug mode
			if focus
				if panel.isDebug()
					disp(msg);
				end
			end
			
		end
		
		function state = isDebug()
			
			% persistent
			persistent debug
			
			% create
			if isempty(debug)
				try
					debug = panel_debug_state();
				catch
	 				debug = false;
				end
			end
			
			% ok
			state = debug;
			
		end
		
		function r = getFractionOfRectangle(r, dim, range)
			
			switch dim
				case 1
					r = [r(1)+range(1)*r(3) r(2) range(2)*r(3) r(4)];
				case 2
					r = [r(1) r(2)+(1-sum(range))*r(4) r(3) range(2)*r(4)];
				otherwise
					error('panel:CaseNotCoded', ['case not coded, dim = ' dim ' (internal error)']);
			end
			
		end
		
		function r = getRectangleOfRectangle(r, s)
			
			w = r(3);
			h = r(4);
			r = [r(1)+s(1)*w r(2)+s(2)*h s(3)*w s(4)*h];
			
		end
		
		function a = getUnionRect(a, b)
			
			if isempty(a)
				a = b;
			end
			if ~isempty(b)
				d = a(1) - b(1);
				if d > 0
					a(1) = a(1) - d;
					a(3) = a(3) + d;
				end
				d = a(2) - b(2);
				if d > 0
					a(2) = a(2) - d;
					a(4) = a(4) + d;
				end
				d = b(1) + b(3) - (a(1) + a(3));
				if d > 0
					a(3) = a(3) + d;
				end
				d = b(2) + b(4) - (a(2) + a(4));
				if d > 0
					a(4) = a(4) + d;
				end
			end
			
		end
		
		function r = reduceRectangle(r, margin)
			
			r(1:2) = r(1:2) + margin(1:2);
			r(3:4) = r(3:4) - margin(1:2) - margin(3:4);
			
		end
		
		function v = normaliseDimension(v, space_size_in_mm)
			
			v = v ./ [space_size_in_mm space_size_in_mm];
			
		end
		
		function v = resolveUnits(d, units)
			
			% first, convert into mm
			v = d{1};
			switch d{2}
				case 'mm'
					% ok
				case 'cm'
					v = v * 10.0;
				case 'in'
					v = v * 25.4;
				case 'pt'
					v = v / 72.0 * 25.4;
				otherwise
					error('panel:CaseNotCoded', ['case not coded, storage units = ' units ' (internal error)']);
			end
			
			% then, convert to specified units
			switch units
				case 'mm'
					% ok
				case 'cm'
					v = v / 10.0;
				case 'in'
					v = v / 25.4;
				case 'pt'
					v = v / 25.4 * 72.0;
				otherwise
					error('panel:CaseNotCoded', ['case not coded, requested units = ' units ' (internal error)']);
			end
			
		end
		
		function resizeCallback(obj, evt)
			
			panel.callbackDispatcher('resize', obj);
			
		end
		
		function closeCallback(obj, evt)
			
			panel.callbackDispatcher('delete', obj);
			delete(obj);
			
		end
		
		function out = callbackDispatcher(op, data)
			
			% debug output
% 			panel.debugmsg(['callbackDispatcher(' op ')...'])
			
			% persistent store
			persistent registeredPanels
			
			% switch on operation
			switch op
				
				case {'register' 'registerNoClear'}
					
					% if a root panel is already attached to this
					% figure, we could throw an error and refuse to
					% create the new object, we could delete the
					% existing panel, or we could allow multiple
					% panels to be attached to the same figure.
					%
					% we should allow multiple panels, because they
					% may have different parents within the same
					% figure (e.g. uipanels). but by default we don't,
					% unless the panel.add() static constructor is
					% used.
					
					if strcmp(op, 'register')
						
						argument_h_figure = data.h_figure;
						i = 0;
						while i < length(registeredPanels)
							i = i + 1;
							if registeredPanels(i).h_figure == argument_h_figure
								delete(registeredPanels(i));
								i = 0;
							end
						end
						
					end
					
					% register the new panel
					if isempty(registeredPanels)
						registeredPanels = data;
					else
						registeredPanels(end+1) = data;
					end
					
					% debug output
% 					panel.debugmsg(['panel registered (' int2str(length(registeredPanels)) ' now registered)']);
					
				case 'unregister'
					
					% debug output
% 					panel.debugmsg(['on unregister, ' int2str(length(registeredPanels)) ' registered']);
					
					for r = 1:length(registeredPanels)
						if registeredPanels(r) == data
							registeredPanels = registeredPanels([1:r-1 r+1:end]);

							% debug output
% 							panel.debugmsg(['panel unregistered (' int2str(length(registeredPanels)) ' now registered)']);
							
							return
						end
					end
					
					% warn
					warning('panel:AbsentOnCallbacksUnregister', 'panel was absent from the callbacks register when it tried to unregister itself');
					
				case 'resize'
					
					argument_h_parent = data;
					for r = 1:length(registeredPanels)
						if registeredPanels(r).h_parent == argument_h_parent
							registeredPanels(r).recomputeLayout([]);
						end
					end
					
				case 'recover'
					
					argument_h_figure = data;
					out = [];
					for r = 1:length(registeredPanels)
						if registeredPanels(r).h_figure == argument_h_figure
							if isempty(out)
								out = registeredPanels(r);
							else
								out(end+1) = registeredPanels(r);
							end
						end
					end
					
				case 'delete'
					
					argument_h_figure = data;
					i = 0;
					while i < length(registeredPanels)
						i = i + 1;
						if registeredPanels(i).h_figure == argument_h_figure
							delete(registeredPanels(i));
							i = 0;
						end
					end
					
			end
			
		end
		
	end
	
	
	
	
end

















% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% HELPERS
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function restore = dashstyle_line(fix, context)

% get axis size in mm
h_line = fix.h;
h_axis = get(h_line, 'parent');
u = get(h_axis, 'units');
set(h_axis, 'units', 'norm');
pos = get(h_axis, 'position');
set(h_axis, 'units', u);
axis_in_mm = pos(3:4) .* context.size_in_mm;

% recover data
xdata = get(h_line, 'xdata');
ydata = get(h_line, 'ydata');
zdata = get(h_line, 'zdata');
linestyle = get(h_line, 'linestyle');
marker = get(h_line, 'marker');

% empty restore
restore = [];

% do not handle 3D
if ~isempty(zdata)
	warning('panel:NoFixdash3D', 'panel cannot fixdash() a 3D line - no action taken');
	return
end

% get range of axis
ax = axis(h_axis);

% get scale in each dimension (mm per unit)
sc = axis_in_mm ./ (ax([2 4]) - ax([1 3]));

% create empty line
data = NaN;

% override linestyle
if ~isempty(fix.linestyle)
	linestyle = fix.linestyle;
end

% transcribe linestyle
linestyle = dashstyle_parse_linestyle(linestyle);
if isempty(linestyle)
	return
end

% scale
scale = 1;
dashes = linestyle * scale;

% store for restore
restore.h_line = h_line;
restore.xdata = xdata;
restore.ydata = ydata;

% create another, separate, line to overlay on the original
% line and render the fixed-up dashes.
restore.h_supp = copyobj(h_line, h_axis);

% if the original line has markers, we'll have to create yet
% another separate line instance to represent them, because
% they shouldn't be "dashed", as it were. note that we don't
% currently attempt to get the z-order right for these
% new lines.
if ~isequal(marker, 'none')
	restore.h_mark = copyobj(h_line, h_axis);
	set(restore.h_mark, 'linestyle', 'none');
	set(restore.h_supp, 'marker', 'none');
else
	restore.h_mark = [];
end

% hide the original line. this line remains in existence so
% that if there is a legend, it doesn't get messed up.
set(h_line, 'xdata', NaN, 'ydata', NaN);

% extract pattern length
patlen = sum(dashes);

% position within pattern is initially zero
pos = 0;

% linedata
line_xy = complex(xdata, ydata);

% for each line segment
while length(line_xy) > 1
	
	% get line segment
	xy = line_xy(1:2);
	line_xy = line_xy(2:end);
	
	% any NaNs, and we're outta here
	if any(isnan(xy))
		continue
	end
	
	% get start etc.
	O = xy(1);
	V = xy(2) - xy(1);
	
	% get mm length of this line segment
	d = sqrt(sum(([real(V) imag(V)] .* sc) .^ 2));
	
	% and mm unit vector
	U = V / d;
	
	% generate a long-enough pattern for this segment
	n = ceil((pos + d) / patlen);
	pat = [0 cumsum(repmat(dashes, [1 n]))] - pos;
	pos = d - (pat(end) - patlen);
	pat = [pat(1:2:end-1); pat(2:2:end)];
	
	% trim spurious segments
	pat = pat(:, any(pat >= 0) & any(pat <= d));
	
	% skip if that's it
	if isempty(pat)
		continue
	end
	
	% and reduce ones that are oversized
	pat(1) = max(pat(1), 0);
	pat(end) = min(pat(end), d);

	% finally, add these segments to the line data
	seg = [O + pat * U; NaN(1, size(pat, 2))];
	data = [data seg(:).'];
	
end

% update line
set(restore.h_supp, 'xdata', real(data), 'ydata', imag(data), ...
	'linestyle', '-');

end


function linestyle = dashstyle_parse_linestyle(linestyle)

if isequal(linestyle, 'none') || isequal(linestyle, '-')
	linestyle = [];
	return
end

while 1

	% if numbers
	if isnumeric(linestyle)
		if ~isa(linestyle, 'double') || ~isrow(linestyle) || mod(length(linestyle), 2) ~= 0
			break
		end
		% no need to parse
		return
	end

	% else, must be char
	if ~ischar(linestyle) || ~isrow(linestyle)
		break
	end
	
	% translate matlab non-standard codes into codes we can
	% easily parse
	switch linestyle
		case ':'
			linestyle = '.';
		case '--'
			linestyle = '-';
	end
	
	% must be only - and .
	if any(linestyle ~= '.' & linestyle ~= '-')
		break
	end
	
	% transcribe
	c = linestyle;
	linestyle = [];
	for l = c
		switch l
			case '-'
				linestyle = [linestyle 2 0.75];
			case '.'
				linestyle = [linestyle 0.5 0.75];
		end
	end
	return

end

warning('panel:BadFixdashLinestyle', 'unusable linestyle in fixdash()');
linestyle = [];

end



% MISCELLANEOUS

function index = isin(list, value)

for i = 1:length(list)
	if strcmp(value, list{i})
		index = i;
		return
	end
end

index = 0;

end

function dim = flippackdim(dim)

% this function, used between arguments in a recursive call,
% causes the dim to be switched with each recurse, so that
% we build a grid, rather than a long, long row.
dim = 3 - dim;

end



% STRING PADDING FUNCTIONS

function s = rpad(s, l)

if nargin < 2
	l = 16;
end

if length(s) < l
	s = [s repmat(' ', 1, l - length(s))];
end

end

function s = lpad(s, l)

if nargin < 2
	l = 16;
end

if length(s) < l
	s = [repmat(' ', 1, l - length(s)) s];
end

end



% HANDLE GRAPHICS HELPERS

function h = getParentFigure(h)

if strcmp(get(h, 'type'), 'figure')
	return
else
	h = getParentFigure(get(h, 'parent'));
end

end

function addHandleCallback(h, name, func)

% % get current list of callbacks
% callbacks = get(h, name);
%
% % if empty, turn into a cell
% if isempty(callbacks)
% 	callbacks = {};
% elseif iscell(callbacks)
% 	% only add ourselves once
% 	for c = 1:length(callbacks)
% 		if callbacks{c} == func
% 			return
% 		end
% 	end
% else
% 	callbacks = {callbacks};
% end
%
% % and add ours (this is friendly, in case someone else has a
% % callback attached)
% callbacks{end+1} = func;
%
% % lay in
% set(h, name, callbacks);

% the above isn't as simple as i thought - for now, we'll
% just stamp on any existing callbacks
set(h, name, func);

end

function store = storeAxisState(h)

% LOCK TICKS AND LIMITS
%
% (LOCK TICKS)
%
% lock state so that the ticks and labels do not change when
% the figure is resized for printing. this is what the user
% will expect, which is why we go through this palaver.
%
% however, for fuck's sake. the following code illustrates
% an idiosyncrasy of matlab (i would call this an
% inconsistency, myself, but there you go).
%
% figure
% axis([0 1 0 1])
% set(gca, 'ytick', [-1 0 1 2])
% get(gca, 'yticklabel')
% set(gca, 'yticklabelmode', 'manual')
%
% now, resize the figure window. at least in R2011b, the
% tick labels change on the first resize event. presumably,
% this is because matlab treats the ticklabel value
% differently depending on if the ticklabelmode is auto or
% manual. if it's manual, the value is used as documented,
% and [0 1] is used to label [-1 0 1 2], cyclically.
% however, if the ticklabelmode is auto, and the ticks
% extend outside the figure, then the ticklabels are set
% sensibly, but the _value_ of ticklabel is not consistent
% with what it would need to be to get this tick labelling
% were the mode manual. and, in a final bizarre twist, this
% doesn't become evident until the resize event. i think
% this is a bug, no other way of looking at it; at best it's
% an inconsistency that is either tedious or impossible to
% work around in the general case.
%
% in any case, we have to lock the ticks to manual as we go
% through the print cycle, so that the ticks do not get
% changed if they were in automatic mode. but we mustn't fix
% the tick labels to manual, since if we do we may encounter
% this inconsistency and end up with the wrong tick labels
% in the print out. i can't, at time of writing, think of a
% case where we'd have to fix the tick labels to manual too.
% the possible cases are:
%
% ticks auto, labels auto: in this case, fixing the ticks to
%		manual should be enough.
%
% ticks manual, labels auto: leave as is.
%
% ticks manual, labels manual: leave as is.
%
% the only other case is ticks auto, labels manual, which is
% a risky case to use, but in any case we can also fix the
% ticks to manual in that case. thus, our preferred solution
% is to always switch the ticks to manual, if they're not
% already, and otherwise leave things be.
%
% (LOCK LIMITS)
%
% the other thing that may get modified, if the user hasn't
% fixed it, is the axis limits. so we lock them too, any
% that are set to auto, and mark them for unlocking when the
% print is complete.

store = '';

% manual-ise ticks on any axis where they are currently
% automatic, and indicate that we need to switch them back
% afterwards.
if strcmp(get(h, 'XTickMode'), 'auto')
	store = [store 'X'];
	set(h, 'XTickMode', 'manual');
end
if strcmp(get(h, 'YTickMode'), 'auto')
	store = [store 'Y'];
	set(h, 'YTickMode', 'manual');
end
if strcmp(get(h, 'ZTickMode'), 'auto')
	store = [store 'Z'];
	set(h, 'ZTickMode', 'manual');
end

% manual-ise limits on any axis where they are currently
% automatic, and indicate that we need to switch them back
% afterwards.
if strcmp(get(h, 'XLimMode'), 'auto')
	store = [store 'x'];
	set(h, 'XLimMode', 'manual');
end
if strcmp(get(h, 'YLimMode'), 'auto')
	store = [store 'y'];
	set(h, 'YLimMode', 'manual');
end
if strcmp(get(h, 'ZLimMode'), 'auto')
	store = [store 'z'];
	set(h, 'ZLimMode', 'manual');
end

% % OLD CODE OBSOLETED 25/01/12 - see notes above
% 
% % store current state
% store.XTick = get(h, 'XTick');
% store.XTickMode = get(h, 'XTickMode');
% store.XTickLabel = get(h, 'XTickLabel');
% store.XTickLabelMode = get(h, 'XTickLabelMode');
% store.YTickMode = get(h, 'YTickMode');
% store.YTick = get(h, 'YTick');
% store.YTickLabel = get(h, 'YTickLabel');
% store.YTickLabelMode = get(h, 'YTickLabelMode');
% store.ZTick = get(h, 'ZTick');
% store.ZTickMode = get(h, 'ZTickMode');
% store.ZTickLabel = get(h, 'ZTickLabel');
% store.ZTickLabelMode = get(h, 'ZTickLabelMode');
% 
% % lock state to manual
% set(h, 'XTickLabelMode', 'manual');
% set(h, 'XTickMode', 'manual');
% set(h, 'YTickLabelMode', 'manual');
% set(h, 'YTickMode', 'manual');
% set(h, 'ZTickLabelMode', 'manual');
% set(h, 'ZTickMode', 'manual');

end

function restoreAxisState(h, store)

% unmanualise
for item = store
	switch item
		case {'X' 'Y' 'Z'}
			set(h, [item 'TickMode'], 'auto');
		case {'x' 'y' 'z'}
			set(h, [upper(item) 'TickMode'], 'auto');
	end
end

% % OLD CODE OBSOLETED 25/01/12 - see notes above
% 
% % restore passed state
% set(h, 'XTick', store.XTick);
% set(h, 'XTickMode', store.XTickMode);
% set(h, 'XTickLabel', store.XTickLabel);
% set(h, 'XTickLabelMode', store.XTickLabelMode);
% set(h, 'YTick', store.YTick);
% set(h, 'YTickMode', store.YTickMode);
% set(h, 'YTickLabel', store.YTickLabel);
% set(h, 'YTickLabelMode', store.YTickLabelMode);
% set(h, 'ZTick', store.ZTick);
% set(h, 'ZTickMode', store.ZTickMode);
% set(h, 'ZTickLabel', store.ZTickLabel);
% set(h, 'ZTickLabelMode', store.ZTickLabelMode);

end



% DIM AND EDGE HANDLING

% we describe each edge of a panel in terms of "dim" (1 or
% 2, horizontal or vertical) and "edge" (1 or 2, former or
% latter). together, [dim edge] is an "edgespec".

function s = edgestr(edgespec)

s = 'lbrt';
s = s(edgeindex(edgespec));

end

function i = edgeindex(edgespec)

% edge indices. margins are stored as [l b r t] but
% dims are packed left to right and top to bottom, so
% relationship between 'dim' and 'end' and index into
% margin is non-trivial. we call the index into the margin
% the "edgeindex". an "edgespec" is just [dim end], in a
% single array.
i = [1 3; 4 2];
i = i(edgespec(1), edgespec(2));

end



% VARIABLE TYPE HELPERS

function val = validate_par(val, argtext, varargin)

% this helper validates arguments to some functions in the
% main body

for n = 1:length(varargin)
	
	% get validation constraint
	arg = varargin{n};
	
	% handle string list
	if iscell(arg)
		% string list
		if ~isin(arg, val)
			error('panel:InvalidArgument', ...
				['invalid argument "' argtext '", "' val '" is not a recognised data value for this option']);
		end
		continue;
	end
	
	% handle strings
	if isstring(arg)
		switch arg
			case 'empty'
				if ~isempty(val)
					error('panel:InvalidArgument', ...
						['invalid argument "' argtext '", option does not expect any data']);
				end
			case 'dimension'
				if ~isdimension(val)
					error('panel:InvalidArgument', ...
						['invalid argument "' argtext '", option expects a dimension']);
				end
			case 'scalar'
				if ~(isnumeric(val) && isscalar(val) && ~isnan(val))
					error('panel:InvalidArgument', ...
						['invalid argument "' argtext '", option expects a scalar value']);
				end
			case 'nonneg'
				if any(val(:) < 0)
					error('panel:InvalidArgument', ...
						['invalid argument "' argtext '", option expects non-negative values only']);
				end
			case 'integer'
				if any(val(:) ~= round(val(:)))
					error('panel:InvalidArgument', ...
						['invalid argument "' argtext '", option expects integer values only']);
				end
		end
		continue;
	end
	
	% handle numeric range
	if isnumeric(arg) && isofsize(arg, [1 2])
		if any(val(:) < arg(1)) || any(val(:) > arg(2))
			error('panel:InvalidArgument', ...
				['invalid argument "' argtext '", option data must be between ' num2str(arg(1)) ' and ' num2str(arg(2))]);
		end
		continue;
	end
	
	% not recognised
	arg
	error('panel:InternalError', 'internal error - bad argument to validate_par (above)');
	
end

end

function b = checkpar(value, mn, mx)

b = isscalar(value) && isnumeric(value) && ~isnan(value);
if b
	if nargin >= 2
		b = b && value >= mn;
	end
	if nargin >= 3
		b = b && value <= mx;
	end
end

end

function b = isintegral(v)

b = all(all(v == round(v)));

end

function b = isstring(value)

sz = size(value);
b = ischar(value) && length(sz) == 2 && sz(1) == 1 && sz(2) >= 1;

end

function b = isdimension(value)

b = isa(value, 'double') && (isscalar(value) || isofsize(value, [1 4]));

end

function b = isscalardimension(value)

b = isa(value, 'double') && isscalar(value);

end

function b = isofsize(value, siz)

sz = size(value);
b = length(sz) == length(siz) && all(sz == siz);

end

function b = isaxis(h)

b = ishandle(h) && strcmp(get(h, 'type'), 'axes');

end

function validate_packspec(packspec)

	% stretchable
	if isempty(packspec)
		return
	end

	% scalar
	if isa(packspec, 'double') && isscalar(packspec)

		% fraction
		if packspec > 0 && packspec <= 1
			return
		end

		% percentage
		if packspec > 1 && packspec <= 100
			return
		end

	end

	% fixed
	if iscell(packspec) && isscalar(packspec)

		% delve
		d = packspec{1};
		if isa(d, 'double') && isscalar(d) && d > 0
			return
		end

	end

	% abs
	if isa(packspec, 'double') && isofsize(packspec, [1 4]) && all(packspec(3:4)>0)
		return
	end

	% otherwise, bad form
	error('panel:BadPackingSpecifier', 'the packing specifier was not valid - see help panel/pack');

end



