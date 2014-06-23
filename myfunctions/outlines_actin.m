function L = outlines_actin(im)

% ; determine cell outlines based on intensity of actin image
% ;
% ; input: 	actin image (double)
% ; output: label matrix
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

global allpar;

% threshold
level = graythresh(im);
bw1 = im2bw(im,level);
figure(3)
subplot(2,2,1)
imshow(bw1);
%remove small objects
minobjsize = allpar.outline3;
bw2 = bwareaopen(bw1,minobjsize);
subplot(2,2,2)
imshow(bw2);
%smoothen outline
se1=strel('disk',allpar.outline4);
bw3=imclose(bw2,se1);
subplot(2,2,3)
imshow(bw3);
%fill holes
bw4 = imfill(bw3,'holes');
subplot(2,2,4)
imshow(bw4);
% % disconnect nearby objects
% se1=strel('disk',allpar.outline4);
% bw4=imclose(bw4,se1);
%show result as label matrix
L = bwlabel(bw4,4);
rgb = label2rgb(L,'jet','k');
figure(2)
imshow(im, []);
colormap gray
hold on
hg = imshow(rgb);
hold off
set(hg,'AlphaData',0.15)