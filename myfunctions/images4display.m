function [im_mpad, im_actin, B] = images4display(L)

% ; prepare images for display
% ;
% ; inputs: 	L:          label matrix
% ;                         all others are in the global variable dat
% ;
% ; outputs:    im_mpad:    image of mPAD channel
% ;             im_actin:   image of actin channel for overlay
% ;             B:          cell array with list of boundaries
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

global dat

% post array (top slice)
im_mpad = dat.stack(:,:,max(dat.objrefdc(5,:)));
im_mpad = double(im_mpad);
im_mpad = 0.5 * (im_mpad - min(im_mpad(:)))/...
    (max(im_mpad(:)) - min(im_mpad(:)));
% actin image (current)
nup = dat.currentslice + size(dat.stack,3)/2;
im_actin = dat.stack(:,:,nup);
im_actin = double(im_actin);
im_actin = 2 * (im_actin - min(im_actin(:)))/...
    (max(im_actin(:)) - min(im_actin(:)));
im_actin(im_actin>1)=1;
% outline of cells
B = bwboundaries(L,8,'noholes');