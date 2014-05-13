function obj_out = discard_incomplete(obj_in)

% ; get rid of tracks that don't span all slices
% ; copyright Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

tracks_range = unique(obj_in(6,:));
nsl = length(unique(obj_in(5,:)));
for k = tracks_range
    lentrack = sum(obj_in(6,:) == k);
    if lentrack < nsl
       cullind = find(obj_in(6,:) == k);
       obj_in(6, cullind) = 0; % particles with trackid 0 are culled at end
    end
end
% now get rid of incomplete posts
obj_in(:, (obj_in(6,:) == 0)) = [];

% output
obj_out = obj_in;
