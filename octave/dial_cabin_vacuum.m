% Copyright 2026 Damian Arthur Palumbo
% SPDX-License-Identifier: Apache-2.0
%
% How much of the nominal cabin survives the builder's mass smoother.
% Same four-pass density smooth as the metric builder. Same mix as the scored shift.
% No energy-condition score. Writes dial_cabin_vacuum.txt.
FW = fileparts(mfilename('fullpath')); addpath(fileparts(FW)); setup_wf; addpath(FW);
ell = 0.8573494832025231;
outDir = getenv('OUT');
if isempty(outDir), error('Set OUT to a writable directory'); end
if exist(outDir, 'dir') ~= 7, mkdir(outDir); end
fid = fopen(fullfile(outDir, 'dial_cabin_vacuum.txt'), 'w');
out = @(varargin) [fprintf(varargin{:}); fprintf(fid, varargin{:})];

R2 = 20;
names = {'fsot', 'theirs'};
R1s = [R2 * (1 - ell), 10];
C = 0.5;
h = 2.5 * (R2 / 110);
L = 150 * (R2 / 110);
N = round(2 * L / h); nz = 5;
gridScaling = [1/(1000*c), h, h, h];
worldCenter = [1, (N+1)/2*h, (N+1)/2*h, (nz+1)/2*h];
worldSize = sqrt((N*h - worldCenter(2))^2 + (N*h - worldCenter(3))^2 + (nz*h - worldCenter(4))^2);
rsample = linspace(0, worldSize*1.2, 1e5)';
dr = rsample(2) - rsample(1);
s1 = 1.79 * 4000;
out('R2=%.3f N=%d h=%.5f dr=%.6e worldSize=%.3f\n', R2, N, h, dr, worldSize);
out('mass smooth span %.0f samples = %.3f m, shift smooth span 4000 samples = %.3f m\n', ...
    s1, s1*dr, 4000*dr);

for n = 1:2
  R1 = R1s(n);
  m = C * R2 * c^2 / (2*G);
  rhoWall = m / (4/3*pi*(R2^3 - R1^3));
  rho0 = rhoWall .* (rsample > R1 & rsample < R2);
  [~, maxR] = min(diff(rho0 > 0)); maxR = rsample(maxR);
  M0 = cumtrapz(rsample, 4*pi .* rho0 .* rsample.^2);
  P0 = TOVconstDensity(R2, M0, rho0, rsample);
  rho = smooth(smooth(smooth(smooth(rho0, s1), s1), s1), s1);
  P = smooth(smooth(smooth(smooth(P0, 4000), 4000), 4000), 4000);
  M = cumtrapz(rsample, 4*pi .* rho .* rsample.^2);
  nNeg = sum(M < 0);
  M(M < 0) = max(M);
  iEdge = find(rsample > R1, 1, 'first');
  Pedge = P0(iEdge);
  Sprs = ones(size(rsample));
  Sprs(rsample >= R2) = 0;
  wall = rsample > R1 & rsample < R2;
  Sprs(wall) = P0(wall) / Pedge;
  Sprs = smooth(smooth(Sprs, 4000), 4000);
  f = compactSigmoid(rsample, R1, R2, 0, 0);
  if f(1) < 0, Ssig = -f; else, Ssig = f; end
  Ssig = smooth(smooth(Ssig, 4000), 4000);
  w = ones(size(Ssig));
  use = Sprs > 1e-8;
  w(use) = min(1, Ssig(use) ./ Sprs(use));
  Scap = Ssig .* (1 + (Sprs - Ssig) .* w);
  Sblend = Ssig .* (1 + Sprs - Ssig);
  S = Ssig .* Sblend + (1 - Ssig) .* Scap;
  S(S < 0) = 0; S(S > 1) = 1;
  pk = max(rho);
  iRho = find(rho > 0, 1, 'first');
  iLast = find(rho > 0, 1, 'last');
  i1 = find(rho >= 0.01*pk, 1, 'first');
  iS = find(S < 1 - 1e-4, 1, 'first');
  iFlat = find(rho < 0.01*pk & S > 0.999);
  if isempty(iFlat)
    rFlat = 0;
  else
    rFlat = rsample(iFlat(end));
  end
  out('\n-- %s R1=%.4f m=%.6e rho_wall=%.6e maxR=%.3f nNegM=%d\n', ...
      names{n}, R1, m, rhoWall, maxR, nNeg);
  out('rho(0)/peak=%.6e rho(R1)/peak=%.6f\n', rho(1)/pk, rho(iEdge)/pk);
  out('first rho>0 at r=%.4f m\n', rsample(iRho));
  out('last rho>0 at r=%.4f m\n', rsample(iLast));
  out('rho reaches 1%% of peak at r=%.4f m\n', rsample(i1));
  out('S drops below 0.9999 at r=%.4f m, S=%.6f, rho/peak=%.6f\n', ...
      rsample(iS), S(iS), rho(iS)/pk);
  out('S(0)=%.6f S(R1)=%.6f S(R2)=%.6f\n', S(1), S(iEdge), interp1(rsample, S, R2));
  out('usable cabin, rho<1%% peak and S>0.999, out to r=%.4f m\n', rFlat);
  stations = [0.2, 1, 2, 2.85, 7, 8, 9.78, 10, 15.7, 17.5, 20, 26.2, 26.5];
  out('r rho/peak S\n');
  for t = stations
    if t > rsample(end), continue; end
    out('%6.2f % .6e % .6f\n', t, interp1(rsample, rho, t)/pk, interp1(rsample, S, t));
  end
end
out('cabin vacuum done\n');
fclose(fid);
