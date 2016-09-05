
TAB = char(9);
SPC = char(32);

L   = textread('reactions','%s','delimiter','\n','whitespace','');       

fid = fopen('reactions.scaled','wt');

for z=1:length(L),
  l = L{z};
  
  [args,nargs,arg0,arg1] = srgetargs(l,TAB);
  
  [sargs,nsargs,sarg0,sarg1] = srgetargs(args{6},SPC);
  
  sidx = [];
  for zs=1:nsargs,
    if ~isempty(sargs{zs})
      if ~strcmp(sargs{zs},SPC),
	sidx = [sidx zs];
      end
    end
  end
  
  npargs = length(sidx);
  [pargs{1:npargs}] = deal(sargs{sidx}); 
  
  ScaleFactor = .33/.65;
  
  pargs{1} = sprintf('%6.1f',ScaleFactor*str2num(pargs{1}));
  pargs{2} = sprintf('%6.1f',ScaleFactor*str2num(pargs{2}));

  fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s %s %s %s\t%s\n', ...
	  args{1},args{2},args{3},args{4},args{5}, ...
	  pargs{1},pargs{2},pargs{3},pargs{4},args{7});
  
end

fclose(fid);

return
  