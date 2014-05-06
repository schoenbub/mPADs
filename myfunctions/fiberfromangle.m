function ifib=fiberfromangle(im,alpha,len,exponent)
da=16;
%directional blurr
angles=-pi/2:pi/da:pi/2-pi/da;
iz=0*im;
alphabin=round(alpha/pi*da)*pi/da;

for al=angles
    a2=cos(2*(alpha-al)); %directional component along
    a2sharp=a2.^exponent;
    h1 = fspecial('motion', len, al*180/pi);
    h2 = fspecial('motion', len, al*180/pi-90);
    ib=(alphabin==al).*(imfilter(a2sharp,h1,'replicate')-imfilter(a2sharp,h2,'replicate')); %blurred in direction perpendicular
    iz=iz+ib; %subtract to reduce weight of broad bright regions
end
ifib=iz;

