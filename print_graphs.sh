#!/usr/bin/env bash
set -e
source path.sh

# Φάκελος με το Γλωσσικό Μοντέλο (περιέχει G.fst)
LANG_DIR="data/lang_test"

# ===========================
# MONOPHONE GRAPH BUILD
# ===========================
MONO_MODEL_DIR="exp/mono"
MONO_GRAPH_DIR="$MONO_MODEL_DIR/graph"
echo "🔧 Δημιουργία HCLG για το Monophone μοντέλο..."
mkdir -p $MONO_GRAPH_DIR
utils/mkgraph.sh --mono $LANG_DIR $MONO_MODEL_DIR $MONO_GRAPH_DIR || exit 1
echo "✅ Ολοκληρώθηκε: $MONO_GRAPH_DIR/HCLG.fst"

# ===========================
# TRIPHONE GRAPH BUILD
# ===========================
TRI_MODEL_DIR="exp/tri_deltas"
TRI_GRAPH_DIR="$TRI_MODEL_DIR/graph"
echo "🔧 Δημιουργία HCLG για το Triphone μοντέλο..."
mkdir -p $TRI_GRAPH_DIR
utils/mkgraph.sh $LANG_DIR $TRI_MODEL_DIR $TRI_GRAPH_DIR || exit 1
echo "✅ Ολοκληρώθηκε: $TRI_GRAPH_DIR/HCLG.fst"

echo "🎯 Η δημιουργία των HCLG γραφών για mono και tri_deltas ολοκληρώθηκε!"
