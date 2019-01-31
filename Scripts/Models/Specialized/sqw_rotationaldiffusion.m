function signal=sqw_rotationaldiffusion(varargin)
% model = sqw_rotationaldiffusion(p, q ,w, {signal}) : molecule rotational diffusion dispersion(Q) Sqw2D
%
%   iFunc/sqw_rotationaldiffusion: a 2D S(q,w) with a molecule rotational diffusion 
%     dispersion based on the Egelstaff model.
%     This is a classical pure incoherent Lorentzian scattering law (no structure).
%
%  Model and parameters:
%  ---------------------
%
%   The dispersion has the form: 
%     Egelstaff book Eq 11.13 and 11.16, p 222
%     Egelstaff J Chem Phys 1970 Eq 6b, 14 and 18b 
%
%   S(q,w) = j_0^2(qd) delta(w) + sum_l (2l+1) j_l(qd)^2 Fl(w)
%
%   where:
%
%   Fl(w)  = exp(l(l+1)Dr/w0)/pi/w0
%            * l(l+1)Dr/sqrt(w^2+(l(l+1)Dr)^2)
%            * K1(sqrt((w^2+(l(l+1)Dr)^2)/w0))
%
%   where we commonly define:
%     j_l is the spherical Bessel function of the 1st kind
%     K1  is the modified  Bessel function of the 2nd kind
%     Dr             Rotational diffusion constant [meV]
%     d              Rotator length [Angs]
%     w0             Rotational diffusion gap [meV]
%
%   The characteristic energy for a jump step is w0, usually around 
%   few meV in liquids, which inverse time t0 characterises the angular residence  
%   time step between jumps, t0 ~ 1-4 ps. 
%
%   When w0 >> Dr, the model is a simple, continuous rotational diffusion (Brownian)
%
%   You can build a jump diffusion model for a given translational weight and 
%   diffusion coefficient:
%      sqw = sqw_rotationaldiffusion([ w0 l0 ])
%
%   You can of course tune other parameters once the model object has been created.
%
%   Evaluate the model with syntax:
%     sqw(p, q, w)
%
%  Additional remarks:
%  -------------------
%
%  The model is classical, e.g. symmetric in energy, and does NOT satisfy the
%  detailed balance.
%
%  To get the 'true' quantum S(q,w) definition, use e.g.
%    sqw = Bosify(sqw_rotationaldiffusion);
%  where the Temperature is then given in [x units]. If 'x' is an energy in [meV]
%  then the Temperature parameter is T[K]/11.6045
%
%  Energy conventions:
%   w = omega = Ei-Ef = energy lost by the neutron [meV]
%       omega > 0, neutron looses energy, can not be higher than Ei (Stokes)
%       omega < 0, neutron gains energy, anti-Stokes
%
% Usage:
% ------
% s = sqw_rotationaldiffusion; 
% value = s(p,q,w); or value = iData(s,p,q,w)
%
% input:  p: sqw_rotationaldiffusion model parameters (double)
%             p(1)= Amplitude 
%             p(2)= Dr             Rotational diffusion constant [meV]
%             p(3)= d              Rotator length [Angs]
%             p(4)= w0             Rotational diffusion gap [meV]
%         q:  axis along wavevector/momentum (row,double) [Angs-1]
%         w:  axis along energy (column,double) [meV]
% output: signal: model value [iFunc_Sqw2D]
%
% Example:
%   s=sqw_rotationaldiffusion;
%   plot(log10(iData(s, [], 0:.1:20, -50:50)))  % q=0:20 Angs-1, w=-50:50 meV
%
% Reference: 
%  P.A.Egelstaff, An introduction to the liquid state, 2nd ed., Oxford (2002)
%  Egelstaff and Schofield, Nuc. Sci. Eng. 12 (1962) 260 <https://doi.org/10.13182/NSE62-A26066>
%
% Version: $Date$
% See also iData, iFunc, sqw_recoil, sqw_diffusion
%   <a href="matlab:doc(iFunc,'Models')">iFunc:Models</a>
% (c) E.Farhi, ILL. License: EUPL.

signal.Name           = [ 'sqw_rotationaldiffusion molecule rotational diffusion dispersion [' mfilename ']' ];
signal.Description    = 'A 2D S(q,w) rotational diffusion dispersion.';

signal.Parameters     = {  ...
  'Amplitude' ...
  'Dr             Rotational diffusion constant [meV]' ...
  'd              Rotator length [Angs]' ...
  'w0             Rotational diffusion gap [meV]' ...
   };
  
signal.Dimension          = 2;         % dimensionality of input space (axes) and result
signal.Guess              = [ 1 1 1 1 ];
signal.UserData.threshold = 1e-4;
signal.UserData.lmax      = 100;
signal.UserData.classical     = true;
signal.UserData.DebyeWaller   = false;

% Expression of S(q,w) is found in Egelstaff, Intro to Liquids, Eq (11.37), p 236.
%  and Egelstaff J Chem Phys 1970 Eq 6b, 14 and 18b 
%  loop on 'l' and automatically stop when new term is smaller than threshold

% spherical/rotational Bessel function, squared
% js2 = @(nu,x)pi./(2* x).*besselj(nu + 0.5, x).^2;


signal.Expression     = { ...
 'q = x; w = y; Dr = p(2); d = p(3); w0 = p(4); t0=1/w0;' ...
 'if isfield(this.UserData,''threshold''), threshold=this.UserData.threshold; else threshold=1e-4; end' ...
 'if isfield(this.UserData,''lmax''), lmax=this.UserData.lmax; else lmax=100; end' ...
 'signal=zeros(size(w));' ...
 'index=find(w == 0);' ...
 'signal(index) = pi./(2* d*q(index)).*besselj(0 + 0.5, d*q(index)).^2;' ...
 '% automatically stop when new term is smaller than threshold' ...
 'nrm = 0;' ...
 'for l=1:lmax' ...
   'if t0 <= 0, Flw = l*(l+1)*Dr./(w.^2+(l*(l+1)*Dr)^2);' ...
   'else Flw = exp(l*(l+1)*Dr*t0)/pi*l*(l+1)*Dr*t0./sqrt(w.^2+(l*(l+1)*Dr)^2).*besselk(1, sqrt(t0*(w.^2+(l*(l+1)*Dr)^2)));' ...
   'end' ...
   'delta  = (2*l+1)*(pi./(2* q*d).*besselj(l + 0.5, q*d).^2).*Flw;' ...
   'signal = signal + delta;' ...
   'if    l==1, nrm = max(abs(delta(:)));' ...
   'elseif max(abs(delta(:))) < nrm*this.UserData.threshold, break;' ...
   'end' ...
 'end' ...
 'signal = signal*p(1);' ...
 };

signal= iFunc(signal);
signal= iFunc_Sqw2D(signal); % overload Sqw flavour

if nargin == 1 && isnumeric(varargin{1})
  p = varargin{1};
  if numel(p) >= 1, signal.ParameterValues(2) = p(1); end
  if numel(p) >= 2, signal.ParameterValues(3) = p(2); end
end
