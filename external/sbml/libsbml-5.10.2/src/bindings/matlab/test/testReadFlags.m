function y = testReadFlags(silent)

if (silent == 0)

disp('Testing readFlags');
disp('********************************************************');
disp('Failed read messages will be printed and can be ignored.');
disp('********************************************************');
end;

test = 97;
Totalfail = 0;

filename = fullfile(pwd,'test-data', 'none.xml');
m = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'none.xml');
m = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'none.xml');
m = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'none.xml');
m = TranslateSBML(filename, 1, 1);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'warn.xml');
m = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'warn.xml');
m = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'warn.xml');
m = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'errors.xml');
m = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'errors.xml');
m = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'errors.xml');
m = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'readerror.xml');
m = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'readerror.xml');
m = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'readerror.xml');
m = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'both.xml');
m = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'both.xml');
m = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'both.xml');
m = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(~isempty(m));

filename = fullfile(pwd,'test-data', 'fatal.xml');
m = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(isempty(m));

filename = fullfile(pwd,'test-data', 'fatal.xml');
m = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(isempty(m));

filename = fullfile(pwd,'test-data', 'fatal.xml');
m = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(isempty(m));

filename = fullfile(pwd,'test-data', 'fatal.xml');
m = TranslateSBML(filename, 1, 1);
Totalfail = Totalfail + fail_unless(isempty(m));

filename = fullfile(pwd,'test-data', 'none.xml');
[m, e] = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'none.xml');
[m, e] = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'none.xml');
[m, e] = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'none.xml');
[m, e] = TranslateSBML(filename, 1, 1);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'warn.xml');
[m, e] = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'warn.xml');
[m, e] = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(~isempty(e));
Totalfail = Totalfail + fail_unless(length(e)==6);

filename = fullfile(pwd,'test-data', 'warn.xml');
[m, e] = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'errors.xml');
[m, e] = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'errors.xml');
[m, e] = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(~isempty(e));
Totalfail = Totalfail + fail_unless(length(e)==1);

filename = fullfile(pwd,'test-data', 'errors.xml');
[m, e] = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'readerror.xml');
[m, e] = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(~isempty(e));
Totalfail = Totalfail + fail_unless(length(e)==1);

filename = fullfile(pwd,'test-data', 'readerror.xml');
[m, e] = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(~isempty(e));
Totalfail = Totalfail + fail_unless(length(e)==4);

filename = fullfile(pwd,'test-data', 'readerror.xml');
[m, e] = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(~isempty(e));
Totalfail = Totalfail + fail_unless(length(e)==1);

filename = fullfile(pwd,'test-data', 'both.xml');
[m, e] = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'both.xml');
[m, e] = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(~isempty(e));
Totalfail = Totalfail + fail_unless(length(e)==4);

filename = fullfile(pwd,'test-data', 'both.xml');
[m, e] = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'fatal.xml');
[m, e] = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(isempty(m));
Totalfail = Totalfail + fail_unless(~isempty(e));
Totalfail = Totalfail + fail_unless(length(e)==1);

filename = fullfile(pwd,'test-data', 'fatal.xml');
[m, e] = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(isempty(m));
Totalfail = Totalfail + fail_unless(~isempty(e));
Totalfail = Totalfail + fail_unless(length(e)==1);

filename = fullfile(pwd,'test-data', 'fatal.xml');
[m, e] = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(isempty(m));
Totalfail = Totalfail + fail_unless(~isempty(e));
Totalfail = Totalfail + fail_unless(length(e)==1);

filename = fullfile(pwd,'test-data', 'fatal.xml');
[m, e] = TranslateSBML(filename, 1, 1);
Totalfail = Totalfail + fail_unless(isempty(m));
Totalfail = Totalfail + fail_unless(~isempty(e));
Totalfail = Totalfail + fail_unless(length(e)==1);

%test default flags

filename = fullfile(pwd,'test-data', 'none.xml');
[m, e] = TranslateSBML(filename, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'none.xml');
[m, e] = TranslateSBML(filename);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'warn.xml');
[m, e] = TranslateSBML(filename, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'warn.xml');
[m, e] = TranslateSBML(filename);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'errors.xml');
[m, e] = TranslateSBML(filename, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'errors.xml');
[m, e] = TranslateSBML(filename);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'readerror.xml');
[m, e] = TranslateSBML(filename, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(~isempty(e));
Totalfail = Totalfail + fail_unless(length(e)==1);

filename = fullfile(pwd,'test-data', 'readerror.xml');
[m, e] = TranslateSBML(filename);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(~isempty(e));
Totalfail = Totalfail + fail_unless(length(e)==1);

filename = fullfile(pwd,'test-data', 'both.xml');
[m, e] = TranslateSBML(filename, 0);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'both.xml');
[m, e] = TranslateSBML(filename);
Totalfail = Totalfail + fail_unless(~isempty(m));
Totalfail = Totalfail + fail_unless(isempty(e));

filename = fullfile(pwd,'test-data', 'fatal.xml');
[m, e] = TranslateSBML(filename, 0);
Totalfail = Totalfail + fail_unless(isempty(m));
Totalfail = Totalfail + fail_unless(~isempty(e));
Totalfail = Totalfail + fail_unless(length(e)==1);

filename = fullfile(pwd,'test-data', 'fatal.xml');
[m, e] = TranslateSBML(filename);
Totalfail = Totalfail + fail_unless(isempty(m));
Totalfail = Totalfail + fail_unless(~isempty(e));
Totalfail = Totalfail + fail_unless(length(e)==1);

if (silent == 0)

disp('**************************************');

disp(sprintf('Number tests: %d', test));
disp(sprintf('Number fails: %d', Totalfail));
disp(sprintf('Pass rate: %d%%\n', ((test-Totalfail)/test)*100));
end;

if (Totalfail == 0)
    y = 0;
else
    y = 1;
end;

function y = fail_unless(arg)

if (~arg)
    y = 1;
else
    y = 0;
end;
    
