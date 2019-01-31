function signal=sqw_jumpdiffusion(varargin)
% model = sqw_jumpdiffusion(p, q ,w, {signal}) : jump/Fick-law diffusion dispersion(Q) Sqw2D
%
%   iFunc/sqw_jumpdiffusion: a 2D S(q,w) with a jump diffusion dispersion
%     based on the Egelstaff model. It can also model a simple Fick's law.
%     This is a classical pure incoherent Lorentzian scattering law (no structure).
%
%   The liquid is assumed to have appreciable short range order in a quasi-
%     crystalline form. Diffusive motion takes place in large discrete jumps, 
%     between which the atoms oscillate as in a solid. 
%
%  Model and parameters:
%  ---------------------
%
%   The dispersion has the form: (Egelstaff book Eq 11.13 and 11.16, p 222)
%      S(q,w) = f(q)/(w^2+f(q)^2)
%   where
%      f(q)   = 1/t0*(1-sin(Q l0)/(q l0))     width of the Lorentzian
%
%   where we commonly define:
%     l0   = Jump distance, e.g. 0.1-5 Angs [Angs]
%     t0   = Residence time step between jumps, e.g. 1-4 ps [s]
%
%   The jump distance l0 can be related to the diffusion constant D as 
%   l0^2 = 6*D*t0, where D is usually around D=1-10 E-9 [m^2/s] in liquids. Its 
%   value in [meV.Angs^2] is D*4.1356e+08. The residence time t0 is usually in 0-4 ps.
%
%   You can build a jump diffusion model for a given translational weight and 
%   diffusion coefficient:
%      sqw = sqw_jumpdiffusion([ D t0 ])
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
%    sqw = Bosify(sqw_jumpdiffusion);
%
%  To add a Debye-Waller factor (thermal motions around the equilibrium), use e.g.
%    sqw = DebyeWaller(sqw);
%
%  Energy conventions:
%   w = omega = Ei-Ef = energy lost by the neutron [meV]
%       omega > 0, neutron looses energy, can not be higher than Ei (Stokes)
%       omega < 0, neutron gains energy, anti-Stokes
%
%  This model is equivalent to the QENS_ChudleyElliot model in LAMP.
%  [http://lamp.mccode.org].
%
% Usage:
% ------
% s = sqw_jumpdiffusion; 
% value = s(p,q,w); or value = iData(s,p,q,w)
%
% input:  p: sqw_jumpdiffusion model parameters (double)
%             p(1)= Amplitude 
%             p(2)= D         Diffusion coefficient e.g. few 1E-9 [m^2/s]
%             p(3)= t0        Residence time step between jumps, e.g. 1-4 ps [s]
%         q:  axis along wavevector/momentum (row,double) [Angs-1]
%         w:  axis along energy (column,double) [meV]
% output: signal: model value [iFunc_Sqw2D]
%
% Example:
%   s=sqw_jumpdiffusion;
%   plot(log10(iData(s, [], 0:.1:20, -50:50)))  % q=0:20 Angs-1, w=-50:50 meV
%
% Reference: 
%  C T Chudley and R J Elliott 1961 Proc. Phys. Soc. 77 353
%%
% Version: $Date$
% See also iData, iFunc, sqw_recoil, sqw_diffusion
%   <a href="matlab:doc(iFunc,'Models')">iFunc:Models</a>
% (c) E.Farhi, ILL. License: EUPL.

signal.Name           = [ 'sqw_jumpdiffusion jump/Fick-law diffusion dispersion [' mfilename ']' ];
signal.Description    = 'A 2D S(q,w) jump diffusion dispersion.';

signal.Parameters     = {  ...
  'Amplitude' ...
  'D              Diffusion coefficient e.g. few 1E-9 [m^2/s]' ...
  't0             Residence time step between jumps, e.g. 1-4 ps [s]' ...
   };
  
signal.Dimension      = 2;         % dimensionality of input space (axes) and result
signal.Guess          = [ 1 1e-9 1e-12 ];
signal.UserData.classical     = true;
signal.UserData.DebyeWaller   = false;

% Expression of S(q,w) is found in Egelstaff, Intro to Liquids, Eq (11.13)+(11.16), p 227.
signal.Expression     = { ...
 'q = x; w = y; D = p(2); t0 = p(3)*241.8E9; % in meV-1' ...
 'dq2= D*q.^2*1E20/241.8E9; % in meV, with q in Angs-1' ...
 '% half width of Lorentzian ~ DQ^2 in [meV]' ...
 'fq=dq2;' ...
 'if t0>0, fq = fq./(1+t0*dq2); end' ...
 'signal = p(1)/pi*fq./(w.^2+fq.^2);' ...
 };

signal= iFunc(signal);
signal= iFunc_Sqw2D(signal); % overload Sqw flavour

if nargin == 1 && isnumeric(varargin{1})
  p = varargin{1};
  if numel(p) >= 1, signal.ParameterValues(2) = p(1); end
  if numel(p) >= 2, signal.ParameterValues(3) = p(2); end
end