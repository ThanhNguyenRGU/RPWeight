function PrintMeanVar(foutErr, foutP, foutR, foutF1,...
                              meanErr, meanP, meanR, meanF1,...
                              varErr, varP, varR, varF1)

        fprintf(foutErr,'------------------\n Mean: \n');        
        fprintf(foutErr,'%d\n', meanErr);
        fprintf(foutErr,'------------------\n Var: \n');        
        fprintf(foutErr,'%d\n', varErr);
        
        fprintf(foutP,'------------------\n Mean: \n');        
        fprintf(foutP,'%d\n', meanP);
        fprintf(foutP,'------------------\n Var: \n');        
        fprintf(foutP,'%d\n', varP);
        
        fprintf(foutR,'------------------\n Mean: \n');        
        fprintf(foutR,'%d\n', meanR);
        fprintf(foutR,'------------------\n Var: \n');        
        fprintf(foutR,'%d\n', varR);
        
        fprintf(foutF1,'------------------\n Mean: \n');        
        fprintf(foutF1,'%d\n', meanF1);
        fprintf(foutF1,'------------------\n Var: \n');        
        fprintf(foutF1,'%d\n', varF1);
        
end

