function [hexaposx hexaposy] = map_pos_hexa(objrefdc,hexaID)

% ; map post positions onto hexagonal lattice
% ;
% ; input:  objrefdc:   refined objects
% ;         hexaID:     object IDs on hexagonal lattice
% ; output: hexaposx:   x positions on hexagonal lattice
% ;         hexaposy:   y positions on hexagonal lattice
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

% output arrays
hexaposx = NaN(size(hexaID));
hexaposy = hexaposx;
% post IDs
indices = unique(objrefdc(6,:));
% get x,y corrdinates of bottom and save into arrays
for j=1:length(indices)
    xy_obj_j = objrefdc(1:2,objrefdc(6,:)==indices(j));
    x = xy_obj_j(1,1);
    y = xy_obj_j(2,1);
    [idx_j_x, idx_j_y] = ind2sub(size(hexaID),...
        find(hexaID == indices(j),1));
    hexaposx(idx_j_x,idx_j_y) = x;
    hexaposy(idx_j_x,idx_j_y) = y;
end