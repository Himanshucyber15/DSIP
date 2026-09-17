#!/bin/bash

NETWORK_ONLY=false
WIFI_ONLY=false

if [[ "$1" == "--network" ]]; then
  NETWORK_ONLY=true
elif [[ "$1" == "--wifi" ]]; then
  WIFI_ONLY=true
fi

# Comprehensive wired network drivers keywords (Intel, Realtek, Broadcom, etc.)
network_keywords="e1000e|e1000|r8169|r8168|tg3|ixgbe|igb|bnx2|broadcom|sky2|atl1c|atl1e|atl1|atlantic|cxgb3|cxgb4|chelsio|cavium|c6x999|forcedeth|fjes|ixgbvf|ixgbevf|mlx4_en|mlx5_core|qede|qede_pf|qed|qedr|skge|sk98lin|sfc|sfcvf|sis190|sunhwtstamp|tlan|tg3|vmxnet3|virtio_net|xennet|xgbe|xgbevf"

# Comprehensive Wi-Fi drivers keywords (Intel, Atheros, Broadcom, Realtek, Mediatek, etc.)
wifi_keywords="iwlwifi|ath9k|ath10k|ath6kl|ath5k|ath|b43|brcmsmac|brcmfmac|rtl8xxxu|rtl8192ce|rtl8192cu|rtl8192de|rtl8723be|rtl8821ae|rtl8822be|rtlwifi|mt76|mt7615|mt7601u|mt76x2u|mt76x0u|wl|wiphy|libertas|zd1211rw|prism54|p54|p54pci|p54usb|ipw2100|ipw2200|ipw3945|r8712u|rt2x00|rt2800usb|rt2800pci|rt2800lib|rt61pci|rt73usb|rt2500pci|rt2500usb|rt5592|rt5592sta"

# Refined description keywords for more relevant filtering
network_desc_keywords="ethernet|network|nic|controller.*ethernet|adapter.*network"

wifi_desc_keywords="wifi|wireless|wlan|radio"

count=0

for mod in $(lsmod | awk 'NR>1 {print $1}'); do
  desc=$(modinfo "$mod" 2>/dev/null | grep -i ^description: | cut -d: -f2- | sed 's/^ *//')

  if $NETWORK_ONLY; then
    # Check if module name or description matches network keywords
    if ! echo "$mod" | grep -Eiq "$network_keywords" && ! echo "$desc" | grep -Eiq "$network_desc_keywords"; then
      continue
    fi
  elif $WIFI_ONLY; then
    # Check if module name or description matches wifi keywords
    if ! echo "$mod" | grep -Eiq "$wifi_keywords" && ! echo "$desc" | grep -Eiq "$wifi_desc_keywords"; then
      continue
    fi
  fi

  echo -n "Module: $mod"
  if [ -n "$desc" ]; then
    echo " — Description: $desc"
  else
    echo
  fi

  path=$(find /lib/modules/$(uname -r) -type f \( -name "${mod}.ko" -o -name "${mod}.ko.xz" \) 2>/dev/null)
  if [ -n "$path" ]; then
    echo "Location: $path"
  fi

  count=$((count + 1))
done

echo "Total number of modules: $count"

