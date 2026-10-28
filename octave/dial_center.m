% Copyright 2026 Damian Arthur Palumbo
% SPDX-License-Identifier: Apache-2.0
%
% Center census of the 0.10c mix. Same profile as dial_mix.m.
% Scores shift amplitude 0 and 0.10 at N=160 and N=320.
% Writes dial_center.txt. Does not change the shell or the shift shape.
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
fid = fopen(fullfile(outDir, 'dial_center.txt'), 'w');
out = @(varargin) [fprintf(varargin{:}); fprintf(fid, varargin{:})];
out('Rbig=%.3f R1big=%.3f mbig=%.6e\n', Rbig, R1big, mbig);
out('center census: same mix, shift off and shift 0.10, N=160 and N=320\n');

R2 = Rbig; R1 = R1big; m = mbig;
for N = [160, 320]
  Lbox = 1.36 * Rbig;
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

  zc = (nz + 1) / 2;
  ix = 3:N-2;
  [X, Y] = ndgrid(((1:N)*h - worldCenter(2)), ((1:N)*h - worldCenter(3)));
  Xs = X(ix, ix); Ys = Y(ix, ix);
  wvol = pi * abs(Ys) * h^2;
  rrplane = sqrt(Xs.^2 + Ys.^2);
  polar = abs(atan2(Ys, Xs));
  polar = min(polar, pi - polar);
  edges = [0, h, 2*h, 4*h, R1, R2, 1e99];
  bname = {'r<h', 'h..2h', '2h..4h', '4h..R1', 'wall', 'exterior'};

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
      rh = rhoE / pk;
      out('\n== center N=%d v=%.2f h=%.3f pk=%.6e max|g_tx|=%.4f %.1fs\n', ...
          N, v, h, pk, max(abs(bx(:))), toc);
      out('bin n minRho minNull minWeak minStrong minDom nRhoNeg nWeakBar\n');
      for b = 1:6
        sel = rrplane >= edges(b) & rrplane < edges(b+1);
        nsel = sum(sel(:));
        if nsel == 0
          out('%-8s %5d %s\n', bname{b}, 0, 'empty');
          continue;
        end
        out('%-8s %5d % .6e % .6e % .6e % .6e % .6e %5d %5d\n', bname{b}, nsel, ...
            min(rh(sel)), min(nul(sel)), min(wk(sel)), min(st(sel)), min(dom(sel)), ...
            sum(rh(sel) < 0), sum(wk(sel) < -1e-3));
      end
      [~, order] = sort(wk(:));
      out('lowest weak: r_m offdeg rho/pk null/pk weak/pk strong/pk dom/pk\n');
      shown = 0;
      for n = 1:numel(order)
        if shown >= 8, break; end
        lin = order(n);
        [ii, jj] = ind2sub(size(wk), lin);
        shown = shown + 1;
        out('%8.2f %6.1f % .6e % .6e % .6e % .6e % .6e\n', ...
            rrplane(ii, jj), polar(ii, jj) * 180 / pi, ...
            rh(ii, jj), nul(ii, jj), wk(ii, jj), st(ii, jj), dom(ii, jj));
      end
      clear Mt W rhoE nul wk st dom rh;
    catch err
      out('ERROR %s\n%s\n', err.message, err.identifier);
    end
    fflush(fid);
  end
end
out('center census done\n');
fclose(fid);
