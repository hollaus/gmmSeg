function filterFolders(sP, tP)

% sP = checkPathName(sP);
% tP = checkPathName(tP);

folders = dir(sP);

for i = 1 : size(folders)
    
    folder = folders(i);
    
    if (strcmp(folder.name, '.') || strcmp(folder.name, '..') || ~folder.isdir)
        continue;
    end
    
    disp([num2str(i) ' / ' num2str(size(folders))])
    
%     [data, width, height] = readgMultiSpect(folderName);
    folderName = fullfile(sP, folder.name);
%     binarMultiSpectGMM_2(folderName, fullfile(tP, [folder.name '.png']));

    files = dir(folderName);
    for j = 1 : length(files)
       fileName = files(j).name;
       if (~contains(fileName, 's.png'))
           continue;
       end
       tPFolder = fullfile(tP, folder.name);
       mkdir(tPFolder);
       img = im2double(imread(fullfile(folderName, fileName)));
       m = medfilt2(img, [73 73], 'symmetric');
       medImg = img - m;
       medImg = normimg(medImg);
       scale = max(img(:)) - min(img(:));
       medImg = medImg * scale;
       medImg = medImg + min(img(:));
       imwrite(medImg, fullfile(tPFolder, fileName));
    end    
    
end