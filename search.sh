#!/bin/bash

echo "🔍 Début des recherches à $(date)"

# === RADARR ===
echo ""
echo "🎬 Radarr: Recherche des films sans fichiers..."

radarr_response=$(curl -s -H "X-Api-Key: $RADARR_API_KEY" "$RADARR_URL/api/v3/movie")

if echo "$radarr_response" | jq empty 2>/dev/null; then
  echo "$radarr_response" | jq -c '.[] | select(.hasFile == false)' | while read -r movie; do
    id=$(echo "$movie" | jq -r '.id')
    title=$(echo "$movie" | jq -r '.title')
    echo "  ➤ Recherche: $title (ID $id)"
    curl -s -X POST "$RADARR_URL/api/v3/command" \
      -H "X-Api-Key: $RADARR_API_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"name\": \"MoviesSearch\", \"movieIds\": [$id]}" > /dev/null
  done
else
  echo "❌ Erreur Radarr : réponse non JSON. Voici un aperçu :"
  echo "$radarr_response" | head -n 10
fi

# === SONARR ===
echo ""
echo "📺 Sonarr: Recherche des épisodes manquants..."

sonarr_response=$(curl -s -H "X-Api-Key: $SONARR_API_KEY" "$SONARR_URL/api/v3/series")

if echo "$sonarr_response" | jq empty 2>/dev/null; then
  echo "$sonarr_response" | jq -c '.[]' | while read -r series; do
    seriesId=$(echo "$series" | jq -r '.id')
    title=$(echo "$series" | jq -r '.title')

    episodes_response=$(curl -s "$SONARR_URL/api/v3/episode?seriesId=$seriesId" -H "X-Api-Key: $SONARR_API_KEY")

    if echo "$episodes_response" | jq empty 2>/dev/null; then
      missing=$(echo "$episodes_response" | jq '[.[] | select(.hasFile == false and .monitored == true)] | length')

      if [ "$missing" -gt 0 ]; then
        echo "  ➤ Recherche: $title ($missing épisodes)"
        curl -s -X POST "$SONARR_URL/api/v3/command" \
          -H "X-Api-Key: $SONARR_API_KEY" \
          -H "Content-Type: application/json" \
          -d "{\"name\": \"SeriesSearch\", \"seriesId\": $seriesId}" > /dev/null
      fi
    else
      echo "  ⚠️  Erreur JSON pour les épisodes de $title"
    fi
  done
else
  echo "❌ Erreur Sonarr : réponse non JSON. Voici un aperçu :"
  echo "$sonarr_response" | head -n 10
fi

echo ""
echo "✅ Recherches terminées à $(date)"
