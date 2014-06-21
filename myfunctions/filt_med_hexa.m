function hexafilt = filt_med_hexa(hexaID,hexavar)


% ; median filtering of hexagonal lattice image
% ; uses post plus its 6 neighbors
% ; 
% ; input:  hexaID:  IDs of posts on hexagonal lattice
% ;         hexavar:  std of post positions on hexagonal lattice
% ; output: hexafilt: std filtered by a median filter
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch


% do median filtering over post and its 6 nearest neighbors
% therefore: pad array
padded_hexa = NaN(size(hexaID)+2);
padded_hexa(2:end-1,2:end-1) = hexavar;
% determine median filtered hexa 'image'
hexafilt = NaN(size(hexaID));
ker = [1, 1, NaN; 1, 1, 1; NaN, 1, 1];
for ix=1:size(hexaID,1)
    for iy=1:size(hexaID,2)
        roi = padded_hexa(ix:ix+2,iy:iy+2).*ker;
        im = median(roi(~isnan(roi)));
        hexafilt(ix,iy) = im;
    end
end
% make those NaN which don't have a valid ID
hexafilt(isnan(hexaID)) = NaN;