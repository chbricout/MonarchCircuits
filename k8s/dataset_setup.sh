# $1 is PVC name

if [ "$1" = "" ]; then
  echo "Missing PVC Name as first argument"
fi

file="imagenet_npz.zip"
expected_sha="e7ce462672a7f7bbdb2591b5f6600c8647c36e2ab74e0265434169b171f2d09f"

if [ -f "$file" ]; then
  echo "Zip dataset found"
  hash=$(sha256sum $file | awk '{print $1}')
  if [ "$hash" = "$expected_sha" ]; then
    echo "Hashes match"

    pod=$(PVC_NAME="$1" PATH_TO_PVC="/data" envsubst <generic/data-pod-template.yaml | kubectl create -f - | awk '{split($1,a,"/"); print a[2]}')
    if [ $? -ne 0 ]; then
      echo "Pod Creation Failed !"
      exit 1
    fi
    echo "Create Pod $pod"

    kubectl wait --for=condition=Ready "pod/$pod" --timeout=60s

    rsync -Pavc --blocking-io --rsh ~/kubectl-rsh.sh $file "$pod":/data/ --progress --timeout=120
    if [ $? -ne 0 ]; then
      echo "Rsync Failed !"
      exit 1
    fi
    echo "Copied zip to pod"

    kubectl exec "$pod" -- sh -c "cd data; unzip $file"
    if [ $? -ne 0 ]; then
      echo "Unzip Failed !"
      exit 1
    fi
    echo "Dataset unziped"

    kubectl exec "$pod" -- sh -c "mv /data/datasets/* /data/; chmod -R o+r data/*"
    if [ $? -ne 0 ]; then
      echo "Moving dataset Failed !"
      exit 1
    fi
    echo "Moved dataset to PVC root"

    kubectl delete pod "$pod"
    if [ $? -ne 0 ]; then
      echo "Pod Deletion Failed !"
      exit 1
    fi
    echo "Pod deleted"
  else
    echo "Hashes differ"
    exit 1
  fi
else
  echo "Zip dataset is missing"
  exit 1
fi
