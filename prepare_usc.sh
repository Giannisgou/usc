#!/usr/bin/env bash

# Script: prepare_usc.sh
# ----------------------
# 4.1
# Σκοπός:
#   1. Αντιγράφει τα path.sh και cmd.sh από το egs/wsj στον τρέχοντα φάκελο (usc).
#   2. Θέτει τη μεταβλητή KALDI_ROOT μέσα στο path.sh.
#   3. Τροποποιεί τις train_cmd, decode_cmd, cuda_cmd στο cmd.sh ώστε να χρησιμοποιούν το run.pl.
#   4. Αντιγράφει (ή συνδέει) τους φακέλους steps, utils, local.

# 1) Ορισμός του path προς το Kaldi root
NEW_KALDI_ROOT="/Users/giannisgousios/kaldi"

# 2) Αντιγραφή path.sh & cmd.sh από egs/wsj/
echo "Αντιγράφω path.sh & cmd.sh από egs/wsj/..."
cp ../wsj/s5/path.sh .
cp ../wsj/s5/cmd.sh .

# 3) Τροποποίηση path.sh για να περιέχει το νέο KALDI_ROOT
echo "Τροποποίηση path.sh ώστε το KALDI_ROOT να είναι: ${NEW_KALDI_ROOT} ..."
sed -i "s|^export KALDI_ROOT=.*|export KALDI_ROOT=${NEW_KALDI_ROOT}|" path.sh

# 4) Ρυθμίσεις στο cmd.sh για train_cmd, decode_cmd, cuda_cmd
echo "Ρυθμίζω τις train_cmd, decode_cmd, cuda_cmd σε run.pl ..."
sed -i '' 's|^export train_cmd=.*|export train_cmd="run.pl"|' cmd.sh
sed -i '' 's|^export decode_cmd=.*|export decode_cmd="run.pl"|' cmd.sh
sed -i '' 's|^export cuda_cmd=.*|export cuda_cmd="run.pl"|' cmd.sh
sed -i '' 's/queue\.pl/run.pl/g' cmd.sh


# 5) Soft link των φακέλων steps, utils, local
echo "Αντιγραφή steps, utils, local από egs/wsj/..."
# Εναλλακτικά, για symlinks:
ln -s ../wsj/s5/steps steps
ln -s ../wsj/s5/utils utils

# 6) Δημιουργία φακέλου local και soft link για score_kaldi.sh
echo "Δημιουργία φακέλου local και soft link για score_kaldi.sh..."
mkdir -p local
# Το soft link δείχνει στο score_kaldi.sh που βρίσκεται μέσα στο steps (που βρίσκεται στον τρέχοντα φάκελο ως symlink)
ln -s ./steps/score_kaldi.sh local/score_kaldi.sh

# 7) Δημιουργία φακέλου conf και αντιγραφή του mfcc.conf
echo "Δημιουργία φακέλου conf και αντιγραφή του mfcc.conf..."
mkdir -p conf
cp mfcc.conf conf/

# 8) Δημιουργία φακέλων data/lang, data/local/dict, data/local/lm_tmp, data/local/nist_lm
echo "Δημιουργία φακέλων data/lang, data/local/dict, data/local/lm_tmp, data/local/nist_lm..."
mkdir -p data/lang data/local/dict data/local/lm_tmp data/local/nist_lm

echo "Η προετοιμασία ολοκληρώθηκε!"
