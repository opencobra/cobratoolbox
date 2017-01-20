function A=compareQualAndQuantDir(model)

qual=model.qualDir;
quant=model.quantDir;

qualForwardQuantForward=nnz(qual==1 & quant==1);
qualForwardQuantReversible=nnz(qual==1 & quant==0);
qualForwardQuantReverse=nnz(qual==1 & quant==-1);

qualReversibleQuantForward=nnz(qual==0 & quant==1);
qualReversibleQuantReversible=nnz(qual==0 & quant==0);
qualReversibleQuantReverse=nnz(qual==0 & quant==-1);

qualReverseQuantForward=nnz(qual==-1 & quant==1);
qualReverseQuantReversible=nnz(qual==-1 & quant==0);
qualReverseQuantReverse=nnz(qual==-1 & quant==-1);

A=cell(4,4);

A{2,1}='Qualitatively Forward';
A{3,1}='Qualitatively Reversible';
A{4,1}='Qualitatively Reverse';

A{1,2}='Quantitatively Forward';
A{1,3}='Quantitatively Reversible';
A{1,4}='Quantitatively Reverse';

n=1;
A{n+1,n+1}=qualForwardQuantForward;
A{n+1,n+2}=qualForwardQuantReversible;
A{n+1,n+3}=qualForwardQuantReverse;

A{n+2,n+1}=qualReversibleQuantForward;
A{n+2,n+2}=qualReversibleQuantReversible;
A{n+2,n+3}=qualReversibleQuantReverse;

A{n+3,n+1}=qualReverseQuantForward;
A{n+3,n+2}=qualReverseQuantReversible;
A{n+3,n+3}=qualReverseQuantReverse;

end

