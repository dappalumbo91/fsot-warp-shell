% Copyright 2026 Damian Arthur Palumbo
% SPDX-License-Identifier: Apache-2.0
%
% Flat-ball correction of the origin stencil. Same 0.10c mix.
% Where the constructed metric is exactly flat, the continuum stress-energy
% is 0. The Cartesian fourth-order stencil reaches outside that ball and
% reports a false negative density. Those cells are set back to 0.
% Raw and corrected values are both printed. Writes dial_flatball.txt.
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
fid = fopen(fullfile(outDir, 'dial_flatball.txt'), 'w');
out = @(varargin) [fprintf(varargin{:}); fprintf(fid, varargin{:})];

R2 = Rbig; R1 = R1big; m = mbig;
Lbox = 1.36 * Rbig;
nz = 5;
worldSize0 = sqrt((2*Lbox - (160+1)/2*(2*Lbox/160))^2 * 2 + (5*(2*Lbox/160) - 3*(2*Lbox/160))^2);
rsample = linspace(0, worldSize0*1.2, 1e5)';
rho0 = m / (4/3*pi*(R2^3-R1^3)) .* (rsample > R1 & rsample < R2);
M0 = cumtrapz(rsample, 4*pi .* rho0 .* rsample.^2);
P0 = TOVconstDensity(R2, M0, rho0, rsample);
s1 = 1.79 * 4000;
rho = smooth(smooth(smooth(smooth(rho0, s1), s1), s1), s1);
P = smooth(smooth(smooth(smooth(P0, 4000), 4000), 4000), 4000);
M = cumtrapz(rsample, 4*pi .* rho .* rsample.^2);
M(M < 0) = max(M);
B = (1 - 2*G.*M./rsample/c^2).^(-1);
B(1) = 1;
iRho = find(rho > 0, 1, 'first');
rFlat = rsample(iRho);
out('Rbig=%.3f R1big=%.3f mbig=%.6e\n', Rbig, R1big, mbig);
out('flat ball: r < %.4f m, first smoothed density %.6e kg/m^3\n', rFlat, rho(iRho));
out('inside that radius the radial B and the mix are exactly flat\n');

for N = [160, 320]
  h = 2 * Lbox / N;
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

  zc = (nz + 1) / 2;
  ix = 3:N-2;
  [X, Y] = ndgrid(((1:N)*h - worldCenter(2)), ((1:N)*h - worldCenter(3)));
  Xs = X(ix, ix); Ys = Y(ix, ix);
  wvol = pi * abs(Ys) * h^2;
  rrplane = sqrt(Xs.^2 + Ys.^2);
  polar = abs(atan2(Ys, Xs));
  polar = min(polar, pi - polar);

  for v = [0, 0.10]
    tic;
    try
      out('building N=%d h=%.3f v=%.2f\n', N, h, v);
      fflush(fid);
      Mt = ws_fast(gridSize, worldCenter, m, R1, R2, 0, 0, 4000, 0, 0, gridScaling);
      [I, J, K] = ndgrid(1:N, 1:N, 1:nz);
      x = I*h - worldCenter(2); y = J*h - worldCenter(3); z = K*h - worldCenter(4);
      rr = sqrt(x.^2 + y.^2 + z.^2);
      Sgrid = interp1(rsample, S, rr, 'linear', 0);
      bx = -Sgrid * v;
      Mt.tensor{1, 2} = reshape(bx, gridSize); Mt.tensor{2, 1} = Mt.tensor{1, 2};
      Mt.tensor{1, 3} = reshape(zeros(size(bx)), gridSize); Mt.tensor{3, 1} = Mt.tensor{1, 3};
      Mt.tensor{1, 4} = reshape(zeros(size(bx)), gridSize); Mt.tensor{4, 1} = Mt.tensor{1, 4};
      W = evalMetric(Mt, 0, 1);
      rhoE = squeeze(W.energyTensorEulerian.tensor{1,1}(1, ix, ix, zc));
      pk = max(abs(rhoE(:)));
      nul = squeeze(W.null(1, ix, ix, zc)) / pk;
      wk = squeeze(W.weak(1, ix, ix, zc)) / pk;
      st = squeeze(W.strong(1, ix, ix, zc)) / pk;
      dom = squeeze(W.dominant(1, ix, ix, zc)) / pk;
      flat = rrplane < rFlat;
      out('\n== raw N=%d v=%.2f  minWeak=%.6e nFlat=%d\n', N, v, min(wk(:)), sum(flat(:)));
      nul(flat) = 0; wk(flat) = 0; st(flat) = 0; dom(flat) = 0; rhoE(flat) = 0;
      g = @(p, q) squeeze(Mt.tensor{p, q}(1, ix, ix, zc));
      detg = g(2,2).*(g(3,3).*g(4,4)-g(3,4).^2) - g(2,3).*(g(2,3).*g(4,4)-g(3,4).*g(2,4)) + g(2,4).*(g(2,3).*g(3,4)-g(3,3).*g(2,4));
      dV = wvol .* sqrt(max(detg, 0));
      Etot = sum(rhoE(:) .* dV(:));
      worst = [max(0, -min(nul(:))), max(0, -min(wk(:))), max(0, -min(st(:))), max(0, -min(dom(:)))];
      serious = mean(nul(:) < -1e-3) ;
      serious = max([mean(nul(:) < -1e-3), mean(wk(:) < -1e-3), mean(st(:) < -1e-3), mean(dom(:) < -1e-3)]);
      shift = max(abs(bx(:)));
      clean = all(worst < 1e-3) && serious == 0 && Etot > 0 && isfinite(pk);
      if clean, label = 'CLEAN'; else, label = 'FAIL'; end
      out('== flat N=%d v=%.2f h=%.3f pk=%.6e nFlat=%d\n', N, v, h, pk, sum(flat(:)));
      out('null=%.6e weak=%.6e strong=%.6e dom=%.6e ser=%.4e E=%.4e shift=%.3e %s %.1fs\n', ...
          worst(1), worst(2), worst(3), worst(4), serious, Etot/c^2, shift, label, toc);
      maps = {nul, wk, st, dom};
      labels = {'null', 'weak', 'strong', 'dominant'};
      for k = 1:4
        aa = maps{k};
        [amin, lin] = min(aa(:));
        [ii, jj] = ind2sub(size(aa), lin);
        out('%s worst=%.6e at r=%.2f off=%.1f\n', labels{k}, max(0, -amin), rrplane(ii, jj), polar(ii, jj)*180/pi);
      end
      clear Mt W;
    catch err
      out('ERROR %s\n%s\n', err.message, err.identifier);
    end
    fflush(fid);
  end
end
out('flat ball done\n');
fclose(fid);
