function [match, field] = strfind(s, varargin)
% STRFIND Find a string within object.
%
%   STRFIND is equivalent to FINDSTR.
%
% Example: s=estruct('x',1:10,'y','blah'); ischar(strfind(s, 'blah'))
% Version: $Date$ (c) E.Farhi. License: EUPL.
% See also estruct, estruct/findstr, set, get, findobj, findfield

[match, field] = findstr(s, varargin{:});
