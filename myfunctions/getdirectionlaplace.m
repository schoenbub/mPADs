function alpha=getdirectionlaplace(im1f,sigma)
if nargin==1
    sigma=0;
end

 h6l=[1 2 0 -2 -1];
 h6=zeros(5);
 h6(1,:)=h6l;
 h6(2,:)=2*h6l;h6(3,:)=3*h6l;h6(4,:)=2*h6l;h6(5,:)=1*h6l;

dxx=h6.^2;
dyy=dxx';
dxy=h6.*h6';
    

im2=imfilter(im1f,dxx,'replicate');
im3=imfilter(im1f,dyy,'replicate');
im4=imfilter(im1f,dxy,'replicate');
ix=im2-im3;
iy=-2*im4;

if sigma==0
    alpha=atan2(iy,ix)/2;
    % rdirect=sqrt(ix.^2 + iy.^2);
    % rdirect=rdirect/max(rdirect(:));
else
    hg = fspecial('gaussian', 20, sigma);
    im1t=im1f/max(im1f(:));
    ixf=imfilter(ix.*im1t,hg,'replicate')./imfilter(im1t,hg,'replicate');
    iyf=imfilter(iy.*im1t,hg,'replicate')./imfilter(im1t,hg,'replicate');
    alpha2=atan2(iyf,ixf)/2;
    % 
    % rdirect=sqrt(ixf.^2 + iyf.^2);
    % rdirect=rdirect/max(rdirect(:));
    alpha=alpha2;
end
