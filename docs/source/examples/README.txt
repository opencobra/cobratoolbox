Please note that the ExcelExample.xlsx file is just for for the headers. 
This file does not load properly within
model2 = xls2model('ExcelExample.xlsx');
as it is missing Metabolites, and thus the model cannot be created properly.
However, it contains all the information on how the file has to be formatted (i.e. what kind of fields/headers) are allowed.
If you want it to load you can simply add:
atp[c]
adp[c]
dhap[c]
fdp[c]
g3p[c]
g6p[c]
h[c]
in the first column of the Metabolites sheet (after the glucose).
Then the file loads but the model will only have proper annotations/information on glucose.