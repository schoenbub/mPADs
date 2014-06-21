function [x y] = find_centers_ingmar(img,pitch)

% ; find centers of posts in fluorescence image
% ; based on intensity and size of object
% ; filter parameters are given in allpar.f1, allpar.f2, allpar.f3

global allpar
% filtering parameters
smoo=allpar.f1;
corrstrel=round(allpar.f2);
fracarea=allpar.f3;

% for debugging
showfigures = false;

% Bandpass filter 
bpfiltsize=round(pitch/smoo);
noisesize=1;
processedimg = bpass(img,noisesize,bpfiltsize); %Grier et al
processedimg=double(processedimg);
                
if showfigures
    figure(6)
    imagesc(processedimg)
    colormap gray
end
       
% binarize
bw1=adaptivethreshold(processedimg,round(pitch),0);
bw1=imclearborder(bw1);

% disconnect artifacts
se1=strel('disk',max([floor(pitch/4.)-corrstrel,1]));
bw2=imopen(bw1,se1);

% remove noise, shrink to central points
minareapost=floor(((pitch/4.)^2.)*pi*fracarea);
bw3=bwareaopen(bw2,minareapost,4);
bw4=bwmorph(bw3,'shrink',Inf);

if showfigures
    figure(5)
    imshow([bw1 bw2; bw3 bw4],[])
end

% get coordinates
[y x ~]=find(bw4);

% % throw out objects which are too close to boundary
% md = floor(pitch/2)+1;
% is = size(img);
% x = x(y>md);
% y = y(y>md);
% y = y(x>md);
% x = x(x>md);
% x = x(y<is(1)-md);
% y = y(y<is(1)-md);
% y = y(x<is(2)-md);
% x = x(x<is(2)-md);
    
