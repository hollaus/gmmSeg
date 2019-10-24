function mainText = getMainText(labelImg, numComponents, fg)


cleanLabelImg = zeros(size(labelImg));

% Clean the label images:
for i = 1 : numComponents
    l = labelImg == i;
    l = removeNoise(l);
    cleanLabelImg = cleanLabelImg + l .* i;
end
    
% cleanLabelImg = labelImg .* fg;

e = 0.5 : numComponents + .5;

% Use the skeleton to detect the major handwriting class:
s = bwmorph(fg, 'skel', 'inf');
h = histcounts(cleanLabelImg(s), e);

[~, fgIdx] = max(h);
fgIdx = e(fgIdx) + .5;

mainText = labelImg == fgIdx;