function gmmSeg(folderName, outputName, filteredFolderName)

%GMMSEG Applies document binarization on multispectral images.
% GMMSEG reads the images contained in a folder folderName and 
% writes the resulting image outputImgName.
% The folder should contain 8 image files (FXXs.png) where XX is the
% channel number.
% 
% Submission for MS-TEx competition
% Authors: Fabian Hollaus, Markus Diem and Robert Sablatnig
% Computer Vision Lab, Vienna University of Technology

numComponents = 10;
if (nargin == 2)
    [data, width, height, filteredData] = readMultiSpect(folderName);
elseif (nargin == 3)
    [filteredData, width, height] = readMultiSpect(filteredFolderName);
    data = readMultiSpect(folderName);
end

% check for duplicate channels in the 7th and 8th channel,
% the gmm is quite sensitive on such fake / duplicate channels and might
% throw an error:
if (size(data,2) > 7 && mean(abs(data(:,7)-data(:,8))) < .001)
    filteredData = filteredData(:,1:7);
    data = data(:, 1:7);
end

writingImg = reshape(data(:,2), height, width);
su = suBinar(writingImg);

% for reproducible results:
rng(3)
rndIdx = getRndIndices(filteredData, 30000, height, width);

regVal = .00001;
labelImg = getLabelImg(filteredData, rndIdx, numComponents, regVal, [height width]);
fgImg = getFGImg(labelImg, numComponents);

labelImg2 = supervisedGMM(filteredData, rndIdx, labelImg, numComponents, su.*fgImg);
mainText = getMainText(labelImg2, numComponents, su.*fgImg);

cleanText = removeNoise(removeNoise(mainText) .* removeNoise(fgImg));
cleanText = removeBackground(cleanText);

c = combineBinaryMasks(su, cleanText);
c = refineBorder(c, writingImg);

imwrite(c, outputName);


function idx = getRndIndices(data, numSamples, height, width)

% Remove samples that are close to the image border, because these might
% contain invalid data in MSTex (stemming maybe from
badMask = zeros(height, width);
badMask(1:5,:) = 1;
badMask(:,1:5) = 1;
badMask(:,end-5:end) = 1;
badMask(end-5:end,:) = 1;

minIdx = min(data,[],2) == min(min(data));
maxIdx = max(data,[],2) == max(max(data));
badMask(minIdx) = 1;
badMask(maxIdx) = 1;

goodIdx = find(~badMask);

r = randperm(length(goodIdx));
idx = goodIdx(r(1 : numSamples));

function ratio = getTpFpRatio(labelImg, fg)

fg = imdilate(fg, strel('disk', 2));

numComponents = max(max(labelImg));
ratio = zeros(numComponents, 1);

for i = 1 : numComponents
    img = labelImg == i;
    tp = sum(sum(img & fg));
    fp = sum(sum(img & ~fg));
    ratio(i) = tp/fp;
end

function bw = refineBorder(bw, img)

% add 1px to permeter
se = strel('disk', 1);
bwd = imdilate(bw, se);
% se = strel('disk', 1);
% bwo = imerode(bwo, se);
bwd = bwd&~bw;  % select border

% remove 1px to permeter
se = strel('disk', 1);
bwe = imerode(bw, se);
bwe = bw&~bwe;  % select border
peri = bwe | bwd;

img(~peri) = 0.5;    % other pixels schould not influence normalization
img = normimg(img);
img(~peri) = 0.5;    % ignore all other pixels

bw = bw | img < 0.5;

function combined = combineBinaryMasks(bSoft, bHard)
% Combines two binary images in such a way that only fg regions of the
% bSoft are connected to bHard remain in the result.
% 
% bSoft = bSoft + bHard;

lSoft = bwlabel(bSoft);
lHard = lSoft .* bHard;

badIdx = setdiff(unique(lSoft),unique(lHard));

badMask = ismember(lSoft, badIdx);

combined = bSoft .* ~badMask;

b = bwmorph(combined, 'skel','Inf');
missingLinks = b-b.*bHard > 0;
missingLinksDil = imdilate(missingLinks, strel('disk',3));
missingLinksMask = missingLinksDil.*bSoft;

cc1 = bwconncomp(missingLinksMask);
stats1 = regionprops(cc1, 'Area');

cc2 = bwconncomp(bHard);
stats2 = regionprops(cc2, 'Area');

idx = find([stats1.Area] < mean([stats2.Area]));
result = ismember(labelmatrix(cc1),idx);

combined = bHard+result;


function [bw] = removeBackground(img)

bg = imresize(im2double(img), 0.5, 'bicubic');
se = strel('disk', 15);
bg = imclose(bg, se);
bg = bg > 0.1;
bg = bwareaopen(bg, 400);
bg = imresize(bg, size(img), 'nearest');
bw = img&bg;

% function [data, width, height] = readMultiSpect(folderName)
% 
% fileNames = {'F1s.png', 'F2s.png', 'F3s.png', 'F4s.png', 'F5s.png', 'F6s.png', ...
%     'F7s.png', 'F8s.png'};
% % fileNames = {'F1n.png', 'F2n.png', 'F3n.png', 'F4n.png', 'F5n.png', 'F6n.png', ...
% %     'F7n.png', 'F8n.png'};
% 
% img = readImg(folderName, fileNames{1});
% 
% [height, width] = size(img);
% 
% numChannels = length(fileNames);
% numPixels = height * width;
% data = zeros(numPixels, numChannels);
% 
% for i = 1 : numChannels
%    
%     if (i > 1)
%        img = readImg(folderName, fileNames{i});
%     end
%     
%     if (size(img,3)==3) 
%         img = img(:,:,1);
%     end
%     
%     data(:,i) = reshape(img, numPixels, 1);
%     
% end
