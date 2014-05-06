function [Segout BWfinal]=detectCell(I)
% FUNCTION to detect cell outline
% Input:    Confocal image of membrane stained Cell (I)
% Output:   Cell Outline
% based on http://www.mathworks.ch/products/image/examples.html?file=/products/demos/shipping/images/ipexcell.html
% 1994-2013 The MathWorks, Inc.
% F. Herzog, May 2013

% REMOVE NOISE
%B = imadjust(I,[0; 0.5],[0; 1]);
B = medfilt2(I);
%B = imadjust(B);
% imshow(B);title('adjusted');figure;

% DETECT EDGES
[junk threshold] = edge(I, 'sobel');
fudgeFactor = .5;
BWs = edge(B,'sobel', threshold * fudgeFactor);
% figure, imshow(BWs), title('binary gradient mask');

se90 = strel('line', 2, 90);
se0 = strel('line', 2, 0);

BWsdil = imdilate(BWs, [se90 se0]);
BWsdil = imdilate(BWsdil, [se90 se0]);

% figure, imshow(BWsdil), title('dilated gradient mask');

BWdfill = imfill(BWsdil, 'holes');
% figure, imshow(BWdfill);
% title('binary image with filled holes');
BWnobord = imclearborder(BWdfill, 6);
% figure, imshow(BWnobord), title('cleared border image');

seD = strel('diamond',2);
BWfinal = imerode(BWnobord,seD);
BWfinal = imerode(BWfinal,seD);
% figure, imshow(BWfinal), title('segmented image');

BWoutline = bwperim(BWfinal);
%Segout = I;
%Segout(BWoutline) = 255;
% figure, imshow(Segout), title('outlined original image');
Segout=BWoutline.*255;

% only consider largest area
% L=bwlabel(BWfinal);
% a=regionprops(L,'Area');
% s = regionprops(L, 'PixelIdxList', 'PixelList');
% cellArea=max([a.Area])
% BWcell=zeros(1200,1200);
% for k=1:numel(s)
%    if a(k).Area(1)==cellArea
%        for m=1:numel(s(k).PixelList(:,1))
%            BWcell(s(k).PixelList(m,2),s(k).PixelList(m,1)) = 255;
%        end
%    end
% end

end
