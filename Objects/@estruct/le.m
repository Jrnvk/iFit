function c = le(a,b)
%  <=   Less than or equal (le).
%    A <= B does element by element comparisons between A and B
%    and returns an object of the same size with elements set to logical 1
%    where the relation is true and elements set to logical 0 where it is
%    not.
%    When comparing two estruct objects, the monitor weighting is applied.
%
%    C = LE(A,B) is called for the syntax 'A <= B'
%
% Example: s=estruct(-10:10); any(s <= 0)
% Version: $Date$ $Version$ $Author$
% See also estruct, estruct/find, estruct/gt, estruct/lt, estruct/ge, estruct/le, estruct/ne, estruct/eq

if nargin ==1
  b=[];
end
c = binary(a, b, 'le');