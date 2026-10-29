% Copyright 2026 Damian Arthur Palumbo
% SPDX-License-Identifier: Apache-2.0
%
% The inner-edge payment cleared the foot and left a side cell at 16.67 m.
% This run prints that cell on the pure slope and on the payment, then scores
% the same mass with the wall joined to the slope before the four density
% smooths. The payment run joined two already-smoothed profiles and left a
% step. The builder smooths the finished wall. Same total mass, same mix.
% Peak density is compared with the compactness-1/2 wall. Above that, no score.
% Does not edit ws_fast. Does not touch scored logs.
FW = fileparts(mfilename('fullpath')); addpath(fileparts(FW)); setup_wf; addpath(FW);
ell = 0.8573494832025231;
R2 = 20;
R1 = R2 * (1 - ell);
C = 1/6;
v = 0.04;
h = 2.5 * (R2/110);
L = 150 * (R2/110);
N = round(2*L/h); nz = 5;
gridSize = [1, N, N, nz];
gridScaling = [1/(1000*c), h, h, h];
worldCenter = [1, (N+1)/2*h, (N+1)/2*h, (nz+1)/2*h];
worldSize = sqrt((N*h - worldCenter(2))^2 + (N*h - worldCenter(3))^2 + (nz*h - worldCenter(4))^2);
rsample = linspace(0, worldSize*1.2, 1e5)';
drs = rsample(2) - rsample(1);
outDir = getenv('OUT');
if isempty(outDir), error('Set OUT to a writable directory'); end
if exist(outDir, 'dir') ~= 7, mkdir(outDir); end
fid = fopen(fullfile(outDir, 'dial_sixth_band.txt'), 'w');
out = @(varargin) [fprintf(varargin{:}); fprintf(fid, varargin{:})];
out('sixth band: slope, inner payment, join-then-smooth. R2=%.3f R1=%.3f v=%.2f\n', R2, R1, v);
out('clean: all four worst/peak < 1e-3, serious fraction 0, E>0, finite peak, shift = speed\n');

m = C * R2 * c^2 / (2*G);
mHalf = 0.5 * R2 * c^2 / (2*G);
rhoHalf = mHalf / (4/3*pi*(R2^3 - R1^3));
rhoUni = m / (4/3*pi*(R2^3 - R1^3));
out('M=%.6e rhoUni=%.6e rhoHalf=%.6e\n', m, rhoUni, rhoHalf);

rho0 = rhoUni .* (rsample > R1 & rsample < R2);
M0 = cumtrapz(rsample, 4*pi .* rho0 .* rsample.^2);
Pball = TOVconstDensity(R2, M0, rho0, rsample);
Pball(~isfinite(Pball) | rsample >= R2) = 0;
iEdge = find(rsample > R1, 1, 'first');
Pedge = Pball(iEdge);
Sprs = ones(size(rsample));
Sprs(rsample >= R2) = 0;
wall = rsample > R1 & rsample < R2;
Sprs(wall) = Pball(wall) / Pedge;
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
dS = gradient(S, drs);
d2S = gradient(dS, drs);
r0 = R1;
for nflip = 1:6
  iF = find(rsample > r0 & d2S > 0 & [0; d2S(1:end-1)] <= 0, 1, 'first');
  if isempty(iF), break; end
  out('curvature flip %d at r=%.3f\n', nflip, rsample(iF));
  r0 = rsample(iF);
end

s1 = 1.79 * 4000;
sm4 = @(q) smooth(smooth(smooth(smooth(q, s1), s1), s1), s1);
rhoU = sm4(rhoUni .* wall);
rhoU(~isfinite(rhoU) | rhoU < 0) = 0;
rhoU = rhoU * (m / trapz(rsample, 4*pi .* rhoU .* rsample.^2));
rhoS = sm4(abs(dS) .* wall);
rhoS(~isfinite(rhoS) | rhoS < 0) = 0;
rhoS = rhoS * (m / trapz(rsample, 4*pi .* rhoS .* rsample.^2));

iCross = find(rsample > R1 & rhoS >= rhoU, 1, 'first');
rCross = rsample(iCross);
iFlip = find(rsample > rCross & d2S > 0 & [0; d2S(1:end-1)] <= 0, 1, 'first');
rFlip = rsample(iFlip);
rhoInner = rhoS;
rhoInner(rsample < rCross) = rhoU(rsample < rCross);
excess = trapz(rsample, 4*pi .* rhoInner .* rsample.^2) - m;
pay = rsample >= rCross & rsample < rFlip;
Mpay = trapz(rsample(pay), 4*pi .* rhoInner(pay) .* rsample(pay).^2);
fPay = (Mpay - excess) / Mpay;
rhoInner(pay) = rhoInner(pay) * fPay;
rhoInner = rhoInner * (m / trapz(rsample, 4*pi .* rhoInner .* rsample.^2));
out('smoothed join rCross=%.3f rFlip=%.3f payment scale=%.4f\n', rCross, rFlip, fPay);

rawU = rhoUni .* wall;
rawS = abs(dS) .* wall;
rawU(~isfinite(rawU) | rawU < 0) = 0;
rawS(~isfinite(rawS) | rawS < 0) = 0;
rawU = rawU * (m / trapz(rsample, 4*pi .* rawU .* rsample.^2));
rawS = rawS * (m / trapz(rsample, 4*pi .* rawS .* rsample.^2));
iCrossR = find(rsample > R1 & rawS >= rawU, 1, 'first');
rhoJoin = [];
fPayJ = NaN;
rCrossR = NaN;
if ~isempty(iCrossR)
  rCrossR = rsample(iCrossR);
  rhoJoin = rawS;
  rhoJoin(rsample < rCrossR) = rawU(rsample < rCrossR);
  excessJ = trapz(rsample, 4*pi .* rhoJoin .* rsample.^2) - m;
  payJ = rsample >= rCrossR & rsample < rFlip;
  MpayJ = trapz(rsample(payJ), 4*pi .* rhoJoin(payJ) .* rsample(payJ).^2);
  out('raw join rCross=%.3f excess/M=%.4f pay/M=%.4f\n', rCrossR, excessJ/m, MpayJ/m);
  if MpayJ > excessJ
    fPayJ = (MpayJ - excessJ) / MpayJ;
    rhoJoin(payJ) = rhoJoin(payJ) * fPayJ;
    rhoJoin = sm4(rhoJoin);
    rhoJoin(~isfinite(rhoJoin) | rhoJoin < 0) = 0;
    rhoJoin = rhoJoin * (m / trapz(rsample, 4*pi .* rhoJoin .* rsample.^2));
    out('raw payment scale=%.4f\n', fPayJ);
  else
    out('SKIP join-smooth: the inner curvature cannot pay for the wall foot\n');
    rhoJoin = [];
  end
else
  out('SKIP join-smooth: raw slope never overtakes the raw wall\n');
end

names = {'slope', 'inner', 'join-smooth'};
rhos = {rhoS, rhoInner, rhoJoin};
nMode = 3;
if isempty(rhoJoin), nMode = 2; end
Am = zeros(length(rsample), nMode);
Bm = zeros(length(rsample), nMode);
useMode = true(1, nMode);
probe = [2.85, 9.78, 12.00, 15.70, 16.67, 17.52];
for mode = 1:nMode
  rhoB = rhos{mode};
  [rhoPk, iPk] = max(rhoB);
  out('%s peak rho=%.6e at r=%.3f peak/rhoHalf=%.3f\n', names{mode}, rhoPk, rsample(iPk), rhoPk/rhoHalf);
  if rhoPk > rhoHalf
    out('SKIP %s: peak density is above the compactness-1/2 wall\n', names{mode});
    useMode(mode) = false;
    continue;
  end
  Mbend = cumtrapz(rsample, 4*pi .* rhoB .* rsample.^2);
  Mbend(Mbend < 0) = max(Mbend);
  horizon = 1 - 2*G*Mbend ./ max(rsample, drs) / c^2;
  out('%s min(1-Rs/r)=%.4f\n', names{mode}, min(horizon));
  if min(horizon) <= 0
    out('SKIP %s: enclosed mass crosses a horizon\n', names{mode});
    useMode(mode) = false;
    continue;
  end
  Ph = zeros(size(rsample));
  iOut = find(rsample > R2 & rhoB < 1e-8 * rhoPk, 1, 'first');
  if isempty(iOut), iOut = length(rsample); end
  for i = (iOut - 1):-1:2
    r = rsample(i + 1); Pp = Ph(i + 1); rhoi = rhoB(i + 1); Mi = Mbend(i + 1);
    denom = r^2 * (1 - 2*G*Mi/(r*c^2));
    if denom <= 0, break; end
    rhs = -G * (rhoi + Pp/c^2) * (Mi + 4*pi*r^3*Pp/c^2) / denom;
    if ~isfinite(rhs), break; end
    Ph(i) = Pp - rhs * drs;
  end
  Ph(~isfinite(Ph) | rsample <= R1) = 0;
  Ph4 = sm4(Ph);
  Ph4(~isfinite(Ph4)) = 0;
  a = alphaNumericSolver(Mbend(:), Ph4(:), R2, rsample(:));
  B = (1 - 2*G.*Mbend./rsample/c^2).^(-1);
  B(1) = 1;
  B(~isfinite(B) | B <= 0) = 1;
  A = -exp(2.*a);
  A(~isfinite(A)) = -1;
  Am(:, mode) = A;
  Bm(:, mode) = B;
  if mode == 1
    aSave = a;
    PhSave = Ph4;
    rhoSave = rhoB;
  else
    out('r dPh4/c2 dalpha drho/rhoHalf\n');
    for t = probe
      dP = (interp1(rsample, Ph4, t) - interp1(rsample, PhSave, t)) / c^2;
      da = interp1(rsample, a, t) - interp1(rsample, aSave, t);
      dr = (interp1(rsample, rhoB, t) - interp1(rsample, rhoSave, t)) / rhoHalf;
      out('%6.2f % .6e % .6e % .6e\n', t, dP, da, dr);
    end
  end
end

[I, J, K] = ndgrid(1:N, 1:N, 1:nz);
xg = I*h - worldCenter(2); yg = J*h - worldCenter(3); zg = K*h - worldCenter(4);
rrg = sqrt(xg.^2 + yg.^2 + zg.^2);
theta = atan2(sqrt(xg.^2 + yg.^2), zg); phi = atan2(yg, xg);
cP = cos(phi); cP(abs(phi) == pi/2) = 0;
cT = cos(theta); cT(abs(theta) == pi/2) = 0;
sT = sin(theta); sP = sin(phi);
zc = (nz + 1) / 2;
ix = 3:N-2;
[X, Y] = ndgrid(((1:N)*h - worldCenter(2)), ((1:N)*h - worldCenter(3)));
Xs = X(ix, ix); Ys = Y(ix, ix);
wvol = pi * abs(Ys) * h^2;
rrplane = sqrt(Xs.^2 + Ys.^2);
polar = abs(atan2(Ys, Xs));
polar = min(polar, pi - polar);
Sgrid = interp1(rsample, S, rrg, 'linear', 0);
bx = -Sgrid * v;
centers = 2:0.5:20;

for mode = 1:nMode
  if ~useMode(mode), continue; end
  out('--- %s ---\n', names{mode});
  Mt = ws_fast(gridSize, worldCenter, m, R1, R2, 0, 0, 4000, v, 0, gridScaling);
  Aval = interp1(rsample, Am(:, mode), rrg, 'linear', -1);
  Bval = interp1(rsample, Bm(:, mode), rrg, 'linear', 1);
  Brad = Bval;
  g22 = (Brad.*cP.^2.*sT.^2 + (cP.^2.*cT.^2)) + sP.^2;
  g33 = (Brad.*sP.^2.*sT.^2 + (cT.^2.*sP.^2)) + cP.^2;
  g44 = (Brad.*cT.^2 + sT.^2);
  g23 = (Brad.*cP.*sP.*sT.^2 + (cP.*cT.^2.*sP) - cP.*sP);
  g24 = (Brad.*cP.*cT.*sT - (cP.*cT.*sT));
  g34 = (Brad.*cT.*sP.*sT - (cT.*sP.*sT));
  Mt.tensor{1, 1} = reshape(Aval, gridSize);
  Mt.tensor{2, 2} = reshape(g22, gridSize);
  Mt.tensor{3, 3} = reshape(g33, gridSize);
  Mt.tensor{4, 4} = reshape(g44, gridSize);
  Mt.tensor{2, 3} = reshape(g23, gridSize); Mt.tensor{3, 2} = Mt.tensor{2, 3};
  Mt.tensor{2, 4} = reshape(g24, gridSize); Mt.tensor{4, 2} = Mt.tensor{2, 4};
  Mt.tensor{3, 4} = reshape(g34, gridSize); Mt.tensor{4, 3} = Mt.tensor{3, 4};
  Mt.tensor{1, 2} = reshape(bx, gridSize); Mt.tensor{2, 1} = Mt.tensor{1, 2};
  Mt.tensor{1, 3} = reshape(zeros(size(bx)), gridSize); Mt.tensor{3, 1} = Mt.tensor{1, 3};
  Mt.tensor{1, 4} = reshape(zeros(size(bx)), gridSize); Mt.tensor{4, 1} = Mt.tensor{1, 4};
  tic;
  W = evalMetric(Mt, 0, 1);
  rhoE = squeeze(W.energyTensorEulerian.tensor{1,1}(1, ix, ix, zc));
  pk = max(abs(rhoE(:)));
  T01 = squeeze(W.energyTensorEulerian.tensor{1,2}(1, ix, ix, zc));
  T11 = squeeze(W.energyTensorEulerian.tensor{2,2}(1, ix, ix, zc));
  dom = squeeze(W.dominant(1, ix, ix, zc));
  nul = squeeze(W.null(1, ix, ix, zc));
  worstD = max(0, -min(dom(:))) / pk;
  worstN = max(0, -min(nul(:))) / pk;
  [~, lin] = min(dom(:));
  [ii, jj] = ind2sub(size(dom), lin);
  out('%s dom worst/peak=%.3e at r=%.3f off=%.1f rho=%.4f T01=%.4f T11=%.4f nullworst=%.3e pk=%.6e %.1fs\n', ...
      names{mode}, worstD, rrplane(ii, jj), polar(ii, jj)*180/pi, rhoE(ii, jj)/pk, T01(ii, jj)/pk, T11(ii, jj)/pk, worstN, pk, toc);
  foot = rrplane < 8;
  outer = rrplane > 10;
  out('%s foot r<8 dom worst/peak=%.3e outer r>10 dom worst/peak=%.3e\n', ...
      names{mode}, max(0, -min(dom(foot))) / pk, max(0, -min(dom(outer))) / pk);
  out('r dom/pk ang rho/pk T01/pk nneg\n');
  for c0 = centers
    sel = abs(rrplane - c0) <= 0.25;
    if ~any(sel(:)), continue; end
    vals = dom(sel);
    [mn, k] = min(vals);
    iiS = find(sel);
    ang = polar(iiS(k)) * 180/pi;
    rhoL = rhoE(iiS(k)) / pk;
    tL = T01(iiS(k)) / pk;
    nneg = sum(vals < -1e-3 * pk);
    if mn < 0 || (c0 >= 14 && c0 <= 18)
      out('%6.2f % .4e %5.1f % .4f % .4f %d\n', c0, mn/pk, ang, rhoL, tL, nneg);
    end
  end
  clear W Mt Aval Bval
end
out('sixth band done\n');
fclose(fid);
