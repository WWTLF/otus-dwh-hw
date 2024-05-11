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
  name        = "Private DB SG"
  description = "Private DB SG"
  network_id  = yandex_vpc_network.otus-lab.id

  ingress {
    protocol    = "TCP"
    description = "Access only from the Airflow VM"
    # v4_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
    security_group_id = yandex_vpc_security_group.airflow-sg.id
    port              = 5432
  }
}


resource "yandex_vpc_security_group" "airflow-sg" {
  name        = "Private DB SG"
  description = "Private DB SG"
  network_id  = yandex_vpc_network.otus-lab.id

}



resource "yandex_vpc_security_group_rule" "ingress1" {
  security_group_binding = yandex_vpc_security_group.airflow-sg.id
  protocol               = "TCP"
  description            = "Public access from the Internet"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  port                   = 8080
  direction = "ingress"
}


resource "yandex_vpc_security_group_rule" "egress1" {
  security_group_binding = yandex_vpc_security_group.airflow-sg.id
  protocol               = "TCP"
  direction = "egress"
  description            = "Egress Access to the postgres"
  to_port                = 5432
  security_group_id      = yandex_vpc_security_group.db-sg.id
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
  password   = "123"
}

resource "yandex_mdb_postgresql_cluster" "otus-lab-db-cluster" {
  name        = "lesson10"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.otus-lab.id
  security_group_ids = [ yandex_vpc_security_group.db-sg.id ]

  config {
    version = 15
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 4
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
    subnet_id = yandex_vpc_subnet.otus-lab-subnet-a.id
    security_group_ids = [ yandex_vpc_security_group.airflow-sg.id ]
  }

  metadata = {
    foo      = "bar"
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
resource "yandex_compute_disk" "airflowdisk" {
  
  type     = "network-ssd"
  zone     = "ru-central1-a"
  image_id = "ubuntu-16.04-v20180727"
}

