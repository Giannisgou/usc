#!/bin/bash
# 4.4.1
source path.sh || exit 1;

data_dir=data/train
lang_dir=data/lang
exp_dir=exp/mono

echo "Εκπαίδευση monophone μοντέλου..."
steps/train_mono.sh $data_dir $lang_dir $exp_dir

echo "Η εκπαίδευση του monophone μοντέλου ολοκληρώθηκε. Τα αποτελέσματα βρίσκονται στο $exp_dir."
