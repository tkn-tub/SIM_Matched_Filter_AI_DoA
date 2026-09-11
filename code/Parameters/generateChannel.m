function h = generateChannel(pos_MU, EnvPars)
%GENERATECHANNEL Generate one realization of the spatial channel
%
% The realization contains:
%   - one LoS component;
%   - Nc NLoS clusters;
%   - Mray rays per cluster.
%
% Large-scale received power is absorbed into the controlled SNR.
% The complex coefficients therefore primarily represent phase and
% small-scale spatial interference.


    KR_dB = EnvPars.mu_K_dB + ...
            EnvPars.sigma_K_dB*randn;

    KR = 10.^(KR_dB/10);

    Nc   = EnvPars.Nc;
    Mray = EnvPars.Mray;

    kappa = 2*pi/EnvPars.lambda;


    ASD_deg = 10.^( ...
        EnvPars.mu_lgASD + ...
        EnvPars.sigma_lgASD*randn);

    ASA_deg = 10.^( ...
        EnvPars.mu_lgASA + ...
        EnvPars.sigma_lgASA*randn);

    ZSA_deg = 10.^( ...
        EnvPars.mu_lgZSA + ...
        EnvPars.sigma_lgZSA*randn);

    ZSD_deg = 10.^( ...
        EnvPars.mu_lgZSD + ...
        EnvPars.sigma_lgZSD*randn);

    % Limits specified by the channel-generation procedure
    ASD_deg = min(ASD_deg, 104);
    ASA_deg = min(ASA_deg, 104);
    ZSA_deg = min(ZSA_deg, 52);
    ZSD_deg = min(ZSD_deg, 52);
    

    lgDS = EnvPars.mu_lgDS + ...
        EnvPars.sigma_lgDS*randn;

    DS_s = 10.^lgDS;

    %% LoS geometry

    delta = pos_MU(:) - EnvPars.pos_RM(:);
    distance = norm(delta);

    if distance <= 0
        error('MU and SIM positions must be different.');
    end

    % Elevation measured from the downward SIM boresight:
    % theta = 0 means directly below the SIM.
    horizontalDistance = hypot(delta(1), delta(2));

    theta0 = atan2(horizontalDistance, -delta(3));
    phi0   = atan2(delta(2), delta(1));

    a0 = steeringVector(theta0, phi0, EnvPars);

    % Approximate receive-element amplitude response
    %F0 = max(cos(theta0), 0).^EnvPars.elementCosinePower;
    %taking into aaccount the SIM tilt
    patternTheta_deg = 0;%90 + EnvPars.patternElevation_deg;

    thetaOff_deg = abs(rad2deg(theta0)- patternTheta_deg);

    Aelem_dB = -min( ...
        12 * (thetaOff_deg / 65).^2, ...
        30);

    % Convert power-pattern attenuation in dB to field amplitude
    F0 = 10.^(Aelem_dB / 20);



    % Free-propagation phase of the LoS component.
    % Path loss is absorbed into SNR for the controlled-SNR experiment.
    alphaL = exp(-1i*kappa*distance);

    h_los = sqrt(KR/(KR + 1)) * F0 * alphaL * a0;

    %% Cluster powers Pc

    %% Generate cluster delays and powers according to TR 38.901

    % DS_s must be the delay-spread realization in seconds
    % generated earlier in this function.

    Xdelay = max(rand(Nc,1), eps);

    % Equation (7.5-1): unnormalized cluster delays
    tauPrime = ...
        -EnvPars.rTau * DS_s .* log(Xdelay);

    % Equation (7.5-2): subtract minimum and sort
    tau = sort(tauPrime - min(tauPrime));

    % Per-cluster shadowing in dB
    Zeta_dB = ...
        EnvPars.clusterShadowingStd_dB .* ...
        randn(Nc,1);

    % Equation (7.5-5): unnormalized cluster powers
    Pprime = ...
        exp( ...
        -tau .* ...
        (EnvPars.rTau - 1) ./ ...
        (EnvPars.rTau * DS_s)) .* ...
        10.^(-Zeta_dB/10);

    % Equation (7.5-6): normalize powers
    Pc = Pprime / sum(Pprime);

    % Remove clusters weaker than -25 dB relative to the strongest
    relativePower_dB = ...
        10*log10(Pc / max(Pc));

    keepClusters = relativePower_dB >= -25;

    Pc  = Pc(keepClusters);
    tau = tau(keepClusters);

    % Renormalize after removal
    Pc = Pc / sum(Pc);

    % Update the actual number of retained clusters
    Nc = numel(Pc);


    h_nlos = complex(zeros(EnvPars.Nel_RM, 1));

    for c = 1:Nc

        %% Generate cluster-center arrival angles

        phiCluster = ...
            phi0 + deg2rad(ASA_deg/1.4) .* randn(Nc,1);

        thetaCluster = ...
            theta0 + deg2rad(ZSA_deg) .* ...
            sign(randn(Nc,1)) .* ...
            abs(randn(Nc,1))/sqrt(2);

        for m = 1:Mray

            alpha_m = EnvPars.rayOffsetAlpha(m);

            phiRay = phiCluster(c) + ...
                deg2rad(EnvPars.clusterASA_deg * alpha_m);

            thetaRay = thetaCluster(c) + ...
                deg2rad(EnvPars.clusterZSA_deg * alpha_m);

            % Evaluate the rays from the user to the SIM atoms in the first
            % layer
            aRay = steeringVector(thetaRay, phiRay, EnvPars);

            % FRay = max(cos(thetaRay), 0).^ ...
            %        EnvPars.elementCosinePower;
            thetaOffRay_deg = abs(rad2deg(thetaRay)- patternTheta_deg);

            AelemRay_dB = -min( ...
                12 * (thetaOffRay_deg / 65).^2, ...
                30);

            FRay = 10.^(AelemRay_dB / 20);

            % Random phase represents free-propagation phase and the
            % fixed Doppler phase within this channel-coherence interval.
            alphaRay = exp(1i*2*pi*rand);

            h_nlos = h_nlos + ...
                sqrt(Pc(c)/Mray) * ...
                FRay * alphaRay * aRay;
        end
    end

    %% Equation (6)

    h = h_los + sqrt(1/(KR + 1))*h_nlos;

    %% Controlled-SNR normalization

    if EnvPars.normalizeH
        channelPower = mean(abs(h).^2);

        if channelPower <= eps
            error('Generated channel has approximately zero power.');
        end

        h = h / sqrt(channelPower);
    end


end


function a = steeringVector(theta, phi, EnvPars)

    kappa = 2*pi/EnvPars.lambda;

    psi_x = kappa * EnvPars.dx_RM * ...
            sin(theta) * cos(phi);

    psi_y = kappa * EnvPars.dy_RM * ...
            sin(theta) * sin(phi);

    % Same sign convention as calibration, reset, step,
    % and the agent's original training environment
    ax = exp( ...
        -1i*psi_x*(0:EnvPars.Nx_RM-1)).';

    ay = exp( ...
        -1i*psi_y*(0:EnvPars.Ny_RM-1)).';

    a = kron(ay, ax);
end

%[appendix]{"version":"1.0"}
%---
