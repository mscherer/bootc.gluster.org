FROM quay.io/bootc-devel/fedora-bootc-43-minimal@sha256:a61dd19b6bfaa30503a2783b23bf9c49a5b129c6543a375bbbab253645935445
#
# empty space for easier rebasing
#

# needed to start the various software at boot
COPY servers.preset /usr/lib/systemd/system-preset/01-servers.preset

# install caddy (reverse proxy) and various stuff
RUN <<EORUN
# fix/workaround https://bugzilla.redhat.com/show_bug.cgi?id=2432642
dnf install -y --setopt=install_weak_deps=false bubblewrap

dnf install -y --setopt=install_weak_deps=false caddy

# systemd-networkd-defaults pull systemd-networkd
dnf install -y --setopt=install_weak_deps=false openssh-server systemd-networkd-defaults

dnf clean all
rm -Rf /var/log/dnf5.log /var/lib/dnf/ /var/cache/
EORUN

# disable the flood of message on the console
COPY disable-flood.conf /usr/lib/sysctl.d/60-disable-flood.conf

# needed as bootc container lint complain about it. Some work should be done
# to get if fixed upstream
# also used to copy the config in /etc/
COPY caddy.tmpfile.conf /usr/lib/tmpfiles.d/caddy.conf
COPY site.caddyfile /usr/lib/site.caddyfile

COPY motd.conf /usr/lib/motd.d/

COPY set_hostname/set_hostname.service /usr/lib/systemd/system/set_hostname.service
COPY set_hostname/set_hostname.sh      /usr/local/bin/set_hostname.sh

RUN bootc container lint --fatal-warnings
