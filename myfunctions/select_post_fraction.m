function objID_out = select_post_fraction(objdc,frac4ref)

% ; determines the track IDs of posts that show little poitional variance
% ; input:  objrefdc:  objects
% ;         frac4ref:  quantile of posts
% ; output: objID_out: IDs of the quantile of posts below frac4ref
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

% IDs of objects
obj_range = unique(objdc(6,:));

% the standard deviation of their position
obj_std = obj_range.*0.;
for j = 1:length(obj_range)
    objs_j = objdc(:,objdc(6,:)==obj_range(j));  % track j
    x = objs_j(1,:);  % x positions of this track
    y = objs_j(2,:);  % y positions of this track
    stdx = std(x);
    stdy = std(y);
    stdxy = sqrt( stdx*stdx + stdy*stdy );
    obj_std(j) = stdxy;
end

%fraction of posts with std below cutoff
std_cutoff = quantile(obj_std,frac4ref);
objID_out = obj_range(obj_std < std_cutoff);