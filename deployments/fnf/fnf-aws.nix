{ accessKeyId }:

let
  region = "ap-southeast-2";
in
{
  node = { resources, ... }: {
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.fnf-key-pair;

    deployment.ec2.securityGroups = [ "allow-ssh" "allow-cardano" ];

    # TODO
    # deployment.ec2.associatePublicIpAddress = false;
  };

  relay = { resources, ... }: {
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.fnf-key-pair;

    deployment.ec2.securityGroups = [ "allow-ssh" "allow-cardano" ];
  };

  resources.ec2KeyPairs.fnf-key-pair = { inherit region accessKeyId; };

  resources.ec2SecurityGroups.allow-cardano = {
    inherit region accessKeyId;
    name = "allow-cardano";
    description = "Allow cardano port";
    rules = [ { protocol = "tcp"; fromPort = 3001; toPort = 3001; sourceIp = "0.0.0.0/0"; } ];
  };

  resources.ec2SecurityGroups.allow-ssh = {
    inherit region accessKeyId;
    name = "allow-ssh";
    description = "Allow SSH";
    rules = [ { protocol = "tcp"; fromPort = 22; toPort = 22; sourceIp = "0.0.0.0/0"; } ];
  };

  # resources.ec2SecurityGroups.allow-relay = {
  #   inherit region accessKeyId;
  #   name = "allow-relay";
  #   description = "Allow relay node";
  #   rules = [ { protocol = "tcp"; fromPort = 8080; toPort = 8080; sourceIp = "0.0.0.0/0"; } ];
  # };

  # resources.ec2SecurityGroups.allow-block-producers = {
  #   inherit region accessKeyId;
  #   name = "allow-block-producers";
  #   description = "Allow block producer nodes";
  #   rules = [ { protocol = "tcp"; fromPort = 8081; toPort = 8081; sourceIp = "0.0.0.0/0"; } ];
  # };
}
