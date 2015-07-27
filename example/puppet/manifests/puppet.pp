node /web01/ {

  network::interface { 'eth0':
    ipaddress => '10.0.0.101',
    netmask   => '255.255.255.0',
  }
  network::route { 'eth0':
    ipaddress => [ '0.0.0.0' ],
    netmask   => [ '0.0.0.0' ],
    gateway   => [ '10.0.0.1' ],
  }

}

node /web02/ {

  network::interface { 'eth0':
    ipaddress => '10.0.0.102',
    netmask   => '255.255.255.0',
  }
  network::route { 'eth0':
    ipaddress => [ '0.0.0.0' ],
    netmask   => [ '0.0.0.0' ],
    gateway   => [ '10.0.0.1' ],
  }

}

node /web03/ {

  network::interface { 'eth0':
    ipaddress => '10.0.0.103',
    netmask   => '255.255.255.0',
  }
  network::route { 'eth0':
    ipaddress => [ '0.0.0.0' ],
    netmask   => [ '0.0.0.0' ],
    gateway   => [ '10.0.0.1' ],
  }

}
