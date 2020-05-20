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

    deployment.ec2.ebsInitialRootDiskSize = 24; # GB

    deployment.ec2.securityGroups = [ resources.ec2SecurityGroups.allow-ssh
                                      resources.ec2SecurityGroups.allow-cardano
                                      resources.ec2SecurityGroups.allow-cardano-metrics
                                    ];

    # TODO
    # deployment.ec2.associatePublicIpAddress = false;
  };

  relay = { resources, ... }: {
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.fnf-key-pair;

    deployment.ec2.ebsInitialRootDiskSize = 24; # GB

    deployment.ec2.securityGroups = [ resources.ec2SecurityGroups.allow-ssh
                                      resources.ec2SecurityGroups.allow-cardano
                                      resources.ec2SecurityGroups.allow-cardano-metrics
                                      resources.ec2SecurityGroups.allow-prometheus
                                      resources.ec2SecurityGroups.allow-grafana
                                    ];
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

  resources.ec2SecurityGroups.allow-cardano-metrics = {
    inherit region accessKeyId;
    name = "allow-cardano-metrics";
    description = "Allow cardano metrics";
    rules = [ { protocol = "tcp"; fromPort = 12789; toPort = 12789; sourceIp = "0.0.0.0/0"; } ];
  };

  resources.ec2SecurityGroups.allow-prometheus = {
    inherit region accessKeyId;
    name = "allow-prometheus";
    description = "Allow prometheus";
    rules = [ { protocol = "tcp"; fromPort = 9090; toPort = 9090; sourceIp = "0.0.0.0/0"; } ];
  };
}
