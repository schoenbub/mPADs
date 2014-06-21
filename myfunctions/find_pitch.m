function ptch=find_pitch(imin)

% for debugging
showfigures=false;

% determines approximate pitch in image

% make image processable
imin1=double(imin);

% crop to quadratic image
is=min(size(imin1));
imq=imin1(1:is,1:is);

% filter, calculate auto correlation magnitude in Fourier space, normalize
imq=imfilter(imq,ones(5,5));
imf=fft2(imq);
auto=abs(imf.*conj(imf));
auto=auto-min(auto(:));
auto=auto/max(auto(:));

% shift zero frequency to center and crop
shiftmagn=[floor(is/2)-1 floor(is/2)-1];
auto=circshift(auto, shiftmagn);
border=4/10;
auto=auto(floor(is*border):(is-floor(is*border)),...
    floor(is*border):(is-floor(is*border)));

% emphasize side lobes by taking the logarithm
fac=500; % adjust this to your needs; too low: low directional sensitivity, too high: noise
autolog= log(auto*fac+1);
h=fspecial('gaussian',[5 5],1.0);
autologf=imfilter(autolog,h);

if showfigures
    figure(9)
    imshow(autologf, [])
    colormap jet
end


% find value of lowest frequency
[r vals]=radial_scan(autologf);
[pks, locs]=findpeaks(vals);
[~, pkloc]=max(pks);
rad0=r(locs(pkloc));
display(rad0);

if showfigures
    figure(10)
    plot(r, vals)
end

% convert back to pitch in original image
% adjust for rectangular size
ismax=max(size(imin));
ptch=rad0*ismax/is;

end
