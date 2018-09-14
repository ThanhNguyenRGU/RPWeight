clear
clc

addpath('C:\Code\data-1');
addpath('C:\Code\data-2');
addpath('C:\Code\cv');
addpath('C:\Code\R\10');

fileList = { 'balance','conn-bench-vowel','hill_valley','ionosphere',...
     'iris','letter','libras','musk2',...
     'optdigits_new','page-blocks','penbased_new_fix','phoneme',...
     'ring1','tae','vehicle',...
     'thyroid','tic-tac-toe','vertebral_3C','waveform_w_noise','waveform_wo_noise',...
     'wine_red','wine_white'
};

nfolds= 10; 
niters = 10; % number of iteration
K=10;
flagCV = 1; % 0: Create cv file in first run, 1: Re-use cv file 
flagR = 1; % 0: Create R file in first run, 1: Re-use R file  
epsilon = 0.25;

for i = 1 : numel(fileList) 
    filename = fileList{i};
    
    D = importdata([filename '.dat']);
    [n,p]=size(D);
    whos D;    
    
    cvFileName = ['cv_' filename '.mat'];
    
    q0 = ceil(2*log(n)/epsilon^2)+1;
    if q0 < p-1
        q = q0;
    else
        q = ceil((p-1)/2);
    end
    disp(q);

    rpFileName = ['rmat_' filename];
    
    natt = size(D(:,1:end-1),2);

    R = cell(nfolds*niters,K);

    outfilename = ['result-DecisionTree/10/rpweight_' filename '(K=10)'];

    foutErr= fopen(strcat(outfilename,'.dat'),'wt');
    foutP = fopen(strcat(outfilename,'_P.dat'),'wt');
    foutR = fopen(strcat(outfilename,'_R.dat'),'wt');
    foutF1 = fopen(strcat(outfilename,'_F1.dat'),'wt');

    [arr,Time] = RPWeightPerf(D, nfolds, niters, K,q, flagCV, cvFileName, flagR, rpFileName, R,...
        foutErr, foutP, foutR, foutF1);

    fprintf(foutErr,'\n meanTrainTime  meanTestTime  meanTotalTime\n');
    fprintf(foutErr,'%d        %d        %d\n',Time.train,Time.test,Time.train+Time.test);

    fclose(foutErr);
    fclose(foutP);
    fclose(foutR);
    fclose(foutF1);
end

