function bool = testCorrespondingRowsCols()
%tests getCorrespondingRows and getCorrespondingCols
S = [-1  0  0  0  0;
      2 -3  0  0  0;
      0  4 -5  0  0;
      0  0  6 -7  0;
      0  0  0  0  8]; 
 
  
printLevel=1;

if printLevel
    display(S)
end  

if printLevel
    display('--- row subset for getCorrespondingRows ----')
end

rowBool=false(size(S,1),1);
colBool=false(size(S,2),1);
rowBool(1:5)=1;
colBool(1:3)=1;

if printLevel
    display(S(rowBool,colBool))
end

mode ='exclusive';
if printLevel
    display('exclusive')
end
restrictedRowBool = getCorrespondingRows(S,rowBool,colBool,mode);

if printLevel
    display(S(restrictedRowBool,colBool))
end

mode ='inclusive';
if printLevel
    display('inclusive')
end
restrictedRowBool = getCorrespondingRows(S,rowBool,colBool,mode);

if printLevel
    display(S(restrictedRowBool,colBool))
end

mode ='partial';
if printLevel
    display('partial')
end
restrictedRowBool = getCorrespondingRows(S,rowBool,colBool,mode);

if printLevel
    display(S(restrictedRowBool,colBool))
end


if printLevel
    display('--- col subset for getCorrespondingCols ----')
end
rowBool=false(size(S,1),1);
colBool=false(size(S,2),1);
rowBool(1:3)=1;
colBool(1:5)=1;

if printLevel
    display(S(rowBool,colBool))
end


mode ='exclusive';
if printLevel
    display('exclusive')
end
restrictedColBool = getCorrespondingCols(S,rowBool,colBool,mode);

if printLevel
    display(S(rowBool,restrictedColBool))
end

mode ='inclusive';
if printLevel
    display('inclusive')
end
restrictedColBool = getCorrespondingCols(S,rowBool,colBool,mode);

if printLevel
    display(S(rowBool,restrictedColBool))
end

mode ='partial';
if printLevel
    display('partial')
end
restrictedColBool = getCorrespondingCols(S,rowBool,colBool,mode);

if printLevel
    display(S(rowBool,restrictedColBool))
end

bool=1;