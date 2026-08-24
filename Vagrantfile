Vagrant.configure("2") do |config|

  config.vm.box = "debian/bookworm64"

  config.vm.define "oltp" do |oltp|

    oltp.vm.hostname = "db-oltp01"

    oltp.vm.network "private_network",
      ip: "192.168.56.11"

    oltp.vm.provider "virtualbox" do |vb|
      vb.name = "sakila-db-oltp01"
      vb.memory = 2048
      vb.cpus = 2
    end

    oltp.vm.provision "shell",
      path: "provisioning/oltp.sh"

  end

end