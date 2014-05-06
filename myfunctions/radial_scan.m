% calculate averaged radial profile
function [r radial_average]=radial_scan(img)

% Size of image and center position
img_size = min(size(img));
center = floor(size(img)/2);

% Create the meshgrid to be used in resampling
[X,Y] = meshgrid(1:size(img,1),1:size(img,2));

for radius = 1:round(0.4*img_size),
    
    % To avoid redundancy, sample at roughly 1 px distances
    num_pxls = 2*pi*radius;
    theta = 0:1/num_pxls:2*pi;
    
    x = center(1) + radius*cos(theta);
    y = center(2) + radius*sin(theta);

    sampled_radial_slice = interp2(X,Y,img,x,y);
    radial_average(radius) = mean(sampled_radial_slice);
    
end

r = 1:round(0.4*img_size);