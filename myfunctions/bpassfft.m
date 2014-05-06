function res = bpassfft(arr,bpfiltsize)

% ; filter in fourier space by ring

% for debugging
showfigures = true;

% fourier transform
is = size(arr);
arr_fft = fft2(arr);
shiftmagn = [floor(is(1)/2)-1 floor(is(2)/2)-1];
arr_fft = circshift(arr_fft, shiftmagn);

if showfigures
    figure(11)
    imshow(arr_fft,[0 1])
end

% ring: outer diam = 2*bpfiltsize, inner diam = 1/2*bpfiltsize
ring = arr_fft.*0.;
[X Y] = meshgrid(-is(2)/2.+0.5:1:is(2)/2.-0.5,...
    -is(1)/2.+0.5:1:is(1)/2.-0.5);
XYdist = sqrt(X.^2+Y.^2);
ring(XYdist>(bpfiltsize/2.)) = 1.;
ring(XYdist>(2.*bpfiltsize)) = 0.;
h = fspecial('gaussian',[5 5],1.5);
ring = imfilter(ring,h);

if showfigures
    figure(12)
    imshow(ring,[])
end


% apply filter and do inverse fourier transform
arr_fft = arr_fft.*ring;


res = abs(ifft2(arr_fft));