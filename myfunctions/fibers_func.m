function [bwout, angleout] = fibers_func(im, handles)
% hObject    handle to fibers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ts=round(str2double(get(handles.threshsmall,'String')));
tl=round(str2double(get(handles.threshlarge,'String')));
fo=str2double(get(handles.factorotsu,'String'));
fo1=str2double(get(handles.factorotsu1,'String'));

imdiff=im*0;

for sig1=[2 3 4 5 7 9] % subtract images with different degrees of blurring to emphasize fibers
    hg = fspecial('gaussian', 4*sig1+1, sig1);
    imdiff=imdiff+(im-imfilter(im,hg,'replicate'));
end;
imdiff2 = medfilt2(imdiff, [3 3]); %median filtering to reduce salt-n-pepa noise, preserves edges
imdiff2 = sharpim(imdiff2); %sharpen image
imdiff2 = imdiff2/max(imdiff2(:)); %normalize
level = fo1*graythresh(imdiff2); %Otsu threshold
bw = im2bw(imdiff2, level); %create binary
bw = imfill(bw,'holes');

sigmaangle=1.0; %blurring degree for directional image
angle=getdirectionlaplace(imdiff,sigmaangle);

ifib = fiberfromangle(imdiff,angle,21,11); %determine fibers from directional blur of angle image
ifib = ifib+fiberfromangle(imdiff,angle,15,9);
ifib = ifib+fiberfromangle(imdiff,angle,9,7);
ifib = ifib/max(ifib(:));
ifib = medfilt2(ifib, [3 3]); %median filtering to reduce salt-n-pepa noise, preserves edges
ifib = sharpim(ifib); %sharpen image
level = fo*graythresh(ifib); %Otsu threshold
bw1 = im2bw(ifib, level); %create binary
bw1 = imfill(bw1,'holes');

bw2=bw1-bw;
bw2(bw2<0)=0;
bw2 = bwareaopen(bw2,tl);

bw3=bw-bw1;
bw3(bw3<0)=0;
bw3 = bwareaopen(bw3,ts);

bw4=bw.*bw1+bw2+bw3; % take overlap plus significant differences

anglew=uint16(((angle/pi)+0.5)*65535);

bwout = bw4;
angleout = angle;
