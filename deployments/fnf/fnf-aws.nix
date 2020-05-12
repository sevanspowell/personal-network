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
}
