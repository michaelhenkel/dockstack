require 'resolv' 
require 'ipaddr' 
 
module Puppet::Parser::Functions 
 newfunction(:get_ip_addr, :type => :rvalue) do |args| 
  IPAddr.new(lookupvar('ipaddress')).to_i % 60
 end 
end
