function [Err,Pre,Recall,F1,time] = RPWeight(L0,LTest,K,q,nfolds,R,TLoop)

start_time1 = clock();
n0 = size(L0,1); % lay ve so quan sat cua L0
meas0 = L0(:,1:end-1);
species0 = L0(:,end); % label of classes
classes = unique(species0);
ncls = length(classes); % So class

% tao ma tran hau nghiem cua L0
P = zeros(n0,ncls*K); %Ma tran xac suat hau nghiem cua L0
indices = crossvalind('Kfold',species0,2);

for i = 1:2
    test = (indices == i);
    train = ~test;
    sample = meas0(test,:);    
    training = meas0(train,:);
    group = species0(train,:);
    
    mdl = cell(K,1);
    for k=1:K
        DLTemp = training*R{TLoop,k}/sqrt(q);
        mdl{k,:} = ClassificationTree.fit(DLTemp,group);
        %mdl{k,:} = prune(mdl{k,:});
        %mdl{k,:} = ClassificationDiscriminant.fit(DLTemp, group, 'discrimType','linear');
        %mdl{k,:} = ClassificationKNN.fit(DLTemp, group,'NumNeighbors',5);
    end
    
    PTempt = [];
    ntest = size(sample,1);
    
    for j=1:ntest
        PP=[];
        XTemp = sample(j,:);
        for k = 1:K    
            XuTemp = XTemp*R{TLoop,k}/sqrt(q);
            [~,PrTemp] = predict(mdl{k,:},XuTemp);
            PP = [PP PrTemp];
        end
        PTempt = [PTempt; PP];
    end
    P(test,:) = PTempt;
end

% gan nhan
Y = zeros(n0,ncls);
for i0=1:n0
    for m=1:ncls
        if species0(i0)== m
            Y(i0,m) = 1;
            break;
        end
    end
end

%Tinh trong so
Wm3 = zeros(K,ncls);


for m=1:ncls
    X = P(:,m:ncls:m+(K-1)*ncls)/sqrt(n0);
    y = Y(:,m)/sqrt(n0);
    Wm3(:,m) = lsqnonneg(X,y);
end


trainingmodel = cell(K,1);
for k=1:K
%       R{k} = createR1(meas0,q);
      DL = meas0*R{TLoop,k}/sqrt(q);
      trainingmodel{k,:} = ClassificationTree.fit(DL,species0);
      %trainingmodel{k,:} = prune(trainingmodel{k,:});
      %trainingmodel{k,:} = ClassificationDiscriminant.fit(DL, species0, 'discrimType','linear');
      %trainingmodel{k,:} = ClassificationKNN.fit(DL, species0,'NumNeighbors',5);
end

elapsed_time1 = etime(clock(), start_time1);
%--------------
start_time2 = clock();
ntest = size(LTest,1); % lay ve so quan sat cua LTest
measTest = LTest(:,1:end-1);
speciesTest = LTest(:,end); % Nhan cua cac phan tu trong LTest
%--------------
%Ma tran xac suat hau nghiem cua LTest
PTest = zeros(ntest,ncls*K);
PTestTempt = [];

for itest=1:ntest
     XTest = measTest(itest,:);
     PP = [];
     for k=1:K
         Xu = XTest*R{TLoop,k}/sqrt(q);
         [~,Pr] = predict(trainingmodel{k,:},Xu);
         PP = [PP Pr];
     end
     PTestTempt = [PTestTempt; PP];
end

PTest = PTestTempt;

LR3 = zeros(ntest,ncls);
ytestRP3 = zeros(ntest,1);

for itest=1:ntest       
    for m=1:ncls
  
        temptC3 = 0;
		for k=1:K
            temptC3 = temptC3 + Wm3(k,m)*PTest(itest,m+(k-1)*ncls);
        end 
        LR3(itest,m) = temptC3;
    end
    [~,id]= max(LR3(itest,:));
    ytestRP3(itest) = classes(id); 
    
end

elapsed_time2 = etime(clock(), start_time2);
%KET THUC QUA TRINH TEST


confusionMatrix = CreateConfusionMatrix(ytestRP3,speciesTest,classes);
[PAvg,RAvg,F1Avg] = CalculatePRF(confusionMatrix);
Pre = PAvg;
Recall = RAvg;
F1 = F1Avg;
Err = sum(ytestRP3~=speciesTest)/ntest;


time.train = elapsed_time1;
time.test = elapsed_time2;
end