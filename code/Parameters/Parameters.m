%[text] # Parameters
%[text] #### Transmission parameters
fc=28*10^9;%transmission frequency
lambda=physconst('LightSpeed')/fc; %wavelength
kappa=2*pi/lambda; %wavenumber
%[text] #### Channel parameters

%[text] #### Noise parameters
% Noise and interference parameters
noiseFigure = 7;                             % dB see [1, Tab. 6-1]
thermalNoiseDensity = -174;                  % dBm/Hz [11, Tab. 5, entry (14)]
%Interference noise
rxInterfDensity = -165.7;                    % dBm/Hz, see [3]
rxInterfDensity = -Inf;                    % no interference noise

% Calculate the corresponding noise power
% Receiver thermal noise density including noise figure
rxNoiseDensity = thermalNoiseDensity + noiseFigure;   % dBm/Hz

% Sum noise and interference in linear mW/Hz
totalNoiseDensity_dBHz = 10*log10(10^((rxNoiseDensity-30)/10) + 10^((rxInterfDensity-30)/10));

% Total noise power over bandwidth BW
noisePower_dB = totalNoiseDensity_dBHz + 10*log10(BW);
%[text] #### RECONFIGURABLE METASURFACE  Sm  
%[text] Placed in the XmYm plane
% [4,Sec. II-A] simulation: 20 x 20 unit cells of lambda/2 x lambda/2.
% [4,Sec. III]  experiment: 13 x 13 unit cells, 300 x 300 mm aperture, 2-bit.
Nx_RM        = 20;                % number of unit cells along xm
Ny_RM        = 20;                % number of unit cells along ym
dx_RM        = lambda/2;          % [m] unit-cell pitch along xm
dy_RM        = lambda/2;          % [m] unit-cell pitch along ym

% Phase resolution of the RM.
%   Inf -> continuous phase          ([4,Sec. II-A], the idealised simulation)
%   2   -> 2-bit {0,90,180,270} deg  ([4,Sec. III], the fabricated prototype)
phaseBits_RM = Inf;

% Amplitude of the aperture function. [4,Eq. (10)] enforces |M| = 1 exactly
% (phase-only modulation). Keep 'uniform' to stay faithful to the paper;
% 'hann' is [EXT], for sidelobe control, and needs the Signal Processing Toolbox.
ampTaper_RM  = 'uniform';         % 'uniform' (paper) | 'hann' [EXT]


%  PROBE ANTENNA  (single element in the XaYa plane, phaseless readout)

% [4,Sec. II-A]: probe at (0, 0, 10*lambda).  [4,Sec. III]: za = 200 mm.
xa_nom   = 0;                     % [m] nominal probe position used to DESIGN M(.)
ya_nom   = 0;                     % [m]
za_nom   = 10*lambda;             % [m]
 
% Actual probe position used in the FORWARD propagation. Setting these
% different from the nominal values reproduces the mismatch study of Fig. 8
% (phase centre of the horn not at the assumed point).
xa_act   = xa_nom;                % [m]
ya_act   = ya_nom;                % [m]
za_act   = za_nom;                % [m]
%[text] #### Plotting parameters
font=20;
%[text] ## References
%[text] \[1\] F. Munier, Y. Guo, and R. Da, "Study on NR Positioning Enhancements (Release 17)," 3rd Generation Partnership Project, Sophia Antipolis, France, Technical Report (TR) TR 38.857 V17.0.0, Mar. 2021
%[text] \[2\] ETSI, "Reconfigurable Intelligent Surfaces (RIS); Communication Models, Channel Models, Channel Estimation and Evaluation Methodology," European Telecommunications Standards Institute, GR RIS 003 V1.1.1,Jun. 2023 
%[text] \[3\] WLAN PPDU Structure, [https://de.mathworks.com/help/wlan/gs/dmg-ppdu-structure.html](https://de.mathworks.com/help/wlan/gs/dmg-ppdu-structure.html)
%[text] \[4\] W. Li, N. Wang, and J. Qi, "Direct Angle of Arrival (AOA) Estimation Using a Metasurface Antenna With Single Frequency Phaseless Measurements Obeyed Schwarz Inequality," IEEE Transactions on Microwave Theory and Techniques, vol. 72, no. 4, pp. 2677–2685, Apr. 2024, doi: 10.1109/TMTT.2023.3314063.  
%[text]  

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
