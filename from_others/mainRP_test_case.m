% Image Processing for Nanopillar Displacement Analysis
% -----------------------------------------------------
% Assumtions: bf pillar image stored in 3rd channel ('_c003' by ImageJ)
%             membrane stain in 2nd channel         ('_c002' by ImageJ)

%clear all;

% INPUT VARIABLES
% ---------------
path='/Volumes/groupshare/Lab Member Data/Florian/from Ingmar/tiffs/';                    % path to directory where images are
bottom='12_G_bottom';                  % name of reference bottom image
top='12_G_top';                     % name of top images
nseq = 1;                   % how many images to track (for timelapse)
xy_size = 51.714*10^-9;     % xy pixel size in [m]
pillar_radius = 250*10^-9;  % pillar radius in [m]
pillar_spacing = 800*10^-9; % min spacing between two pillar centers [m]
k = 78*10^-3;               % spring constant of pillar in [N/m]
drift_res = 100;            % resolution of drift correction in [1/pixel]
threshold_bot = 0.90;           % thresholding value between [0-1]
threshold_top = 0.85;

% READ IMAGES and create xyt stack
R=imread([path bottom '.tif']);     % reference image
[nx ny] = size(R);
P = zeros(nx,ny,nseq);              % pillar image array
C = zeros(nx,ny,nseq);              % cell image array

for i=1:nseq
%     P(:,:,i)=im2double(imadjust(imread(path top '_t' num2str(i,'%0.3d') '_c003.tif'])));
%     C(:,:,i)=imread([path top '_t' num2str(i,'%0.3d') '_c002.tif']);
    P(:,:,i)=imadjust(imcomplement(uint8(imread([path top '_t' num2str(9,'%0.3d') '_c003.tif']))));
    C(:,:,i)=imread([path top '_t' num2str(9,'%0.3d') '_c002.tif']);
    C(:,:,i)= medfilt2(C(:,:,i));
end

% REMOVE XY DRIFT from top images (by Manuel Guizar)
ftR = fft2(R);        % fourier transform of ref. image
for i=i:nseq
    ftP = fft2(P(:,:,i));           % fourier transform of shifted image
    [shift ftP] = dftregistration(ftR, ftP,drift_res);
    P(:,:,i)=abs(ifft2(ftP));       % shift corrected image
	C(:,:,i)= shiftImage(C(:,:,i), shift(2), shift(3), shift(4));
end


% CELL DETECTION
C_outline = zeros(nx,ny,nseq);
C_area = zeros(nx,ny,nseq);
for i=1:nseq
    [C_outline(:,:,i) C_area(:,:,i)] = detectCell(uint8(C(:,:,i)));
end

% PARTICLE DETECTION (by Raghuveer Parthasarathy)
obj_size = round(2*pillar_radius/xy_size);    % object and neighbourhood size 

% analyze reference image
tmpobj = fo5_rp(R,'spatialfilter', obj_size, threshold_bot, 'radial');
tmpobj(5,:) = 1;
obj = tmpobj;
% analyze image sequence
for i=1:nseq
    tmpobj = fo5_rp(P(:,:,i), 'spatialfilter', obj_size, threshold_top, 'radial');
    tmpobj(5,:) = i+1;
    obj = [obj tmpobj];
end

% Link particles (by Raghuveer Parthasarathy)
cutoff = pillar_spacing/(2*xy_size);    % maximal pillar displacement in pixels
obj = nnlink_rp(obj, cutoff^2);

% ANALYZE TRACKING
% Calculate distances
[d_cell M1]= calcDistance(obj,  nseq, cutoff, C_area, nx, ny);  % OPTIONALLY with MASK
[d_outside M2] = calcDistance(obj, nseq, cutoff, imcomplement(C_area), nx, ny);
imagesc(M2+M1+C_outline*mean(mean(M1))); figure;

% VISUALIZE output
showPillars(R.*0.5,C.*0.5,C_outline,obj,1)      
figure;
hist(d_cell*xy_size*k*10^9,100); title('Histogram of Cell Pillars'); xlabel('Force [nN]'); ylabel('Pillar Count');
xlim([0 35]);
figure;
hist(d_outside*xy_size*k*10^9,100); title('Histogram of Sourround Pillars'); xlabel('Force [nN]'); ylabel('Pillar Count');
xlim([0 35]);
figure;
v = [d_cell'; d_outside'];
g = [ones(size(d_cell')); 2*ones(size(d_outside'))];
boxplot(v,g); title('Boxplot of Cell (1) and Surround (2) Pillars'); ylabel('Force [nN]');

% figure;
% boxplot(d_outside*xy_size*k*10^9); title('Boxplot of Sourround Pillars'); ylabel('Force [nN]');
