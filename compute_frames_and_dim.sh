#!/bin/bash
# compute_frames_and_dim.sh
# Σκοπός:
#   1. Εμφανίζει τον αριθμό των frames για τις 5 πρώτες προτάσεις του training set.
#   2. Εμφανίζει τη διάσταση των χαρακτηριστικών.
#
# Υποθέτει ότι υπάρχει το αρχείο feats.scp στο data/train που περιέχει τα MFCCs.
source ./path.sh

echo "Number of frames for the first 5 utterances of the training set:"
feat-to-len scp:data/train/feats.scp ark,t:- | head -n 5

echo ""
echo "Feature dimension (same for all utterances):"
feat-to-dim scp:data/train/feats.scp -
