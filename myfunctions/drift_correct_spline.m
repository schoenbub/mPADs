function objdc = drift_correct_spline(objref,trackIDs)

% ; drift correction between slices in stack
% ; shift of slices in stack is fitted by spline
% ; 
% ; inputs:
% ;     objref: refined objects
% ;     trackIDs: IDs of tracks which should be used
% ; output:
% ;     objdc: the correction is then applied to all posts
% ; 
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

% slice numbers
slice_range = unique(objref(5,:));

% objects in slice 1
obj_j = objref(:,objref(5,:)==slice_range(1));
obj_j = sort(obj_j,6);

% indices of posts of given track IDs
indices = trackIDs;
for i=1:length(indices)
    indices(i) = find(obj_j(6,:) == trackIDs(i),1,'first');
end
% posts from indices
obj_j_mask = obj_j(:,indices);
x1 =  obj_j_mask(1,:);
y1 =  obj_j_mask(2,:);
% built up stack
dxystack = zeros([length(slice_range) 2]);
stdxystack = zeros([length(slice_range) 2]);
for j = 2:length(slice_range)
    % select slice j
    obj_j = objref(:,objref(5,:)==slice_range(j));
    obj_j = sort(obj_j,6);
    % indices of posts of given track IDs
    for i=1:length(indices)
        indices(i) = find(obj_j(6,:)==trackIDs(i),1,'first');
    end
    % posts from indices
    obj_j_mask = obj_j(:,indices);
    % mean displacement
    xj = obj_j_mask(1,:);
    yj = obj_j_mask(2,:);
    dxj1 = mean(xj - x1);
    dyj1 = mean(yj - y1);
    dxystack(j,1) = dxj1;
    dxystack(j,2) = dyj1;
    %std for each slice, used for interpolation
    stdxystack(j,1) = std(xj - x1);
    stdxystack(j,2) = std(yj - y1);
end

% spline fit of average displacements between slices
% use data from slice 2:end only
% but interpolate for whole stack range
cfit1 = slice_range(2:end);
smoothness = 0.1; % smoothness of spline, not critical, smaller = smoother
dxt = csaps(cfit1,dxystack(2:end,1),smoothness,slice_range,1./stdxystack(2:end,1).^2);
dyt = csaps(cfit1,dxystack(2:end,2),smoothness,slice_range,1./stdxystack(2:end,2).^2);

% show fit results
figure(21)
hold off
plot(cfit1,dxystack(2:end,1),'ok',slice_range,dxt,'-k')
hold on
plot(cfit1,dxystack(2:end,2),'or',slice_range,dyt,'-r')
xlabel('slice')
ylabel('dx, dy (pixel)')

% apply correction and assemble output

% objects in slice 1
objdc = [];
for j = 1:length(slice_range)
    obj_j = objref(:,objref(5,:)==slice_range(j));
    obj_j(1,:) = obj_j(1,:)-dxt(j);
    obj_j(2,:) = obj_j(2,:)-dyt(j);
    % amend to result object
    objdc = [objdc obj_j];
end

