function [arrErr,Time] = RPWeightPerf(D, nfolds, niters, K,q, flagCV, cvFileName, flagR, rpFileName, R,...
    foutErr, foutP, foutR, foutF1)
species = D(:,end);
natt = size(D(:,1:end-1),2);
n0 = length(species);
allIdx = (1:n0)';
traintime_sum = 0;
testtime_sum = 0;
arrErr = cell(niters*nfolds,1);
arrP = cell(niters*nfolds,1);
arrR = cell(niters*nfolds,1);
arrF1 = cell(niters*nfolds,1);

if(flagCV == 0)
    cv = cell(1,niters*nfolds);
else
    cv = load(cvFileName);
end

for loop=1:niters
    fprintf('At the %2d iteration:\n',loop);
    for i = 1:nfolds
        PrintLoopIndex(foutErr, foutP, foutR, foutF1,((loop-1)*nfolds + i));
        disp(i);
        
        if(flagCV == 0)
            CVO = cvpartition(species,'k',nfolds);
            trIdx = CVO.training(i);
            teIdx = CVO.test(i);
            cv{((loop-1)*nfolds + i)} = allIdx(teIdx);
        else
            teIdx = cv.cv{((loop-1)*nfolds + i)};
            trIdx = allIdx(~ismember(allIdx,teIdx));
        end
        L0 = D(trIdx,:);
        LTest = D(teIdx,:);
        
        if(flagR == 0)
            for k=1:K
                rtemp = createR1(natt,q);
                R{((loop-1)*nfolds+i),k} = rtemp;
                dlmwrite(strcat(rpFileName,'_',num2str(((loop-1)*nfolds+i)),'_',num2str(k),'.txt'),rtemp);
            end
            [Err,PAvg,RAvg,F1Avg,time]= RPWeight(L0,LTest,K,q,nfolds, R,((loop-1)*nfolds+i));
        else
            %                 for k=1:K
            %                     rtemp = load(strcat(rpFileName,'_',num2str(((loop-1)*nfolds+i)),'_',num2str(k),'.txt'));
            %                     R{((loop-1)*nfolds+i),k} = rtemp;
            %                 end
            Rmat = load(strcat(rpFileName,'.mat'));
            [Err,PAvg,RAvg,F1Avg,time]= RPWeight(L0,LTest,K,q,nfolds, Rmat.R,((loop-1)*nfolds+i));
        end
        
        arrErr{(((loop-1)*nfolds)+i),1}= Err;
        arrP{(((loop-1)*nfolds)+i),1}= PAvg;
        arrR{(((loop-1)*nfolds)+i),1}= RAvg;
        arrF1{(((loop-1)*nfolds)+i),1}= F1Avg;
       
        traintime_sum = traintime_sum + time.train;
        testtime_sum = testtime_sum + time.test;
        
        PrintEPRF(foutErr, foutP, foutR, foutF1,Err,PAvg,RAvg,F1Avg);
       
    end
end
if(flagCV == 0)
    save(strcat(cvFileName),'cv');
end
%Tinh trung binh va phuong sai
total = nfolds*niters;
[meanErr,varErr] = CalculateMeanVar(arrErr,total);
[meanP,varP] = CalculateMeanVar(arrP,total);
[meanR,varR] = CalculateMeanVar(arrR,total);
[meanF1,varF1] = CalculateMeanVar(arrF1,total);


PrintMeanVar(foutErr, foutP, foutR, foutF1,meanErr, meanP, meanR, meanF1,varErr, varP, varR, varF1);

Time.train = traintime_sum/total;
Time.test = testtime_sum/total;
end