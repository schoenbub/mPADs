function force = force_hooke(defl,pdiam,pheight,emod,nu)

% ; determine force from post deflection (top-bottom)
% ; 
% ; account for bending, shearing, and substrate warping
% ; see publication: Schoen et al., Nano Lett. 2010, 10, 1823–1830
% ;                  DOI: 10.1021/nl100533c
% ;
% ; inputs:
% ;     defl: deflection [um]
% ;     pdiam: post diameter [um]
% ;     pheight: post height [um]
% ;     emod: Youngs' modulus [MPa]
% ;     nu: Poisson ratio
% ; output:
% ;     force: force [nN]
% ; 
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

% tilting factor
tf = tilting_factor(nu);

% spring stiffness, units = 1/MPa*um =N/m
pr = pheight/pdiam; %post aspect ratio
k_post = 1./((16/3*pr^3 + (7 + 6*nu)/3*pr + 8*tf*pr^2) *4/(pi*emod*pdiam));

% force in nN according to Hooke's law
force = defl.*k_post.*1000.;

