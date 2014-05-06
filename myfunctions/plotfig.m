function plotfig(handles)
global dat 

maxv=str2double(get(handles.maxv,'String'));
minv=str2double(get(handles.minv,'String'));
max2v=str2double(get(handles.max2v,'String'));
min2v=str2double(get(handles.min2v,'String'));

if dat.currentchanged

    % channel 1
    x1=double(dat.stack(:,:,dat.currentslice));
    x1=double(x1-min(x1(:)));
    y1=(x1)/(max(x1(:)));
    
    % ask stack size, then you know the index for 2nd channel
    stack_size=get(handles.slice,'Max');
    x2=double(dat.stack(:,:,dat.currentslice+stack_size));
    x2=double(x2-min(x2(:)));
    y2=(x2)/(max(x2(:)));
    
    % 
    dat.currentchanged=0;
    
    y=zeros([size(y1) 2]);
    y(:,:,1)=y1;
    y(:,:,2)=y2;
    dat.raw=y;
    
else
    y=dat.raw;
end

y1s=imadjust(y(:,:,1),[minv maxv],[0 1],1);
y2s=imadjust(y(:,:,2),[min2v max2v],[0 1],1);
% dat.corr=[y1, y2];

% axes(findobj('Tag','image1'))
set(handles.figure1,'CurrentAxes',handles.image1);
% imagesc('Parent',get(handles.image1,'Tag'),y1s)
imagesc(y1s)
colormap gray
axis equal
axis off

% axes(findobj('Tag','image2'))
set(handles.figure1,'CurrentAxes',handles.image2);
% imagesc('Parent', get(handles.image2,'Tag'),y2s)
imagesc(y2s)
colormap gray
axis equal
axis off
