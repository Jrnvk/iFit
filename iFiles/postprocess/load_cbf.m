function a=load_cbf(a)
% function a=load_cbf(a)
%
% Returns an iData style dataset from a CBF file
%
% Version: $Revision: 1.1 $
% See also: iData/load, iLoad, save, iData/saveas

% handle input iData arrays
if length(a(:)) > 1
  for index=1:length(a(:))
    a(index) = feval(mfilename, a(index));
  end
  return
end
a.Data.parameters = str2struct(a.Data.header);

