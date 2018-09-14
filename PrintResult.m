function PrintResult( fout,mMean,mVar )
fprintf(fout,'------------------\n');
fprintf(fout,'Mean: \n');
for i=1:size(mMean,1)
    for j =1:size(mMean,2)
        fprintf(fout,'%d ',mMean(i,j));
    end
    fprintf(fout,'\n');
end
fprintf(fout,'------------------\n');
fprintf(fout,'\nVar: \n');
for i=1:size(mVar,1)
    for j =1:size(mVar,2)
        fprintf(fout,'%d ',mVar(i,j));
    end
    fprintf(fout,'\n');
end
end

