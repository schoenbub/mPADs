function impadded=centerpad(im,imsize)

% ; padd array with borders of specified size and zero value
% ; accepts different border size

is = size(im);
sizdiff = imsize - is;
compatible = logical(sum(mod(sizdiff,[2 2])));

if ~compatible
    impadded=im;
    return
end

impadded = clamppad(im,sizediff/2);
