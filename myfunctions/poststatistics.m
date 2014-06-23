function [xyposts, IDposts, angposts, forceposts, labelposts, cellavgforce,...
    cellmaxforce, celltotalforce, cellnetforce, cellnetang, f0median, kspring] =...
    poststatistics(L)

% ; statistics of post forces
% ;
% ; inputs:     L:      label matrix
% ;                     all others contained in global variables dat and allpar
% ; 
% ; outputs: the names should tell what you get...
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

% global variables
global dat allpar

% load post data
hx = dat.hexaposx;
hy = dat.hexaposy;
hID = dat.hexaIDs;
ha = dat.hexaang;
hf = dat.hexaforce;
% convert into linear lists
xyposts = [hx(~isnan(hID)), hy(~isnan(hID))];
IDposts = hID(~isnan(hID));
angposts = ha(~isnan(hID));
forceposts = hf(~isnan(hID));
% linear list for region label (that contains this post)
labelposts = 0*IDposts;
for k=1:length(xyposts)
    labelposts(k) = L(round(xyposts(k,2)),round(xyposts(k,1)));
end
% force statistics over individual cells
cellavgforce = zeros([1 max(L(:))]);
cellmaxforce = cellavgforce;
celltotalforce = cellavgforce;
cellnetforce = cellavgforce;
cellnetang = cellavgforce;
for i=1:max(L(:))
    % force of posts under cell
    fi = forceposts(labelposts == i);
    fi = fi(~isnan(fi));
    % average force
    cellavgforce(i) = mean(fi);
    % total force
    celltotalforce(i) = sum(fi);
    % maximum force
    cellmaxforce(i) = max(fi);
    % angles of forces
    fa = angposts(labelposts == i);
    % vectorial sum of forces (=net or residual force)
    cellfx = cos(fa).*fi;
    cellfy = sin(fa).*fi;
    cellnetx = sum(cellfx);
    cellnety = sum(cellfy);
    cellnetforce(i) = sqrt(cellnetx.^2 + cellnety.^2);
    cellnetang(i) = atan2(cellnety,cellnetx);
end
% outside cells: determine median force (~ measurement resolution)
f0 = forceposts(labelposts == 0);
f0median = median(f0);
% spring constant of mPAD array
kspring = force_hooke(1,allpar.mpadD, allpar.mpadL,...
    allpar.mpadE, allpar.mpadNu);
