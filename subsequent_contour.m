% Subsequent contour
%
% Mask from initial_contour is roots

%% Iterate over frames
for ii = 2:300
%% Define search region
[iY,iX,iFrame] = size(im);

indX = 1:iX;
indY = 1:iY;
[indX,indY] = meshgrid(indX,indY);

% locations of points
pointsX = indX(roots(:,:,ii-1)>0);
pointsY = indY(roots(:,:,ii-1)>0);

xWidth = abs(min(pointsX) - max(pointsX));
yWidth = abs(min(pointsY) - max(pointsY));

% Define search indices
xSearch = (min(pointsX)-round(0.5*xWidth)): ...
    (max(pointsX)+round(0.5*xWidth));
ySearch = (min(pointsY)-round(0.5*yWidth)): ...
    (max(pointsY)+round(0.5*yWidth));
%[xSearch,ySearch] = meshgrid(xSearch,ySearch);

%% Next region
imageSection = im(ySearch,xSearch,ii);
mask = roots(ySearch,xSearch,ii-1);

% active contour
bw = activecontour(imageSection,mask,'edge','ContractionBias',0.1);

% label contours
[bw,labelnum] = bwlabel(bw);

% Find largest contour
if labelnum > 1
    warning('More than one contour found\n')
    contourSize = zeros(labelnum,1);
    for jj = 1:labelnum
        contourSize(jj) = length(bw(bw==jj));
    end
    
    % Keep maximum size
    [~,ind] = max(contourSize);
    bw(bw~=ind) = 0;
    bw(bw>0) = 1;
end
    
% Save contour
dumRoot = imageSection;
dumRoot(~bw) = 0;
roots(ySearch,xSearch,ii) = dumRoot; %#ok<SAGROW>

figure(2)
subplot(1,2,1)
imshow(im(ySearch,xSearch,ii),[])
subplot(1,2,2)
imshow(dumRoot,[])
pause(0.5)

end