function [ mMean,mVar ] = CalculateMeanVar( arr, total)
mMean = zeros(size(arr{1,1}));
for i=1:total
    mMean = mMean + arr{i,1};
end
mMean = mMean./total;

mVar = zeros(size(mMean));
for i=1:total
    mVar = mVar + (arr{i,1} - mMean).^2;
end
mVar = mVar./total;

end

