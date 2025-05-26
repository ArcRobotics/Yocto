bitbake package-index
dev_dir="build/tmp/deploy/deb"
cd ${dev_dir}
echo "Starting a package serve at ${dev_dir}"
python3 -m http.server  8000 --bind 0.0.0.0
