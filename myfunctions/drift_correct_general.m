function obj_out = drift_correct_general(obj_in,objID,method)

% ; correct drift between slices
% ; calls subroutines
% ; input:  obj_in: object
% ;         objID:  IDs of objects that shall be used
% ;         method: 0=mean, 1=spline-fit of mean
% ; output: drift-corrected objects
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

switch method
    case 0 % just by mean per slice
        obj_out = drift_correct(obj_in,objID);
    case 1 % spline interpolation over stack
        obj_out = drift_correct_spline(obj_in,objID);
end