
clear html
fid=fopen('index.html');
tline = fgetl(fid);
cnt =1;
while ischar(tline)
    disp(tline)
    tline = fgetl(fid);
    html{cnt} = tline;
    cnt = cnt + 1;
end
fclose(fid);
html = html';
fid =fopen('index4.html', 'w');

for i = 1 : length(html)-1
fprintf(fid,html{i});
end