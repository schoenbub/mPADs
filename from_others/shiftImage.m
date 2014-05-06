function [Out] = shiftImage(Img, diffphase, row_shift, col_shift)
% to be used with dftregistration.m by Manuel Guizar
% copy & pasted by F. Herzog

buf2ft=fft2(Img);
[nr,nc]=size(buf2ft);
Nr = ifftshift([-fix(nr/2):ceil(nr/2)-1]);
Nc = ifftshift([-fix(nc/2):ceil(nc/2)-1]);
[Nc,Nr] = meshgrid(Nc,Nr);
Greg = buf2ft.*exp(i*2*pi*(-row_shift*Nr/nr-col_shift*Nc/nc));
Greg = Greg*exp(i*diffphase);
Out = abs(ifft2(Greg));
%Out = uint8(Out);
end
