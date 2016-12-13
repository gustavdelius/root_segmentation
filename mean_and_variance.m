function mean_and_variance(dataArray)

close all

%2D

%Choose data
N = 155;
test_array = dataArray(600:1300,600:1300,N);
imshow(test_array,[]);

%Circular neighbourhood
filt_size = 11;
[x,y] = meshgrid(linspace(-1,1,filt_size));
r = sqrt(x.^2 + y.^2);
nhood = r <= 1;

%Entropy filter
J2 = entropyfilt(test_array,nhood); 
figure, imshow(J2,[]);

%Rescale
a = min(J2(:));
b = max(J2(:));
J3 = 255*(J2 - a)/(b-a);

%Mask based on intensities (heuristic)
mask_1 = test_array < 95;
mask_2 = test_array > 65;
mask_3 = J3 < 200;
mask_4 = mask_1.*mask_2.*mask_3;

%Circular neighbourhood
filt_size = 4;
[x,y] = meshgrid(linspace(-1,1,filt_size));
r = sqrt(x.^2 + y.^2);
nhood = r <= 1;

%Binary fun - erosion and filling
erodedBW = imerode(mask_4,nhood);
IM2 = imfill(erodedBW,'holes');
IM2 = imdilate(IM2,nhood);

filt_size = 7;
[x,y] = meshgrid(linspace(-1,1,filt_size));
r = sqrt(x.^2 + y.^2);
nhood = r <= 1;
erodedBW = imerode(IM2,nhood);
IM2 = imfill(erodedBW,'holes');
IM2 = imdilate(IM2,nhood);

%Binary boundaries and replot
B = bwboundaries(IM2);
figure,
imshow(test_array,[]);
hold on
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
end

end