% Copyright 2026 Damian Arthur Palumbo
% SPDX-License-Identifier: Apache-2.0
%
% Mass down at fixed outer radius, so the wall density falls with the mass.
% FSOT wall, mix shift, builder lapse. Does not edit ws_fast.
% Compactness 1/4 and 1/5, at 0.04c and 0.06c, are in dial_mass_down.txt.
% This copy scores compactness 1/6 at 0.04c into dial_mass_down_16.txt.
FW = fileparts(mfilename('fullpath')); addpath(fileparts(FW)); setup_wf; addpath(FW);
ell = 0.8573494832025231;
Mjup = 1.89813e27;
R2 = 20;
R1 = R2 * (1 - ell);
h = 2.5 * (R2/110);
L = 150 * (R2/110);
N = round(2*L/h); nz = 5;
gridSize = [1, N, N, nz];
gridScaling = [1/(1000*c), h, h, h];
worldCenter = [1, (N+1)/2*h, (N+1)/2*h, (nz+1)/2*h];
worldSize = sqrt((N*h - worldCenter(2))^2 + (N*h - worldCenter(3))^2 + (nz*h - worldCenter(4))^2);
rsample = linspace(0, worldSize*1.2, 1e5)';
outDir = getenv('OUT');
if isempty(outDir), error('Set OUT to a writable directory'); end
if exist(outDir, 'dir') ~= 7, mkdir(outDir); end
fid = fopen(fullfile(outDir, 'dial_mass_down_16.txt'), 'w');
out = @(varargin) [fprintf(varargin{:}); fprintf(fid, varargin{:})];
out('mass down, fixed R2=%.3f R1=%.3f. Density falls with compactness.\n', R2, R1);
out('clean: all four worst/peak < 1e-3, serious fraction 0, E>0, finite peak, shift = speed\n');
mHalf = 0.5 * R2 * c^2 / (2*G);
rhoHalf = mHalf / (4/3*pi*(R2^3 - R1^3));
out('C=1/2 reference: M=%.6e (%.3f Mjup) rho=%.6e\n', mHalf, mHalf/Mjup, rhoHalf);

Cs = [1/6];
vs = [0.04];
keyPrev = '';
zc = (nz + 1) / 2;
ix = 3:N-2;
[X, Y] = ndgrid(((1:N)*h - worldCenter(2)), ((1:N)*h - worldCenter(3)));
Xs = X(ix, ix); Ys = Y(ix, ix);
wvol = pi * abs(Ys) * h^2;
marks = [0.489, 0.600, 0.785, 0.876] * R2;

for n = 1:numel(vs)
  C = Cs(n); v = vs(n);
  key = sprintf('%.6f', C);
  if ~strcmp(key, keyPrev)
    m = C * R2 * c^2 / (2*G);
    rhoW = m / (4/3*pi*(R2^3 - R1^3));
    Rcap = R2 * sqrt(C / 0.5);
    mCap = mHalf * (C / 0.5)^1.5;
    out('\n-- C=%.3f M=%.6e (%.3f Mjup) rho=%.6e rho/rhoHalf=%.3f\n', C, m, m/Mjup, rhoW, rhoW/rhoHalf);
    out('same density as the C=1/2 wall: R2=%.3f M=%.6e (%.3f Mjup)\n', Rcap, mCap, mCap/Mjup);
    rho = zeros(size(rsample)) + rhoW .* (rsample > R1 & rsample < R2);
    Mprof = cumtrapz(rsample, 4*pi .* rho .* rsample.^2);
    P = TOVconstDensity(R2, Mprof, rho, rsample);
    iEdge = find(rsample > R1, 1, 'first');
    Pedge = P(iEdge);
    Sprs = ones(size(rsample));
    Sprs(rsample >= R2) = 0;
    wall = rsample > R1 & rsample < R2;
    Sprs(wall) = P(wall) / Pedge;
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
    keyPrev = key;
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
  out('== C=%.3f v=%.2f\n', C, v);
  for k = 1:4
    aa = squeeze(maps{k}(1, ix, ix, zc));
    worst(k) = max(0, -min(aa(:))) / pk;
    serious(k) = mean(aa(:) < -1e-3 * pk);
    [~, lin] = min(aa(:));
    [ii, jj] = ind2sub(size(aa), lin);
    out('%s worst/peak=%.3e at r=%.3f off=%.1f T01=%.4f T11=%.4f\n', ...
        labels{k}, worst(k), rrplane(ii, jj), polar(ii, jj)*180/pi, T01(ii, jj)/pk, T11(ii, jj)/pk);
  end
  shift = max(abs(Mt.tensor{1, 2}(:)));
  clean = all(worst < 1e-3) && all(serious == 0) && Etot > 0 && isfinite(pk) && abs(shift - v) < 1e-3;
  if clean, label = 'CLEAN'; else, label = 'FAIL'; end
  out('E=%.4e null=%.3e weak=%.3e strong=%.3e dom=%.3e ser=%.4f shift=%.3e %s %.1fs\n', ...
      Etot/c^2, worst(1), worst(2), worst(3), worst(4), max(serious), shift, label, toc);
  dom = squeeze(W.dominant(1, ix, ix, zc));
  [~, i0] = min(abs(Xs(:, 1)));
  ray = rrplane(i0, :); keep = Ys(i0, :) > 0;
  ray = ray(keep);
  doms = dom(i0, keep); rhos = rhoE(i0, keep); t01s = T01(i0, keep);
  [ray, ord] = sort(ray);
  doms = doms(ord); rhos = rhos(ord); t01s = t01s(ord);
  out('r rho T01 dom\n');
  for t = marks
    out('%6.2f % .4f % .4f % .4f\n', t, interp1(ray, rhos, t)/pk, interp1(ray, t01s, t)/pk, interp1(ray, doms, t)/pk);
  end
  clear Mt W;
  fflush(fid);
end
out('mass down done\n');
fclose(fid);
