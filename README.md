# iftop-ip
Helps to find the top IP addresses with max Rx/Tx speed rate on Linux systems

# Installation
Clone repository
```
https://github.com/StuxForce/iftop-ip.git
```
Change permissions
```
chmod +x /path/to/iftop_ip.sh
```

# Usage
```
iftop_ip.sh <interface_name>
```
**<interface_name>** - network interface name, like eth0

After calculating connections and speed, you will see output like this:
```
ip_address | direction | speed | connections_count

Top 5 traffic receiving IPs at eth3 interface:
192.168.1.XXX <= 1.39 Mbit/s (2)
192.168.1.XXX <= 1.28 Mbit/s (2)
192.168.3.XXX <= 0.62 Mbit/s (2)
192.168.1.XXX <= 0.59 Mbit/s (2)
188.0.169.XXX <= 0.57 Mbit/s (2)

Top 5 traffic sending IPs at eth3 interface:
95.79.XXX.182 => 5.49 Mbit/s (6)
95.79.XXX.184 => 2.81 Mbit/s (4)
95.79.XXX.174 => 2.21 Mbit/s (3)
95.79.XXX.183 => 2.19 Mbit/s (3)
95.79.XXX.187 => 2.09 Mbit/s (3)
```

