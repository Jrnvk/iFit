function wout = replicate (win, wref)
% Make a higher dimensional dataset from a one dimensional dataset by
% replicating the data along the extra dimensions of a reference dataset.
%
% Syntax:
%   >> wout = replicate (win, wref)
%
% Input:
% ------
%   win     One dimensional dataset.
%
%   wref    Reference dataset structure to use as template for expanding the 
%           input straucture.
%           - The plot axis of win must also be plot axis of wref, and the number
%           of points along these common axes must be the same, although the
%           numerical values of the coordinates need not be the same.
%           - The data is expanded along the plot axes of wref that are 
%           integration axes of win. 
%           - The annotations etc. are taken from the reference dataset.
%
% Output:
% -------
%   wout    Output dataset structure.


% Original author: T.G.Perring
%
% $Revision: 301 $ ($Date: 2009-11-03 20:52:59 +0000 (Tue, 03 Nov 2009) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if isa(win,classname)
    wout=dnd(replicate(sqw(win),wref));
else
    error('Check input argument types')
end
