function [objs] = find_centers(img, pitch, nhoodctrs)

% for debugging
showplots=true;

%% center positions for ROIs
x = nhoodctrs(:,1);
y = nhoodctrs(:,2);    

% Get rid of maxima too close to the edge
lenx = 2*(floor(pitch*0.3)) + 1; % size for ROI
leny = lenx;
edgeind = ((x < lenx/2) | (x > (size(img,2) - lenx/2))) | ...
    ((y < leny/2) | (y > (size(img,1) - leny/2)));
x(edgeind) = [];
y(edgeind) = [];

% get rid of bad neighborhood centers
wNan = find(isnan(x) | isnan(y));
x(wNan) = [];
y(wNan) = [];

%% Determine ROIs
rect = zeros(length(x), 4);
% Compute the first ROI then all
if ~isempty(x)
    rect(1,:) = [(round(x(1)) - floor(lenx/2)) (round(y(1)) - floor(leny/2)) (lenx-1) (leny-1)];
    cropimg1 = img(rect(1,2):(rect(1,2)+lenx-1), rect(1,1):(rect(1,1)+lenx-1));
    % all the other neighborhoods
    cropimg = repmat(cropimg1, [1 1 length(x)]); % to allocate memory
    for k = 2:length(x)
        rect(k,:) = [(round(x(k)) - floor(lenx/2)) (round(y(k)) - floor(leny/2)) (lenx-1) (leny-1)];
        cropimg(:,:,k) = img(rect(k,2):(rect(k,2)+lenx-1), rect(k,1):(rect(k,1)+lenx-1));
    end
end

%% Compute "masses" (particle brightness)
% Calculate "mass" (intensity) in each neighborhood
% subtract background, estimated from mean of non-neighborhood px.
nhood = getnhood(strel('disk', floor(lenx/2),0));
meanbkg = zeros(1, length(x));
savemass = zeros(1, length(x));
for k = 1:length(x)
    tempreg = cropimg(:,:,k);
    cropreg = tempreg(nhood);
    bkgreg  = tempreg(~nhood);
    meanbkg(k) = mean(bkgreg(:));
    savemass(k) = sum(cropreg(:)) - sum(nhood(:))*meanbkg(k);
end

%% Refine positions
% Do refinement (find center) around each local max
xcent = zeros(1,length(x));
ycent = zeros(1,length(x));
sigma = zeros(1,length(x));
lsumx = 1:size(cropimg,2);
lsumy = 1:size(cropimg,1);
Lx = lsumx(end);
Ly = lsumy(end);
meand2 = zeros(1, length(x));
% Radial-symmetry based fit -- fast, accurate
[xcent ycent sigma meand2] = radialcenter_stk(cropimg) ;
% Is the center within reasonable bounds? If not, replace with centroid
badcase = find(abs(xcent - Lx/2)>1.5*Lx | abs(ycent - Ly/2)>1.5*Ly);
for j = badcase
    ci = cropimg(:,:,j);
    xcent(j) = sum(sum(ci) .* lsumx) / sum(sum(ci));
    ycent(j) = sum(sum(ci,2) .* lsumy') / sum(sum(ci));
end

% center position relative to image boundary
% Note that the *center* of the upper left pixel is (1,1)
xn = xcent + rect(:,1)' - 1; % -1 is to correct for matlab indexing
yn = ycent + rect(:,2)' - 1;

%% Plot found centers
if showplots
    figure(6);
    imshow(zeros(size(img))); title('6 particle centers')
    for j=1:length(xn)
        rectangle('Position', [xn(j)-1 yn(j)-1 2 2], 'Curvature', [1 1], ...
            'Linewidth', 2.0, 'EdgeColor', [1.0 1.0 0.3]);
    end
end

%% Create objs matrix
nrows = 8;
objs = zeros(nrows, length(xn));
objs(1,:) = xn;
objs(2,:) = yn;
objs(3,:) = savemass;
objs(4,:) = 1:length(x);
objs(7,:) = sigma;
objs(8,:) = meand2;

end