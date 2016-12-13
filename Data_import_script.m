close all
clear all

%% Parameters

dirName = ''; % Host directory of files
timeString = 'T3'; % Choose T1 (8 weeks), T2 (10 weeks) or T3 (12 weeks)
fileDiameter = '1900'; % Choose 500 or 1900 (pixels)
fileDepth = '300'; % Choose from 300 or 2000 (pixels)

%% Import

filePath = strcat(dirName,timeString,'_',fileDiameter,'_',fileDiameter,'_',fileDepth,'_8bit.raw'); % Builds the filename
diamNum = str2num(fileDiameter); % Sets the file diameter in pixels from input parameter string
depthNum = str2num(fileDepth); % Sets the file Z in pixels from input parameter string
fin=fopen(filePath,'rb'); % Sets the file to open
I=fread(fin,diamNum*diamNum*depthNum,'uint8=>uint8'); % Reads in the file
fclose(fin);
dataArray = reshape(I, [diamNum diamNum depthNum]); % Puts data into array called "dataArray"
halfDepth = round(depthNum/2) % Set halfway point of depth for display
clear I;

%% Display example slices

figure(1)
imshow(dataArray(:,:,1),[0 255]); % Display slice 1
title('Uppermost Slice');
figure(2)
imshow(dataArray(:,:,halfDepth),[0 255]); % Display slice 1
title('Middle Slice')
figure(3)
imshow(dataArray(:,:,depthNum),[0 255]); % Display slice 1
title('Lowermost Slice')