function signal=sab_recoil(varargin)
% model = sab_recoil(p, alpha ,beta, {signal}) : Free-gas/recoil dispersion(Q) Sab
%
%   iFunc/sab_recoil: a 2D S(alpha,beta) with a free-gas/recoil dispersion
%
%   This is a 2D free-gas model appropriate to model the scattering law of a gas
%     molecule, as well as the translational component of a liquid. 
%     This is a pure incoherent scattering law (no structure).
%     This model is equivalent to the NJOY/LEAPR "free-gas translation".
%
%   The input parameter 'wt' is the translational weight, which quantifies the 
%   fraction of the scattering originating from recoil/diffusion, e.g. wt=Mdiff/M
%   A pure recoil is obtained with wt=1. The model satisfies the detailed balance.
%
%   The dispersion has the form (Egelstaff book Eq 10.14):
%      S(alpha,beta) = 1/sqrt(4*pi*wt*alpha)*exp( (wt*alpha + beta)^2/4/wt/a)
%
%   where we commonly define (h stands for hbar):
%     alpha=  h2q2/2MkT = (Ei+Ef-2*mu*sqrt(Ei*Ef))/AkT   unit-less moment
%     beta = -hw/kT     = (Ef-Ei)/kT                     unit-less energy
%     A    = M/m                
%     mu   = cos(theta) = (Ki.^2 + Kf.^2 - q.^2) ./ (2*Ki.*Kf)
%     m    = mass of the neutron
%     M    = mass of the scattering target [g/mol]
%     wt   = translational weight, wt=Mdiff/M e.g. in [0-1]
%
% conventions:
% w = omega = Ei-Ef = energy lost by the neutron [meV]
%     omega > 0, neutron looses energy, can not be higher than Ei (Stokes)
%     omega < 0, neutron gains energy, anti-Stokes
%
%   You can build a freegas model for a given translational weight with:
%      sab = sab_recoil(wt)
%
%   Evaluate the model with syntax:
%     sab(p, alpha, beta)
%
% input:  p: sab_recoil model parameters (double)
%             p(1)= wt          Translational weight Mdiff/M [1]
%             p(2)= Amplitude 
%         alpha:  axis along unitless wavevector/momentum (row,double)
%         beta:   axis along unitless energy (column,double)
% output: signal: model value [iFunc_Sab]
%
% Example:
%   s=sab_recoil;
%   plot(log10(iData(s, [], 0:.1:20, -50:50)))  % alpha=0:20, beta=-50:50
%
% Reference: 
%  P.A.Egelstaff, An introduction to the liquid state, 2nd ed., Oxford (2002)
%  M.Mattes and J.Keinert, IAEA INDC (NDS)-0470 (2005) https://www-nds.iaea.org/publications/indc/indc-nds-0470/
%  R.E.McFarlane, LA-12639-MS (ENDF 356) (March 1994) https://t2.lanl.gov/nis/publications/thermal.pdf
%
% Version: $Date$ $Version$ $Author$
% See also iData, iFunc
%   <a href="matlab:doc(iFunc,'Models')">iFunc:Models</a>
% 

signal.Name           = [ 'sab_recoil free-gas/recoil dispersion [' mfilename ']' ];
signal.Description    = 'A 2D S(alpha,beta) recoil/free-gas/translational dispersion.';

signal.Parameters     = {  ...
  'wt             Translational weight; wt=Mdiff/M [1]' ...
  'Amplitude' };
  
signal.Dimension      = 2;         % dimensionality of input space (axes) and result
signal.Guess          = [ 1 1 ];
signal.UserData.classical     = false;
signal.UserData.DebyeWaller   = false;

% Egelstaff Eq 10.14
signal.Expression     = { ...
 'a = x; b = y; wt = p(1);' ...
 'signal  = p(2)./sqrt(4*pi*wt*a).*exp(-(wt*a + b).^2/4/wt./a);' ...
 };

signal= iFunc(signal);
signal= iFunc_Sab(signal); % overload Sab flavour

if nargin == 1 && isnumeric(varargin{1})
  p = varargin{1};
  if numel(p) >= 1, signal.ParameterValues(1) = p(1); end
end
