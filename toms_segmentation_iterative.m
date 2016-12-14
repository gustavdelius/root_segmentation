% toms segementation iterative
% needs the loaded image as 'dataArray'


im1=dataArray(:,:,1); % takes the first slice
max_depth = 30; 

% create output
roots = zeros(size(im1,2),size(im1,2),max_depth);

%[x,y,z]=ind2sub([size(im1,1),size(im1,2),max_depth],);

% 0) Set Parameters
% a) for the first slice
threshold1 = 0.2*255;
threshold2 = 0.4*255;
opening1 = 7; % opening radius 
dilation_radius = 3;
std_factor= 1.0;
median_filter_size = 11;
threshold_bin = 130;
final_opening=2;

% b) for the iterative process
dilation_radius_iter = 10;
median_filter_size_iter=11;
threshold_bin_iter=130;
minCCsize=150;
% plot options
plot_histogram = 0;
plot_first_iteration = 0;
plot_iter = 1;


%%%%% 1) First iteration
% a) Initial guess that the root is approx grayscale 0.2-0.4
%root_guess=find(all([im1>(0.2*255),im1<(0.4*255)]));
%root_guess=find(im1>(0.2*255));
root_guess = zeros(size(im1)); % empty black screen
%[root_guessx,root_guessy]
% roots_found=find(im1>(0.2*255) & im1<(0.4*255));
mask_1 = im1>(threshold1);
mask_2 = im1<(threshold2);
roots_found = uint8(mask_1 & mask_2); % indexes of roots
display_roots1 = im1.*roots_found;


% b) Opening by 7 pixels
se = strel('disk',opening1); % create a disk of 6 pixels
afterOpening = imopen(display_roots1,se);

% c) Dilation by 1 pixel
afterDilation= imdilate(afterOpening,strel('disk',dilation_radius));

% d) Back to the original image and get the histogram of gray values
gray_values = double(im1(find(afterDilation)));
if plot_histogram==1
% (Potentially a histogram of the gray values)
    col=histc(gray_values,0:255)
    bar(0:255,col)
    title('histogram gray values')
end
mean_gray = mean(gray_values);
std_gray = std(gray_values);
% e) gaussian 'filtering'/transformation of gray values in the original image
trans_Im = gaussian_transform(im1,mean_gray,std_factor*std_gray);

% f) median filter
median_filtered = medfilt2(trans_Im,median_filter_size*ones(2,1));

% g) binarise
binarise_image = median_filtered>threshold_bin;


% h) largest conencted compoennt
delete_small_components= zeros(size(binarise_image));
CC = bwconncomp(binarise_image); % get all connected components
numPixels = cellfun(@numel,CC.PixelIdxList); % for each component get the size
[biggest,idx] = max(numPixels); % find the largest
delete_small_components(CC.PixelIdxList{idx}) = 1; % only keep the largest cc

% i) final opening
afterFinalOpening = imopen(delete_small_components,strel('disk',final_opening));

roots(:,:,1) = afterFinalOpening;

%%%%% 2) Iterative process 
for d =2:max_depth
    d
    im_slice=dataArray(:,:,d); % takes the second slice
    % a) Dilate from step before
    afterIterDilation= imdilate(afterFinalOpening,strel('disk',dilation_radius_iter));
    % b) Gaussian Transformation

    trans_Im_iter = gaussian_transform(im_slice,mean_gray,std_factor*std_gray);
    % c) median filter
    median_filtered_iter = medfilt2(trans_Im_iter,median_filter_size_iter*ones(2,1));
    % d) bianrise
    binarise_image_iter = median_filtered_iter>threshold_bin_iter;
    % e) throw small components away
    delete_small_components_iter= zeros(size(binarise_image_iter));
    CC = bwconncomp(binarise_image_iter); % get all connected components
    numPixels = cellfun(@numel,CC.PixelIdxList); % for each component get the size
    large_compoments=find(numPixels>minCCsize);

    for comps_idx = large_compoments
        delete_small_components_iter(CC.PixelIdxList{comps_idx}) = 1; % only keep the cc that are at least minSize
    end

    % e) final opening
    afterFinalOpeningIter = imopen(delete_small_components_iter,strel('disk',final_opening));

    
    % f) save it
    roots(:,:,d) = afterFinalOpeningIter;
end





% plotting of the roots
%x,y,z]=ind2sub([size(im1,1),size(im1,2),max_depth],roots);
[x,y,z] = ind2sub([size(im1,1),size(im1,2),max_depth],find(roots));
figure('Color',[1 1 1])
scatter3(x,y,z)



%%%%%% Auxiliary functions


function trans_Im = gaussian_transform(Image,mean_gray,std_gray)
% Does a Gaussian transformation of the gray values 
transform = normpdf(0:255,mean_gray,std_gray); % get a gaussian as the transform
transform = round(255*transform/max(transform)); % rescale to be in (0,255)
trans_Im = zeros(size(Image)); % output image
% go over all possible values of gray and create the transformed image
for gray_val=0:255
    in_original = find(Image==gray_val); % index in original with this gray
    trans_Im(in_original) = transform(gray_val+1); % set the output to be this value
end
end

