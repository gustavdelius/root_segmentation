%% Initial contour
%
xlim = 1151:1187;

ylim = 995:1031;

frame = 43:300;

im = dataArray(:,:,frame);

% root locations
roots = 0*im;

figure(1)

imshow(im(ylim,xlim,1),[])

%% Try and fit average contour
imageSection = im(ylim,xlim,1);
mask = 0*imageSection+1;

% active contour
bw = activecontour(imageSection,mask);

% label contours
[bw,labelnum] = bwlabel(bw);

% Find largest contour
if labelnum > 1
    contourSize = zeros(labelnum,1);
    for ii = 1:labelnum
        contourSize(ii) = length(bw(bw==ii));
    end
    
    % Keep maximum size
    [~,ind] = max(contourSize);
    bw(bw~=ind) = 0;
    bw(bw>0) = 1;
end
    
% Save contour
dumRoot = imageSection;
dumRoot(~bw) = 0;
roots(ylim,xlim,1) = dumRoot;
dumPerimeter = bwperim(roots(:,:,1));

[iY,iX,iFrame] = size(im);
indX = 1:iX;
indY = 1:iY;
[indX,indY] = meshgrid(indX,indY);
perimX = indX(dumPerimeter>0);
perimY = indY(dumPerimeter>0);
