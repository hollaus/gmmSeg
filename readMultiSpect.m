function [data, width, height, filteredData] = readMultiSpect(folderName)

if (nargin == 1)
    filter = false;
end

% fileNames = {'F01s.png', 'F02s.png', 'F03s.png', 'F04s.png', 'F05s.png', 'F06s.png', ...
%     'F07s.png', 'F08s.png'};
fileNames = {'F1s.png', 'F2s.png', 'F3s.png', 'F4s.png', 'F5s.png', 'F6s.png', ...
    'F7s.png', 'F8s.png'};
% fileNames = {'F1n.png', 'F2n.png', 'F3n.png', 'F4n.png', 'F5n.png', 'F6n.png', ...
%     'F7n.png', 'F8n.png'};

% In case some MSI channels are missing (deleted because they are
% duplicates in MS-Tex dataset), remove the missing file names:
files = dir(folderName);
existingFileNames = {files(:).name};
fileNames = fileNames(:);
fileNames = intersect(existingFileNames, fileNames);

img = im2double(imread(fullfile(folderName, fileNames{1})));
% img = (imread(fullfile(folderName, fileNames{1})));

[height, width] = size(img);

numChannels = length(fileNames);
numPixels = height * width;
data = zeros(numPixels, numChannels);
if (nargout == 4)
    filteredData = data;
end

for i = 1 : numChannels
    if (i > 1)
       img = im2double(imread(fullfile(folderName, fileNames{i})));
%         img = (imread(fullfile(folderName, fileNames{i})));
    end
    
    if (size(img,3)==3) 
        img = img(:,:,1);
    end
    
    data(:,i) = reshape(img, numPixels, 1);
    
    if (nargout == 4)
        m = medfilt2(img, [73 73], 'symmetric');
        medImg = img - m;
        medImg = normimg(medImg);
        scale = max(img(:)) - min(img(:));
        medImg = medImg * scale;
        medImg = medImg + min(img(:));
        
        filteredData(:,i) = reshape(medImg, numPixels, 1);
    end
    
end