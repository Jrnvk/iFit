function s = edit(s)
% s = edit(s) : edit an iFunc model with a window dialogue
%
%   @iFunc/edit: displays a window dialogue to view/edit properties of an
%     iFunc model definition
%
% input:  s: object or array (iFunc) 
% output: s: object or array (iFunc) 
%
% Version: $Date$ $Version$ $Author$
% See also  iFunc/struct, iFunc/char
%

s = ifitmakefunc(s);
