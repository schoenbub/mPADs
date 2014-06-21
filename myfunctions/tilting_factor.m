function tf = tilting_factor(nu)

% ; tilting factor for substrate warping
% ; 
% ; see publication: Schoen et al., Nano Lett. 2010, 10, 1823–1830
% ;                  DOI: 10.1021/nl100533c
% ;
% ; inputs:
% ;     nu: poisson number
% ; output:
% ;     tf: tilting factor
% ; 
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

tf = 1.3*(1 + nu)/(2*pi)*(2*(1 - nu) + (1 - 1/(4*(1 - nu))));