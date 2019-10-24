function result = removeNoise(b)

%     Remove noise (usually it is located in the near of characters):
cc = bwconncomp(b);
stats = regionprops(cc, 'Area');
idx = find([stats.Area] > 20);
result = ismember(labelmatrix(cc),idx);