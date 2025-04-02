#!/bin/bash
set -e
source ./path.sh
# run_unigram.sh
# -------------
# Σκοπός:
#   1. Αντιγράφει το score.sh από το wsj (μέσω του ../wsj/s5/local/score.sh) στο τοπικό φάκελο local.
#   2. Αντιγράφει το G.fst από το data/lang_phones_bg στον φάκελο data/lang.
#   3. Δημιουργεί το HCLG γράφο με το utils/mkgraph.sh χρησιμοποιώντας το monophone μοντέλο.
#   4. Εκτελεί το decoding για τα dev και test set.
#   5. Τυπώνει τα αποτελέσματα PER για τα dev και test set.
#
# Βεβαιώσου ότι έχεις κάνει "source path.sh" πριν τρέξεις αυτό το script,
# ώστε να φορτωθούν οι διαδρομές και τα εργαλεία του Kaldi.

# Αντιγραφή score.sh
echo "Αντιγραφή score.sh από ../wsj/s5/local/score.sh στο ./local/score.sh..."
cp ../wsj/s5/local/score.sh ./local/score.sh

# Αντιγραφή του G.fst από το data/lang_phones_bg στο data/lang
echo "Αντιγραφή του G.fst από data/lang_phones_bg στο data/lang..."
cp ./data/lang_train/G_ug.fst ./data/lang/G_ug.fst

# 4.4.2: Δημιουργία του HCLG γράφου
echo "Δημιουργία HCLG γράφου (HCLG) χρησιμοποιώντας utils/mkgraph.sh..."
utils/mkgraph.sh --mono data/lang exp/mono exp/mono/graph_nosp_tgpr || exit 1

# 4.4.3: Decoding για το dev (validation) set
echo "Decoding για το dev set..."
steps/decode.sh exp/mono/graph_nosp_tgpr data/dev exp/mono/decode_dev || exit 1

# Decoding για το test set
echo "Decoding για το test set..."
steps/decode.sh exp/mono/graph_nosp_tgpr data/test exp/mono/decode_test || exit 1

# 4.4.4: Τύπωση PER αποτελεσμάτων
echo "Printing PER results for test: "
./local/score.sh data/test ./data/lang ./exp/mono/decode_test/

echo "Printing PER results for dev: "
./local/score.sh data/dev ./data/lang ./exp/mono/decode_dev/

echo "Το decoding και η αξιολόγηση ολοκληρώθηκαν!"
