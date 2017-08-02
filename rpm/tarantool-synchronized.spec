Name: tarantool-synchronized
Version: 0.1.0
Release: 1%{?dist}
Summary: Critical sections for Tarantool
Group: Applications/Databases
License: BSD
URL: https://github.com/tarantool/synchronized
Source0: synchronized-%{version}.tar.gz
BuildArch: noarch
BuildRequires: tarantool-devel >= 1.7.2.0
Requires: tarantool >= 1.7.2.0

%description
The `synchronized` function ensures that one fiber does not enter
a critical section of code while another fiber is in the critical section.
If another fiber tries to enter a critical section, it will wait, block,
until the key is released.

%prep
%setup -q -n synchronized-%{version}

%check
./test/synchronized.test.lua

%install
# Create /usr/share/tarantool/synchronized
mkdir -p %{buildroot}%{_datadir}/tarantool/synchronized
# Copy init.lua to /usr/share/tarantool/synchronized/init.lua
cp -p synchronized/*.lua %{buildroot}%{_datadir}/tarantool/synchronized

%files
%dir %{_datadir}/tarantool/synchronized
%{_datadir}/tarantool/synchronized/
%doc README.md
%{!?_licensedir:%global license %doc}
%license LICENSE AUTHORS

%changelog
* Wed Aug 2 2017 Roman Tsisyk <roman@taratoool.org> 0.1.0-1
 Initial version.
