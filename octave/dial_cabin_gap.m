% Copyright 2026 Damian Arthur Palumbo
% SPDX-License-Identifier: Apache-2.0
%
% Cabin gap. Their empty cabin is half the outer radius. The FSOT wall leaves 1-ell.
% This scores their cabin, and the legacy 50 m cabin, at compactness 1/2.
% Mass is C*R2*c^2/(2*G). Same mix. Fractional grid of the 110 m article.
% Ship speed is only the amplitude. Writes dial_cabin_gap.txt.
FW = fileparts(mfilename('fullpath')); addpath(fileparts(FW)); setup_wf; addpath(FW);
outDir = getenv('OUT');
if isempty(outDir), error('Set OUT to a writable directory'); end
if exist(outDir, 'dir') ~= 7, mkdir(outDir); end
fid = fopen(fullfile(outDir, 'dial_cabin_gap.txt'), 'w');
out = @(varargin) [fprintf(varargin{:}); fprintf(fid, varargin{:})];
out('cabin gap: compactness 1/2, their R1/R2 = 1/2, legacy R1 = 50 m at R2 = 110 m\n');
out('clean: all four worst/peak < 1e-3, serious fraction 0, E>0, finite peak, shift = speed\n');

tags = {'fuchs','fuchs','fuchs','legacy','legacy','legacy'};
R2s = [20, 20, 20, 110, 110, 110];
R1s = [10, 10, 10, 50, 50, 50];
vs = [0.04, 0.06, 0.10, 0.04, 0.06, 0.10];
C = 0.50;
keyPrev = '';

for n = 1:numel(vs)
  tag = tags{n}; R2 = R2s(n); R1 = R1s(n); v = vs(n);
  h = 2.5 * (R2/110); L = 150 * (R2/110);
  N = round(2*L/h); nz = 5;
  gridSize = [1, N, N, nz];
  gridScaling = [1/(1000*c), h, h, h];
  worldCenter = [1, (N+1)/2*h, (N+1)/2*h, (nz+1)/2*h];
  key = sprintf('%.6f %.6f', R2, R1);
  if ~strcmp(key, keyPrev)
    m = C * R2 * c^2 / (2*G);
    worldSize = sqrt((N*h - worldCenter(2))^2 + (N*h - worldCenter(3))^2 + (nz*h - worldCenter(4))^2);
    rsample = linspace(0, worldSize*1.2, 1e5)';
    rho = zeros(size(rsample)) + m / (4/3*pi*(R2^3 - R1^3)) .* (rsample > R1 & rsample < R2);
    M = cumtrapz(rsample, 4*pi .* rho .* rsample.^2);
    P = TOVconstDensity(R2, M, rho, rsample);
    iEdge = find(rsample > R1, 1, 'first');
    Sprs = ones(size(rsample));
    Sprs(rsample >= R2) = 0;
    wall = rsample > R1 & rsample < R2;
    Sprs(wall) = P(wall) / P(iEdge);
    Sprs = smooth(smooth(Sprs, 4000), 4000);
    f = compactSigmoid(rsample, R1, R2, 0, 0);
    if f(1) < 0, Ssig = -f; else, Ssig = f; end
    Ssig = smooth(smooth(Ssig, 4000), 4000);
    wgt = ones(size(Ssig));
    use = Sprs > 1e-8;
    wgt(use) = min(1, Ssig(use) ./ Sprs(use));
    Scap = Ssig .* (1 + (Sprs - Ssig) .* wgt);
    Sblend = Ssig .* (1 + Sprs - Ssig);
    S = Ssig .* Sblend + (1 - Ssig) .* Scap;
    S(S < 0) = 0; S(S > 1) = 1;
    dS = gradient(S, rsample);
    out('\n-- %s R2=%.3f R1=%.3f R1/R2=%.3f C=%.3f m=%.6e N=%d h=%.4f S(0)=%.5f S(R2)=%.5f\n', ...
        tag, R2, R1, R1/R2, C, m, N, h, S(1), interp1(rsample, S, R2));
    out('r/R2 S Ssig Sprs dS\n');
    for frac = [R1/R2, 0.60, 0.70, 0.80, 0.90, 1.00]
      rrk = frac * R2;
      out('%.3f %.5f %.5f %.5f %.6e\n', frac, interp1(rsample, S, rrk), ...
          interp1(rsample, Ssig, rrk), interp1(rsample, Sprs, rrk), interp1(rsample, dS, rrk));
    end
    keyPrev = key;
    zc = (nz + 1) / 2;
    ix = 3:N-2;
    [X, Y] = ndgrid(((1:N)*h - worldCenter(2)), ((1:N)*h - worldCenter(3)));
    Xs = X(ix, ix); Ys = Y(ix, ix);
    wvol = pi * abs(Ys) * h^2;
  end
  tic;
  Mt = ws_fast(gridSize, worldCenter, m, R1, R2, 0, 0, 4000, v, 0, gridScaling);
  [I, J, K] = ndgrid(1:N, 1:N, 1:nz);
  x = I*h - worldCenter(2); y = J*h - worldCenter(3); z = K*h - worldCenter(4);
  rr = sqrt(x.^2 + y.^2 + z.^2);
  Sgrid = interp1(rsample, S, rr, 'linear', 0);
  bx = -Sgrid * v;
  Mt.tensor{1, 2} = reshape(bx, gridSize); Mt.tensor{2, 1} = Mt.tensor{1, 2};
  Mt.tensor{1, 3} = reshape(zeros(size(bx)), gridSize); Mt.tensor{3, 1} = Mt.tensor{1, 3};
  Mt.tensor{1, 4} = reshape(zeros(size(bx)), gridSize); Mt.tensor{4, 1} = Mt.tensor{1, 4};
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
  T01 = squeeze(W.energyTensorEulerian.tensor{1,2}(1, ix, ix, zc));
  T11 = squeeze(W.energyTensorEulerian.tensor{2,2}(1, ix, ix, zc));
  out('== %s v=%.2f max|g_tx|=%.4f\n', tag, v, max(abs(Mt.tensor{1, 2}(:))));
  for k = 1:4
    aa = squeeze(maps{k}(1, ix, ix, zc));
    worst(k) = max(0, -min(aa(:))) / pk;
    serious(k) = mean(aa(:) < -1e-3 * pk);
    [~, lin] = min(aa(:));
    [ii, jj] = ind2sub(size(aa), lin);
    rc = rrplane(ii, jj);
    if rc < R1, reg = 'cavity'; elseif rc <= R2, reg = 'wall'; else, reg = 'exterior'; end
    out('%s worst/peak=%.3e at r=%.3f m (%s) g_tx=%.4f off-axis=%.1f deg T01/pk=%.4f T11/pk=%.4f\n', ...
        labels{k}, worst(k), rc, reg, shx(ii, jj), polar(ii, jj)*180/pi, T01(ii, jj)/pk, T11(ii, jj)/pk);
  end
  shift = max(abs(Mt.tensor{1, 2}(:)));
  clean = all(worst < 1e-3) && all(serious == 0) && Etot > 0 && isfinite(pk) && abs(shift - v) < 1e-3;
  if clean, label = 'CLEAN'; else, label = 'FAIL'; end
  out('E=%.4e null=%.3e weak=%.3e strong=%.3e dom=%.3e ser=%.4f shift=%.3e %s %.1fs\n', ...
      Etot/c^2, worst(1), worst(2), worst(3), worst(4), max(serious), shift, label, toc);
  clear Mt W;
  fflush(fid);
end
out('cabin gap done\n');
fclose(fid);
