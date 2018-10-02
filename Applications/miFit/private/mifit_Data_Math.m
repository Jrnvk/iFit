function mifit_Data_Math(varargin)
% Data/Transform others: apply a binary operator on Datasets

  % should contain e.g. conv4d and powder...
  op = {'cart2sph (Cartesian to spherical coordinates)', ...
  'cwt (Continuous wavelet transform)', ...
  'fft (Fast Fourier Transform)','ifft (inverse Fast Fourier Transform)', ...
  'del2 (Laplacian delta)','gradient (derivative/gradient)', ...
  'diff (Difference and approximate derivative)',...
  'cumtrapz (cumulated integral)','sum (summation, total value)', ...
  'prod (product, total value)','trapz (trapezoidal integral)','cumsum (cumulated sum)','cumprod (cumulated product)',...
  'smooth (smooth)','kmeans (k-means clustering)', ...
  'pca (Principal component analysis)','interp (interpolation)', ...
  'std (standard deviation, width)','fill (remove/interpolate missing data)', ...
  'hist (build accumulated histogram from event list)'};
  mifit_Data_Operator(op);
