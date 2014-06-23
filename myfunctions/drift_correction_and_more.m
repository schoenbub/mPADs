function objID_still = drift_correction_and_more()

% ; correct for drift between slices in stack
% ;
% ; input:  none    (all in global variables)
% ;
% ; output: objID_still     post IDs of posts used in second round
% ;                         (all in global variables)
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

global allpar dat

% process parameters
method = 1;
outl = allpar.dc1;
frac4refine = allpar.dc2;

% load refined positions
objref = dat.objref;

% map posts (IDs) onto hexagonal grid
hexa_lattice = map_onto_hexa(objref);
% save into global variable
dat.hexaIDs = hexa_lattice;
% save positions in hexagonal map
[hx hy] = map_pos_hexa(objref,hexa_lattice);
dat.hexaposx = hx;
dat.hexaposy = hy;


% first correct globally (all posts, by mean displacement)
trackIDs = unique(objref(6,:));
objrefdc = drift_correct(objref,trackIDs);

% map of post variances
var_lattice = map_var_hexa(objrefdc,hexa_lattice);
% show variance map
figure(56)
subplot(2,3,1)
imshow(var_lattice',[0 2])
colormap jet
% median filtering
filtered_hexa = filt_med_hexa(hexa_lattice,var_lattice);
% show filtered
subplot(2,3,2)
imshow(filtered_hexa',[0 2])
colormap jet

%% second round: use fraction of posts that showed little movement
% determine fraction of posts and get their ID

if outl ==1
    % sort out the posts within the cell outlines
    L = dat.labelmask;
    xyposts = round([hx(~isnan(hexa_lattice)), hy(~isnan(hexa_lattice))]);
    IDposts = hexa_lattice(~isnan(hexa_lattice));
    for k=fliplr(1:length(xyposts))
        if L(xyposts(k,2),xyposts(k,1))>0
            IDposts(k) = [];
        end
    end
    objID_still = squeeze(IDposts); 
    % ...the same on the hexagonal lattice
    hexa4refine = NaN(size(hexa_lattice));
    for j=1:length(objID_still)
        hexa4refine(hexa_lattice == objID_still(j)) = objID_still(j);
    end

else
    hexa4refine = hexa_lattice;
end
% determine posts that shall be used for 2nd round
objID_still = select_post_fraction(hexa4refine,filtered_hexa,...
    frac4refine);
% show this fraction
hexa_still = uint8(sign(hexa_lattice)*10);
for j=1:length(objID_still)
    id_j = objID_still(j);
    hexa_still(hexa_lattice == id_j) = 2;
end
subplot(2,3,3)
imshow(hexa_still',[0 10])
colormap jet

% 2nd refinement
objrefdc = drift_correct_general(objrefdc,objID_still,method);

% save into global variable
dat.objrefdc = objrefdc;
% save variance hexagonal map
var_lattice = map_var_hexa(objrefdc,hexa_lattice);
dat.hexavar = var_lattice;