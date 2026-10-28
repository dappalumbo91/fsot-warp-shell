% Copyright 2026 Damian Arthur Palumbo
% SPDX-License-Identifier: Apache-2.0
%
% Resolution stress of the 0.10c mix. Same profile as dial_mix.m, N=320.
% Place this file in the Warp Factory Octave port's fsot_warp directory
% and run it with SHELL_ENV and OUT set. See README.md.
%
% The shift recipe is the same join. Ship speed is the amplitude.
% This script only changes the metric grid. It writes dial_mix_fine.txt.
FW = fileparts(mfilename('fullpath')); addpath(fileparts(FW)); setup_wf; addpath(FW);
envPath = getenv('SHELL_ENV');
fid0 = fopen(envPath, 'r');
m110 = fscanf(fid0, '%f', 1);
Rbig = fscanf(fid0, '%f', 1);
R1big = fscanf(fid0, '%f', 1);
mbig = fscanf(fid0, '%f', 1);
fclose(fid0);
outDir = getenv('OUT');
if exist(outDir, 'dir') ~= 7, mkdir(outDir); end
fid = fopen(fullfile(outDir, 'dial_mix_fine.txt'), 'w');
out = @(varargin) [fprintf(varargin{:}); fprintf(fid, varargin{:})];
out('Rbig=%.3f R1big=%.3f mbig=%.6e\n', Rbig, R1big, mbig);
out('clean: all four worst/peak < 1e-3, serious fraction 0, E>0, finite peak\n');

N = 320;
R2 = Rbig; R1 = R1big; m = mbig; Lbox = 1.36 * Rbig;
h = 2 * Lbox / N; nz = 5;
gridSize = [1, N, N, nz];
gridScaling = [1/(1000*c), h, h, h];
worldCenter = [1, (N+1)/2*h, (N+1)/2*h, (nz+1)/2*h];
worldSize = sqrt((N*h - worldCenter(2))^2 + (N*h - worldCenter(3))^2 + (nz*h - worldCenter(4))^2);
rsample = linspace(0, worldSize*1.2, 1e5)';
rho = zeros(size(rsample)) + m / (4/3*pi*(R2^3 - R1^3)) .* (rsample > R1 & rsample < R2);
M = cumtrapz(rsample, 4*pi .* rho .* rsample.^2);
P = TOVconstDensity(R2, M, rho, rsample);
iEdge = find(rsample > R1, 1, 'first');
Pedge = P(iEdge);
Sprs = ones(size(rsample));
Sprs(rsample >= R2) = 0;
wall = rsample > R1 & rsample < R2;
Sprs(wall) = P(wall) / Pedge;
Sprs = smooth(smooth(Sprs, 4000), 4000);
f = compactSigmoid(rsample, R1, R2, 0, 0);
if f(1) < 0
  Ssig = -f;
else
  Ssig = f;
end
Ssig = smooth(smooth(Ssig, 4000), 4000);
w = ones(size(Ssig));
use = Sprs > 1e-8;
w(use) = min(1, Ssig(use) ./ Sprs(use));
Scap = Ssig .* (1 + (Sprs - Ssig) .* w);
Sblend = Ssig .* (1 + Sprs - Ssig);
S = Ssig .* Sblend + (1 - Ssig) .* Scap;
S(S < 0) = 0;
S(S > 1) = 1;
drs = rsample(2) - rsample(1);
dS = diff(S) / drs;
[slopeMax, slopeAt] = max(abs(dS));
out('S(0)=%.5f S(4587)=%.5f S(7756)=%.5f S(7933)=%.5f S(R2)=%.5f\n', ...
    S(1), interp1(rsample, S, 4587), interp1(rsample, S, 7756), ...
    interp1(rsample, S, 7933), interp1(rsample, S, R2));
out('dS(4587)=%.6e dS(7756)=%.6e dS(7933)=%.6e peak |dS/dr|=%.6e at r=%.1f\n', ...
    interp1(rsample(1:end-1), dS, 4587), interp1(rsample(1:end-1), dS, 7756), ...
    interp1(rsample(1:end-1), dS, 7933), slopeMax, rsample(slopeAt));
out('N=%d h=%.3f\n', N, h);

rows = {
  'mix fine v=0.10', 0.10;
};
zc = (nz + 1) / 2;
ix = 3:N-2;
[X, Y] = ndgrid(((1:N)*h - worldCenter(2)), ((1:N)*h - worldCenter(3)));
Xs = X(ix, ix); Ys = Y(ix, ix);
wvol = pi * abs(Ys) * h^2;
[~, iLimb] = min(abs(Xs(:, 1)));

for n = 1:size(rows, 1)
  name = rows{n, 1}; v = rows{n, 2};
  tic;
  try
    Mt = ws_fast(gridSize, worldCenter, m, R1, R2, 0, 0, 4000, v, 0, gridScaling);
    [I, J, K] = ndgrid(1:N, 1:N, 1:nz);
    x = I*h - worldCenter(2); y = J*h - worldCenter(3); z = K*h - worldCenter(4);
    rr = sqrt(x.^2 + y.^2 + z.^2);
    Sgrid = interp1(rsample, S, rr, 'linear', 0);
    bx = -Sgrid * v;
    Mt.tensor{1, 2} = reshape(bx, gridSize); Mt.tensor{2, 1} = Mt.tensor{1, 2};
    Mt.tensor{1, 3} = reshape(zeros(size(bx)), gridSize); Mt.tensor{3, 1} = Mt.tensor{1, 3};
    Mt.tensor{1, 4} = reshape(zeros(size(bx)), gridSize); Mt.tensor{4, 1} = Mt.tensor{1, 4};
    out('\n== %s  h=%.3f  max|g_tx|=%.4f\n', name, h, max(abs(Mt.tensor{1, 2}(:))));
    W = evalMetric(Mt, 0, 1);
    g = @(p, q) squeeze(Mt.tensor{p, q}(1, ix, ix, zc));
    detg = g(2,2).*(g(3,3).*g(4,4)-g(3,4).^2) - g(2,3).*(g(2,3).*g(4,4)-g(3,4).*g(2,4)) + g(2,4).*(g(2,3).*g(3,4)-g(3,3).*g(2,4));
    dV = wvol .* sqrt(max(detg, 0));
    rhoE = squeeze(W.energyTensorEulerian.tensor{1,1}(1, ix, ix, zc));
    pk = max(abs(rhoE(:)));
    Etot = sum(rhoE(:) .* dV(:));
    maps = {W.null, W.weak, W.strong, W.dominant};
    labels = {'null', 'weak', 'strong', 'dominant'};
    worst = zeros(1, 4); serious = zeros(1, 4);
    shx = squeeze(Mt.tensor{1, 2}(1, ix, ix, zc));
    rrplane = sqrt(Xs.^2 + Ys.^2);
    polar = abs(atan2(Ys, Xs));
    polar = min(polar, pi - polar);
    for k = 1:4
      aa = squeeze(maps{k}(1, ix, ix, zc));
      worst(k) = max(0, -min(aa(:))) / pk;
      serious(k) = mean(aa(:) < -1e-3 * pk);
      [amin, lin] = min(aa(:));
      [ii, jj] = ind2sub(size(aa), lin);
      rc = rrplane(ii, jj);
      if rc < R1
        reg = 'cavity';
      elseif rc <= R2
        reg = 'wall';
      else
        reg = 'exterior';
      end
      out('%s worst/peak=%.3e at r=%.2f m (%s) g_tx=%.4f off-axis=%.1f deg rho=%.3e\n', ...
          labels{k}, worst(k), rc, reg, shx(ii, jj), polar(ii, jj) * 180 / pi, rhoE(ii, jj));
    end
    shift = max(abs(Mt.tensor{1, 2}(:)));
    clean = all(worst < 1e-3) && all(serious == 0) && Etot > 0 && isfinite(pk);
    if clean, label = 'CLEAN'; else, label = 'FAIL'; end
    out('E=%.4e nec=%.3e dec=%.3e ser=%.4f shift=%.3e %s %.1fs\n', ...
        Etot/c^2, worst(1), worst(4), max(serious), shift, label, toc);
    dom = squeeze(W.dominant(1, ix, ix, zc));
    nul = squeeze(W.null(1, ix, ix, zc));
    T01 = squeeze(W.energyTensorEulerian.tensor{1,2}(1, ix, ix, zc));
    T11 = squeeze(W.energyTensorEulerian.tensor{2,2}(1, ix, ix, zc));
    out('limb r_m g_tx T01/pk T11/pk dom/pk null/pk\n');
    for j = 1:numel(ix)
      if Ys(iLimb, j) < 0, continue; end
      rc = sqrt(Xs(iLimb, j)^2 + Ys(iLimb, j)^2);
      domv = max(0, -dom(iLimb, j))/pk;
      nulv = max(0, -nul(iLimb, j))/pk;
      if domv > 0 || (rc > 4200 && rc < 9000)
        out('%8.1f %8.4f %10.4f %10.4f %10.4f %10.4f\n', ...
            rc, shx(iLimb, j), T01(iLimb, j)/pk, T11(iLimb, j)/pk, domv, nulv);
      end
    end
    clear Mt W;
  catch err
    out('ERROR %s\n%s\n', err.message, err.identifier);
  end
  fflush(fid);
end
fclose(fid);
