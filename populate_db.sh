#!/bin/bash

BASE_URL="http://localhost:8080/api"

echo "=== Populating Database with Sample Data ==="

# First, register a user to get a token
echo "1. Creating test user..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "displayName": "Admin User",
    "email": "admin@example.com",
    "password": "password123",
    "bio": "Sample admin user for testing"
  }')

TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "Failed to get token. Trying to login instead..."
  LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d '{
      "email": "admin@example.com",
      "password": "password123"
    }')
  TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
fi

echo "Got token: ${TOKEN:0:20}..."

# Create Entities
echo -e "\n2. Creating entities..."

ENTITY1=$(curl -s -X POST "$BASE_URL/entities" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "The Castro Theatre",
    "address": "429 Castro St, San Francisco, CA 94114"
  }' | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo "Created: The Castro Theatre"

ENTITY2=$(curl -s -X POST "$BASE_URL/entities" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Golden Gate Park",
    "address": "Golden Gate Park, San Francisco, CA 94122"
  }' | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo "Created: Golden Gate Park"

ENTITY3=$(curl -s -X POST "$BASE_URL/entities" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "The Fillmore",
    "address": "1805 Geary Blvd, San Francisco, CA 94115"
  }' | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo "Created: The Fillmore"

ENTITY4=$(curl -s -X POST "$BASE_URL/entities" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Dolores Park",
    "address": "Dolores St & 19th St, San Francisco, CA 94114"
  }' | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo "Created: Dolores Park"

# Create Events
echo -e "\n3. Creating events..."

curl -s -X POST "$BASE_URL/events" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"name\": \"Indie Film Festival\",
    \"date\": \"2025-11-15T19:00:00Z\",
    \"entityID\": \"$ENTITY1\",
    \"eventDescription\": \"A weekend celebration of independent cinema featuring award-winning films from around the world.\",
    \"link\": \"https://example.com/indie-fest\"
  }" > /dev/null
echo "Created: Indie Film Festival"

curl -s -X POST "$BASE_URL/events" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"name\": \"Jazz Night with Miles Tribute Band\",
    \"date\": \"2025-11-08T20:00:00Z\",
    \"entityID\": \"$ENTITY3\",
    \"eventDescription\": \"Experience the magic of Miles Davis performed by the acclaimed tribute band.\",
    \"link\": \"https://example.com/jazz-night\"
  }" > /dev/null
echo "Created: Jazz Night"

curl -s -X POST "$BASE_URL/events" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"name\": \"Outdoor Yoga & Meditation\",
    \"date\": \"2025-10-25T09:00:00Z\",
    \"entityID\": \"$ENTITY2\",
    \"eventDescription\": \"Start your weekend with a peaceful yoga session in the park. All levels welcome!\",
    \"link\": \"https://example.com/yoga\"
  }" > /dev/null
echo "Created: Outdoor Yoga"

curl -s -X POST "$BASE_URL/events" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"name\": \"Summer Concert Series: Rock Legends\",
    \"date\": \"2025-12-01T18:00:00Z\",
    \"entityID\": \"$ENTITY3\",
    \"eventDescription\": \"Three bands paying tribute to classic rock legends. Food trucks and beer garden open at 5pm.\",
    \"link\": \"https://example.com/summer-concerts\"
  }" > /dev/null
echo "Created: Summer Concert Series"

curl -s -X POST "$BASE_URL/events" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"name\": \"Food Truck Festival\",
    \"date\": \"2025-11-20T12:00:00Z\",
    \"entityID\": \"$ENTITY4\",
    \"eventDescription\": \"Over 30 food trucks featuring cuisines from around the world. Live music all day!\",
    \"link\": \"https://example.com/food-trucks\"
  }" > /dev/null
echo "Created: Food Truck Festival"

curl -s -X POST "$BASE_URL/events" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"name\": \"Classic Movie Night: Casablanca\",
    \"date\": \"2025-10-30T19:30:00Z\",
    \"entityID\": \"$ENTITY1\",
    \"eventDescription\": \"See this timeless classic on the big screen with live piano accompaniment.\",
    \"link\": \"https://example.com/casablanca\"
  }" > /dev/null
echo "Created: Classic Movie Night"

# Create Topics
echo -e "\n4. Creating topics..."

TOPIC1=$(curl -s -X POST "$BASE_URL/topics" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Movies & TV",
    "topicDescription": "Discuss your favorite films, TV shows, and what you are watching"
  }' | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo "Created: Movies & TV"

TOPIC2=$(curl -s -X POST "$BASE_URL/topics" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Books & Reading",
    "topicDescription": "Share book recommendations and discuss what you are reading"
  }' | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo "Created: Books & Reading"

TOPIC3=$(curl -s -X POST "$BASE_URL/topics" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Music",
    "topicDescription": "Talk about your favorite artists, albums, and concerts"
  }' | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo "Created: Music"

TOPIC4=$(curl -s -X POST "$BASE_URL/topics" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Food & Restaurants",
    "topicDescription": "Share restaurant reviews and cooking tips"
  }' | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo "Created: Food & Restaurants"

TOPIC5=$(curl -s -X POST "$BASE_URL/topics" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Travel",
    "topicDescription": "Share travel stories and destination recommendations"
  }' | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo "Created: Travel"

TOPIC6=$(curl -s -X POST "$BASE_URL/topics" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Technology",
    "topicDescription": "Discuss the latest tech news, gadgets, and innovations"
  }' | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo "Created: Technology"

# Create Topic Posts
echo -e "\n5. Creating topic posts..."

# Movies & TV posts
curl -s -X POST "$BASE_URL/topics/$TOPIC1/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "Just finished watching The Bear season 2. The tension in every episode is incredible! Anyone else watching?"
  }' > /dev/null

curl -s -X POST "$BASE_URL/topics/$TOPIC1/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "Dune Part 2 was absolutely stunning in IMAX. The cinematography is worth seeing on the biggest screen possible."
  }' > /dev/null

curl -s -X POST "$BASE_URL/topics/$TOPIC1/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "Hot take: The original Blade Runner is better than 2049. The atmosphere and noir aesthetic cant be beat."
  }' > /dev/null
echo "Created 3 posts in Movies & TV"

# Books posts
curl -s -X POST "$BASE_URL/topics/$TOPIC2/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "Finally reading Project Hail Mary and I cant put it down! If you liked The Martian, you will love this one."
  }' > /dev/null

curl -s -X POST "$BASE_URL/topics/$TOPIC2/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "Looking for sci-fi recommendations. Just finished the Three Body Problem trilogy and need something similar!"
  }' > /dev/null

curl -s -X POST "$BASE_URL/topics/$TOPIC2/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "Anyone else rereading their favorite books? Just started Harry Potter again and its like visiting old friends."
  }' > /dev/null
echo "Created 3 posts in Books & Reading"

# Music posts
curl -s -X POST "$BASE_URL/topics/$TOPIC3/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "Saw Tame Impala last night at the Fillmore. Absolutely mind-blowing light show and sound!"
  }' > /dev/null

curl -s -X POST "$BASE_URL/topics/$TOPIC3/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "What are your top albums of 2024? Mine: 1. The new Radiohead 2. Kendrick latest 3. Arlo Parks"
  }' > /dev/null

curl -s -X POST "$BASE_URL/topics/$TOPIC3/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "Vinyl collecting is getting expensive but theres nothing like the warm sound of a record player."
  }' > /dev/null
echo "Created 3 posts in Music"

# Food posts
curl -s -X POST "$BASE_URL/topics/$TOPIC4/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "Best tacos in SF? I vote La Taqueria in the Mission. That carne asada is unbeatable."
  }' > /dev/null

curl -s -X POST "$BASE_URL/topics/$TOPIC4/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "Made homemade pasta for the first time. So much work but totally worth it! Any tips for a beginner?"
  }' > /dev/null

curl -s -X POST "$BASE_URL/topics/$TOPIC4/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "Coffee nerds: whats your brewing method? Ive been using a V60 and loving the clarity of flavor."
  }' > /dev/null
echo "Created 3 posts in Food & Restaurants"

# Travel posts
curl -s -X POST "$BASE_URL/topics/$TOPIC5/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "Just got back from Iceland. The northern lights were absolutely magical. Best trip of my life!"
  }' > /dev/null

curl -s -X POST "$BASE_URL/topics/$TOPIC5/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "Looking for budget travel tips for SE Asia. Planning 3 months starting in Thailand. Where should I go?"
  }' > /dev/null
echo "Created 2 posts in Travel"

# Technology posts
curl -s -X POST "$BASE_URL/topics/$TOPIC6/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "The new iPhone camera system is impressive, but is it worth the upgrade from 14 Pro? Discuss."
  }' > /dev/null

curl -s -X POST "$BASE_URL/topics/$TOPIC6/posts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "content": "AI coding assistants are getting scary good. What tools are you using for development?"
  }' > /dev/null
echo "Created 2 posts in Technology"

echo -e "\n=== Database Population Complete! ==="
echo "Summary:"
echo "- 4 Entities created"
echo "- 6 Events created"
echo "- 6 Topics created"
echo "- 17 Topic Posts created"
