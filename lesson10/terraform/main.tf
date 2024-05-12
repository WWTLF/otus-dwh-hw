terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
}

resource "yandex_vpc_network" "otus-lab" {
  name = "otus-lab"
}

resource "yandex_vpc_subnet" "otus-lab-subnet-a" {
  v4_cidr_blocks = ["10.2.0.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.otus-lab.id
}


resource "yandex_vpc_subnet" "otus-lab-subnet-b" {
  v4_cidr_blocks = ["10.3.0.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.otus-lab.id
}



resource "yandex_vpc_security_group" "db-sg" {
  name        = "db-sg"
  description = "Private DB SG"
  network_id  = yandex_vpc_network.otus-lab.id

  ingress {
    protocol          = "TCP"
    description       = "Access only from the Airflow VM"
    security_group_id = yandex_vpc_security_group.airflow-sg.id    
    port              = 6432
  }

  ingress {
    protocol          = "ICMP"
    description       = "Access only from the Airflow VM"
    security_group_id = yandex_vpc_security_group.airflow-sg.id    
  }
}


resource "yandex_vpc_security_group" "airflow-sg" {
  name        = "airflow-sg"
  description = "Private DB SG"
  network_id  = yandex_vpc_network.otus-lab.id

}



resource "yandex_vpc_security_group_rule" "ingress-80" {
  security_group_binding = yandex_vpc_security_group.airflow-sg.id
  protocol               = "TCP"
  description            = "Public access from the Internet"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  port                   = 80
  direction              = "ingress"
}

resource "yandex_vpc_security_group_rule" "ingress-22" {
  security_group_binding = yandex_vpc_security_group.airflow-sg.id
  protocol               = "TCP"
  description            = "Public access from the Internet"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  port                   = 22
  direction              = "ingress"
}



resource "yandex_vpc_security_group_rule" "egress-6432" {
  security_group_binding = yandex_vpc_security_group.airflow-sg.id
  protocol               = "TCP"
  direction              = "egress"
  description            = "Egress Access to the postgres"  
  port                   = 6432
  security_group_id      = yandex_vpc_security_group.db-sg.id
}


resource "yandex_vpc_security_group_rule" "egress-icmp" {
  security_group_binding = yandex_vpc_security_group.airflow-sg.id
  protocol               = "ICMP"
  direction              = "egress"
  description            = "Egress Access to the postgres"  
  security_group_id      = yandex_vpc_security_group.db-sg.id
}


resource "yandex_vpc_security_group_rule" "egress-open-notify" {
  security_group_binding = yandex_vpc_security_group.airflow-sg.id
  protocol               = "TCP"
  direction              = "egress"
  description            = "Egress Access to the open-notify"
  port                   = 80
  v4_cidr_blocks = [ "138.68.39.196/32" ]
}



resource "yandex_mdb_postgresql_database" "lesson10" {
  cluster_id = yandex_mdb_postgresql_cluster.otus-lab-db-cluster.id
  name       = "lesson10"
  owner      = yandex_mdb_postgresql_user.user.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
  extension {
    name = "uuid-ossp"
  }
}

resource "yandex_mdb_postgresql_user" "user" {
  cluster_id = yandex_mdb_postgresql_cluster.otus-lab-db-cluster.id
  name       = "user"
  password   = "12345678"
}

resource "yandex_mdb_postgresql_cluster" "otus-lab-db-cluster" {
  name               = "lesson10"
  environment        = "PRESTABLE"
  network_id         = yandex_vpc_network.otus-lab.id
  security_group_ids = [yandex_vpc_security_group.db-sg.id]

  config {
    version = 15
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 16
    }
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.otus-lab-subnet-a.id
  }
}

resource "yandex_compute_instance" "airflow-vm" {
  name        = "airflowvm"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.airflowdisk.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.otus-lab-subnet-a.id
    security_group_ids = [yandex_vpc_security_group.airflow-sg.id]
    nat                = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    serial-port-enable =  "1"
    enable-oslogin = true
  }
}
resource "yandex_compute_disk" "airflowdisk" {
  type     = "network-ssd"
  zone     = "ru-central1-a"
  image_id = "fd8829m2l6d5lu2qip10"
  size     = 16
}

