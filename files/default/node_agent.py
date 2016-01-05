import psutil
import time
import os
import sys
from socket import socket
running_in_pydev = 'PYDEV_CONSOLE_ENCODING' in os.environ
sys.stdout.flush()
from yaml import load, dump
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper


def getParms():
    f = open('/etc/ec2/meta_data.yaml')
    meta = load(f, Loader=Loader)
    f.close()
    parms = dict(meta.items())
    return parms

parms = getParms()
environment = parms['environment']
nodename = parms['nodename']
server_type = parms['server_type']
location = parms['location']
slug = parms['slug']

monitor_server = None
while monitor_server==None:
    try:
        monitor_server = open('/var/chef/cache/monitor_ip_address.txt').readlines()[0].strip()
    except:
        monitor_server = None
        time.sleep(1)
        


if running_in_pydev==True:
    delay = 10
    server_type='localhost'
else:
    delay = 60

def getSock(parms):
    if running_in_pydev==False:
        CARBON_SERVER = monitor_server
        print CARBON_SERVER
    else:
        CARBON_SERVER = monitor_server
    CARBON_PORT = 2003
    sock = socket()
    try:
      sock.connect( (CARBON_SERVER,CARBON_PORT) )
      print 'connected to ' + parms['monitor_server']
    except:
      print "Couldn't connect to %(server)s on port %(port)d, is carbon-agent.py running?" % { 'server':CARBON_SERVER, 'port':CARBON_PORT }
      #sys.exit(1)
    return sock
sock = getSock(parms)

def getCpu():
    cputimes = psutil.cpu_times()
    cpu={}
    cpu['cpu.nice']=cputimes.nice
    cpu['cpu.user']=cputimes.user
    cpu['cpu.system']=cputimes.system
    cpu['cpu.idle']=cputimes.idle
    cpu['cpu.iowait']=cputimes.iowait
    cpu['cpu.irq']=cputimes.irq
    cpu['cpu.softirq']=cputimes.softirq
    
    load = os.getloadavg()
    cpu['cpu.load_1']=load[0]
    cpu['cpu.load_5']=load[1]
    cpu['cpu.load_15']=load[2]
    
    try:
        cmd = """vmstat -s | grep -i stolen"""
        steal = os.system(cmd)
        cpu['cpu.steal']=steal
    except:
        pass
    
    
    return cpu

def getPysMem():

    try:
        phymem = psutil.phymem_usage()
    except:
        phymem = psutil.virtual_memory()
        
    mem={}
    mem['phymem.total']=phymem.total
    mem['phymem.used']=phymem.used
    mem['phymem.free']=phymem.free
    mem['phymem.percent']=phymem.percent
    
    try:
        virtmem = psutil.virtmem_usage()
        virt={}
        virt['virtual_mem.total']=virtmem.total
        virt['virtual_mem.used']=virtmem.used
        virt['virtual_mem.free']=virtmem.free
        virt['virtual_mem.percent']=virtmem.percent
    except:
        virt={}
        

    return mem, virt

def getDiskIoCounters():
    
    disk_io_counters = psutil.disk_io_counters()
    diskiocounters={}
    diskiocounters['disk_io_counters.read_count']=disk_io_counters.read_count
    diskiocounters['disk_io_counters.write_count']=disk_io_counters.write_count
    diskiocounters['disk_io_counters.read_bytes']=disk_io_counters.read_bytes
    diskiocounters['disk_io_counters.write_bytes']=disk_io_counters.write_bytes
    diskiocounters['disk_io_counters.read_time']=disk_io_counters.read_time
    diskiocounters['disk_io_counters.write_time']=disk_io_counters.write_time
    
    return diskiocounters

def getDisk():
    diskpartistions = {}
    partitons = psutil.disk_partitions()
    for part in partitons:
        device = part.device.replace('/','-')
        mountpoint = part.mountpoint
        du = psutil.disk_usage(mountpoint)
        
        diskpartistions['disk_partitions.%s.%s.total'%(device, mountpoint.replace('/','-'))]=du.total
        diskpartistions['disk_partitions.%s.%s.used'%(device, mountpoint.replace('/','-'))]=du.used
        diskpartistions['disk_partitions.%s.%s.free'%(device, mountpoint.replace('/','-'))]=du.free
        diskpartistions['disk_partitions.%s.%s.precent'%(device, mountpoint.replace('/','-'))]=du.percent
    
    return diskpartistions

def getIo():
    ioo={}
    
    try:
        io = psutil.network_io_counters(pernic=True)
        for k,iostat in io.iteritems():
            ioo['%s.bytes_sent'%k] = iostat.bytes_sent
            ioo['%s.bytes_recv'%k] = iostat.bytes_recv
            ioo['%s.packets_sent'%k] = iostat.packets_sent
            ioo['%s.packets_recv'%k] = iostat.packets_recv
    except:
        pass
    return ioo

while True:
    
    update_data = {}
    
    cpu_percent = psutil.cpu_percent(interval=delay, percpu=True)
    cpu_core_percent = {}
    for k,v in enumerate(cpu_percent):
        cpu_core_percent['cpu.cpu_percent.core.%s'%k]=v
    cpu = getCpu()
    phymem, virtmem = getPysMem()
    io = getIo()
    dioc = getDiskIoCounters()
    dpart = getDisk()
    
    update_data.update(cpu)
    update_data.update(cpu_core_percent)
    update_data.update(phymem)
    update_data.update(virtmem)
    update_data.update(io)
    update_data.update(dioc)
    update_data.update(dpart)
    
    
    
    now = int( time.time() )
    lines = []
    #"bidder.hongkong.development.nodename"
    for metric_name, metric_value in update_data.iteritems():
        tree = "%s.%s.%s.%s" % (server_type,location,environment,nodename.replace('.','-'))
        lines.append("%s.%s %s %d" % (tree,metric_name,metric_value,now))
    
    message = '\n'.join(lines) + '\n' #all lines must end in a newline
    
    if running_in_pydev==True:
        print "sending message\n"
        print '-' * 80
        print message
        print
        
    try:
        sock.sendall(message)
    except:
        parms = getParms()
        sock = getSock(parms)