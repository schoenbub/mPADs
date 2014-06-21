function show_results_driftcorrection(objID_2nd,fignum)

% ; assemble figure that summarizes the results from the drift correction
% ; inputs are:
% ;         objID_2nd: ID of tracks used in 2nd round of registration
% ;         fignum: number of figure window
% ; output: none. 
% ; subplots are: 
% ; upper left: tracks of posts, color-coded standard deviation of tracks
% ; upper right: white posts are used for second registration
% ; lower left: histogram of standard deviation of post tracks
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

global dat allpar

% drift-corrected data
objrefdc = dat.objrefdc;
% for size of post circles
pitch = dat.pitch;
% color option
colormax = allpar.dc3;
% which image to overlay: top
sl = max(objrefdc(5,:));

% ID of valid objects/posts
obj_range = unique(objrefdc(6,:));

figure(fignum);

%% plot refined tracks and color-coded variance
subplot(2,2,1); %upper left

radpost=floor(pitch/4.);
obj_std = zeros([1 length(obj_range)]);
imshow(dat.stack(:,:,sl), []); 
title('drift corrected post tracks')
for j = 1:numel(obj_range)
    objs_j = objrefdc(:,objrefdc(6,:)==obj_range(j));  % track j
    x = objs_j(1,:);  % x positions of this track
    y = objs_j(2,:);  % y positions of this track
    line(x,y,'Color','r','LineWidth',2);
    stdx = std(x);
    stdy = std(y);
    stdxy = sqrt( stdx*stdx + stdy*stdy );
    obj_std(j) = stdxy;
    huevalue = 0.75*(1 - min([stdxy/colormax, 1]));
    rectangle('Position', [x(end)-radpost ...
        y(end)-radpost 2*radpost 2*radpost], ...
        'Curvature', [1 1], ...
        'Linewidth', 2.0, 'EdgeColor', hsv2rgb([huevalue 1 1]));
end


%% plot which posts were used in second round
subplot(2,2,2); % upper right

radpost=floor(pitch/3.);
imshow(dat.stack(:,:,sl).*0., []); 
title('used posts in second round')
for j = 1:numel(obj_range);
    objs_j = objrefdc(:,objrefdc(6,:)==obj_range(j));  % track j
    % position
    x = objs_j(1,:);
    y = objs_j(2,:);
    % color
    if sum(objID_2nd==obj_range(j)) == 1
        colopt = [1 1 1];
    else
        huevalue = 0.75*(1 - min([obj_std(j)/colormax, 1]));
        colopt = hsv2rgb([huevalue 1 1]);
    end
    % plot
    rectangle('Position', [x(1)-radpost ...
        y(1)-radpost 2*radpost 2*radpost], ...
        'Curvature', [1 1], ...
        'Linewidth', 2.0, 'EdgeColor', colopt,...
        'FaceColor',colopt);
end

%% show histogram of std

subplot(2,2,3); %lower right

xbin = 0.05:0.1:5;
hist(obj_std,xbin)