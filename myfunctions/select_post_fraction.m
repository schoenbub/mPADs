function objID_out = select_post_fraction(hexaID,hexavar,frac4ref)

% ; determines the track IDs of posts that show little poitional variance
% ; input:  hexaID:  object IDs on hexagonal lattice
% ;         hexavar: variance on hexagonal lattice
% ;         frac4ref:  quantile of posts
% ; output: objID_out: IDs of the quantile of posts below frac4ref
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

% flatten into list that is easier to handle
varlist = hexavar(~isnan(hexaID)); %use only those provided
IDlist = hexaID(~isnan(hexaID));

% determine cutoff
std_cutoff = quantile(varlist,frac4ref);

% select IDs of posts whose std is below cutoff
objID_out = sort(IDlist(varlist<std_cutoff));


% %% earlier implementation
% % the standard deviation of their position
% obj_std = obj_range.*0.;
% for j = 1:length(obj_range)
%     objs_j = objdc(:,objdc(6,:)==obj_range(j));  % track j
%     x = objs_j(1,:);  % x positions of this track
%     y = objs_j(2,:);  % y positions of this track
%     stdx = std(x);
%     stdy = std(y);
%     stdxy = sqrt( stdx*stdx + stdy*stdy );
%     obj_std(j) = stdxy;
% end
% 
% %fraction of posts with std below cutoff
% std_cutoff = quantile(obj_std,frac4ref);
% objID_out = obj_range(obj_std < std_cutoff);