function v = isscalar(a)
%  ISSCALAR True if array is a scalar.
%    ISSCALAR(S) returns logical true (1) if S is a 1 x 1 object Signal
%    and logical false (0) otherwise.
%
% Example: s=estruct(pi); isscalar(axescheck(s))
% Version: $Date$ $Version$ $Author$
% See also estruct, estruct/isvector, estruct/size, estruct/ndims

v = unary(a, 'isscalar');
if iscell(v), v=cell2mat(v); end
v = logical(v);