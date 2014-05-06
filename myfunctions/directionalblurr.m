function idirblur=directionalblurr(im,len)
da=16;
%directional blurr
angles=-pi/2:pi/da:pi/2-pi/da;
iz=0*im;

for al=angles
    h1 = fspecial('motion', len, al*180/pi);
    ib=imfilter(im,h1,'replicate'); %blurred in direction
    iz=iz+ib; %add up all
end
idirblur=iz;
