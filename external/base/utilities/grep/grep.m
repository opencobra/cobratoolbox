% GREP
%	  a unix-like, very fast utility to find patterns
%	  in any files in folders and their subfolders
%
% SYNTAX
%	  help
%			 GREP		show this screen
%			 GREP -p	show extended help for PATTERN/FILE
%			 GREP -f	show contents of output structure P
%			 GREP -e	show examples
%	  search
%			 GREP PATTERN FILE(*)
%			 GREP OPT1 ... OPTn PATTERN FILE(*)
%		[FL,P] = GREP(PATTERN,FILE(*))
%		[FL,P] = GREP({PATTERN(s)},{FILE1(*),...,FILEn(*)})
%		[FL,P] = GREP(OPT1,...,OPTn,PATTERN,FILE)
%		[FL,P] = GREP(OPT1,...,OPTn,{PATTERN(s)},{FILE1(*),...,FILEn(*)})
%
% OPT	: arg	processing
% ---------------------------------------------------------------------------------
% -c	:	prints only a count of the lines that contain the pattern(s)
% -D	:	debug mode: shows major processing steps
% -d	:	debug mode: shows all   processing steps
% -da	:	debug mode: shows all   output including debug messages
% -e	:  PL	searches for a string in pattern-list PL or {PL1,...,PLn}
%	: {PL}	useful syntax when the string contains an option flag character (-)
%		   multiple instances of <-e PL> and/or <-e {PL,...}> may be listed
%	   PL	   searches for the first token in pattern without white spaces
%	  {PL}	   searches for complete pattern(s) including white spaces
% -f	:  PF	takes the list of patterns from ASCII pattern-file PF
%		   each line defines a single pattern that may include white spaces
% -i	:	ignores upper/lower case distinction during comparisons
% -I?	:  IL	only includes folders/files with at least one matching pattern
%	  {IL}	   from IL or {IL1,...ILn}, which may include regular expressions
%		   multple instances of <-I? IL> and/or <I? {IL,...}> may be listed
%   -Id	:	searches for inclusions in folders
%   -If	:	searches for inclusions in file names
%   -Ip	:	searches for inclusions in full paths: folder/filename
% -l	:	prints the names of files with matching lines once
% -n	:	precedes each line by its line number in the file
% -Q	:	does not prefix output with file name
% -R	:	uses the regular expression engine <regexp> [def: <strfind>]
% -r	:	recursively searches in subfolder(s)
% -s	:	works silently and displays only error messages
% -u	:	does not produce underlined text
% -V	:	prints name of each file before it is searched
% -v	:	prints all lines except those that contain the pattern
% -x	:	prints only lines that are matched entirely
% -X?	:  XL	excludes folders/files with at least one matching pattern
%	  {XL}	   from XL or {XL1,...XLn}, which may include regular expressions
%		   multple instances of <-X? XL> and/or <X? {XL,...}> may be listed
%   -Xd	:	searches for exclusions in folders
%   -Xf	:	searches for exclusions in file names
%   -Xp	:	searches for exclusions in full paths: folder/filename
%
% NOTES		all folder separators are replaced by unix-style </> to facilitate
%		   the use of regular expressions with <-I?|X?> options
%		<-I?|X?> options allow wildcard searches using regular expressions
%		clicking on underlined text opens the file at the matching line

% created:
%	us	14-Jan-1987
% modified:
%	us	04-Apr-2006 00:31:57

%--------------------------------------------------------------------------------
function	[pout,p]=grep(varargin)

% program parameters
		tim=clock;
		ver='04-Apr-2006 00:31:57';

% option table
		com='command line';
	otbl={
%	flag	inival	nrpar	defpar	accum	desc
%	-----------------------------------------------------------------------------------------
	'-c'	false	0	[]	0	'count matches'
	'-D'	false	0	[]	0	'major proc steps'
	'-d'	false	0	[]	0	'minor proc steps'
	'-da'	false	0	[]	0	'show all ouput including proc steps'
	'-e'	false	1	{}	1	'pattern list'
	'-f'	false	1	com	0	'pattern file'
	'-i'	false	0	[]	0	'ignore case'
	'-Id'	false	1	{}	1	'only include folders with one matching token'
	'-If'	false	1	{}	1	'only include files with one matching token'
	'-Ip'	false	1	{}	1	'only include full paths with one matching token'
	'-l'	false	0	[]	0	'print file name'
	'-n'	false	0	[]	0	'print line number'
	'-Q'	false	0	[]	0	'no file name prefix'
	'-R'	false	0	[]	0	'regular expression engine'
	'-r'	false	0	[]	0	'search in subfolders'
	'-s'	false	0	[]	0	'quiet mode except error messages'
	'-u'	false	0	[]	0	'does not produce underlined text'
	'-V'	false	0	[]	0	'print file before search'
	'-v'	false	0	[]	0	'print non-matching lines'
	'-x'	false	0	[]	0	'complete match'
	'-Xd'	false	1	{}	1	'exclude folders with matching token'
	'-Xf'	false	1	{}	1	'exclude files with matching token'
	'-Xp'	false	1	{}	1	'exclude full paths with matching token'
	};

	if	nargout
		pout=[];
	end

% initialize engine
		p=ini_par(ver,tim);
		[p,msg]=set_opt(otbl,p,varargin{:});
	if	~isempty(msg)
		p=show_res(100,p,msg);
	if	nargout
		pout=p;
	end
		return;
	end
		p.npat=p.opt.ns;
		p.pattern=p.opt.pattern(:);
		p.porigin=p.opt.f.val;

% get subfolders
		p=show_res(-100,p,sprintf('GREP> searching folders    ...'));
		t1=clock;
		p=get_folders(p);
		p.runtime(2)=etime(clock,t1);
		p=show_res( -99,p,sprintf('GREP> done %13.3f   %d folder(s)',p.runtime(1),p.nfolder));

% get files
	if	p.nfolder
		p=show_res( -98,p,sprintf('GREP> searching files      ...'));
		t1=clock;
		p=get_files(p);
		p.runtime(3)=etime(clock,t1);
		p=show_res( -97,p,sprintf('GREP> done %13.3f   %d file(s)',p.runtime(2),p.nfiles));
	end

	if	nargout
		pout=unique(p.files);
	end
		p=ini_par(p);
		return;
%--------------------------------------------------------------------------------
%--------------------------------------------------------------------------------
% SUBROUTINES
%	- ehelp		extended help engine
%	- ini_par	initialize structure
%	- set_opt	input parser
%	- get_folders	harvest input folders
%	- get_folder	harvest subfolders/input folder
%	- get_files	harvest files/input folder
%	- get_file	harvest files
%	- chk_path	check file/folder inclusion/exclusion
%	- get_match	look for matches
%	- update	update arrays
%	- show_res	common display engine
%	- show_entry	final  display engine
%--------------------------------------------------------------------------------
%--------------------------------------------------------------------------------
function	p=ehelp(p,fnam,tag)

		[fp,msg]=fopen(which(fnam),'rt');
	if	fp > 0
		hs=fread(fp,inf,'*char').';
		fclose(fp);
		ib=strfind(hs,tag);
	if	isempty(ib)	||...
		numel(ib)<2
		hs=sprintf('GREP> help sectio <%s> not found/not valid',tag);
	else
		hs=hs(ib(end-1)+length(tag)+1:ib(end)-1);
		hs=strrep(hs,p.par.hdel,'');
	end
	else
		hs=sprintf('%s: <%s>',msg,fnam);
	end
		disp(hs);
		return;
%--------------------------------------------------------------------------------
function	p=ini_par(ver,tim)

% clean up
	if	isstruct(ver)
		p=ver;
		tim=p.par.tim;
		p.nxfolder=p.par.chkex(1);
		p.nxfiles=p.par.chkex(2);
		p.nafolder=p.nfolder+p.nxfolder;
		p.nafiles=p.nfiles+p.nxfiles;
		p.mdepth=max(p.fdepth);
	if	~isempty(p.result)
		p.result=char(p.result);
	end
	if	~p.opt.D.flg	&&...
		~p.opt.d.flg
		p=rmfield(p,'par');
	end
		p.runtime(1)=etime(clock,tim);
		return;
	end

% initialize common structure
% - parameters
		magic='GREP';
		fsep='/';

% - special characters
%   - EOL UNIX		= LF
%   - EOL WINDOWS	= CR+LF
		par.tab=sprintf('\t');	% 009 = TAB: horizontal tab
		par.cr=sprintf('\r');	% 013 =  CR: carriage return
		par.lf=sprintf('\n');	% 010 =  LF: line feed
		par.fsep=fsep;
		par.isold=0;
		par.nbytes=0;
		par.nlines=0;
		par.mfc=1;
		par.mlc=1;
		par.cd=[];
		par.cf=[];
		par.cn=[];
		par.cs=[];
		par.s=[];
		par.eol=[];
		par.chkpath=false;	% true if I[]/X[] flags are set
		par.chkex=[0,0];
		par.hasmatch=false;
		par.nmatch=0;
		par.hdel='%$';
		par.reft='<a href="matlab:opentoline(''%s'',%-1d)">%s</a>: %s';
		par.tim=tim;

% ID
		p.magic=magic;
		p.ver=ver;
		p.mver=version;
		p.rundate=datestr(tim);
		p.runtime=[0,0,0];
% parameters/options
		p.opt=[];
		p.msg=[];
		p.par=par;

		p.section_1='===== FOLDERS  =====';
		p.nfolder=0;
		p.nxfolder=0;
		p.nafolder=0;
		p.folder{1,1}=[];
		p.fenum=[];
		p.mdepth=0;
		p.fdepth(1,1)=0;
		p.section_2='===== PATTERNS =====';
		p.npat=0;
		p.pattern={};
		p.porigin={};
		p.section_3='===== FILES    =====';
		p.nfiles=0;
		p.nxfiles=0;
		p.nafiles=0;
		p.nbytes=0;
		p.nlines=0;
		p.section_4='===== MATCHES  =====';
		p.mfiles=0;
		p.mbytes=0;
		p.mlines=0;
		p.pfiles=0;
		p.pcount=0;
		p.files={};
		p.lcount=[];
		p.findex=[];
		p.pindex=[];
		p.line=[];
		p.match={};
		p.result={};
		return;
%--------------------------------------------------------------------------------
function	[p,msg]=set_opt(otbl,p,varargin)

		o=[];
		msg=[];

% set options
% ...default options
		o.des1='===== OPTIONS =====';
	for	i=1:size(otbl,1)
		fn=otbl{i,1}(2:end);
		o.(fn).flg=otbl{i,2};
		o.(fn).acc=otbl{i,5};
		o.(fn).des=otbl{i,6};
		o.(fn).def=otbl{i,4};
		o.(fn).val=otbl{i,4};
	end

		argn=numel(varargin);
	if	argn < 2
	if	~argn
		help(mfilename);
		msg=sprintf('GREP> needs at least two arguments');
	elseif	numel(varargin{1}) > 1
	switch	lower(varargin{1}(1:2))
	case	{'-p'}
		ehelp(p,mfilename,'___FORMAT___');
		msg=true;
	case	{'-e'}
		ehelp(p,mfilename,'___EXAMPLE___');
		msg=true;
	case	{'-f'}
		ehelp(p,mfilename,'___OUTPUT___');
		msg=true;
	otherwise
		help(mfilename);
		msg=sprintf('GREP> needs at least two arguments');
	end
	else
		help(mfilename);
		msg=sprintf('GREP> needs at least two arguments');
	end
		p.opt=o;
		return;
	end

% ...user defined options
% ...must account for syntax of various forms
%	('-a -b +c -d','-f',xxx,'-g +h',...)

% ...reconstruct <varargin> as a string
		pat=sprintf('GREP>ARG|%20.19f[',rand);
		arg=varargin;
		ic=cellfun(@(x) [pat,class(x),']'],arg,'uniformoutput',false);
		il=cellfun('isclass',arg,'char');
		ic(il)=arg(il);
		ic=sprintf('%s ',ic{:});
		ic=strread(ic,'%s');
		[ox,io]=ismember(ic,otbl(:,1));		%#ok MLINT 2006a
		ox=io(io>0);
		ax=find(io);
		argn=numel(ic);
		iv=strfind(ic,pat);
		iv=~cellfun('isempty',iv);
		ic(iv)=arg(~il);

	for	i=1:numel(ox)
		ix=ox(i);
		fn=otbl{ix,1}(2:end);
		o.(fn).flg=xor(otbl{ix,2},1);
	if	otbl{ix,3} > 0
		vx=ax(i)+1:ax(i)+otbl{ix,3};
	if	vx(end) <= argn
	if	o.(fn).acc
	if	~iscell(ic(vx))
		ic(vx)={ic(vx)};
		o.(fn).val=[o.(fn).val;{ic(vx)}];
	else
		o.(fn).val=[o.(fn).val,ic{vx}];
	end
	else
		o.(fn).val=ic(vx);
	end
	else
		o.(fn).flg=otbl{ix,2};
		msg=sprintf('GREP> parameter(s) missing for option <%s> [%-1d]',...
				otbl{ix,1},otbl{ix,3});
	end
	end
	end

	if	o.Id.flg	||...
		o.If.flg	||...
		o.Ip.flg	||...
		o.Xd.flg	||...
		o.Xf.flg	||...
		o.Xp.flg
		p.par.chkpath=true;
	end

% get search template(s)/file(s)
% ...templates
		o.des2='===== INPUT =====';
		o.arg={};
		o.ns=0;
		o.pattern=varargin{end-1};
		o.nf=0;
		o.files=varargin{end};

	if	~iscell(o.pattern)
		o.pattern={o.pattern};
	end
	if	o.e.flg
		o.pattern=o.e.val;
	end
	if	o.f.flg
	if	iscell(o.f.val{1})
		o.f.val{1}=o.f.val{1}{:};
	end
		pnam=o.f.val{1};
	if	exist(pnam,'file')
		o.pattern=textread(pnam,'%s','delimiter','\n','whitespace','');
	else
		msg=sprintf('GREP> pattern file not existing <%s>',pnam);
	end
	end
		o.ns=numel(o.pattern);
		o.arg=ic;

% ...files
	if	~iscell(o.files)
		o.files={o.files};
	end
		o.files=o.files(:);
		o.ns=numel(o.pattern);
		o.nf=numel(o.files);

	for	i=1:o.nf
	if	isempty(o.files{i})
		o.files{i}=[cd,p.par.fsep,'*.*'];
	end
	if	o.files{i}(end)=='/'	||...
		o.files{i}(end)=='\'
		o.files{i}=o.files{i}(1:end-1);
	end
		o.fpat{i}=o.files{i};
		o.fnam{i}='*.*';
		o.fext{i}='.*';
	if	strcmp(o.fpat{i},'.')
		o.fpat{i}=cd;
	end
	if	~exist(o.files{i},'dir')
		[o.fpat{i},o.fnam{i},o.fext{i}]=fileparts(o.files{i});
	if	isempty(o.fpat{i})
		o.fpat{i}=cd;
	end
	if	isempty(o.fnam{i})
		o.fnam{i}='*';
	end
	if	isempty(o.fext{i})
		o.fext{i}='.*';
	end
		o.fnam{i}=[o.fnam{i},o.fext{i}];
	end
	end

% ...remove dup folders
		o.npat=0;
		o.xpat=1;
		o.upat=1;
		[o.fpat,ix]=sort(o.fpat(:));
		o.files=o.files(ix);
		o.fnam=o.fnam(ix);
		o.fext=o.fext(ix);
		[o.npat,o.npat,o.xpat]=unique(o.fpat);
		o.npat=numel(o.npat);
		o.upat=find([1;diff(o.xpat)]>0);

		p.opt=o;
		return;
%--------------------------------------------------------------------------------
function	p=get_folders(p)

	for	i=1:p.opt.npat
		cf=p.opt.fpat{p.opt.upat(i)};
		cf=strrep(cf,filesep,p.par.fsep);
		p=get_folder(p,cf,cf,0,i);
	end
		return;
%--------------------------------------------------------------------------------
function	p=get_folder(p,frot,crot,depth,ix)

% recursively find all subfolders of a root
% note	we CANNOT use <genpath> as it does not return all subfolders!
%	eg,
%	- @class  subfolders
%	- private subfolders

% root folders
	if	~depth
		p=show_res(-10,p,sprintf('GREP> folder              <%s>',frot));
	if	exist(frot,'dir')
		[tf,p]=chk_path(1,p,frot,'***FOLDER***');
	if	tf
		p.nfolder=p.nfolder+1;
		p.folder{p.nfolder,1}=strrep(frot,filesep,p.par.fsep);
		p.fenum(p.nfolder,1)=ix;
	end
	else
		msg=sprintf('GREP> folder not found <%s>',frot);
		p=show_res(100,p,msg);
	end
	end

	if	~p.opt.r.flg
		return;
	end

% subfolders
		rd=dir(crot);
		rx=[rd.isdir]==1;
		rd=rd(rx);
		nd=numel(rd);
	for	i=1:nd
	if	rd(i).isdir && ~all(rd(i).name=='.')	% rd(i).name(1) ~= '.'
	if	~isempty(crot)
		nrot=[crot,p.par.fsep,rd(i).name];
	else
		nrot=rd(i).name;
	end
		nrot=strrep(nrot,filesep,p.par.fsep);
		[tf,p]=chk_path(1,p,nrot,'***SUBFOLDER***');
	if	tf
		p.nfolder=p.nfolder+1;
		depth=depth+1;
		p.fdepth(p.nfolder,1)=depth;
		p.folder{p.nfolder,1}=strrep(nrot,filesep,p.par.fsep);
		p.fenum(p.nfolder,1)=ix;
		p=show_res(-9,p,sprintf('- subfolder %5d/%6d  <%s>',depth,p.nfolder,nrot));
		p=get_folder(p,frot,nrot,depth,ix);
		depth=depth-1;
	end
	end
	end
	if	~depth
		p.par.isold=0;
	end
		return;
%--------------------------------------------------------------------------------
function	p=get_files(p)

	for	i=1:p.opt.nf
		cn=p.opt.fnam{i};
		fx=find(p.fenum==p.opt.xpat(i));
		cp=p.folder(fx);
	for	j=1:numel(fx)
		p.par.cd=cp{j};
		p=show_res(-8,p,sprintf('GREP> files %5d/%7d <%s:%s>',i,j,p.par.cd,cn));
		d=dir([p.par.cd,p.par.fsep,cn]);
	if	~isempty(d)
	for	k=1:numel(d)
	if	~d(k).isdir
		p.par.cf=[p.par.cd,p.par.fsep,d(k).name];
		p.par.cn=d(k).name;
		[tf,p]=chk_path(2,p,p.par.cf,p.par.cn);
	if	tf
		p=show_res(-7,p,sprintf('- file	  %7d/%7d <%s>',k,numel(d),p.par.cf));
		p=get_file(p);
	end
	end
	end
	end
	end
	end
		return;
%--------------------------------------------------------------------------------
function	p=get_file(p)

%D	if	exist(p.par.cf,'file')
		[fp,msg]=fopen(p.par.cf,'rb');
	if	fp < 0
		msg=sprintf('GREP> cannot open file <%s>\nGREP> %s',p.par.cf,msg);
		p=show_res(100,p,msg);
	else
		p.par.s=fread(fp,inf,'*char').';
		fclose(fp);
		p.par.nbytes=numel(p.par.s);
	if	ispc
		p.par.s=strrep(p.par.s,[p.par.cr,p.par.lf],p.par.lf);
	end
		p.par.s=strrep(p.par.s,char(0),'^');
		p=show_res(2,p);
		p=get_match(p);
	end
%D	end
		return;
%--------------------------------------------------------------------------------
function	[tf,p]=chk_path(mode,p,fnam,frot)

		tf=true;
% - escape immediately if user did not choose inclusion/exclusion flags
	if	~p.par.chkpath
		return;
	end

		ixi=true;
		ixe=false;
	switch	mode
% include/exclude folders
	case	1
		smode='FOLDER';
	if	p.opt.Id.flg
		ix=regexp(fnam,p.opt.Id.val);
		ixi=any(~cellfun('isempty',ix));
	end
	if	ixi
	if	p.opt.Xd.flg
		ix=regexp(fnam,p.opt.Xd.val);
		ixe=any(~cellfun('isempty',ix));
	end
	end
% incrementally include/exclude files/full paths
	case	2
		smode='FILE';
	if	p.opt.If.flg
		ix=regexp(frot,p.opt.If.val);
		ixi=any(~cellfun('isempty',ix));
	end
	if	ixi
	if	p.opt.Xf.flg
		ix=regexp(frot,p.opt.Xf.val);
		ixe=any(~cellfun('isempty',ix));
	end
	if	~ixe
		smode='PATH';
	if	p.opt.Ip.flg
		ix=regexp(fnam,p.opt.Ip.val);
		ixi=any(~cellfun('isempty',ix));
	end
	if	ixi
	if	p.opt.Xp.flg
		ix=regexp(fnam,p.opt.Xp.val);
		ixe=any(~cellfun('isempty',ix));
	end	% does not match PATH Xp
	end	% does not macht PATH Ip
	end	% does not match FILE Xf
	end	% does not match FILE If

	end	% switch

	if	~ixi		||...
		ixe
		p.par.chkex(mode)=p.par.chkex(mode)+1;
		p=show_res(-50,p,sprintf('* exclude %7.7s         <%s>',smode,fnam));
		tf=false;
	end
		return;
%--------------------------------------------------------------------------------
function	p=get_match(p)

		p.par.hasmatch=false;
		s=p.par.s;
	if	p.opt.i.flg
		s=lower(s);
	end
% find EOL marker(s)
		p.par.eol=[0,strfind(s,p.par.lf),numel(s)+1];
		p.par.nlines=numel(p.par.eol)-2;
		p.nfiles=p.nfiles+1;
		p.nbytes=p.nbytes+p.par.nbytes;
		p.nlines=p.nlines+p.par.nlines;

	for	j=1:p.opt.ns
		str=p.opt.pattern{j};
	if	p.opt.i.flg
		str=lower(str);
	end
		p.par.cs=str;

% find string pattern <str>
	if	p.opt.R.flg
		ix=regexp(s,str);
	else
		ix=strfind(s,str);
	end

		p.par.nmatch=0;
	if	~isempty(ix)

% ...find line(s)
		[lx,lx]=histc(ix,p.par.eol);	%#ok MLINT 2006a
		lx=lx(find([diff(lx),1]));	%#ok MLINT 2006a

% ...-v: only print non-matching lines
	if	p.opt.v.flg
		tl=1:numel(p.par.eol)-2;
		ll=tl~=0;
		ll(lx)=false;
		lx=tl(ll);
	end

		nx=numel(lx);
	if	nx
		p=show_res(-2,p,lx,0);
	for	i=1:nx
		sx=p.par.eol(lx(i))+1:p.par.eol(lx(i)+1)-1;
		nl=lx(i);
		nm=p.par.s(sx);

% ...-x: only print fully matching lines
	if	~p.opt.x.flg	||...
		numel(sx)==numel(str)
		p.par.nmatch=p.par.nmatch+1;
		p=show_res(3,p,nl,nm);
	if	~p.opt.c.flg	||...
		i==1
		p=update(3,p,nl,nm);
	end
	end
	end	% each	match
	end	% found match
	end	% found matches

	if	p.par.nmatch
		p.par.hasmatch=true;
		p.pfiles=p.pfiles+1;
		p.pcount=p.pcount+nx;
		p.files(p.pfiles,1)={p.par.cf};
		p.lcount(p.pfiles,1)=nx;
		p.findex=[p.findex;repmat(p.pfiles,nx,1)];
		p.pindex=[p.pindex;repmat(j,nx,1)];
	if	p.opt.c.flg
		p=show_res(4,p);
	end
	end

	end	% for each <string>

	if	p.par.hasmatch
		p.mfiles=p.mfiles+1;
		p.mbytes=p.mbytes+p.par.nbytes;
		p.mlines=p.mlines+p.par.nlines;
	end

		return;
%--------------------------------------------------------------------------------
function	p=update(mode,p,varargin)

	switch	mode
	case	3
		p.line(p.par.mlc,1)=varargin{1};
		p.match(p.par.mlc,1)={varargin{2}};
		p.par.mlc=p.par.mlc+1;
	case	4
		p.result(p.par.mfc,1)={varargin{1}};
		p.par.mfc=p.par.mfc+1;
	end
		return;
%--------------------------------------------------------------------------------
function	p=show_res(mode,p,varargin)

% common output engine

%	mode	display entity
%	-100	subfolder engine start
%	-99	subfolder engine end
%	-98	match engine start
%	-97	match engine end
%	-50	exclude folder/file
%	-10	folder
%	-9	subfolder
%	-8	current folder
%	-7	current file
%	-2	match
%	2	file before search
%	3	line
%	4	line count only
%	100	error message

% display all ouput
		if	p.opt.da.flg
			p=show_entry(mode,p,varargin{:});
			return;
		end

% display selected ouput only
		if	p.opt.s.flg	&&...
			mode < 100
			return;
		else
		if	mode < -10
		if	~p.opt.D.flg	&&...
			~p.opt.d.flg
			return;
		end
		elseif	mode < 0
		if	~p.opt.d.flg
			return;
		end
		end
		end
			p=show_entry(mode,p,varargin{:});
			return;
%--------------------------------------------------------------------------------
function	p=show_entry(mode,p,varargin)

			str=[];
			txt=[];		%#ok MLINT 2006a
			ref=[];
	switch	mode
	case	{-100 -99 -98 -97 -50 -10 -9 -8 -7}
			str=varargin{1};
	case	-2
			str=sprintf('+ match  %16d <%s>',numel(varargin{1}),p.par.cf);
	case	2
		if	p.opt.V.flg
			str=sprintf('%s',p.par.cf);
		end
	case	3
		if	p.opt.l.flg	&&...
			p.par.nmatch==1
			str=sprintf('%s [%s]',p.par.cf,p.par.cs);
		end
		if	~p.opt.c.flg
		if	p.opt.D.flg	||...
			p.opt.d.flg
			ref=sprintf('%17d',varargin{1});
			txt=sprintf('%17d:	  <%s>',varargin{1},varargin{2});
		elseif	p.opt.n.flg	&&...
			~p.opt.Q.flg
			ref=sprintf('%s:%-1d',p.par.cn,varargin{1});
			txt=sprintf('%s:%-1d: %s',p.par.cn,varargin{1},varargin{2});
		elseif	p.opt.n.flg	&&...
			p.opt.Q.flg
			ref=sprintf('%-1d',varargin{1});
			txt=sprintf('%-1d: %s',varargin{1},varargin{2});
		elseif	~p.opt.Q.flg
			ref=sprintf('%s',p.par.cn);
			txt=sprintf('%s: %s',p.par.cn,varargin{2});
		else
			txt=sprintf('%s',varargin{2});
		end
		if	~isempty(ref)
		if	~p.opt.u.flg
			txt=sprintf(p.par.reft,p.par.cf,varargin{1},ref,varargin{2});
		end
		end
		if	~isempty(str)
			str=str2mat(str,txt);
		else
			str=txt;
		end
		end
	case	4
		if	p.opt.c.flg
			str=sprintf('%-d',p.lcount(p.pfiles));
		end
	case	100
			p.msg=varargin{1};
		if	ischar(p.msg)
			str=p.msg;
		end
	end

		if	~isempty(str)
			p=update(4,p,str);
			disp(str);
		end
			return;
%--------------------------------------------------------------------------------
%--------------------------------------------------------------------------------
% EXTENDED HELP SECTION
%	formatted for pretty output
%	do NOT change alignment
%--------------------------------------------------------------------------------
%	BOL delimiter	%$
%	tag		contents
%	___FORMAT___	input formats
%	___OUTPUT___	P.field explanations
%	___EXAMPLE___	examples

%{
%$___FORMAT___
%$  SYNTAX
%$			 grep PATTERN FILE
%$			 grep OPT1 ... OPTn PATTERN FILE
%$		[FL,P] = grep(PATTERN,FILE)
%$		[FL,P] = grep({PATTERN(s)}, {FILE(s)})
%$		[FL,P] = grep(OPT1, ..., OPTn, PATTERN, FILE)
%$		[FL,P] = grep(OPT1,...,OPTn,{PATTERN(s)},{FILE(s)})
%$
%$  input arguments/formats
%$  ---------------------------------------------------------------------------------
%$  OPT
%$  ---------------------------------------------------------------------------------
%$	for available options,
%$	see <grep> or <help grep>
%$
%$	any mixture of	...,'-a -b -d','-k','-y -z',...
%$
%$	note	the input parser will tokenize strings
%$		   into single options and other arguments
%$		   see: <P.opt.arg> for parsing results
%$
%$	special cases
%$
%$	-e	'-e -l'
%$		add pattern <-l> AND	set option [-l]
%$		'-e',{'-n'}
%$		add pattern <-n> do NOT set option [-n]
%$	-e	'this is'
%$		by definition will only search for <this>
%$	-e	{'this is','a test'}
%$		will first search for <this is>
%$		than <a test>
%$	-s	silent mode will run much(!) faster
%$		results can easily be extracted from P
%$		see: <grep -f> for information
%$
%$	inclusion/exclusion of folder(s)/file(s)/full path(s)
%$
%$		assume this folder/file structure/contents
%$			z:/abc/def/ghi/foo.m
%$			z:/abc/def/ghi/foo.txt
%$			z:/abc/def/ghi/goo.p
%$			z:/abc/def/xxy/goo.p
%$			z:/abc/def/xxy/goo.txt
%$		assume this root folder when running GREP
%$			z:/abc/def
%$		assume the recursion flag [-r] is set
%$
%$	-Id	'/xx'
%$		only searches in folder
%$			z:/abc/def/xxy	... all files
%$	-Id	'xx'
%$	-If	'\.t'	(note regular expression for <.>)
%$		***or***
%$	-Ip	'y/g.*\.t'
%$		only searches in folder/file
%$			z:/abc/def/xxy/goo.txt
%$	-Xd	'(de)|(xx)'
%$		does not search any folder/file
%$	-Xd	'x'
%$		only searches in folder
%$			z:/abc/def/ghi	... all files
%$	-Xd	'x'
%$	-Xf	'txt'
%$		only searches in folder/files
%$			z:/abc/def/ghi/foo.m
%$			z:/abc/def/ghi/goo.p
%$	-Xd	'xxx'
%$	-If	'foo'
%$		***or***
%$	-Ip	'ghi/fo'
%$		only searches in folder/files
%$			z:/abc/def/ghi/foo.m
%$			z:/abc/def/ghi/foo.txt
%$
%$	note
%$		ALL folder separators are replaced by
%$		   unix-style </> for entry checks to
%$		   facilitate the use of regular expression
%$		leading/trailing </>s are significant
%$		inclusions and exclusions are ANDed, but single tokens
%$		   within an option are OREed for final results
%$		multiple inclusions/exclusions may be
%$		   listed in any order
%$		using <-Ip> and <-Xp> only may be significantly slower
%$		   compared to combinations of <-I[df]> and <-X[df]>
%$		since folders are resolved sequentially in depth, <-Xd>
%$		   options will exclude any subfolder below the
%$		   excluded folder(s)
%$
%$  PATTERN
%$  ---------------------------------------------------------------------------------
%$	 'p1'		will search	 <p1> in each FILE
%$	{'p1',...,'pn'} will search each <px> in each FILE
%$
%$	note	 'p1' cannot include white spaces
%$		{'p1'}   may include white spaces
%$		<px> may be a regular expression [-R]
%$		only one input type will be used at runtime
%$		precedence: 1. -f / 2. -e / 3. PATTERN
%$
%$  FILE
%$  ---------------------------------------------------------------------------------
%$	 'f1'		will search in	    folder/file <f1>
%$	{'f1',...,'fn'} will search in each folder/file <fx>
%$
%$	folder/file(s) are determined/expanded according to these rules
%$
%$	FILE		folder	file	remark
%$	----------------------------------------------------------
%$	f*.x		./	f*.x	uses current folder
%$	/a/b		/a/b/	*.*	search all files in folder
%$	/a/b/		/a/b/	*.*	search all files in folder
%$	/a/b/*		/a/b/	*.*	search all files in folder
%$	/a/b/*.x	/a/b/	*.x	search all  <.x> in folder
%$	/a/b/f		/a/b/	f*.*	if <f> is NOT a folder
%$	/a/b/f*.x	/a/b/	f*.x
%$
%$	note	if recursive folder search is selected [-r],
%$		   file(s) will be searched in the root path and
%$		   its subfolder(s)
%$		the recursion engine does NOT use <genpath>
%$		use the <-I?> and <-X?> options to use wildcard
%$		   searches on folders/files
%$
%$  output arguments
%$  ---------------------------------------------------------------------------------
%$  FL	cell array with unique list of files with matching patterns
%$  P	structure  with timing and result of the engines (for programmers)
%$	see: <grep -f> for information about .fields
%$___FORMAT___

%$___OUTPUT___
%$  SYNTAX
%$			[FL,P] = grep(...)
%$
%$  output arguments
%$  ---------------------------------------------------------------------------------
%$  FL          cell array with unique list of files with matching patterns
%$  P           structure  with timings and result of the engines (for programmers)
%$
%$  P.fieldname:  contents              explanation
%$  ---------------------------------------------------------------------------------
%$        magic:  'GREP'                magic id
%$          ver:   char                 current GREP version
%$         mver:   char                 current ML   version
%$      rundate:   char                 datestr(clock)
%$      runtime:  [t1 t2 t3]            runtimes [sec]:
%$                                      - t1: full time spent in grep
%$                                      - t2: engine for (sub)folder(s)
%$                                      - t3: engine for pattern matching
%$          opt:  [struct]              current options and input args
%$          msg:   char                 error message(s)
%$    section_1:  '===== FOLDERS  ='    FOLDER STATS
%$      nfolder:   double               nr of unique folder(s) found
%$     nxfolder:   double               nr of excluded (sub)folder(s) [-Id|Xd]
%$     nafolder:   double               nr of all (sub)folder(s)
%$       folder:  {char}                unique folder name(s)
%$        fenum:   double               enumerator of (sub)folder(s) in .folder
%$                                      - subfolder(s) keep the .fenum of their root
%$       mdepth:   double               max depth of subfolder(s)
%$       fdepth:   double               depth of each subfolder [0: root]
%$    section_2:  '===== PATTERNS ='    PATTERN STATS
%$         npat:   double               nr of patterns
%$      pattern:  {char}                pattern(s)
%$      porigin:   char                 origin of pattern(s):
%$                                      - 'command line'
%$                                      -  name of pattern file [-f]
%$    section_3:  '===== FILES    ='    FILE STATS
%$       nfiles:   double               nr of files searched
%$      nxfiles:   double               nr of excluded file(s)  [-If|Xf]
%$      nafiles:   double               nr of all file(s) after [-Id|Xd]
%$       nbytes:   double               nr of bytes read
%$       nlines:   double               nr of lines searched
%$    section_4:  '===== MATCHES  ='    MATCH STATS
%$       mfiles:   double               nr of file(s) with matching patterns
%$       mbytes:   double               nr of bytes of .mfiles file(s)
%$       mlines:   double               nr of lines of .mfiles file(s)
%$       pfiles:   double               nr of .files with matching patterns
%$       pcount:   double               nr of lines with a match
%$        files:  {char}                file name for each match
%$                                      - repeated for each matching pattern
%$       lcount:  [double]              count of matching lines in .files [-c]
%$       findex:  [double]              index into .files   for each match
%$       pindex:  [double]              index into .pattern for each match
%$         line:  [double]              nr of matching line
%$        match:  {char}                matching line
%$       result:  [char]                runtime output
%$
%$  NOTE
%$	to reconstruct user defined results from P, which may be useful
%$	with the [-s] option, a programmer can use constructs like
%$	- file name|nr counts
%$		fmt=repmat(max(cellfun('length',P.files)),P.pfiles,1);
%$		r=[num2cell(fmt+3),...
%$		   P.files,...
%$		   num2cell(P.lcount)].';
%$		s=sprintf('%-*s: %5d\n',r{:})
%$	- file name|pattern|line nr|nr counts|matching line
%$		r=[P.files(P.findex),...
%$		   P.pattern(P.pindex),...
%$		   num2cell(P.line),...
%$		   num2cell(P.lcount(P.findex)),...
%$		   P.match]
%$___OUTPUT___

%$___EXAMPLE___
% GREP EXAMPLES
% assume GREP.TXT is in your current working folder
	fnam='grep.txt';
% - show contents (note all spaces are TABs!)
	type(fnam);

% simple case insensitive [-i] string search in GREP.M for instances of
%		Version
% listing file name [def] and the line number [-n] of occurrences
%-------------------------------------------------------------------------------
	grep -i -n Version grep.m

% regular expression search [-R] in GREP.M for instances of
%		=true or =false
% listing line number [-n] but not the file name [-Q]
%-------------------------------------------------------------------------------
	grep -Q -n -R =true|=false grep.m

% simple string search in GREP.M for exactly matching [-x] instances of
%		\t\tmsg=true;
% listing the file name [def] and the line number [-n] for each occurrence
%-------------------------------------------------------------------------------
	TAB=sprintf('\t');
	fl=grep('-x -n',[TAB,TAB,'msg=true;'],'grep.m');

% simple string search in GREP.TXT for
%		every line of itself in turn
% using the pattern-file [-f] option and
% listing the full file name and pattern for each file with matches [-l]
% as well as the file name [def] for each occurrence
%-------------------------------------------------------------------------------
	fl=grep('-l -f',fnam,fnam);

% simple string search in GREP.TXT for instances of
%		-n
% using the [-e] option since -n itself is an option flag (listing line number!)
% and listing the file name [def] for each non-matching line [-v] only
% - compare with previous example!
%-------------------------------------------------------------------------------
	fl=grep('-v -e',{'-n'},fnam);

% full depth search [-r] of the entire ELFUN TOOLBOX for instances of
%		sign or cosine or atan
% listing the full file name and pattern for each file with matches [-l]
% as well as the file name [def] and the line number [-n] for each occurrence
%-------------------------------------------------------------------------------
	fpat=[matlabroot,'/toolbox/matlab/elfun'];
	fl=grep('-r -l -n',{'sign','cosine','atan'},fpat);

% full depth search [-r] of the entire ELFUN TOOLBOX for instances of
%		sign or cosine or atan
% using the two versions of the [-e] option and
% listing the full file name and pattern for each file with matches [-l]
% as well as the count [-c] of all instances
%-------------------------------------------------------------------------------
	fl=grep('-r -l -c -e sign -e',{'cosine','atan'},fpat);

% full depth search [-r] of the entire ELFUN TOOLBOX for instances of
%		sign or cosine or atan
%	only including files with a regular expression pattern [-If]
%		[Cc]ont
% using the two versions of the [-e] option and
% listing the full file name and pattern for each file with matches [-l]
% as well as the file name [def] and the line number [-n] for each occurrence
%-------------------------------------------------------------------------------
	fl=grep('-r -l -n -If [Cc]ont -e sign -e',{'cosine','atan'},fpat);

% full depth search [-r] of the entire ELFUN TOOLBOX for instances of
%		sign or cosine or atan
%	only including files with a regular expression pattern [-If]
%		[Cc]ont
%	and excluding folders with a pattern [-Xd]
%		/ja
% - using the two versions of the [-e] option,
% and listing the full file name and pattern for each file with matches [-l]
% as well as the file name [def] and the line number [-n] for each occurrence
%-------------------------------------------------------------------------------
	fl=grep('-r -l -n -If [Cc]ont -e sign -e',{'cosine','atan'},'-Xd','/ja',fpat);
%$___EXAMPLE___
%---------------------------------------------------------------------------------
%}
