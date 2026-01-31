#!/bin/bash

echo "📦 Démarrage de Wakerr (Radarr/Sonarr search...)"
echo "⏱️  Intervalle : $INTERVAL_HOURS heures"

while true; do
  ./search.sh
  echo "✅ Requête terminée. Prochaine exécution dans $INTERVAL_HOURS heures..."
  sleep $((INTERVAL_HOURS * 3600))
done
