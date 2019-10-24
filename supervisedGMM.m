function result = supervisedGMM(data, rndIdx, labelImg, numComponents, su)


dominantFGIdx = getFGIdx(labelImg, numComponents, su);
secondFGIdx = getSecondFGIdx(dominantFGIdx, labelImg, numComponents, su);

rng(3)

mu = [];
s = [];
PComponents = [];
idx = 1;

% figure;imshow(labelImg == dominantFGIdx); title('dominant');
% figure;imshow(labelImg == secondFGIdx); title('second');

r = zeros(size(labelImg));
r(rndIdx) = 1;

for i = 1 : numComponents
   l = (labelImg == i);
   
   if (i == secondFGIdx)
       continue;
%    elseif (i == dominantFGIdx)
%        l = l | (labelImg == secondFGIdx);
   end
   
   lr = l & r;
   
   if (sum(sum(lr)) < 20)
       continue;
   end
   
%    figure;imshow(l); title(num2str(i));
   mA = mean(data(lr,:));
   if (isnan(mA(1)))
       continue;
   end
   
   if (i == dominantFGIdx)
        PComponents(1,idx)= (length(l)*2) / (size(labelImg,1)*size(labelImg,2));
   else
       PComponents(1,idx)= (length(l)) / (size(labelImg,1)*size(labelImg,2));
   end
   
   mu(idx,:) = mA;
   s(:,:,idx) = cov(data(lr,:));
   idx = idx + 1;
    
end

S = struct('mu',mu,'Sigma',s,'ComponentProportion',PComponents, 'RegularizationValue', .0001);

g = fitgmdist(data(rndIdx,:),size(mu,1),'Start',S);

clusterIdx = cluster(g,data);

disp(['cluster num: ' num2str(max(max(clusterIdx)))]);
result = reshape(clusterIdx, size(labelImg,1), size(labelImg,2));

% nomacs(label2rgb(labelImg2))



function secondFGIdx = getSecondFGIdx(dominantFGIdx, labelImg, numComponents, su)

% dominantFGIdx = getFGIdx(labelImg, numComponents, su);
dominantFGImg = labelImg == dominantFGIdx;

[bw, numBW] = bwlabel(su);
bwo = bw .* dominantFGImg;

suC = ismember(bw, unique(bwo)) .* su;
suCRemain = suC .* ~ dominantFGImg;

% lSu = suCRemain .* labelImg;
e = 0.5 : numComponents + .5;
h = histcounts(labelImg(suCRemain > 0), e);

[~, secondFGIdx] = max(h);
secondFGIdx = e(secondFGIdx) + .5;

