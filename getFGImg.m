function fg = getFGImg(labelImg, numComponents)

e = 0.5 : numComponents + .5;
h = histcounts(labelImg, e);
[~, maxBinIdx] = max(h);
bgIdx = e(maxBinIdx) + .5;

fg = labelImg ~= bgIdx;