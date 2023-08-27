#VPC Peering

What is VPC Peering ?
A VPC peering connection is a networking connection between two VPCs that enables you to route traffic between them using private IPv4 addresses or IPv6 addresses. Instances in either VPC can communicate with each other as if they are within the same network. You can create a VPC peering connection between your own VPCs, or with a VPC in another AWS account. The VPCs can be in different regions (also known as an inter-region VPC peering connection).

Peering means the exchange of data directly between internet service providers, rather than via the internet.

So, VPC peering allows us to exchange or share data among different VPC's of AWS which can be in different accounts and in different regions.

AWS is well known for its friendly or user interactive behaviour , so it provides us an interactive naming convention that is Requester and Accepter.

Requester VPC - The VPC from which we are creating request to peer another VPC.

Accepter VPC - The VPC which will accept the request for peering .

Condition-
We cannot create a VPC peering connection between VPCs with matching or overlapping IPv4 CIDR blocks.
