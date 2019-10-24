function labelImg = getLabelImg(data, rndIdx, numComponents, regVal, imgSize)



smallestN = inf;

% for i = 1 : 5
    
%     rng('default')
    rng(3)

    g = fitgmdist(data(rndIdx,:), numComponents, 'Options',statset('MaxIter', 500), 'RegularizationValue', regVal, 'SharedCovariance', true);
    clusterIdx = cluster(g,data);

    disp(['cluster num: ' num2str(max(max(clusterIdx)))]);
    labelImg = reshape(clusterIdx, imgSize(1), imgSize(2));
    
%     nomacs(label2rgb(labelImg));

    gmmFG = getFGImg(labelImg, numComponents);
    [~, n] = bwlabel(gmmFG);
    
%     if (n < smallestN)
%         smallestN = n;
%         bestG = g;
%     end
%     
% %     g.BIC
%     
% end

% clusterIdx = cluster(bestG,data);
clusterIdx = cluster(g,data);
labelImg = reshape(clusterIdx, imgSize(1), imgSize(2));

