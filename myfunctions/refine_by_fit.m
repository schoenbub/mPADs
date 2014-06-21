function obj_refined=refine_by_fit(img,objs,roisize,method)

% ; refine positions using the gradient method by Raghuveer Parthasarathy
% ; see his function "fo5_rp.m"
% ;
% ; input:
% ;         img: image
% ;         obj: initial objects
% ;         roisize: size of region of interest
% ;         method: 0= radial symmetric gradient by RP, 1= COM
% ; 
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch


%% x,y initial center positions
x = objs(1,:);
y = objs(2,:);

%% Determine ROIs containing neighborhoods
rect = zeros(length(x), 4);
% Compute the first local neighborhood to know the image size, and then all
% the rest.  A bit inelegant; could calculate all rect's at once...
% Skip if there are no objects to find
if ~isempty(x)
    rect(1,:) = [(round(x(1)) - floor(roisize/2)) (round(y(1)) - floor(roisize/2)) (roisize-1) (roisize-1)];
    cropimg1 = img(rect(1,2):(rect(1,2)+roisize-1), rect(1,1):(rect(1,1)+roisize-1));
    % all the other neighborhoods
    cropimg = repmat(cropimg1, [1 1 length(x)]); % to allocate memory
    for k = 2:length(x)
        rect(k,:) = [(round(x(k)) - floor(roisize/2)) (round(y(k)) - floor(roisize/2)) (roisize-1) (roisize-1)];
        cropimg(:,:,k) = img(rect(k,2):(rect(k,2)+roisize-1), rect(k,1):(rect(k,1)+roisize-1));
    end
end

%% Compute "masses" (particle brightness)
% Calculate "mass" (intensity) in each neighborhood
% inner disk = neighborhood
% subtract background, estimated from mean of non-neighborhood px.
nhood = getnhood(strel('disk', floor(roisize/2),0));  
meanbkg = zeros(1, length(x));
savemass = zeros(1, length(x));
for k = 1:length(x)
    tempreg = cropimg(:,:,k);
    if ~(size(nhood)==size(tempreg))
        display(['incompatible size: ' num2str(size(nhood)) ' versus ' num2str(size(tempreg))])
    end
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
switch method
    case 0
        % Radial-symmetry based fit -- fast, accurate
        [xcent ycent sigma meand2] = radialcenter_stk(cropimg) ;
        % Is the center within reasonable bounds?
        % If not, replace with centroid
        % frequency of bad cases ~ 1/100,000 !  (Extremely rare)
        badcase = find(abs(xcent - Lx/2)>1.5*Lx | abs(ycent - Ly/2)>1.5*Ly);
        for j = badcase
            ci = cropimg(:,:,j);
            xcent(j) = sum(sum(ci) .* lsumx) / sum(sum(ci));
            ycent(j) = sum(sum(ci,2) .* lsumy') / sum(sum(ci));
        end
    case 1
        % centroid (center of mass) fit
        % don't subtract background
        % consider all points at once (not looping)
        sumcropimg = sum(sum(cropimg,1),2); % length = length(x)
        xcent = sum(sum(cropimg,1).*repmat(lsumx, [1,1,length(x)]),2) ./ sumcropimg;
        xcent = reshape(xcent, [1 length(x)]);
        ycent = sum(sum(cropimg,2).*repmat(lsumy', [1,1,length(x)]),1) ./ sumcropimg;
        ycent = reshape(ycent, [1 length(x)]);
        % for sigma
        rptxcent = reshape(repmat(xcent, [length(lsumx), 1]), 1, length(lsumx), length(x));
        rptycent = reshape(repmat(ycent, [length(lsumy), 1]), length(lsumy), 1, length(y));
        x2cent = sum(sum(cropimg,1).*...
                    repmat(lsumx, [1,1,length(x)])-rptxcent.*...
                    repmat(lsumx, [1,1,length(x)])-rptxcent ,2) ./ sumcropimg;
        x2cent = reshape(x2cent, [1 length(x)]);
        y2cent = sum(sum(cropimg,2).*...
                    repmat(lsumy', [1,1,length(x)])-rptycent.*...
                    repmat(lsumy', [1,1,length(x)])-rptycent ,1) ./ sumcropimg;
        y2cent = reshape(y2cent, [1 length(x)]);
        sigma = sqrt(x2cent.*x2cent + y2cent.*y2cent);
    otherwise
        errordlg('Unknown method! [refine_by_fit]');
end
    
% center position relative to image boundary
% Note that the *center* of the upper left pixel is (1,1)
xn = xcent + rect(:,1)' - 1; % -1 is to correct for matlab indexing
yn = ycent + rect(:,2)' - 1;

% output
obj_refined = objs;
obj_refined(1,:) = xn;
obj_refined(2,:) = yn;
