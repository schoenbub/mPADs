function [bwout overout] = outlines_func(im, handles)

% ; old function for outline

imdiff=im*0;
for sig1=[5 7 11 15 19 25 33 41 49] % subtract images with different degrees of blurring
    hg = fspecial('gaussian', 5*sig1+1, sig1);
    imdiff=imdiff+(im-imfilter(im,hg,'replicate'));
end;
wo = str2double(get(handles.wghtorig,'String'));
imdiff=imdiff+wo*(im-mean(im(:))); % remove dim background in dark regions
imdiff=imdiff/(max(imdiff(:)));

fon = str2double(get(handles.throutl,'String'));
level = fon*graythresh(imdiff); %choose threshold not exactly at 0. but a little higher to get rid of connected background pixels
bw0 = im2bw(imdiff, level); %create binary


% attempt to work with rank filters to close gaps in outline
% se = fspecial('disk',9);
% se(se>0) = 1;
% perc = floor(0.9*sum(se(:)));
% imrank = ordfilt2(imdiff,perc,se,'ones');
% se = fspecial('disk',10);
% se(se>0) = 1;
% perc = max(floor(0.1*sum(se(:))),1);
% imrank = ordfilt2(imrank,perc,se,'ones');
% bwrank = im2bw(imrank, 0); %create binary
% bw1 = imfill(bwrank,'holes'); % fill holes
% % some holes where empty spaces between cells; try to get them back again
% mhs = round(str2double(get(handles.holesize,'String')));
% bwholes = bw1-bwrank;
% bwholes = bwareaopen(bwholes,mhs);
% bwrank = bw1-bwholes;

se = strel('disk',5);
bw1 = imopen(bw0,se); % remove thin connected objects
mos = round(str2double(get(handles.minobjsiz,'String')));
bw1 = bwareaopen(bw1,mos); % remove small remaining objects, only centers of cells should remain
bw0 = imreconstruct(bw1,bw0,4); % reconstruct objects based on remaining centers

bw1 = imfill(bw0,'holes'); % fill holes
% some holes where empty spaces between cells; try to get them back again
mhs = round(str2double(get(handles.holesize,'String')));
bwholes = bw1-bw0;
bwholes = bwareaopen(bwholes,mhs);
bw1 = bw1-bwholes;

% marker = imerode(bw1,se);
% bwout = imreconstruct(marker,bwrank);

% figure(2)
% imagesc([bw1 bwrank bwout])
% colormap gray

% 
bw1 = bwmorph(bw1,'clean'); % remove single pixels
dim = round(get(handles.outmeds,'Value'))
bw1 = medfilt2(bw1,[dim dim]); % median filter to smoothen outline without displacing it
mos = round(str2double(get(handles.minobjsiz,'String')));
bw1 = bwareaopen(bw1,mos);
% 
bw2 = bwperim(bw1,4);
overim = max(bw2,im);

bwout = bw1;
overout = overim;

