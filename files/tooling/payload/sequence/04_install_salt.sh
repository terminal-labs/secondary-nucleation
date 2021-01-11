apt install -y ntp curl wget rsync zip unzip build-essential nano git python-software-properties python-dev python-m2crypto python-virtualenv zlib1g-dev libffi-dev python3-dev

su -m $USERNAME <<'EOF'
  wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
  bash Miniconda3-latest-Linux-x86_64.sh -b

  wget https://tl-build-resources.s3-accelerate.amazonaws.com/2018.3.3.zip
  unzip 2018.3.3.zip -d unzipped

  export PATH=~/platform/miniconda3/bin:$PATH
  source ~/miniconda3/etc/profile.d/conda.sh

  conda update -y -n base -c defaults conda
  conda --version
  conda update -y conda
  conda --version
  conda create -y -n salt python=3.6.9

  conda activate salt

  cd unzipped
  cd 2018.3.3/salt
  pip install msgpack==0.6.2
  pip install pyzmq==17.0 PyYAML pycrypto msgpack-python jinja2 psutil futures tornado
  pip install -e .
EOF
