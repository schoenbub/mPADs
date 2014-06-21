function [hexadefl, hexaang, hexaforce] = map_results_hexa(defl_ang_force,hexaID)

% ; save deflection, direction ,and force info on hexagonal lattice
% ;
% ; input:  defl_ang_force:   results of force calculations
% ;         hexaID:           object IDs on hexagonal lattice
% ; output: hexadefl:         post deflections on hexagonal lattice
% ;         hexaang:          force directions on hexagonal lattice
% ;         hexaforce:        force magnitude on hexagonal lattice
% ; output also saved in global variable)
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

global dat

% output arrays
hexadefl = NaN(size(hexaID));
hexaang = hexadefl;
hexaforce = hexadefl;

% post IDs
indices = defl_ang_force(1,:);

% get x,y corrdinates of bottom and save into arrays
for j=1:length(indices)
    [idx_j_x, idx_j_y] = ind2sub(size(hexaID),...
        find(hexaID == indices(j),1));
    hexadefl(idx_j_x,idx_j_y) = defl_ang_force(2,j);
    hexaang(idx_j_x,idx_j_y) = defl_ang_force(3,j);
    hexaforce(idx_j_x,idx_j_y) = defl_ang_force(4,j);
end

% save into global variables
dat.hexadefl = hexadefl;
dat.hexaang = hexaang;
dat.hexaforce = hexaforce;