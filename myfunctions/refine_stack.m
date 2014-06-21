function objref = refine_stack(objinit,slice_range,method)

% ; loop through stack and refine positions
% ; input:
% ;     objinit: initially found objects
% ;     slice_range: slices to process
% ;     method: 0=radial symmetric gradient, 1= COM
% ; output:
% ;     refined objects
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

global dat
pitch = dat.pitch;
roisize = round(pitch/2.);
if mod(roisize,2) == 0
    roisize = roisize-1;
end

curr = slice_range(1);   % bottom slice
img = dat.stack(:,:,curr);
objs_j = objinit(:,objinit(5,:)==curr);  
objref = refine_by_fit(img,objs_j,roisize,method);
for j = 2:length(slice_range)
    curr = slice_range(j);
    img = dat.stack(:,:,curr);
    objs_j = objinit(:,objinit(5,:)==curr); % selected slice
    objs_j = refine_by_fit(img,objs_j,roisize,method);
    objref = [objref objs_j];
end