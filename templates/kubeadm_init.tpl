apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 0.0.0.0
  bindPort: 6443
nodeRegistration:
  name: "master-0"
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
  criSocket: "unix:///var/run/crio/crio.sock"
  kubeletExtraArgs:
    cloud-provider: "external"
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: "systemd"
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
clusterName: cluster.local
etcd:
  local:
    imageRepository: quay.io/coreos
    imageTag: v3.3.12
    dataDir: /var/lib/etcd
    extraArgs:
      metrics: extensive
      election-timeout: "5000"
      heartbeat-interval: "250"
      auto-compaction-retention: "8"
    serverCertSANs:
      - etcd.kube-system.svc
      - etcd.kube-system
      - etcd
      - 127.0.0.1
      - 192.168.0.2
      - 192.168.0.3
      - 192.168.0.4
      - 192.168.0.5
    peerCertSANs:
      - etcd.kube-system.svc
      - etcd.kube-system
      - etcd
      - 127.0.0.1
      - 192.168.0.2
      - 192.168.0.3
      - 192.168.0.4
      - 192.168.0.5
dns:
  type: CoreDNS
  imageRepository: docker.io/coredns
  imageTag: 1.6.7
networking:
  dnsDomain: cluster.local
  serviceSubnet: 192.168.2.0/24
  podSubnet: 192.168.3.0/24
kubernetesVersion: ${KUBERNETES_VERSION}
controlPlaneEndpoint: ${VIP}:6443
certificatesDir: /etc/kubernetes/pki
imageRepository: k8s.gcr.io
useHyperKubeImage: False
apiServer:
  extraArgs:
    authorization-mode: "Node,RBAC"
    bind-address: 0.0.0.0
    apiserver-count: "3"
    endpoint-reconciler-type: "lease"
    service-node-port-range: 30000-32767
    kubelet-preferred-address-types: "InternalDNS,InternalIP,Hostname,ExternalDNS,ExternalIP"
    profiling: "false"
    request-timeout: "1m0s"
    enable-aggregator-routing: "false"
    storage-backend: "etcd3"
    allow-privileged: "true"
    audit-log-path: "/var/log/audit/kube-apiserver-audit.log"
    audit-log-maxage: "30"
    audit-log-maxbackup: "1"
    audit-log-maxsize: "100"
    audit-policy-file: "/etc/kubernetes/audit-policy/apiserver-audit-policy.yaml"
    feature-gates: ${FEATURE_GATES}
    tls-min-version: "VersionTLS12"
    tls-cipher-suites: "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
    event-ttl: 1h0m0s
  extraVolumes:
  - name: audit-policy
    hostPath: /etc/kubernetes/audit-policy/apiserver-audit-policy.yaml
    mountPath: /etc/kubernetes/audit-policy/apiserver-audit-policy.yaml
  - name: audit-log
    hostPath: /var/log/audit/kube-apiserver-audit.log
    mountPath: /var/log/audit/kube-apiserver-audit.log
    readOnly: false
  certSANs:
     - 127.0.0.1
     - 192.168.0.2
     - 192.168.0.3
     - 192.168.0.4
     - 192.168.0.5
     - ${VIP}
  timeoutForControlPlane: "5m0s"
controllerManager:
  extraArgs:
    node-monitor-grace-period: "40s"
    node-monitor-period: "5s"
    pod-eviction-timeout: "5m0s"
    node-cidr-mask-size: "24"
    profiling: "false"
    terminated-pod-gc-threshold: "12500"
    bind-address: 0.0.0.0
    feature-gates: ""
    configure-cloud-routes: "false"
    flex-volume-plugin-dir: "/var/lib/kubelet/volumeplugins"
    tls-min-version: "VersionTLS12"
    tls-cipher-suites: "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
scheduler:
  extraArgs:
    bind-address: 0.0.0.0
    feature-gates: ${FEATURE_GATES}
    tls-min-version: "VersionTLS12"
    tls-cipher-suites: "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
bindAddress: 0.0.0.0
clientConnection:
  acceptContentTypes: ""
  burst: 10
  contentType: "application/vnd.kubernetes.protobuf"
  kubeconfig: ""
  qps: 5
clusterCIDR: 192.168.3.0/24
configSyncPeriod: "15m0s"
conntrack:
  maxPerCore: 32768
  min: 131072
  tcpCloseWaitTimeout: "1h0m0s"
  tcpEstablishedTimeout: "24h0m0s"
enableProfiling: false
healthzBindAddress: 0.0.0.0:10256
hostnameOverride: "master-0"
iptables:
  masqueradeAll: false
  masqueradeBit: 14
  minSyncPeriod: "0s"
  syncPeriod: "30s"
ipvs:
  excludeCIDRs:
  minSyncPeriod: "0s"
  scheduler: "rr"
  syncPeriod: "30s"
  strictARP: false
metricsBindAddress: 127.0.0.1:10249
mode:
nodePortAddresses: []
oomScoreAdj: -999
portRange: "0"
udpIdleTimeout: "250ms"
---
