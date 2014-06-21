function defl_ang_force = calc_forces(objrefdc)

% ; calculate forces from post tracks
% ; different methods possible: at the moment, only spline fit is
% implemented
% ;
% ; input:  objrefdc:       refined objects
% ;
% ; output: defl_ang_force: post IDs, deflection, angles, forces 
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

global allpar dat
                
% process parameters
pixel_size = allpar.pixelsize;
pd = allpar.mpadD;
ph = allpar.mpadL;
emod = allpar.mpadE;
nu = allpar.mpadNu;
method_force = allpar.force1;
smoothness_spline = allpar.force2;


slice_range = sort(unique(objrefdc(5,:)));
obj_range = unique(objrefdc(6,:));

% calculation
switch method_force

    case 0 % spline fit of deflection profile
        %%

        % z positions of slices in µm
        zpos = (slice_range-slice_range(1))./...
            (slice_range(end)-slice_range(1)).*ph;
        % display progress bar
        progtitle = sprintf('fitting deflection profiles by spline...  '); 
        progbar = waitbar(0, progtitle);

        % loop through posts
        defl_ang_force = repmat(obj_range,[4 1]);
        for j = 1:numel(obj_range)
            % object j
            obj_j = objrefdc(:,objrefdc(6,:)==obj_range(j));
            obj_j = sort(obj_j,5); %sort according to slice number
            x = obj_j(1,:);
            y = obj_j(2,:);
            % fitting of spline
            xfit = csaps(zpos,x,smoothness_spline,[0. ph]);
            yfit = csaps(zpos,y,smoothness_spline,[0. ph]);
            % deflection and direction
            dx = xfit(end)-xfit(1);
            dy = yfit(end)-yfit(1);
            defl_ang_force(2,j) = sqrt(dx*dx + dy*dy);
            defl_ang_force(3,j) = atan2(dy,dx);
            % show progress
            if mod(j,20) == 0
                waitbar(j/numel(obj_range), progbar, progtitle);
            end
        end
        close(progbar);

        % force from deflection
        defl_ang_force(4,:) = force_hooke(...
            defl_ang_force(2,:)*pixel_size,pd,ph,emod,nu);

    case 1 % fit with full profile (bending plus shear plus tilting)
                %%
                
    case 2 % use directly refined positions (top-bottom)
                %%
                
end