
function xyz_stack=import_tiff_stack(fname1,fname2)

% returns an array with xy in first two dimensions, stack in third
% dimension, arbitrary number of channels
% NB - assumes all images in stack have same size and bit depth

info1 = imfinfo(fname1);
info2 = imfinfo(fname2);

img_size1=info1(1).Height;
img_size2=info1(1).Width;
img_type=['uint' num2str(info1(1).BitDepth)];

ni1 = numel(info1);
ni2 = numel(info2);
ni12=(ni1+ni2);

xyz_stack=zeros([img_size1 img_size2 ni12], img_type);
%preallocate array of correct type and size to improve speed

for k = 1:ni1
    A = imread(fname1, k, 'Info', info1);
    xyz_stack(:,:,k)=A;
end
% load 2nd stack and append to first one
for k = 1:ni2
    A = imread(fname2, k, 'Info', info2);
    xyz_stack(:,:,k+ni1)=A;
end
