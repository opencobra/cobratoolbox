function [rval,ival]=getVals(x,index)

%%%rval=builtin('subsref',x,struct('type',{'()','.'},'subs',{{index},'rval'}));
%%%rexp=builtin('subsref',x,struct('type',{'()','.'},'subs',{{index},'rexp'}));
%%%ival=builtin('subsref',x,struct('type',{'()','.'},'subs',{{index},'ival'}));
%%%iexp=builtin('subsref',x,struct('type',{'()','.'},'subs',{{index},'iexp'}));

rval=x(index).rval;
%rexp=x(index).rexp;
ival=x(index).ival;
%iexp=x(index).iexp;
if isempty(ival), ival='0'; end
if isempty(rval), rval='0'; end %  Suggested, ARW 2.01.08

