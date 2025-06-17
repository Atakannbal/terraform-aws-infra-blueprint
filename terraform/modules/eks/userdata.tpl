MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="/:/+++"

--/:/+++
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
# In multipart MIME format to support EKS appending to it
/etc/eks/bootstrap.sh --apiserver-endpoint '${cluster_endpoint}' --b64-cluster-ca '${certificate_authority_data}' --kubelet-extra-args '--max-pods=8' '${cluster_name}'
--/:/+++--