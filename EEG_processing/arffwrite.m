function arffwrite(fname,data,path)
% fname This is file name without extension
%data is m x n where m are the instances and n-1 are the features. The last
%column is the class as integer

[nrow,ncol] = size(data);
filename1=strcat(path, fname,'.arff');
out1 = fopen (filename1, 'w+');
aa1=strcat('@relation',{' '},fname);
fprintf (out1, '%s\n\n', char(aa1));
for jj=1:ncol
fprintf (out1, '@attribute feature_%s numeric\n',num2str(jj));
end

txt1=strcat('@attribute',{' '},'class',{' {'});

txt1=strcat(txt1,'right, wrong',{''});
txt1=strcat(txt1,{'}'});

fprintf (out1, '%s\n\n',char(txt1));
fprintf (out1,'@data\n');

for i=1:nrow
    for j=1:ncol
       txt2 = strcat(num2str(data(i,j)),',',{' '});
       fprintf (out1,'%s',char(txt2)); 
    end
    fprintf (out1,'?\n');
end


fclose(out1);