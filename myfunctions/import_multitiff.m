function xyz_stack=import_multitiff(fname)

% returns an array with xy in first two dimensions, stack in third
% dimension, arbitrary number of channels
% NB - assumes all images in stack have same size and bit depth

info1 = imfinfo(fname);

img_size1=info1(1).Height;
img_size2=info1(1).Width;
img_type=['uint' num2str(info1(1).BitDepth)];

num_images = numel(info1);

xyz_stack=zeros([img_size1 img_size2 num_images], img_type);
%preallocate array of correct type and size to improve speed

for k = 1:num_images
    A = imread(fname, k, 'Info', info1);
    xyz_stack(:,:,k)=A;
end