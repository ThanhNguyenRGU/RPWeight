function [ zOpt ] = getOptimizeLamda( P, Y, arrRho, nfolds, niters, ncls, species0, K)
indices = crossvalind('Kfold',species0,nfolds);
classes = unique(species0);
rhoSize = length(arrRho);

rhoMC1 = zeros(nfolds*niters,ncls);
rhoMC2 = zeros(nfolds*niters,ncls);
zOpt = zeros(2,ncls);
couple = permn(1:rhoSize,ncls);
nCouple = size(couple,1);
for c = 1:niters
    for t=1:nfolds
        test = (indices == t);
        train = ~test;
        PtTest = P(test,:);
        PtTrain = P(train,:);
        
        LR = zeros(size(PtTest,1),ncls,rhoSize);
        ytestRP = zeros(size(PtTest,1),nCouple);
        Wm = zeros(K,ncls,rhoSize);
        for m=1:ncls
            PtTrain_m = PtTrain(:,m:ncls:m+(K-1)*ncls)/sqrt(size(PtTrain,1));
            YtTrain = Y(train,m)/sqrt(size(PtTrain,1));
            for z=1:rhoSize               
                Wm(:,m,z) = ridge(YtTrain,PtTrain_m,arrRho(z));
%                 Wm(:,m,z) = Wm(m,z);
            end
        end
        % Test Pt
        for itest = 1:size(PtTest,1)
            for z=1:rhoSize
                for m=1:ncls
                    tempt = 0;
                    for k=1:K
                        tempt = tempt + Wm(k,m,z)*PtTest(itest,m+(k-1)*ncls);
                    end
                    LR(itest,m,z) = tempt;                  
                end
            end
            
            for i =1:nCouple
                % Get LR array corresponding with each couple
                LRValue = [];
                for m = 1:ncls
                    LRValue = [LRValue LR(itest,m,couple(i,m))];
                end
                % Phan lop
                [~,id]= max(LRValue);
                ytestRP(itest,i) = classes(id);
            end
        end       
        
        % Get error rate to get lamda m
        Errs =  zeros(nCouple,1);
        speciesPtTest = species0(test,:);
        for i = 1:nCouple
            Errs(i,1) = sum(ytestRP(:,i)~=speciesPtTest)/size(speciesPtTest,1);
        end
        % Get lamda m
        [~,zMinIdx] = min(Errs);
        rhoMC1((c-1)*nfolds + t,:) = arrRho(couple(zMinIdx,:));
        
        % C2
        Lm = zeros(ncls,rhoSize);
        for m=1:ncls
            YtM = Y(test,m);
            
            PtTest_m = PtTest(:,m:ncls:m+(K-1)*ncls);
            for z=1:rhoSize
                Lm(m,z) = norm(PtTest_m*Wm(:,m,z)-YtM);
            end
        end
        
		
		meanLm = zeros(nCouple,1);
		for i = 1:nCouple
            % Get Lm corresponding with each couple
            LmValue = [];
            for m=1:ncls
                LmValue = [LmValue Lm(m,couple(i,m))];
            end
			meanLm(i,1) = mean(LmValue);			
		end
		[~,zMinIdxC2] = min(meanLm);
        rhoMC2((c-1)*nfolds + t,:) = arrRho(couple(zMinIdxC2,:));		
    end
end

zOpt(1,:) = mean(rhoMC1);
zOpt(2,:) = mean(rhoMC2);
end

