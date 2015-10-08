#!/usr/bin/python
import yaml
import ruamel.yaml
import argparse
import json
import argparse
import subprocess
import re

svcFile = '/dockervolumes/puppet1/etc/puppet/hieradata/common.yaml'
dnsFile = '/dockervolumes/dns1/dnsmasq.d/dns/dockstack.dns'
siteFile = '/dockervolumes/puppet1/etc/puppet/manifests/site.pp'


def register(containerName, ipAddress, serviceName, action):
  if action == 'add':
    print 'adding registration'
    serviceYaml=ruamel.yaml.load(open(svcFile), ruamel.yaml.RoundTripLoader)
    svcAr = serviceYaml['registered_services'][serviceName]
    if svcAr is None:
      svcAr = []
      svcAr.append(containerName)
      serviceYaml['registered_services'][serviceName] = svcAr
    else:
      serviceYaml['registered_services'][serviceName].append(containerName)
    
  if action == 'remove':
    print 'removing registration'
    serviceYaml=ruamel.yaml.load(open(svcFile), ruamel.yaml.RoundTripLoader)
    serviceYaml['registered_services'][serviceName].remove(containerName)
    if len(serviceYaml['registered_services'][serviceName]) == 0:
      serviceYaml['registered_services'][serviceName] = None

  serviceUpdate = ruamel.yaml.dump(serviceYaml, Dumper=ruamel.yaml.RoundTripDumper)
  f = open(svcFile, 'w')
  f.write(serviceUpdate)
  f.close()

def updatecert(containerName, domain, master, action):
  print 'updating puppet cert'
  nodeName = containerName + '.' + domain
  cmd = 'docker exec ' + master + ' puppet cert clean ' + nodeName
  print cmd
  subprocess.call(cmd.split())

def getconfig(containerName):
  print 'updating config'
  cmd = 'docker exec ' + containerName + ' puppet agent -t'
  print cmd
  subprocess.call(cmd.split())

def updatehaproxy(haproxy):
  print 'updating haproxy'
  cmd = 'docker exec ' + haproxy + ' puppet agent -t'
  subprocess.call(cmd.split())
  cmd = 'docker exec ' + haproxy + ' supervisorctl restart haproxy'
  subprocess.call(cmd.split())

def updatedns(containerName, ipAddress, domain, action):
  newDnsEntry = ipAddress + ' ' + containerName + '.' + domain
  f = open(dnsFile)
  dnsFileContent = f.read()
  f.close()
  dnsStringList = dnsFileContent.splitlines()
  counter = 0
  lineNumber = ''

  for line in dnsStringList:
    if containerName in line:
      lineNumber = counter
      lineContent = line
    counter = counter + 1

  if action == 'add':
    print 'adding dns entry'
    if lineNumber:
      dnsStringList[lineNumber] = newDnsEntry
    else:
      dnsStringList.append(newDnsEntry)

  if action == 'remove':
    print 'removing dns entry'
    dnsStringList.remove(lineContent)

  f = open(dnsFile,'w')
  for item in dnsStringList:
    f.write("%s\n" % item)
  f.close()
  cmd='docker exec dns1 pkill -x -HUP dnsmasq'
  subprocess.call(cmd.split())

def updatesite(containerName, serviceName, domain, action):
  nodeName = containerName + '.' + domain
  f = open(siteFile)
  siteFileContent = f.read()
  f.close()
  serviceStringPattern = re.compile('node \''+serviceName+'\'')
  nodeNamePattern = re.compile(nodeName)
  siteFileStringCounter = 0
  siteFileStringLineNumber = None
  siteFileStringList = siteFileContent.splitlines()
  for siteStringLine in siteFileStringList:
    if serviceStringPattern.search(siteStringLine):
      siteFileStringLineNumber = siteFileStringCounter
    siteFileStringCounter = siteFileStringCounter + 1

  nodeCounter = 0
  nodeLineNumber = None
  if siteFileStringLineNumber is not None:
    serviceLineList = siteFileStringList[siteFileStringLineNumber].split()
    for serviceLine in serviceLineList:
      if nodeNamePattern.search(serviceLine):
        nodeLineNumber = nodeCounter
        foundServiceLine = serviceLine
      nodeCounter = nodeCounter + 1

  
    if nodeLineNumber is not None:
      if action == 'remove':
        print 'removing site entry'
        serviceLineList.remove(',\'' + nodeName + '\'')
        serviceLineList = ' '.join(serviceLineList)
        siteFileStringList[siteFileStringLineNumber] = serviceLineList
    else:
      if action == 'add' and nodeLineNumber is None:
        print 'adding site entry'
        serviceLineLength = len(serviceLineList)
        serviceLineList.insert(serviceLineLength - 1, ',\'' + nodeName + '\'')
        serviceLineList = ' '.join(serviceLineList)
        siteFileStringList[siteFileStringLineNumber] = serviceLineList

  #print '\n'.join(siteFileStringList)
  f = open(siteFile,'w')
  f.write('\n'.join(siteFileStringList))
  f.close()

if __name__ == "__main__":

  parser = argparse.ArgumentParser(description='updates hiera file')
  parser.add_argument('-c','--container',
                   help='container name')
  parser.add_argument('-s','--service',
                   help='service')
  parser.add_argument('-i','--ipaddress',
                   help='ipaddress')
  parser.add_argument('-d','--domain',
                   help='domain')
  parser.add_argument('-m','--master',
                   help='Puppet Master')
  parser.add_argument('-x','--haproxy',
                   help='Haproxy Container')
  parser.add_argument('-k','--keystone',
                   help='Keystone Container')
  parser.add_argument('--types',
                   help='csv with values of register,updatecert,getconfig,updatehaproxy,updatedns,updatesite')
  parser.add_argument("action",
                   help='add/remove')
  args = parser.parse_args()

  serviceTypes = args.types.split(',')
  serviceTypeOptions = ['updatekeystone','register','updatecert','getconfig','updatehaproxy','updatedns','updatesite']
  print args
  for serviceType in serviceTypes:
    if serviceType not in serviceTypeOptions:
      print 'wrong service type'

  if 'register' in serviceTypes:
    register(args.container, args.ipaddress, args.service, args.action)

  if 'updatedns' in serviceTypes:
    updatedns(args.container, args.ipaddress, args.domain, args.action)

  if 'updatesite' in serviceTypes:
    updatesite(args.container, args.service, args.domain, args.action)

  if 'updatecert' in serviceTypes:
    updatecert(args.container, args.domain, args.master, args.action)

  if 'getconfig' in serviceTypes:
    getconfig(args.container)

  if 'updatehaproxy' in serviceTypes:
    updatehaproxy(args.haproxy)

  if 'updatekeystone' in serviceTypes:
    getconfig(args.keystone)
