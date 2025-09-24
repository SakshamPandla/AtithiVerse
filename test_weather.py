#!/usr/bin/env python3
"""
Weather API Test Script
Tests the weather endpoints to ensure they're working properly
"""

import requests
import json
import time

def test_weather_api():
    """Test the weather API endpoints"""
    base_url = "http://127.0.0.1:5000"
    
    print("🌤️ Testing Weather API Endpoints...")
    print("=" * 50)
    
    # Test cities
    test_cities = ["Agra", "Goa", "Jaipur", "Kochi", "Shimla"]
    
    for city in test_cities:
        print(f"\n📍 Testing weather for: {city}")
        
        # Test current weather
        try:
            response = requests.get(f"{base_url}/api/weather/{city}", timeout=10)
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    print(f"✅ Current weather: {data['temperature']}°C, {data['weather_description']}")
                else:
                    print(f"❌ Weather API error: {data.get('error')}")
            else:
                print(f"❌ HTTP error: {response.status_code}")
        except Exception as e:
            print(f"❌ Request failed: {e}")
        
        # Test 5-day forecast
        try:
            response = requests.get(f"{base_url}/api/weather/forecast/{city}", timeout=10)
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    print(f"✅ 5-day forecast: {len(data['forecast'])} days available")
                    for day in data['forecast'][:2]:  # Show first 2 days
                        print(f"   {day['day_name']}: {day['min_temp']}°-{day['max_temp']}°C, {day['weather_description']}")
                else:
                    print(f"❌ Forecast API error: {data.get('error')}")
            else:
                print(f"❌ HTTP error: {response.status_code}")
        except Exception as e:
            print(f"❌ Request failed: {e}")
        
        time.sleep(1)  # Rate limiting
    
    print("\n" + "=" * 50)
    print("🎉 Weather API testing completed!")

if __name__ == "__main__":
    test_weather_api()
