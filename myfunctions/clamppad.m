function impadded=clamppad(im,nborder)

% ; padd array with borders of specified size and zero value
% ; accepts different border size

sizpadded=size(im)+2*nborder;
impadded=double(zeros(sizpadded));
if length(nborder)>1
    impadded(nborder(1)+1:end-nborder(1),nborder(2)+1:end-nborder(2))=im;
else
    impadded(nborder+1:end-nborder,nborder+1:end-nborder)=im;
end