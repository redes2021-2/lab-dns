Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/focal64"

  config.vm.provider "virtualbox" do |v|
    v.gui = false
      v.memory = 1024
  end

  config.vm.define "PC1" do |m|
      m.vm.network "public_network", ip: "192.168.10.1", bridge: [ 
      "wlp3s0",
      "enp2s0",
      "docker0",
  ]
  end

  config.vm.define "PC2" do |m|
    m.vm.network "public_network", ip: "192.168.10.2", bridge: [
      "wlp3s0",
      "enp2s0",
      "docker0",
    ]
  end

  config.vm.define "PC3" do |m|
    m.vm.network "public_network", ip: "192.168.10.3"
  end
end