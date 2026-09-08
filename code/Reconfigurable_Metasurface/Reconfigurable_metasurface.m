%[text] # Reconfigurable Metasurface
%[text] Description: This code evaluates \[1, Eq. (16)\] element by element:
%[text] - Eq. (3): incident field at the metasurface under the far-field approximation, Ei(xm,ym) = sum\_n Cn \* exp(j(kx\_pn\*xm + ky\_pn\*ym))
%[text] - Eq. (2): Eo = Ei .\* M, with the aperture function M of Eq. (10) as  M(xm,ym;u,v) = exp(-j(u + k\*xa/za)xm - j(v + k\*ya/za)ym + j\*k\*(xm^2+ym^2)/(2\*za))
%[text] - Eq. (5): Fresnel propagation of Eo over the gap za to the probe
%[text] - Square-law detection: the measurement is |Ea(u,v)|^2 only. No phase. \
%[text] Because Eq. (5) contributes -j\*k\*(xm^2+ym^2)/(2\*za) and Eq.(2) contributes  +j\*k\*(xm^2+ym^2)/(2\*za), the quadratic (lens) terms cancel and the linear terms collapse to exp(j\[(kx\_pn-u)xm + (ky\_pn-v)ym\]) -- which is Eq. (16), peaking at (u,v) = (kx\_pn, ky\_pn). Running the full chain rather than Eq. (16) is what lets the script also reproduce the DEGRADATIONS the paper  reports: probe-position mismatch (Fig. 8) and 2-bit quantisation (\[1,Sec. III\]).

%[text] ## References
%[text] \[1\] W. Li, N. Wang, and J. Qi, "Direct Angle of Arrival (AOA) Estimation Using a Metasurface Antenna With Single Frequency Phaseless Measurements Obeyed Schwarz Inequality," IEEE Transactions on Microwave Theory and Techniques, vol. 72, no. 4, pp. 2677–2685, Apr. 2024, doi: 10.1109/TMTT.2023.3314063.  

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
