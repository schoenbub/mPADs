function hexavar = map_var_hexa(objrefdc,hexaID)

% ; map post std onto hexagonal lattice
% ;
% ; input:  objrefdc:   refined objects
% ;         hexaID:     object IDs on hexagonal lattice
% ; output: post std on hexagonal lattice
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch


hexavar = NaN(size(hexaID));
indices = unique(objrefdc(6,:));
for j=1:length(indices)
    xy_obj_j = objrefdc(1:2,objrefdc(6,:)==indices(j));
    stdx = std(xy_obj_j(1,:));
    stdy = std(xy_obj_j(2,:));
    stdxy = sqrt( stdx*stdx + stdy*stdy );
    [idx_j_x, idx_j_y] = ind2sub(size(hexaID),...
        find(hexaID == indices(j),1));
    hexavar(idx_j_x,idx_j_y) = stdxy;
end