function objdc = drift_correct(objref,trackIDs)

% ; drift correction between slices in stack
% ; trackIDs: gives tracks which should be used
% ; the correction is then applied to all posts

% slice numbers
slice_range = unique(objref(5,:));

% objects in slice 1
obj_j = objref(:,objref(5,:)==slice_range(1));
obj_j = sort(obj_j,6);
objdc = obj_j;
% indices of posts of given track IDs
indices = trackIDs;
for i=1:length(indices)
    indices(i) = find(obj_j(6,:) == trackIDs(i),1,'first');
end
% posts from indices
obj_j_mask = obj_j(:,indices);
x1 =  obj_j_mask(1,:);
y1 =  obj_j_mask(2,:);
xst = slice_range.*0.;
yst = xst;
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
    % correct ALL posts versus bottom slice
    obj_j(1,:) = obj_j(1,:)-dxj1;
    obj_j(2,:) = obj_j(2,:)-dyj1;
    % amend to result object
    objdc = [objdc obj_j];
    % amend to xy data for plot
    xst(j) = dxj1;
    yst(j) = dyj1;
end

% show fit results
figure(21)
hold off
plot(2:length(xst)+1,xst,'ok')
hold on
plot(2:length(yst)+1,yst,'or')
xlabel('slice')
ylabel('dx, dy (pixel)')