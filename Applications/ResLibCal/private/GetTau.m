function tau = GetTau(x, getlabel)
%===================================================================================
%  function GetTau(tau)
%  ResLib v.3.4
%===================================================================================
%
%  Tau-values for common monochromator crystals
%
% A. Zheludev, 1999-2006
% Oak Ridge National Laboratory
%====================================================================================
choices={ 'pg(002)', 1.87325;...
      'pg(004)', 3.74650;...
      'ge(111)', 1.92366;...
      'ge(220)', 3.14131;...
      'ge(311)', 3.68351;...
      'be(002)', 3.50702;...
      'pg(110)', 5.49806;...
      'Cu2MnAl(111)', 2*pi/3.437;...
      'Co0.92Fe0.08', 2*pi/1.771;...
      'Ge(511)', 2*pi/1.089;...
      'Ge(533)', 2*pi/0.863;...
      'Si(111)', 2*pi/3.135;...
      'Cu(111)', 2*pi/2.087;...
      'Cu(002)', 2*pi/1.807;...
      'Cu(220)', 2*pi/1.278};

if nargin > 1
  % return the index/label of the closest monochromator
    [dif, index] = sort(abs(cell2mat(choices(:,2))-x));
    index=index(1);
    if dif(1) < 5e-2
      tau = choices{index,1}; % the label
    else
      tau = '';
    end
elseif isnumeric(x)
    tau = x;
else

    index=find(strcmpi(x, choices(:,1)));
    if ~isempty(index)
      tau = choices{index(1), 2};
    else
      tau = [];
    end

end;
