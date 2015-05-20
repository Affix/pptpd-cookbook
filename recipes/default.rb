#
# Cookbook Name:: poptop
# Recipe:: default
#
# Copyright 2015, Affix.ME
#
# All rights reserved - Do Not Redistribute
#

cookbook_file "/etc/yum.repos.d/pptp.repo" do
        source "pptp.repo"
        mode "0644"
        action :create
end

package 'pptpd' do
  action :install
end

directory "/etc/sysctl.d" do
  mode "0644"
end

cookbook_file "/etc/pptpd.conf" do
        source "pptpd.conf"
        mode "0644"
        action :create
end

cookbook_file "/etc/ppp/chap-secrets" do
        source "chap-secrets"
        mode "0644"
        action :create
end

cookbook_file "/etc/ppp/options.pptpd" do
        source "options.pptpd"
        mode "0644"
        action :create
end

cookbook_file "/etc/sysctl.d/20-ipv4-forward.conf" do
        source "sysctl.conf"
        mode "0644"
        action :create
end

execute "Execute Sysctl" do
  command "sysctl -p /etc/sysctl.d/20-ipv4-forward.conf"
  not_if  "sysctl -e net.ipv4.ip_forward | grep 1"
end

execute "IPTables" do
	command "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
	command "iptables --table nat --append POSTROUTING --out-interface ppp0 -j MASQUERADE"
	command "iptables -I INPUT -s 10.0.0.0/8 -i ppp0 -j ACCEPT"
	command "iptables --append FORWARD --in-interface eth0 -j ACCEPT"
	not_if "iptables -t nat -nL | grep -i MASQUERADE"
end

service 'pptpd' do
        action [ :enable, :start]
end
