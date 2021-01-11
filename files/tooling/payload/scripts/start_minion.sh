export PATH=/home/saltmaster/miniconda3/bin:$PATH
source /home/saltmaster/miniconda3/etc/profile.d/conda.sh
conda activate salt
python -V
salt-minion -d
