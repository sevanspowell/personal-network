{ accessKeyId }:

let
  region = "ap-southeast-2";
in
{
  resources.s3Buckets.backups = {
    inherit region accessKeyId;
    name = "backups";
  };
}
