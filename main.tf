provider "aws" {
  profile	=  "${var.aws_profile}"
  region     = "${var.region}"
}
resource "aws_vpc" "main" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags {
      Name = "Code_test_vpc"
    }
}
# get Availability Zones information
data "aws_availability_zones" "available" {}

#gateway
resource "aws_internet_gateway" "gw" {
   vpc_id = "${aws_vpc.main.id}"
    tags {
        Name = "code_test"
    }
}
resource "aws_network_acl" "all" {
   vpc_id = "${aws_vpc.main.id}"
    egress {
        protocol = "-1"
        rule_no = 2
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    ingress {
        protocol = "-1"
        rule_no = 1
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    tags {
        Name = "open acl"
    }
}
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
      Name = "Public"
  }
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }
}

resource "aws_subnet" "PublicAZA" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.publicsubnet_cidr1}"
  tags {
        Name = "PublicAZA"
  }
 availability_zone = "${data.aws_availability_zones.available.names[0]}"
}
resource "aws_route_table_association" "PublicAZA" {
    subnet_id = "${aws_subnet.PublicAZA.id}"
    route_table_id = "${aws_route_table.public.id}"
}
resource "aws_subnet" "PublicAZB" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.publicsubnet_cidr2}"
  tags {
        Name = "PublicAZA"
  }
 availability_zone = "${data.aws_availability_zones.available.names[1]}"
}
resource "aws_route_table_association" "PublicAZB" {
    subnet_id = "${aws_subnet.PublicAZB.id}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_security_group" "webserversg" {
  name = "webserversg"
  tags {
        Name = "webserversg"
  }
  description = "webserversg"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "webserver" {
    ami = "ami-0def3275"
    instance_type = "t2.micro"

    tags {
        Name = "webserver"
    }
    subnet_id = "${aws_subnet.PublicAZA.id}"
    vpc_security_group_ids = ["${aws_security_group.webserversg.id}"]
    associate_public_ip_address = true
    key_name = "codetest"

    provisioner "file" {
	  source      = "master.yml"
	  destination = "/tmp/master.yml"

	  connection {
		type     = "ssh"
		user     = "ubuntu"
		private_key = "${file("codetest.pem")}"
	  }
	}
	
	provisioner "remote-exec" {
		connection {
			type     = "ssh"
			user     = "ubuntu"
			private_key = "${file("codetest.pem")}"
		  }
		inline = [
		"pwd",
		"sudo apt-get update -y",
		"sudo apt-get install ansible -y",
		"sudo ansible-playbook -i localhost /tmp/master.yml"
		]
		}
	
	#provisioner "local-exec" {
#		command = " echo -e \"[webserver]\n${aws_instance.webserver.public_ip} ansible_connection=ssh ansible_ssh_user=ubuntu\" > inventory && ansible-playbook -i inventory master.yml"
#	}
}
