local promtail_scrape_config = import 'github.com/grafana/loki/production/ksonnet/promtail/scrape_config.libsonnet';

{
  _config+:: {
    cluster: error 'must specify cluster',
    metrics_url: error 'must specify metrics url',
    metrics_tenant_id: error 'must specify metrics tenant',
    metrics_api_key_path: error 'must specify metrics api key path',
    logs_url: error 'must specify logs url',
    logs_tenant_id: error 'must specify logs tenant',
    logs_api_key_path: error 'must specify metrics api key path',
  },

  grafana_agent_config+:: {
    integrations: {
      prometheus_remote_write: [
        {
          basic_auth: { username: $._config.metrics_tenant_id, password_file: $._config.metrics_api_key_path },
          url: $._config.metrics_url,
        },
      ],
    },
    logs: {
      configs: [
        {
          name: 'integrations',
          clients: [
            {
              basic_auth: { username: $._config.logs_tenant_id, password_file: $._config.logs_api_key_path },
              external_labels: {
                cluster: $._config.cluster,
                scraper: 'grafana-agent',  // TODO: remove this once this actually pushes logs.
              },
              url: $._config.logs_url,
            },
          ],
          positions: {
            filename: '/tmp/positions.yaml',
          },
          target_config: {
            sync_period: '10s',
          },
          scrape_configs: promtail_scrape_config.promtail_config.scrape_configs,
        },
      ],
    },
    metrics: {
      configs: [
        {
          name: 'integrations',
          remote_write: [
            {
              basic_auth: { username: $._config.metrics_tenant_id, password_file: $._config.metrics_api_key_path },
              url: $._config.metrics_url,
            },
          ],
          scrape_configs: [
            {
              bearer_token_file: '/var/run/secrets/kubernetes.io/serviceaccount/token',
              job_name: 'integrations/kubernetes/cadvisor',
              kubernetes_sd_configs: [{ role: 'node' }],
              metric_relabel_configs: [
                {
                  action: 'keep',
                  regex: 'container_network_transmit_packets_total|storage_operation_duration_seconds_count|container_fs_reads_total|kube_horizontalpodautoscaler_spec_min_replicas|kubelet_running_pods|kube_daemonset_updated_number_scheduled|kube_statefulset_status_replicas|kubelet_certificate_manager_client_expiration_renew_errors|kubelet_pod_worker_duration_seconds_count|cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits|kubelet_volume_stats_capacity_bytes|kubelet_volume_stats_available_bytes|container_memory_cache|kube_resourcequota|kube_deployment_status_replicas_available|kube_job_failed|kube_namespace_created|kubelet_runtime_operations_errors_total|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|kubelet_running_pod_count|container_memory_rss|node_namespace_pod_container:container_memory_cache|kube_deployment_spec_replicas|kubelet_runtime_operations_total|container_fs_reads_bytes_total|kube_pod_owner|kubelet_volume_stats_inodes_used|kube_deployment_status_replicas_updated|kube_statefulset_status_replicas_ready|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|rest_client_request_duration_seconds_bucket|storage_operation_duration_seconds_bucket|kube_statefulset_status_observed_generation|storage_operation_errors_total|cluster:namespace:pod_memory:active:kube_pod_container_resource_limits|kube_pod_container_resource_requests|container_fs_writes_bytes_total|container_network_receive_packets_total|kubelet_pleg_relist_duration_seconds_bucket|kubelet_node_config_error|kube_daemonset_status_number_available|kube_statefulset_metadata_generation|kube_node_spec_taint|process_resident_memory_bytes|kube_deployment_status_observed_generation|up|kube_statefulset_replicas|kube_job_spec_completions|kubernetes_build_info|kubelet_certificate_manager_server_ttl_seconds|kubelet_cgroup_manager_duration_seconds_count|kubelet_certificate_manager_client_ttl_seconds|kube_node_status_capacity|namespace_workload_pod:kube_pod_owner:relabel|namespace_memory:kube_pod_container_resource_limits:sum|kube_node_status_condition|container_cpu_cfs_periods_total|kube_node_status_allocatable|kube_horizontalpodautoscaler_status_desired_replicas|kube_statefulset_status_current_revision|kubelet_pod_worker_duration_seconds_bucket|node_namespace_pod_container:container_memory_swap|container_memory_working_set_bytes|namespace_cpu:kube_pod_container_resource_requests:sum|container_cpu_usage_seconds_total|container_memory_swap|kube_daemonset_status_number_misscheduled|process_cpu_seconds_total|namespace_cpu:kube_pod_container_resource_limits:sum|kube_job_status_succeeded|namespace_workload_pod|go_goroutines|kube_deployment_metadata_generation|kubelet_running_container_count|kubelet_pod_start_duration_seconds_count|namespace_memory:kube_pod_container_resource_requests:sum|kubelet_volume_stats_inodes|kubelet_server_expiration_renew_errors|kubelet_running_containers|kube_node_info|kube_statefulset_status_update_revision|kube_pod_container_status_waiting_reason|kube_horizontalpodautoscaler_spec_max_replicas|kubelet_pleg_relist_duration_seconds_count|container_network_receive_bytes_total|kubelet_node_name|machine_memory_bytes|node_namespace_pod_container:container_memory_working_set_bytes|kube_horizontalpodautoscaler_status_current_replicas|kube_replicaset_owner|container_network_transmit_bytes_total|container_network_receive_packets_dropped_total|kubelet_pleg_relist_interval_seconds_bucket|volume_manager_total_volumes|kubelet_cgroup_manager_duration_seconds_bucket|container_cpu_cfs_throttled_periods_total|cluster:namespace:pod_memory:active:kube_pod_container_resource_requests|kube_daemonset_status_current_number_scheduled|kube_statefulset_status_replicas_updated|kube_pod_container_resource_limits|container_fs_writes_total|kube_pod_status_phase|kube_daemonset_status_desired_number_scheduled|container_network_transmit_packets_dropped_total|kubelet_runtime_operations_duration_seconds_bucket|rest_client_requests_total|node_namespace_pod_container:container_memory_rss|kube_pod_info|node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile',
                  source_labels: ['__name__'],
                },
              ],
              relabel_configs: [
                {
                  replacement: 'kubernetes.default.svc.cluster.local:443',
                  target_label: '__address__',
                },
                {
                  regex: '(.+)',
                  replacement: '/api/v1/nodes/${1}/proxy/metrics/cadvisor',
                  source_labels: ['__meta_kubernetes_node_name'],
                  target_label: '__metrics_path__',
                },
              ],
              scheme: 'https',
              tls_config: {
                ca_file: '/var/run/secrets/kubernetes.io/serviceaccount/ca.crt',
                insecure_skip_verify: false,
                server_name: 'kubernetes',
              },
            },
            {
              bearer_token_file: '/var/run/secrets/kubernetes.io/serviceaccount/token',
              job_name: 'integrations/kubernetes/kubelet',
              kubernetes_sd_configs: [{ role: 'node' }],
              metric_relabel_configs: [
                {
                  action: 'keep',
                  regex: 'container_network_transmit_packets_total|storage_operation_duration_seconds_count|container_fs_reads_total|kube_horizontalpodautoscaler_spec_min_replicas|kubelet_running_pods|kube_daemonset_updated_number_scheduled|kube_statefulset_status_replicas|kubelet_certificate_manager_client_expiration_renew_errors|kubelet_pod_worker_duration_seconds_count|cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits|kubelet_volume_stats_capacity_bytes|kubelet_volume_stats_available_bytes|container_memory_cache|kube_resourcequota|kube_deployment_status_replicas_available|kube_job_failed|kube_namespace_created|kubelet_runtime_operations_errors_total|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|kubelet_running_pod_count|container_memory_rss|node_namespace_pod_container:container_memory_cache|kube_deployment_spec_replicas|kubelet_runtime_operations_total|container_fs_reads_bytes_total|kube_pod_owner|kubelet_volume_stats_inodes_used|kube_deployment_status_replicas_updated|kube_statefulset_status_replicas_ready|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|rest_client_request_duration_seconds_bucket|storage_operation_duration_seconds_bucket|kube_statefulset_status_observed_generation|storage_operation_errors_total|cluster:namespace:pod_memory:active:kube_pod_container_resource_limits|kube_pod_container_resource_requests|container_fs_writes_bytes_total|container_network_receive_packets_total|kubelet_pleg_relist_duration_seconds_bucket|kubelet_node_config_error|kube_daemonset_status_number_available|kube_statefulset_metadata_generation|kube_node_spec_taint|process_resident_memory_bytes|kube_deployment_status_observed_generation|up|kube_statefulset_replicas|kube_job_spec_completions|kubernetes_build_info|kubelet_certificate_manager_server_ttl_seconds|kubelet_cgroup_manager_duration_seconds_count|kubelet_certificate_manager_client_ttl_seconds|kube_node_status_capacity|namespace_workload_pod:kube_pod_owner:relabel|namespace_memory:kube_pod_container_resource_limits:sum|kube_node_status_condition|container_cpu_cfs_periods_total|kube_node_status_allocatable|kube_horizontalpodautoscaler_status_desired_replicas|kube_statefulset_status_current_revision|kubelet_pod_worker_duration_seconds_bucket|node_namespace_pod_container:container_memory_swap|container_memory_working_set_bytes|namespace_cpu:kube_pod_container_resource_requests:sum|container_cpu_usage_seconds_total|container_memory_swap|kube_daemonset_status_number_misscheduled|process_cpu_seconds_total|namespace_cpu:kube_pod_container_resource_limits:sum|kube_job_status_succeeded|namespace_workload_pod|go_goroutines|kube_deployment_metadata_generation|kubelet_running_container_count|kubelet_pod_start_duration_seconds_count|namespace_memory:kube_pod_container_resource_requests:sum|kubelet_volume_stats_inodes|kubelet_server_expiration_renew_errors|kubelet_running_containers|kube_node_info|kube_statefulset_status_update_revision|kube_pod_container_status_waiting_reason|kube_horizontalpodautoscaler_spec_max_replicas|kubelet_pleg_relist_duration_seconds_count|container_network_receive_bytes_total|kubelet_node_name|machine_memory_bytes|node_namespace_pod_container:container_memory_working_set_bytes|kube_horizontalpodautoscaler_status_current_replicas|kube_replicaset_owner|container_network_transmit_bytes_total|container_network_receive_packets_dropped_total|kubelet_pleg_relist_interval_seconds_bucket|volume_manager_total_volumes|kubelet_cgroup_manager_duration_seconds_bucket|container_cpu_cfs_throttled_periods_total|cluster:namespace:pod_memory:active:kube_pod_container_resource_requests|kube_daemonset_status_current_number_scheduled|kube_statefulset_status_replicas_updated|kube_pod_container_resource_limits|container_fs_writes_total|kube_pod_status_phase|kube_daemonset_status_desired_number_scheduled|container_network_transmit_packets_dropped_total|kubelet_runtime_operations_duration_seconds_bucket|rest_client_requests_total|node_namespace_pod_container:container_memory_rss|kube_pod_info|node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile',
                  source_labels: ['__name__'],
                },
              ],
              relabel_configs: [
                {
                  replacement: 'kubernetes.default.svc.cluster.local:443',
                  target_label: '__address__',
                },
                {
                  regex: '(.+)',
                  replacement: '/api/v1/nodes/${1}/proxy/metrics',
                  source_labels: ['__meta_kubernetes_node_name'],
                  target_label: '__metrics_path__',
                },
              ],
              scheme: 'https',
              tls_config: {
                ca_file: '/var/run/secrets/kubernetes.io/serviceaccount/ca.crt',
                insecure_skip_verify: false,
                server_name: 'kubernetes',
              },
            },
            {
              job_name: 'integrations/kubernetes/kube-state-metrics',
              kubernetes_sd_configs: [{ role: 'service' }],
              metric_relabel_configs: [
                {
                  action: 'keep',
                  regex: 'container_network_transmit_packets_total|storage_operation_duration_seconds_count|container_fs_reads_total|kube_horizontalpodautoscaler_spec_min_replicas|kubelet_running_pods|kube_daemonset_updated_number_scheduled|kube_statefulset_status_replicas|kubelet_certificate_manager_client_expiration_renew_errors|kubelet_pod_worker_duration_seconds_count|cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits|kubelet_volume_stats_capacity_bytes|kubelet_volume_stats_available_bytes|container_memory_cache|kube_resourcequota|kube_deployment_status_replicas_available|kube_job_failed|kube_namespace_created|kubelet_runtime_operations_errors_total|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|kubelet_running_pod_count|container_memory_rss|node_namespace_pod_container:container_memory_cache|kube_deployment_spec_replicas|kubelet_runtime_operations_total|container_fs_reads_bytes_total|kube_pod_owner|kubelet_volume_stats_inodes_used|kube_deployment_status_replicas_updated|kube_statefulset_status_replicas_ready|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|rest_client_request_duration_seconds_bucket|storage_operation_duration_seconds_bucket|kube_statefulset_status_observed_generation|storage_operation_errors_total|cluster:namespace:pod_memory:active:kube_pod_container_resource_limits|kube_pod_container_resource_requests|container_fs_writes_bytes_total|container_network_receive_packets_total|kubelet_pleg_relist_duration_seconds_bucket|kubelet_node_config_error|kube_daemonset_status_number_available|kube_statefulset_metadata_generation|kube_node_spec_taint|process_resident_memory_bytes|kube_deployment_status_observed_generation|up|kube_statefulset_replicas|kube_job_spec_completions|kubernetes_build_info|kubelet_certificate_manager_server_ttl_seconds|kubelet_cgroup_manager_duration_seconds_count|kubelet_certificate_manager_client_ttl_seconds|kube_node_status_capacity|namespace_workload_pod:kube_pod_owner:relabel|namespace_memory:kube_pod_container_resource_limits:sum|kube_node_status_condition|container_cpu_cfs_periods_total|kube_node_status_allocatable|kube_horizontalpodautoscaler_status_desired_replicas|kube_statefulset_status_current_revision|kubelet_pod_worker_duration_seconds_bucket|node_namespace_pod_container:container_memory_swap|container_memory_working_set_bytes|namespace_cpu:kube_pod_container_resource_requests:sum|container_cpu_usage_seconds_total|container_memory_swap|kube_daemonset_status_number_misscheduled|process_cpu_seconds_total|namespace_cpu:kube_pod_container_resource_limits:sum|kube_job_status_succeeded|namespace_workload_pod|go_goroutines|kube_deployment_metadata_generation|kubelet_running_container_count|kubelet_pod_start_duration_seconds_count|namespace_memory:kube_pod_container_resource_requests:sum|kubelet_volume_stats_inodes|kubelet_server_expiration_renew_errors|kubelet_running_containers|kube_node_info|kube_statefulset_status_update_revision|kube_pod_container_status_waiting_reason|kube_horizontalpodautoscaler_spec_max_replicas|kubelet_pleg_relist_duration_seconds_count|container_network_receive_bytes_total|kubelet_node_name|machine_memory_bytes|node_namespace_pod_container:container_memory_working_set_bytes|kube_horizontalpodautoscaler_status_current_replicas|kube_replicaset_owner|container_network_transmit_bytes_total|container_network_receive_packets_dropped_total|kubelet_pleg_relist_interval_seconds_bucket|volume_manager_total_volumes|kubelet_cgroup_manager_duration_seconds_bucket|container_cpu_cfs_throttled_periods_total|cluster:namespace:pod_memory:active:kube_pod_container_resource_requests|kube_daemonset_status_current_number_scheduled|kube_statefulset_status_replicas_updated|kube_pod_container_resource_limits|container_fs_writes_total|kube_pod_status_phase|kube_daemonset_status_desired_number_scheduled|container_network_transmit_packets_dropped_total|kubelet_runtime_operations_duration_seconds_bucket|rest_client_requests_total|node_namespace_pod_container:container_memory_rss|kube_pod_info|node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile',
                  source_labels: [
                    '__name__',
                  ],
                },
              ],
              relabel_configs: [
                {
                  action: 'keep',
                  regex: 'kube-state-metrics',  // This service name is for standard kube-state-metrics deployed by prometheus-ksonnet, not the helm chart.
                  source_labels: [
                    '__meta_kubernetes_service_name',
                  ],
                },
              ],
            },
          ],
        },
      ],
      global: {
        external_labels: {
          cluster: $._config.cluster,
        },
        scrape_interval: '60s',
      },
      wal_directory: '/tmp/grafana-agent-wal',
    },
    server: {
      http_listen_port: 12345,
    },
  },
}
