for kernel_size in 1 2 4 8 16 32; do
  for layer_type in "dense" "monarch"; do
    job_yaml=$(EXP_ARGS="-hs 1024 -ds imagenet32 -ly $layer_type  -ps $kernel_size -sloc output/32_${kernel_size}x${kernel_size}_lossy_${layer_type}.jpc" envsubst <train-template.yaml)
    job=$(echo $job_yaml | kubectl create -f - | awk '{print $1}')
    echo "Launched job for layer: $layer_type, kernel: $kernel_size ($job)"
  done
done
