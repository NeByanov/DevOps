#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this installer with sudo" >&2
  exit 1
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
helper_target=/usr/local/sbin/cloud-provider-kind-clean-stale-gateways
dropin_dir=/etc/systemd/system/cloud-provider-kind.service.d
dropin_target=$dropin_dir/10-clean-stale-gateways.conf

if [ ! -f /etc/systemd/system/cloud-provider-kind.service ]; then
  echo "cloud-provider-kind.service was not found" >&2
  exit 1
fi

if [ -e "$helper_target" ] && ! cmp -s "$script_dir/cloud-provider-kind-clean-stale-gateways.sh" "$helper_target"; then
  echo "$helper_target already exists with different content" >&2
  exit 1
fi

if [ -e "$dropin_target" ] && ! cmp -s "$script_dir/10-clean-stale-gateways.conf" "$dropin_target"; then
  echo "$dropin_target already exists with different content" >&2
  exit 1
fi

install -o root -g root -m 0755 \
  "$script_dir/cloud-provider-kind-clean-stale-gateways.sh" \
  "$helper_target"
install -d -o root -g root -m 0755 "$dropin_dir"
install -o root -g root -m 0644 \
  "$script_dir/10-clean-stale-gateways.conf" \
  "$dropin_target"

systemctl daemon-reload
systemctl restart cloud-provider-kind.service
systemctl is-active --quiet cloud-provider-kind.service

echo "cloud-provider-kind Gateway recovery hook installed"
