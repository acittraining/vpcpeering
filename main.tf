// created two vpc with name requester and accepter vpc

resource "aws_vpc" "create_vpc" {
 
  count      = "${length(var.list)}"
  cidr_block = "${lookup(var.map, element(var.list, count.index))}"


  tags = {

    Name  = var.list[count.index]


  }
}

// created vpc peering connection between both vpc by auto-accepting the request
resource "aws_vpc_peering_connection" "just_peer" {
  vpc_id        = "${aws_vpc.create_vpc[0].id}"
  peer_vpc_id   = "${aws_vpc.create_vpc[1].id}"
  
  auto_accept   =  true
  
 tags = {

     Name   =   "just_peer"

 }  
  depends_on =   [aws_vpc.create_vpc]

}




// creating public subnet in requester_vpc and private subnet in accepter_vpc

resource "aws_subnet" "create_subnet" {
 
  count = "${length(var.list)}"
  availability_zone = "${count.index  ==  0 ? "ap-south-1a" : "ap-south-1b"}"
  vpc_id  = "${element(aws_vpc.create_vpc.*.id, count.index)}"


  map_public_ip_on_launch = "${count.index == 0 ? "true" : "false"}"
  cidr_block = "10.${count.index}.0.0/20"
   
  tags = {

    Name = "${count.index == 0 ? "public_subnet" : "private_subnet"}"

  }
}


// attaching internet gateway to the public subnet which is in requester_vpc

resource "aws_internet_gateway" "requester_igw" {

  vpc_id = aws_vpc.create_vpc[0].id


  tags = {

    Name = "requester_igw"


  }
}




/* creating route_table in accepter_vpc in which our destination is the cidr of public_subnet of requester_vpc and target is the id of peering_connection */

resource "aws_route_table" "accepter_rt" {

    vpc_id  = "${aws_vpc.create_vpc[1].id}"

    route {

      cidr_block        = "10.0.0.0/20"
      vpc_peering_connection_id     = "${aws_vpc_peering_connection.just_peer.id}"

    }

    depends_on  = [aws_vpc_peering_connection.just_peer]
    tags = {

        Name    = "accepter_routetable"
    }
}

/* creating route_table in requester_vpc in which our destination is the cidr of private_subnet of accepter_vpc and target is the id of peering_connection */

resource "aws_route_table" "requester_rt" {
    vpc_id  = "${aws_vpc.create_vpc[0].id}"
    route {
    cidr_block        = "0.0.0.0/0"
    gateway_id        = "${aws_internet_gateway.requester_igw.id}"


    }

    route {
    cidr_block        = "10.1.0.0/20"
    vpc_peering_connection_id     = "${aws_vpc_peering_connection.just_peer.id}"
    }

    depends_on  = [aws_vpc_peering_connection.just_peer]


    tags = {

        Name    = "requester_routetable"
    }
}

// associating requester_route_table with public_subnet

resource "aws_route_table_association" "requester_rt_association" {
    
     subnet_id       = "${aws_subnet.create_subnet[0].id}"
     route_table_id  = "${aws_route_table.requester_rt.id }"
}


//associating accepter_route_table with private_subnet
resource "aws_route_table_association" "accepter_rt_association" {
    
    subnet_id       = "${aws_subnet.create_subnet[1].id}"
    route_table_id  = "${aws_route_table.accepter_rt.id }"


}


// creating security_group for both the instances i.e. public and private 

resource "aws_security_group" "create_sg" {
    count =   2
    name  =   "${count.index  == 0 ? "requester_sg" : "accepter_sg"}"
    description = "alowing only ssh to connect with ec2 and then connect to another ec2 which is in private vpc"
    vpc_id      = "${aws_vpc.create_vpc[count.index].id}"


    ingress {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
      cidr_blocks = [count.index  ==  0 ? "0.0.0.0/0" : "10.${count.index -1}.0.0/20"]


    }


    egress  {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      cidr_blocks  = ["0.0.0.0/0"]


    }


    tags  = {


      Name  = "${count.index  == 0 ? "requester_sg" : "accepter_sg"}"


    }
}




// launching both the instances with different key_pair


resource "aws_instance" "create_inst" {
  count = 2
  instance_type = "t2.micro"
  ami           = "ami-0447a12f28fddb066"
  key_name      = "${count.index == 0 ? "peering" : "acceptor"}"
  subnet_id     = "${aws_subnet.create_subnet[count.index].id}"
  security_groups = [ aws_security_group.create_sg[count.index].id ]


  tags  = {
    
    Name  = "${count.index  == 0 ? "public_inst" : "private_inst"}"
    
  }
}
