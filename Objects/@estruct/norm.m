function v = norm(a, varargin)
% NORM   Object norm.
%   Computes the norm of the object Signal. The default is to use the 
%   2-norm, defined as sqrt(sum( |a|^2 ))
%
%     NORM(V,P)    = sum(abs(V).^P)^(1/P).
%     NORM(V)      = norm(V,2).
%     NORM(V,inf)  = max(abs(V)).
%     NORM(V,-inf) = min(abs(V)).
%
% Version: $Date$ $Version$ $Author$
% See also estruct, estruct/sum, estruct/trapz, norm

v = unary(a, 'norm', varargin{:});

